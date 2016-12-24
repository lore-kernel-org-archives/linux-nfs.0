Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp1.dds.nl ([83.96.147.43]:51692 "EHLO smtp1.dds.nl"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750971AbcLXJ4A (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Sat, 24 Dec 2016 04:56:00 -0500
Received: from webmail.dds.nl (app1.dds.nl [81.21.136.61])
        by smtp1.dds.nl (Postfix) with ESMTP id 11C69888EC
        for <linux-nfs@vger.kernel.org>; Sat, 24 Dec 2016 10:48:29 +0100 (CET)
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII;
 format=flowed
Date: Sat, 24 Dec 2016 10:48:29 +0100
From: Xen <list@xenhideout.nl>
To: linux-nfs@vger.kernel.org
Subject: Stale NFS file handle
Message-ID: <ca233abe4345a85b73ba8f4c742f3af9@xenhideout.nl>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi,

On a Debian server I have mounted several snapshots daily that I export 
with NFS.

At the end of the day the nfs-kernel-server service is shut down, the 
snapshots are renewed, remounted, and the server is brought online 
again.

In the beginning (I haven't been doing this for long) it all worked fine 
and I could mount the shares on the client, which is an older NAS unit, 
running an old kernel as 2.6.32.

Yet one of the shares now refuses to get mounted and I don't know why. 
The only thing I haven't tried is actually renaming the mount points.

mount: mounting island.vpn:/srv/root on /mnt/remote/root failed: Stale 
NFS file handle

This "island.vpn" simply translates to 10.8.20.25, in this case.

This is one of 5 mounts and one of 5 snapshots. The other snapshots 
simply succeed.

I have rebooted both servers.

I have removed the mount points on both places: the mount points for the 
snapshots, and the mount points for the shares on the client.

I have run exportfs -r and exportfs -f.

Oh, apologies, I see the issue, or at least part of it.

Dec 24 02:45:35 island rpc.mountd[3217]: / and /srv/root have same 
filehandle for diskstation.vpn, using first

I really wanted to find out if it uses nfs3 or nfs4, but I think it uses 
nfs 4.

The above message does not always repeat itself:

Dec 24 02:56:35 island rpc.mountd[3217]: authenticated mount request 
from 10.8.20.1:944 for /srv/root (/srv/root)
Dec 24 02:58:09 island rpc.mountd[3217]: authenticated mount request 
from 10.8.20.1:638 for /srv/boot (/srv/boot)

The site uses LVM snapshots, root (and boot) are regular, non-thin 
snapshots.

These are my exports:

/srv/home       diskstation(ro,no_subtree_check,no_root_squash)
/srv/data       diskstation(ro,no_subtree_check,no_root_squash)
/srv/sites      diskstation(ro,no_subtree_check,no_root_squash)
/srv/boot       diskstation(ro,no_subtree_check,no_root_squash)
/srv/root       diskstation(ro,no_subtree_check,no_root_squash)

All other mounts succeed without issue. Root did fine at first as well.

Edit: adding fsid=22 to the root line fixed it:

/srv/home       diskstation(ro,no_subtree_check,no_root_squash)
/srv/data       diskstation(ro,no_subtree_check,no_root_squash)
/srv/sites      diskstation(ro,no_subtree_check,no_root_squash)
/srv/boot       diskstation(ro,no_subtree_check,no_root_squash)
/srv/root       diskstation(ro,fsid=22,no_subtree_check,no_root_squash)

All snapshots are independently mounted and hence do not contain other 
mounts on them.

Well I'm glad that's sorted. I don't know why the NFS server would pick 
a filesystem to export that wasn't even mentioned. Of course the 
snapshot and the root (original) will have the same UUID.

Not its partition, but its filesystem will.

So I apologize for this message ;-).

Regards.
