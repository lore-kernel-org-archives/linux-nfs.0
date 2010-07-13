Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([18.85.46.34]:51247 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752449Ab0GMBNJ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 12 Jul 2010 21:13:09 -0400
Date: Mon, 12 Jul 2010 21:13:06 -0400
From: Christoph Hellwig <hch@infradead.org>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: Christoph Hellwig <hch@infradead.org>, linux-nfs@vger.kernel.org
Subject: Re: [PATCH 1/3] NFS: Fix up the fsync code
Message-ID: <20100713011306.GA364@infradead.org>
References: <20100712220932.20019.21170.stgit@heimdal.trondhjem.org>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20100712220932.20019.21170.stgit@heimdal.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

>  	/* Flush writes to the server and return any errors */
> -	return nfs_do_fsync(ctx, inode);
> +	return vfs_fsync(file, 0);

Either the argument to vfs_fsync or the comment needs some changes.
datasync = 0 means we don't just flush writes but also metadata.  I
don't know enough about the NFS CTO guarantees to figure which one you
actually want.

