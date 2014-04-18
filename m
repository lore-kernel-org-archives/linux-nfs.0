Return-Path: linux-nfs-owner@vger.kernel.org
Received: from bombadil.infradead.org ([198.137.202.9]:48423 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751307AbaDRN4Q (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 18 Apr 2014 09:56:16 -0400
Date: Fri, 18 Apr 2014 06:56:12 -0700
From: Christoph Hellwig <hch@infradead.org>
To: Anna Schumaker <Anna.Schumaker@netapp.com>
Cc: Trond.Myklebust@primarydata.com, linux-nfs@vger.kernel.org
Subject: Re: [PATCH 01/17] NFS: Create a common argument structure for reads
 and writes
Message-ID: <20140418135612.GA20096@infradead.org>
References: <1397768981-12856-1-git-send-email-Anna.Schumaker@Netapp.com>
 <1397768981-12856-2-git-send-email-Anna.Schumaker@Netapp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1397768981-12856-2-git-send-email-Anna.Schumaker@Netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

>  /*
> + * Arguments shared by the read and write call.
> + */
> +struct nfs_pgio_args {
> +	struct nfs4_sequence_args	seq_args;
> +	struct nfs_fh *		fh;
> +	struct nfs_open_context *context;
> +	struct nfs_lock_context *lock_context;
> +	nfs4_stateid		stateid;
> +	__u64			offset;
> +	__u32			count;
> +	enum nfs3_stable_how	stable;		/* used by write */
> +	unsigned int		pgbase;
> +	struct page **		pages;
> +	const u32 *		bitmask;	/* used by write */
> +};

It might make sense to keep the arguments only used for writes together
at the end of the structure.

Otherwise looks good,

Reviewed-by: Christoph Hellwig <hch@lst.de>
