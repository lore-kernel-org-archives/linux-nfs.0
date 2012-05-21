Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-wg0-f44.google.com ([74.125.82.44]:46084 "EHLO
	mail-wg0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751508Ab2EUPKf (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 21 May 2012 11:10:35 -0400
Received: by wgbdr13 with SMTP id dr13so5090545wgb.1
        for <linux-nfs@vger.kernel.org>; Mon, 21 May 2012 08:10:34 -0700 (PDT)
Message-ID: <4FBA5AE5.8080707@tonian.com>
Date: Mon, 21 May 2012 18:10:29 +0300
From: Benny Halevy <bhalevy@tonian.com>
MIME-Version: 1.0
To: Boaz Harrosh <bharrosh@panasas.com>
CC: Andy Adamson <andros@netapp.com>, NFS list <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] SQUASHME: pnfsd-lexp: Fix compiler warning when CONFIG_SUNRPC_DEBUG
 is not set
References: <4FBA1BD4.7090303@panasas.com>
In-Reply-To: <4FBA1BD4.7090303@panasas.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 2012-05-21 13:41, Boaz Harrosh wrote:
> 
> Fix "Unused variable" warning if CONFIG_SUNRPC_DEBUG is not set
> 

Merged, thanks!

> Signed-off-by: Boaz Harrosh <boazharrosh@gmail.com>
> ---
> git diff --stat -p -M fs/nfsd/nfs4pnfsds.c
>  fs/nfsd/nfs4pnfsds.c | 3 +--
>  1 file changed, 1 insertion(+), 2 deletions(-)
> 
> diff --git a/fs/nfsd/nfs4pnfsds.c b/fs/nfsd/nfs4pnfsds.c
> index 2732f20..ab67523 100644
> --- a/fs/nfsd/nfs4pnfsds.c
> +++ b/fs/nfsd/nfs4pnfsds.c
> @@ -170,10 +170,9 @@ static int stateid_hashval(stateid_t *stidp)
>  	hashval = stateid_hashval(stidp);
>  	list_for_each_entry(local, &ds_stid_hashtbl[hashval], ds_hash)
>  		if (!memcmp(&local->ds_stid.si_opaque, &stidp->si_opaque, sizeof(stidp->si_opaque))) {
> -			stateid_t *sid = &local->ds_stid;
>  			dprintk("NFSD: %s <-- %p ds_flags %lx " STATEID_FMT "\n",
>  				__func__, local, local->ds_flags,
> -				STATEID_VAL(sid));
> +				STATEID_VAL(&local->ds_stid));
>  			return local;
>  		}
>  	return NULL;
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
