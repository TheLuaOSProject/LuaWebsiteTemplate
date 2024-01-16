---@diagnostic disable: undefined-global

return html {charset="utf8"} {
    head {
        title "404 Not Found",
        meta {name="viewport", content="width=device-width, initial-scale=1"},
        link {rel="stylesheet", href="https://cdnjs.cloudflare.com/ajax/libs/bulma/0.7.5/css/bulma.min.css"},
        link {rel="stylesheet", href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.11.2/css/all.min.css"},
    };

    body {
        section {class="hero is-primary is-fullheight"} {
            div {class="hero-body"} {
                div {class="container has-text-centered"} {
                    h1 {class="title"} "404 Not Found";
                    h2 {class="subtitle"} "The page you are looking for does not exist."
                }
            }
        }
    };
}
