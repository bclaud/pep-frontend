import gleam/dynamic/decode
import gleam/list
import gleam/string
import lustre
import lustre/attribute
import lustre/effect.{type Effect}
import lustre/element.{type Element}
import lustre/element/html
import lustre/event
import rsvp

pub fn main() {
  let app = lustre.application(init, update, view)
  let assert Ok(_) = lustre.start(app, "#app", Nil)
}

// MODEL ------

pub type Model {
  Model(peps: List(Pep), busca_nome: String, busca_cpf: String)
}

pub type Pep {
  Pep(
    cpf_parcial: String,
    data_carencia: String,
    data_fim: String,
    data_inicio: String,
    nome: String,
    regiao: String,
    sigla: String,
  )
}

fn pep_decoder() {
  use cpf_parcial <- decode.field("cpf_parcial", decode.string)
  use nome <- decode.field("nome", decode.string)
  use data_fim <- decode.optional_field("data_fim", "", decode.string)
  use data_inicio <- decode.optional_field("data_inicio", "", decode.string)
  use regiao <- decode.optional_field("regiao", "", decode.string)
  use data_carencia <- decode.optional_field("data_carencia", "", decode.string)
  use sigla <- decode.optional_field("regiao", "", decode.string)

  decode.success(Pep(
    cpf_parcial:,
    nome:,
    data_fim:,
    data_inicio:,
    regiao:,
    data_carencia:,
    sigla:,
  ))
}

fn init(_args) -> #(Model, Effect(Msg)) {
  let model = Model(peps: [], busca_nome: "", busca_cpf: "")

  #(model, effect.none())
}

// UPDATE -------------
pub type Msg {
  InputSearchByCpf(String)
  InputSearchByName(String)
  FetchResulted(Result(List(Pep), rsvp.Error))
  SubmittedSearch
}

fn update(model: Model, msg: Msg) -> #(Model, Effect(Msg)) {
  case msg {
    InputSearchByName(name) -> {
      let model = Model(..model, busca_cpf: "", busca_nome: name)
      #(model, effect.none())
    }
    InputSearchByCpf(cpf) -> {
      let model = Model(..model, busca_cpf: cpf, busca_nome: "")

      #(model, effect.none())
    }
    FetchResulted(Ok(peps)) -> {
      let model = Model(..model, peps: peps)
      #(model, effect.none())
    }
    FetchResulted(Error(_)) -> {
      #(model, effect.none())
    }
    SubmittedSearch -> {
      #(model, search_pep(model))
    }
  }
}

fn search_pep(model: Model) -> Effect(Msg) {
  case model.busca_cpf, model.busca_nome {
    cpf, "" -> {
      search_pep_by_cpf(cpf)
    }
    "", name -> {
      search_pep_by_name(name)
    }
    _, _ -> effect.none()
  }
}

fn search_pep_by_name(name) -> Effect(Msg) {
  case string.length(name) > 3 {
    True -> {
      let url = "https://pep.claudlabs.com/api/pep/nome/" <> name
      let handler = rsvp.expect_json(decode.list(pep_decoder()), FetchResulted)

      rsvp.get(url, handler)
    }
    False -> effect.none()
  }
}

fn search_pep_by_cpf(cpf) -> Effect(Msg) {
  case string.length(cpf) == 6 {
    True -> {
      let url = "https://pep.claudlabs.com/api/pep/" <> cpf
      let handler = rsvp.expect_json(decode.list(pep_decoder()), FetchResulted)

      rsvp.get(url, handler)
    }
    False -> effect.none()
  }
}

// VIEW ------------------------

fn view(model: Model) -> Element(Msg) {
  html.div([attribute.class("px-4 py-6 md:px-1 md:py-1 max-w-6xl mx-auto")], [
    html.h2(
      [attribute.class("text-2xl font-bold text-center text-indigo-800 mb-6")],
      [html.text("Listagem")],
    ),
    html.div([attribute.class("flex flex-col items-center gap-4 mb-8")], [
      view_search_input("Nome:", model.busca_nome, InputSearchByName),
      view_search_input(
        "CPF Parcial (6 dígitos do meio):",
        model.busca_cpf,
        InputSearchByCpf,
      ),
      view_search_button(),
    ]),
    view_pep_table(model),
  ])
}

fn view_pep_table(model: Model) {
  case list.is_empty(model.peps) {
    True -> {
      html.h3([attribute.class("text-center text-gray-500 text-lg mt-8")], [
        html.text("🔍 Utilize uma das pesquisas"),
      ])
    }
    False -> {
      html.table(
        [
          attribute.class(
            "w-full table-fixed border-collapse rounded-lg overflow-hidden shadow-lg bg-white",
          ),
        ],
        [
          html.thead([], [view_header_peps()]),
          html.tbody([], list.map(model.peps, view_rows_peps)),
        ],
      )
    }
  }
}

fn view_search_input(label, v, to_msg) {
  html.div([attribute.class("flex flex-col gap-4")], [
    html.label([attribute.class("text-sm font-medium text-gray-700")], [
      html.text(label),
    ]),
    html.input([
      attribute.class(
        "w-full px-4 py-2 border rounded-lg focus:ring-2 focus:ring-indigo-500 focus:border-indigo-500 transition-all",
      ),
      attribute.placeholder("Busque aqui"),
      attribute.type_("text"),
      attribute.value(v),
      event.on_input(to_msg),
    ]),
  ])
}

fn view_search_button() {
  html.button(
    [
      attribute.class(
        "px-4 py-2 bg-indigo-600 hover:bg-indigo-700 text-white rounded-lg transition-colors",
      ),
      event.on_click(SubmittedSearch),
    ],
    [html.text("Pesquisar")],
  )
}

fn view_header_peps() {
  let header_fields = ["Nome", "CPF", "Data inicial", "Data final", "Região"]

  let create_headers =
    list.map(header_fields, fn(header) {
      html.th(
        [
          attribute.class(
            "px-4 py-3 text-left align-middle font-bold text-indigo-700 uppercase tracking-wider bg-indigo-50 border-b border-gray-200",
          ),
        ],
        [html.text(header)],
      )
    })

  html.tr([], create_headers)
}

pub fn view_rows_peps(pep: Pep) {
  html.tr(
    [
      attribute.class(
        "even:bg-white odd:bg-gray-50 hover:bg-indigo-50 transition-colors",
      ),
    ],
    [
      html.td(
        [
          attribute.class(
            "px-4 py-3 text-gray-700 align-middle border-b border-gray-200",
          ),
        ],
        [html.text(pep.nome)],
      ),
      html.td(
        [
          attribute.class(
            "px-4 py-3 text-gray-700 align-middle border-b border-gray-200",
          ),
        ],
        [html.text(pep.cpf_parcial)],
      ),
      html.td(
        [
          attribute.class(
            "px-4 py-3 text-gray-700 align-middle border-b border-gray-200",
          ),
        ],
        [html.text(pep.data_inicio)],
      ),
      html.td(
        [
          attribute.class(
            "px-4 py-3 text-gray-700 align-middle border-b border-gray-200",
          ),
        ],
        [html.text(pep.data_fim)],
      ),
      html.td(
        [
          attribute.class(
            "px-4 py-3 text-gray-700 align-middle border-b border-gray-200",
          ),
        ],
        [html.text(pep.regiao)],
      ),
    ],
  )
}
