# tor-docker

[![Build Status](https://drone.aricodes.net/api/badges/aricodes-oss/tor-docker/status.svg)](https://drone.aricodes.net/aricodes-oss/tor-docker)

Regular builds of the most up-to-date stable version of Tor from source, with a slim alpine-based image and no out-of-the-box assumptions on what you want running in your container.

# Usage

If you just want the default tor service configuration running, just start the container and you're done!

If you want to customize the config, read on...

## Customizing `torrc`

You can mount your own `torrc` file at `/etc/torrc`, using whatever configuration options suit your usecase best. Sometimes though, this isn't sufficient, and that's where you can programmatically generate your config:

### Custom `torrc` example

`docker run -v $PWD/torrc:/etc/torrc aricodes/tor:latest`

## Startup scripts

If you're using this image to host your own hidden service inside of `docker-compose` or `docker-swarm`, you'll need to be able to dynamically find the IP of the container running your app in order to update your config file. You could do so with a shell script:

```sh
export TARGET_ADDR=$(nslookup container_name_here | grep Address | head -n2 | tail -n1 | cut -d' ' -f2)
```

And then by dropping that into your torrc config file -

```
echo "HiddenServiceDir /var/lib/tor/my_service/" >> /etc/torrc
echo "HiddenServicePort 80 $TARGET_ADDR:80" >> /etc/torrc
```

but you would need to run that on startup. Simply mount your script as a volume into the `/scripts` folder and then entrypoint will run them before starting the tor service itself!

### Startup scripts example

`docker run -v $PWD/generate-my-config.sh:/scripts/generate-my-config.sh aricodes/tor:latest`
