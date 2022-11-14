require 'open-uri'
require 'json'

class GamesController < ApplicationController

  def new
    grid = []
    7.times { grid.push(('a'..'z').to_a[rand(26)]) }
    3.times { grid.push(["a", "e", "i", "o", "u"].sample) }
    @grid = grid
    @start_time = Time.now.to_i
  end

  def score
    @end_time = Time.now.to_i
    @start_time = params[:start_time].to_i
    @grid = params[:grid].split
    @attempt = params[:attempt]
    run_game(@attempt, @grid, @start_time, @end_time)
  end

  def run_game(attempt, grid, start_time, end_time)
    # TODO: runs the game and return detailed hash of result (with `:score`, `:message` and `:time` keys)
    url = "https://wagon-dictionary.herokuapp.com/#{attempt}"
    word = JSON.parse(URI.open(url).read)
    result = {
      score: 0,
      message: "",
      time: 0
    }
    result[:time] = end_time - start_time
    return return_result(word, grid, attempt, result)
  end

  def return_result(word, grid, attempt, result)
    gridtest = get_gridtest(grid, attempt)

    if word["found"] && (grid.join(' ').downcase.split & attempt.chars).size == gridtest
      result[:message] = 'Well Done!'
      result[:score] = attempt.size + (20 - (result[:time])).to_i
    elsif word["found"]
      result[:message] = 'Not in the grid'
    else
      result[:message] = "Not an english word"
    end
    @result = result
  end

  def get_gridtest(grid, attempt)
    gridtest = attempt.size
    doublonattempt = attempt.chars.detect { |e| attempt.chars.count(e) > 1 }
    doublongrid = ''
    doublongrid = grid.detect { |e| grid.count(e) > 1 } if grid.detect { |e| grid.count(e) > 1 }
    gridtest -= 1 if doublonattempt == doublongrid.downcase
    gridtest
  end
end
