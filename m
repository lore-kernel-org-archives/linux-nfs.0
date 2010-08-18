Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:32064 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752997Ab0HRSH5 convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 18 Aug 2010 14:07:57 -0400
Subject: Re: [PATCH 1/1] nfs41: prevent exchange_id from sending
 server-only flag
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: andros@netapp.com
Cc: linux-nfs@vger.kernel.org, Fred Isaman <iisaman@citi.umich.edu>,
        Benny Halevy <bhalevy@panasas.com>
In-Reply-To: <1282153092-7228-1-git-send-email-andros@netapp.com>
References: <1282153092-7228-1-git-send-email-andros@netapp.com>
Content-Type: text/plain; charset="UTF-8"
Date: Wed, 18 Aug 2010 14:07:53 -0400
Message-ID: <1282154873.8540.69.camel@heimdal.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Wed, 2010-08-18 at 13:38 -0400, andros@netapp.com wrote:
> From: Fred Isaman <iisaman@citi.umich.edu>
> 
> clp->cl_exchange_flags is used both for client output and server input.
> This causes problems in certain recovery situations, when the server
> has sent back EXCHGID4_FLAG_CONFIRMED_R, causing the client to erroneously
> use the flag in future EXCHANGE_ID requests.
> 
> Signed-off-by: Fred Isaman <iisaman@citi.umich.edu>
> Signed-off-by: Benny Halevy <bhalevy@panasas.com>
> ---
>  fs/nfs/nfs4proc.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
> 
> diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
> index 198d51d..e5fea95 100644
> --- a/fs/nfs/nfs4proc.c
> +++ b/fs/nfs/nfs4proc.c
> @@ -4427,7 +4427,7 @@ int nfs4_proc_exchange_id(struct nfs_client *clp, struct rpc_cred *cred)
>  	nfs4_verifier verifier;
>  	struct nfs41_exchange_id_args args = {
>  		.client = clp,
> -		.flags = clp->cl_exchange_flags,
> +		.flags = clp->cl_exchange_flags & ~EXCHGID4_FLAG_CONFIRMED_R,
>  	};
>  	struct nfs41_exchange_id_res res = {
>  		.client = clp,

Wait... This is utterly silly...

So we start be passing in clp->cl_exchange_flags == 0, then the server
modifies that to some other value, and then from there on we always use
the latest value of clp->cl_exchange_flags that resulted from the last
call to EXCHANGE_ID????

We should be setting .flags according to the client capabilities, not
according to the server reply...

IOW:
args.flags = EXCHGID4_FLAG_SUPP_MOVED_REFER | EXCHGID4_FLAG_USE_NON_PNFS;


