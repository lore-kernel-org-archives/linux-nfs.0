Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:34340 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932796Ab2F2U3L (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 29 Jun 2012 16:29:11 -0400
Date: Fri, 29 Jun 2012 16:29:03 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: NeilBrown <neilb@suse.de>
Cc: Al Viro <viro@ZenIV.linux.org.uk>, Nick Piggin <npiggin@gmail.com>,
        Nick Piggin <npiggin@kernel.dk>, linux-nfs@vger.kernel.org,
        linux-fsdevel@vger.kernel.org
Subject: Re: [PATCH] fs/dcache: allow __d_obtain_alias() to return unhashed
 dentries
Message-ID: <20120629202903.GB17103@fieldses.org>
References: <AANLkTingRv_gtRSctGzMfYrKg02M_sKj97HSQPRm_mA_@mail.gmail.com>
 <20101227234641.GA22248@fieldses.org>
 <20110118204509.GA10903@fieldses.org>
 <AANLkTikL2CDSWQJ1QH_Y4G-j70Vd=VesNMMnYTmMGHC9@mail.gmail.com>
 <20110118220817.GF10903@fieldses.org>
 <20110308181320.GA15566@fieldses.org>
 <20110310105821.GE22723@ZenIV.linux.org.uk>
 <20110311150749.2fa2be66@notabene.brown>
 <20120628135927.GA6406@fieldses.org>
 <20120629201034.GA17103@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20120629201034.GA17103@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Jun 29, 2012 at 04:10:34PM -0400, J. Bruce Fields wrote:
> On Thu, Jun 28, 2012 at 09:59:27AM -0400, J. Bruce Fields wrote:
> > Coming back to this now, just trying to review the
> > filehandle-lookup/dcache interactions:
> > 
> > On Fri, Mar 11, 2011 at 03:07:49PM +1100, NeilBrown wrote:
> > > 1/ Originally DCACHE_DISCONNECTED didn't really mean much - it's presence
> > >    was only a hint, its absence was a strong statement.
> > >    If the flag is set, the dentry might not be linked to the root.
> > >    If it is clear, it definitely is link through to the root.
> > >    However I think it was used with stronger intent than that.
> > > 
> > >    Now it seems to mean a little bit more:  If it is set and the dentry
> > >    is hashed, then it must be on the sb->s_anon list.
> > 
> > The code that makes that assumption is __d_shrink (which does the work
> > of d_drop)--it uses DCACHE_DISCONECTED to decide which hash chain to
> > lock.
> > 
> > I can't find any basis for that assumption.  The only code that clears
> > DCACHE_DISCONNECTED is in expfs.c, and it isn't done at the same time as
> > hashing.  Am I missing something?
> > 
> > >    This is a significant
> > >    which I never noticed (I haven't been watching).  Originally a
> > >    disconnected dentry would be attached (and hashed) to its parent.  Then
> > >    that parent would get its own parent and so on until it was attached all
> > >    the way to the root.  Only then would be start clearing
> > >    DCACHE_DISCONNECTED.  It seems we must clear it sooner now... I wonder if
> > >    that is correct.
> > 
> > It looks wrong to me:
> > 
> > If we clear DCACHE_DISCONNECTED too early, then we risk a filehandle
> > lookup thinking the dentry is OK to use.  That could mean for example
> > trying to rename across directories that don't have any ancestor
> > relationship to each other in the dcache yet.
> > 
> > So we need to wait to clear DCACHE_DISCONNECTED until we *know* the
> > dentry's parents go all the way back to the root.  As you say, that's
> > what the current code does.
> > 
> > But that means DCACHE_DISCONNECTED dentries can be hashed to their
> > parents, and __d_shrink can be handed such dentries and then get the
> > locking wrong.
> > 
> > It looks like this bug might originate with Nick Piggin's ceb5bdc2d246
> > "fs: dcache per-bucket dcache hash locking"?  There's no discussion in
> > the changelog, so probably it was just based on an unexamined assumption
> > about DCACHE_DISCONNECTED.
> > 
> > I wonder if an IS_ROOT() test could replace the DCACHE_DISCONNECTED test
> > in __d_shrink(), or if we need another flag, or ?
> 
> Bah, sorry, and I only just noticed that you already said as much later
> and did the IS_ROOT() thing in your patch.
> 
> Anyway, here's just that one change with a slightly more painstaking
> changelog.
> 
> --b.
> 
> commit b1fa644355122627424fe2240a9fc60cbef4c349
> Author: J. Bruce Fields <bfields@redhat.com>
> Date:   Thu Jun 28 12:10:55 2012 -0400
> 
>     dcache: use IS_ROOT to decide where dentry is hashed
>     
>     Every hashed dentry is either hashed in the dentry_hashtable, or a
>     superblock's s_anon list.
>     
>     __d_shrink assumes it can determine which is the case by checking
>     DCACHE_DISCONNECTED; this is not true.
>     
>     It is true that when DCACHE_DISCONNECTED is cleared, the dentry is not
>     only hashed on dentry_hashtable, but is fully connected to its parents
>     back to the root.
>     
>     But the converse is *not* true: fs/exportfs/expfs.c:reconnect_path()
>     attempts to connect a directory (found by filehandle lookup) back to
>     root by ascending to parents and performing lookups one at a time.  It
>     does not clear DCACHE_DISCONNECTED until its done, and that is not at
>     all an atomic process.
>     
>     In particular, it is possible for DCACHE_DISCONNECTED to be set on a
>     dentry which is hashed on the dentry_hashtable.
>     
>     Instead, use IS_ROOT() to check which hash chain a dentry is on.  This
>     *does* work:
>     
>     Dentries are hashed only by:
>     
>     	- d_obtain_alias, which adds an IS_ROOT() dentry to sb_anon.
>     
>     	- __d_rehash, called by _d_rehash: hashes to the dentry's
>     	  parent, and all callers of _d_rehash appear to have d_parent
>     	  set to a "real" parent.
>     	- __d_rehash, called by __d_move: rehashes the moved dentry to
>     	  hash chain determined by target, and assigns target's d_parent
>     	  to its d_parent, before dropping the dentry's d_lock.
>     
>     Therefore I believe it's safe for a holder of a dentry's d_lock to
>     assume that it is hashed on sb_anon if and only if IS_ROOT(dentry) is
>     true.
>     
>     I believe the incorrect assumption about DCACHE_DISCONNECTED was
>     originally introduced by ceb5bdc2d246 "fs: dcache per-bucket dcache hash
>     locking".
>     
>     Cc: Neil Brown <neilb@suse.de>
>     Cc: Nick Piggin <npiggin@kernel.dk>
>     Signed-off-by: J. Bruce Fields <bfields@redhat.com>
> 
> diff --git a/fs/dcache.c b/fs/dcache.c
> index 87c2da7..b2b382c 100644
> --- a/fs/dcache.c
> +++ b/fs/dcache.c
> @@ -410,7 +410,7 @@ static void __d_shrink(struct dentry *dentry)
>  {
>  	if (!d_unhashed(dentry)) {
>  		struct hlist_bl_head *b;
> -		if (unlikely(dentry->d_flags & DCACHE_DISCONNECTED))
> +		if (unlikely(IS_ROOT(dentry->d_flags)))

Um, right--I'll send an actual tested version along with some other
stuff later.

--b.

>  			b = &dentry->d_sb->s_anon;
>  		else
>  			b = d_hash(dentry->d_parent, dentry->d_name.hash);
