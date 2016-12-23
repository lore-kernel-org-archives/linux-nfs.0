Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mout.gmx.net ([212.227.17.21]:64817 "EHLO mout.gmx.net"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1755607AbcLWNMh (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 23 Dec 2016 08:12:37 -0500
MIME-Version: 1.0
Message-ID: <trinity-4254572c-7361-4bba-8056-b645fac97726-1482498754742@3capp-mailcom-bs14>
From: daggs <daggs@gmx.com>
To: linux-nfs@vger.kernel.org
Subject: unable to mount nfs4 mount
Content-Type: text/plain; charset=UTF-8
Date: Fri, 23 Dec 2016 14:12:34 +0100
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Greetings,

I'm trying to mount an nfs mount it seems ti fails, I'd appreciate some help on the matter.
the client is a gentoo setup with kernel 4.9.0, nfs-utils-1.3.4.
running showmount -e 10.0.0.10 (the server) returns this:
Export list for 10.0.0.10:
/mnt/nfs_exports/media 10.0.0.0/24
/mnt/nfs_exports       10.0.0.0/24

when I try to mount I get this:
mount -v -t nfs 10.0.0.10://mnt/nfs_exports/media /tmp/media -o vers=4,rw,async,auto
mount.nfs: timeout set for Fri Dec 23 14:30:56 2016
mount.nfs: trying text-based options 'vers=4,addr=10.0.0.10,clientaddr=10.0.0.1'
mount.nfs: mount(2): Connection timed out
mount.nfs: Connection timed

the server is a odroidc2 board, the kernel is based 3.14.79 (I know it is old but there is still no full mainline kernel support for this board), nfs-utils-1.3.3 built with latest buildroot.
cat /etc/exportfs returns this:
/mnt/nfs_exports        10.0.0.0/24(rw,fsid=0,no_subtree_check)
/mnt/nfs_exports/media  10.0.0.0/24(rw,nohide,insecure,no_subtree_check)

ps aux | egrep "nfs|rpc" on the server returns this:
   37 root     [rpciod]
   41 root     [nfsiod]
  132 root     /usr/bin/rpcbind
  194 root     [nfsd4]
  195 root     [nfsd4_callbacks]
  199 root     [nfsd]
  200 root     [nfsd]
  233 root     rpc.statd
  237 root     /usr/sbin/rpc.idmapd
  241 root     rpc.mountd -V 3 -V 4

connection logs shows this:
[    4.278267] NFSD: Using /var/lib/nfs/v4recovery as the NFSv4 state recovery directory
[    4.278556] NFSD: starting 90-second grace period (net ffffffc001d42600)
[   20.777604] svc: socket ffffffc05bca4700 TCP (listen) state change 10
[   20.777805] svc: transport ffffffc05bc5d000 served by daemon ffffffc05bfec000
[   20.778100] svc: socket ffffffc05bf8ce00 TCP (listen) state change 1
[   20.778378] svc: tcp_accept ffffffc05bc5d000 sock ffffffc05ca10000
[   20.778618] nfsd: connect from 10.0.0.1, port=914
[   20.778811] svc: svc_setup_socket ffffffc05ca0ef00
[   20.779009] setting up TCP socket for reading
[   20.779190] svc: svc_setup_socket created ffffffc05c393000 (inet ffffffc05bf8ce00)
[   20.779501] svc: transport ffffffc05c393000 served by daemon ffffffc05bf8e000
[   20.779797] svc: server ffffffc05bf8e000, pool 0, transport ffffffc05c393000, inuse=3
[   20.780119] svc: tcp_recv ffffffc05c393000 data 1 conn 0 close 0
[   20.780368] svc: socket ffffffc05c393000 recvfrom(ffffffc05c3932bc, 0) = 4
[   20.780651] svc: TCP record, 40 bytes
[   20.780841] svc: socket ffffffc05c393000 recvfrom(ffffffc05be54028, 4056) = 40
[   20.781101] svc: TCP final record (40 bytes)
[   20.781292] svc: got len=40
[   20.781481] svc: svc_authenticate (0)
[   20.781670] svc: calling dispatcher
[   20.781860] svc: socket ffffffc05c393000 sendto([ffffffc05c270000 28... ], 28) = 28 (addr 10.0.0.1, port=914)
[   20.782232] svc: socket ffffffc05bf8ce00 TCP data ready (svsk ffffffc05c393000)
[   20.782532] svc: transport ffffffc05c393000 put into queue
[   20.782759] svc: transport ffffffc05c393000 busy, not enqueued
[   20.782999] svc: server ffffffc05bf8e000 waiting for data (to = 360000)
[   20.783273] svc: transport ffffffc05c393000 dequeued, inuse=2
[   20.783510] svc: server ffffffc05bf8e000, pool 0, transport ffffffc05c393000, inuse=3
[   20.783833] svc: tcp_recv ffffffc05c393000 data 1 conn 0 close 0
[   20.784081] svc: socket ffffffc05c393000 recvfrom(ffffffc05c3932bc, 0) = 4
[   20.784365] svc: TCP record, 172 bytes
[   20.784557] svc: socket ffffffc05c393000 recvfrom(ffffffc05be540ac, 3924) = 172
[   20.784821] svc: TCP final record (172 bytes)
[   20.785012] svc: got len=172
[   20.785200] svc: svc_authenticate (1)
[   20.785392] svc: transport ffffffc05bc5d000 put into queue
[   20.785579] svc: server ffffffc05bfec000 waiting for data (to = 360000)
[   20.785845] svc: transport ffffffc05bc5d000 dequeued, inuse=1
[   20.786082] svc: tcp_accept ffffffc05bc5d000 sock ffffffc05ca10000
[   20.786338] svc: server ffffffc05bfec000 waiting for data (to = 360000)
[   21.778372] svc: svc_process dropit
[   21.778565] svc: xprt ffffffc05c393000 dropped request
[   21.778757] svc: server ffffffc05bf8e000 waiting for data (to = 360000)
[   28.464973] svc: socket ffffffc05bf8ce00 TCP (connected) state change 8 (svsk ffffffc05c393000)
[   28.465297] svc: transport ffffffc05c393000 served by daemon ffffffc05bf8e000
[   28.465591] svc: socket ffffffc05bf8ce00 TCP data ready (svsk ffffffc05c393000)
[   28.465893] svc: transport ffffffc05c393000 busy, not enqueued
[   28.466147] svc_recv: found XPT_CLOSE
[   28.466340] svc: svc_delete_xprt(ffffffc05c393000)
[   28.466535] svc: svc_tcp_sock_detach(ffffffc05c393000)
[   28.466728] svc: svc_sock_detach(ffffffc05c393000)
[   28.466922] svc: server ffffffc05bf8e000 waiting for data (to = 360000)

cat /etc/idmapd.conf on the server returns:
[General]

Verbosity = 0
Pipefs-Directory = /var/lib/nfs/rpc_pipefs
Domain = localdomain

[Mapping]

Nobody-User = nobody
Nobody-Group = nogroup

any ideas what can be the issue?
is this a kernel bug that was fixed in later stages?

Thanks,

Dagg.
