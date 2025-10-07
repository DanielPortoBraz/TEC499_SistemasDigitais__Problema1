# TEC499_SistemasDigitais__Problema1

## Sumário

- [Descrição do Projeto](#descrição-do-projeto)
- [Funcionalidades](#funcionalidades)
- [Arquitetura Conceitual do Projeto](#arquitetura-conceitual-do-projeto)
- [Diagrama de Blocos](#diagrama-de-blocos)
  - [Co-Processador Aritmético (CPA)](#co-processador-aritmético-cpa)
  - [Unidade de Controle (UC)](#unidade-de-controle-uc)
  - [Unidade de Lógica e Aritmética (ULA)](#unidade-de-lógica-e-aritmética-ula)
  - [Memória](#memória)
  - [E/S](#es)
- [Tutorial de execução](#tutorial-de-execução)
- [Teste e execução](#teste-e-execução)
- [Referências](#referências)

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

Baseado na **Arquitetura de Von Neumann**, o sistema é composto pelos seguintes blocos principais:
- **Módulo de CPA**  
  Responsável por sequenciar as etapas de leitura, processamento e escrita da imagem.  
  - **UC (Unidade de Controle)**: coordena o fluxo de instruções e o controle das operações de zoom.  
  - **ULA (Unidade Lógica e Aritmética)**: executa os cálculos de coordenadas e gera o endereço de memória da imagem.  

- **Memória (RAM)**  
  Armazena tanto a imagem original quanto a imagem processada.  

- **Controlador VGA**  
  Converte os dados processados em sinais de vídeo para exibição.

  **Observação:** O bloco E/S contém, além do monitor conectado por VGA, duas chaves (keys) para operação de zoom.

Tal Arquitetura está contida no seguinte diagrama, e apresenta a sequência de 6 passos de execução:

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

### Os 6 passos de Execução (no diagrama):

1. Envio de pacote de dados da Imagem  
2. Entrada de pacote de dados da Imagem no CPA pela UC  
3. Aplicação de algoritmo de zoom em `p` na ULA  
4. Envio de novo pacote (`p'`) com os dados processados pelo algoritmo, da ULA para UC  
5. Envio de `p'` da UC para a MEM  
6. Envio da Imagem formada por pacotes `p'` da MEM para E/S  
 
## Diagrama de Blocos
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

![Cópia de Cabeçalho (1)](https://github.com/user-attachments/assets/423929d7-ac9a-4898-979f-ba92abc0e3da)


##### Zoom-Out - Amostragem/ Decimação (Instrução: 0010 ... ...):
1. Desloca o eixo X em 1 bit para a **esquerda** com offset (Multiplica por 2 e garante centralização da imagem)
2. Desloca o eixo Y em 1 bit para a **esquerda** com offset (Multiplica por 2 e garante centralização da imagem)
3. Verifica se os resultados estão na faixa de resolução. (`Eixo X <= 320` e `Eixo Y <= 240`)
4. Calcula endereço para converter coordenada resultante em índice do vetor da Memória com a imagem (`Eixo Y * 320 + Eixo X`)
* **Exemplo com matriz 3x4:**

![Cabeçalho](https://github.com/user-attachments/assets/412045ba-2629-4e68-965d-2750f8fe1324)

### Memória
A Memória Principal é responsável por armazenar a imagem original, utilizada como fonte de dados para os algoritmos de zoom.
 - Implementada como RAM M10K interna do FPGA, configurada para 320x240 pixels (76.800 posições de 8 bits).
 - Opera em modo somente leitura (wren = 0), sendo acessada continuamente pelo CPA através do endereço calculado pela ULA.
 - Cada endereço corresponde a um pixel em escala de cinza (8 bits).
 - É inicializada com um arquivo .mif (Memory Initialization File), que define os valores de cada pixel a partir da imagem carregada.

A Memória Secundária atua como um framebuffer uma área intermediária para escrita e leitura dos pixels processados.

 - Também implementada em RAM M10K de 320x240 posições de 8 bits.
 - Durante o processamento, o CPA grava os novos pixels calculados (imagem com zoom) nessa memória.b
 - Após o preenchimento completo (sinal frame_ready ativo), o controle de acesso é transferido para o módulo VGA, que passa a ler os pixels sequencialmente para gerar o quadro exibido no monitor.
 - O endereço de leitura é calculado pelo próprio módulo VGA (vga_addr = next_y * 320 + next_x).

### E/S
A Entrada/Saída (E/S) do sistema é composta pelos sinais de controle (chaves e botão) e pelo módulo VGA, que realiza a exibição da imagem processada no monitor.
Entradas
 - Chaves (SW6 e SW7): Selecionam a operação a ser executada —
  -  SW6 → Zoom-In (Vizinho Mais Próximo)
  -  SW7 → Zoom-Out (Decimação)
 - Botão (KEY0): Reset geral do sistema, reinicializando o CPA, as memórias e o VGA.
 - Clock de 50 MHz: Fonte principal de sincronização, a partir da qual são derivados:
   -  25 MHz → VGA e memórias
   -  100 MHz → CPA (UC + ULA)
Saídas
 - Monitor VGA: Exibe a imagem processada com zoom aplicado.
  -  Sinais: HSYNC, VSYNC, RED, GREEN, BLUE, BLANK, SYNC, CLK.
  -  Operação: resolução de 320x240 a 60 Hz.
- Imagem em escala de cinza (8 bits): O valor do pixel (0–255) é replicado nos três canais RGB para formar tons de cinza.

#### Módulo VGA (Verilog)
O módulo VGA utilizado neste projeto não foi desenvolvido não foi desenvolvido pela equipe, sendo cedido pelo professor para uso no projeto.
 - Ele é responsável por gerar os sinais de sincronismo horizontal e vertical, além do controle de leitura sequencial dos pixels no framebuffer.
 - Recebe como entrada o clock de 25 MHz e os dados vindos da Memória Secundária, produzindo os sinais analógicos VGA compatíveis com o monitor.
 - Foi integrado ao projeto sem modificações de funcionalidade, apenas com ajustes de interconexão e frequência de operação para compatibilidade com o restante da arquitetura.

## Tutorial de Execução
Primeiramente, é necessário realizar o download da pasta `TEC499_SistemasDigitais__Problema1`, que contém todos os arquivos necessários para executar a aplicação. Para a execução, é preciso ter instalado o Intel Quartus Prime no dispositivo. Cumprindo esses requisitos, o passo a passo é explicado a seguir.

### Configuração do Quartus

1. Ao inicializar o Quartus, é exibida a opção "Open Project" na tela inicial. Selecione essa opção;
2. Busque a pasta do projeto no seu explorador e selecione o arquivo `.qpf`;
3. Após aberto, a opção _Start Compilation_, representada por um botão de iniciar em azul na barra de ferramentas, deve ser selecionada para compilar o código. Quando a barra de "compile design" da aba Task chegar em 100%, significa que o projeto já pode ser executado na placa.

![bandicam-2025-10-06-00-37-27-065](https://github.com/user-attachments/assets/e9072d18-2c0a-4129-af81-2b65b0ba5774)

3. Para execução, clique em "Programmer" na barra de ferramentas para abrir a janela de execução. Nesta etapa, é importante que a placa esteja conectada no dispositivo através da entrada `USB-Blaster II`;
4. Clique em "Hardware Setup" e selecione `DE-SoC`;
5. Após fechar a janela de "Hardware Setup", clique em "Auto Detect";
6. Selecione a segunda opção (`5CSEMA5`) e clique em "Ok". Na próxima janela, clique em "Yes";
7. Delete o segundo arquivo `<none>` da lista;
8. Clique em "Add File" e selecione o arquivo `.sof` dentro da pasta `output_files`;
9. Clique no botão start. A aplicação será executada na placa quando _Progress_ chegar a 100%.

![exemplo3](https://github.com/user-attachments/assets/24db3811-1ec3-4706-8da1-6e6b54fc0ea7)

### Manual de uso

O sistema utiliza duas chaves e um botão. Abaixo está uma imagem da placa com indicações da localização de cada componente de controle, com legenda.

<img width="622" height="454" alt="Captura de tela 2025-10-06 210843" src="https://github.com/user-attachments/assets/6ccfa528-76ad-4932-bce3-5067608f0578" />


  **Azul**: Botão de reset
  
  **Vermelho**: Chave 6, responsável pelo Zoom-In
  
  **Verde**: Chave 7, responsável pelo Zoom-Out

---

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

As imagens abaixo demonstram a aplicação de Zoom-In e Zoom-Out, respectivamente.   

![zoom_in](https://github.com/user-attachments/assets/3baea778-3c46-4020-9ed2-f458486ca088)

![zoom-out](https://github.com/user-attachments/assets/c7aab951-7555-4dec-ba09-0d7392c3190d)

## Referências
PATTERSON, D. A.; HENNESSY, J. L. Computer organization and design : the hardware/software interface, ARM edition / Computer organization and design : the hardware/software interface, ARM edition.
Cyclone V Device Overview. Disponível em: https://www.intel.com/content/www/us/en/docs/programmable/683694/current/cyclone-v-device-overview.html.
TERASIC. DE1-SoC User Manual. Rev. 1.2.2 (rev. C/D). 7. KiB. 7 abr. 2015. Disponível em: https://www.terasic.com.tw/cgi-bin/page/archive.pl?CategoryNo=167&Language=English&No=836&PartNo=4
