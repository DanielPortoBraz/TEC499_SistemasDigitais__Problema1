# TEC499_SistemasDigitais__Problema1
## Descrição do Projeto
Este projeto implementa um **coprocessador gráfico autosuficiente** para manipulação de imagens, com foco em operações de **zoom in** e **zoom out**, baseado na seleção da operação e a coordenada a ser exibida no monitor conectado por VGA. A implementação foi desenvolvida para o **Kit de Desenvolvimento DE1-SoC**, utilizando o **FPGA Altera Cyclone V SE (5CSEMA5F31C6N)** e a ferramenta **Intel Quartus Prime 23.1**. Em razão do FPGA, **as operações** são selecionadas por **chaves**, uma para **zoom in** e outra para **zoom-out**.


## Funcionalidades
- Execução de **dois algoritmos de manipulação de imagem**:
  -  **Vizinho mais próximo** (Zoom-In)
  -  **Decimação** (Zoom-Out)
- Arquitetura **autosuficiente**, funcionando como **coprocessador gráfico independente**.
- Geração de sinais VGA para exibição da imagem processada, em tons de cinza com profundidade de **8 bits** (256 níveis), através da conversão para sinais RGB analógicos.
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

O sistema está organizado em Verilog com base no Diagrama de Blocos acima. Para permitir a execução de operações de zoom, é utilizado um clock negado de 100 MHz, obtido por meio de um PLL a partir do clock de 50 MHz da placa, conectado ao CPA. Em paralelo, um clock negado de 25 MHz é gerado por um divisor de clock a partir dos mesmos 50 MHz, sendo conectado às Memórias RAM M10K (configuradas para armazenamento de 76.800 x 8 bits, ou 320x240 pixels em escala de cinza) e ao módulo VGA, definido para operar em 320x240 a 60 Hz. Essa configuração foi escolhida de forma a manter a sincronização entre o processamento do CPA e a exibição no VGA, de modo que a cada quatro ciclos/estados da Unidade de Controle, um ciclo corresponde à leitura ou escrita realizada no VGA e nas memórias.  

As conexões entre os módulos seguem a hierarquia funcional estabelecida. O CPA recebe como entradas o clock de 100 MHz, as chaves de seleção de operação e as coordenadas atuais fornecidas pelo VGA. A partir desses sinais, o CPA gera endereços que são enviados à Memória RAM Principal, onde se encontra armazenada a imagem original. Os pixels resultantes dessa leitura são transferidos para a Memória RAM Secundária, que funciona como framebuffer para o VGA. O módulo VGA, sincronizado ao clock de 25 MHz, acessa continuamente essa memória para obter os pixels na ordem sequencial correta e gerar os sinais HSYNC, VSYNC e RGB que compõem a imagem exibida no monitor.  

### Datapath do Sistema
1. **Entrada de dados:** As chaves e as coordenadas fornecidas pelo VGA entram no CPA como parte da instrução.  
2. **Controle:** A Unidade de Controle (UC) faz o CPA percorrer os estados de leitura e decodificação, determinando qual operação de zoom aplicar e em qual coordenada.  
3. **Execução:** A Unidade Lógica e Aritmética (ULA) calcula o novo endereço da imagem conforme o algoritmo de zoom selecionado.  
4. **Escrita:** O endereço resultante acessa a Memória Principal, que envia o pixel correspondente para ser escrito na Memória Secundária.  
5. **Arbitragem:** Um multiplexador garante a seleção correta do endereço da Memória Secundária, escolhendo entre a escrita vinda do CPA (durante o processamento) ou a leitura sequencial vinda do contador/VGA (durante a exibição).  
6. **Iteração:** Esse processo se repete até que toda a Memória Secundária esteja preenchida com a imagem processada.  
7. **Exibição:** O módulo VGA lê a Memória Secundária, quadro a quadro, e gera os sinais de vídeo que exibem a imagem resultante no monitor.  



---

