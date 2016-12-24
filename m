Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mout.gmx.net ([212.227.15.15]:62140 "EHLO mout.gmx.net"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750919AbcLXHLq (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Sat, 24 Dec 2016 02:11:46 -0500
MIME-Version: 1.0
Message-ID: <trinity-f47ff353-231a-48ff-b6d4-a8f34c45ea26-1482563498427@3capp-mailcom-bs14>
From: daggs <daggs@gmx.com>
To: NeilBrown <neilb@suse.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: unable to mount nfs4 mount
Content-Type: text/plain; charset=UTF-8
Date: Sat, 24 Dec 2016 08:11:38 +0100
In-Reply-To: <87r34yngxn.fsf@notabene.neil.brown.name>
References: <trinity-4254572c-7361-4bba-8056-b645fac97726-1482498754742@3capp-mailcom-bs14>,
 <87r34yngxn.fsf@notabene.neil.brown.name>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Greetings,
> 
> > Greetings,
> >
> > I'm trying to mount an nfs mount it seems ti fails, I'd appreciate some help on the matter.
> > the client is a gentoo setup with kernel 4.9.0, nfs-utils-1.3.4.
> > running showmount -e 10.0.0.10 (the server) returns this:
> > Export list for 10.0.0.10:
> > /mnt/nfs_exports/media 10.0.0.0/24
> > /mnt/nfs_exports       10.0.0.0/24
> >
> > when I try to mount I get this:
> > mount -v -t nfs 10.0.0.10://mnt/nfs_exports/media /tmp/media -o vers=4,rw,async,auto
> > mount.nfs: timeout set for Fri Dec 23 14:30:56 2016
> > mount.nfs: trying text-based options 'vers=4,addr=10.0.0.10,clientaddr=10.0.0.1'
> > mount.nfs: mount(2): Connection timed out
> > mount.nfs: Connection timed
> >
> > the server is a odroidc2 board, the kernel is based 3.14.79 (I know it is old but there is still no full mainline kernel support for this board), nfs-utils-1.3.3 built with latest buildroot.
> > cat /etc/exportfs returns this:
> > /mnt/nfs_exports        10.0.0.0/24(rw,fsid=0,no_subtree_check)
>                                          ^^^^^^^
> 
> Get rid of this, or get rid of "/mnt/nfs_exports" in your mount command.
> i.e.
>   mount -v -t nfs 10.0.0.10:/media /tmp/media -o vers=4,rw,async,auto
> 

tried the mount line, same behavior.
client:
mount -v -t nfs 10.0.0.10:/media /tmp/media -o vers=4,rw,async,auto
mount.nfs: timeout set for Sat Dec 24 09:07:17 2016
mount.nfs: trying text-based options 'vers=4,addr=10.0.0.10,clientaddr=10.0.0.1'
mount.nfs: mount(2): Connection timed out
mount.nfs: Connection timed out

server:
[    7.585428] svc: socket ffffffc05bfaa000 TCP (listen) state change 10
[    7.585628] svc: transport ffffffc05c05c000 served by daemon ffffffc05bfd0000
[    7.585924] svc: socket ffffffc05c3bce00 TCP (listen) state change 1
[    7.586198] svc: tcp_accept ffffffc05c05c000 sock ffffffc05ca05180
[    7.586441] nfsd: connect from 10.0.0.1, port=737
[    7.586634] svc: svc_setup_socket ffffffc05c8ef400
[    7.586832] setting up TCP socket for reading
[    7.587011] svc: svc_setup_socket created ffffffc05bc70000 (inet ffffffc05c3bce00)
[    7.587324] svc: transport ffffffc05bc70000 put into queue
[    7.587551] svc: transport ffffffc05c05c000 put into queue
[    7.587777] svc: server ffffffc05bfd0000 waiting for data (to = 360000)
[    7.588050] svc: transport ffffffc05bc70000 dequeued, inuse=1
[    7.588287] svc: server ffffffc05bfd0000, pool 0, transport ffffffc05bc70000, inuse=2
[    7.588612] svc: tcp_recv ffffffc05bc70000 data 1 conn 0 close 0
[    7.588859] svc: socket ffffffc05bc70000 recvfrom(ffffffc05bc702bc, 0) = 4
[    7.589143] svc: TCP record, 40 bytes
[    7.589330] svc: socket ffffffc05bc70000 recvfrom(ffffffc05c272028, 4056) = 40
[    7.589592] svc: TCP final record (40 bytes)
[    7.589781] svc: got len=40
[    7.589970] svc: svc_authenticate (0)
[    7.590156] svc: calling dispatcher
[    7.590344] svc: socket ffffffc05bc70000 sendto([ffffffc05c3e8000 28... ], 28) = 28 (addr 10.0.0.1, port=737)
[    7.590715] svc: socket ffffffc05c3bce00 TCP data ready (svsk ffffffc05bc70000)
[    7.591015] svc: transport ffffffc05bc70000 put into queue
[    7.591242] svc: transport ffffffc05bc70000 busy, not enqueued
[    7.591482] svc: server ffffffc05bfd0000 waiting for data (to = 360000)
[    7.591756] svc: transport ffffffc05c05c000 dequeued, inuse=1
[    7.591993] svc: tcp_accept ffffffc05c05c000 sock ffffffc05ca05180
[    7.592249] svc: server ffffffc05bfd0000 waiting for data (to = 360000)
[    7.592521] svc: transport ffffffc05bc70000 dequeued, inuse=1
[    7.592758] svc: server ffffffc05bfd0000, pool 0, transport ffffffc05bc70000, inuse=2
[    7.593081] svc: tcp_recv ffffffc05bc70000 data 1 conn 0 close 0
[    7.593329] svc: socket ffffffc05bc70000 recvfrom(ffffffc05bc702bc, 0) = 4
[    7.593613] svc: TCP record, 172 bytes
[    7.593801] svc: socket ffffffc05bc70000 recvfrom(ffffffc05c2720ac, 3924) = 172
[    7.594070] svc: TCP final record (172 bytes)
[    7.594260] svc: got len=172
[    7.594448] svc: svc_authenticate (1)
[    7.594636] RPC:       Want update, refage=120, age=0
[    8.588359] svc: svc_process dropit
[    8.588550] svc: xprt ffffffc05bc70000 dropped request
[    8.588739] svc: server ffffffc05bfd0000 waiting for data (to = 360000)
[   10.518359] svc: svc_process dropit
[   10.518550] svc: xprt ffffffc05c396000 dropped request
[   10.518738] svc: transport ffffffc05c396000 busy, not enqueued
[   10.518956] svc: server ffffffc05b812000 waiting for data (to = 360000)
[   15.684420] svc: socket ffffffc05c3bce00 TCP (connected) state change 8 (svsk ffffffc05bc70000)
[   15.684740] svc: transport ffffffc05bc70000 served by daemon ffffffc05b812000
[   15.685035] svc: socket ffffffc05c3bce00 TCP data ready (svsk ffffffc05bc70000)
[   15.685337] svc: transport ffffffc05bc70000 busy, not enqueued
[   15.685592] svc_recv: found XPT_CLOSE
[   15.685785] svc: svc_delete_xprt(ffffffc05bc70000)
[   15.685979] svc: svc_tcp_sock_detach(ffffffc05bc70000)
[   15.686174] svc: svc_sock_detach(ffffffc05bc70000)
[   15.686370] svc: server ffffffc05b812000 waiting for data (to = 360000)

my /etc/exports if copied from the gentoo setup which has a working nfsv4 server.

Dagg.
