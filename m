Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from zeniv.linux.org.uk ([195.92.253.2]:40590 "EHLO
        ZenIV.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752177AbeENPpw (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 14 May 2018 11:45:52 -0400
Date: Mon, 14 May 2018 16:45:51 +0100
From: Al Viro <viro@ZenIV.linux.org.uk>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org,
        Linus Torvalds <torvalds@linux-foundation.org>,
        Jeff Layton <jlayton@kernel.org>
Subject: Re: [RFC][PATCH] nfsd: vfs_mkdir() might succeed leaving dentry
 negative unhashed
Message-ID: <20180514154550.GH30522@ZenIV.linux.org.uk>
References: <20180511211339.GG30522@ZenIV.linux.org.uk>
 <20180514153216.GC7160@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20180514153216.GC7160@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, May 14, 2018 at 11:32:16AM -0400, J. Bruce Fields wrote:
> On Fri, May 11, 2018 at 10:13:39PM +0100, Al Viro wrote:
> > [-stable fodder; as it is, one can e.g. add
> > /mnt/cgroup     localhost(rw,no_root_squash,fsid=4242)
> > to /etc/exports,
> > mount -t cgroup none /mnt/cgroup
> > mkdir /tmp/a
> > mount -t nfs localhost://mnt/cgroup /tmp/a
> > mkdir /tmp/a/foo
> 
> How is the cgroup filesystem exportable?  That sounds like a bug in
> itself.  We don't want people using NFS as some kind of weird remote
> configuration protocol.

You can't have open-by-fhandle without exportability.  And it's not
the only fs like that.

> > and have knfsd oops; the patch below deals with that.
> > 
> > Questions:
> > 	1) is fh_update() use below legitimate, or should we
> > do fh_put/fh_compose instead?
> 
> fh_update looks OK to me, but do we need it here?  There's already a
> 
> 	if (!err)
> 		err = fh_update(reshp);
> 
> at the end of nfsd_create_locked.

Might be too late for that, though - the trouble hits when we hit
nfsd_create_setattr().

> > 	2) is nfserr_serverfail valid for situation when
> > directory created by such vfs_mkdir() manages to disappear
> > under us immediately afterwards?  Or should we return nfserr_stale
> > instead?
> 
> We just got a successful result on the create and the parent's still
> locked, so if somebody hits this I think we want them reporting a bug,
> not wasting time trying to find a mistake in their own logic.

No.  Suppose it's NFS-over-NFS (and yes, I agree that it's a bad idea;
somebody *has* done that).  Lookup after successful mkdir can legitimately
fail if it's been removed server-side.

And we *will* need to allow nfs_mkdir() to return that way in some cases
(== success with dentry passed to it left unhashed negative), I'm afraid ;-/
