# TEC499_SistemasDigitais__Problema1
## Descrição do Projeto
Este projeto implementa um **coprocessador gráfico autosuficiente** para manipulação de imagens, com foco em operações de **zoom in** e **zoom out**, baseado na seleção da operação e a coordenada a ser exibida no monitor conectado por VGA. A implementação foi desenvolvida para o **Kit de Desenvolvimento DE1-SoC**, utilizando o **FPGA Altera Cyclone V SE (5CSEMA5F31C6N)** e a ferramenta **Intel Quartus Prime 23.1**. Em razão deste Kit, **as operações** são selecionadas por **chaves**, uma para **zoom in** e outra para **zoom-out**.


## Funcionalidades
- Execução de **dois algoritmos de manipulação de imagem**:
  -  **Vizinho mais próximo** (Zoom-In)
  -  **Decimação** (Zoom-Out)
- Arquitetura **autosuficiente**, funcionando como **coprocessador gráfico independente**.
- Geração de sinais VGA para exibição da imagem processada.
- Memória dedicada para armazenamento da imagem original e da imagem resultante.
- Controle totalmente implementado em **Verilog**.

## Arquitetura Conceitual do Projeto

Baseada na **Arquitetura de Von Neumann**, o sistema é composto pelos seguintes blocos principais, conforme o diagrama:

<img width="500" height="500" alt="image" src="https://github.com/user-attachments/assets/553fe304-6932-4161-acc1-f2565401de27" />

---

#### Legenda

- **CPU**: Unidade Central de Processamento  
- **CPA**: Co-Processador Aritmético  
- **UC**: Unidade de Controle  
- **ULA**: Unidade de Lógica e Aritmética  
- **E/S**: Entrada e Saída  
- **VGA**: Video Gate Array  
- **MEM**: Memória  
- **p**: pacote de dados da Imagem 
- **p'**: pacote de dados processados após ZOOM  

---

- **Módulo de CPA**  
  Responsável por sequenciar as etapas de leitura, processamento e escrita da imagem.  
  - **UC (Unidade de Controle)**: coordena o fluxo de instruções e o controle das operações de zoom.  
  - **ULA (Unidade Lógica e Aritmética)**: executa os cálculos de coordenadas e gera o endereço de memória da imagem.  

- **Memória (RAM)**  
  Armazena tanto a imagem original quanto a imagem processada.  

- **Controlador VGA**  
  Converte os dados processados em sinais de vídeo para exibição.

  **Observação:** O bloco E/S contém, além do monitor conectado por VGA, duas chaves (keys) para operação de zoom.

---

### Processo de Aplicação de Zoom e Exibição da Imagem no VGA

1. Envio de pacote de dados da Imagem  
2. Entrada de pacote de dados da Imagem no CPA pela UC  
3. Aplicação de algoritmo de zoom em `p` na ULA  
4. Envio de novo pacote (`p'`) com os dados processados pelo algoritmo, da ULA para UC  
5. Envio de `p'` da UC para a MEM  
6. Envio da Imagem formada por pacotes `p'` da MEM para E/S  
 
## Arquitetura Implementada em Verilog (Diagrama de Blocos)
<img width="2260" height="1040" alt="Diagrama em branco (2)" src="https://github.com/user-attachments/assets/c5c1c422-d4c8-46d6-a0f3-7a1e29d4c03d" />


### Co-Processador Aritmético (CPA)
O Co-Processador Aritmético é composto pela Unidade de Controle e a Unidade de Lógica e Aritmética. Sua operação é realizada a um **clock de 100 MHz** que o permite receber os comandos das **chaves** e os **eixos X e Y** da coordenada atual do VGA e enviá-los um endereço para memória. Cada conjunto de entradas é recebido no formato de uma **instrução de 24 bits** que é decodificada pela Unidade de Controle nos campos **op** (4 bits), **x_in** (10 bits) e **y_in** (10 bits) e enviada para a Unidade de Lógica e Aritmética para calcular o endereço da memória conforme tais campos.
A seguir, estes passo são detalhados nos blocos internos ao CPA.

#### Unidade de Controle (UC)
A Unidade de Controle atua em ciclo de 4 estados, que são:
<img width="910" height="445" alt="Estados_UC" src="https://github.com/user-attachments/assets/a2a16019-498f-41f7-a6ee-aad0ec20bc54" />
* **Fetch**: Leitura da instrução que contém a seleção do zoom e a coordenada (eixo x e eixo y);
* **Decode**: Decodificação para separar os campos de instrução. Define qual o zoom em qual coordenada será aplicado
* **Execute**: Execução do algoritmo na ULA, até que a operação seja finalizada
* **Write**: Escrita do dado processasdo pela ULA (endereço selecionado).

#### Unidade de Lógica e Aritmética (ULA)
Explicação da ULA baseada nos algoritmos (inserir matriz ilustrando passo a passo)

### Memória
Memória Principal
Memória Secundária

### E/S
Explicação da Entrada e Saída e módulo verilog (VGA)

## Tutorial de Execução
Primeiramente, é necessário realizar o download da pasta TEC499_SistemasDigitais__Problema1, que contém todos os arquivos necessários para executar a aplicação. Para a execução, é preciso ter instalado o Intel Quartus Prime. Ao inicializar esse programa, é exibida a opção "Open Project" na tela inicial, e é por aí que o usuário tem que selecionar a pasta do projeto. Após aberto, há um botão com símbolo de play em azul, que é usado para compilar todo o código. Quando a barra chegar em 100% na aba [...], significa que o projeto já pode ser executado na placa.
Para execução, há a opção "Programmer" que abre a aba {...}

### Conversor .mif e mudança de imagem
O projeto já possui duas imagens .mif dentro dele, imagem_teste.mif e imagem.mif. Caso o usuário queira carregar outra imagem no VGA, ele pode usar o algoritmo presente nesse repertório, conversorMif, para converter imagens de resolução 320x240 para o formato .mif. Esse conversor suporta grande parte das extensões, como PNG e JPEG. Basta executá-lo e informar o diretório completo da imagem quando o programa pedir. Ele gera um arquivo .mif no mesmo diretório da imagem original, já em escala de cinza.

Para mudar a imagem a ser exibida no monitor, é necessário alterar o diretório em memory.v. Basta acessar o arquivo e configurar o caminho em altsyncram_component.init_file. Para simplificação, é recomendável que o arquivo .mif seja transferido para a raiz do projeto, assim basta apenas especificar o nome do arquivo.

## Teste e Execução
Execução de caso básico com imagem
