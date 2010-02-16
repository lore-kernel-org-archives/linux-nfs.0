From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH 1/2] commit_metadata export operation replacing
	nfsd_sync_dir
Date: Tue, 16 Feb 2010 17:06:45 -0500
Message-ID: <20100216220645.GA24735@infradead.org>
References: <20100216210026.5694.14423.stgit@case> <20100216210413.5694.88826.stgit@case>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: bfields@fieldses.org, linux-nfs@vger.kernel.org, xfs@oss.sgi.com
To: Ben Myers <bpm@sgi.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([18.85.46.34]:37966 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933294Ab0BPWGq (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 16 Feb 2010 17:06:46 -0500
In-Reply-To: <20100216210413.5694.88826.stgit@case>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This looks very good to me.  A couple of tiny nitpicks below:


> +/*
> + * Commit metadata changes to stable storage.  You pay pass NULL for dchild.
> + */

The dchild argument is gone in this version.

> +	struct writeback_control wbc = {
> +		.sync_mode = WB_SYNC_ALL,
> +		.nr_to_write = 0, /* metadata only */
> +	};
> +	int error = 0;
> +
> +	if (!EX_ISSYNC(fhp->fh_export))
> +		return 0;
> +
> +	if (export_ops->commit_metadata) {
> +		error = export_ops->commit_metadata(inode);
> +	} else {
> +		error = sync_inode(inode, &wbc);
> +	}

Maybe move the wbc declaration into the else branch here to keep
variables in the smallest possible scope.

> @@ -1199,7 +1204,7 @@ nfsd_create_setattr(struct svc_rqst *rqstp, struct svc_fh *resfhp,
>  	if (current_fsuid() != 0)
>  		iap->ia_valid &= ~(ATTR_UID|ATTR_GID);
>  	if (iap->ia_valid)
> -		return nfsd_setattr(rqstp, resfhp, iap, 0, (time_t)0);
> +		return nfsd_setattr(rqstp, resfhp, iap, 0, 0);

While this is a worthwhile cleanup I'd not put it into a patch that is
now entirely unrelated.

> +	err = nfsd_create_setattr(rqstp, resfhp, iap);
>  
> +	/*
> +	 * nfsd_setattr already committed the child.  Transactional filesystems
> +	 * had a chance to commit changes for both parent and child
> +	 * simultaneously making the following commit_metadata a noop.
> +	 */
> +	err2 = nfserrno(commit_metadata(fhp));
> +       	if (err2)
>  		err = err2;

The if statement above seems rather minindented, possibly due to the
partial use of spaces instead of tabs.

