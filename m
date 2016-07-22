Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:49444 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752154AbcGVB7F (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 21 Jul 2016 21:59:05 -0400
Date: Thu, 21 Jul 2016 21:59:04 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: NeilBrown <neilb@suse.com>
Cc: fdmanana@kernel.org, linux-btrfs@vger.kernel.org,
        NFS List <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 1/2] Btrfs: be more precise on errors when getting an
 inode from disk
Message-ID: <20160722015904.GB29969@fieldses.org>
References: <1465491191-28102-1-git-send-email-fdmanana@kernel.org>
 <874m7i8oou.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <874m7i8oou.fsf@notabene.neil.brown.name>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Jul 22, 2016 at 11:08:17AM +1000, NeilBrown wrote:
> On Fri, Jun 10 2016, fdmanana@kernel.org wrote:
> 
> > From: Filipe Manana <fdmanana@suse.com>
> >
> > When we attempt to read an inode from disk, we end up always returning an
> > -ESTALE error to the caller regardless of the actual failure reason, which
> > can be an out of memory problem (when allocating a path), some error found
> > when reading from the fs/subvolume btree (like a genuine IO error) or the
> > inode does not exists. So lets start returning the real error code to the
> > callers so that they don't treat all -ESTALE errors as meaning that the
> > inode does not exists (such as during orphan cleanup). This will also be
> > needed for a subsequent patch in the same series dealing with a special
> > fsync case.
> >
> > Signed-off-by: Filipe Manana <fdmanana@suse.com>
> 
> SNIP
> 
> > @@ -5594,7 +5602,8 @@ struct inode *btrfs_iget(struct super_block *s, struct btrfs_key *location,
> >  		} else {
> >  			unlock_new_inode(inode);
> >  			iput(inode);
> > -			inode = ERR_PTR(-ESTALE);
> > +			ASSERT(ret < 0);
> > +			inode = ERR_PTR(ret < 0 ? ret : -ESTALE);
> >  		}
> 
> Just a heads-up.  This change breaks NFS :-(
> 
> The change in error code percolates up the call chain:
> 
>  nfs4_pufh->fh_verify->nfsd_set_fh_dentry->exportfs_decode_fh
>     ->btrfs_fh_to_dentry->ntrfs_get_dentry->btrfs_iget
> 
> and nfsd returns NFS4ERR_NOENT to the client instead of NFS4ERR_STALE,
> and the client doesn't handle that quite the same way.
> 
> This doesn't mean that the change is wrong, but it could mean we need to
> fix something else in the path to sanitize the error code.
> 
> nfsd_set_fh_dentry already has
> 
> 	error = nfserr_stale;
> 	if (PTR_ERR(exp) == -ENOENT)
> 		return error;
> 
> 	if (IS_ERR(exp))
> 		return nfserrno(PTR_ERR(exp));
> 
> for a different error case, so duplicating that would work, but I doubt
> it is best.  At the very least we should check for valid errors, not
> specific invalid ones.
> 
> Bruce: do you have an opinion where we should make sure that PUTFH (and
> various other requests) returns a valid error code?

Uh, I guess not.  Maybe exportfs_decode_fh?

Though my kneejerk reaction is to be cranky and wonder why btrfs
suddenly needs a different convention for decode_fh().

--b.
