Return-Path: linux-nfs-owner@vger.kernel.org
Received: from bombadil.infradead.org ([198.137.202.9]:55897 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752264AbaCROJn (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 18 Mar 2014 10:09:43 -0400
Date: Tue, 18 Mar 2014 07:09:42 -0700
From: Christoph Hellwig <hch@infradead.org>
To: Anna Schumaker <schumaker.anna@gmail.com>
Cc: Trond Myklebust <trond.myklebust@primarydata.com>,
        linux-nfs@vger.kernel.org
Subject: Re: [PATCH 1/2] nfs: remove ->write_pageio_init from rpc ops
Message-ID: <20140318140942.GB11672@infradead.org>
References: <20140318112825.GA22359@infradead.org>
 <532840E8.5090804@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <532840E8.5090804@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

> > +	struct nfs_server *server = NFS_SERVER(inode);
> > +	const struct nfs_pageio_ops *pg_ops = &nfs_pageio_write_ops;
> > +
> > +#if IS_ENABLED(CONFIG_NFS_V4)
> > +	if (server->pnfs_curr_ld)
> > +		pg_ops = server->pnfs_curr_ld->pg_write_ops;
> > +#endif
> > +	nfs_pageio_init(pgio, inode, pg_ops, compl_ops, server->wsize, ioflags);
> >  }
> 
> I thought it was bad style to put a #ifdef in the middle of a function, which is why we have so many noop functions in the rest of the code.  Should this be done with a select_compl_ops() function instead?

I don't think it's much of a problem for a small and readable function
with a single ifdef.  And we'd need one helper for read and write each,
which would make the code much harder to read.  Still better than what's
there currently, though.

The other option would be to simply always have the pnfs_curr_ld field
in the server structure and remove the ifdef entirely.
