package de.chojo.shepquotes.config.elements;

import com.fasterxml.jackson.annotation.JsonCreator;
import com.fasterxml.jackson.annotation.JsonProperty;
import de.chojo.jdautil.localization.util.Replacement;
import net.dv8tion.jda.api.entities.Activity;

import java.util.List;
import java.util.concurrent.ThreadLocalRandom;

@SuppressWarnings({"FieldMayBeFinal", "FieldCanBeLocal"})
public class PresenceSettings {
    private boolean active;
    private int interval = 5;
    private List<Presence> status = List.of(
    );

    public boolean isActive() {
        return active;
    }

    public List<Presence> status() {
        return status;
    }

    public Presence randomStatus() {
        if (status.isEmpty()) return Presence.of(Activity.ActivityType.WATCHING, "something");
        return status.get(ThreadLocalRandom.current().nextInt(status.size()));
    }

    public int interval() {
        return interval;
    }

    public static class Presence {
        private Activity.ActivityType type;
        private String text;

        @JsonCreator(mode = JsonCreator.Mode.PROPERTIES)
        public Presence(@JsonProperty("type") Activity.ActivityType type, @JsonProperty("text") String text) {
            this.type = type;
            this.text = text;
        }

        public static Presence of(Activity.ActivityType type, String text) {
            return new Presence(type, text);
        }

        public Activity.ActivityType type() {
            return type;
        }

        public String text(List<Replacement> replacements) {
            var message = text;
            for (Replacement replacement : replacements) {
                message = replacement.invoke(message);
            }
            return message;
        }
    }
}
