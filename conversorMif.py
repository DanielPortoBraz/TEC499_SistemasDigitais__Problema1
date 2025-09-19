from PIL import Image
import os

def converter_para_mif(caminho_imagem, largura_data, profundidade_mem):
   
    # Carregando imagem
    try:
        img = Image.open(caminho_imagem)
    except FileNotFoundError:
        print(f"Erro: Arquivo de imagem não encontrado em '{caminho_imagem}'.")
        return
    except Exception as e:
        print(f"Ocorreu um erro ao abrir a imagem: {e}")
        return

    # Converte a imagem para escala de cinza (Luminosity)
    img = img.convert('L/home/aluno/Downloads')

    pixels = list(img.getdata())
    
    # Extrai o diretório e o nome da imagem original
    diretorio = os.path.dirname(caminho_imagem)
    nome_base = os.path.splitext(os.path.basename(caminho_imagem))[0]
    caminho_saida = os.path.join(diretorio, f"{nome_base}.mif")

    # Abre o arquivo .mif para escrita
    with open(caminho_saida, 'w') as f:
        # Escreve o cabeçalho do arquivo .mif
        f.write(f"WIDTH={largura_data};\n")
        f.write(f"DEPTH={profundidade_mem};\n")
        f.write("ADDRESS_RADIX=HEX;\n")
        f.write("DATA_RADIX=HEX;\n\n")
        f.write("CONTENT BEGIN\n")

        # Itera sobre os pixels e os converte para hexadecimal
        for i, pixel_value in enumerate(pixels):
        
            endereco_hex = hex(i)[2:].upper()
            valor_hex = hex(pixel_value)[2:].upper()
            
            # Garante que o endereço tenha o número correto de bits
            largura_endereco = (profundidade_mem.bit_length() + 3) // 4
            endereco_hex = endereco_hex.zfill(largura_endereco)
            
            # Garante que o valor tenha o número correto de bits
            largura_dados_bytes = (largura_data + 7) // 8
            valor_hex = valor_hex.zfill(largura_dados_bytes * 2)

            f.write(f"  {endereco_hex}  :   {valor_hex};\n")

        # Preenche o resto da memória com zeros
        for i in range(len(pixels), profundidade_mem):
            endereco_hex = hex(i)[2:].upper()
            largura_endereco = (profundidade_mem.bit_length() + 3) // 4
            endereco_hex = endereco_hex.zfill(largura_endereco)
            
            f.write(f"  {endereco_hex}  :   00;\n")

        f.write("END;\n")

    print(f"Conversão concluída! O arquivo .mif foi salvo em '{caminho_saida}'.")

if __name__ == "__main__":
    caminho_imagem = input("Caminho completo para a imagem: ")
    
    largura_dados = 8     
    profundidade = 76800
    
    converter_para_mif(caminho_imagem, largura_dados, profundidade)