defmodule NumericRecognition.DatasetParser.Parser do

  def get_data(train_images, expected_result) do
    <<_::32, n_images::32, n_rows::32, n_cols::32, images::binary>> = train_images

    <<_::32, n_labels::32, labels::binary>> = expected_result
    gross_images = parse_dataset_group(n_images, n_rows, n_cols, images)
    labels = sanitize_labels(n_labels, labels)
    {gross_images, labels}
  end

  def parse_dataset_group(n_images, n_rows, n_cols, images) do
    argument = {n_images, n_rows, n_cols, images}
    get_images_array(argument)
  end

  defp sanitize_labels(n_labels, labels) do
    labels
    |> Nx.from_binary({:u, 8})
    |> Nx.reshape({n_labels, 1}, names: [:batch, :output])
    |> Nx.equal(Nx.tensor(Enum.to_list(0..9)))
    |> Nx.to_batched_list(30)
  end

  defp get_images_array({n_images, n_rows, n_cols, images}) do
    shape_size = n_rows * n_cols
    images
    |> Nx.from_binary({:u, 8})
    |> Nx.reshape({n_images, shape_size}, names: [:batch, :input])
    |> Nx.divide(255)
    |> Nx.to_batched_list(30)
  end

end