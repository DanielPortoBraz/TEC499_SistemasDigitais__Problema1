# Coprocessador Gráfico com FPGA (Zoom In/Out)

Este projeto implementa um **coprocessador gráfico autosuficiente** para manipulação de imagens, com foco em operações de **zoom in** e **zoom out**.  
A implementação foi desenvolvida para o **Kit de Desenvolvimento DE1-SoC**, utilizando o **FPGA Altera Cyclone V SE (5CSEMA5F31C6N)** e a ferramenta **Intel Quartus Prime 23.1**.

---

## Funcionalidades

- Execução de **quatro algoritmos de manipulação de imagem**:
  -  **Zoom-In**
  -  **Zoom-Out**
- Arquitetura **autosuficiente**, funcionando como **coprocessador gráfico independente**.
- Geração de sinais VGA para exibição da imagem processada.
- Memória dedicada para armazenamento da imagem original e da imagem resultante.
- Controle totalmente implementado em **Verilog**.

---

## Arquitetura

A arquitetura do sistema é composta pelos seguintes blocos principais:

- **Módulo de Controle (FSM)** → Sequencia as etapas de leitura, processamento e escrita da imagem.
- **Memória (RAM dual-port)** → Armazena tanto a imagem original quanto a imagem processada.
- **Controlador VGA** → Converte os dados processados em sinais de vídeo para exibição.
- **Clock e Reset** → Gerenciamento do tempo de operação e inicialização do sistema.

---

## Tecnologias Utilizadas

- **Hardware:** Kit DE1-SoC com FPGA Altera Cyclone V SE
- **Linguagem:** Verilog
- **Ferramenta de Síntese e Simulação:** Intel Quartus Prime 23.1
- **Saída de Vídeo:** Interface VGA

---

---

## Inicialização

- **Aplicação de Zoom-In**
- **Retorno a imagem original**
- **Aplicação de Zoom-out**
- **Tentativa de aplicação de Zoom-In e Zoom-Out simultâneos**
- **Botão de reset**
  
---
