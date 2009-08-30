From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH 1/5] NFS: combine nfs_kill_super() and nfs4_kill_super()
Date: Sun, 30 Aug 2009 12:42:29 -0400
Message-ID: <20090830164229.GA32025@infradead.org>
References: <20090830162211.3652.14638.stgit@matisse.1015granger.net> <20090830163432.3652.437.stgit@matisse.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: trond.myklebust@fys.uio.no, linux-nfs@vger.kernel.org
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([18.85.46.34]:34443 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753452AbZH3Qmb (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 30 Aug 2009 12:42:31 -0400
In-Reply-To: <20090830163432.3652.437.stgit-RytpoXr2tKZ9HhUboXbp9zCvJB+x5qRC@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sun, Aug 30, 2009 at 12:34:33PM -0400, Chuck Lever wrote:
> +static void nfs_kill_super(struct super_block *sb)
>  {
> +	struct nfs_server *server = NFS_SB(sb);
> +
> +	dprintk("--> %s\n", __func__);
> +
> +#ifdef CONFIG_NFS_V4
> +	if (server->nfs_client->rpc_ops->version == 4) {
> +		nfs_super_return_all_delegations(sb);
> +		nfs4_renewd_prepare_shutdown(server);
> +	}
> +#endif	/* CONFIG_NFS_V4 */
>  
>  	bdi_unregister(&server->backing_dev_info);

This was previously not done for nfs4.  If it is a bug-fixed that
should be documented in the patch description, and if not it needs
to be changed.

