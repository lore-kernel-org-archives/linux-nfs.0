Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:40220 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751751AbcGVUIo (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 22 Jul 2016 16:08:44 -0400
Date: Fri, 22 Jul 2016 16:08:43 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: NeilBrown <neilb@suse.com>
Cc: fdmanana@kernel.org, linux-btrfs@vger.kernel.org,
        NFS List <linux-nfs@vger.kernel.org>,
        Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH 1/2] Btrfs: be more precise on errors when getting an
 inode from disk
Message-ID: <20160722200843.GA7463@fieldses.org>
References: <1465491191-28102-1-git-send-email-fdmanana@kernel.org>
 <874m7i8oou.fsf@notabene.neil.brown.name>
 <20160722015904.GB29969@fieldses.org>
 <87bn1q75ut.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <87bn1q75ut.fsf@notabene.neil.brown.name>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Jul 22, 2016 at 12:40:26PM +1000, NeilBrown wrote:
> On Fri, Jul 22 2016, J. Bruce Fields wrote:
> 
> > On Fri, Jul 22, 2016 at 11:08:17AM +1000, NeilBrown wrote:
> >> On Fri, Jun 10 2016, fdmanana@kernel.org wrote:
> >> 
> >> > From: Filipe Manana <fdmanana@suse.com>
> >> >
> >> > When we attempt to read an inode from disk, we end up always returning an
> >> > -ESTALE error to the caller regardless of the actual failure reason, which
> >> > can be an out of memory problem (when allocating a path), some error found
> >> > when reading from the fs/subvolume btree (like a genuine IO error) or the
> >> > inode does not exists. So lets start returning the real error code to the
> >> > callers so that they don't treat all -ESTALE errors as meaning that the
> >> > inode does not exists (such as during orphan cleanup). This will also be
> >> > needed for a subsequent patch in the same series dealing with a special
> >> > fsync case.
> >> >
> >> > Signed-off-by: Filipe Manana <fdmanana@suse.com>
> >> 
> >> SNIP
> >> 
> >> > @@ -5594,7 +5602,8 @@ struct inode *btrfs_iget(struct super_block *s, struct btrfs_key *location,
> >> >  		} else {
> >> >  			unlock_new_inode(inode);
> >> >  			iput(inode);
> >> > -			inode = ERR_PTR(-ESTALE);
> >> > +			ASSERT(ret < 0);
> >> > +			inode = ERR_PTR(ret < 0 ? ret : -ESTALE);
> >> >  		}
> >> 
> >> Just a heads-up.  This change breaks NFS :-(
> >> 
> >> The change in error code percolates up the call chain:
> >> 
> >>  nfs4_pufh->fh_verify->nfsd_set_fh_dentry->exportfs_decode_fh
> >>     ->btrfs_fh_to_dentry->ntrfs_get_dentry->btrfs_iget
> >> 
> >> and nfsd returns NFS4ERR_NOENT to the client instead of NFS4ERR_STALE,
> >> and the client doesn't handle that quite the same way.
> >> 
> >> This doesn't mean that the change is wrong, but it could mean we need to
> >> fix something else in the path to sanitize the error code.
> >> 
> >> nfsd_set_fh_dentry already has
> >> 
> >> 	error = nfserr_stale;
> >> 	if (PTR_ERR(exp) == -ENOENT)
> >> 		return error;
> >> 
> >> 	if (IS_ERR(exp))
> >> 		return nfserrno(PTR_ERR(exp));
> >> 
> >> for a different error case, so duplicating that would work, but I doubt
> >> it is best.  At the very least we should check for valid errors, not
> >> specific invalid ones.
> >> 
> >> Bruce: do you have an opinion where we should make sure that PUTFH (and
> >> various other requests) returns a valid error code?
> >
> > Uh, I guess not.  Maybe exportfs_decode_fh?
> >
> > Though my kneejerk reaction is to be cranky and wonder why btrfs
> > suddenly needs a different convention for decode_fh().
> >
> 
> I can certainly agree with that perspective, though it would be
> appropriate in that case to make sure we document the requirements for
> fh_to_dentry (the current spelling for 'decode_fh').  So I went looking
> for documentation and found:
> 
>  * fh_to_dentry:
>  *    @fh_to_dentry is given a &struct super_block (@sb) and a file handle
>  *    fragment (@fh, @fh_len). It should return a &struct dentry which refers
>  *    to the same file that the file handle fragment refers to.  If it cannot,
>  *    it should return a %NULL pointer if the file was found but no acceptable
>  *    &dentries were available, or an %ERR_PTR error code indicating why it
>  *    couldn't be found (e.g. %ENOENT or %ENOMEM).  Any suitable dentry can be
>  *    returned including, if necessary, a new dentry created with d_alloc_root.
>  *    The caller can then find any other extant dentries by following the
>  *    d_alias links.
>  *
> 
> So the new btrfs code is actually conformant!!
> That documentation dates back to 2002 when I wrote it....
> And it looks like ENOENT wasn't handled correctly then :-(
> 
> I suspect anything that isn't ENOMEM should be converted to ESTALE.
> ENOMEM causes the client to be asked to retry the request later.
> 
> Does this look reasonable to you?
> (Adding Christof as he as contributed a lot to exportfs)
> 
> If there is agreement I'll test and post a proper patch.

I can live with it.  It bothers me that we're losing potentially useful
information about what went wrong in the filesystem.  Maybe this is a
place a dprintk could be handy?

--b.

> 
> Thanks,
> NeilBrown
> 
> 
> diff --git a/fs/exportfs/expfs.c b/fs/exportfs/expfs.c
> index 207ba8d627ca..3527b58cd5bc 100644
> --- a/fs/exportfs/expfs.c
> +++ b/fs/exportfs/expfs.c
> @@ -428,10 +428,10 @@ struct dentry *exportfs_decode_fh(struct vfsmount *mnt, struct fid *fid,
>  	if (!nop || !nop->fh_to_dentry)
>  		return ERR_PTR(-ESTALE);
>  	result = nop->fh_to_dentry(mnt->mnt_sb, fid, fh_len, fileid_type);
> -	if (!result)
> -		result = ERR_PTR(-ESTALE);
> -	if (IS_ERR(result))
> -		return result;
> +	if (PTR_ERR(result) == -ENOMEM)
> +		return ERR_CAST(result)
> +	if (IS_ERR_OR_NULL(result))
> +		return ERR_PTR(-ESTALE);
>  
>  	if (d_is_dir(result)) {
>  		/*
> @@ -541,6 +541,8 @@ struct dentry *exportfs_decode_fh(struct vfsmount *mnt, struct fid *fid,
>  
>   err_result:
>  	dput(result);
> +	if (err != -ENOMEM)
> +		err = -ESTALE;
>  	return ERR_PTR(err);
>  }
>  EXPORT_SYMBOL_GPL(exportfs_decode_fh);


