# Alerta SOS Invisível

Aplicação Flutter para acionamento e acompanhamento de alertas SOS, com suporte a localização geográfica, mapas e comunicação com uma API HTTP. O projeto está a ser desenvolvido para funcionar como uma solução de alerta rápido, permitindo representar a localização de uma ocorrência e acompanhar o seu estado.

> **Estado do projeto:** em desenvolvimento.

## Índice

- [Sobre o projeto](#sobre-o-projeto)
- [Funcionalidades](#funcionalidades)
- [Tecnologias utilizadas](#tecnologias-utilizadas)
- [Estrutura do projeto](#estrutura-do-projeto)
- [Pré-requisitos](#pré-requisitos)
- [Instalação](#instalação)
- [Executar a aplicação](#executar-a-aplicação)
- [Testes](#testes)
- [Configuração de mapas](#configuração-de-mapas)
- [Integração com a API](#integração-com-a-api)
- [Plataformas suportadas](#plataformas-suportadas)
- [Boas práticas de desenvolvimento](#boas-práticas-de-desenvolvimento)
- [Contribuição](#contribuição)
- [Licença](#licença)

## Sobre o projeto

O **Alerta SOS Invisível** é uma aplicação multiplataforma construída com Flutter e Dart. A proposta é disponibilizar uma forma simples e rápida de criar ou acompanhar alertas de emergência, utilizando localização e visualização cartográfica.

O projeto inclui a base de uma aplicação Flutter e está organizado para crescer com novas funcionalidades, como:

- criação e gestão de alertas;
- obtenção da localização do utilizador;
- visualização de ocorrências num mapa;
- comunicação com serviços externos através de HTTP;
- apresentação de datas e horas de forma localizada;
- separação entre modelos, controladores e ecrãs da aplicação.

O repositório também contém uma especificação de referência para um futuro painel web de operação do sistema, com perfis como operador, despachante, comando e dono de estabelecimento.

## Funcionalidades

### Funcionalidades disponíveis na base atual

- Aplicação Flutter multiplataforma.
- Interface baseada em Material Design.
- Integração preparada com mapas.
- Suporte para mapas Google através de `google_maps_flutter`.
- Suporte para mapas OpenStreetMap através de `flutter_map`.
- Modelação de coordenadas geográficas com `latlong2`.
- Comunicação com APIs HTTP através do pacote `http`.
- Formatação de datas, horas e números com `intl`.
- Organização do código por camadas de controladores, modelos e vistas.
- Teste de fumaça da aplicação principal.

### Funcionalidades previstas

A implementação pode evoluir para incluir:

- acionamento de alertas SOS;
- envio da localização atual para o backend;
- acompanhamento do estado de um alerta;
- histórico de ocorrências;
- identificação do canal de origem do alerta;
- localização aproximada quando apenas a última posição conhecida estiver disponível;
- atualização de posições em tempo real;
- notificações e alertas sonoros;
- integração com esquadras, patrulhas e operadores;
- painel operacional para acompanhamento das ocorrências.

> As funcionalidades previstas dependem da implementação dos ecrãs, controladores e serviços de backend correspondentes.

## Tecnologias utilizadas

- [Flutter](https://flutter.dev/) — framework de desenvolvimento multiplataforma.
- [Dart](https://dart.dev/) — linguagem de programação.
- `google_maps_flutter` — integração com Google Maps.
- `flutter_map` — componente de mapas baseado em tiles.
- `latlong2` — representação de latitude e longitude.
- `http` — pedidos HTTP para integração com APIs.
- `intl` — internacionalização e formatação de datas.
- `flutter_test` — testes automatizados.
- `flutter_lints` — regras de análise estática e boas práticas.

As versões das dependências estão definidas no ficheiro [`pubspec.yaml`](pubspec.yaml).

## Estrutura do projeto

```text
.
├── android/                 # Configuração da aplicação para Android
├── ios/                     # Configuração da aplicação para iOS
├── lib/
│   ├── controllers/         # Controladores e lógica de apresentação
│   ├── models/              # Modelos de dados da aplicação
│   ├── views/               # Ecrãs e componentes visuais
│   └── main.dart            # Ponto de entrada da aplicação
├── linux/                   # Configuração para Linux
├── macos/                   # Configuração para macOS
├── test/                    # Testes automatizados
├── web/                     # Configuração para Flutter Web
├── windows/                 # Configuração para Windows
├── analysis_options.yaml    # Regras do analisador Dart
├── pubspec.yaml             # Dependências e metadados do projeto
└── README.md                # Documentação do projeto
```

## Pré-requisitos

Antes de executar o projeto, instale:

1. [Flutter SDK](https://docs.flutter.dev/get-started/install)
2. [Dart SDK](https://dart.dev/get-dart) — normalmente incluído no Flutter SDK.
3. Um editor compatível, como:
   - Android Studio;
   - Visual Studio Code;
   - IntelliJ IDEA.
4. Pelo menos um dispositivo ou emulador configurado para a plataforma escolhida.

Verifique a instalação com:

```bash
flutter doctor
```

Corrija os problemas indicados pelo comando antes de iniciar o desenvolvimento.

## Instalação

Clone o repositório e entre na pasta do projeto:

```bash
git clone https://github.com/Felton7JE/Alerta-Maxima.git
cd Alerta-Maxima
```

Instale as dependências:

```bash
flutter pub get
```

Confirme que o projeto está corretamente configurado:

```bash
flutter analyze
```

## Executar a aplicação

Liste os dispositivos disponíveis:

```bash
flutter devices
```

Execute a aplicação no dispositivo selecionado:

```bash
flutter run
```

Para executar numa plataforma específica, utilize, por exemplo:

```bash
flutter run -d chrome
flutter run -d android
flutter run -d ios
```

Para consultar os identificadores exatos dos dispositivos disponíveis, execute `flutter devices`.

## Testes

Execute todos os testes do projeto com:

```bash
flutter test
```

O projeto inclui um teste de fumaça que verifica se a aplicação principal é criada e se o título **ALERTA SOS INVISÍVEL** é apresentado.

Durante o desenvolvimento, recomenda-se executar também:

```bash
flutter analyze
flutter test
```

## Configuração de mapas

O projeto possui dependências para duas abordagens de mapas:

- `google_maps_flutter`, para integração com Google Maps;
- `flutter_map`, para utilização de mapas baseados em tiles, como OpenStreetMap.

### Google Maps

Para utilizar Google Maps em produção, é necessário configurar as chaves de API para cada plataforma, respeitando as instruções oficiais do Flutter e do Google Maps Platform.

A configuração normalmente envolve:

- criar uma chave de API no Google Cloud;
- ativar as APIs necessárias;
- configurar a chave no Android;
- configurar a chave no iOS;
- restringir a chave por aplicação e plataforma.

Não coloque chaves privadas diretamente no código-fonte nem as publique no repositório.

### OpenStreetMap

Ao utilizar `flutter_map` com OpenStreetMap, configure corretamente o fornecedor de tiles e respeite os termos de utilização e as políticas de atribuição do serviço utilizado.

## Integração com a API

A dependência `http` está incluída para permitir a comunicação com um backend. A integração pode ser organizada através de serviços ou controladores responsáveis por:

- autenticação;
- criação de alertas;
- consulta de alertas ativos;
- consulta do histórico;
- envio de posições;
- atualização do estado de uma ocorrência;
- tratamento de erros de rede;
- renovação ou validação de sessão.

Uma estrutura recomendada para a evolução do projeto é:

```text
lib/
├── controllers/
├── models/
├── services/       # Comunicação com APIs e serviços externos
├── views/
└── main.dart
```

### Recomendações de segurança

- Não guardar palavras-passe em texto simples.
- Não incluir tokens ou chaves de API no código-fonte.
- Usar HTTPS em ambientes de teste integrados e produção.
- Validar as respostas recebidas da API.
- Tratar erros de timeout, ausência de internet e respostas HTTP inesperadas.
- Limpar os dados da sessão durante o logout.

## Estados sugeridos para alertas

Para manter consistência entre a aplicação móvel e o painel operacional, podem ser utilizados estados como:

| Estado | Descrição |
| --- | --- |
| `NOVO` | Alerta criado e ainda não assumido. |
| `ASSUMIDO` | Um operador assumiu o alerta. |
| `EQUIPA_A_CAMINHO` | Uma equipa foi despachada e está a deslocar-se. |
| `EQUIPA_NO_LOCAL` | A equipa chegou ao local. |
| `RESOLVIDO` | A ocorrência foi concluída. |
| `FALSO_ALARME` | O alerta foi classificado como falso alarme. |
| `CANCELADO_PELO_UTILIZADOR` | O utilizador cancelou o alerta. |
| `EXPIRADO` | O alerta deixou de receber atualizações. |

A implementação final destes estados deve ser alinhada com o contrato da API.

## Plataformas suportadas

O projeto contém diretórios de configuração para:

- Android;
- iOS;
- Web;
- Windows;
- Linux;
- macOS.

A disponibilidade real de funcionalidades, especialmente localização, notificações e mapas, pode variar de acordo com a plataforma e com a configuração específica de cada ambiente.

## Boas práticas de desenvolvimento

- Manter os widgets visuais em `lib/views`.
- Manter a lógica de interação e estado nos controladores.
- Representar dados da aplicação através de modelos tipados.
- Evitar colocar chamadas HTTP diretamente nos widgets.
- Criar testes para regras de negócio e fluxos críticos.
- Executar `flutter analyze` antes de abrir um pull request.
- Manter as dependências atualizadas com cuidado e testar após cada atualização.
- Usar nomes claros e consistentes em português ou inglês, evitando misturar convenções no mesmo módulo.
- Nunca guardar informações sensíveis em ficheiros versionados.

## Contribuição

Contribuições são bem-vindas.

1. Faça um fork do projeto.
2. Crie uma branch para a sua alteração:

   ```bash
   git checkout -b feat/minha-alteracao
   ```

3. Faça as alterações necessárias.
4. Execute a análise e os testes:

   ```bash
   flutter analyze
   flutter test
   ```

5. Faça commit das alterações:

   ```bash
   git commit -m "feat: descreve a alteração"
   ```

6. Envie a branch para o GitHub:

   ```bash
   git push origin feat/minha-alteracao
   ```

7. Abra um pull request descrevendo o que foi alterado e como validar a alteração.

## Licença

Este projeto ainda não contém um ficheiro de licença definido. Antes de distribuir ou reutilizar o código, defina uma licença no repositório, como MIT, Apache-2.0 ou outra adequada ao projeto.

## Documentação adicional

- [Documentação oficial do Flutter](https://docs.flutter.dev/)
- [Aprender Flutter](https://docs.flutter.dev/get-started/learn-flutter)
- [Codelab oficial do Flutter](https://docs.flutter.dev/get-started/codelab)
- [Recursos de aprendizagem do Flutter](https://docs.flutter.dev/reference/learning-resources)
- [Documentação do Dart](https://dart.dev/guides)
