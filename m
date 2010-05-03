From: " J. Bruce Fields" <bfields@citi.umich.edu>
Subject: Re: [RFC 1/3] nfsd4: use local variable in
	nfs4svc_encode_compoundres
Date: Mon, 3 May 2010 18:37:18 -0400
Message-ID: <20100503223717.GF11904@fieldses.org>
References: <4BDEF641.4020507@panasas.com> <1272904293-27080-1-git-send-email-bhalevy@panasas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org
To: Benny Halevy <bhalevy@panasas.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:41863 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755246Ab0ECWhS (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 3 May 2010 18:37:18 -0400
In-Reply-To: <1272904293-27080-1-git-send-email-bhalevy@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, May 03, 2010 at 07:31:33PM +0300, Benny Halevy wrote:
> 'cs' is already computed, re-use it.

Thanks, applied.

--b.

> 
> Signed-off-by: Benny Halevy <bhalevy@panasas.com>
> ---
>  fs/nfsd/nfs4xdr.c |    4 ++--
>  1 files changed, 2 insertions(+), 2 deletions(-)
> 
> diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
> index b04583c..19ff5a3 100644
> --- a/fs/nfsd/nfs4xdr.c
> +++ b/fs/nfsd/nfs4xdr.c
> @@ -3311,9 +3311,9 @@ nfs4svc_encode_compoundres(struct svc_rqst *rqstp, __be32 *p, struct nfsd4_compo
>  		if (cs->status != nfserr_replay_cache) {
>  			nfsd4_store_cache_entry(resp);
>  			dprintk("%s: SET SLOT STATE TO AVAILABLE\n", __func__);
> -			resp->cstate.slot->sl_inuse = false;
> +			cs->slot->sl_inuse = false;
>  		}
> -		nfsd4_put_session(resp->cstate.session);
> +		nfsd4_put_session(cs->session);
>  	}
>  	return 1;
>  }
> -- 
> 1.6.3.3
> 
