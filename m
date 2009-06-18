From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH 28/44] nfsd41: use the maximum operations per compound
	in nfsd4_compoundargs
Date: Thu, 18 Jun 2009 18:14:43 -0400
Message-ID: <20090618221443.GH12234@fieldses.org>
References: <1245115233-7725-1-git-send-email-bhalevy@panasas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: pnfs@linux-nfs.org, linux-nfs@vger.kernel.org
To: Benny Halevy <bhalevy@panasas.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([141.211.133.115]:34491 "EHLO
	pickle.fieldses.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753971AbZFRWOk (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 18 Jun 2009 18:14:40 -0400
In-Reply-To: <1245115233-7725-1-git-send-email-bhalevy@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Jun 16, 2009 at 04:20:33AM +0300, Benny Halevy wrote:
> From: Andy Adamson <andros@netapp.com>
> 
> The size of the nfsd4_op array in nfsd4_compoundargs determines the
> supported maximum number of operations.

This is another one that is a clear straightfoward bugfix to existing
code, so please put it right up at the front of the patch series.

(ALso a comment that more clearly explains the problem would help, say,
like:

	"We're returning NFSD_MAX_OPS_PER_COMPOUND = 16 to 4.1 clients,
	but the limit the server actually enforces (in
	nfsd4_decode_compound) is 8.  Fix the value of
	NFSD_MAX_OPS_PER_COMPOUND to return the correct value to 4.1
	clients."

)

--b.

> 
> Signed-off-by: Andy Adamson <andros@netapp.com>
> Signed-off-by: Benny Halevy <bhalevy@panasas.com>
> ---
>  include/linux/nfsd/state.h |    3 +--
>  include/linux/nfsd/xdr4.h  |    2 +-
>  2 files changed, 2 insertions(+), 3 deletions(-)
> 
> diff --git a/include/linux/nfsd/state.h b/include/linux/nfsd/state.h
> index aea8137..093f165 100644
> --- a/include/linux/nfsd/state.h
> +++ b/include/linux/nfsd/state.h
> @@ -94,8 +94,7 @@ struct nfs4_cb_conn {
>  
>  #define NFSD_MAX_SLOTS_PER_SESSION	16
>  #define NFSD_SLOT_CACHE_SIZE		512
> -/* Maximum number of operations per session compound */
> -#define NFSD_MAX_OPS_PER_COMPOUND	16
> +#define NFSD_MAX_OPS_PER_COMPOUND	8
>  
>  struct nfsd4_slot {
>  	bool	sl_inuse;
> diff --git a/include/linux/nfsd/xdr4.h b/include/linux/nfsd/xdr4.h
> index 84ac4bb..d99c8fe 100644
> --- a/include/linux/nfsd/xdr4.h
> +++ b/include/linux/nfsd/xdr4.h
> @@ -446,7 +446,7 @@ struct nfsd4_compoundargs {
>  	u32				minorversion;
>  	u32				opcnt;
>  	struct nfsd4_op			*ops;
> -	struct nfsd4_op			iops[8];
> +	struct nfsd4_op			iops[NFSD_MAX_OPS_PER_COMPOUND];
>  };
>  
>  struct nfsd4_compoundres {
> -- 
> 1.6.3
> 
