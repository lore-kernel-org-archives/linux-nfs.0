Return-Path: linux-nfs-owner@vger.kernel.org
Received: from bombadil.infradead.org ([198.137.202.9]:60120 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753311Ab3KBNwj (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 2 Nov 2013 09:52:39 -0400
Date: Sat, 2 Nov 2013 06:52:38 -0700
From: Christoph Hellwig <hch@infradead.org>
To: Anna Schumaker <bjschuma@netapp.com>
Cc: bfields@fieldses.org, linux-nfs@vger.kernel.org
Subject: Re: [PATCH 3/4] NFSD: Add WRITE_PLUS support for hole punches
Message-ID: <20131102135238.GB18961@infradead.org>
References: <1382972247-1108-1-git-send-email-bjschuma@netapp.com>
 <1382972247-1108-4-git-send-email-bjschuma@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1382972247-1108-4-git-send-email-bjschuma@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

> +__be32 nfsd4_vfs_fallocate(struct file *file, bool allocated, loff_t offset, loff_t len)
> +{
> +	int error, mode = 0;
> +
> +	if (allocated == false)
> +		mode = FALLOC_FL_PUNCH_HOLE | FALLOC_FL_KEEP_SIZE;
> +
> +	error = do_fallocate(file, mode, offset, len);
> +	if (error == 0)
> +		error = vfs_fsync_range(file, offset, offset + len, 0);

What are you trying to do with the fsync_range here?  If it's just to
make sure the metadata operation is stable on disk please use commit_metadata()
from fs/nfsd/vfs.c.  As there's no data involved here I can't really see
what else it would be for.


Also the allocated flag doesn't make any sense for people not taking the
same drugs as the spec authors, please add a comment what it means.

Btw, how did anyone come up with the name WRITE PLUS for something that
doesn't actually involve any writes?

