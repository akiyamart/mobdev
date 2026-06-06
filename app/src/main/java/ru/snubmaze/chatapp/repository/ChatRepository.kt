package ru.snubmaze.chatapp.repository

import kotlinx.coroutines.CancellationException
import kotlinx.coroutines.delay
import ru.snubmaze.chatapp.data.model.*
import ru.snubmaze.chatapp.network.RetrofitClient
import java.io.IOException
import java.time.Instant

class UnauthorizedException : Exception()
class NetworkException : Exception()
class InvalidCredentialsException : Exception()
class ServerException(val code: Int) : Exception()

class ChatRepository {

    companion object {
        const val USE_MOCK = true

        private val mockMessages: MutableMap<String, MutableList<Message>> = mutableMapOf(
            "general" to mutableListOf(
                Message("1", "alice", "general",
                    MessageData(TextContent("Привет всем!"), null), "2025-01-01T10:00:00Z"),
                Message("2", "bob", "general",
                    MessageData(TextContent("Привет! Как дела?"), null), "2025-01-01T10:01:00Z"),
                Message("3", "alice", "general",
                    MessageData(TextContent("Всё отлично, спасибо!"), null), "2025-01-01T10:02:00Z"),
            ),
            "kotlin" to mutableListOf(
                Message("10", "dev1", "kotlin",
                    MessageData(TextContent("Кто пользуется Coroutines?"), null), "2025-01-02T09:00:00Z"),
                Message("11", "dev2", "kotlin",
                    MessageData(TextContent("Flow очень удобен"), null), "2025-01-02T09:01:00Z"),
                Message("12", "dev1", "kotlin",
                    MessageData(TextContent("Согласен, особенно StateFlow"), null), "2025-01-02T09:05:00Z"),
            ),
            "android" to mutableListOf(
                Message("20", "tester", "android",
                    MessageData(TextContent("Эмулятор тормозит"), null), "2025-01-03T11:00:00Z"),
                Message("21", "dev1", "android",
                    MessageData(TextContent("Попробуй физическое устройство"), null), "2025-01-03T11:05:00Z"),
                Message("22", "tester", "android",
                    MessageData(TextContent("Стало лучше, спасибо!"), null), "2025-01-03T11:10:00Z"),
            ),
            "random" to mutableListOf(
                Message("30", "bob", "random",
                    MessageData(TextContent("Хорошая погода сегодня"), null), "2025-01-04T15:00:00Z"),
                Message("31", "alice", "random",
                    MessageData(TextContent("Да, наконец-то тепло!"), null), "2025-01-04T15:01:00Z"),
            ),
            "itmo" to mutableListOf(
                Message("40", "student", "itmo",
                    MessageData(TextContent("Когда дедлайн по лабе?"), null), "2025-01-05T08:00:00Z"),
                Message("41", "teacher", "itmo",
                    MessageData(TextContent("Сдача в пятницу до 23:59"), null), "2025-01-05T08:30:00Z"),
            ),
        )
        private var mockIdCounter = 100
    }

    private val api = if (!USE_MOCK) RetrofitClient.api else null

    suspend fun login(name: String, password: String): Result<String> {
        if (USE_MOCK) {
            delay(500)
            return Result.success("mock-token-$name")
        }
        return try {
            val response = api!!.login(LoginRequest(name, password))
            if (response.isSuccessful) {
                val token = response.body()
                if (token != null) Result.success(token)
                else Result.failure(ServerException(-1))
            } else {
                when (response.code()) {
                    401 -> Result.failure(InvalidCredentialsException())
                    else -> Result.failure(ServerException(response.code()))
                }
            }
        } catch (e: CancellationException) {
            throw e
        } catch (e: IOException) {
            Result.failure(NetworkException())
        } catch (e: Exception) {
            Result.failure(ServerException(-1))
        }
    }

    suspend fun getChannels(token: String): Result<List<String>> {
        if (USE_MOCK) {
            delay(300)
            return Result.success(mockMessages.keys.toList())
        }
        return try {
            val response = api!!.getChannels(token)
            when {
                response.isSuccessful -> Result.success(response.body() ?: emptyList())
                response.code() == 401 -> Result.failure(UnauthorizedException())
                else -> Result.failure(ServerException(response.code()))
            }
        } catch (e: CancellationException) {
            throw e
        } catch (e: IOException) {
            Result.failure(NetworkException())
        } catch (e: Exception) {
            Result.failure(ServerException(-1))
        }
    }

    suspend fun getMessages(
        token: String,
        channelName: String,
        lastKnownId: String = "0",
        reverse: Boolean = false
    ): Result<List<Message>> {
        if (USE_MOCK) {
            delay(400)
            val msgs = mockMessages.getOrPut(channelName) { mutableListOf() }
            return Result.success(msgs.reversed())
        }
        return try {
            val response = api!!.getMessages(
                token, channelName, limit = 20,
                lastKnownId = lastKnownId, reverse = reverse
            )
            when {
                response.isSuccessful -> Result.success(response.body() ?: emptyList())
                response.code() == 401 -> Result.failure(UnauthorizedException())
                else -> Result.failure(ServerException(response.code()))
            }
        } catch (e: CancellationException) {
            throw e
        } catch (e: IOException) {
            Result.failure(NetworkException())
        } catch (e: Exception) {
            Result.failure(ServerException(-1))
        }
    }

    suspend fun sendMessage(
        token: String,
        from: String,
        to: String,
        text: String
    ): Result<Unit> {
        if (USE_MOCK) {
            delay(300)
            val msg = Message(
                id = (++mockIdCounter).toString(),
                from = from,
                to = to,
                data = MessageData(TextContent(text), null),
                time = Instant.now().toString()
            )
            mockMessages.getOrPut(to) { mutableListOf() }.add(msg)
            return Result.success(Unit)
        }
        return try {
            val request = SendMessageRequest(
                from = from,
                to = to,
                data = MessageData(text = TextContent(text), image = null)
            )
            val response = api!!.sendMessage(token, request)
            when {
                response.isSuccessful -> Result.success(Unit)
                response.code() == 401 -> Result.failure(UnauthorizedException())
                else -> Result.failure(ServerException(response.code()))
            }
        } catch (e: CancellationException) {
            throw e
        } catch (e: IOException) {
            Result.failure(NetworkException())
        } catch (e: Exception) {
            Result.failure(ServerException(-1))
        }
    }

    suspend fun logout(token: String) {
        if (USE_MOCK) return
        try { api!!.logout(token) } catch (e: Exception) { }
    }
}
