Return-Path: linux-nfs-owner@vger.kernel.org
Received: from bombadil.infradead.org ([198.137.202.9]:42610 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753788Ab3KEJkQ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 5 Nov 2013 04:40:16 -0500
Date: Tue, 5 Nov 2013 01:40:16 -0800
From: Christoph Hellwig <hch@infradead.org>
To: Anna Schumaker <bjschuma@netapp.com>
Cc: bfields@fieldses.org, linux-nfs@vger.kernel.org
Subject: Re: [PATCH 3/4] NFSD: Add WRITE_PLUS support for hole punches
Message-ID: <20131105094016.GA7186@infradead.org>
References: <1382972247-1108-1-git-send-email-bjschuma@netapp.com>
 <1382972247-1108-4-git-send-email-bjschuma@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1382972247-1108-4-git-send-email-bjschuma@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

> +{
> +	int error, mode = 0;
> +
> +	if (allocated == false)
> +		mode = FALLOC_FL_PUNCH_HOLE | FALLOC_FL_KEEP_SIZE;
> +
> +	error = do_fallocate(file, mode, offset, len);
> +	if (error == 0)
> +		error = vfs_fsync_range(file, offset, offset + len, 0);
> +	return nfserrno(error);

Same problem with the falloc vs WRITE_PLUS mismatch here.  For XFS you
could make the allocated case all XFS_IOC_ZERO_RANGE, but the proposed
VFS equivalent never seemed to have made it in.

Also no need for the FALLOC_FL_KEEP_SIZE in the hole punch case, it is
ignored.

