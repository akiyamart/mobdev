package ru.snubmaze.chatapp

import android.content.res.Configuration
import android.os.Bundle
import android.view.View
import androidx.activity.viewModels
import androidx.appcompat.app.AppCompatActivity
import androidx.core.view.WindowCompat
import androidx.navigation.fragment.NavHostFragment
import ru.snubmaze.chatapp.databinding.ActivityMainBinding
import ru.snubmaze.chatapp.ui.SelectChatFragment
import ru.snubmaze.chatapp.ui.channels.ChannelsFragment
import ru.snubmaze.chatapp.ui.messages.MessagesFragment

class MainActivity : AppCompatActivity() {

    private lateinit var binding: ActivityMainBinding
    val sharedViewModel: MainSharedViewModel by viewModels()

    val isLandscape: Boolean
        get() = resources.configuration.orientation == Configuration.ORIENTATION_LANDSCAPE

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        WindowCompat.setDecorFitsSystemWindows(window, false)

        if (!isLandscape && savedInstanceState != null) {
            supportFragmentManager.beginTransaction().apply {
                supportFragmentManager.findFragmentById(R.id.channels_pane)?.let { remove(it) }
                supportFragmentManager.findFragmentById(R.id.messages_pane)?.let { remove(it) }
            }.commitNow()
        }

        binding = ActivityMainBinding.inflate(layoutInflater)
        setContentView(binding.root)

        if (isLandscape) setupLandscape()
    }

    private fun setupLandscape() {
        val token = getSharedPreferences("auth", MODE_PRIVATE).getString("token", null)
        if (token.isNullOrEmpty()) {
            showLoginForLandscape()
        } else {
            setupTwoPaneLandscape()
        }
    }

    private fun showLoginForLandscape() {
        supportFragmentManager.beginTransaction().apply {
            supportFragmentManager.findFragmentById(R.id.channels_pane)?.let { remove(it) }
            supportFragmentManager.findFragmentById(R.id.messages_pane)?.let { remove(it) }
        }.commitNow()

        binding.twoPaneLayout?.visibility = View.GONE
        binding.navHostFragment.visibility = View.VISIBLE

        if (supportFragmentManager.findFragmentById(R.id.nav_host_fragment) == null) {
            val navHostFragment = NavHostFragment.create(R.navigation.nav_graph)
            supportFragmentManager.beginTransaction()
                .add(R.id.nav_host_fragment, navHostFragment)
                .setPrimaryNavigationFragment(navHostFragment)
                .commitNow()
        }
    }

    private fun setupTwoPaneLandscape() {
        supportFragmentManager.findFragmentById(R.id.nav_host_fragment)?.let {
            supportFragmentManager.beginTransaction().remove(it).commitNow()
        }

        binding.twoPaneLayout?.visibility = View.VISIBLE
        binding.navHostFragment.visibility = View.GONE

        if (supportFragmentManager.findFragmentById(R.id.channels_pane) == null) {
            supportFragmentManager.beginTransaction()
                .replace(R.id.channels_pane, ChannelsFragment())
                .commitNow()
        }

        val channel = sharedViewModel.currentChannel
        if (channel != null && supportFragmentManager.findFragmentById(R.id.messages_pane) == null) {
            openChannelInPane(channel)
        } else if (supportFragmentManager.findFragmentById(R.id.messages_pane) == null) {
            supportFragmentManager.beginTransaction()
                .replace(R.id.messages_pane, SelectChatFragment())
                .commitNow()
        }
    }

    fun openChannelInPane(channelName: String) {
        sharedViewModel.currentChannel = channelName
        val fragment = MessagesFragment().apply {
            arguments = Bundle().apply { putString("channelName", channelName) }
        }
        supportFragmentManager.beginTransaction()
            .replace(R.id.messages_pane, fragment)
            .commit()
    }

    fun closeMessagesPane() {
        sharedViewModel.currentChannel = null
        supportFragmentManager.beginTransaction()
            .replace(R.id.messages_pane, SelectChatFragment())
            .commit()
        val channels = supportFragmentManager.findFragmentById(R.id.channels_pane)
        if (channels is ChannelsFragment) channels.clearSelection()
    }

    fun navigateToLogin() {
        if (isLandscape) showLoginForLandscape()
    }

    fun onLoginSuccessInLandscape() {
        binding.root.post { setupTwoPaneLandscape() }
    }
}
