Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:42178 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751219AbdBXUq6 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 24 Feb 2017 15:46:58 -0500
Date: Fri, 24 Feb 2017 15:46:56 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Rasmus Villemoes <linux@rasmusvillemoes.dk>
Cc: Jeff Layton <jlayton@poochiereds.net>, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org
Subject: Re: [PATCH] fs: nfsd: remove superfluous KERN_INFO
Message-ID: <20170224204656.GE26378@fieldses.org>
References: <1487895356-24307-1-git-send-email-linux@rasmusvillemoes.dk>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1487895356-24307-1-git-send-email-linux@rasmusvillemoes.dk>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Thanks, applying.--b.

On Fri, Feb 24, 2017 at 01:15:55AM +0100, Rasmus Villemoes wrote:
> dprintk already provides a KERN_* prefix; this KERN_INFO just shows up
> as some odd characters in the output.
> 
> Signed-off-by: Rasmus Villemoes <linux@rasmusvillemoes.dk>
> ---
>  fs/nfsd/nfs4state.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
> index a0dee8ae9f97..df86e888f833 100644
> --- a/fs/nfsd/nfs4state.c
> +++ b/fs/nfsd/nfs4state.c
> @@ -2281,7 +2281,7 @@ gen_callback(struct nfs4_client *clp, struct nfsd4_setclientid *se, struct svc_r
>  out_err:
>  	conn->cb_addr.ss_family = AF_UNSPEC;
>  	conn->cb_addrlen = 0;
> -	dprintk(KERN_INFO "NFSD: this client (clientid %08x/%08x) "
> +	dprintk("NFSD: this client (clientid %08x/%08x) "
>  		"will not receive delegations\n",
>  		clp->cl_clientid.cl_boot, clp->cl_clientid.cl_id);
>  
> -- 
> 2.1.4
