Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:41593 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753105AbaACV50 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 3 Jan 2014 16:57:26 -0500
Date: Fri, 3 Jan 2014 16:57:24 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Kinglong Mee <kinglongmee@gmail.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH] NFSD: fix bad length checking for backchannel
Message-ID: <20140103215724.GC5164@fieldses.org>
References: <52B80C36.8020000@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <52B80C36.8020000@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Dec 23, 2013 at 06:11:02PM +0800, Kinglong Mee wrote:
> the length for backchannel checking should be multiplied by sizeof(__be32).

Thanks, applying.

--b.

> 
> Signed-off-by: Kinglong Mee <kinglongmee@gmail.com>
> ---
>  fs/nfsd/nfs4state.c | 9 +++++++--
>  1 file changed, 7 insertions(+), 2 deletions(-)
> 
> diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
> index 105d6fa..05f4db8 100644
> --- a/fs/nfsd/nfs4state.c
> +++ b/fs/nfsd/nfs4state.c
> @@ -1851,6 +1851,11 @@ static __be32 check_forechannel_attrs(struct nfsd4_channel_attrs *ca, struct nfs
>  	return nfs_ok;
>  }
>  
> +#define NFSD_CB_MAX_REQ_SZ	((NFS4_enc_cb_recall_sz + \
> +				 RPC_MAX_HEADER_WITH_AUTH) * sizeof(__be32))
> +#define NFSD_CB_MAX_RESP_SZ	((NFS4_dec_cb_recall_sz + \
> +				 RPC_MAX_REPHEADER_WITH_AUTH) * sizeof(__be32))
> +
>  static __be32 check_backchannel_attrs(struct nfsd4_channel_attrs *ca)
>  {
>  	ca->headerpadsz = 0;
> @@ -1861,9 +1866,9 @@ static __be32 check_backchannel_attrs(struct nfsd4_channel_attrs *ca)
>  	 * less than 1k.  Tighten up this estimate in the unlikely event
>  	 * it turns out to be a problem for some client:
>  	 */
> -	if (ca->maxreq_sz < NFS4_enc_cb_recall_sz + RPC_MAX_HEADER_WITH_AUTH)
> +	if (ca->maxreq_sz < NFSD_CB_MAX_REQ_SZ)
>  		return nfserr_toosmall;
> -	if (ca->maxresp_sz < NFS4_dec_cb_recall_sz + RPC_MAX_REPHEADER_WITH_AUTH)
> +	if (ca->maxresp_sz < NFSD_CB_MAX_RESP_SZ)
>  		return nfserr_toosmall;
>  	ca->maxresp_cached = 0;
>  	if (ca->maxops < 2)
> -- 
> 1.8.4.2
