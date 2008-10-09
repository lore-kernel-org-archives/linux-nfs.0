From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: connectathon test failures
Date: Thu, 9 Oct 2008 15:23:52 -0400
Message-ID: <20081009192352.GB482@fieldses.org>
References: <20081008225543.GG14527@fieldses.org> <20081009020300.GA17896@fieldses.org> <20081009021011.GB17896@fieldses.org> <1223562985.7494.17.camel@localhost> <20081009155347.GB28785@fieldses.org> <1223573773.7494.21.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:37100 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756696AbYJITYA (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 9 Oct 2008 15:24:00 -0400
In-Reply-To: <1223573773.7494.21.camel@localhost>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Oct 09, 2008 at 01:36:13PM -0400, Trond Myklebust wrote:
> OK. Having thought a little bit more about this, I think we can just
> delete the wraparound protection in nfs_update_inode(). We already have
> similar protection in nfs_inode_attrs_need_update()...

I retested with this patch, and it passed.  Thanks!

--b.

> 
> Cheers
>   Trond
> --------------------------------------------------------------------------
> From: Trond Myklebust <Trond.Myklebust@netapp.com>
> Date: Thu, 9 Oct 2008 13:27:55 -0400
> NFS: Fix attribute updates
> 
> This fixes a regression seen when running the Connectathon testsuite
> against an ext3 filesystem. The reason was that the inode was constantly
> being marked as 'just updated' by the jiffy wraparound test.
> This again meant that newer GETATTR calls were failing to pass the
> nfs_inode_attrs_need_update() test unless the changes caused a ctime update
> on the server, since they were perceived as having been started before the
> latest inode update.
> 
> Given that nfs_inode_attrs_need_update() already checks for wraparound
> of nfsi->last_updated, we can drop the buggy "protection" in
> nfs_update_inode().
> 
> Also make a slight micro-optimisation of nfs_inode_attrs_need_update(): we
> are more often going to see time_after(fattr->time_start, nfsi->last_updated)
> be true, rather than seeing an update of ctime/size, so put that test
> first to ensure that we optimise away the ctime/size tests.
> 
> Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
> ---
> 
>  fs/nfs/inode.c |   13 ++++---------
>  1 files changed, 4 insertions(+), 9 deletions(-)
> 
> diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
> index e25009f..6554281 100644
> --- a/fs/nfs/inode.c
> +++ b/fs/nfs/inode.c
> @@ -933,10 +933,10 @@ static int nfs_inode_attrs_need_update(const struct inode *inode, const struct n
>  {
>  	const struct nfs_inode *nfsi = NFS_I(inode);
>  
> -	return nfs_ctime_need_update(inode, fattr) ||
> -			nfs_size_need_update(inode, fattr) ||
> -			time_after(fattr->time_start, nfsi->last_updated) ||
> -			time_after(nfsi->last_updated, jiffies);
> +	return time_after(fattr->time_start, nfsi->last_updated) ||
> +		nfs_ctime_need_update(inode, fattr) ||
> +		nfs_size_need_update(inode, fattr) ||
> +		time_after(nfsi->last_updated, jiffies);
>  }
>  
>  static int nfs_refresh_inode_locked(struct inode *inode, struct nfs_fattr *fattr)
> @@ -1167,11 +1167,6 @@ static int nfs_update_inode(struct inode *inode, struct nfs_fattr *fattr)
>  				nfsi->attrtimeo = NFS_MAXATTRTIMEO(inode);
>  			nfsi->attrtimeo_timestamp = now;
>  		}
> -		/*
> -		 * Avoid jiffy wraparound issues with nfsi->last_updated
> -		 */
> -		if (!time_in_range(nfsi->last_updated, nfsi->read_cache_jiffies, now))
> -			nfsi->last_updated = nfsi->read_cache_jiffies;
>  	}
>  	invalid &= ~NFS_INO_INVALID_ATTR;
>  	/* Don't invalidate the data if we were to blame */
> 
> 
> -- 
> Trond Myklebust
> Linux NFS client maintainer
> 
> NetApp
> Trond.Myklebust@netapp.com
> www.netapp.com
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
