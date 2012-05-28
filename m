Return-Path: linux-nfs-owner@vger.kernel.org
Received: from natasha.panasas.com ([67.152.220.90]:54076 "EHLO
	natasha.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754796Ab2E1QjF (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 28 May 2012 12:39:05 -0400
Message-ID: <4FC3AA15.3010107@panasas.com>
Date: Mon, 28 May 2012 19:38:45 +0300
From: Boaz Harrosh <bharrosh@panasas.com>
MIME-Version: 1.0
To: Benny Halevy <bhalevy@tonian.com>
CC: <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 1/5] pnfsd: make return_on_close state layout-global for
 the file/client
References: <4FC3A235.8090908@tonian.com> <1338221358-22447-1-git-send-email-bhalevy@tonian.com>
In-Reply-To: <1338221358-22447-1-git-send-email-bhalevy@tonian.com>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 05/28/2012 07:09 PM, Benny Halevy wrote:

> As per RFC5661 errata #3226
> http://www.ietf.org/mail-archive/web/nfsv4/current/msg10965.html
> Once the server returns the return_on_close flag set, all the layout
> for that client will be implicitly returned on last close.
> 


This one I'll keep though It will conflict with my patches.

I will incorporate whats relevant.

> Reported-by: Boaz Harrosh <bharrosh@panasas.com>
> Signed-off-by: Benny Halevy <bhalevy@tonian.com>
> ---
>  fs/nfsd/nfs4pnfsd.c |   19 ++++++++++++++-----
>  fs/nfsd/pnfsd.h     |    2 +-
>  2 files changed, 15 insertions(+), 6 deletions(-)
> 
> diff --git a/fs/nfsd/nfs4pnfsd.c b/fs/nfsd/nfs4pnfsd.c
> index 9f94cd0..a95e96e 100644
> --- a/fs/nfsd/nfs4pnfsd.c
> +++ b/fs/nfsd/nfs4pnfsd.c
> @@ -161,6 +161,7 @@ void pnfs_clear_device_notify(struct nfs4_client *clp)
>  	spin_lock(&layout_lock);
>  	list_add(&new->ls_perfile, &fp->fi_layout_states);
>  	spin_unlock(&layout_lock);
> +	new->ls_roc = false;
>  	return new;
>  }
>  
> @@ -286,6 +287,15 @@ static void update_layout_stateid(struct nfs4_layout_state *ls, stateid_t *sid)
>  	spin_unlock(&layout_lock);
>  }
>  
> +static void update_layout_roc(struct nfs4_layout_state *ls, bool roc)
> +{
> +	if (roc) {
> +		ls->ls_roc = true;
> +		dprintk("%s: Marked return_on_close on layoutstate %p\n",
> +			__func__, ls);
> +	}
> +}
> +
>  static void
>  init_layout(struct nfs4_layout *lp,
>  	    struct nfs4_layout_state *ls,
> @@ -293,8 +303,7 @@ static void update_layout_stateid(struct nfs4_layout_state *ls, stateid_t *sid)
>  	    struct nfs4_client *clp,
>  	    struct svc_fh *current_fh,
>  	    struct nfsd4_layout_seg *seg,
> -	    stateid_t *stateid,
> -	    bool roc)
> +	    stateid_t *stateid)
>  {
>  	dprintk("pNFS %s: lp %p ls %p clp %p fp %p ino %p\n", __func__,
>  		lp, ls, clp, fp, fp->fi_inode);
> @@ -305,7 +314,6 @@ static void update_layout_stateid(struct nfs4_layout_state *ls, stateid_t *sid)
>  	memcpy(&lp->lo_seg, seg, sizeof(lp->lo_seg));
>  	get_layout_state(ls);		/* put on destroy_layout */
>  	lp->lo_state = ls;
> -	lp->lo_roc = roc;
>  	update_layout_stateid(ls, stateid);
>  	list_add_tail(&lp->lo_perclnt, &clp->cl_layouts);
>  	list_add_tail(&lp->lo_perfile, &fp->fi_layouts);
> @@ -811,6 +819,7 @@ struct super_block *
>  
>  	lgp->lg_seg = res.lg_seg;
>  	lgp->lg_roc = res.lg_return_on_close;
> +	update_layout_roc(ls, res.lg_return_on_close);
>  
>  	/* SUCCESS!
>  	 * Can the new layout be merged into an existing one?
> @@ -820,7 +829,7 @@ struct super_block *
>  		goto out_freelayout;
>  
>  	/* Can't merge, so let's initialize this new layout */
> -	init_layout(lp, ls, fp, clp, lgp->lg_fhp, &res.lg_seg, &lgp->lg_sid, res.lg_return_on_close);
> +	init_layout(lp, ls, fp, clp, lgp->lg_fhp, &res.lg_seg, &lgp->lg_sid);
>  out_unlock:
>  	if (ls)
>  		put_layout_state(ls);
> @@ -1225,7 +1234,7 @@ void pnfsd_roc(struct nfs4_client *clp, struct nfs4_file *fp)
>  		bool empty;
>  
>  		/* Check for a match */
> -		if (!lo->lo_roc || lo->lo_client != clp)
> +		if (!lo->lo_state->ls_roc || lo->lo_client != clp)
>  			continue;
>  
>  		/* Return the layout */
> diff --git a/fs/nfsd/pnfsd.h b/fs/nfsd/pnfsd.h
> index f0862fb..e960fd3 100644
> --- a/fs/nfsd/pnfsd.h
> +++ b/fs/nfsd/pnfsd.h
> @@ -45,6 +45,7 @@ struct nfs4_layout_state {
>  	struct kref		ls_ref;
>  	struct nfs4_stid	ls_stid;
>  	struct list_head	ls_perfile;
> +	bool			ls_roc;
>  };
>  
>  /* outstanding layout */
> @@ -55,7 +56,6 @@ struct nfs4_layout {
>  	struct nfs4_client		*lo_client;
>  	struct nfs4_layout_state	*lo_state;
>  	struct nfsd4_layout_seg		lo_seg;
> -	bool				lo_roc;
>  };
>  
>  struct pnfs_inval_state {


