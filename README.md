# Erlang_1
A tcpServer (wrote in Erlang) controlled by an Android client.

This server works with menu item 10.TCPclient1 in my repo [Android_1](https://github.com/Vladi2017/Android_1). It is implemented based on generic server [gen_server](https://www.erlang.org/doc/design_principles/gen_server_concepts.html) OTP standard behavior. After the client is connected, the server sends periodically keepAlive to the Android client to keep up the socket channel over (p)MNO ((public) mobile network operator) air interface. Basically the client responds with his status. Also keepAliveInterval can be controlled at run time from the Android client based on a minimal message protocol. Both TCPserver and TCPclient produce detailed logs.

Usage:
1. [Install Erlang/OTP](https://www.erlang.org/downloads)
2. clone this repo.
- Then in Erlang shell:

    `2> cd("path_to_TCPserver").`
3. To compile:

    `3> c(echo_server,[verbose,no_load]).`
      
    `4> c(socket_server,[verbose,no_load]).`
4. Check there was generated the two .beam files:

    `5> ls().`
5. Start tcpServer:

    `6> echo_server:start(listen_port).`
6. Launch [TCPclient1](https://github.com/Vladi2017/Android_1) on the Android phone, set server IP address and port, select Connect.

Tip: For long term running (e.g. on a RaspberryPi (RPI)) you can run the Erlang shell in screen window manager (please see [screen home page](https://savannah.gnu.org/projects/screen/) for details). This way the tcpServer can run as a background process keeping available the login shell..