### Co-Processador Aritmético (CPA)
O **Co-Processador Aritmético** é composto pela **Unidade de Controle** e a **Unidade de Lógica e Aritmética**. Sua operação é realizada a um **clock de 100 MHz** que o permite receber os comandos das **chaves** e os **eixos X e Y** da **coordenada atual do VGA** e enviá-los um **endereço para memória**. Cada conjunto de entradas é recebido no formato de uma **instrução de 24 bits** que é decodificada pela Unidade de Controle nos campos **op** (**4 bits**), **x_in** (**10 bits**) e **y_in** (**10 bits**) e enviada para a **Unidade de Lógica e Aritmética** para calcular o endereço da memória conforme tais campos.
A seguir, estes passos são detalhados nos blocos internos ao CPA.

#### Unidade de Controle (UC)
A Unidade de Controle atua em ciclo de 4 estados (cada um leva 1 ciclo de clock), que são:
<img width="445" height="217" alt="Estados_UC" src="https://github.com/user-attachments/assets/a2a16019-498f-41f7-a6ee-aad0ec20bc54" />
* **Fetch**: Leitura da instrução que contém a seleção do zoom e a coordenada (eixo x e eixo y).
* **Decode**: Decodificação para separar os campos de instrução. Define qual o zoom e em qual coordenada será aplicado. Formato da instrução:
  
  |  | Instrução (24 bits) | |
  |:---:|:---:|:---:|
  | op | x_in | y_in |
  | Operação de Zoom (4 bits) | Eixo X da Coordenada (10 bits) | Eixo Y da Coordenada (10 bits) |

* **Execute**: Execução do algoritmo na ULA, até que a operação seja finalizada (sinal `zoom_done` em 1)
* **Write**: Escrita do dado processado pela ULA (endereço selecionado).

#### Unidade de Lógica e Aritmética (ULA)
A Unidade de Lógica e Aritmética recebe os dados de operação de zoom e os eixos da coordenada a ser aplicado o algoritmo. Assim, com base na seleção feita para Zoom-in ou Zoom-out, é gerado como saída o endereço resultante. Todas as operações da ULA levam 1 ciclo de clock (100 MHz), com a saída estando pronta desde o estado de execução e sendo liberada somente no estado de Escrita.
Com relação aos algoritmos de Zoom-In e Zoom-Out internos da ULA, estão implementados o Vizinho Mais Próximo e a Amostragem/ Decimação, respectivamente. Segue o passo a passo de cada um:
##### Zoom-In - Vizinho Mais Próximo (Instrução: 0001 ... ...):
1. Desloca o eixo X em 1 bit para a **direita** com offset (Divide por 2 e garante centralização da imagem)
2. Desloca o eixo Y em 1 bit para a **direita** com offset (Divide por 2 e garante centralização da imagem)
3. Verifica se os resultados estão na faixa de resolução. (`Eixo X <= 320` e `Eixo Y <= 240`)
4. Calcula endereço para converter coordenada resultante em índice do vetor da Memória com a imagem (`Eixo Y * 320 + Eixo X`)
* **Exemplo com matriz 3x4:**
(Animação)
  
##### Zoom-Out - Amostragem/ Decimação (Instrução: 0010 ... ...):
1. Desloca o eixo X em 1 bit para a **esquerda** com offset (Multiplica por 2 e garante centralização da imagem)
2. Desloca o eixo Y em 1 bit para a **esquerda** com offset (Multiplica por 2 e garante centralização da imagem)
3. Verifica se os resultados estão na faixa de resolução. (`Eixo X <= 320` e `Eixo Y <= 240`)
4. Calcula endereço para converter coordenada resultante em índice do vetor da Memória com a imagem (`Eixo Y * 320 + Eixo X`)
* **Exemplo com matriz 3x4:**
(Animação)

### Memória
Memória Principal
Memória Secundária

### E/S
Explicação da Entrada e Saída e módulo verilog (VGA)

