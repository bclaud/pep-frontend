module Main exposing (..)

import Browser
import Html exposing (..)
import Html.Attributes exposing (class, placeholder, type_, value)
import Html.Events exposing (onInput)
import Http
import Json.Decode as Decode exposing (Decoder, decodeString, float, int, list, nullable, string)
import Json.Decode.Pipeline as Pdecode exposing (hardcoded, optional, required)



-- MAIN


main : Program () Model Msg
main =
    Browser.element
        { init = \flags -> ( initialModel, Cmd.none )
        , update = update
        , view = view
        , subscriptions = \model -> Sub.none
        }



-- MODEL


type alias Model =
    { peps : List Pep
    , buscaNome : String
    , buscaCpf : String
    }


type alias Pep =
    { cpf_parcial : String
    , data_carencia : String
    , data_fim : String
    , data_inicio : String
    , nome : String
    , regiao : String
    , sigla : String
    }


pepDecoder : Decoder Pep
pepDecoder =
    Decode.succeed Pep
        |> Pdecode.required "cpf_parcial" string
        |> Pdecode.hardcoded ""
        |> Pdecode.hardcoded ""
        |> Pdecode.hardcoded ""
        |> Pdecode.required "nome" string
        |> Pdecode.hardcoded ""
        |> Pdecode.hardcoded ""


init : Model
init =
    Model [ createPep "" "" "" "" "" "" (Just "") ] "" ""


initialModel : Model
initialModel =
    Model [ createPep "" "" "" "" "" "" (Just "") ] "" ""


createPep : String -> String -> String -> String -> String -> String -> Maybe String -> Pep
createPep cpf_parcial data_carencia data_fim data_inicio nome regiao sigla =
    case sigla of
        Just sig ->
            Pep cpf_parcial data_carencia data_fim data_inicio nome regiao sig

        Nothing ->
            Pep cpf_parcial data_carencia data_fim data_inicio nome regiao ""


searchPepByNome : String -> Cmd Msg
searchPepByNome nome =
    if String.length nome > 3 then
        Http.get
            { url = "http://localhost:4000/api/pep/nome/" ++ nome
            , expect = Http.expectJson SearchedByName (Decode.list pepDecoder)
            }

    else
        Cmd.none


searchPepByCpf : String -> Cmd Msg
searchPepByCpf cpf_parcial =
    case String.length cpf_parcial of
        6 ->
            Http.get
                { url = "http://localhost:4000/api/pep/" ++ cpf_parcial
                , expect = Http.expectJson SearchedByName (Decode.list pepDecoder)
                }

        _ ->
            Cmd.none



-- UPDATE


type Msg
    = InputSearchByCpf String
    | InputSearchByName String
    | SearchedByName (Result Http.Error (List Pep))
    | SearchedByCpf (Result Http.Error (List Pep))


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        InputSearchByName name ->
            ( { model | buscaNome = name }, searchPepByNome name )

        --{ model | buscaNome = name, peps = [ Pep name "Clodovislis" "123123123" ] }
        InputSearchByCpf cpf ->
            ( { model | buscaCpf = cpf }, searchPepByCpf cpf )

        SearchedByName (Ok peps) ->
            ( { model | peps = peps }, Cmd.none )

        SearchedByName (Err _) ->
            ( model, Cmd.none )

        SearchedByCpf (Ok peps) ->
            ( { model | peps = peps }, Cmd.none )

        SearchedByCpf (Err _) ->
            ( model, Cmd.none )



-- Nao preciso criar duas mensagens, basta atualizar o model com as informacoes.
-- A ideia é que seja em tempo real, entao vai ser onInput, mas poderia ser com outros eventos :)
--{ model | buscaCpf = cpf, peps = [ Pep "Mirovaldo" "Rabindramba" cpf ] }
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
viewSearchInput p v toMsg =
    input [ type_ "text", placeholder p, value v, onInput toMsg ] []



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
    tr [ class "table-row" ] [ td [] [ text pep.nome ], td [] [ text pep.cpf_parcial ] ]
