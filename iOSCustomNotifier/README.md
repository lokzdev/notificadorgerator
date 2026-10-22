# Notificador Custom (iOS)

Aplicativo nativo para iPhone em Swift / SwiftUI para agendar notificações com fotos personalizadas, quantidade de repetições e intervalos de tempo exatos.

## Recursos
- **Título Personalizado**: Sem indicadores numéricos (1/10, etc.), exibindo puramente o título digitado.
- **Mensagem / Corpo**: Texto personalizado.
- **Foto da Notificação**: Seletor de fotos da galeria com suporte ao `UNNotificationAttachment` (ao puxar ou segurar a notificação no iOS, ela expande a foto em alta resolução).
- **Repetições e Intervalo**: Dispara em série mesmo com a tela bloqueada ou app fechado.

## Como Gerar o `.ipa` pelo GitHub Actions (Sem Mac)
1. Crie um repositório no seu GitHub.
2. Suba esta pasta para lá (`git push`).
3. Vá na aba **Actions** do GitHub.
4. O workflow **Build iOS IPA** rodará automaticamente no servidor macOS da Apple/Microsoft.
5. Quando concluir, baixe o arquivo `NotificadorCustom-ipa` na seção **Artifacts**.

## Como Instalar no iPhone pelo Windows (Sideloadly)
1. Conecte o iPhone no PC via cabo USB.
2. Abra o [Sideloadly](https://sideloadly.io/).
3. Arraste o arquivo `NotificadorCustom.ipa` para dentro do Sideloadly.
4. Digite o seu Apple ID e clique em **Start**.
5. Quando aparecer "Done", o app estará no seu iPhone!
