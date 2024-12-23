# Heroku MaxMind GeoIP2 Buildpack

This buildpack downloads and installs MaxMind GeoIP2 databases for use in your Heroku application.

## Setup

1. Add the buildpack to your Heroku app:

```bash
heroku buildpacks:add https://github.com/your-repo/heroku-maxmind-geoip-buildpack
```

2. Set your MaxMind license key:

```bash
heroku config:set MAXMIND_LICENSE_KEY=your_license_key_here
```

## Configuration

### Required Environment Variables

- `MAXMIND_LICENSE_KEY`: Your MaxMind license key (required)

### Optional Environment Variables

- `MAXMIND_EDITIONS`: Space or comma-separated list of database editions to install
  - Default: `GeoLite2-Country`
  - Available options: `GeoLite2-Country`, `GeoLite2-City`, `GeoLite2-ASN`
  - Example: `heroku config:set MAXMIND_EDITIONS="GeoLite2-Country GeoLite2-City"`

- `MAXMIND_DB_DIR`: Base directory for database files
  - Default: `$HOME/vendor`
  - Usually shouldn't need to change this

### Provided Environment Variables

The buildpack automatically sets these variables for your application:

- `MAXMIND_GEOLITE2_COUNTRY_PATH`: Full path to the Country database
- `MAXMIND_GEOLITE2_CITY_PATH`: Full path to the City database (if installed)
- `MAXMIND_GEOLITE2_ASN_PATH`: Full path to the ASN database (if installed)

## Usage Examples

### Ruby
```ruby
require 'maxmind-db'

# Basic usage (Country database)
reader = MaxMind::DB.new(ENV['MAXMIND_GEOLITE2_COUNTRY_PATH'])
result = reader.get('8.8.8.8')

# Using multiple databases
if ENV['MAXMIND_GEOLITE2_CITY_PATH']
  city_reader = MaxMind::DB.new(ENV['MAXMIND_GEOLITE2_CITY_PATH'])
  city_result = city_reader.get('8.8.8.8')
end
```

### Python
```python
import geoip2.database
import os

# Basic usage
with geoip2.database.Reader(os.environ['MAXMIND_GEOLITE2_COUNTRY_PATH']) as reader:
    response = reader.country('8.8.8.8')
    country_code = response.country.iso_code
```

### Node.js
```javascript
const Reader = require('@maxmind/db-reader');
const fs = require('fs');

// Basic usage
const buffer = fs.readFileSync(process.env.MAXMIND_GEOLITE2_COUNTRY_PATH);
const reader = new Reader(buffer);
const result = reader.get('8.8.8.8');
```

## Database Information

| Database | Size (approx) | Use Case |
|----------|---------------|----------|
| GeoLite2-Country | 7MB | Basic country detection, geo-blocking |
| GeoLite2-City | 70MB | Detailed location info, localization |
| GeoLite2-ASN | 7MB | Network/ISP detection, VPN identification |

## Cache Behavior

- Databases are cached to speed up deployments
- Cache is invalidated weekly to ensure fresh data
- Force a fresh download by clearing the build cache:
```bash
heroku builds:cache:purge -a your-app-name
```

## Support

For issues and questions, please [open an issue](https://github.com/quikly/heroku-buildpack-maxmind/issues).