## Tutorial de Execução
Primeiramente, é necessário realizar o download da pasta TEC499_SistemasDigitais__Problema1, que contém todos os arquivos necessários para executar a aplicação. Para a execução, é preciso ter instalado o Intel Quartus Prime no dispositivo. Cumprindo esses requisitos, o passo a passo é explicado a seguir. 

1. Ao inicializar o Quartus, é exibida a opção "Open Project" na tela inicial, e é por aí que o usuário tem que ir até a pasta do projeto e selecionar o arquivo `.qpf`.
2. Após aberto, a opção de Start Compilation, representada com símbolo de play em azul na barra de ferramentas, deve ser selecionada para compilar o código. Quando a barra de "compile design" da aba Task chegar em 100%, significa que o projeto já pode ser executado na placa.
![bandicam-2025-10-06-00-37-27-065](https://github.com/user-attachments/assets/e9072d18-2c0a-4129-af81-2b65b0ba5774)
3. Para execução, há a opção "Programmer" na barra de ferramentas que abre a janela para execução. Nesta etapa, é importante que a placa esteja conectada no dispositivo através da entrada `USB-Blaster II`. É necessário clicar em "Hardware Setup" e selecionar o `DE-SoC`.
4. Após isso, os próximos passos são exemplificados através da demonstração abaixo.

![exemplo3](https://github.com/user-attachments/assets/24db3811-1ec3-4706-8da1-6e6b54fc0ea7)

### Conversor .mif e mudança de imagem
O projeto já possui duas imagens .mif dentro dele, `imagem_teste.mif` e `imagem.mif`. Caso o usuário queira carregar outra imagem no VGA, ele pode usar o algoritmo presente nesse repertório, conversorMif, para converter imagens de resolução 320x240 para o formato .mif. Esse conversor suporta grande parte das extensões, como PNG e JPEG. Basta executá-lo e informar o diretório completo da imagem quando o programa pedir. Ele gera um arquivo .mif no mesmo diretório da imagem original.

<img width="1302" height="511" alt="exemplo1" src="https://github.com/user-attachments/assets/8bc38242-2365-45cc-bed9-d3b49197bcd1" />

> [!NOTE]
> Para um melhor resultado, preservando todo o conteúdo da imagem, é importante que a mesma esteja na resolução 320x240.


Para mudar a imagem a ser exibida no monitor, é necessário alterar o diretório em `memory.v`. Basta acessar o arquivo e configurar o caminho em `altsyncram_component.init_file`. Para simplificação, é recomendável que o arquivo .mif seja transferido para a raiz do projeto, assim basta apenas especificar o nome do arquivo. Logo abaixo é possível visualizar todo esse processo com a `imagem_exemplo`.

<img width="2024" height="723" alt="exemplo2" src="https://github.com/user-attachments/assets/981e2509-8770-479a-a289-7f5404193e6a" />

## Teste e Execução
Após todo o processo explanado na seção anterior, o sistema já está pronto para funcionar. Inicialmente, a imagem já deve ser carregada no monitor de forma automática. Usando a imagem de teste como exemplo, assim seria a inicialização do sistema:

![Imagem do WhatsApp de 2025-10-03 à(s) 11 21 24_9ed5630e](https://github.com/user-attachments/assets/bb9d01ed-e343-4125-98bf-7ba1e00bad8f)
<p>
  Exibição da imagem original 320x240 na saída VGA.
</p>

Após isso, o sistema pode funcionar de acordo com quatro casos principais, sendo eles:

1. Ativação da chave 6: Aplica o algoritmo de Vizinho Mais Próximo, aplicando o efeito de zoom-in no canto inferior direito da imagem;
2. Ativação da chave 7: Aplica o algoritmo de Decimação, aplicando o efeito de zoom-out no centro da imagem, com redução na resolução;
3. Botão de reset (Key 0) pressionado: Todo o sistema passa pelo processo de reinicialização.
4. Ativação simultânea das chaves: A imagem permanece no seu estado original.
