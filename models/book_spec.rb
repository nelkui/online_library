# spec/models/book_spec.rb
RSpec.describe Book, type: :model do
    it 'is valid with valid attributes' do
      book = Book.new(title: 'Test Book', author: 'Test Author')
      expect(book).to be_valid
    end
    
    it 'is not valid without a title' do
      book = Book.new(title: nil, author: 'Test Author')
      expect(book).not_to be_valid
    end
  end
  
  # spec/controllers/books_controller_spec.rb
  RSpec.describe BooksController, type: :controller do
    describe 'POST #create' do
      context 'with valid parameters' do
        let(:valid_params) { { book: { title: 'Test Book', author: 'Test Author' } } }
        
        it 'creates a new book' do
          expect { post :create, params: valid_params }.to change(Book, :count).by(1)
        end
        
        it 'redirects to the created book' do
          post :create, params: valid_params
          expect(response).to redirect_to(Book.last)
        end
      end
    end
  end