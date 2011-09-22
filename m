Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:32291 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751374Ab1IVNmN (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 22 Sep 2011 09:42:13 -0400
From: David Howells <dhowells@redhat.com>
In-Reply-To: <878vpgwx76.fsf@tucsk.pomaz.szeredi.hu>
References: <878vpgwx76.fsf@tucsk.pomaz.szeredi.hu> <20110922124608.7739.27750.stgit@warthog.procyon.org.uk>
To: Miklos Szeredi <miklos@szeredi.hu>
Cc: dhowells@redhat.com, raven@themaw.net, viro@ZenIV.linux.org.uk,
        jlayton@redhat.com, gregkh@suse.de, torvalds@linux-foundation.org,
        linux-nfs@vger.kernel.org, leonardo.lists@gmail.com
Subject: Re: [PATCH] NFS4: Revert commit to make the automount code ignore LOOKUP_FOLLOW
Date: Thu, 22 Sep 2011 14:41:30 +0100
Message-ID: <24566.1316698890@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

Miklos Szeredi <miklos@szeredi.hu> wrote:

> > When it goes wrong, what happens is that nfs_follow_remote_path() walks from
> > the rootfh to the remote directory (/scratch) using vfs_path_lookup().  It
> > passes LOOKUP_FOLLOW to vfs_path_lookup() to tell it to transit terminal
> > symlinks and terminal automounts.  Unfortunately, with the aforementioned
> > commit, LOOKUP_FOLLOW now expressly does not follow terminal
> > automounts.
> 
> What is exactly happening here?  By not following automounts how do we
> end up with two mounts instead of one?  I would have guessed the other
> way round.

Linux's NFS4 client performs a VFS path walk to resolve the path in the mount
devname to the root fh of the new mount.  This differs from NFS2/3 where the
client asks the server's mountd to do it.

With the situation I described, where you're attempting to directly mount a
directory that's the root of a mount on the server (but not the root of the
whole filesystem tree), you have a situation where the FSID changes as you
walk through the tree.

So, for example, assume "/" is on fsid 0 and "/scratch" is on fsid 1.

Now, when NFS sees a change of fsid, it interpolates an automount point on the
directory in which it saw the fsid change:

			/ (FSID0)
			|
			|
			|
		     scratch (S_AUTOMOUNT set)
		     (FSID0)

 and, when triggered, d_automount
will then create a new superblock for the new fsid and that will get mounted
on the automount point:

			/ (FSID0)
			|
			|
			|
		     scratch ::::::::::::/(FSID1)
		     (FSID0)		 |
					 |-----|-----|-----|
					 |     |     |     |
					 a     b     c     d

However, during the NFS4 root lookup pathwalk, because the root of fsid 1 is
terminal in the path, with your patch it will not trigger automounting because
none of LOOKUP_PARENT, _DIRECTORY, _OPEN or _CREATE are set.  LOOKUP_FOLLOW
was set and *that* used to be sufficient to force the automount.

So what happens is that scratch from fsid 0 gets mounted rather than / from
fsid 1 and this is an automount point.  It will cause / from fsid 1 to be
mounted eventually when someone goes into it, but then you have to do two
unmounts to get rid of it instead of one.

David
