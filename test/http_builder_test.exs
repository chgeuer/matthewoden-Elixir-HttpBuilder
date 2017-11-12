defmodule HttpBuilderTest do
  use ExUnit.Case, async: true

  import HttpBuilder

  alias HttpBuilder.HttpRequest
  alias HttpBuilder.Adapters

  doctest HttpBuilder

  
  test "new adds a host and adapter to a request" do
    request = new("google.com", Adapters.HTTPosion)
    assert request.host  == "google.com"
    assert request.adapter == Adapters.HTTPosion
  end


  @methods [:get, :put, :post, :patch, :delete, :options, :connect]
  
  test "each HTTP method adds their method to the request" do
    Enum.each(@methods, fn method ->
      request = apply(HttpBuilder, method, [%HttpRequest{}])
      assert request.method == method
    end)
  end


  test "each HTTP method can take an optional path" do
    Enum.each(@methods, fn method ->
      request = apply(HttpBuilder, method, [%HttpRequest{}, "/location"])
      assert request.path == "/location"
    end)
  end

  test "with_query_params appends a list of two-item tuples to the request query params" do
    request = 
      %HttpRequest{}
      |> with_query_params([{"test", "true"}, {"also", "true"}])
    
    assert request.query_params == [{"test", "true"}, {"also", "true"}]
    
    request = 
      request
      |> with_query_params([{"another", "param"}])

    assert request.query_params == [{"another", "param"}, {"test", "true"}, {"also", "true"}]
  end


  test "with_query_params transforms a map into a list of two-item tuples, appending it to the request" do
    request = 
      %HttpRequest{}
      |> with_query_params(%{"test" => "true", "also" => "true"})
    
    assert request.query_params == [{"also", "true"}, {"test", "true"}]
    
    request = 
      request
      |> with_query_params(%{"another" => "param"})

    assert request.query_params == [{"another", "param"}, {"also", "true"}, {"test", "true"}]
  end

  test "with_headers appends a list of two-item tuples to the request query params" do
    request = 
      %HttpRequest{}
      |> with_headers([{"test", "true"}, {"also", "true"}])
    
    assert request.headers == [{"test", "true"}, {"also", "true"}]
    
    request = 
      request
      |> with_headers([{"another", "param"}])

    assert request.headers == [{"another", "param"}, {"test", "true"}, {"also", "true"}]
  end


  test "with_headers takes a list of two-item tuples, appending it to the request" do
    request = 
      %HttpRequest{}
      |> with_headers(%{"test" => "true", "also" => "true"})
    
    assert request.headers == [{"also", "true"}, {"test", "true"}]
    
    request = 
      request
      |> with_headers(%{"another" => "param"})

    assert request.headers == [{"another", "param"}, {"also", "true"}, {"test", "true"}]
  end


  test "with_headers transforms a map into a list of two-item tuples, appending it to the request" do
    request = 
      %HttpRequest{}
      |> with_headers(%{"test" => "true", "also" => "true"})
    
    assert request.headers == [{"also", "true"}, {"test", "true"}]
    
    request = 
      request
      |> with_headers(%{"another" => "param"})

    assert request.headers == [{"another", "param"}, {"also", "true"}, {"test", "true"}]
  end


  test "with_body adds the body to the request" do
    request = 
      %HttpRequest{}
      |> with_body(%{"test" => true})

    assert request.body == %{"test" => true}
  end

  test "with_stream_body marks the body as a streaming enumerable" do
    request = 
      %HttpRequest{}
      |> with_stream_body(["alpha", "beta"])

    assert request.body == {:stream ,["alpha", "beta"] }
  end

  test "with_file_body mark the request body as a path-based upload." do
    request = 
      %HttpRequest{}
      |> with_file_body("/path/to/file")

    assert request.body == {:file,"/path/to/file" }
  end

  test "with_form_encoded_body takes a list of two-item tuples, and marks the request body as form-encoded." do
    request = 
      %HttpRequest{}
      |> with_form_encoded_body([{"test", "true"}])

    assert request.body == {:form, [{"test", "true"}] }
  end
  
  test "with_request_timeout marks the time limit for the overall request" do
    request = 
      %HttpRequest{}
      |> with_request_timeout(3)

    assert request.req_timeout == 3
  end

    
  test "with_recieve_timeout marks the time limit to receive a connection." do
    request = 
      %HttpRequest{}
      |> with_request_timeout(3)

    assert request.req_timeout == 3
  end


  test "with_retry marks how many attempts should be made in the event of network failure." do
    request = 
      %HttpRequest{}
      |> with_retry(3)

    assert request.retry == 3
  end

  test "with_options appends a single item to a list of additional options" do
    request = 
      %HttpRequest{}
      |> with_options(amazing_feature: true)

    assert request.options == [{:amazing_feature, true}]
  end

  test "with_options appends a list of additional options" do
    request = 
      %HttpRequest{}
      |> with_options([amazing_feature: true])
      |> with_options([other_feature: true, final_feature: false])

    assert request.options == [
      {:other_feature, true}, 
      {:final_feature, false},
      {:amazing_feature, true}
    ]

  end


  

end
