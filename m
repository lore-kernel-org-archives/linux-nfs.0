Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:39062 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759271AbbJ3KzL (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 30 Oct 2015 06:55:11 -0400
Date: Fri, 30 Oct 2015 11:55:09 +0100
From: Karel Zak <kzak@redhat.com>
To: Neil Brown <neilb@suse.com>
Cc: util-linux@vger.kernel.org, linux-nfs@vger.kernel.org
Subject: Re: mount does not accurately identify existing NFS mounts, and
 shouldn't try.
Message-ID: <20151030105509.GG19508@ws.net.home>
References: <87twpnll5y.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <87twpnll5y.fsf@notabene.neil.brown.name>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Oct 19, 2015 at 12:08:41PM +1100, Neil Brown wrote:
> 	/* Refuse the same filesystem on the same mount point */
> 	err = -EBUSY;
> 	if (path->mnt->mnt_sb == newmnt->mnt.mnt_sb &&
> 	    path->mnt->mnt_root == path->dentry)
> 		goto unlock;
> 
> This is the *only* time that the kernel returns EBUSY for a "mount a new
> filesystem" request (remount can return EBUSY for other reasons I
> think).
> 
> So in the case where "mount" thinks it should check if the filesystem is
> already mounted and ignore the request if it is, the best thing it can
> do is to just try the mount and ignore any "EBUSY" error status - treat
> that the same as success.
> 
> So all that code for "is this the same mountpoint" can probably be
> discarded.

Well, we have many situations (another than mount -a) when you want to
know if the FS is mounted, but you have not permissions for mount(2)
or you don't want to try it (because mount(2) may trigger many another
things in userspace).

> Did I miss any important consideration there?

The problem is that the way between fstab entry and mount(2) is
sometimes pretty complex (mount.<type> helpers, loop devices,
UUID/LABEL translation, etc).

So, compare fstab with /proc/mounts is usually good compromise...

Your suggestion seems usable for mount -a, but it's one small use-case
(and for example systemd don't use "mount -a" during boot).

> Unfortunately this change could be awkward to implement as /sbin/mount
> decides whether to try the mount and (for NFS), /sbin/mount.nfs gives an
> error message if EBUSY is returned.  Would we need to pass a "noebusy"
> flag, but only if mount.nfs were willing to accept it....
> 
> Any suggestions?

We have kill(PID, 0) to detect if the PID is valid, you don't have to
parse all /proc. It would be nice to have the same for filesystems,
something like

    mount("/dev/sda1, "/mnt", "ext4", MS_NOMOUNT, NULL)

   Karel 

-- 
 Karel Zak  <kzak@redhat.com>
 http://karelzak.blogspot.com
