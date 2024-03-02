CREATE TABLE IF NOT EXISTS centrifugo_outbox (
	id BIGSERIAL PRIMARY KEY,
	method text NOT NULL,
	payload JSONB NOT NULL,
	partition INTEGER NOT NULL default 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT now() NOT NULL
);

CREATE OR REPLACE FUNCTION centrifugo_notify_partition_change()
RETURNS TRIGGER AS $$
BEGIN
    PERFORM pg_notify('centrifugo_partition_change', NEW.partition::text);
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER centrifugo_notify_partition_trigger
AFTER INSERT ON centrifugo_outbox
FOR EACH ROW
EXECUTE FUNCTION centrifugo_notify_partition_change();