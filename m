Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:37341 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757978Ab3HHSLh (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 8 Aug 2013 14:11:37 -0400
Date: Thu, 8 Aug 2013 14:11:30 -0400
From: Jeff Layton <jlayton@redhat.com>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: <linux-nfs@vger.kernel.org>, William Dauchy <william@gandi.net>,
        Pascal Bouchareine <pascal@gandi.net>
Subject: Re: [PATCH v3] NFS: Fix writeback performance issue on cache
 invalidation
Message-ID: <20130808141130.27cf2b26@tlielax.poochiereds.net>
In-Reply-To: <1375910064-23731-1-git-send-email-Trond.Myklebust@netapp.com>
References: <1375910064-23731-1-git-send-email-Trond.Myklebust@netapp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, 7 Aug 2013 17:14:24 -0400
Trond Myklebust <Trond.Myklebust@netapp.com> wrote:

> If a cache invalidation is triggered, and we happen to have a lot of
> writebacks cached at the time, then the call to invalidate_inode_pages2()
> will end up calling ->launder_page() on each and every dirty page in order
> to sync its contents to disk, thus defeating write coalescing.
> The following patch ensures that we try to sync the inode to disk before
> calling invalidate_inode_pages2() so that we do the writeback as efficiently
> as possible.
> 
> Reported-by: William Dauchy <william@gandi.net>
> Reported-by: Pascal Bouchareine <pascal@gandi.net>
> Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
> Tested-by: William Dauchy <william@gandi.net>
> Reviewed-by: Jeff Layton <jlayton@redhat.com>
> ---
> v2: Add check for regular file as per Jeff Layton's suggestion.
> v3: Minor cleanup and add Jeff as a reviewer
> 
>  fs/nfs/inode.c | 10 ++++++++--
>  1 file changed, 8 insertions(+), 2 deletions(-)
> 
> diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
> index af6e806..3ea4f64 100644
> --- a/fs/nfs/inode.c
> +++ b/fs/nfs/inode.c
> @@ -963,9 +963,15 @@ EXPORT_SYMBOL_GPL(nfs_revalidate_inode);
>  static int nfs_invalidate_mapping(struct inode *inode, struct address_space *mapping)
>  {
>  	struct nfs_inode *nfsi = NFS_I(inode);
> -	
> +	int ret;
> +
>  	if (mapping->nrpages != 0) {
> -		int ret = invalidate_inode_pages2(mapping);
> +		if (S_ISREG(inode->i_mode)) {
> +			ret = nfs_sync_mapping(mapping);
> +			if (ret < 0)
> +				return ret;
> +		}
> +		ret = invalidate_inode_pages2(mapping);
>  		if (ret < 0)
>  			return ret;
>  	}

It occurs to me that we have several places that call nfs_sync_mapping
without checking S_ISREG. Are they potentially problematic?

Might it make more sense to move the S_ISREG test inside of
nfs_sync_mapping and just have it "return 0" when it's not a regular
file?

-- 
Jeff Layton <jlayton@redhat.com>
