// Phoenix and LiveView are loaded as UMD bundles via <script> tags in root.html.heex,
// exposing window.Phoenix and window.LiveView globals.

const Hooks = {};

Hooks.RayCanvas = {
  mounted() {
    this.ctx = this.el.getContext("2d");
    this.ctx.fillStyle = "#000";
    this.ctx.fillRect(0, 0, this.el.width, this.el.height);

    this.handleEvent("clear_canvas", () => {
      this.ctx.fillStyle = "#000";
      this.ctx.fillRect(0, 0, this.el.width, this.el.height);
    });

    this.handleEvent("row_ready", ({y, pixels}) => {
      if (pixels.length === 0) return;
      const imageData = this.ctx.createImageData(this.el.width, 1);
      pixels.forEach(([x, r, g, b]) => {
        const i = x * 4;
        imageData.data[i]     = r;
        imageData.data[i + 1] = g;
        imageData.data[i + 2] = b;
        imageData.data[i + 3] = 255;
      });
      this.ctx.putImageData(imageData, 0, y);
    });
  }
};

// Close flash alerts on click
document.querySelectorAll("[role=alert][data-flash]").forEach((el) => {
  el.addEventListener("click", () => el.setAttribute("hidden", ""));
});

const csrfToken = document.querySelector("meta[name='csrf-token']").getAttribute("content");
const liveSocket = new LiveView.LiveSocket("/live", Phoenix.Socket, {params: {_csrf_token: csrfToken}, hooks: Hooks});
liveSocket.connect();
