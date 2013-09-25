Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx11.netapp.com ([216.240.18.76]:5444 "EHLO mx11.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754910Ab3IYVQu convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 25 Sep 2013 17:16:50 -0400
From: "Adamson, Dros" <Weston.Adamson@netapp.com>
To: "Schumaker, Bryan" <Bryan.Schumaker@netapp.com>
CC: "Myklebust, Trond" <Trond.Myklebust@netapp.com>,
        "<linux-nfs@vger.kernel.org>" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] NFS: Give "flavor" an initial value to fix a compile
 warning
Date: Wed, 25 Sep 2013 21:16:49 +0000
Message-ID: <204AA022-3981-4505-BB0D-A7E9C8C769C8@netapp.com>
References: <1380142968-9515-1-git-send-email-bjschuma@netapp.com>
In-Reply-To: <1380142968-9515-1-git-send-email-bjschuma@netapp.com>
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Sep 25, 2013, at 5:02 PM, bjschuma@netapp.com wrote:

> From: Anna Schumaker <bjschuma@netapp.com>
> 
> cd3c993 introduces a compile warning by not assigning an initial value
> to the "flavor" variable.  This could only be a problem if the server
> returns a supported secflavor list of length zero, but it's better to
> fix this before it's ever hit.
> 
> Signed-off-by: Anna Schumaker <bjschuma@netapp.com>

Acked-by: Weston Andros Adamson <dros@netapp.com>

Thanks!
-dros

> ---
> fs/nfs/nfs4proc.c | 2 +-
> 1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
> index f5fe16b..d53d678 100644
> --- a/fs/nfs/nfs4proc.c
> +++ b/fs/nfs/nfs4proc.c
> @@ -7576,7 +7576,7 @@ nfs41_find_root_sec(struct nfs_server *server, struct nfs_fh *fhandle,
> {
> 	int err;
> 	struct page *page;
> -	rpc_authflavor_t flavor;
> +	rpc_authflavor_t flavor = RPC_AUTH_MAXFLAVOR;
> 	struct nfs4_secinfo_flavors *flavors;
> 	struct nfs4_secinfo4 *secinfo;
> 	int i;
> -- 
> 1.8.4
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

