From: Bryan McLellan <btm-lsPLeDye5/bFdV6YJ5OsiQ@public.gmane.org>
Subject: NFSv3 Client Timeout on 2.6.27
Date: Thu, 9 Apr 2009 15:25:26 -0700
Message-ID: <893823750904091525x455fae14i8a4df65fdb632e65@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rv-out-0506.google.com ([209.85.198.234]:47749 "EHLO
	rv-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758634AbZDIWZm (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 9 Apr 2009 18:25:42 -0400
Received: by rv-out-0506.google.com with SMTP id f9so808002rvb.1
        for <linux-nfs@vger.kernel.org>; Thu, 09 Apr 2009 15:25:41 -0700 (PDT)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

I have a number of NFS clients running 2.6.27 (Ubuntu Intrepid,
2.6.27-7-server) where the NFS mount periodically will hang up.

Trying to list the files in the mounted directory results in ls
hanging up. ^C won't interrupt it, and I have to disconnect the ssh
session, reconnect, and sigkill the process.

The server is running 2.6.28 (Ubuntu Jaunty,
linux-image-2.6.28-11-generic). I previously had a ReadyNAS running
2.6.17.8ReadyNAS as the NFS server, that exhibited the same symptoms.
This issue did not occur when the clients were running Debian Etch
(2.6.18) or Ubuntu Hardy (2.6.24).

netstat shows the NFS connection in the FIN_WAIT2 on the client and
CLOSE_WAIT on the server. I'm not sure, but I feel like we shouldn't
be in this state. The clients that are functioning correctly still are
in the ESTABLISHED state on both ends.

With rpc debugging enabled on the client, trying to list in the mount
produces only:

Apr  9 15:20:37 bvt-was02 kernel: [3802245.497803] NFS: revalidating
(0:16/9191425)

There's no network traffic or debugging information output on the
server when I do this.

'lsof -b' doesn't show any processes accessing the mount.

client:/etc/fstab - rw,hard,intr
client:/proc/mounts -
rw,vers=3,rsize=131072,wsize=131072,namlen=255,hard,nointr,proto=tcp,timeo=600,retrans=2,sec=sys,mountaddr=10.0.1.21,mountvers=3,mountproto=tcp,addr=10.0.1.21

dmesg output on the client showing the unstable nature of the mount over time:

[81374.920070] nfs: server prod-nas.prod.example.com not responding,
still trying
[81698.573128] nfs: server prod-nas.prod.example.com OK
[555666.990060] nfs: server prod-nas.prod.example.com not responding,
still trying
[772900.350061] nfs: server prod-nas.prod.example.com not responding,
still trying
[1131572.860104] nfs: server prod-nas.prod.example.com not responding,
still trying
[1502545.374631] nfs: server prod-nas.prod.example.com OK
[2107998.110058] nfs: server prod-nas.prod.example.com not responding,
still trying
[2113336.382702] nfs: server prod-nas.prod.example.com OK
[2469692.030057] nfs: server prod-nas.prod.example.com not responding,
still trying
[2623893.880066] nfs: server prod-nas.prod.example.com not responding,
still trying
[2926917.138339] nfs: server prod-nas.prod.example.com OK
[3181092.780062] nfs: server file01.prod.example.com not responding,
still trying
[3181780.894596] nfs: server file01.prod.example.com OK
[3706362.490101] nfs: server file01.prod.example.com not responding,
still trying

I haven't been able to produce any network problems to indicate there
is instability there to justify the above.
