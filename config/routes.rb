# config/routes.rb
Rails.application.routes.draw do
  resources :books do
    resources :borrowings, only: [:create, :update]
  end
  resources :borrowers, only: [:index, :show]
end

# app/models/book.rb
class Book < ApplicationRecord
  has_many :borrowings
  has_many :borrowers, through: :borrowings
  
  validates :title, :author, presence: true
  validates :title, uniqueness: true
end

# app/models/borrower.rb
class Borrower < ApplicationRecord
  has_many :borrowings
  has_many :books, through: :borrowings
  
  validates :name, presence: true
end

# app/models/borrowing.rb
class Borrowing < ApplicationRecord
  belongs_to :book
  belongs_to :borrower
  
  validates :book, :borrower, presence: true
  validates :book, availability: true
end

# app/controllers/books_controller.rb
class BooksController < ApplicationController
  def index
    @books = Book.all
  end
  
  def show
    @book = Book.find(params[:id])
  end
  
  def create
    @book = Book.new(book_params)
    if @book.save
      redirect_to @book, notice: 'Book created successfully'
    else
      render :new
    end
  end
  
  private
  
  def book_params
    params.require(:book).permit(:title, :author, :description)
  end
end

# app/controllers/borrowings_controller.rb
class BorrowingsController < ApplicationController
  def create
    @book = Book.find(params[:book_id])
    @borrower = Borrower.find_or_create_by(name: params[:borrower_name])
    
    if @book.available?
      @borrowing = @book.borrowings.create(
        borrower: @borrower,
        borrowed_at: Time.current,
        status: 'borrowed'
      )
      
      if @borrowing.save
        @book.update(available: false)
        redirect_to @book, notice: 'Book borrowed successfully'
      end
    else
      redirect_to @book, alert: 'Book is not available'
    end
  end
  
  def update
    @borrowing = Borrowing.find(params[:id])
    @borrowing.update(
      returned_at: Time.current,
      status: 'returned'
    )
    
    @book = @borrowing.book
    @book.update(available: true)
    
    redirect_to @book, notice: 'Book returned successfully'
  end
end