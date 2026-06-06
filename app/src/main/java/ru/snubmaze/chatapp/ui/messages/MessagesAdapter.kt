package ru.snubmaze.chatapp.ui.messages

import android.view.LayoutInflater
import android.view.ViewGroup
import android.widget.ImageView
import android.widget.TextView
import androidx.recyclerview.widget.RecyclerView
import com.bumptech.glide.Glide
import ru.snubmaze.chatapp.R
import ru.snubmaze.chatapp.data.model.Message
import ru.snubmaze.chatapp.network.RetrofitClient

class MessagesAdapter(
    private val onImageClick: (String) -> Unit
) : RecyclerView.Adapter<RecyclerView.ViewHolder>() {

    private var items: List<Message> = emptyList()

    companion object {
        private const val TYPE_TEXT = 0
        private const val TYPE_IMAGE = 1
    }

    fun setMessages(messages: List<Message>) {
        items = messages
        notifyDataSetChanged()
    }

    class TextViewHolder(parent: ViewGroup) : RecyclerView.ViewHolder(
        LayoutInflater.from(parent.context)
            .inflate(R.layout.item_message_text, parent, false)
    ) {
        val sender: TextView = itemView.findViewById(R.id.senderText)
        val text: TextView = itemView.findViewById(R.id.messageText)
    }

    class ImageViewHolder(parent: ViewGroup) : RecyclerView.ViewHolder(
        LayoutInflater.from(parent.context)
            .inflate(R.layout.item_message_image, parent, false)
    ) {
        val sender: TextView = itemView.findViewById(R.id.senderText)
        val image: ImageView = itemView.findViewById(R.id.messageImage)
    }

    override fun getItemViewType(position: Int): Int {
        return if (items[position].data.image != null) TYPE_IMAGE else TYPE_TEXT
    }

    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): RecyclerView.ViewHolder {
        return if (viewType == TYPE_IMAGE) ImageViewHolder(parent)
        else TextViewHolder(parent)
    }

    override fun onBindViewHolder(holder: RecyclerView.ViewHolder, position: Int) {
        val message = items[position]
        when (holder) {
            is TextViewHolder -> {
                holder.sender.text = message.from
                holder.text.text = message.data.text?.text ?: ""
            }
            is ImageViewHolder -> {
                holder.sender.text = message.from
                val link = message.data.image?.link ?: ""
                Glide.with(holder.image.context)
                    .load("${RetrofitClient.BASE_URL}thumb/$link")
                    .placeholder(android.R.drawable.ic_menu_gallery)
                    .into(holder.image)
                holder.image.setOnClickListener {
                    onImageClick(link)
                }
            }
        }
    }

    override fun getItemCount() = items.size
}