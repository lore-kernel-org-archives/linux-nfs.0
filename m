Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:51595 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752989AbaIHPAt (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 8 Sep 2014 11:00:49 -0400
Date: Mon, 8 Sep 2014 11:00:48 -0400
To: Christoph Hellwig <hch@lst.de>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH] nfsd: update mtime on truncate
Message-ID: <20140908150048.GA31967@fieldses.org>
References: <1410117352-28443-1-git-send-email-hch@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1410117352-28443-1-git-send-email-hch@lst.de>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sun, Sep 07, 2014 at 12:15:52PM -0700, Christoph Hellwig wrote:
> This fixes a failure in xfstests generic/313 because nfs doesn't update
> mtime on a truncate.  The protocol requires this to be done implicity
> for a size changing setattr.

Thanks,  Intending just to queue up for 3.18 unless you see a reason
it's more urgent.

--b.

> 
> Signed-off-by: Christoph Hellwig <hch@lst.de>
> ---
>  fs/nfsd/vfs.c | 10 ++++++++++
>  1 file changed, 10 insertions(+)
> 
> diff --git a/fs/nfsd/vfs.c b/fs/nfsd/vfs.c
> index f501a9b..60ed117 100644
> --- a/fs/nfsd/vfs.c
> +++ b/fs/nfsd/vfs.c
> @@ -445,6 +445,16 @@ nfsd_setattr(struct svc_rqst *rqstp, struct svc_fh *fhp, struct iattr *iap,
>  		if (err)
>  			goto out;
>  		size_change = 1;
> +
> +		/*
> +		 * RFC5661, Section 18.30.4:
> +		 *   Changing the size of a file with SETATTR indirectly
> +		 *   changes the time_modify and change attributes.
> +		 *
> +		 * (and similar for the older RFCs)
> +		 */
> +		if (iap->ia_size != i_size_read(inode))
> +			iap->ia_valid |= ATTR_MTIME;
>  	}
>  
>  	iap->ia_valid |= ATTR_CTIME;
> -- 
> 1.9.1
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
