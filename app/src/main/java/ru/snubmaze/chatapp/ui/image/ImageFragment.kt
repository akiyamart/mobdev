package ru.snubmaze.chatapp.ui.image

import android.os.Bundle
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import androidx.fragment.app.Fragment
import androidx.navigation.fragment.findNavController
import com.bumptech.glide.Glide
import ru.snubmaze.chatapp.MainActivity
import ru.snubmaze.chatapp.databinding.FragmentImageBinding
import ru.snubmaze.chatapp.network.RetrofitClient

class ImageFragment : Fragment() {

    private var _binding: FragmentImageBinding? = null
    private val binding get() = _binding!!

    private val imagePath: String by lazy {
        requireArguments().getString("imagePath", "")
    }

    override fun onCreateView(
        inflater: LayoutInflater,
        container: ViewGroup?,
        savedInstanceState: Bundle?
    ): View {
        _binding = FragmentImageBinding.inflate(inflater, container, false)
        return binding.root
    }

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)

        Glide.with(this)
            .load("${RetrofitClient.BASE_URL}img/$imagePath")
            .placeholder(android.R.drawable.ic_menu_gallery)
            .into(binding.fullImage)

        binding.closeButton.setOnClickListener {
            val mainActivity = activity as? MainActivity
            if (mainActivity?.isLandscape == true) {
                parentFragmentManager.popBackStack()
            } else {
                findNavController().popBackStack()
            }
        }
    }

    override fun onDestroyView() {
        super.onDestroyView()
        _binding = null
    }
}
