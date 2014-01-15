Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cantor2.suse.de ([195.135.220.15]:53876 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751754AbaAOReH (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 15 Jan 2014 12:34:07 -0500
Message-ID: <1389807296.16290.32.camel@tucsk.piliscsaba.szeredi.hu>
Subject: Re: [PATCH] dcache: fix d_splice_alias handling of aliases
From: Miklos Szeredi <mszeredi@suse.cz>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Al Viro <viro@zeniv.linux.org.uk>, linux-fsdevel@vger.kernel.org,
        linux-kernel@vger.kernel.org, linux-nfs@vger.kernel.org,
        miklos@szeredi.hu
Date: Wed, 15 Jan 2014 18:34:56 +0100
In-Reply-To: <20140115151749.GF23999@fieldses.org>
References: <20140115151749.GF23999@fieldses.org>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, 2014-01-15 at 10:17 -0500, J. Bruce Fields wrote:
> From: "J. Bruce Fields" <bfields@redhat.com>
> 
> d_splice_alias can create duplicate directory aliases (in the !new
> case), or (in the new case) d_move without holding appropriate locks.

It can d_move, because the dentry is known to be disconnected, i.e. it
doesn't have a parent for which we could obtain the lock.

> d_materialise_unique deals with both of these problems.  (The latter
> seems to be dealt by trylocks (see __d_unalias), which look like they
> could cause spurious lookup failures--but that's at least better than
> corrupting the dcache.)
> 
> Signed-off-by: J. Bruce Fields <bfields@redhat.com>
> ---
>  fs/dcache.c |   25 +------------------------
>  1 file changed, 1 insertion(+), 24 deletions(-)
> 
> Only lightly tested....  If this is right, then we can also just ditch
> d_splice_alias completely, and clean up the various d_find_alias's.
> 
> I think the only reason we have both d_splice_alias and
> d_materialise_unique is that the former was written for exportable
> filesystems and the latter for distributed filesystems.
> 
> But we have at least one exportable filesystem (fuse) using
> d_materialise_unique.  And I doubt d_splice_alias was ever completely
> correct even for on-disk filesystems.
> 
> Am I missing some subtlety?

One subtle difference is that for a non-directory d_splice_alias() will
reconnect a DCACHE_DISCONNECTED dentry if one exists, while
d_materialise_unique() will not.

Does this matter in practice?   The small number of extra dentries
probably does not matter.

Thanks,
Miklos


> 
> --b.
> 
> diff --git a/fs/dcache.c b/fs/dcache.c
> index 4bdb300..da82fa9 100644
> --- a/fs/dcache.c
> +++ b/fs/dcache.c
> @@ -1926,33 +1926,10 @@ EXPORT_SYMBOL(d_obtain_alias);
>   */
>  struct dentry *d_splice_alias(struct inode *inode, struct dentry *dentry)
>  {
> -	struct dentry *new = NULL;
> -
>  	if (IS_ERR(inode))
>  		return ERR_CAST(inode);
>  
> -	if (inode && S_ISDIR(inode->i_mode)) {
> -		spin_lock(&inode->i_lock);
> -		new = __d_find_alias(inode, 1);
> -		if (new) {
> -			BUG_ON(!(new->d_flags & DCACHE_DISCONNECTED));
> -			spin_unlock(&inode->i_lock);
> -			security_d_instantiate(new, inode);
> -			d_move(new, dentry);
> -			iput(inode);
> -		} else {
> -			/* already taking inode->i_lock, so d_add() by hand */
> -			__d_instantiate(dentry, inode);
> -			spin_unlock(&inode->i_lock);
> -			security_d_instantiate(dentry, inode);
> -			d_rehash(dentry);
> -		}
> -	} else {
> -		d_instantiate(dentry, inode);
> -		if (d_unhashed(dentry))
> -			d_rehash(dentry);
> -	}
> -	return new;
> +	return d_materialise_unique(dentry, inode);
>  }
>  EXPORT_SYMBOL(d_splice_alias);
>  


