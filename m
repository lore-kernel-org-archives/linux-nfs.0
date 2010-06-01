From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH] nfsd: nfsd_setattr needs to call commit_metadata
Date: Tue, 1 Jun 2010 19:18:49 -0400
Message-ID: <20100601231849.GE27423@fieldses.org>
References: <20100601195917.GA25910@lst.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: bpm@sgi.com, linux-nfs@vger.kernel.org
To: Christoph Hellwig <hch@lst.de>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:52865 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751364Ab0FAXSx (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 1 Jun 2010 19:18:53 -0400
In-Reply-To: <20100601195917.GA25910@lst.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Jun 01, 2010 at 09:59:18PM +0200, Christoph Hellwig wrote:
> The conversion of write_inode_now calls to commit_metadata in commit
> f501912a35c02eadc55ca9396ece55fe36f785d0 missed out the call in nfsd_setattr.
> 
> But without this conversion we can't guarantee that a SETATTR request
> has actually been commited to disk with XFS, which causes a regression
> from 2.6.32 (only for NFSv2, but anyway).

Got it, thanks.

--b.

> 
> Signed-off-by: Christoph Hellwig <hch@lst.de>
> 
> Index: linux-2.6/fs/nfsd/vfs.c
> ===================================================================
> --- linux-2.6.orig/fs/nfsd/vfs.c	2010-06-01 21:24:34.945004695 +0200
> +++ linux-2.6/fs/nfsd/vfs.c	2010-06-01 21:25:48.299003856 +0200
> @@ -443,8 +443,7 @@ nfsd_setattr(struct svc_rqst *rqstp, str
>  	if (size_change)
>  		put_write_access(inode);
>  	if (!err)
> -		if (EX_ISSYNC(fhp->fh_export))
> -			write_inode_now(inode, 1);
> +		commit_metadata(fhp);
>  out:
>  	return err;
>  
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
