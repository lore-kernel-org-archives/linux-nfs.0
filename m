Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:37610 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751941Ab1IVM6x (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 22 Sep 2011 08:58:53 -0400
Received: by bkbzt4 with SMTP id zt4so2465228bkb.19
        for <linux-nfs@vger.kernel.org>; Thu, 22 Sep 2011 05:58:52 -0700 (PDT)
From: Miklos Szeredi <miklos@szeredi.hu>
To: David Howells <dhowells@redhat.com>
Cc: raven@themaw.net, viro@ZenIV.linux.org.uk, jlayton@redhat.com,
        gregkh@suse.de, torvalds@linux-foundation.org,
        linux-nfs@vger.kernel.org, leonardo.lists@gmail.com
Subject: Re: [PATCH] NFS4: Revert commit to make the automount code ignore LOOKUP_FOLLOW
References: <20110922124608.7739.27750.stgit@warthog.procyon.org.uk>
Date: Thu, 22 Sep 2011 14:58:21 +0200
In-Reply-To: <20110922124608.7739.27750.stgit@warthog.procyon.org.uk> (David
	Howells's message of "Thu, 22 Sep 2011 13:46:08 +0100")
Message-ID: <878vpgwx76.fsf@tucsk.pomaz.szeredi.hu>
Content-Type: text/plain; charset=us-ascii
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

David Howells <dhowells@redhat.com> writes:

> Revert the following change:
>
> 	commit 0ec26fd0698285b31248e34bf1abb022c00f23d6
> 	Author: Miklos Szeredi <mszeredi@suse.cz>
> 	Date:   Mon Sep 5 18:06:26 2011 +0200
> 	Subject: vfs: automount should ignore LOOKUP_FOLLOW
>
> which makes stat(), getxattr(), etc. behave as lstat(), lgetxattr(), etc. with
> respect to automounting: it prevents them from triggering terminal automounts.
>
> The problem with this is that this breaks nfs_follow_remote_path() used by NFS4
> to find the root object to mount for the mount() syscall.
>
> This can be tested by the following procedure:
>
>  (1) Export a directory from an NFS4 server that has something mounted upon it
>      and that isn't "/" - say, for example, "/scratch".  It must have a
>      different FSID from "/".
>
>  (2) Mount this on the client.
>
> 	mount sirius:/scratch /mnt
>
>  (3) List the contents of the client's mountpoint:
>
> 	ls /mnt
>
>  (4) Examine /proc/fs/nfsfs/volumes.  You should see one entry (assuming
>      nothing else is NFS mounted) :
>
> 	NV SERVER   PORT DEV     FSID              FSC
> 	v4 200108b001940000021125fffe84efad  801 0:34    1:0               no
>
>      which corresponds to the filesystem mounted on /scratch on the server.
>
>      If, however, you see two entries:
>
> 	NV SERVER   PORT DEV     FSID              FSC
> 	v4 200108b001940000021125fffe84efad  801 0:33    0:0               no
> 	v4 200108b001940000021125fffe84efad  801 0:34    1:0               no
>
>      then it went wrong.
>
> When it goes wrong, what happens is that nfs_follow_remote_path() walks from
> the rootfh to the remote directory (/scratch) using vfs_path_lookup().  It
> passes LOOKUP_FOLLOW to vfs_path_lookup() to tell it to transit terminal
> symlinks and terminal automounts.  Unfortunately, with the aforementioned
> commit, LOOKUP_FOLLOW now expressly does not follow terminal
> automounts.

What is exactly happening here?  By not following automounts how do we
end up with two mounts instead of one?  I would have guessed the other
way round.

> There are some alternatives:
>
>  (1) Fix up userspace to expect stat(), getxattr(), etc. to expect these to
>      cause path-terminal automounting.  libacl and coreutils (ls) have been
>      fixed up upstream already but there are other things such as GUI
>      filemanagers.

This is a distro solution, not a kernel solution.

>  (2) Passing LOOKUP_DIRECTORY from nfs_follow_remote_path() to
>      vfs_path_lookup() might work as presumably the mount root will be a
>      directory.

Sounds like a big hack.

>
>  (3) Add a new flag, say LOOKUP_AUTOMOUNT, to force automounting.  This could
>      be extended to userspace.

This is sane.  Athough I can't tell if this is the right solution for
the NFSv4 problem without actually understanding what is happening
there.

>
>  (4) Add a new flag, say LOOKUP_GETTING_ATTRS, to indicate that we're doing a
>      stat() or a getxattr() and suppress automounting on that basis.

What's the difference between LOOKUP_NO_AUTOMOUNT and
LOOKUP_GETTING_ATTRS?

Thanks,
Miklos
