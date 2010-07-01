From: Benny Halevy <bhalevy@panasas.com>
Subject: Re: [PATCH] nfsd: fix pointer dereference in dprintk of write verifiers
Date: Thu, 01 Jul 2010 17:38:43 +0300
Message-ID: <4C2CA873.2030009@panasas.com>
References: <1277815752-14948-1-git-send-email-bhalevy@panasas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: linux-nfs@vger.kernel.org
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:29491 "EHLO
	daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1756320Ab0GAOiq (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 1 Jul 2010 10:38:46 -0400
In-Reply-To: <1277815752-14948-1-git-send-email-bhalevy@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Bruce, this is for the pnfsd branch so please ignore for upstream

Benny

On Jun. 29, 2010, 15:49 +0300, Benny Halevy <bhalevy@panasas.com> wrote:
> Signed-off-by: Benny Halevy <bhalevy@panasas.com>
> ---
>  fs/nfsd/nfs4xdr.c |    8 ++++----
>  1 files changed, 4 insertions(+), 4 deletions(-)
> 
> diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
> index 225023c..8b41a9d 100644
> --- a/fs/nfsd/nfs4xdr.c
> +++ b/fs/nfsd/nfs4xdr.c
> @@ -2552,8 +2552,8 @@ nfsd4_encode_commit(struct nfsd4_compoundres *resp, __be32 nfserr, struct nfsd4_
>  		RESERVE_SPACE(8);
>  		WRITEMEM(commit->co_verf.data, 8);
>  		dprintk("NFSD: nfsd4_encode_commit: verifier %x:%x\n",
> -			*(u32 *)(&commit->co_verf.data)[0],
> -			*(u32 *)(&commit->co_verf.data)[1]);
> +			((u32 *)(&commit->co_verf.data))[0],
> +			((u32 *)(&commit->co_verf.data))[1]);
>  
>  		ADJUST_ARGS();
>  	}
> @@ -3127,8 +3127,8 @@ nfsd4_encode_write(struct nfsd4_compoundres *resp, __be32 nfserr, struct nfsd4_w
>  		WRITE32(write->wr_how_written);
>  		WRITEMEM(write->wr_verifier.data, 8);
>  		dprintk("NFSD: nfsd4_encode_write: verifier %x:%x\n",
> -			*(u32 *)(&write->wr_verifier.data)[0],
> -			*(u32 *)(&write->wr_verifier.data)[1]);
> +			((u32 *)(&write->wr_verifier.data))[0],
> +			((u32 *)(&write->wr_verifier.data))[1]);
>  		ADJUST_ARGS();
>  	}
>  	return nfserr;
