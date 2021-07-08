defmodule MultiplayerWeb.Router do
  use MultiplayerWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", MultiplayerWeb do
    pipe_through :browser

    get "/", PageController, :index
  end

  scope "/api", MultiplayerWeb do
    pipe_through :api
    post "/broadcast", BroadcastController, :post
    resources "/projects", ProjectController
    resources "/scopes", ScopeController
  end

  scope "/api/swagger" do
    forward "/", PhoenixSwagger.Plug.SwaggerUI,
      otp_app: :multiplayer,
      swagger_file: "swagger.json"
  end

  def swagger_info do
    %{
      schemes: ["http", "https"],
      info: %{
        version: "1.0",
        title: "Multiplayer",
        description: "API Documentation for Multiplayer v1",
        termsOfService: "Open for public"
      },
      securityDefinitions: %{
        Bearer: %{
          type: "apiKey",
          name: "Authorization",
          description:
          "API Token must be provided via `Authorization: Bearer ` header",
      in: "header"
        }
      },
      consumes: ["application/json"],
      produces: ["application/json"],
      tags: [
        %{name: "Projects"},
        %{name: "Broadcast"}
      ]
    }
  end

  # Enables LiveDashboard only for development
  #
  # If you want to use the LiveDashboard in production, you should put
  # it behind authentication and allow only admins to access it.
  # If your application does not have an admins-only section yet,
  # you can use Plug.BasicAuth to set up some basic authentication
  # as long as you are also using SSL (which you should anyway).
  if Mix.env() in [:dev, :test] do
    import Phoenix.LiveDashboard.Router

    scope "/" do
      pipe_through :browser
      live_dashboard "/dashboard", metrics: MultiplayerWeb.Telemetry
    end
  end
end
