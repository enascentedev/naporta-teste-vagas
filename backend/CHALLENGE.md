# Desafio de código Backend

#### Nesse desafio serão avaliados
* Seu domínio em Back-End
* Lógica
* Forma de organizar o código
* Segurança
* Boas práticas
* Conhecimento em Node.js, Go e tecnologias utilizadas

Boa sorte e obrigado por participar!

## 🚨 As regras do jogo

1. A API deverá ser construída em **Node.js**. Nós preferimos o framework NestJS, mas se for optar por outro, justifique sua escolha no README.

2. Implementar autenticação com **JWT**. O token deve ser informado no formato Bearer nas requisições.

3. Utilize **Banco de Dados Relacional ou Não Relacional**. Nós preferimos MongoDB ou PostgreSQL, mas se for optar por outro, justifique usa escolha no README.

4. Para a comunicação com o Banco de Dados, utilize algum ODM. Ex: Prisma.

5. Sua API deverá seguir os padrões REST na construção das rotas e nos retornos.

6. Crie um arquivo README que explique como executar o projeto, e quaisquer scripts necessários.

7. A aplicação deve possuir um script que popule o Banco de Dados inicialmente com pedidos fictícios para demonstração.

## 🎁 Bônus

Esses itens não são obrigatórios, porém desejados.

* Clean Code
* Testes automatizados
* Docker
* Linter
* Serverless

## 🖥 O Desafio

O desafio consiste em criar uma Web API para a naPorta que será consumida pelo portal web. 

Sua API deve conter as seguintes features:

* Criar pedido
* Listar pedidos
* Filtrar pedidos por numero, período (data inicial e data final) e status
* Editar pedido
* Excluir pedido (exclusão lógica)

### Dados do pedido: 

| Campo                               |
|-------------------------------------|
| Id                                  |
| Numero do pedido                    |
| Data previsão de entrega            |
| Cliente (nome e documento)          |
| Endereço de entrega                 |
| Items do pedido (descrição e preço) |
| Data de criação                     |


## 🏗 Ao finalizar o projeto

Seu projeto deve ser disponibilizado em um repositório **público** do GitHub.
Envie um email para william.hoffmann@naporta.log.br com o assunto Desafio Back-End Node.js - [SEU NOME] contendo o link para o repositório que você criou.

## :question: Dúvidas

Envie suas dúvidas diretamente para william.hoffmann@naporta.log.br.