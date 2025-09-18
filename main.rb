require 'json'

USUARIOS_FILE = 'usuarios.json'
FILMES_FILE = 'filmes.json'

# -----------------------
# Funções de leitura e escrita
# -----------------------
def carregar_json(file)
  JSON.parse(File.read(file))
rescue
  []
end

def salvar_json(file, data)
  File.write(file, JSON.pretty_generate(data))
end

# -----------------------
# Funções do sistema
# -----------------------
def listar_filmes(filmes)
  puts "\n--- Lista de Filmes ---"
  filmes.each do |f|
    puts "#{f['id']}. #{f['titulo']} (#{f['genero']}, #{f['ano']})"
  end
end

def cadastrar_usuario(usuarios)
  print "Nome: "
  nome = gets.chomp
  print "Email: "
  email = gets.chomp
  print "Gêneros preferidos (separados por vírgula): "
  generos = gets.chomp.split(',').map(&:strip)
  id = (usuarios.map { |u| u['id'] }.max || 0) + 1
  usuario = { "id" => id, "nome" => nome, "email" => email, "generos_preferidos" => generos, "avaliacoes" => {} }
  usuarios << usuario
  salvar_json(USUARIOS_FILE, usuarios)
  puts "Usuário cadastrado com sucesso!"
end

def cadastrar_filme(filmes)
  print "Título: "
  titulo = gets.chomp
  print "Gênero: "
  genero = gets.chomp
  print "Ano: "
  ano = gets.chomp.to_i
  id = (filmes.map { |f| f['id'] }.max || 0) + 1
  filmes << { "id" => id, "titulo" => titulo, "genero" => genero, "ano" => ano }
  salvar_json(FILMES_FILE, filmes)
  puts "Filme cadastrado com sucesso!"
end

def avaliar_filme(usuario, filmes)
  listar_filmes(filmes)
  print "Digite o ID do filme para avaliar: "
  id = gets.chomp.to_i
  filme = filmes.find { |f| f['id'] == id }
  if filme
    print "Nota (1 a 5): "
    nota = gets.chomp.to_i
    usuario['avaliacoes'][id.to_s] = nota
    usuarios = carregar_json(USUARIOS_FILE)
    usuarios.map! { |u| u['id'] == usuario['id'] ? usuario : u }
    salvar_json(USUARIOS_FILE, usuarios)
    puts "Filme avaliado com sucesso!"
  else
    puts "Filme não encontrado."
  end
end

def recomendar_filmes(usuario, filmes)
  # Filmes não avaliados
  nao_avaliados = filmes.reject { |f| usuario['avaliacoes'].key?(f['id'].to_s) }
  # Filtrar por gênero preferido
  recomendados = nao_avaliados.select { |f| usuario['generos_preferidos'].include?(f['genero']) }
  puts "\n--- Filmes Recomendados para #{usuario['nome']} ---"
  if recomendados.empty?
    puts "Nenhuma recomendação disponível no momento."
  else
    recomendados.each do |f|
      puts "#{f['titulo']} (#{f['genero']}, #{f['ano']})"
    end
  end
end

def selecionar_usuario(usuarios)
  puts "\n--- Usuários ---"
  usuarios.each { |u| puts "#{u['id']}. #{u['nome']} (#{u['email']})" }
  print "Digite o ID do usuário: "
  id = gets.chomp.to_i
  usuario = usuarios.find { |u| u['id'] == id }
  unless usuario
    puts "Usuário não encontrado."
  end
  usuario
end

# -----------------------
# Loop principal
# -----------------------
usuarios = carregar_json(USUARIOS_FILE)
filmes = carregar_json(FILMES_FILE)

loop do
  puts "\n--- Sistema de Recomendação de Filmes ---"
  puts "1. Cadastrar Usuário"
  puts "2. Cadastrar Filme"
  puts "3. Avaliar Filme"
  puts "4. Recomendar Filmes"
  puts "5. Listar Filmes"
  puts "6. Sair"
  print "Escolha uma opção: "
  opcao = gets.chomp.to_i

  case opcao
  when 1
    cadastrar_usuario(usuarios)
  when 2
    cadastrar_filme(filmes)
  when 3
    usuario = selecionar_usuario(usuarios)
    avaliar_filme(usuario, filmes) if usuario
  when 4
    usuario = selecionar_usuario(usuarios)
    recomendar_filmes(usuario, filmes) if usuario
  when 5
    listar_filmes(filmes)
  when 6
    puts "Saindo..."
    break
  else
    puts "Opção inválida!"
  end
end
