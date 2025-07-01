# Inventário de Máquinas

## Visão Geral

O módulo de Inventário de Máquinas permite gerenciar o cadastro, consulta e transferência de máquinas entre setores da empresa. O sistema oferece duas formas principais de visualização e busca:

### 1. Busca por Setor
- Permite selecionar um setor específico
- Exibe todas as máquinas cadastradas naquele setor
- Mostra informações detalhadas de cada máquina
- Permite visualizar histórico de movimentações

### 2. Busca por Máquina
- Permite buscar uma máquina específica por código ou nome
- Exibe informações detalhadas da máquina encontrada
- Permite transferir a máquina para outro setor
- Mostra histórico completo da máquina

## Funcionalidades

### Cadastro de Máquinas
- **Código da Máquina**: Identificador único (obrigatório)
- **Nome da Máquina**: Nome descritivo (obrigatório)
- **Setor**: Setor onde a máquina está localizada (obrigatório)
- **Fabricante**: Fabricante da máquina
- **Modelo**: Modelo específico da máquina
- **Número de Série**: Número de série do equipamento
- **Responsável**: Pessoa responsável pela máquina
- **Localização**: Localização física específica
- **Status**: Estado atual da máquina (Ativa, Inativa, Em Manutenção, Aguardando Peças)
- **Observações**: Informações adicionais

### Transferência de Setor
- Permite mover uma máquina de um setor para outro
- Registra automaticamente no histórico da máquina
- Permite adicionar observações sobre a transferência
- Atualiza o status da máquina conforme necessário

### Histórico de Máquinas
- Registra todas as movimentações e alterações
- Tipos de eventos:
  - **Cadastro**: Nova máquina cadastrada
  - **Transferência de Setor**: Mudança de setor
  - **Manutenção**: Eventos de manutenção
  - **Atualização**: Alterações nos dados
  - **Inativação**: Desativação da máquina

## Estrutura de Arquivos

### Models
- `maquina_model.dart`: Modelo de dados da máquina
- `historico_maquina_model.dart`: Modelo de dados do histórico

### Services
- `maquina_service.dart`: Serviços de comunicação com a API

### ViewModels
- `maquina_viewmodel.dart`: Gerenciamento de estado da aplicação

### Views
- `inventario_maquinas_view.dart`: Interface principal do inventário

### Widgets
- `cadastro_maquina_dialog.dart`: Diálogo para cadastro de máquinas

## Endpoints da API

### Buscar Máquinas por Setor
```
GET /rest/WSMAQUINA/retmaq
Parâmetros: empfil, setor
```

### Buscar Máquina por Código
```
GET /rest/WSMAQUINA/retmaq
Parâmetros: empfil, codigo
```

### Buscar Histórico da Máquina
```
GET /rest/WSMAQUINA/rethist
Parâmetros: empfil, maquinaid
```

### Cadastrar Nova Máquina
```
POST /rest/WSMAQUINA/
Body: dados da máquina
```

### Atualizar Máquina
```
PUT /rest/WSMAQUINA/
Body: dados atualizados da máquina
```

### Transferir Setor
```
PUT /rest/WSMAQUINA/transfsetor
Body: dados da transferência
```

### Buscar Setores
```
GET /rest/WSMAQUINA/retsetores
Parâmetros: empfil
```

### Buscar Máquinas (Filtro)
```
GET /rest/WSMAQUINA/buscar
Parâmetros: empfil, termo
```

## Como Usar

### Acessando o Inventário
1. Faça login no sistema
2. Na tela inicial, clique em "Inventário de Máquinas"
3. Escolha entre as abas "Por Setor" ou "Por Máquina"

### Cadastrando uma Nova Máquina
1. Clique no ícone "+" na barra superior
2. Preencha os campos obrigatórios (marcados com *)
3. Clique em "Cadastrar"

### Consultando Máquinas por Setor
1. Selecione o setor desejado no dropdown
2. As máquinas do setor serão exibidas automaticamente
3. Clique em uma máquina para ver detalhes

### Buscando uma Máquina Específica
1. Vá para a aba "Por Máquina"
2. Digite o código ou nome da máquina
3. Clique em "Buscar"

### Transferindo uma Máquina
1. Abra os detalhes da máquina
2. Clique em "Transferir Setor"
3. Selecione o novo setor
4. Adicione observações (opcional)
5. Clique em "Transferir"

### Visualizando Histórico
1. Abra os detalhes da máquina
2. Clique em "Histórico"
3. Visualize todos os eventos relacionados à máquina

## Status das Máquinas

- **Ativa (1)**: Máquina em funcionamento normal
- **Inativa (2)**: Máquina desativada
- **Em Manutenção (3)**: Máquina em processo de manutenção
- **Aguardando Peças (4)**: Máquina aguardando reposição de peças

## Observações Técnicas

- O sistema utiliza Provider para gerenciamento de estado
- Todas as operações são assíncronas
- Tratamento de erros implementado
- Interface responsiva com Material Design
- Validação de formulários
- Feedback visual para o usuário 