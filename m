Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ea0-f178.google.com ([209.85.215.178]:59602 "EHLO
	mail-ea0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756101Ab3AUOrm (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 21 Jan 2013 09:47:42 -0500
Received: by mail-ea0-f178.google.com with SMTP id a14so2547234eaa.23
        for <linux-nfs@vger.kernel.org>; Mon, 21 Jan 2013 06:47:39 -0800 (PST)
Message-ID: <50FD5507.4010303@tonian.com>
Date: Mon, 21 Jan 2013 16:47:35 +0200
From: Benny Halevy <bhalevy@tonian.com>
MIME-Version: 1.0
To: ycnian@gmail.com
CC: linux-nfs@vger.kernel.org
Subject: Re: [PATCH] pnfsd: Update the reference of nfs4_layout_state properly
References: <1358217471-18458-1-git-send-email-ycnian@gmail.com>
In-Reply-To: <1358217471-18458-1-git-send-email-ycnian@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 2013-01-15 04:37, ycnian@gmail.com wrote:
> From: Yanchuan Nian <ycnian@gmail.com>
> 
> The reference of nfs4_layout_state is set to 1 when creating.
> it isn't necessary to increase the reference again in
> nfs4_process_layout_stateid(), otherwise it will lead to a
> memory leak.
> 
> Signed-off-by: Yanchuan Nian <ycnian@gmail.com>

Thanks. Committing for pnfs-all-3.7 and latest.

Benny

> ---
>  fs/nfsd/nfs4pnfsd.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
> 
> diff --git a/fs/nfsd/nfs4pnfsd.c b/fs/nfsd/nfs4pnfsd.c
> index 2211b50..dd7856c 100644
> --- a/fs/nfsd/nfs4pnfsd.c
> +++ b/fs/nfsd/nfs4pnfsd.c
> @@ -248,10 +248,10 @@ nfs4_process_layout_stateid(struct nfs4_client *clp, struct nfs4_file *fp,
>  			status = nfserr_bad_stateid;
>  			goto out;
>  		}
> +		get_layout_state(ls);
>  	}
>  	status = 0;
>  
> -	get_layout_state(ls);
>  	*lsp = ls;
>  	dprintk("%s: layout stateid=" STATEID_FMT " ref=%d\n", __func__,
>  		STATEID_VAL(&ls->ls_stid.sc_stateid), atomic_read(&ls->ls_ref.refcount));
> 
