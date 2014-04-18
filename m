Return-Path: linux-nfs-owner@vger.kernel.org
Received: from bombadil.infradead.org ([198.137.202.9]:49159 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751197AbaDRN50 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 18 Apr 2014 09:57:26 -0400
Date: Fri, 18 Apr 2014 06:57:25 -0700
From: Christoph Hellwig <hch@infradead.org>
To: Anna Schumaker <Anna.Schumaker@netapp.com>
Cc: Trond.Myklebust@primarydata.com, linux-nfs@vger.kernel.org
Subject: Re: [PATCH 02/17] NFS: Create a common results structure for reads
 and writes
Message-ID: <20140418135725.GB20096@infradead.org>
References: <1397768981-12856-1-git-send-email-Anna.Schumaker@Netapp.com>
 <1397768981-12856-3-git-send-email-Anna.Schumaker@Netapp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1397768981-12856-3-git-send-email-Anna.Schumaker@Netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

> +struct nfs_pgio_res {
> +	struct nfs4_sequence_res	seq_res;
> +	struct nfs_fattr *	fattr;
> +	struct nfs_writeverf *	verf;		/* used by write */
> +	const struct nfs_server *server;	/* used by write */
> +	__u32			count;
> +	int			eof;		/* used by read */

Same comment as for the previous patch applies here.  Also maybe
this should use a union to overlay the read/write only fields?

