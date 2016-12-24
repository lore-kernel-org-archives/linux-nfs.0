Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mout.gmx.net ([212.227.15.19]:54119 "EHLO mout.gmx.net"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1755542AbcLXTwa (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Sat, 24 Dec 2016 14:52:30 -0500
MIME-Version: 1.0
Message-ID: <trinity-8111cff0-0509-405f-8faa-190a3c9291c6-1482609137078@3capp-mailcom-bs11>
From: daggs <daggs@gmx.com>
To: NeilBrown <neilb@suse.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: unable to mount nfs4 mount
Content-Type: text/plain; charset=UTF-8
Date: Sat, 24 Dec 2016 20:52:17 +0100
In-Reply-To: <87lgv5nmi6.fsf@notabene.neil.brown.name>
References: <trinity-4254572c-7361-4bba-8056-b645fac97726-1482498754742@3capp-mailcom-bs14>
 <87r34yngxn.fsf@notabene.neil.brown.name>
 <trinity-f47ff353-231a-48ff-b6d4-a8f34c45ea26-1482563498427@3capp-mailcom-bs14>,
 <87lgv5nmi6.fsf@notabene.neil.brown.name>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Greeting Neil,

> > Greetings,
> >> 
> >> > Greetings,
> >> >
> >> > I'm trying to mount an nfs mount it seems ti fails, I'd appreciate some help on the matter.
> >> > the client is a gentoo setup with kernel 4.9.0, nfs-utils-1.3.4.
> >> > running showmount -e 10.0.0.10 (the server) returns this:
> >> > Export list for 10.0.0.10:
> >> > /mnt/nfs_exports/media 10.0.0.0/24
> >> > /mnt/nfs_exports       10.0.0.0/24
> >> >
> >> > when I try to mount I get this:
> >> > mount -v -t nfs 10.0.0.10://mnt/nfs_exports/media /tmp/media -o vers=4,rw,async,auto
> >> > mount.nfs: timeout set for Fri Dec 23 14:30:56 2016
> >> > mount.nfs: trying text-based options 'vers=4,addr=10.0.0.10,clientaddr=10.0.0.1'
> >> > mount.nfs: mount(2): Connection timed out
> >> > mount.nfs: Connection timed
> >> >
> >> > the server is a odroidc2 board, the kernel is based 3.14.79 (I know it is old but there is still no full mainline kernel support for this board), nfs-utils-1.3.3 built with latest buildroot.
> >> > cat /etc/exportfs returns this:
> >> > /mnt/nfs_exports        10.0.0.0/24(rw,fsid=0,no_subtree_check)
> >>                                          ^^^^^^^
> >> 
> >> Get rid of this, or get rid of "/mnt/nfs_exports" in your mount command.
> >> i.e.
> >>   mount -v -t nfs 10.0.0.10:/media /tmp/media -o vers=4,rw,async,auto
> >> 
> >
> > tried the mount line, same behavior.
> > client:
> > mount -v -t nfs 10.0.0.10:/media /tmp/media -o vers=4,rw,async,auto
> > mount.nfs: timeout set for Sat Dec 24 09:07:17 2016
> > mount.nfs: trying text-based options 'vers=4,addr=10.0.0.10,clientaddr=10.0.0.1'
> > mount.nfs: mount(2): Connection timed out
> > mount.nfs: Connection timed out
> 
> Sorry - I should have known that.  I just responded to the first obvious
> error I saw, without confirming that it would have the results
> reported.  The error I saw wouldn't cause "Connection timed out".
> 
> This message
> > [    8.588359] svc: svc_process dropit
> 
> might suggest that rpc.mountd isn't running. Is it?
> If it is, is it producing any error messages in the logs?
> 

from the original post:
ps aux | egrep "nfs|rpc" on the server returns this:
37 root [rpciod]
41 root [nfsiod]
132 root /usr/bin/rpcbind
194 root [nfsd4]
195 root [nfsd4_callbacks]
199 root [nfsd]
200 root [nfsd]
233 root rpc.statd
237 root /usr/sbin/rpc.idmapd
241 root rpc.mountd -V 3 -V 4

all the prints from the logs that I've found (/var/log/messages) exist in the previous mail I've sent.
is there another log I'm missing? if so, where can I find it?

Thanks.

Dagg.
