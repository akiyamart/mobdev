package ru.snubmaze.chatapp.ui.channels

import android.os.Bundle
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import androidx.appcompat.app.AlertDialog
import androidx.core.view.ViewCompat
import androidx.core.view.WindowInsetsCompat
import androidx.core.view.updatePadding
import androidx.fragment.app.Fragment
import androidx.fragment.app.viewModels
import androidx.navigation.fragment.findNavController
import androidx.recyclerview.widget.LinearLayoutManager
import ru.snubmaze.chatapp.MainActivity
import ru.snubmaze.chatapp.R
import ru.snubmaze.chatapp.databinding.FragmentChannelsBinding

class ChannelsFragment : Fragment() {

    private val viewModel: ChannelsViewModel by viewModels()
    private var _binding: FragmentChannelsBinding? = null
    private val binding get() = _binding!!
    private lateinit var adapter: ChannelsAdapter

    private var selectedChannel: String? = null

    override fun onCreateView(
        inflater: LayoutInflater,
        container: ViewGroup?,
        savedInstanceState: Bundle?
    ): View {
        _binding = FragmentChannelsBinding.inflate(inflater, container, false)
        return binding.root
    }

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)

        ViewCompat.setOnApplyWindowInsetsListener(binding.root) { _, insets ->
            val bars = insets.getInsets(WindowInsetsCompat.Type.systemBars())
            binding.toolbar.updatePadding(top = bars.top)
            WindowInsetsCompat.CONSUMED
        }

        adapter = ChannelsAdapter { channelName ->
            selectedChannel = channelName
            adapter.setSelectedChannel(channelName)

            val mainActivity = activity as? MainActivity
            if (mainActivity?.isLandscape == true) {
                mainActivity.openChannelInPane(channelName)
            } else {
                findNavController().navigate(
                    R.id.action_channels_to_messages,
                    Bundle().apply { putString("channelName", channelName) }
                )
            }
        }

        binding.channelsRecyclerView.layoutManager = LinearLayoutManager(requireContext())
        binding.channelsRecyclerView.adapter = adapter

        viewModel.channels.observe(viewLifecycleOwner) { channels ->
            adapter.setChannels(channels)
            adapter.setSelectedChannel(selectedChannel)
        }

        viewModel.loading.observe(viewLifecycleOwner) { isLoading ->
            binding.progressBar.visibility = if (isLoading) View.VISIBLE else View.GONE
        }

        viewModel.error.observe(viewLifecycleOwner) { error ->
            error?.let {
                AlertDialog.Builder(requireContext())
                    .setTitle(R.string.error_dialog_title)
                    .setMessage(it)
                    .setPositiveButton(R.string.btn_ok, null)
                    .show()
            }
        }

        viewModel.unauthorized.observe(viewLifecycleOwner) { isUnauthorized ->
            if (isUnauthorized == true) {
                viewModel.resetUnauthorized()
                navigateToLogin()
            }
        }

        binding.logoutButton.setOnClickListener {
            viewModel.logout()
            navigateToLogin()
        }
    }

    private fun navigateToLogin() {
        val mainActivity = activity as? MainActivity
        if (mainActivity?.isLandscape == true) {
            mainActivity.navigateToLogin()
        } else {
            findNavController().navigate(R.id.action_channels_to_login)
        }
    }

    fun clearSelection() {
        selectedChannel = null
        if (_binding != null) adapter.setSelectedChannel(null)
    }

    override fun onDestroyView() {
        super.onDestroyView()
        _binding = null
    }
}
