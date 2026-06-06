package ru.snubmaze.chatapp.ui.login

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
import ru.snubmaze.chatapp.repository.InvalidCredentialsException
import ru.snubmaze.chatapp.repository.NetworkException
import ru.snubmaze.chatapp.repository.ServerException

class LoginViewModel(application: Application) : AndroidViewModel(application) {

    private val app: Application = application
    private val repository = ChatRepository()

    private val _loginState = MutableLiveData<LoginState>()
    val loginState: LiveData<LoginState> = _loginState

    private val prefs = application.getSharedPreferences("auth", Context.MODE_PRIVATE)

    init {
        val savedName = prefs.getString("name", null)
        val savedPwd = prefs.getString("pwd", null)
        if (savedName != null && savedPwd != null) {
            doLogin(savedName, savedPwd)
        }
    }

    fun doLogin(name: String, password: String) {
        _loginState.value = LoginState.Loading
        viewModelScope.launch {
            val result = repository.login(name, password)
            result.fold(
                onSuccess = { token ->
                    prefs.edit {
                        putString("name", name)
                        putString("pwd", password)
                        putString("token", token)
                    }
                    _loginState.value = LoginState.Success(token, name)
                },
                onFailure = { error ->
                    val message = when (error) {
                        is InvalidCredentialsException ->
                            app.getString(R.string.error_wrong_credentials)
                        is NetworkException ->
                            app.getString(R.string.error_network)
                        is ServerException ->
                            app.getString(R.string.error_server_code, error.code)
                        else ->
                            app.getString(R.string.error_unknown)
                    }
                    _loginState.value = LoginState.Error(message)
                }
            )
        }
    }
}

sealed class LoginState {
    object Loading : LoginState()
    data class Success(val token: String, val name: String) : LoginState()
    data class Error(val message: String) : LoginState()
}
