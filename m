Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from e6.ny.us.ibm.com ([32.97.182.146]:53494 "EHLO e6.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751871Ab1I0Qnj (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 27 Sep 2011 12:43:39 -0400
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e6.ny.us.ibm.com (8.14.4/8.13.1) with ESMTP id p8RGJSkg010736
	for <linux-nfs@vger.kernel.org>; Tue, 27 Sep 2011 12:19:28 -0400
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p8RGhb6K258452
	for <linux-nfs@vger.kernel.org>; Tue, 27 Sep 2011 12:43:37 -0400
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p8RGhbJu006546
	for <linux-nfs@vger.kernel.org>; Tue, 27 Sep 2011 13:43:37 -0300
Date: Tue, 27 Sep 2011 09:43:35 -0700
From: Malahal Naineni <malahal@us.ibm.com>
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>, linux-nfs@vger.kernel.org
Subject: Re: [PATCH] Check validity of cl_rpcclient in nfs_server_list_show
Message-ID: <20110927164335.GA19331@us.ibm.com>
References: <1315965305-23757-1-git-send-email-malahal@us.ibm.com>
 <20110919153429.GA16725@us.ibm.com>
 <2E1EB2CF9ED1CB4AA966F0EB76EAB4430B35626A@SACMVEXC2-PRD.hq.netapp.com>
 <20110921002714.GA31689@us.ibm.com>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20110921002714.GA31689@us.ibm.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Malahal Naineni [malahal@us.ibm.com] wrote:
> Myklebust, Trond [Trond.Myklebust@netapp.com] wrote:
> > Shouldn't we just skip all nfs_client structures that don't have
> > cl_cons_state set to NFS_CS_READY? I see no reason to display their
> > properties even if they have got far enough as to create an rpc client.
> > 
> > Cheers
> >   Trond
> 
> Sounds good to me. Here is a tested patch.

Any comments on this one?

Thanks, Malahal.

> 
> 
> As soon as the nfs_client gets created, its cl_rpcclient is set to
> ERR_PTR(-EINVAL). The rpc client structure is allocated later. Check
> if the client is ready before using the cl_rpcclient pointer.
> 
> Signed-off-by: Malahal Naineni <malahal@us.ibm.com>
> ---
>  fs/nfs/client.c |    4 ++++
>  1 files changed, 4 insertions(+), 0 deletions(-)
> 
> diff --git a/fs/nfs/client.c b/fs/nfs/client.c
> index 5833fbb..a54c45e 100644
> --- a/fs/nfs/client.c
> +++ b/fs/nfs/client.c
> @@ -1867,6 +1867,10 @@ static int nfs_server_list_show(struct seq_file *m, void *v)
>  	/* display one transport per line on subsequent lines */
>  	clp = list_entry(v, struct nfs_client, cl_share_link);
> 
> +	/* Check if the client is initialized */
> +	if (clp->cl_cons_state != NFS_CS_READY)
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
> 
