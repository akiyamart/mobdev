package ru.snubmaze.chatapp.ui.channels

import android.view.LayoutInflater
import android.view.ViewGroup
import android.widget.TextView
import androidx.recyclerview.widget.RecyclerView
import ru.snubmaze.chatapp.R

class ChannelsAdapter(
    private val onClick: (String) -> Unit
) : RecyclerView.Adapter<ChannelsAdapter.ViewHolder>() {

    private var items: List<String> = emptyList()

    private var selectedChannel: String? = null

    fun setChannels(channels: List<String>) {
        items = channels
        notifyDataSetChanged()
    }

    fun setSelectedChannel(channel: String?) {
        selectedChannel = channel
        notifyDataSetChanged()
    }

    class ViewHolder(val textView: TextView) : RecyclerView.ViewHolder(textView)

    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): ViewHolder {
        val view = LayoutInflater.from(parent.context)
            .inflate(R.layout.item_channel, parent, false) as TextView
        return ViewHolder(view)
    }

    override fun onBindViewHolder(holder: ViewHolder, position: Int) {
        val channel = items[position]
        holder.textView.text = channel

        if (channel == selectedChannel) {
            holder.textView.setBackgroundColor(
                holder.textView.context.getColor(R.color.channel_selected)
            )
        } else {
            holder.textView.setBackgroundResource(R.drawable.selector_channel_item)
        }

        holder.textView.setOnClickListener { onClick(channel) }
    }

    override fun getItemCount() = items.size
}