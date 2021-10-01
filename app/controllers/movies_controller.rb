class MoviesController < ApplicationController

    def show
      id = params[:id] # retrieve movie ID from URI route
      @movie = Movie.find(id) # look up movie by unique ID
      # will render app/views/movies/show.<extension> by default
    end
  
    def index
      @all_ratings = Movie.pluck("rating").uniq.sort
      
      params.each do |key, value|
        session[key] = value
      end
      
      @movie_order = session[:sort]

      if not session[:ratings]
        session[:ratings] = {}
        @all_ratings.each do |key, value|
          session[:ratings][key] = 1
        end
        redirect_to controller: "movies", action: "index", :ratings => session[:ratings], :sort => session[:sort]
      end
      
      @checked_ratings = session[:ratings]
      
      if @movie_order == "movie_title"
        @movies = Movie.where(rating: session[:ratings].keys).order(:title)
      elsif @movie_order == "release_date"
        @movies = Movie.order(:release_date).where(rating: session[:ratings].keys)
      else
        @movies = Movie.all.where(rating: session[:ratings].keys)
      end
    end

    def new
      # default: render 'new' template
    end
  
    def create
      @movie = Movie.create!(movie_params)
      flash[:notice] = "#{@movie.title} was successfully created."
      redirect_to movies_path
    end
  
    def edit
      @movie = Movie.find params[:id]
    end
  
    def update
      @movie = Movie.find params[:id]
      @movie.update_attributes!(movie_params)
      flash[:notice] = "#{@movie.title} was successfully updated."
      redirect_to movie_path(@movie)
    end
  
    def destroy
      @movie = Movie.find(params[:id])
      @movie.destroy
      flash[:notice] = "Movie '#{@movie.title}' deleted."
      redirect_to movies_path
    end
  
    private
    # Making "internal" methods private is not required, but is a common practice.
    # This helps make clear which methods respond to requests, and which ones do not.
    def movie_params
      params.require(:movie).permit(:title, :rating, :description, :release_date)
    end
  end