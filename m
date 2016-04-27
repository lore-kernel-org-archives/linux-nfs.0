Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ig0-f196.google.com ([209.85.213.196]:35569 "EHLO
	mail-ig0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751920AbcD0SFj convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 27 Apr 2016 14:05:39 -0400
Received: by mail-ig0-f196.google.com with SMTP id fn8so8186016igb.2
        for <linux-nfs@vger.kernel.org>; Wed, 27 Apr 2016 11:05:39 -0700 (PDT)
Content-Type: text/plain; charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 9.3 \(3124\))
Subject: Re: [PATCH Version 3 9/9] NFS add multiaddr to nfs_show_nfsv4_options
From: Weston Andros Adamson <dros@monkey.org>
In-Reply-To: <1461771370-16375-10-git-send-email-andros@netapp.com>
Date: Wed, 27 Apr 2016 14:05:37 -0400
Cc: Trond Myklebust <trond.myklebust@primarydata.com>,
        Steve Dickson <steved@redhat.com>,
        linux-nfs list <linux-nfs@vger.kernel.org>
Message-Id: <DF9E39F3-AF6A-4459-8747-EBAE3A03E684@monkey.org>
References: <1461771370-16375-1-git-send-email-andros@netapp.com> <1461771370-16375-10-git-send-email-andros@netapp.com>
To: William Andros Adamson <andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


> On Apr 27, 2016, at 11:36 AM, andros@netapp.com wrote:
> 
> From: Andy Adamson <andros@netapp.com>
> 
> Signed-off-by: Andy Adamson <andros@netapp.com>
> ---
> fs/nfs/super.c             | 24 ++++++++++++++++++++++++
> net/sunrpc/xprtmultipath.c |  1 +
> 2 files changed, 25 insertions(+)
> 
> diff --git a/fs/nfs/super.c b/fs/nfs/super.c
> index 70a4fda..1dc1e18 100644
> --- a/fs/nfs/super.c
> +++ b/fs/nfs/super.c
> @@ -605,8 +605,32 @@ static void nfs_show_nfsv4_options(struct seq_file *m, struct nfs_server *nfss,
> 				    int showdefaults)
> {
> 	struct nfs_client *clp = nfss->nfs_client;
> +	struct rpc_clnt *clnt = clp->cl_rpcclient;
> +	struct rpc_xprt_switch *xps;
> +	struct rpc_xprt *pos;
> +	unsigned int nxprts;
> 
> 	seq_printf(m, ",clientaddr=%s", clp->cl_ipaddr);
> +	rcu_read_lock();
> +	xps = xprt_switch_get(rcu_dereference(clnt->cl_xpi.xpi_xpswitch));
> +	pos = xprt_iter_xprt(&clnt->cl_xpi);
> +	if (xps == NULL || pos == NULL)
> +		return;

^^ you need an rcu_read_unlock() before the return.

-dros

> +	nxprts = xps->xps_nxprts;
> +	list_for_each_entry_rcu(pos, &xps->xps_xprt_list, xprt_switch) {
> +		if (nxprts == 0)
> +			break;
> +		if (pos->address_strings[RPC_DISPLAY_ADDR] == NULL)
> +			break;
> +		/* Do not display mount xprt as a multiaddr */
> +		if (pos == rcu_access_pointer(clp->cl_rpcclient->cl_xprt))
> +			continue;
> +		seq_printf(m, ",multiaddr=%s",
> +			pos->address_strings[RPC_DISPLAY_ADDR]);
> +		nxprts--;
> +	}
> +	rcu_read_unlock();
> +	xprt_switch_put(xps);
> }
> #else
> static void nfs_show_nfsv4_options(struct seq_file *m, struct nfs_server *nfss,
> diff --git a/net/sunrpc/xprtmultipath.c b/net/sunrpc/xprtmultipath.c
> index 360f64c..708c22a 100644
> --- a/net/sunrpc/xprtmultipath.c
> +++ b/net/sunrpc/xprtmultipath.c
> @@ -403,6 +403,7 @@ struct rpc_xprt *xprt_iter_xprt(struct rpc_xprt_iter *xpi)
> 	WARN_ON_ONCE(!rcu_read_lock_held());
> 	return xprt_iter_ops(xpi)->xpi_xprt(xpi);
> }
> +EXPORT_SYMBOL_GPL(xprt_iter_xprt);
> 
> static
> struct rpc_xprt *xprt_iter_get_helper(struct rpc_xprt_iter *xpi,
> -- 
> 1.8.3.1
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

