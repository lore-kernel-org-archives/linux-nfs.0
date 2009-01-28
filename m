From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH] : Fix compilation warnings in fs/nfsd/nfs4state.c
Date: Wed, 28 Jan 2009 14:11:04 -0500
Message-ID: <20090128191104.GA6276@fieldses.org>
References: <ea11fea30901272238t4d11ba15t8bac4cd702ea7440@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: kmsmith@umich.edu, kandros@umich.edu, linux-nfs@vger.kernel.org,
	akpm@linux-foundation.org
To: Manish Katiyar <mkatiyar@gmail.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([141.211.133.115]:40876 "EHLO
	pickle.fieldses.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751049AbZA1TLG (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 28 Jan 2009 14:11:06 -0500
In-Reply-To: <ea11fea30901272238t4d11ba15t8bac4cd702ea7440-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Jan 28, 2009 at 12:08:19PM +0530, Manish Katiyar wrote:
> Below patch removes the following warning ;-
> fs/nfsd/nfs4state.c:1657: warning: unused variable 'flp'

I don't believe we want to support a .config with NFS or NFSD turned on
but CONFIG_FILE_LOCKING off.

--b.

> 
> 
> Signed-off-by: Manish Katiyar <mkatiyar@gmail.com>
> ---
>  fs/nfsd/nfs4state.c |    5 ++++-
>  1 files changed, 4 insertions(+), 1 deletions(-)
> 
> diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
> index 69e98ca..2903589 100644
> --- a/fs/nfsd/nfs4state.c
> +++ b/fs/nfsd/nfs4state.c
> @@ -1654,7 +1654,10 @@ nfs4_open_delegation(struct svc_fh *fh, struct
> nfsd4_open *open, struct nfs4_sta
>  	struct nfs4_delegation *dp;
>  	struct nfs4_stateowner *sop = stp->st_stateowner;
>  	struct nfs4_callback *cb = &sop->so_client->cl_callback;
> -	struct file_lock fl, *flp = &fl;
> +	struct file_lock fl;
> +#ifdef CONFIG_FILE_LOCKING
> +	struct file_lock *flp = &fl;
> +#endif
>  	int status, flag = 0;
> 
>  	flag = NFS4_OPEN_DELEGATE_NONE;
> -- 
> 1.5.4.3
> 
> 
> Thanks -
> Manish
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
