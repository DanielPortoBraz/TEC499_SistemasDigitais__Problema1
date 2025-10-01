# TEC499_SistemasDigitais__Problema1
Este projeto consiste na implementação de um sistema de zoom e downscale aplicados a uma imagem exibida e transmitida por conexão VGA. O sistema é projetado no Kit de Desenvolvimento DE1-SoC.

## Descrição do Projeto
O projeto é um módulo embarcado de redimensionamento de imagens para sistemas de vigilância e exibição em tempo real. Nesse sentido, o _hardware_ aplica efeitos de ampliação de imagem (_zoom_) e redução (_downscale_), simulando um comportamento de interpolação visual.

Nesta etapa, foi construído um sistema autosufisciente que funciona como co-processador gráfico. Para isso, foi utilizado o Kit de Desenvolvimento De1-SoC, que contém o FPGA Altera Cyclone V SE 5CSEMA5F31C6N. Além disso, a implementação foi realizada através do Quartus Prime versão 23.1. Para a manipulação da imagem, são utilizados quatro algoritmos, sendo dois de zoom-in e dois para zoom-out.


## Funcionalidades

## Arquitetura do Projeto
Diagrama + fluxo geral + explicação em alto nível do verilog (utilizar rtl viewwer)

### Unidade Central de Processamento (CPU)
Explicação da CPU em alto nível e do módulo verilog

#### Unidade de Controle (UC)
Explicação da UC em alto nível e do módulo verilog

#### Unidade de Lógica e Aritmética (ULA)
Explicação da ULA em alto nível e do módulo verilog

### Memória
Explicação da memória em alto nível e módulo verilog (on chip memory)

### E/S
Explicação da Entrada e Saída e módulo verilog (VGA)

## Tutorial de Execução
Passo a passo desde a compilação até o uso dos periféricos da placa

## Teste e Execução
Execução de caso básico com imagem

