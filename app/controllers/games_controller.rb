require 'open-uri'
require 'json'

class GamesController < ApplicationController
  def new
    @letters = generate_grid(10).join(" ")
    @start_time = Time.now
  end

  def score
    @attempt = params[:attempt]
    letters = params[:hidden_letters]
    start_time = Time.parse(params[:hidden_time])
    @end_time = Time.now
    @result = run_game(@attempt, letters, start_time, @end_time)
  end
end

def generate_grid(grid_size)
  characters = ('a'..'z').to_a
  grid_size.times.map { characters.sample }
end

def existing_word?(attempt)
  word = JSON.parse(URI.open("https://wagon-dictionary.herokuapp.com/#{attempt}").read)
  word['found']
end

def check_grid(attempt, grid)
  attempt.chars.all? { |letter| grid.include? letter }
end

def give_score_and_message(attempt, time)
  score_and_message = []
  score_and_message[0] = existing_word?(attempt) ? attempt.length * (attempt.length / time.to_f) : 0
  score_and_message[1] = existing_word?(attempt) ? 'Well done!' : 'Not an English word, sorry!'
  score_and_message
end

def run_game(attempt, grid, start_time, end_time)
  time = end_time - start_time
  if check_grid(attempt, grid) == true
    score = give_score_and_message(attempt, time)[0]
    message = give_score_and_message(attempt, time)[1]
    { time: time, score: score, message: message }
  else
    { time: time, score: 0, message: 'Not in the grid!' }
  end
end
