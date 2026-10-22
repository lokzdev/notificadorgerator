# Notificador Custom (Android)

Aplicativo Android nativo em Kotlin para configurar e disparar notificações customizadas com repetições e intervalos de tempo exatos.

## Recursos
- **Título Personalizado**: Escolha o nome da notificação.
- **Mensagem / Corpo**: Escolha o texto que aparece na notificação.
- **Quantidade de Repetições**: Escolha quantas vezes a notificação vai aparecer (ex: 3x, 5x, 10x).
- **Intervalo de Tempo**: Escolha o tempo entre cada disparo (Segundos, Minutos ou Horas).
- **Segundo Plano Real**: Utiliza `AlarmManager.setExactAndAllowWhileIdle()`, disparando mesmo com a tela do celular apagada ou com o app fechado.
- **Suporte a Android 13 e 14+**: Permissões em tempo de execução de `POST_NOTIFICATIONS` configuradas.

## Como Gerar o APK no Windows em 2 Minutos

1. Baixe e instale o [Android Studio](https://developer.android.com/studio) no Windows.
2. Abra o Android Studio e clique em **Open** (Abrir).
3. Selecione a pasta deste projeto: `AndroidCustomNotifier`.
4. Aguarde o Android Studio sincronizar os arquivos do Gradle (leva menos de 1 minuto na primeira vez).
5. No menu superior, clique em:
   **Build > Build Bundle(s) / APK(s) > Build APK(s)**
6. Quando terminar, aparecerá uma notificação no canto inferior direito com um link **locate**. Clique nele!
7. O arquivo `app-debug.apk` estará pronto.

## Como Instalar no Celular Android
1. Envie o arquivo `app-debug.apk` para o seu celular (pode ser via cabo USB, WhatsApp Web, Google Drive ou Telegram).
2. No celular, toque no arquivo `.apk` e clique em **Instalar** (se pedir permissão para instalar fontes desconhecidas, clique em Permitir).
3. Abra o app, defina o título, a mensagem e o tempo de repetição e aproveite!
