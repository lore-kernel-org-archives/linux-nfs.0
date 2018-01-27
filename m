Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ot0-f173.google.com ([74.125.82.173]:32910 "EHLO
        mail-ot0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752358AbeA0Mum (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sat, 27 Jan 2018 07:50:42 -0500
Received: by mail-ot0-f173.google.com with SMTP id d7so2716801oti.0
        for <linux-nfs@vger.kernel.org>; Sat, 27 Jan 2018 04:50:41 -0800 (PST)
MIME-Version: 1.0
From: Naruto Nguyen <narutonguyen2018@gmail.com>
Date: Sat, 27 Jan 2018 19:50:41 +0700
Message-ID: <CANpxKHE=eKuFc2HBgT0aqDb+Q5EOFWOfCzf=tmmuH7zNyn878g@mail.gmail.com>
Subject: Question about random UDP port on rpcbind 0.2.3
To: linux-nfs@vger.kernel.org
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

I would like to ask you a question regarding the new random UDP port
in rpcbind 0.2.3.

In rpcbind 0.2.3, when I start rpcbind (version 0.2.3) through
rpcbind.service, then I do netstat

udp        0      0 0.0.0.0:111             0.0.0.0:*
         10408/rpcbind
udp        0      0 0.0.0.0:831             0.0.0.0:*
         10408/rpcbind
udp6       0      0 :::111                  :::*
         10408/rpcbind
udp6       0      0 :::831                  :::*
         10408/rpcbind

The rpcbind does not only listen on port 111 but also on a random udp
port "831" in this case, this port is changed every time the rpcbind
service retstarts. And it listens on 0.0.0.0 so it opens a hole on
security. Could you please let me know what this port is for and is
there any way to avoid that like force it listen on a internal
interface rather than on any interfaces like that? I do not see the
random port on rpcbind 0.2.1, not sure why? As the rpcbind is started
from systemd so "-h" option is invalid as the man page says:


   -h      Specify specific IP addresses to bind to for UDP requests.
This option may be specified multiple times and can be used to
restrict the interfaces rpcbind will respond to.  Note that when
rpcbind is controlled via sys-
             temd's socket activation, the -h option is ignored. In
this case, you need to edit the ListenStream and ListenDgram
definitions in /usr/lib/systemd/system/rpcbind.socket instead.

Thanks a lot,
Brs,
Naruto
