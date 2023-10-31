defmodule TicWeb.SiteComponents do
  @moduledoc """
  Provides site's UI components.
  """
  use Phoenix.Component
  import TicWeb.CoreComponents
  import TicWeb.GameComponents
  # alias Phoenix.LiveView.JS

  @doc """
  Renders contents within a card
  """
  attr :class, :string, default: nil
  slot :inner_block, required: true

  def card(assigns) do
    ~H"""
    <div class={[
      "bg-gray-700 shadow rounded-lg p-4 sm:p-6 xl:p-8",
      @class
    ]}>
      <%= render_slot(@inner_block) %>
    </div>
    """
  end

  attr :src, :string
  slot :inner_block

  def navbar(assigns) do
    ~H"""
    <nav class="bg-slate-900 text-gray-100 fixed mt-5 z-30 w-full">
      <div class="px-3 py-3 lg:px-5 lg:pl-3">
        <div class="flex items-center justify-between">
          <%= render_slot(@inner_block) %>
        </div>
      </div>
    </nav>
    """
  end

  attr :url, :string
  slot :inner_block, required: true

  def logo(assigns) do
    ~H"""
    <a href={"#{@url}"} class="text-xl font-bold flex items-center lg:ml-2.5">
      <%= render_slot(@inner_block) %>
    </a>
    """
  end

  def mobile_toggle_button(assigns) do
    ~H"""
    <button
      id="toggleSidebarMobile"
      aria-expanded="true"
      aria-controls="sidebar"
      class="lg:hidden mr-2 text-gray-600 hover:text-gray-900 cursor-pointer p-2 hover:bg-gray-100 focus:bg-gray-100 focus:ring-2 focus:ring-gray-100 rounded"
    >
      <.icon name="hero-bars-2" />
    </button>
    """
  end

  slot :inner_block, required: true

  def action_buttons(assigns) do
    ~H"""
    <div class="flex justify-center gap-4 py-2 w-full">
      <%= render_slot(@inner_block) %>
    </div>
    """
  end

  attr :class, :string, default: nil
  slot :inner_block, required: true
  attr :rest, :global, doc: "the arbitrary HTML attributes to add to button"

  def action_button(assigns) do
    ~H"""
    <.link
      class={[
        "rounded-xl bg-red-900 hover:bg-red-700 py-2 px-3 text-sm font-semibold leading-6 text-white active:text-white/80",
        @class
      ]}
      {@rest}
    >
      <%= render_slot(@inner_block) %>
    </.link>
    """
  end

  attr :name1, :string, default: nil
  attr :name2, :string, default: nil
  slot :messages
  slot :buttons

  def game_card(assigns) do
    ~H"""
    <div class="relative flex flex-col items-center rounded-[20px] w-[400px] mx-auto p-4 bg-white bg-clip-border shadow-3xl shadow-shadow-500 dark:!bg-navy-800 dark:text-white dark:!shadow-none">
      <div class="relative flex h-32 w-full justify-center rounded-xl bg-cover">
        <img
          src="https://horizon-tailwind-react-git-tailwind-components-horizon-ui.vercel.app/static/media/banner.ef572d78f29b0fee0a09.png"
          class="absolute flex h-10 w-full justify-center rounded-xl bg-cover"
        />
        <div class="absolute bottom-10 w-full px-10 flex justify-between">
          <div>
            <div class="flex h-14 w-14 items-center justify-center rounded-full border-[4px] border-white bg-pink-400 dark:!border-navy-700">
              <.x_mark class="h-10 w-10" />
            </div>
            <div class="w-full text-center text-zinc-900"><%= @name1 %></div>
          </div>
          <div>
            <div class="flex h-14 w-14 items-center justify-center rounded-full border-[4px] border-white bg-pink-400 dark:!border-navy-700">
              <.o_mark class="h-10 w-10" />
            </div>
            <div class="w-full text-center text-zinc-900"><%= @name2 %></div>
          </div>
        </div>
      </div>
      <div class="mt-6 mb-3 flex gap-14 md:!gap-14">
        <%= render_slot(@inner_block) %>
      </div>
      <div class="flex justify-center w-full">
        <%= render_slot(@messages) %>
      </div>
      <div class="flex justify-center w-full">
        <%= render_slot(@buttons) %>
      </div>
    </div>
    """
  end
end
