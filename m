Return-Path: linux-nfs-owner@vger.kernel.org
Received: from natasha.panasas.com ([67.152.220.90]:54338 "EHLO
	natasha.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753322Ab2E1Qw4 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 28 May 2012 12:52:56 -0400
Message-ID: <4FC3AD59.4050703@panasas.com>
Date: Mon, 28 May 2012 19:52:41 +0300
From: Boaz Harrosh <bharrosh@panasas.com>
MIME-Version: 1.0
To: Benny Halevy <bhalevy@tonian.com>
CC: <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 4/5] pnfsd-lexp: return_on_close config option
References: <4FC3A235.8090908@tonian.com> <1338221387-22621-1-git-send-email-bhalevy@tonian.com>
In-Reply-To: <1338221387-22621-1-git-send-email-bhalevy@tonian.com>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 05/28/2012 07:09 PM, Benny Halevy wrote:

> Signed-off-by: Benny Halevy <bhalevy@tonian.com>
> ---
>  fs/nfsd/Kconfig      |    7 +++++++
>  fs/nfsd/pnfsd_lexp.c |    5 +++++
>  2 files changed, 12 insertions(+), 0 deletions(-)
> 
> diff --git a/fs/nfsd/Kconfig b/fs/nfsd/Kconfig
> index 9d4d79b..f9b3426 100644
> --- a/fs/nfsd/Kconfig
> +++ b/fs/nfsd/Kconfig
> @@ -132,3 +132,10 @@ config PNFSD_LEXP_LAYOUT_SEGMENT_SIZE
>  	  Set simulated layout segment size.
>  
>  	  If unsure, say N.
> +
> +config PNFSD_LEXP_RETURN_ON_CLOSE
> +	bool "Reply to LAYOUTGET with return_on_close set to true"
> +	depends on PNFSD_LOCAL_EXPORT
> +	default false
> +	help
> +	  Set return_on_close response flag.
> diff --git a/fs/nfsd/pnfsd_lexp.c b/fs/nfsd/pnfsd_lexp.c
> index 30d9757..33a724c 100644
> --- a/fs/nfsd/pnfsd_lexp.c
> +++ b/fs/nfsd/pnfsd_lexp.c
> @@ -153,6 +153,11 @@ static int get_stripe_unit(int blocksize)
>  	res->lg_seg.offset = 0;
>  	res->lg_seg.length = NFS4_MAX_UINT64;
>  #endif  /* CONFIG_PNFSD_LEXP_LAYOUT_SEGMENTS */
> +#ifdef     CONFIG_PNFSD_LEXP_RETURN_ON_CLOSE
> +	res->lg_return_on_close = true;
> +#else   /* CONFIG_PNFSD_LEXP_RETURN_ON_CLOSE */
> +	res->lg_return_on_close = false;


Back to my original question. With current code this case is a BUG.
It will leak layouts and therefore file-reference in case of a layout-get
with open-state ID. 

So I suggest hardcoding to true until such time that we actually can
support it

Boaz

> +#endif  /* CONFIG_PNFSD_LEXP_RETURN_ON_CLOSE */
>  
>  	layout = kzalloc(sizeof(*layout), GFP_KERNEL);
>  	if (layout == NULL) {


