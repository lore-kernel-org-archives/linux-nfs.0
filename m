Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:4785 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751372Ab1B1Vjo convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 28 Feb 2011 16:39:44 -0500
Subject: Re: [PATCH] zero out delegation in the inode after it has been
 returned
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: Jim Rees <rees@umich.edu>
Cc: Benny Halevy <bhalevy@panasas.com>, linux-nfs@vger.kernel.org,
        peter honeyman <honey@citi.umich.edu>
In-Reply-To: <20110228213103.GA1256@merit.edu>
References: <20110228213103.GA1256@merit.edu>
Content-Type: text/plain; charset="UTF-8"
Date: Mon, 28 Feb 2011 16:39:04 -0500
Message-ID: <1298929144.8564.44.camel@heimdal.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Mon, 2011-02-28 at 16:31 -0500, Jim Rees wrote: 
> Signed-off-by: Jim Rees <rees@umich.edu>
> ---
>  fs/nfs/delegation.c |    2 ++
>  1 files changed, 2 insertions(+), 0 deletions(-)
> 
> diff --git a/fs/nfs/delegation.c b/fs/nfs/delegation.c
> index bbbc6bf..5bc4f7e 100644
> --- a/fs/nfs/delegation.c
> +++ b/fs/nfs/delegation.c
> @@ -176,9 +176,11 @@ void nfs_inode_reclaim_delegation(struct inode *inode, struct rpc_cred *cred,
>  
>  static int nfs_do_return_delegation(struct inode *inode, struct nfs_delegation *delegation, int issync)
>  {
> +	struct nfs_inode *nfsi = NFS_I(inode);
>  	int res = 0;
>  
>  	res = nfs4_proc_delegreturn(inode, delegation->cred, &delegation->stateid, issync);
> +	rcu_assign_pointer(nfsi->delegation, NULL);
>  	nfs_free_delegation(delegation);
>  	return res;
>  }

Big NACK...

nfsi->delegation is released under the appropriate locks well before we
get here. The above line is 100% racy and risks clobbering any new
delegation that has been issued after the delegreturn completed...

Trond
-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com

