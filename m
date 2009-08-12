From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: Re: [PATCH RFC 03/13] sunrpc: introduce 32-bit Xcoding helpers
Date: Wed, 12 Aug 2009 16:12:51 -0400
Message-ID: <1250107971.5973.1.camel@heimdal.trondhjem.org>
References: <4A82DC7B.3090600@panasas.com>
	 <1250090511-9605-1-git-send-email-bhalevy@panasas.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: linux-nfs@vger.kernel.org
To: Benny Halevy <bhalevy@panasas.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:25807 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754361AbZHLUNI (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 12 Aug 2009 16:13:08 -0400
In-Reply-To: <1250090511-9605-1-git-send-email-bhalevy@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, 2009-08-12 at 18:21 +0300, Benny Halevy wrote:
> To be used instead of WRITE32/READ32.
> 
> Signed-off-by: Benny Halevy <bhalevy@panasas.com>
> ---
>  include/linux/sunrpc/xdr.h |   17 +++++++++++++++++
>  1 files changed, 17 insertions(+), 0 deletions(-)
> 
> diff --git a/include/linux/sunrpc/xdr.h b/include/linux/sunrpc/xdr.h
> index 7da466b..466ea12 100644
> --- a/include/linux/sunrpc/xdr.h
> +++ b/include/linux/sunrpc/xdr.h
> @@ -112,6 +112,23 @@ static inline __be32 *xdr_encode_array(__be32 *p, const void *s, unsigned int le
>  }
>  
>  /*
> + * Xcode 32bit quantities
> + */
> +static inline __be32 *
> +xdr_encode_int(__be32 *p, __u32 val)
> +{
> +	*p = cpu_to_be32(val);
> +	return p + 1;
> +}
> +
> +static inline __be32 *
> +xdr_decode_int(__be32 *p, __u32 *valp)
> +{
> +	*valp = be32_to_cpu(*p);
> +	return p + 1;
> +}
> +
> +/*
>   * Decode 64bit quantities (NFSv3 support)
>   */
>  static inline __be32 *

These two functions are completely superfluous. Please just open code
trivial cases like these...

Cheers
  Trond
-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com
