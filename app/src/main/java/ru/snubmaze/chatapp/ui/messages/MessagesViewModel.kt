package ru.snubmaze.chatapp.ui.messages

import android.app.Application
import android.content.Context
import androidx.core.content.edit
import androidx.lifecycle.AndroidViewModel
import androidx.lifecycle.LiveData
import androidx.lifecycle.MutableLiveData
import androidx.lifecycle.viewModelScope
import kotlinx.coroutines.launch
import ru.snubmaze.chatapp.R
import ru.snubmaze.chatapp.data.model.Message
import ru.snubmaze.chatapp.repository.ChatRepository
import ru.snubmaze.chatapp.repository.NetworkException
import ru.snubmaze.chatapp.repository.ServerException
import ru.snubmaze.chatapp.repository.UnauthorizedException

class MessagesViewModel(application: Application) : AndroidViewModel(application) {

    private val app: Application = application
    private val repository = ChatRepository()
    private val prefs = application.getSharedPreferences("auth", Context.MODE_PRIVATE)

    private val _messages = MutableLiveData<List<Message>>()
    private val _error = MutableLiveData<String?>()
    private val _loading = MutableLiveData<Boolean>()
    private val _sendSuccess = MutableLiveData<Boolean>()
    private val _scrollToBottom = MutableLiveData<Unit>()
    private val _unauthorized = MutableLiveData<Boolean>()

    val messages: LiveData<List<Message>> = _messages
    val error: LiveData<String?> = _error
    val loading: LiveData<Boolean> = _loading
    val sendSuccess: LiveData<Boolean> = _sendSuccess
    val scrollToBottom: LiveData<Unit> = _scrollToBottom
    val unauthorized: LiveData<Boolean> = _unauthorized

    fun resetUnauthorized() { _unauthorized.value = false }

    private val token: String get() = prefs.getString("token", "") ?: ""
    val userName: String get() = prefs.getString("name", "") ?: ""

    var currentChannel: String = ""
        private set

    private var oldestKnownId: String = "0"
    private var hasMoreMessages: Boolean = true

    fun setChannel(channelName: String) {
        if (currentChannel == channelName) return
        currentChannel = channelName
        oldestKnownId = Int.MAX_VALUE.toString()
        hasMoreMessages = true
        _messages.value = emptyList()
        loadMessages()
    }

    fun loadMessages() {
        if (_loading.value == true) return
        _loading.value = true
        viewModelScope.launch {
            val result = repository.getMessages(
                token = token,
                channelName = currentChannel,
                lastKnownId = Int.MAX_VALUE.toString(),
                reverse = true
            )
            _loading.value = false
            result.fold(
                onSuccess = { newMessages ->
                    val ordered = newMessages.reversed()
                    _messages.value = ordered
                    oldestKnownId = ordered.firstOrNull()?.id ?: Int.MAX_VALUE.toString()
                    hasMoreMessages = newMessages.size >= 20
                    _scrollToBottom.value = Unit
                },
                onFailure = { handleError(it) }
            )
        }
    }

    fun loadMoreMessages() {
        if (_loading.value == true || !hasMoreMessages) return
        _loading.value = true
        viewModelScope.launch {
            val result = repository.getMessages(
                token = token,
                channelName = currentChannel,
                lastKnownId = oldestKnownId,
                reverse = true
            )
            _loading.value = false
            result.fold(
                onSuccess = { olderMessages ->
                    if (olderMessages.isEmpty()) {
                        hasMoreMessages = false
                    } else {
                        oldestKnownId = olderMessages.last().id
                        val current = _messages.value ?: emptyList()
                        _messages.value = olderMessages.reversed() + current
                    }
                },
                onFailure = { handleError(it) }
            )
        }
    }

    fun sendMessage(text: String) {
        if (text.isBlank()) return
        viewModelScope.launch {
            val result = repository.sendMessage(
                token = token,
                from = userName,
                to = currentChannel,
                text = text
            )
            result.fold(
                onSuccess = {
                    _sendSuccess.value = true
                    loadMessages()
                },
                onFailure = { handleError(it) }
            )
        }
    }

    fun resetSendSuccess() {
        _sendSuccess.value = false
    }

    private fun handleError(error: Throwable) {
        when (error) {
            is UnauthorizedException -> {
                prefs.edit { remove("token"); remove("name"); remove("pwd") }
                _unauthorized.value = true
            }
            is NetworkException ->
                _error.value = app.getString(R.string.error_network)
            is ServerException ->
                _error.value = app.getString(R.string.error_server_code, error.code)
            else ->
                _error.value = app.getString(R.string.error_unknown)
        }
    }
}
