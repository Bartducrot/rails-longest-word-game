require 'open-uri'

class GameController < ApplicationController
  def game
    @grid = generate_grid(10)
    @start_time = Time.now.to_i
  end

  def score
    @attempt = params["attempt"]
    @enable = attempt_not_in_grid(@attempt, @grid)
    @start_time = params["start_time"].to_i
    @end_time = Time.now.to_i
    @attempt = params["attempt"]
    @grid = params["grid"].split("")
    @result = run_game(@attempt, @grid, @start_time, @end_time)
  end


  private


  ALPHABET = "azertyuiopqsdfghjklmwxcvbn".upcase
  def generate_grid(grid_size)
    # TODO: generate random grid of letters
    res = []
    res << ALPHABET[Random.new.rand(25)].to_s until res.length == grid_size
    return res
  end
  APICALL1 = "https://api-platform.systran.net/translation/text/translate?source="
  APICALL2 = "en&target=fr&key=fee293f7-30bc-4980-b9a1-c51b5b94ef80&input="
  APICALL = APICALL1 + APICALL2

  def attempt_not_in_grid(attempt, grid)
    # TODO: implement the improved method
    grid = grid.to_s.delete("\"").delete(",").delete(" ").delete("[").delete("]")
    attempt_hash = Hash.new(0)
    attempt.downcase.scan(/[a-z]/).each { |letter| attempt_hash[letter] += 1 }
    grid_hash = Hash.new(0)
    grid.downcase.scan(/[a-z]/).each { |letter| grid_hash[letter] += 1 }
    attempt_hash.each_key { |key| return true if grid_hash[key].zero? || grid_hash[key] < attempt_hash[key] }
    return false
  end

  def result(attempt, start_time, end_time, api_hash)
    res = {}
    res[:translation] = api_hash["outputs"][0]["output"]
    res[:time] = (end_time - start_time)
    res[:score] = (1000.0* attempt.length * 1/(end_time - start_time)).truncate
    # res[:score] = 1000 * (1 / (end_time - start_time)) * attempt.length
    res[:message] = "well done"
    return res
  end

  def run_game(attempt, grid, start_time, end_time)
    # TODO: runs the game and return detailed hash of result
    url = APICALL + attempt
    api_json = open(url).read
    api_hash = JSON.parse(api_json)
    if attempt_not_in_grid(attempt, grid)
      return { translation: "", time: 0, score: 0, message: "not in the grid" }
    elsif attempt == api_hash["outputs"][0]["output"]
      return { translation: nil, time: 0, score: 0, message: "not an english word" }
    else
      return result(attempt, start_time, end_time, api_hash)
    end
  end

end
