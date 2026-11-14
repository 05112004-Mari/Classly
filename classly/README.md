# Classly

Organizador de estudos para estudantes, feito em Flutter com Firebase.
Projeto Prático – Parte 2 (Flutter + Firebase).

**Site publicado:** https://clay-19fa5.web.app

## Funcionalidades

- **Login e recuperação de senha** com Firebase Authentication, com feedback de progresso e de erro (RF001). Também é possível entrar com a conta Google.
- **Cadastro de usuário** com Authentication e dados extras (nome e telefone) na coleção `usuarios` do Firestore (RF002).
- **Inserção de dados** no Firestore com mensagem de sucesso ou de erro, sempre separados por usuário (RF003):
  - **Início**: tarefas e provas (coleção `tarefas`).
  - **Kanban**: quadro com três colunas (A Fazer, Em Andamento, Concluído), com arrastar e soltar (coleção `kanban`).
  - **Planejar**: calendário, plano de estudos semanal e metas (coleções `planos` e `metas`).
  - **Aulas**: grade horária semanal (coleção `aulas`).
- **Leitura em tempo real** com `StreamBuilder` e `ListView`, com tela de carregando, mensagem de falha e botão "Tentar novamente" (RF004).
- **Regras de segurança do Firestore**: cada usuário só lê e altera os próprios dados.
- **Publicação** no Firebase Hosting.

## Tecnologias

- Flutter e Dart
- Firebase Authentication
- Cloud Firestore
- Firebase Hosting

## Estrutura do projeto (MVC)

```
lib/
  controller/   regras e acesso ao Firebase
  model/        modelos de dados
  view/         telas
  widgets/      componentes reutilizáveis
  firebase_options.dart
  main.dart
```

## Coleções do Firestore

Todas as coleções guardam o `uid` do dono e só ele acessa os próprios documentos.

| Coleção    | Campos |
|------------|--------|
| `usuarios` | uid, nome, telefone, email, criadoEm |
| `aulas`    | uid, disciplina, diaSemana, inicio, fim, sala, criadoEm |
| `tarefas`  | uid, title, description, priority, dueDate, dueTime, subject, completed, isExam, criadoEm |
| `kanban`   | uid, titulo, disciplina, descricao, data, hora, prioridade, status, criadoEm |
| `planos`   | uid, disciplina, topico, diaSemana, horario, duracao, criadoEm |
| `metas`    | uid, titulo, descricao, categoria, prazo, prioridade, concluida, criadoEm |

## Como rodar o projeto

O projeto já inclui o `lib/firebase_options.dart` do projeto Firebase `clay-19fa5`.

```
flutter pub get
flutter run -d chrome
```

Para avaliar sem instalar nada, basta abrir o site publicado:
https://clay-19fa5.web.app

## Publicação

```
flutter build web
firebase deploy --only hosting
```

## Integrantes

- Mariana Cristina Dos Santos – RA [2840482511038]
- Maria Fernanda Ribeiro Tavares – RA [2840482511041]

## Links da entrega

- Site: https://clay-19fa5.web.app
- Vídeo: [link do vídeo]
