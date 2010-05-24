Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from zeniv.linux.org.uk ([195.92.253.2]:57524 "EHLO
	ZenIV.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758689Ab0EXXoH (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 24 May 2010 19:44:07 -0400
Date: Tue, 25 May 2010 00:44:04 +0100
From: Al Viro <viro@ZenIV.linux.org.uk>
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Cc: Neil Brown <neilb@suse.de>, "Dr. J. Bruce Fields" <bfields@fieldses.org>,
        Chuck Lever <chuck.lever@oracle.com>, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org
Subject: Re: [PATCH] VFS: fix recent breakage of FS_REVAL_DOT
Message-ID: <20100524234404.GU31073@ZenIV.linux.org.uk>
References: <20100524165756.2cfa54c4@notabene.brown>
 <20100524115903.GP31073@ZenIV.linux.org.uk>
 <20100524155031.GQ31073@ZenIV.linux.org.uk>
 <1274718082.10795.31.camel@heimdal.trondhjem.org>
 <20100524164736.GR31073@ZenIV.linux.org.uk>
 <1274720791.10795.50.camel@heimdal.trondhjem.org>
 <20100524190828.GS31073@ZenIV.linux.org.uk>
 <1274735612.4030.16.camel@heimdal.trondhjem.org>
 <20100524230109.GT31073@ZenIV.linux.org.uk>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20100524230109.GT31073@ZenIV.linux.org.uk>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Tue, May 25, 2010 at 12:01:09AM +0100, Al Viro wrote:
> Client question: what stops you from stack overflows in that area?  Call
> chains you've got are *deep*, and I really wonder what happens if you
> hit a referral point while traversing nested symlink, get pathname
> resolution (already several levels into recursion) call ->follow_link(),
> bounce down through nfs_do_refmount/nfs_follow_referral/try_location/
> vfs_kern_mount/nfs4_referral_get_sb/nfs_follow_remote_path into
> vfs_path_lookup, which will cheerfully add a few more loops like that.
> 
> Sure, the *total* nesting depth through symlinks is still limited by 8, but
> that pile of stack frames is _MUCH_ fatter than what we normally have in
> pathname resolution.  You've suddenly added ~60 extra stack frames to the
> worst-case stack footprint of the pathname resolution.  Don't try that
> on sparc64, boys and girls, it won't be happy with attempt to carve ~12Kb
> extra out of its kernel stack...  In fact, it's worse than just ~60 stack
> frames - several will contain (on-stack) struct nameidata in them, which
> very definitely will _not_ fit into the minimal stack frame.  It's about
> 160 bytes extra, for each of those (up to 7).

Actually, just what will happen if you have a referral that would eventually
resolve to a directory you have no permissions to access?  AFAICS, you'll
end up trying it on all alternates, since nfs_follow_referral() will cheerfully
keep trying one variant after another, getting -EACCES from each.  Worse,
if there are nested referrals in it, you'll get all sequences of alternates
tried before you give up.

..o*O(at least it's merely exponential; Ackermann would be even more fun)
