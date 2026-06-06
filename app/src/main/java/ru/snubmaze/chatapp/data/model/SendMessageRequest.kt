package ru.snubmaze.chatapp.data.model

data class SendMessageRequest(
    val from: String,
    val to: String,
    val data: MessageData
)
