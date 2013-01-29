Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:34756 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751647Ab3A2W31 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 29 Jan 2013 17:29:27 -0500
Date: Tue, 29 Jan 2013 17:29:26 -0500
From: bfields <bfields@fieldses.org>
To: majianpeng <majianpeng@gmail.com>
Cc: linux-nfs <linux-nfs@vger.kernel.org>, Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH 2/2] nfsd: Fix memleak.
Message-ID: <20130129222926.GA6219@fieldses.org>
References: <201301291315585633212@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <201301291315585633212@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Tejun, maybe this could be added to your series?

(Or should I just take it without the idr_remove_all()?)

--b.

On Tue, Jan 29, 2013 at 01:16:06PM +0800, majianpeng wrote:
> When free nfs-client, it must free the ->cl_stateids.
> 
> Signed-off-by: Jianpeng Ma <majianpeng@gmail.com>
> ---
>  fs/nfsd/nfs4state.c |    2 ++
>  1 file changed, 2 insertions(+)
> 
> diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
> index ac8ed96..a8309c6 100644
> --- a/fs/nfsd/nfs4state.c
> +++ b/fs/nfsd/nfs4state.c
> @@ -1060,6 +1060,8 @@ free_client(struct nfs4_client *clp)
>  	}
>  	free_svc_cred(&clp->cl_cred);
>  	kfree(clp->cl_name.data);
> +	idr_remove_all(&clp->cl_stateids);
> +	idr_destroy(&clp->cl_stateids);
>  	kfree(clp);
>  }
>  
> -- 
> 1.7.9.5
