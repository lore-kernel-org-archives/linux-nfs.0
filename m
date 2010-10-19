From: Roman Borisov <ext-roman.borisov@nokia.com>
Subject: Re: [PATCH] nfs: fix unchecked value
Date: Tue, 19 Oct 2010 18:16:35 +0400
Message-ID: <4CBDA843.7030809@nokia.com>
References: <a4f05d53b0912562f2950958831579f14c60dbb8.1286973348.git.ext-roman.borisov@nokia.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Cc: Andy Shevchenko <ext-andriy.shevchenko@nokia.com>,
	Trond.Myklebust@netapp.com, linux-nfs@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx04.teleca.com ([212.92.145.6]:59685 "EHLO mx04.teleca.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751310Ab0JSOYs (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 19 Oct 2010 10:24:48 -0400
In-Reply-To: <a4f05d53b0912562f2950958831579f14c60dbb8.1286973348.git.ext-roman.borisov@nokia.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 10/13/2010 04:54 PM, Roman Borisov wrote:
> Return value of "decode_attr_bitmap()" was not checked;
>
> Signed-off-by: Roman Borisov<ext-roman.borisov@nokia.com>
> ---
>   fs/nfs/nfs4xdr.c |    5 ++++-
>   1 files changed, 4 insertions(+), 1 deletions(-)
>
> diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
> index 6ea5c93..9e9cb40 100644
> --- a/fs/nfs/nfs4xdr.c
> +++ b/fs/nfs/nfs4xdr.c
> @@ -2676,7 +2676,10 @@ out_overflow:
>   static int decode_attr_supported(struct xdr_stream *xdr, uint32_t *bitmap, uint32_t *bitmask)
>   {
>   	if (likely(bitmap[0]&  FATTR4_WORD0_SUPPORTED_ATTRS)) {
> -		decode_attr_bitmap(xdr, bitmask);
> +		int ret;
> +		ret = decode_attr_bitmap(xdr, bitmask);
> +		if (unlikely(ret<  0))
> +			return ret;
>   		bitmap[0]&= ~FATTR4_WORD0_SUPPORTED_ATTRS;
>   	} else
>   		bitmask[0] = bitmask[1] = 0;

Reviewed-by: Andy Shevchenko <ext-andriy.shevchenko@nokia.com>

Hello,

could you please review the patch and send the comments if any

Thanks,
Roman Borisov
