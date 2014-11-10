Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:58449 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751138AbaKJWVV (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 10 Nov 2014 17:21:21 -0500
Date: Mon, 10 Nov 2014 17:21:10 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Christoph Hellwig <hch@lst.de>
Cc: Trond Myklebust <trond.myklebust@primarydata.com>,
        linux-nfs@vger.kernel.org
Subject: Re: [PATCH 1/2] nfsd: correctly define v4.2 support attributes
Message-ID: <20141110222109.GL32702@fieldses.org>
References: <1415448664-25815-1-git-send-email-hch@lst.de>
 <1415448664-25815-2-git-send-email-hch@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1415448664-25815-2-git-send-email-hch@lst.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sat, Nov 08, 2014 at 01:11:03PM +0100, Christoph Hellwig wrote:
> Even when security labels are disabled we support at least the same
> attributes as v4.1.
> 
> Signed-off-by: Christoph Hellwig <hch@lst.de>
> ---
>  fs/nfsd/nfsd.h | 9 ++++++---
>  1 file changed, 6 insertions(+), 3 deletions(-)
> 
> diff --git a/fs/nfsd/nfsd.h b/fs/nfsd/nfsd.h
> index 747f3b95..43b6a36 100644
> --- a/fs/nfsd/nfsd.h
> +++ b/fs/nfsd/nfsd.h
> @@ -335,12 +335,15 @@ void		nfsd_lockd_shutdown(void);
>  	(NFSD4_SUPPORTED_ATTRS_WORD2 | FATTR4_WORD2_SUPPATTR_EXCLCREAT)
>  
>  #ifdef CONFIG_NFSD_V4_SECURITY_LABEL
> -#define NFSD4_2_SUPPORTED_ATTRS_WORD2 \
> -	(NFSD4_1_SUPPORTED_ATTRS_WORD2 | FATTR4_WORD2_SECURITY_LABEL)
> +#define NFSD4_2_SECURITY_ATTRS		FATTR4_WORD2_SECURITY_LABEL
>  #else
> -#define NFSD4_2_SUPPORTED_ATTRS_WORD2 0
> +#define NFSD4_2_SECURITY_ATTRS		9

I'm assuming that 9 was meant to be a 0.

--b.

>  #endif
>  
> +#define NFSD4_2_SUPPORTED_ATTRS_WORD2 \
> +	(NFSD4_1_SUPPORTED_ATTRS_WORD2 | \
> +	NFSD4_2_SECURITY_ATTRS)
> +
>  static inline u32 nfsd_suppattrs0(u32 minorversion)
>  {
>  	return minorversion ? NFSD4_1_SUPPORTED_ATTRS_WORD0
> -- 
> 1.9.1
> 
