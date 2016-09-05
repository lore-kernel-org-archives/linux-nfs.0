Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from linuxhacker.ru ([217.76.32.60]:46902 "EHLO fiona.linuxhacker.ru"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754026AbcIEFEb (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 5 Sep 2016 01:04:31 -0400
From: Oleg Drokin <green@linuxhacker.ru>
Content-Type: text/plain; charset=us-ascii
Subject: 4.6, 4.7 slow ifs export with more than one client.
Date: Mon, 5 Sep 2016 00:55:25 -0400
Message-Id: <6C329B27-111A-4B16-84F4-7357940EBC01@linuxhacker.ru>
Cc: Jeff Layton <jlayton@poochiereds.net>
To: linux-nfs@vger.kernel.org
Mime-Version: 1.0 (Apple Message framework v1283)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hello!

   I have a somewhat mysterious problem with my nfs test rig that I suspect is something
   stupid I am missing, but I cannot figure it out and would appreciate any help.

   NFS server is Fedora23 with 4.6.7-200.fc23.x86_64 as the kernel.
   Clients are a bunch of 4.8-rc5 nodes, nfsroot.
   If I only start one of them, all is fine, if I start all 9 or 10, then suddenly all
   operations ground to a half (nfs-wise). NFS server side there's very little load.

   I hit this (or something similar) back in June, when testing 4.6-rcs (and the server
   was running 4.4.something I believe), and back then after some mucking around
   I set:
net.core.rmem_default=268435456
net.core.wmem_default=268435456
net.core.rmem_max=268435456
net.core.wmem_max=268435456

   and while no idea why, that helped, so I stopped looking into it completely.

   Now fast forward to now, I am back at the same problem and the workaround above
   does not help anymore.

   I also have a bunch of "NFSD: client 192.168.10.191 testing state ID with incorrect client ID"
   in my logs (also had in June. Tried to disable nfs 4.2 and 4.1 and that did not
   help).

   So anyway I discovered the nfsdcltrack and such and I noticed that whenever
   the kernel calls it, it's always with the same hexid of
   4c696e7578204e465376342e32206c6f63616c686f7374

   NAturally if I try to list the content of the sqlite file, I get:
sqlite> select * from clients;
Linux NFSv4.2 localhost|1473049735|1
sqlite> select * from clients;
Linux NFSv4.2 localhost|1473049736|1
sqlite> select * from clients;
Linux NFSv4.2 localhost|1473049737|1
sqlite> select * from clients;
Linux NFSv4.2 localhost|1473049751|1
sqlite> select * from clients;
Linux NFSv4.2 localhost|1473049752|1
sqlite> 

   (the number keeps changing), so it looks like client id detection broke somehow?

   These same clients (and a bunch more) also mount another nfs server (for crashdump
   purposes) that is centos7-based, there everything is detected correctly
   and performance is ok. The select shows:
sqlite> select * from clients;
Linux NFSv4.0 192.168.10.219/192.168.10.1 tcp|1472868376|0
Linux NFSv4.0 192.168.10.218/192.168.10.1 tcp|1472868376|0
Linux NFSv4.0 192.168.10.210/192.168.10.1 tcp|1472868384|0
Linux NFSv4.0 192.168.10.221/192.168.10.1 tcp|1472868387|0
Linux NFSv4.0 192.168.10.220/192.168.10.1 tcp|1472868388|0
Linux NFSv4.0 192.168.10.211/192.168.10.1 tcp|1472868389|0
Linux NFSv4.0 192.168.10.222/192.168.10.1 tcp|1473035496|0
Linux NFSv4.0 192.168.10.217/192.168.10.1 tcp|1473035500|0
Linux NFSv4.0 192.168.10.216/192.168.10.1 tcp|1473035501|0
Linux NFSv4.0 192.168.10.224/192.168.10.1 tcp|1473035520|0
Linux NFSv4.0 192.168.10.226/192.168.10.1 tcp|1473045789|0
Linux NFSv4.0 192.168.10.227/192.168.10.1 tcp|1473045789|0
Linux NFSv4.1 fedora1.localnet|1473046045|1
Linux NFSv4.1 fedora-1-3.localnet|1473046139|1
Linux NFSv4.1 fedora-2-4.localnet|1473046229|1
Linux NFSv4.1 fedora-1-1.localnet|1473046244|1
Linux NFSv4.1 fedora-1-4.localnet|1473046251|1
Linux NFSv4.1 fedora-2-1.localnet|1473046342|1
Linux NFSv4.1 fedora-1-2.localnet|1473046498|1
Linux NFSv4.1 fedora-2-3.localnet|1473046524|1
Linux NFSv4.1 fedora-2-2.localnet|1473046689|1
sqlite> 

  (the first nameless bunch is centos7 nfsroot clients, fedora* bunch are
  the ones on 4.8-rc5).
  If I try to mount the Fedora23 server from one of the centos7 clients, the record
  does not appear in the output either.

   Now, while a theory that "aha, it's nfs 4.2 that is broken with Fedora23"
   might look possible, I have another Fedora23 server that is mounted by
   yet another (single) client and there things seems to be fine:
sqlite> select * from clients;
Linux NFSv4.2 xbmc.localnet|1471825025|1


   So with all of that in the picture, I wonder what is it I am doing wrong just on
   this server?

   Thanks.

Bye,
    Oleg