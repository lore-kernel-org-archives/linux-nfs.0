Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([18.85.46.34]:36228 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933325Ab1CWVAa (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 23 Mar 2011 17:00:30 -0400
Date: Wed, 23 Mar 2011 17:00:28 -0400
From: Christoph Hellwig <hch@infradead.org>
To: Fred Isaman <iisaman@netapp.com>
Cc: linux-nfs@vger.kernel.org, Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: Re: [PATCH 11/12] NFSv4.1: layoutcommit
Message-ID: <20110323210028.GA31040@infradead.org>
References: <1300886875-5016-1-git-send-email-iisaman@netapp.com>
 <1300886875-5016-12-git-send-email-iisaman@netapp.com>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1300886875-5016-12-git-send-email-iisaman@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

> @@ -326,6 +326,9 @@ nfs_file_fsync(struct file *file, int datasync)
>  		ret = xchg(&ctx->error, 0);
>  	if (!ret && status < 0)
>  		ret = status;
> +	if (!ret && !datasync)
> +		/* application has asked for meta-data sync */
> +		ret = pnfs_layoutcommit_inode(inode, 1);

I don't think that is correct.  AFAIK the layoutcommit is needed to
get back to the data after a crash - basically the only thing a
!datasync fsync can skip is dirty timestamps.

>  int nfs_write_inode(struct inode *inode, struct writeback_control *wbc)
>  {
> -	return nfs_commit_unstable_pages(inode, wbc);
> +	int ret;
> +
> +	ret = nfs_commit_unstable_pages(inode, wbc);
> +	if (ret >= 0 && test_bit(NFS_INO_LAYOUTCOMMIT, &NFS_I(inode)->flags)) {
> +		int status, sync = wbc->sync_mode;
> +
> +		if (wbc->nonblocking || wbc->for_background)
> +				sync = 0;

incorrect indentation.

