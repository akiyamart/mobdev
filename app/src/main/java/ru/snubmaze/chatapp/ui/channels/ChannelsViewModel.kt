package ru.snubmaze.chatapp.ui.channels

import android.app.Application
import android.content.Context
import androidx.core.content.edit
import androidx.lifecycle.AndroidViewModel
import androidx.lifecycle.LiveData
import androidx.lifecycle.MutableLiveData
import androidx.lifecycle.viewModelScope
import kotlinx.coroutines.launch
import ru.snubmaze.chatapp.R
import ru.snubmaze.chatapp.repository.ChatRepository
import ru.snubmaze.chatapp.repository.NetworkException
import ru.snubmaze.chatapp.repository.ServerException
import ru.snubmaze.chatapp.repository.UnauthorizedException

class ChannelsViewModel(application: Application) : AndroidViewModel(application) {

    private val app: Application = application
    private val repository = ChatRepository()
    private val prefs = application.getSharedPreferences("auth", Context.MODE_PRIVATE)

    private val _channels = MutableLiveData<List<String>>()
    private val _error = MutableLiveData<String?>()
    private val _loading = MutableLiveData<Boolean>()
    private val _unauthorized = MutableLiveData<Boolean>()

    val channels: LiveData<List<String>> = _channels
    val error: LiveData<String?> = _error
    val loading: LiveData<Boolean> = _loading
    val unauthorized: LiveData<Boolean> = _unauthorized

    fun resetUnauthorized() { _unauthorized.value = false }

    private val token: String get() = prefs.getString("token", "") ?: ""

    init {
        loadChannels()
    }

    fun loadChannels() {
        _loading.value = true
        viewModelScope.launch {
            val result = repository.getChannels(token)
            _loading.value = false
            result.fold(
                onSuccess = { _channels.value = it },
                onFailure = {
                    when (it) {
                        is UnauthorizedException -> {
                            prefs.edit { remove("token"); remove("name"); remove("pwd") }
                            _unauthorized.value = true
                        }
                        is NetworkException ->
                            _error.value = app.getString(R.string.error_network)
                        is ServerException ->
                            _error.value = app.getString(R.string.error_server_code, it.code)
                        else ->
                            _error.value = app.getString(R.string.error_unknown)
                    }
                }
            )
        }
    }

    fun logout() {
        val currentToken = token
        prefs.edit { remove("token"); remove("name"); remove("pwd") }
        viewModelScope.launch { repository.logout(currentToken) }
    }
}
