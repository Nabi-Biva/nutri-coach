import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["text", "input"]
  static values = { url: String }

  startEditing() {
    this.textTarget.classList.add("d-none")
    this.inputTarget.classList.remove("d-none")
    const inputField = this.inputTarget.querySelector("input")
    inputField.focus()
    inputField.select()
  }

  stopEditing() {
    this.textTarget.classList.remove("d-none")
    this.inputTarget.classList.add("d-none")
  }

  save(event) {
    event.preventDefault()
    const newTitle = this.inputTarget.querySelector("input").value.trim()

    if (newTitle === "") {
      this.stopEditing()
      return
    }

    fetch(this.urlValue, {
      method: "PATCH",
      headers: {
        "Content-Type": "application/json",
        "X-CSRF-Token": document.querySelector("[name='csrf-token']").content,
        "Accept": "text/vnd.turbo-stream.html"
      },
      body: JSON.stringify({ chat: { title: newTitle } })
    })
      .then(response => response.text())
      .then(html => {
        if (html) Turbo.renderStreamMessage(html)
      })

    this.stopEditing()
  }

  handleKeydown(event) {
    if (event.key === "Enter") {
      this.save(event)
    } else if (event.key === "Escape") {
      this.stopEditing()
    }
  }
}
