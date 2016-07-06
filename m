Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:57384 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753882AbcGFNw0 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 6 Jul 2016 09:52:26 -0400
Date: Wed, 6 Jul 2016 09:52:23 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Christophe JAILLET <christophe.jaillet@wanadoo.fr>
Cc: jlayton@poochiereds.net, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org, kernel-janitors@vger.kernel.org
Subject: Re: [PATCH 2/2] nfsd: remove extraneous KERN_INFO prefix
Message-ID: <20160706135223.GD18856@fieldses.org>
References: <1467440688-8368-1-git-send-email-christophe.jaillet@wanadoo.fr>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1467440688-8368-1-git-send-email-christophe.jaillet@wanadoo.fr>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Thanks, applying both patches.--b.

On Sat, Jul 02, 2016 at 08:24:48AM +0200, Christophe JAILLET wrote:
> smatch complains about using KERN_INFO as a prefix when calling dprintk
> 
> Signed-off-by: Christophe JAILLET <christophe.jaillet@wanadoo.fr>
> ---
>  fs/nfsd/nfs4state.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
> index bc2173a..ba6b2df 100644
> --- a/fs/nfsd/nfs4state.c
> +++ b/fs/nfsd/nfs4state.c
> @@ -2226,7 +2226,7 @@ gen_callback(struct nfs4_client *clp, struct nfsd4_setclientid *se, struct svc_r
>  out_err:
>  	conn->cb_addr.ss_family = AF_UNSPEC;
>  	conn->cb_addrlen = 0;
> -	dprintk(KERN_INFO "NFSD: this client (clientid %08x/%08x) "
> +	dprintk("NFSD: this client (clientid %08x/%08x) "
>  		"will not receive delegations\n",
>  		clp->cl_clientid.cl_boot, clp->cl_clientid.cl_id);
>  
> -- 
> 2.7.4
