From: Benny Halevy <bhalevy@panasas.com>
Subject: Re: [PATCH 1/1] net: fix deliver_no_wcard regression on loopback
 device
Date: Thu, 17 Jun 2010 12:01:21 -0400
Message-ID: <4C1A46D1.5080108@panasas.com>
References: <1276693350-1780-1-git-send-email-iisaman@netapp.com> <1276693350-1780-2-git-send-email-iisaman@netapp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: linux-nfs@vger.kernel.org
To: Fred Isaman <iisaman@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-iw0-f174.google.com ([209.85.214.174]:62061 "EHLO
	mail-iw0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756381Ab0FQQBR (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 17 Jun 2010 12:01:17 -0400
Received: by iwn9 with SMTP id 9so6932374iwn.19
        for <linux-nfs@vger.kernel.org>; Thu, 17 Jun 2010 09:01:17 -0700 (PDT)
In-Reply-To: <1276693350-1780-2-git-send-email-iisaman@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Took in at pnfs-all-2.6.35-rc3-2010-06-17

Thanks!

Benny


On Jun. 16, 2010, 9:02 -0400, Fred Isaman <iisaman@netapp.com> wrote:
> From: John Fastabend <john.r.fastabend@intel.com>
> 
> deliver_no_wcard is not being set in skb_copy_header.
> In the skb_cloned case it is not being cleared and
> may cause the skb to be dropped when the loopback device
> pushes it back up the stack.
> 
> Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
> ---
>  net/core/skbuff.c |    1 +
>  1 files changed, 1 insertions(+), 0 deletions(-)
> 
> diff --git a/net/core/skbuff.c b/net/core/skbuff.c
> index 9f07e74..bcf2fa3 100644
> --- a/net/core/skbuff.c
> +++ b/net/core/skbuff.c
> @@ -532,6 +532,7 @@ static void __copy_skb_header(struct sk_buff *new, const struct sk_buff *old)
>  	new->ip_summed		= old->ip_summed;
>  	skb_copy_queue_mapping(new, old);
>  	new->priority		= old->priority;
> +	new->deliver_no_wcard	= old->deliver_no_wcard;
>  #if defined(CONFIG_IP_VS) || defined(CONFIG_IP_VS_MODULE)
>  	new->ipvs_property	= old->ipvs_property;
>  #endif

