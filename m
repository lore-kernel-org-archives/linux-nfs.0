Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mout.gmx.net ([212.227.17.20]:63023 "EHLO mout.gmx.net"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751674AbcLYUKB (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Sun, 25 Dec 2016 15:10:01 -0500
MIME-Version: 1.0
Message-ID: <trinity-c0b9c914-6d36-40d8-a13a-38cde8b7d23f-1482696592233@3capp-mailcom-bs03>
From: daggs <daggs@gmx.com>
To: NeilBrown <neilb@suse.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: unable to mount nfs4 mount
Content-Type: text/plain; charset=UTF-8
Date: Sun, 25 Dec 2016 21:09:52 +0100
In-Reply-To: <87inq8olcj.fsf@notabene.neil.brown.name>
References: <trinity-4254572c-7361-4bba-8056-b645fac97726-1482498754742@3capp-mailcom-bs14>
 <87r34yngxn.fsf@notabene.neil.brown.name>
 <trinity-f47ff353-231a-48ff-b6d4-a8f34c45ea26-1482563498427@3capp-mailcom-bs14>
 <87lgv5nmi6.fsf@notabene.neil.brown.name>
 <trinity-8111cff0-0509-405f-8faa-190a3c9291c6-1482609137078@3capp-mailcom-bs11>,
 <87inq8olcj.fsf@notabene.neil.brown.name>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Greetings Neil,

> > Greeting Neil,
> >
> >> > Greetings,
> >> >> 
> >> >> > Greetings,
> >> >> >
> >> >> > I'm trying to mount an nfs mount it seems ti fails, I'd appreciate some help on the matter.
> >> >> > the client is a gentoo setup with kernel 4.9.0, nfs-utils-1.3.4.
> >> >> > running showmount -e 10.0.0.10 (the server) returns this:
> >> >> > Export list for 10.0.0.10:
> >> >> > /mnt/nfs_exports/media 10.0.0.0/24
> >> >> > /mnt/nfs_exports       10.0.0.0/24
> >> >> >
> >> >> > when I try to mount I get this:
> >> >> > mount -v -t nfs 10.0.0.10://mnt/nfs_exports/media /tmp/media -o vers=4,rw,async,auto
> >> >> > mount.nfs: timeout set for Fri Dec 23 14:30:56 2016
> >> >> > mount.nfs: trying text-based options 'vers=4,addr=10.0.0.10,clientaddr=10.0.0.1'
> >> >> > mount.nfs: mount(2): Connection timed out
> >> >> > mount.nfs: Connection timed
> >> >> >
> >> >> > the server is a odroidc2 board, the kernel is based 3.14.79 (I know it is old but there is still no full mainline kernel support for this board), nfs-utils-1.3.3 built with latest buildroot.
> >> >> > cat /etc/exportfs returns this:
> >> >> > /mnt/nfs_exports        10.0.0.0/24(rw,fsid=0,no_subtree_check)
> >> >>                                          ^^^^^^^
> >> >> 
> >> >> Get rid of this, or get rid of "/mnt/nfs_exports" in your mount command.
> >> >> i.e.
> >> >>   mount -v -t nfs 10.0.0.10:/media /tmp/media -o vers=4,rw,async,auto
> >> >> 
> >> >
> >> > tried the mount line, same behavior.
> >> > client:
> >> > mount -v -t nfs 10.0.0.10:/media /tmp/media -o vers=4,rw,async,auto
> >> > mount.nfs: timeout set for Sat Dec 24 09:07:17 2016
> >> > mount.nfs: trying text-based options 'vers=4,addr=10.0.0.10,clientaddr=10.0.0.1'
> >> > mount.nfs: mount(2): Connection timed out
> >> > mount.nfs: Connection timed out
> >> 
> >> Sorry - I should have known that.  I just responded to the first obvious
> >> error I saw, without confirming that it would have the results
> >> reported.  The error I saw wouldn't cause "Connection timed out".
> >> 
> >> This message
> >> > [    8.588359] svc: svc_process dropit
> >> 
> >> might suggest that rpc.mountd isn't running. Is it?
> >> If it is, is it producing any error messages in the logs?
> >> 
> >
> > from the original post:
> > ps aux | egrep "nfs|rpc" on the server returns this:
> > 37 root [rpciod]
> > 41 root [nfsiod]
> > 132 root /usr/bin/rpcbind
> > 194 root [nfsd4]
> > 195 root [nfsd4_callbacks]
> > 199 root [nfsd]
> > 200 root [nfsd]
> > 233 root rpc.statd
> > 237 root /usr/sbin/rpc.idmapd
> > 241 root rpc.mountd -V 3 -V 4
> 
> Sorry, I missed that.
> Still, it looks like mountd might be misbehaving.  That is a good place
> to start anyway.
> Can you strace mountd while you attempt a mount?
> e.g.
>   strace -o /tmp/trace -s 1000 -p 241
> 
> and send the /tmp/trace.
> Also, after the attempt fails, run
>  rpcdebug -m rpc -s cache
>  grep . /proc/net/rpc/*/c*
>  cat /proc/fs/nfsd/exports
> 
> and report the output.
> 
here:

# cat /tmp/trace
pselect6(1024, [3 4 5 7 8 9 10 11 12], NULL, NULL, NULL, NULL) = 1 (in [3])
read(3, "nfsd 10.0.0.1\n", 32768)       = 14
openat(AT_FDCWD, "/run/nfs/etab", O_RDONLY) = 14
fstat(14, {st_mode=S_IFREG|0644, st_size=435, ...}) = 0
close(14)                               = 0
write(3, "nfsd 10.0.0.1 2079 10.0.0.0/24 \n", 32) = 32
pselect6(1024, [3 4 5 7 8 9 10 11 12], NULL, NULL, NULL, NULL <detached ...>
# rpcdebug -m rpc -s cache
rpc        cache
# grep . /proc/net/rpc/*/c*
/proc/net/rpc/auth.unix.gid/content:#uid cnt: gids...
/proc/net/rpc/auth.unix.ip/channel:nfsd 10.0.0.1
/proc/net/rpc/auth.unix.ip/channel:nfsd 10.0.0.1
/proc/net/rpc/auth.unix.ip/content:#class IP domain
/proc/net/rpc/auth.unix.ip/content:# expiry=2079 refcnt=1 flags=1
/proc/net/rpc/auth.unix.ip/content:# nfsd 10.0.0.1 10.0.0.0/24
/proc/net/rpc/nfs4.idtoname/content:#domain type id [name]
/proc/net/rpc/nfs4.nametoid/content:#domain type name [id]
/proc/net/rpc/nfsd.export/content:#path domain(flags)
/proc/net/rpc/nfsd.fh/content:#domain fsidtype fsid [path]
# cat /proc/fs/nfsd/exports
# Version 1.1
# Path Client(Flags) # IPs

Dagg.
