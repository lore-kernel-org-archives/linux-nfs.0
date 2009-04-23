From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH 08/29] nfsd41: protect sv_drc_pages_used with spinlock
Date: Thu, 23 Apr 2009 19:36:47 -0400
Message-ID: <20090423233647.GM1906@fieldses.org>
References: <1240504988-9572-1-git-send-email-andros@netapp.com> <1240504988-9572-2-git-send-email-andros@netapp.com> <1240504988-9572-3-git-send-email-andros@netapp.com> <1240504988-9572-4-git-send-email-andros@netapp.com> <1240504988-9572-5-git-send-email-andros@netapp.com> <1240504988-9572-6-git-send-email-andros@netapp.com> <1240504988-9572-7-git-send-email-andros@netapp.com> <1240504988-9572-8-git-send-email-andros@netapp.com> <1240504988-9572-9-git-send-email-andros@netapp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org, pnfs@linux-nfs.org
To: andros@netapp.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([141.211.133.115]:33702 "EHLO
	pickle.fieldses.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753075AbZDWXgs (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 23 Apr 2009 19:36:48 -0400
In-Reply-To: <1240504988-9572-9-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Apr 23, 2009 at 12:42:47PM -0400, andros@netapp.com wrote:
> From: Andy Adamson <andros@netapp.com>
> 
> Don't use the sv_lock as per March 31 review by bfields.

If you could remind me (and anyone else) what my complaint was, that'd
be helpful.  (OK, I think it's coming back to me.  Still, it's a comment
that's not useful to anyone else later.)

> 
> Serialize access to sv_drc_pages_used which changes on session creation.

So this information is all server-wide?

Might as well just make it (the lock, and the other sv_drc_* stuff)
global, I guess.  It shouldn't be in an rpc-level structure (struct
svc_serv) since it's nfs/sessions-specific.

--b.

> 
> Signed-off-by: Andy Adamson <andros@netapp.com>
> ---
>  fs/nfsd/nfs4state.c        |    4 ++--
>  include/linux/sunrpc/svc.h |    1 +
>  net/sunrpc/svc.c           |    1 +
>  3 files changed, 4 insertions(+), 2 deletions(-)
> 
> diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
> index 4cc66f3..af21f94 100644
> --- a/fs/nfsd/nfs4state.c
> +++ b/fs/nfsd/nfs4state.c
> @@ -427,11 +427,11 @@ static int set_forechannel_maxreqs(struct nfsd4_channel_attrs *fchan)
>  {
>  	int status = 0, np = fchan->maxreqs * NFSD_PAGES_PER_SLOT;
>  
> -	spin_lock(&nfsd_serv->sv_lock);
> +	spin_lock(&nfsd_serv->sv_drc_lock);
>  	if (np + nfsd_serv->sv_drc_pages_used > nfsd_serv->sv_drc_max_pages)
>  		np = nfsd_serv->sv_drc_max_pages - nfsd_serv->sv_drc_pages_used;
>  	nfsd_serv->sv_drc_pages_used += np;
> -	spin_unlock(&nfsd_serv->sv_lock);
> +	spin_unlock(&nfsd_serv->sv_drc_lock);
>  
>  	if (np <= 0) {
>  		status = nfserr_resource;
> diff --git a/include/linux/sunrpc/svc.h b/include/linux/sunrpc/svc.h
> index 2a30775..0d2315c 100644
> --- a/include/linux/sunrpc/svc.h
> +++ b/include/linux/sunrpc/svc.h
> @@ -94,6 +94,7 @@ struct svc_serv {
>  	struct module *		sv_module;	/* optional module to count when
>  						 * adding threads */
>  	svc_thread_fn		sv_function;	/* main function for threads */
> +	spinlock_t              sv_drc_lock;
>  	unsigned int		sv_drc_max_pages; /* Total pages for DRC */
>  	unsigned int		sv_drc_pages_used;/* DRC pages used */
>  };
> diff --git a/net/sunrpc/svc.c b/net/sunrpc/svc.c
> index 8847add..c25070a 100644
> --- a/net/sunrpc/svc.c
> +++ b/net/sunrpc/svc.c
> @@ -394,6 +394,7 @@ __svc_create(struct svc_program *prog, unsigned int bufsize, int npools,
>  	INIT_LIST_HEAD(&serv->sv_permsocks);
>  	init_timer(&serv->sv_temptimer);
>  	spin_lock_init(&serv->sv_lock);
> +	spin_lock_init(&serv->sv_drc_lock);
>  
>  	serv->sv_nrpools = npools;
>  	serv->sv_pools =
> -- 
> 1.5.4.3
> 
