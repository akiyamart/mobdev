package ru.snubmaze.chatapp.ui.messages

import android.os.Bundle
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import androidx.activity.OnBackPressedCallback
import androidx.appcompat.app.AlertDialog
import androidx.core.view.ViewCompat
import androidx.core.view.WindowInsetsCompat
import androidx.core.view.updatePadding
import androidx.fragment.app.Fragment
import androidx.fragment.app.activityViewModels
import androidx.fragment.app.viewModels
import androidx.navigation.NavOptions
import androidx.navigation.fragment.findNavController
import androidx.recyclerview.widget.LinearLayoutManager
import androidx.recyclerview.widget.RecyclerView
import ru.snubmaze.chatapp.MainActivity
import ru.snubmaze.chatapp.MainSharedViewModel
import ru.snubmaze.chatapp.R
import ru.snubmaze.chatapp.databinding.FragmentMessagesBinding

class MessagesFragment : Fragment() {

    private val viewModel: MessagesViewModel by viewModels()
    private val sharedViewModel: MainSharedViewModel by activityViewModels()
    private var _binding: FragmentMessagesBinding? = null
    private val binding get() = _binding!!

    private val channelName: String by lazy {
        requireArguments().getString("channelName", "")
    }
    private lateinit var adapter: MessagesAdapter
    private lateinit var layoutManager: LinearLayoutManager

    override fun onCreateView(
        inflater: LayoutInflater,
        container: ViewGroup?,
        savedInstanceState: Bundle?
    ): View {
        _binding = FragmentMessagesBinding.inflate(inflater, container, false)
        return binding.root
    }

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)

        ViewCompat.setOnApplyWindowInsetsListener(binding.root) { _, insets ->
            val bars = insets.getInsets(WindowInsetsCompat.Type.systemBars())
            binding.toolbar.updatePadding(top = bars.top)
            binding.inputLayout.updatePadding(bottom = bars.bottom)
            WindowInsetsCompat.CONSUMED
        }

        sharedViewModel.currentChannel = channelName
        viewModel.setChannel(channelName)
        binding.toolbar.title = channelName

        layoutManager = LinearLayoutManager(requireContext()).apply { stackFromEnd = true }
        binding.messagesRecyclerView.layoutManager = layoutManager

        adapter = MessagesAdapter { imagePath ->
            navigateToImage(imagePath)
        }
        binding.messagesRecyclerView.adapter = adapter

        binding.messagesRecyclerView.addOnScrollListener(object : RecyclerView.OnScrollListener() {
            override fun onScrolled(recyclerView: RecyclerView, dx: Int, dy: Int) {
                if (dy < 0 && layoutManager.findFirstVisibleItemPosition() == 0) {
                    viewModel.loadMoreMessages()
                }
            }
        })

        viewModel.messages.observe(viewLifecycleOwner) { messages ->
            adapter.setMessages(messages)
        }

        viewModel.scrollToBottom.observe(viewLifecycleOwner) {
            val count = adapter.itemCount
            if (count > 0) binding.messagesRecyclerView.scrollToPosition(count - 1)
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

        viewModel.sendSuccess.observe(viewLifecycleOwner) { success ->
            if (success == true) {
                binding.messageEditText.text?.clear()
                viewModel.resetSendSuccess()
            }
        }

        viewModel.unauthorized.observe(viewLifecycleOwner) { isUnauthorized ->
            if (isUnauthorized == true) {
                viewModel.resetUnauthorized()
                navigateToLogin()
            }
        }

        binding.sendButton.setOnClickListener {
            val text = binding.messageEditText.text?.toString()?.trim() ?: ""
            viewModel.sendMessage(text)
        }

        binding.toolbar.setNavigationIcon(R.drawable.ic_back)
        binding.toolbar.navigationContentDescription = getString(R.string.nav_back)
        binding.toolbar.setNavigationOnClickListener { navigateBack() }

        requireActivity().onBackPressedDispatcher.addCallback(
            viewLifecycleOwner,
            object : OnBackPressedCallback(true) {
                override fun handleOnBackPressed() { navigateBack() }
            }
        )
    }

    private fun navigateBack() {
        val mainActivity = activity as? MainActivity
        if (mainActivity?.isLandscape == true) {
            mainActivity.closeMessagesPane()
        } else {
            findNavController().popBackStack()
        }
    }

    private fun navigateToLogin() {
        val mainActivity = activity as? MainActivity
        if (mainActivity?.isLandscape == true) {
            mainActivity.navigateToLogin()
        } else {
            findNavController().navigate(
                R.id.loginFragment,
                null,
                NavOptions.Builder().setPopUpTo(R.id.nav_graph, true).build()
            )
        }
    }

    private fun navigateToImage(imagePath: String) {
        val mainActivity = activity as? MainActivity
        if (mainActivity?.isLandscape == true) {
            val fragment = ru.snubmaze.chatapp.ui.image.ImageFragment().apply {
                arguments = Bundle().apply { putString("imagePath", imagePath) }
            }
            parentFragmentManager.beginTransaction()
                .replace(R.id.messages_pane, fragment)
                .addToBackStack(null)
                .commit()
        } else {
            findNavController().navigate(
                R.id.action_messages_to_image,
                Bundle().apply { putString("imagePath", imagePath) }
            )
        }
    }

    override fun onDestroyView() {
        super.onDestroyView()
        _binding = null
    }
}
