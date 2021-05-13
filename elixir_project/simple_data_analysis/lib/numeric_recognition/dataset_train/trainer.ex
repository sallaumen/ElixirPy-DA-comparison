defmodule NumericRecognition.DatasetTrain.Trainer do
  alias NumericRecognition.DatasetTrain.TrainerNumericalDefinition
  alias NumericRecognition.DatasetParse.Parser

  def execute() do
    analyse_size = 0..29
    train_images = File.read!("dataset/train-images-idx3-ubyte.gz") |> :zlib.gunzip()
    expected_result = File.read!("dataset/train-labels-idx1-ubyte.gz") |> :zlib.gunzip()
    {images, labels} = Parser.get_data(train_images, expected_result, analyse_size)

    zip = zip_images_with_labels({images, labels})

    params =
      TrainerNumericalDefinition.get_or_train_neural_network(:train, "predictions_v1", zip, 1)

    [fbi | _] = images

    TrainerNumericalDefinition.predict(params, fbi[analyse_size])
    |> to_result_output()

    :ok
  end

  def execute_with_axon() do
#    analyse_size = 0..29
#    train_images = File.read!("dataset/train-images-idx3-ubyte.gz") |> :zlib.gunzip()
#    expected_result = File.read!("dataset/train-labels-idx1-ubyte.gz") |> :zlib.gunzip()
#    {images, labels} = Parser.get_data(train_images, expected_result, analyse_size)
#    zip = zip_images_with_labels({images, labels})
#
#    model =
#      Axon.input({nil, 784})
#      |> Axon.dense(128, activation: :relu)
#      |> Axon.dense(10, activation: :softmax)
#      |> Axon.Training.step(:categorical_cross_entropy, Axon.Optimizers.adam(0.01))
#      |> Axon.Training.train(images, labels, compiler: EXLA, epochs: 5, log_every: 100)
    :ok
  end

  defp zip_images_with_labels({images, labels}) do
    Enum.zip(images, labels)
    |> Enum.with_index()
  end

  defp to_result_output(predictions) do
    result_array =
      predictions
      |> Nx.to_flat_list()
      |> Enum.chunk_every(10)
      |> Enum.map(fn list -> list |> Enum.zip(0..9) end)
      |> Enum.map(fn list -> Enum.max(list) end)
      |> Enum.map(fn zip ->
        {_probability, index} = zip
        index
      end)

    IO.puts("Real output:")
    IO.inspect(result_array)
  end
end
