module Main exposing (..)

import Browser
import Html exposing (..)
import Html.Attributes as Attr exposing (..)
import Html.Events exposing (onInput)



-- MAIN


main =
    Browser.sandbox
        { init = init
        , update = update
        , view = view
        }



-- MODEL


type alias Model =
    { peps : List Pep
     , buscaNome : String
     , buscaCpf : String }


type alias Pep =
    { nome : String
    , sobrenome : String
    , cpf : String
    }


init : Model
init =
    Model [ Pep "Astolfo" "Sobrenome" "123456", Pep "Arnaldo" "Maninho" "123432" ] "" ""



-- UPDATE


type Msg
    = InputSearchByCpf String
    | InputSearchByName String


update : Msg -> Model -> Model
update msg model =
    case msg of
       InputSearchByName name  ->
            {model | buscaNome = name}

       InputSearchByCpf cpf ->
           { model | buscaCpf = cpf}



-- VIEW


view : Model -> Html Msg
view model =
    div [ class "content" ]
        [ h2 [] [ text "Listagem de peps :) " ]
        , viewSearchInput "Busque por nome" model.buscaNome InputSearchByName
        , viewSearchInput "Busque por CPF parcial (6 digitos do meio)" model.buscaCpf InputSearchByCpf
        , table [ class "table-peps" ]
            (List.append [ viewHeaderPeps ] (List.map viewRowsPeps model.peps))
        ]


viewSearchInput : String -> String -> (String -> msg) -> Html msg
viewSearchInput p v toMsg=
    input [ type_ "text", placeholder p, value v, onInput toMsg] []

-- Depois atualizar pra puxar os valores do record de Pep. Na verdade sera necessario transformar o PEP em um dict
-- Ja que as chaves de um record nao vao pra runtime


viewHeaderPeps : Html msg
viewHeaderPeps =
    let
        headerFields =
            [ "Nome", "CPF" ]

        createHeaders =
            List.map (\header -> th [ class ("header-" ++ header) ] [ text header ]) headerFields
    in
    tr [ class "row-table-header" ] createHeaders


viewRowsPeps : Pep -> Html msg
viewRowsPeps pep =
    tr [ class "table-row" ] [ td [] [ text pep.nome ], td [] [ text pep.cpf ] ]
