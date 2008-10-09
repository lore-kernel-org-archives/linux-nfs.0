From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: connectathon test failures
Date: Thu, 9 Oct 2008 11:53:48 -0400
Message-ID: <20081009155347.GB28785@fieldses.org>
References: <20081008225543.GG14527@fieldses.org> <20081009020300.GA17896@fieldses.org> <20081009021011.GB17896@fieldses.org> <1223562985.7494.17.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:57760 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755229AbYJIPxu (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 9 Oct 2008 11:53:50 -0400
In-Reply-To: <1223562985.7494.17.camel@localhost>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Oct 09, 2008 at 10:36:25AM -0400, Trond Myklebust wrote:
> On Wed, 2008-10-08 at 22:10 -0400, J. Bruce Fields wrote:
> > On Wed, Oct 08, 2008 at 10:03:00PM -0400, bfields wrote:
> > > On Wed, Oct 08, 2008 at 06:55:43PM -0400, bfields wrote:
> > > > I'm getting connectathon test failures with the latest merge of code
> > > > from both our trees, linux-to-linux over v3 and v4.
> > > > 
> > > > I just got this a moment ago, so haven't tried to track it down at all
> > > > yet--but I seem to recall in the past this sort of failure has been an
> > > > attribute revalidation problem (usually with the ext3 ctime resolution
> > > > at least partly to blame).
> > > 
> > > The failure first happens with d65f557f3 "NFS: Fix
> > > nfs_post_op_update_inode_force_wcc()".
> > 
> > Err, sorry, no: that was the last *good* one!  It's the following one (
> > (4dc05efb86 "NFS: Convert __nfs_revalidate_inode() to use
> > nfs_refresh_inode()") where the failures start.
> 
> Hmm... That patch should be correct. I rather suspect a problem with the
> updating of nfsi->last_updated.
> 
> Could you see if something like the following patch helps?

Yep, if I apply this on top of your linux-mm
(19d771f3caccaf66ce2fb539319222139e5b4e88) then I can no longer see the
failure.

--b.

> ---------------------------------------------------------------------------------
> From: Trond Myklebust <Trond.Myklebust@netapp.com>
> NFS: Fix attribute updates
> 
> Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
> ---
> 
>  fs/nfs/inode.c |   12 ++++++------
>  1 files changed, 6 insertions(+), 6 deletions(-)
> 
> diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
> index e25009f..d45e7b5 100644
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
> @@ -1170,8 +1170,8 @@ static int nfs_update_inode(struct inode *inode, struct nfs_fattr *fattr)
>  		/*
>  		 * Avoid jiffy wraparound issues with nfsi->last_updated
>  		 */
> -		if (!time_in_range(nfsi->last_updated, nfsi->read_cache_jiffies, now))
> -			nfsi->last_updated = nfsi->read_cache_jiffies;
> +		if (!time_in_range(nfsi->last_updated, now - NFS_MAXATTRTIMEO(inode), now))
> +			nfsi->last_updated = now - NFS_MAXATTRTIMEO(inode);
>  	}
>  	invalid &= ~NFS_INO_INVALID_ATTR;
>  	/* Don't invalidate the data if we were to blame */
> 
> -- 
> Trond Myklebust
> Linux NFS client maintainer
> 
> NetApp
> Trond.Myklebust@netapp.com
> www.netapp.com
