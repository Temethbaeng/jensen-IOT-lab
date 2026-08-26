CREATE TABLE IF NOT EXISTS devices (
  id SERIAL PRIMARY KEY,
  device_id TEXT UNIQUE NOT NULL,
  location TEXT NOT NULL,
  device_type TEXT NOT NULL
);

CREATE TABLE IF NOT EXISTS measurements (
  id SERIAL PRIMARY KEY,
  device_id TEXT NOT NULL REFERENCES devices(device_id),
  temperature NUMERIC(5,2) NOT NULL,
  humidity NUMERIC(5,2),
  battery INTEGER,
  created_at TIMESTAMP NOT NULL DEFAULT NOW()
);

INSERT INTO devices (device_id, location, device_type)
VALUES
  ('sensor-001', 'Factory A', 'environment'),
  ('sensor-002', 'Factory B', 'environment'),
  ('sensor-003', 'Factory C', 'environment')
ON CONFLICT (device_id) DO NOTHING;

-- Fråga 1: totalt antal mätningar i databasen
SELECT COUNT(*) AS total_measurements FROM measurements;

-- Fråga 2: Medeltemperatur över samtliga mätningar, avrundat till två decimaler
SELECT ROUND(AVG(temperature), 2) AS average_temperature FROM measurements;

-- Fråga 3: Alla mätningar från de senaste 24 timmarna, nyaste först
SELECT * FROM measurements
WHERE created_at >= NOW() - INTERVAL '24 hours'
ORDER BY created_at DESC;
