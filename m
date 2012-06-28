Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:53885 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751221Ab2F1N7d (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 28 Jun 2012 09:59:33 -0400
Date: Thu, 28 Jun 2012 09:59:27 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: NeilBrown <neilb@suse.de>
Cc: Al Viro <viro@ZenIV.linux.org.uk>, Nick Piggin <npiggin@gmail.com>,
        Nick Piggin <npiggin@kernel.dk>, linux-nfs@vger.kernel.org,
        linux-fsdevel@vger.kernel.org
Subject: Re: [PATCH] fs/dcache: allow __d_obtain_alias() to return unhashed
 dentries
Message-ID: <20120628135927.GA6406@fieldses.org>
References: <20101218020118.GA3179@amd>
 <20101218161609.GA22150@fieldses.org>
 <AANLkTingRv_gtRSctGzMfYrKg02M_sKj97HSQPRm_mA_@mail.gmail.com>
 <20101227234641.GA22248@fieldses.org>
 <20110118204509.GA10903@fieldses.org>
 <AANLkTikL2CDSWQJ1QH_Y4G-j70Vd=VesNMMnYTmMGHC9@mail.gmail.com>
 <20110118220817.GF10903@fieldses.org>
 <20110308181320.GA15566@fieldses.org>
 <20110310105821.GE22723@ZenIV.linux.org.uk>
 <20110311150749.2fa2be66@notabene.brown>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20110311150749.2fa2be66@notabene.brown>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Coming back to this now, just trying to review the
filehandle-lookup/dcache interactions:

On Fri, Mar 11, 2011 at 03:07:49PM +1100, NeilBrown wrote:
> 1/ Originally DCACHE_DISCONNECTED didn't really mean much - it's presence
>    was only a hint, its absence was a strong statement.
>    If the flag is set, the dentry might not be linked to the root.
>    If it is clear, it definitely is link through to the root.
>    However I think it was used with stronger intent than that.
> 
>    Now it seems to mean a little bit more:  If it is set and the dentry
>    is hashed, then it must be on the sb->s_anon list.

The code that makes that assumption is __d_shrink (which does the work
of d_drop)--it uses DCACHE_DISCONECTED to decide which hash chain to
lock.

I can't find any basis for that assumption.  The only code that clears
DCACHE_DISCONNECTED is in expfs.c, and it isn't done at the same time as
hashing.  Am I missing something?

>    This is a significant
>    which I never noticed (I haven't been watching).  Originally a
>    disconnected dentry would be attached (and hashed) to its parent.  Then
>    that parent would get its own parent and so on until it was attached all
>    the way to the root.  Only then would be start clearing
>    DCACHE_DISCONNECTED.  It seems we must clear it sooner now... I wonder if
>    that is correct.

It looks wrong to me:

If we clear DCACHE_DISCONNECTED too early, then we risk a filehandle
lookup thinking the dentry is OK to use.  That could mean for example
trying to rename across directories that don't have any ancestor
relationship to each other in the dcache yet.

So we need to wait to clear DCACHE_DISCONNECTED until we *know* the
dentry's parents go all the way back to the root.  As you say, that's
what the current code does.

But that means DCACHE_DISCONNECTED dentries can be hashed to their
parents, and __d_shrink can be handed such dentries and then get the
locking wrong.

It looks like this bug might originate with Nick Piggin's ceb5bdc2d246
"fs: dcache per-bucket dcache hash locking"?  There's no discussion in
the changelog, so probably it was just based on an unexamined assumption
about DCACHE_DISCONNECTED.

I wonder if an IS_ROOT() test could replace the DCACHE_DISCONNECTED test
in __d_shrink(), or if we need another flag, or ?

--b.
