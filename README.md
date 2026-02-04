
# 📅 FacilitAgenda

**FacilitAgenda** é uma aplicação web/mobile desenvolvida em **Flutter + Firebase** para **controle simples e profissional de agendamentos de locações**.

O foco do projeto é ajudar **locadores** a organizarem reservas, valores e sinais pagos, de forma clara, rápida e confiável — sem complicação.

---

## 🚀 Funcionalidades

* 📆 **Agenda visual com calendário**
* ➕ Criar, ✏️ editar e 🗑️ excluir agendamentos
* 👤 Nome do cliente
* 💰 Valor da locação
* ✅ Controle de **sinal pago / não pago**
* 📝 Observações livres
* 📊 **Total automático por mês**
* 🔐 Autenticação com **Google Login**
* 👥 **Multiusuário** (cada usuário vê apenas seus dados)
* ☁️ Persistência em **Cloud Firestore**
* 🌍 Compatível com **Web, Mobile e Desktop**

---

## 🧠 Conceitos Importantes

* Datas de agendamento são salvas em **UTC**, garantindo:

  * funcionamento correto em qualquer fuso horário
  * consistência ao trocar de mês ou dia
* Cada agendamento pertence a um usuário autenticado
* O sistema foi pensado para ser:

  * simples para usar
  * fácil de manter
  * escalável para novas funcionalidades

---

## 🛠️ Tecnologias Utilizadas

* **Flutter**
* **Firebase Authentication**
* **Cloud Firestore**
* **TableCalendar**
* **Flutter Web**

---

## 🔐 Estrutura de Dados (Firestore)

Coleção: `bookings`

```json
{
  "userId": "string",
  "clientName": "string",
  "value": 1500.00,
  "hasDeposit": true,
  "notes": "Observações do cliente",
  "date": "Timestamp (UTC)"
}
```

---

## ▶️ Como rodar o projeto

### 1️⃣ Clonar o repositório

```bash
git clone https://github.com/seu-usuario/facilitagenda.git
cd facilitagenda
```

### 2️⃣ Instalar dependências

```bash
flutter pub get
```

### 3️⃣ Configurar o Firebase

* Criar um projeto no Firebase
* Ativar **Authentication (Google)**
* Ativar **Cloud Firestore**
* Configurar o `firebase_options.dart`

### 4️⃣ Rodar o projeto

```bash
flutter run -d chrome
```

---

## 📄 Licença

Este projeto está sob a licença **MIT**.
Sinta-se livre para usar, modificar e evoluir.

---

## ✨ Autor

Desenvolvido por **Luis Eduardo Dias Catapreta**
Projeto criado para organização prática de locações de curto prazo.

---
