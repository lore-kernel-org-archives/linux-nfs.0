From: Benny Halevy <bhalevy@panasas.com>
Subject: Re: [pnfs] [PATCH 22/22] SQUASHME: nfsd41 drop parens in	nfsd4_is_solo_sequence
 call
Date: Fri, 03 Apr 2009 04:02:17 +0300
Message-ID: <49D56019.7040505@panasas.com>
References: <1238718003-8764-1-git-send-email-andros@netapp.com>	<1238718003-8764-6-git-send-email-andros@netapp.com>	<1238718003-8764-7-git-send-email-andros@netapp.com>	<1238718003-8764-8-git-send-email-andros@netapp.com>	<1238718003-8764-9-git-send-email-andros@netapp.com>	<1238718003-8764-10-git-send-email-andros@netapp.com>	<1238718003-8764-11-git-send-email-andros@netapp.com>	<1238718003-8764-12-git-send-email-andros@netapp.com>	<1238718003-8764-13-git-send-email-andros@netapp.com>	<1238718003-8764-14-git-send-email-andros@netapp.com>	<1238718003-8764-15-git-send-email-andros@netapp.com>	<1238718003-8764-16-git-send-email-andros@netapp.com>	<1238718003-8764-17-git-send-email-andros@netapp.com>	<1238718003-8764-18-git-send-email-andros@netapp.com>	<1238718003-8764-19-git-send-email-an
 dros@netapp.com>	<1238718003-8764-20-git-send-email-andros@netapp.com>	<1238718003-8764-21-git-send-email-andros@netapp.com> <1238718003-8764-22-git-send-email-andros@netapp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: bfields@citi.umich.edu, linux-nfs@vger.kernel.org,
	pnfs@linux-nfs.org
To: andros@netapp.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from gw-ca.panasas.com ([209.116.51.66]:15179 "EHLO
	laguna.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751252AbZDCBCW (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 2 Apr 2009 21:02:22 -0400
In-Reply-To: <1238718003-8764-22-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Apr. 03, 2009, 3:20 +0300, andros@netapp.com wrote:
> From: Andy Adamson <andros@netapp.com>
> 
> March 31 review comments.
> squash into nfsd41: non-page DRC for solo sequence responses
> 
> Signed-off-by: Andy Adamson <andros@netapp.com>
> ---
>  include/linux/nfsd/xdr4.h |    4 ++--
>  1 files changed, 2 insertions(+), 2 deletions(-)
> 
> diff --git a/include/linux/nfsd/xdr4.h b/include/linux/nfsd/xdr4.h
> index 3514f00..03e7025 100644
> --- a/include/linux/nfsd/xdr4.h
> +++ b/include/linux/nfsd/xdr4.h
> @@ -495,8 +495,8 @@ static inline int nfsd4_is_solo_sequence(struct nfsd4_compoundres *resp)
>  
>  static inline int nfsd4_not_cached(struct nfsd4_compoundres *resp)
>  {
> -	return (resp->cstate.slot->sl_cache_entry.ce_cachethis == 0 ||
> -			nfsd4_is_solo_sequence(resp));
> +	return resp->cstate.slot->sl_cache_entry.ce_cachethis == 0 ||

since ce_cachethis is boolean rather than numeric, how about using "!"
rather than "== 0"?

Benny

> +			nfsd4_is_solo_sequence(resp);
>  }
>  
>  #define NFS4_SVC_XDRSIZE		sizeof(struct nfsd4_compoundargs)
