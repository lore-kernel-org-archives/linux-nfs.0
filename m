Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:51876 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S935045AbdACTlj (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 3 Jan 2017 14:41:39 -0500
Date: Tue, 3 Jan 2017 14:41:37 -0500
To: Xen <list@xenhideout.nl>
Cc: linux-nfs@vger.kernel.org
Subject: Re: Stale NFS file handle
Message-ID: <20170103194137.GA5712@fieldses.org>
References: <ca233abe4345a85b73ba8f4c742f3af9@xenhideout.nl>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <ca233abe4345a85b73ba8f4c742f3af9@xenhideout.nl>
From: bfields@fieldses.org (J. Bruce Fields)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sat, Dec 24, 2016 at 10:48:29AM +0100, Xen wrote:
> Hi,
> 
> On a Debian server I have mounted several snapshots daily that I
> export with NFS.
> 
> At the end of the day the nfs-kernel-server service is shut down,
> the snapshots are renewed, remounted, and the server is brought
> online again.
> 
> In the beginning (I haven't been doing this for long) it all worked
> fine and I could mount the shares on the client, which is an older
> NAS unit, running an old kernel as 2.6.32.
> 
> Yet one of the shares now refuses to get mounted and I don't know
> why. The only thing I haven't tried is actually renaming the mount
> points.
> 
> mount: mounting island.vpn:/srv/root on /mnt/remote/root failed:
> Stale NFS file handle
> 
> This "island.vpn" simply translates to 10.8.20.25, in this case.
> 
> This is one of 5 mounts and one of 5 snapshots. The other snapshots
> simply succeed.
> 
> I have rebooted both servers.
> 
> I have removed the mount points on both places: the mount points for
> the snapshots, and the mount points for the shares on the client.
> 
> I have run exportfs -r and exportfs -f.
> 
> Oh, apologies, I see the issue, or at least part of it.
> 
> Dec 24 02:45:35 island rpc.mountd[3217]: / and /srv/root have same
> filehandle for diskstation.vpn, using first

Huh.  That message is from utils/mountd/cache.c:nfsd_fh().

> I really wanted to find out if it uses nfs3 or nfs4, but I think it
> uses nfs 4.
> 
> The above message does not always repeat itself:
> 
> Dec 24 02:56:35 island rpc.mountd[3217]: authenticated mount request
> from 10.8.20.1:944 for /srv/root (/srv/root)
> Dec 24 02:58:09 island rpc.mountd[3217]: authenticated mount request
> from 10.8.20.1:638 for /srv/boot (/srv/boot)
> 
> The site uses LVM snapshots, root (and boot) are regular, non-thin
> snapshots.
> 
> These are my exports:
> 
> /srv/home       diskstation(ro,no_subtree_check,no_root_squash)
> /srv/data       diskstation(ro,no_subtree_check,no_root_squash)
> /srv/sites      diskstation(ro,no_subtree_check,no_root_squash)
> /srv/boot       diskstation(ro,no_subtree_check,no_root_squash)
> /srv/root       diskstation(ro,no_subtree_check,no_root_squash)
> 
> All other mounts succeed without issue. Root did fine at first as well.
> 
> Edit: adding fsid=22 to the root line fixed it:
> 
> /srv/home       diskstation(ro,no_subtree_check,no_root_squash)
> /srv/data       diskstation(ro,no_subtree_check,no_root_squash)
> /srv/sites      diskstation(ro,no_subtree_check,no_root_squash)
> /srv/boot       diskstation(ro,no_subtree_check,no_root_squash)
> /srv/root       diskstation(ro,fsid=22,no_subtree_check,no_root_squash)
> 
> All snapshots are independently mounted and hence do not contain
> other mounts on them.
> 
> Well I'm glad that's sorted. I don't know why the NFS server would
> pick a filesystem to export that wasn't even mentioned. Of course
> the snapshot and the root (original) will have the same UUID.

At a guess, this may be the v4 pseudoroot code: it exports (under heavy
restrictions) all the directories required to reach any exported
filesystem.

So maybe mountd, when searching for a filesystem matching the given
filehandle, found that pseudoroot export for "/", then later found the
real export for "/srv/root", and resolved the conflict by sticking with
the first one.

We could tell mountd to resolve such conflicts in favor of non-pseudroot
filesystems.  I'm not sure that would work.

Is there some way we could make sure a new uuid is generated for the
snapshots, so we avoid this kind of conflict even when explicitly
exporting multiple snapshots of the same filesystem?

Requiring admins to add explicit fsid='s all over seems unhelpful.

--b.

> Not its partition, but its filesystem will.
> 
> So I apologize for this message ;-).
> 
> Regards.
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
