require 'discordrb'
require 'helpers'

RSpec.configure do |c|
  c.include Helpers
end

module Discordrb
  include Helpers
  describe Bot do
    subject(:bot) do
      described_class.new(token: 'fake_token')
    end

    let!(:server) do
      Discordrb::Server.new(fake_server_data, bot)
    end

    before do
      bot.instance_variable_set(:@servers, SERVER_ID => server)
    end

    it 'should set up' do
      expect(bot.server(SERVER_ID)).to eq(server)
      expect(bot.server(SERVER_ID).emoji.size).to eq(2)
    end

    describe '#handle_dispatch' do
      it 'handles GUILD_EMOJIS_UPDATE' do
        edit_emoji_name = 'changed_emoji_name'
        data = JSON.parse(%({"guild_id":"#{SERVER_ID}","emojis":[{"roles":[],"require_colons":true,"name":"#{edit_emoji_name}","managed":false,"id":"#{EMOJI1_ID}"},{"roles":[],"require_colons":true,"name":"#{EMOJI3_NAME}","managed":false,"id":"#{EMOJI3_ID}"}]}))
        type = :GUILD_EMOJIS_UPDATE
        expect(bot).to receive(:raise_event).exactly(4).times
        bot.send(:handle_dispatch, type, data)
      end
    end

    describe '#update_guild_emoji' do
      it 'removes an emoji' do
        fake_emoji_data = JSON.parse(%({"guild_id":"#{SERVER_ID}","emojis":[{"roles":[],"require_colons":true,"name":"#{EMOJI1_NAME}","managed":false,"id":"#{EMOJI1_ID}"}]}))
        bot.send(:update_guild_emoji, fake_emoji_data)
        emojis = bot.server(SERVER_ID).emoji
        emoji = emojis[EMOJI1_ID]
        expect(emojis.size).to eq(1)
        expect(emoji.name).to eq(EMOJI1_NAME)
        expect(emoji.server).to eq(server)
        expect(emoji.roles).to eq([])
      end

      it 'adds an emoji' do
        fake_emoji_data = JSON.parse(%({"guild_id":"#{SERVER_ID}","emojis":[{"roles":[],"require_colons":true,"name":"#{EMOJI1_NAME}","managed":false,"id":"#{EMOJI1_ID}"},{"roles":[],"require_colons":true,"name":"#{EMOJI2_NAME}","managed":false,"id":"#{EMOJI2_ID}"},{"roles":[],"require_colons":true,"name":"#{EMOJI3_NAME}","managed":false,"id":"#{EMOJI3_ID}"}]}))
        bot.send(:update_guild_emoji, fake_emoji_data)
        emojis = bot.server(SERVER_ID).emoji
        emoji = emojis[EMOJI3_ID]
        expect(emojis.size).to eq(3)
        expect(emoji.name).to eq(EMOJI3_NAME)
        expect(emoji.server).to eq(server)
        expect(emoji.roles).to eq([])
      end

      it 'edits an emoji' do
        emoji_name = 'new_emoji_name'
        fake_emoji_data = JSON.parse(%({"guild_id":"#{SERVER_ID}","emojis":[{"roles":[],"require_colons":true,"name":"#{EMOJI1_NAME}","managed":false,"id":"#{EMOJI1_ID}"},{"roles":[],"require_colons":true,"name":"#{emoji_name}","managed":false,"id":"#{EMOJI2_ID}"}]}))
        bot.send(:update_guild_emoji, fake_emoji_data)
        emojis = bot.server(SERVER_ID).emoji
        emoji = emojis[EMOJI2_ID]
        expect(emojis.size).to eq(2)
        expect(emoji.name).to eq(emoji_name)
        expect(emoji.server).to eq(server)
        expect(emoji.roles).to eq([])
      end
    end
  end
end