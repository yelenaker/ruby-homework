# ================================
# Сервіс Notifier
# ================================
# Він приймає будь-який об'єкт, який має метод #deliver(message)
# (це може бути Email-сервіс, Slack-бот тощо)
# ================================

class Notifier
  def initialize(deliverer)
    @deliverer = deliverer  # об'єкт, який вміє доставляти повідомлення
  end

  def notify(message)
    @deliverer.deliver(message)
  end
end

# ================================
# Адаптер Email (макет / mock)
# ================================
# Імітує роботу з email — просто виводить повідомлення в консоль
# ================================

class EmailAdapter
  def deliver(message)
    puts "[EMAIL] Відправлено повідомлення: #{message}"
  end
end

# ================================
# Адаптер Slack (макет / mock)
# ================================
# Імітує відправку повідомлення у Slack
# ================================

class SlackAdapter
  def deliver(message)
    puts "[SLACK] Відправлено повідомлення: #{message}"
  end
end

# ================================
# Приклад використання
# ================================

email_notifier = Notifier.new(EmailAdapter.new)
slack_notifier = Notifier.new(SlackAdapter.new)

email_notifier.notify("Привіт з Ruby через Email!")
slack_notifier.notify("Привіт з Ruby через Slack!")
