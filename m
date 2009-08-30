From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [PATCH 1/5] NFS: combine nfs_kill_super() and nfs4_kill_super()
Date: Sun, 30 Aug 2009 12:59:53 -0400
Message-ID: <1251651593.12486.14.camel@heimdal.trondhjem.org>
References: <20090830162211.3652.14638.stgit@matisse.1015granger.net>
	 <20090830163432.3652.437.stgit@matisse.1015granger.net>
	 <20090830164229.GA32025@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Chuck Lever <chuck.lever@oracle.com>, linux-nfs@vger.kernel.org
To: Christoph Hellwig <hch@infradead.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-out1.uio.no ([129.240.10.57]:41338 "EHLO mail-out1.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753452AbZH3Q77 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 30 Aug 2009 12:59:59 -0400
In-Reply-To: <20090830164229.GA32025@infradead.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sun, 2009-08-30 at 12:42 -0400, Christoph Hellwig wrote:
> On Sun, Aug 30, 2009 at 12:34:33PM -0400, Chuck Lever wrote:
> > +static void nfs_kill_super(struct super_block *sb)
> >  {
> > +	struct nfs_server *server = NFS_SB(sb);
> > +
> > +	dprintk("--> %s\n", __func__);
> > +
> > +#ifdef CONFIG_NFS_V4
> > +	if (server->nfs_client->rpc_ops->version == 4) {
> > +		nfs_super_return_all_delegations(sb);
> > +		nfs4_renewd_prepare_shutdown(server);
> > +	}
> > +#endif	/* CONFIG_NFS_V4 */
> >  
> >  	bdi_unregister(&server->backing_dev_info);
> 
> This was previously not done for nfs4.  If it is a bug-fixed that
> should be documented in the patch description, and if not it needs
> to be changed.

It has always been done, but it was in a separate function
(nfs4_kill_super()). I don't really see what we gain by inlining it into
nfs_kill_super..

Also, I'm concerned about the growth of "if (version == X)" type
constructs. We shouldn't be looking at the version number in order to
figure out whether or not we're holding delegations, or whether or not a
particular daemon thread is running.
AFAICS, in this case it should in any case be safe to call
nfs_super_return_all_delegations() (as long as CONFIG_NFS_V4 is defined
- that we might want to fix). Ditto for nfs4_renewd_prepare_shutdown().

Cheers
  Trond

