Return-Path: linux-nfs-owner@vger.kernel.org
Received: from bombadil.infradead.org ([198.137.202.9]:58473 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753617AbaIIP7l (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 9 Sep 2014 11:59:41 -0400
Date: Tue, 9 Sep 2014 08:59:41 -0700
From: Christoph Hellwig <hch@infradead.org>
To: Anna Schumaker <Anna.Schumaker@netapp.com>
Cc: Trond.Myklebust@primarydata.com, linux-nfs@vger.kernel.org
Subject: Re: [PATCH 1/2] nfs: Add ALLOCATE support
Message-ID: <20140909155941.GA6185@infradead.org>
References: <1410274196-30841-1-git-send-email-Anna.Schumaker@Netapp.com>
 <1410274196-30841-2-git-send-email-Anna.Schumaker@Netapp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1410274196-30841-2-git-send-email-Anna.Schumaker@Netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Sep 09, 2014 at 10:49:55AM -0400, Anna Schumaker wrote:
> +	struct nfs_server *server = NFS_SERVER(inode);
> +	long ret = -EOPNOTSUPP;
> +
> +	if (server->caps & NFS_CAP_ALLOCATE) {
> +		ret = nfs42_proc_allocate(inode, stateid, offset, len);
> +		if (ret == -EOPNOTSUPP)
> +			server->caps &= ~NFS_CAP_ALLOCATE;
> +	}

So if we want clients to allow this sort of optimization we can't return
NFSERR_PNOTSUPP if it's called on the "wrong" kind of file.  Back to the
drawing board on that one.

