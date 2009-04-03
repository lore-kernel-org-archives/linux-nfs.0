From: Benny Halevy <bhalevy@panasas.com>
Subject: Re: [pnfs] [PATCH 21/22] SQUASHME: nfsd41 change nfsd4_not_cached
 return
Date: Fri, 03 Apr 2009 03:34:40 +0300
Message-ID: <49D559A0.6090907@panasas.com>
References: <1238718003-8764-1-git-send-email-andros@netapp.com>	<1238718003-8764-5-git-send-email-andros@netapp.com>	<1238718003-8764-6-git-send-email-andros@netapp.com>	<1238718003-8764-7-git-send-email-andros@netapp.com>	<1238718003-8764-8-git-send-email-andros@netapp.com>	<1238718003-8764-9-git-send-email-andros@netapp.com>	<1238718003-8764-10-git-send-email-andros@netapp.com>	<1238718003-8764-11-git-send-email-andros@netapp.com>	<1238718003-8764-12-git-send-email-andros@netapp.com>	<1238718003-8764-13-git-send-email-andros@netapp.com>	<1238718003-8764-14-git-send-email-andros@netapp.com>	<1238718003-8764-15-git-send-email-andros@netapp.com>	<1238718003-8764-16-git-send-email-andros@netapp.com>	<1238718003-8764-17-git-send-email-andros@netapp.com>	<1238718003-8764-18-git-send-email-and
 ros@netapp.com>	<1238718003-8764-19-git-send-email-andros@netapp.com>	<1238718003-8764-20-git-send-email-andros@netapp.com> <1238718003-8764-21-git-send-email-andros@netapp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: bfields@citi.umich.edu, linux-nfs@vger.kernel.org,
	pnfs@linux-nfs.org
To: andros@netapp.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from gw-ca.panasas.com ([209.116.51.66]:32534 "EHLO
	laguna.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754714AbZDCAeo (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 2 Apr 2009 20:34:44 -0400
In-Reply-To: <1238718003-8764-21-git-send-email-andros@netapp.com>
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
>  include/linux/nfsd/xdr4.h |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
> 
> diff --git a/include/linux/nfsd/xdr4.h b/include/linux/nfsd/xdr4.h
> index 0352863..3514f00 100644
> --- a/include/linux/nfsd/xdr4.h
> +++ b/include/linux/nfsd/xdr4.h
> @@ -493,7 +493,7 @@ static inline int nfsd4_is_solo_sequence(struct nfsd4_compoundres *resp)
>  	return args->opcnt == 1;
>  }
>  
> -static inline u32 nfsd4_not_cached(struct nfsd4_compoundres *resp)
> +static inline int nfsd4_not_cached(struct nfsd4_compoundres *resp)

Here too, returning bool is more appropriate.

Benny

>  {
>  	return (resp->cstate.slot->sl_cache_entry.ce_cachethis == 0 ||
>  			nfsd4_is_solo_sequence(resp));
