Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-out2.uio.no ([129.240.10.58]:53638 "EHLO mail-out2.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751484Ab0EYNEu (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 25 May 2010 09:04:50 -0400
Subject: Re: [PATCH] VFS: fix recent breakage of FS_REVAL_DOT
From: Trond Myklebust <trond.myklebust@fys.uio.no>
To: Al Viro <viro@ZenIV.linux.org.uk>
Cc: Neil Brown <neilb@suse.de>, "Dr. J. Bruce Fields" <bfields@fieldses.org>,
        Chuck Lever <chuck.lever@oracle.com>, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org
In-Reply-To: <20100524234404.GU31073@ZenIV.linux.org.uk>
References: <20100524165756.2cfa54c4@notabene.brown>
	 <20100524115903.GP31073@ZenIV.linux.org.uk>
	 <20100524155031.GQ31073@ZenIV.linux.org.uk>
	 <1274718082.10795.31.camel@heimdal.trondhjem.org>
	 <20100524164736.GR31073@ZenIV.linux.org.uk>
	 <1274720791.10795.50.camel@heimdal.trondhjem.org>
	 <20100524190828.GS31073@ZenIV.linux.org.uk>
	 <1274735612.4030.16.camel@heimdal.trondhjem.org>
	 <20100524230109.GT31073@ZenIV.linux.org.uk>
	 <20100524234404.GU31073@ZenIV.linux.org.uk>
Content-Type: text/plain; charset="UTF-8"
Date: Tue, 25 May 2010 09:04:43 -0400
Message-ID: <1274792683.5377.20.camel@heimdal.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Tue, 2010-05-25 at 00:44 +0100, Al Viro wrote: 
> On Tue, May 25, 2010 at 12:01:09AM +0100, Al Viro wrote:
> > Client question: what stops you from stack overflows in that area?  Call
> > chains you've got are *deep*, and I really wonder what happens if you
> > hit a referral point while traversing nested symlink, get pathname
> > resolution (already several levels into recursion) call ->follow_link(),
> > bounce down through nfs_do_refmount/nfs_follow_referral/try_location/
> > vfs_kern_mount/nfs4_referral_get_sb/nfs_follow_remote_path into
> > vfs_path_lookup, which will cheerfully add a few more loops like that.
> > 
> > Sure, the *total* nesting depth through symlinks is still limited by 8, but
> > that pile of stack frames is _MUCH_ fatter than what we normally have in
> > pathname resolution.  You've suddenly added ~60 extra stack frames to the
> > worst-case stack footprint of the pathname resolution.  Don't try that
> > on sparc64, boys and girls, it won't be happy with attempt to carve ~12Kb
> > extra out of its kernel stack...  In fact, it's worse than just ~60 stack
> > frames - several will contain (on-stack) struct nameidata in them, which
> > very definitely will _not_ fit into the minimal stack frame.  It's about
> > 160 bytes extra, for each of those (up to 7).
> 
> Actually, just what will happen if you have a referral that would eventually
> resolve to a directory you have no permissions to access?  AFAICS, you'll
> end up trying it on all alternates, since nfs_follow_referral() will cheerfully
> keep trying one variant after another, getting -EACCES from each.  Worse,
> if there are nested referrals in it, you'll get all sequences of alternates
> tried before you give up.
> 
> ..o*O(at least it's merely exponential; Ackermann would be even more fun)

We could perhaps quit if the referral resolves to EACCES, but there is
the theoretical possibility that the administrator of the particular
replicated server has instead just unexported the filesystem, (which
will also result in EACCES).



