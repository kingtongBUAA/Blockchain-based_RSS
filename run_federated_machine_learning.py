import collections
import numpy as np
import tensorflow as tf
import tensorflow_federated as tff
emnist_train, emnist_test = tff.simulation.datasets.emnist.load_data()
emnist_train.element_type_structure
example_dataset = emnist_train.create_tf_dataset_for_client(emnist_train.client_ids[0])
example_element = next(iter(example_dataset))
example_element['label'].numpy()
NUM_CLIENTS = 10
NUM_EPOCHS = 5
BATCH_SIZE = 20
SHUFFLE_BUFFER = 100
PREFETCH_BUFFER=10
def preprocess(dataset):
  def batch_format_fn(element):
    return collections.OrderedDict(x=tf.reshape(element['pixels'], [-1, 784]),y=tf.reshape(element['label'], [-1, 1]))
  return dataset.repeat(NUM_EPOCHS).shuffle(SHUFFLE_BUFFER).batch(BATCH_SIZE).map(batch_format_fn).prefetch(PREFETCH_BUFFER)
preprocessed_example_dataset = preprocess(example_dataset)
sample_batch = tf.nest.map_structure(lambda x: x.numpy(),next(iter(preprocessed_example_dataset)))
sample_batch
def make_federated_data(client_data, client_ids):
  return [
      preprocess(client_data.create_tf_dataset_for_client(x))
      for x in client_ids
  ]
sample_clients = emnist_train.client_ids[0:NUM_CLIENTS]
federated_train_data = make_federated_data(emnist_train, sample_clients)
def create_keras_model():
  return tf.keras.models.Sequential([
      tf.keras.layers.Input(shape=(784,)),
      tf.keras.layers.Dense(10, kernel_initializer='zeros'),
      tf.keras.layers.Softmax(),
  ])
def model_fn():
  keras_model = create_keras_model()
  return tff.learning.from_keras_model(
      keras_model,
      dummy_batch=sample_batch,
      loss=tf.keras.losses.SparseCategoricalCrossentropy(),
      metrics=[tf.keras.metrics.SparseCategoricalAccuracy()])
iterative_process = tff.learning.build_federated_averaging_process(model_fn,client_optimizer_fn=lambda: tf.keras.optimizers.SGD(learning_rate=0.02),server_optimizer_fn=lambda: tf.keras.optimizers.SGD(learning_rate=1.0))
state = iterative_process.initialize()
state, metrics = iterative_process.next(state, federated_train_data)
NUM_ROUNDS =100
logdir = "/tmp/logs/scalars/training/"
summary_writer = tf.summary.create_file_writer(logdir)
state = iterative_process.initialize()
with summary_writer.as_default():
  for round_num in range(1, NUM_ROUNDS):
    state, metrics = iterative_process.next(state, federated_train_data)
    for name, value in metrics._asdict().items():
      tf.summary.scalar(name, value, step=round_num)
	  