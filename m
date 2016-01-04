Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:53009 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752012AbcADWtI (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 4 Jan 2016 17:49:08 -0500
Date: Mon, 4 Jan 2016 17:49:07 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Julia Lawall <Julia.Lawall@lip6.fr>
Cc: kernel-janitors@vger.kernel.org, Jeff Layton <jlayton@poochiereds.net>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org
Subject: Re: [PATCH] lockd: constify nlmsvc_binding structure
Message-ID: <20160104224907.GG30315@fieldses.org>
References: <1450905913-657-1-git-send-email-Julia.Lawall@lip6.fr>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1450905913-657-1-git-send-email-Julia.Lawall@lip6.fr>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Dec 23, 2015 at 10:25:13PM +0100, Julia Lawall wrote:
> The nlmsvc_binding structure is never modified, so declare it as const.
> 
> Done with the help of Coccinelle.
> 
> Signed-off-by: Julia Lawall <Julia.Lawall@lip6.fr>
> 
> ---
> 
> This assumes that whoever takes advantage of the EXPORT_SYMBOL will also
> not want to write in the fields.  Is that reasonable?

Looks right to me, thanks, applying.--b.

> 
>  fs/lockd/svc.c             |    2 +-
>  fs/nfsd/lockd.c            |    2 +-
>  include/linux/lockd/bind.h |    2 +-
>  3 files changed, 3 insertions(+), 3 deletions(-)
> 
> diff --git a/fs/lockd/svc.c b/fs/lockd/svc.c
> index 44d18ad..0c1a699 100644
> --- a/fs/lockd/svc.c
> +++ b/fs/lockd/svc.c
> @@ -48,7 +48,7 @@
>  
>  static struct svc_program	nlmsvc_program;
>  
> -struct nlmsvc_binding *		nlmsvc_ops;
> +const struct nlmsvc_binding	*nlmsvc_ops;
>  EXPORT_SYMBOL_GPL(nlmsvc_ops);
>  
>  static DEFINE_MUTEX(nlmsvc_mutex);
> diff --git a/include/linux/lockd/bind.h b/include/linux/lockd/bind.h
> index 4d24d64..140edab6 100644
> --- a/include/linux/lockd/bind.h
> +++ b/include/linux/lockd/bind.h
> @@ -29,7 +29,7 @@ struct nlmsvc_binding {
>  	void			(*fclose)(struct file *);
>  };
>  
> -extern struct nlmsvc_binding *	nlmsvc_ops;
> +extern const struct nlmsvc_binding *nlmsvc_ops;
>  
>  /*
>   * Similar to nfs_client_initdata, but without the NFS-specific
> diff --git a/fs/nfsd/lockd.c b/fs/nfsd/lockd.c
> index 77e7a5c..1a03bc3 100644
> --- a/fs/nfsd/lockd.c
> +++ b/fs/nfsd/lockd.c
> @@ -58,7 +58,7 @@ nlm_fclose(struct file *filp)
>  	fput(filp);
>  }
>  
> -static struct nlmsvc_binding	nfsd_nlm_ops = {
> +static const struct nlmsvc_binding nfsd_nlm_ops = {
>  	.fopen		= nlm_fopen,		/* open file for locking */
>  	.fclose		= nlm_fclose,		/* close file */
>  };
