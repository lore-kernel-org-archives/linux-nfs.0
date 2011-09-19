Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from e5.ny.us.ibm.com ([32.97.182.145]:40760 "EHLO e5.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756294Ab1ISPey (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 19 Sep 2011 11:34:54 -0400
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e5.ny.us.ibm.com (8.14.4/8.13.1) with ESMTP id p8JF479K009634
	for <linux-nfs@vger.kernel.org>; Mon, 19 Sep 2011 11:04:07 -0400
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p8JFYlwC171252
	for <linux-nfs@vger.kernel.org>; Mon, 19 Sep 2011 11:34:48 -0400
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p8JFYJfN005395
	for <linux-nfs@vger.kernel.org>; Mon, 19 Sep 2011 09:34:19 -0600
Date: Mon, 19 Sep 2011 08:34:29 -0700
From: Malahal Naineni <malahal@us.ibm.com>
To: linux-nfs@vger.kernel.org
Cc: Trond.Myklebust@netapp.com
Subject: Re: [PATCH] Check validity of cl_rpcclient in nfs_server_list_show
Message-ID: <20110919153429.GA16725@us.ibm.com>
References: <1315965305-23757-1-git-send-email-malahal@us.ibm.com>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1315965305-23757-1-git-send-email-malahal@us.ibm.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Any comments on the patch below? It is very easy to reproduce the bug
(at least on SLES11 SP1).

Thanks, Malahal.

Malahal Naineni [malahal@us.ibm.com] wrote:
> As soon as the nfs_client gets created, its cl_rpcclient is set to
> ERR_PTR(-EINVAL). The rpc client structure is allocated later. Check
> for the validity of cl_rpcclient before using it.
> 
> Signed-off-by: Malahal Naineni <malahal@us.ibm.com>
> ---
>  fs/nfs/client.c |    4 ++++
>  1 files changed, 4 insertions(+), 0 deletions(-)
> 
> diff --git a/fs/nfs/client.c b/fs/nfs/client.c
> index 5833fbb..ff79e72 100644
> --- a/fs/nfs/client.c
> +++ b/fs/nfs/client.c
> @@ -1867,6 +1867,10 @@ static int nfs_server_list_show(struct seq_file *m, void *v)
>  	/* display one transport per line on subsequent lines */
>  	clp = list_entry(v, struct nfs_client, cl_share_link);
> 
> +	/* Check if the rpc client is initialized */
> +	if (IS_ERR(clp->cl_rpcclient))
> +		return 0;
> +
>  	seq_printf(m, "v%u %s %s %3d %s\n",
>  		   clp->rpc_ops->version,
>  		   rpc_peeraddr2str(clp->cl_rpcclient, RPC_DISPLAY_HEX_ADDR),
> -- 
> 1.7.0.4
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
