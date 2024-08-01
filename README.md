# Como utilizar o projeto

## Configuração da toolchain

Os passos de instalação aqui descritos são voltados e foram testados em um sistema Ubuntu 22.04 LTS.
A documentação oficial recomenda que esse seja o sistema utilizado.

### Avisos

A qualquer momento que haja um problema, certifique-se de que a seção [**# Problemas comuns**](#problemas-comuns) não cobre o seu erro como um dos primeiros passos de troubleshooting.

Recomenda-se a utilização de um sistema limpo e destrutível para o desenvolvimento do projeto, já que alguns passos de instalação neste guia podem ser destrutivos.
Uma alternativa é utilizar uma máquina virual, mas a divisão de recursos pode ser um problema.
Caso queira utilizar mas nunca tenha instalado uma máquina virtual anteriormente, recomendo assistir a [este curto vídeo](https://www.youtube.com/watch?v=nvdnQX9UkMY).

### Versão correta do Python

O Python é uma ferramenta notória pela baixa *backward compatibility*.
Perdi muitas horas por culpa de versões do Python e de pacotes *builtin* conflitantes.
Talvez exista alguma outra forma melhor de resolver o problema, pois a solução presente a seguir não é ideal.
Recomenda-se seguir os passos a seguir à risca caso não tenha certeza do que está fazendo.

Certifique-se de que a versão de `python3` resolvido pelo `PATH` é o Python 3.10.

    ```sh
    python3 --version
    ```

    - Caso não seja, instale o Python 3.10 e troque o Python que é resolvido de `python3` no `PATH` 

        ```sh
        # Esse repositório tem várias versões de Python
        sudo add-apt-repository ppa:deadsnakes/ppa 
        
        # Instalar o Python 3.10
        sudo apt install -y python3.10

        # Adicionar a nova versão de Python como uma alternativa no `PATH`
        sudo update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.10 1

        # Transformar o Python 3.10 como a alternativa padrão de resolução do `PATH`
        # Este comando abre uma processo iterativo de seleção de resolução padrão. Selecione o código associado ao caminho do Python 3.10.
        sudo update-alternatives --config python3
        ```

### Instalar o ROS 2 Humble

1. Siga os passos contidos na [documentação oficial](https://docs.ros.org/en/humble/Installation/Ubuntu-Install-Debians.html),
até o comando `sudo apt upgrade` (inclusive) na seção `Install ROS 2 packages`.
2. Ainda no guia, instale a versão `Desktop Install (Recommended)`. **Não** instale o `ROS-Base Install (Bare Bones)`.
Esse processo vai demorar, mas geralmente não precisa de supervisão humana.
3. Instale o `ros-dev-tools` presente no guia.

Depois disso, não é necessário prosseguir no guia de instalação. 

### Setup do ROS

Muitos programas do ecossistema do ROS necessitam que o *script* `/opt/ros/humble/setup.bash` tenha sido executado. Por isso, você teria que executá-lo em grande parte dos terminais abertos. Para evitar essa inconveniência, pode-se adicionar a execução desse *script* ao `~/.bashrc`, um script que roda toda vez que um novo terminal bash é aberto. Para isso, execute o comando a seguir:

```bash
echo source /opt/ros/humble/setup.bash >> ~/.bashrc
```

Agora basta abrir um novo terminal ou executar o *script* no terminal atual.

Lembrando que essa adição ao `~/.bashrc` pode causar lentidão ao abrir uma nova instância do terminal. Para mitigar esse problema, pode-se optar por apenas utilizar a função [`setros`](#setros) do [`macros.bash`](./macros.bash), explicado mais adiante na seção [# macros.bash](#macrosbash).

### Pacotes Python

A *toolchain* depende de alguns pacotes de Python.
Além disso, alguns pacotes precisam de um *downgrade* 
Entre eles, é necessário fazer o *downgrade* do pacote `setuptools` pois o `setup.py`, utilizado no processo de instalação múltiplas vezes,
foi deprecado nas versões mais novas de `setuptools`.
Às vezes também é necessário fazer downgrade do `empy`.
Para garantir que isso não será um problema, faça os dois.
Note que é necessário ter o `pip` instalado (disponível no *apt*).
```sh
sudo apt install pip # Se não tiver ainda

pip install --user setuptools==58.2.0 empy==3.3.4 kconfiglib jsonschema jinja2 pyros-genmsg
```

### Micro DDS

Este é o programa que permite a comunicação do PX4 com o ROS.
Ele pode ser instalado onde quiser, mas o *script* abaixo o instala na *home*.
Este processo demorará, mas geralmente não precisa de supervisão humana até o seu final.
No final, ele poderá pedir uma senha.

```sh
cd
git clone https://github.com/eProsima/Micro-XRCE-DDS-Agent.git
cd Micro-XRCE-DDS-Agent
mkdir build
cd build
cmake ..
make
sudo make install
sudo ldconfig /usr/local/lib/
```

### Instalar o PX4-Autopilot

O [repositório oficial do PX4-Autopilot](https://github.com/PX4/PX4-Autopilot.git) carecia de algumas funcionalidades necessárias.
Então este repositório utiliza uma versão customizada do repositório

Baixar o repositório personalizado do PX4:
```sh
cd
git clone https://github.com/felipebarichello/PX4-Autopilot-ColAvoid.git --recursive
```

Ele deve ser instalado na home (ou deve conter um *symlink* lá) pois o *script* de *launch* presume isso e não funcionará caso contrário.
Alternativamente, pode-se alterar o script
[`$REPO/src/ROS2_PX4_Offboard/px4_offboard/px4_offboard/processes.py`](./src/ROS2_PX4_Offboard/px4_offboard/px4_offboard/processes.py)
para utilizar o caminho desejado.

Em seguida, execute o seguinte *script* para instalar o PX4, dentro do diretório baixado:
```sh
bash Tools/setup/ubuntu.sh
```

É normal aparecerem vários *warnings* no processo de instalação.

### Testar a instalação

Caso nenhum erro ocorra, vá para o local em que colocou este repositório e execute os comandos:
```sh
source ./macros.bash
setros && buildall && sim
```
e verifique se o comportamento é compatível com a descrição a seguir **(não feche as janelas antes de ler a seção [# Fechar os programas](#fechar-os-programas)**:

- Duas novas janelas de terminal são abertas; se antes só havia uma aberta, agora há três:
    1. **PX4 Shell**: A que já estava aberta, agora com outputs no estilo `[velocity_control-4] [INFO] [1710362381.891866260] [px4_offboard.velocity]: FlightCheck: True`
    2. **Teleop**: Uma que apresenta vários controles de teclado e termina com "Press SPACE to arm/disarm the drone"
    3. Uma com duas abas:
        1. **Cliente DDS**: Uma das abas frequentemente imprime a seguinte linha: `INFO  [uxrce_dds_client] time sync converged`
        2. **SITL**: A outra aba é mais colorida (se seu terminal suporta cores) e imprime mensagens que começam com algo semelhante a `[1710362261.223419] info     | ProxyClient.cpp`
- Adicionalmente, é aberta uma janela gráfica do Gazebo.

**Independentemente do resultado, antes de fechar os processos abertos, prossiga para a seção [# Fechar os programas](#fechar-os-programas).**

Após isso, caso tenha encontrado algum erro, veja a seção [**# Problemas comuns**](#problemas-comuns) para possíveis soluções.

## Fechar os programas

Alguns programas abertos, lançados como nodos do ROS, possuem suas próprias janelas, como o Gazebo o o RViz.
Fechar eles pelo botão de fechar da janela não só não fecha eles, como pode travar um processo do Gazebo.
Por isso, feche todos os programas diretamente no terminal com `Ctrl+C`.
Veja a seção [**# Problemas comuns > Erro na abertura do Gazebo**](#erro-na-abertura-do-gazebo) para ver o erro que pode ser causado por isso.
Caso não haja nenhum erro, prossiga para a seção [**# Estrutura do projeto**](#estrutura-do-projeto) para entender a estrutura do projeto.

## Problemas comuns

### Ao tentar simular, erros em vermelho acusando algo no CMakeLists.txt

O repositório PX4-Autopilot-ColAvoid foi baixado sem a opção `--recursive`.
Execute `git submodule update --init --recursive` nele para corrigir o problema.
Então volte a partir do ponto após o clone em [**# Instalar o PX4-Autopilot**](#instalar-o-px4-autopilot)

### Erro ao iniciar o PX4

Esse erro se caracteriza por uma mensagem de erro em vermelho no terminal que executa o SITL
(ver [**# Testar a instalação**](#testar-a-instalação) para identificar esse terminal).
Pode acontecer toda vez que a simulação é executada pela primeira vez.
Deve ser resolvido fechando todos os processos e executando novamente o comando [`sim`](#sim).

### ninja: error: unknown target

Caso o erro seja algo semelhante a `ninja: error: unknown target`, tente executar os seguintes comandos no repositório do PX4:
```sh
make clean
make distclean
```
e então repita o processo.

### Erro na abertura do Gazebo

Pode ser que já haja alguma instância do Gazebo rodando em segundo plano.
Isso geralmente é gerado por tentar fechar o programa através da janela, ao invés do terminal.
Para resolver o problema, execute
```sh
kgz
```
para eliminar os processos do Gazebo.
Esse comando é uma função definida em [macros.bash](./macros.bash)

## Estrutura do projeto

Esta seção explica a árvore de arquivos do projeto e quais comandos são necessários para o desenvolvimento do projeto.

### [macros.bash](./macros.bash)

O script [macros.bash](./macros.bash) possui funções de shell que executa os principais comandos necessários para o desenvolvimento do projeto.

Para utilizar os comandos nele contidos, execute `source macros.bash` em cada instância de terminal que precisa deles.
Note que alguns deles requerem que o script [`install/setup.bash`](./install/setup.bash) tenha sido executado previamente (pode ser através do comando [`setup`](#setup)).
Alguns comandos só funcionam se o *working directory* for a raíz deste repositório, então alguns erros podem ser originados desse detalhe. 
Abaixo, listo eles e descrevo o objetivo de cada um.

#### `setros`

Executa o script `source /opt/ros/humble/setup.bash` para o terminal atual.
Muitos programas do ecossistema do ROS necessitam que esse *script* tenha sido executado.

#### `setup`

Executa o script `install/setup.bash` para o terminal atual.

#### `buildall`

O primeiro build (quando não há os diretórios [`install/`](./install/) e [`build`](./build/) na raíz do projeto).
Muitos outros comandos dependem deste ter sido executado.
Também executa [`setup`](#setup).

Mais tecnicamente, faz o *build* de todos os pacotes ROS.
Às vezes pode ser a solução para algum problema se estiver relacionado com um pacote que não seja o principal.

#### `build`

Realiza o *build* apenas do pacote principal do projeto. Precisa ser executado toda vez que quiser efetivar modificações dentro de [`src/`](./src/).
Também executa [`setup`](#setup).

Mais tecnicamente, faz o *build* apenas do pacote ["px4_offboard"](./src/ROS2_PX4_Offboard/px4_offboard/)

#### `remodel`

Copia os arquivos relacionados ao modelo do drone (tudo que está em [`models/`](./models/)) para o diretório em que o PX4 consegue referenciá-los.

Para modificar o modelo, por exemplo para adicionar um LIDAR, o arquivo do modelo deve ser substituído.
Isso pode ser feito modificando os arquivos dentro de
`$PX4_AUTOPILOT/Tools/simulation/gz/models/`.
Mas para manter o versionamento dos arquivos de modelos, os modelos devem ser alterados em [`models/`](./models/),
e então copiados para lá.
O comando `remodel` faz essa cópia

#### `sim`

Executa todos os programas necessários para a simulação de um drone no sistema PX4/Gazebo/ROS, inclusive com controle pelo teclado.
Na verdade, executa apenas o script de *launch* do pacote [`px4_offboard`](./src/ROS2_PX4_Offboard/px4_offboard/), que por sua vez inicializa esses processos.

#### `kgz`

Fecha todos os processos do Gazebo que estão rodando em segundo plano.
Elimina alguns erros que podem ocorrer ao tentar abrir o Gazebo,
conforme descrito na seção [# Problemas comuns > Erro na abertura do Gazebo](#erro-na-abertura-do-gazebo).

### [src/](./src/)

Contém o código fonte dos *ROS nodes*.

### [models/](./models/)

Contém os arquivos relacionados ao modelo do drone.
Esse diretório por si só não é lido pelo Gazebo ou pelo PX4.
Para efetivar alguma mudança feita aqui, é necessário copiar os arquivos para onde o PX4 consegue lê-los.
A melhor forma de fazer isso é utilizando o comando `remodel`.

### [install/setup.bash](./install/setup.bash)

É gerado pelo processo de build.
O script precisa ser executado (`source install/setup.bash`, caso seu terminal seja o `bash`) em todo novo terminal que precisa interagir com programas vinculados ao projeto, como por exemplo o `rviz`.
As funções [`setup`](#setup), [`build`](#build) e [`buildall`](#buildall) do script [`macros.bash`](./macros.bash) executam-no automaticamente.

### Outros arquivos gerados automaticamente

Todos os arquivos dentro de [`build`](./build/), [`install`](./install/) e [`log`](./log/) são gerados automaticamente. Fora o `install/setup.bash`, eles geralmente não são muito úteis para uso manual.
