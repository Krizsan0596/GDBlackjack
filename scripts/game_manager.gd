extends Node2D

@onready var cardManager = $CardManager
@onready var deck = $CardManager/Deck
@onready var playerHand = $CardManager/PlayerHand
@onready var dealerHand = $CardManager/DealerHand
@onready var hiddenHand = $CardManager/HiddenDealerHand

@onready var outText = $UI/OutText
@onready var hitButton = $UI/Hit
@onready var standButton = $UI/Stand
@onready var quitButton = $UI/Quit
@onready var playAgainButton = $"UI/Play Again"

enum gameState {
	PLAYING, 
	PLAYER_BUST,
	DEALER_BUST,
	PLAYER_BJ,
	DEALER_BJ,
	PLAYER_WIN,
	DEALER_WIN,
	PUSH
}

var state = gameState.PLAYING

var playerScore: int
var dealerScore: int

var playerCards: Array = []
var dealerCards: Array = []

func _ready() -> void:
	hitButton.pressed.connect(_on_hit)
	standButton.pressed.connect(_on_stand)
	hitButton.visible = false
	standButton.visible = false
	quitButton.pressed.connect(_on_quit)
	playAgainButton.pressed.connect(_on_play_again)
	playAgainButton.visible = false
	quitButton.visible = false
	await get_tree().create_timer(1).timeout
	setup_game()
	playerScore = sum_hand(playerCards)
	dealerScore = sum_hand(dealerCards)
	if playerScore == 21 and dealerScore == 21:
		dealerHand.move_cards(hiddenHand.get_random_cards(1), 0)
		game_end(gameState.PUSH)
	if playerScore == 21:
		dealerHand.move_cards(hiddenHand.get_random_cards(1), 0)
		game_end(gameState.PLAYER_BJ)
	if dealerScore == 21:
		dealerHand.move_cards(hiddenHand.get_random_cards(1), 0)
		game_end(gameState.DEALER_BJ)
	

func setup_game():
	create_deck()
	await get_tree().create_timer(.5).timeout
	
	await deal_cards()
	
func deal_cards():
	for i in 2:
		hit(playerHand)
		await get_tree().create_timer(.2).timeout
	hit(hiddenHand)
	await get_tree().create_timer(.2).timeout
	hit(dealerHand)
	hitButton.visible = true
	standButton.visible = true

func hit(hand:Hand) -> void:
	if deck.get_card_count() > 0:
			var card = deck.get_top_cards(1)
			hand.move_cards(card)
			if hand == playerHand:
				playerCards.append(card[0])
				playerScore = sum_hand(playerCards)
				if playerScore > 21:
					game_end(gameState.PLAYER_BUST)
					
			else:
				dealerCards.append(card[0])
				dealerScore = sum_hand(dealerCards)
				if dealerScore > 21:
					game_end(gameState.DEALER_BUST)
func create_deck():
	var suits = ["club", "diamond", "heart", "spade"]
	var values = ["A", "2", "3", "4", "5", "6", "7", "8", "9", "10", "J", "Q", "K"]
	
	for suit in suits:
		for value in values:
			var card_name = "%s_%s" % [suit, value]
			var card = cardManager.card_factory.create_card(card_name, deck)
			card.can_be_interacted_with = false
			deck.add_card(card)
	deck.shuffle()

func _on_hit():
	hit(playerHand)

func _on_stand():
	hitButton.visible = false
	standButton.visible = false
	dealer_turn()

func _on_play_again():
	playAgainButton.visible = false
	quitButton.visible = false
	outText.text = ""
	deck.undo(dealerCards)
	deck.undo(playerCards)
	deck.shuffle()
	await get_tree().create_timer(.5).timeout
	playerCards.clear()
	dealerCards.clear()
	deal_cards()

func _on_quit():
	get_tree().quit()

func sum_hand(hand:Array) -> int:
	var ace_count:int = 0
	var sum:int = 0
	for card in hand:
		var value = card.card_name.split("_")[-1]
		if value == "A":
			ace_count += 1
			sum += 1
		elif value == "K" or value == "Q" or value == "J":
			sum += 10
		else:
			sum += int(value)
	while ace_count > 0 and sum <= 11:
		sum += 10
		ace_count -= 1
	return sum
	
func game_end(end_state:gameState):
	hitButton.visible = false
	standButton.visible = false
	quitButton.visible = true
	playAgainButton.visible = true
	if end_state == gameState.PLAYER_BUST:
		outText.text = "You bust! Better luck next time!"
	if end_state == gameState.DEALER_BUST:
		outText.text = "The dealer bust! You win!"
	if end_state == gameState.PLAYER_BJ:
		outText.text = "You got blackjack! You win!"
	if end_state == gameState.DEALER_BJ:
		outText.text = "The dealer got blackjack! You lose!"
	if end_state == gameState.PLAYER_WIN:
		outText.text = "You beat the dealer! You win!"
	if end_state == gameState.DEALER_WIN:
		outText.text = "The dealer beat you! Better luck next time!"
	if end_state == gameState.PUSH:
		outText.text = "It's a tie!"
func dealer_turn():
	dealerHand.move_cards(hiddenHand.get_random_cards(1), 0)
	while dealerScore < 17:
		hit(dealerHand)
		await get_tree().create_timer(.2).timeout
	if dealerScore <= 21:
		if dealerScore > playerScore:
			game_end(gameState.DEALER_WIN)
		elif dealerScore < playerScore:
			game_end(gameState.PLAYER_WIN)
		elif dealerScore == playerScore:
			game_end(gameState.PUSH)
