module Main exposing (..)

import Browser
import Html exposing (..)
import Html.Attributes as Attr exposing (..)



-- MAIN


main =
    Browser.sandbox
        { init = init
        , update = update
        , view = view
        }



-- MODEL


type alias Model =
    { peps : List Pep }


type alias Pep =
    { nome : String, sobrenome : String, cpf : String }


init : Model
init =
    Model [ Pep "Astolfo" "Sobrenome" "123456", Pep "Arnaldo" "Maninho" "123432" ]



-- UPDATE


type Msg
    = Something


update : Msg -> Model -> Model
update msg model =
    case msg of
        Something ->
            model



-- VIEW


view : Model -> Html msg
view model =
    div [ class "content" ]
        [ h2 [] [ text "Listagem de peps :) " ]
        , viewListagemPeps model.peps
        ]


viewListagemPeps : List Pep -> Html msg
viewListagemPeps peps =
    ul [ class "peps" ] (List.map viewNomeCompleto peps)


viewNomeCompleto : Pep -> Html msg
viewNomeCompleto pep =
    li [ class "pep" ] [ text (pep.nome ++ " " ++ pep.sobrenome) ]
