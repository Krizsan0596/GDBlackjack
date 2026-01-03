extends Node2D

@onready var cardManager = $CardManager
@onready var deck = $CardManager/Deck
@onready var playerHand = $CardManager/PlayerHand
@onready var dealerHand = $CardManager/DealerHand
@onready var hiddenHand = $CardManager/HiddenDealerHand

@onready var hitButton = $UI/Hit
@onready var standButton = $UI/Stand

var playerCards: Array = []
var dealerCards: Array = []

func _ready() -> void:
	hitButton.pressed.connect(_on_hit)
	standButton.pressed.connect(_on_stand)
	hitButton.visible = false
	standButton.visible = false
	setup_game()

func setup_game():
	await get_tree().create_timer(3).timeout
	create_deck()
	
	for i in 2:
		hit(playerHand)
	hit(hiddenHand)
	hit(dealerHand)
	hitButton.visible = true
	standButton.visible = true

func hit(hand:Hand) -> void:
	if deck.get_card_count() > 0:
			var card = deck.get_top_cards(1)
			if hand == playerHand:
				playerCards.append(card[0])
			else:
				dealerCards.append(card[0])
			hand.move_cards(card)
func create_deck():
	var suits = ["club", "diamond", "heart", "spade"]
	var values = ["A", "2", "3", "4", "5", "6", "7", "8", "9", "10", "J", "Q", "K"]
	
	for suit in suits:
		for value in values:
			var card_name = "%s_%s" % [suit, value]
			var card = cardManager.card_factory.create_card(card_name, deck)
			deck.add_card(card)

func _on_hit():
	hit(playerHand)
	

func _on_stand():
	hitButton.visible = false
	standButton.visible = false
	dealer_turn()
func dealer_turn():
	pass
