Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from zeniv.linux.org.uk ([195.92.253.2]:34231 "EHLO
	ZenIV.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754449Ab0EXXBN (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 24 May 2010 19:01:13 -0400
Date: Tue, 25 May 2010 00:01:09 +0100
From: Al Viro <viro@ZenIV.linux.org.uk>
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Cc: Neil Brown <neilb@suse.de>, "Dr. J. Bruce Fields" <bfields@fieldses.org>,
        Chuck Lever <chuck.lever@oracle.com>, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org
Subject: Re: [PATCH] VFS: fix recent breakage of FS_REVAL_DOT
Message-ID: <20100524230109.GT31073@ZenIV.linux.org.uk>
References: <20100524165756.2cfa54c4@notabene.brown>
 <20100524115903.GP31073@ZenIV.linux.org.uk>
 <20100524155031.GQ31073@ZenIV.linux.org.uk>
 <1274718082.10795.31.camel@heimdal.trondhjem.org>
 <20100524164736.GR31073@ZenIV.linux.org.uk>
 <1274720791.10795.50.camel@heimdal.trondhjem.org>
 <20100524190828.GS31073@ZenIV.linux.org.uk>
 <1274735612.4030.16.camel@heimdal.trondhjem.org>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1274735612.4030.16.camel@heimdal.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Mon, May 24, 2010 at 05:13:32PM -0400, Trond Myklebust wrote:

> Sorry... I misunderstood you.
> 
> In cases like the above, then the default behaviour of the server would
> be to assign the same filehandles to those mount points. The
> administrator can, however, make them different by choosing to use the
> 'fsid' mount option to manually assign different fsids to the different
> export points.
> 
> If not, then the client will automatically group these things in the
> same superblock, so like the server, it too is supposed to share the
> same inode for these different objects. It will then use
> d_obtain_alias() to get a root dentry for that inode (see
> nfs4_get_root()).

Yes, it will.  So what will happen in nfs_follow_referral()?  Note that
we check the rootpath returned by the server (whatever it will end up
being) against the mnt_devname + relative path from mnt_root to referral
point.  In this case it'll be /a/z or /b/z (depending on which export
will server select when it sees the fsid) vs /a/z/x or /b/z/x (depending
on which one does client walk into).  And the calls of nfs4_proc_fs_locations()
will get identical arguments whether client walks into a/z/x or b/z/x.
So will the actual RPC requests seen by the server, so it looks like in
at least one of those cases we will get the rootpath that is _not_ a prefix
we are expecting, stepping into
        if (strncmp(path, fs_path, strlen(fs_path)) != 0) {
                dprintk("%s: path %s does not begin with fsroot %s\n",
                        __func__, path, fs_path);
                return -ENOENT;
        }
in nfs4_validate_fspath().

Question regarding RFC3530: is it actually allowed to have the same fhandle
show up in two different locations in server's namespace?  If so, what
should GETATTR with FS_LOCATIONS return for it?

Client question: what stops you from stack overflows in that area?  Call
chains you've got are *deep*, and I really wonder what happens if you
hit a referral point while traversing nested symlink, get pathname
resolution (already several levels into recursion) call ->follow_link(),
bounce down through nfs_do_refmount/nfs_follow_referral/try_location/
vfs_kern_mount/nfs4_referral_get_sb/nfs_follow_remote_path into
vfs_path_lookup, which will cheerfully add a few more loops like that.

Sure, the *total* nesting depth through symlinks is still limited by 8, but
that pile of stack frames is _MUCH_ fatter than what we normally have in
pathname resolution.  You've suddenly added ~60 extra stack frames to the
worst-case stack footprint of the pathname resolution.  Don't try that
on sparc64, boys and girls, it won't be happy with attempt to carve ~12Kb
extra out of its kernel stack...  In fact, it's worse than just ~60 stack
frames - several will contain (on-stack) struct nameidata in them, which
very definitely will _not_ fit into the minimal stack frame.  It's about
160 bytes extra, for each of those (up to 7).

Come to think of that, x86 variants might get rather upset about that kind
of treatment as well.  Minimal stack frames are smaller, but so's the stack...
