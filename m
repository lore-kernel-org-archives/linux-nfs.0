Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:49316 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752495AbeAWU3A (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 23 Jan 2018 15:29:00 -0500
Date: Tue, 23 Jan 2018 15:28:59 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Arnd Bergmann <arnd@arndb.de>
Cc: Jeff Layton <jlayton@kernel.org>,
        Rasmus Villemoes <rasmus.villemoes@prevas.dk>,
        Chuck Lever <chuck.lever@oracle.com>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        Kinglong Mee <kinglongmee@gmail.com>,
        linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
Subject: Re: [PATCH] [v2] NFSD: hide unused svcxdr_dupstr()
Message-ID: <20180123202859.GA4484@fieldses.org>
References: <20180122210919.1257261-1-arnd@arndb.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20180122210919.1257261-1-arnd@arndb.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Thanks, applied.--b.

On Mon, Jan 22, 2018 at 10:09:12PM +0100, Arnd Bergmann wrote:
> There is now only one caller left for svcxdr_dupstr() and this is inside
> of an #ifdef, so we can get a warning when the option is disabled:
> 
> fs/nfsd/nfs4xdr.c:241:1: error: 'svcxdr_dupstr' defined but not used [-Werror=unused-function]
> 
> This changes the remaining caller to use a nicer IS_ENABLED() check,
> which lets the compiler drop the unused code silently.
> 
> Fixes: e40d99e6183e ("NFSD: Clean up symlink argument XDR decoders")
> Suggested-by: Rasmus Villemoes <rasmus.villemoes@prevas.dk>
> Signed-off-by: Arnd Bergmann <arnd@arndb.de>
> ---
> v2: use IS_ENABLED() instead of an #ifdef
> ---
>  fs/nfsd/nfs4xdr.c | 5 ++---
>  1 file changed, 2 insertions(+), 3 deletions(-)
> 
> diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
> index f51c9cccaf78..86a1a2450376 100644
> --- a/fs/nfsd/nfs4xdr.c
> +++ b/fs/nfsd/nfs4xdr.c
> @@ -455,8 +455,8 @@ nfsd4_decode_fattr(struct nfsd4_compoundargs *argp, u32 *bmval,
>  	}
>  
>  	label->len = 0;
> -#ifdef CONFIG_NFSD_V4_SECURITY_LABEL
> -	if (bmval[2] & FATTR4_WORD2_SECURITY_LABEL) {
> +	if (IS_ENABLED(CONFIG_NFSD_V4_SECURITY_LABEL) &&
> +	    bmval[2] & FATTR4_WORD2_SECURITY_LABEL) {
>  		READ_BUF(4);
>  		len += 4;
>  		dummy32 = be32_to_cpup(p++); /* lfs: we don't use it */
> @@ -476,7 +476,6 @@ nfsd4_decode_fattr(struct nfsd4_compoundargs *argp, u32 *bmval,
>  		if (!label->data)
>  			return nfserr_jukebox;
>  	}
> -#endif
>  	if (bmval[2] & FATTR4_WORD2_MODE_UMASK) {
>  		if (!umask)
>  			goto xdr_error;
> -- 
> 2.9.0
