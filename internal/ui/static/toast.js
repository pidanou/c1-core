document.addEventListener("alpine:init", () => {
  Alpine.data("toast", () => ({
    toasts: [],

    add(event) {
      this.toasts.push({
        id: `toast-${Math.random().toString(16).slice(2)}`,
        message: event.detail.message,
        type: event.detail.type,
      });
    },

    remove(id) {
      const index = this.toasts.findIndex((toast) => toast.id === id);
      this.toasts.splice(index, 1);
    },

    toastInit(el) {
      const id = el.getAttribute("id");
      console.log(id);
      let that = this;
      setTimeout(function () {
        that.remove(id);
      }, 4000);
    },

    globalInit() {
      window.toast = function (message, type = "info") {
        window.dispatchEvent(
          new CustomEvent("add-toast", {
            detail: {
              message: message,
              type: type,
            },
          }),
        );
      };
    },
  }));
});
