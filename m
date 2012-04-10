Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:35149 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755271Ab2DJVP1 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 10 Apr 2012 17:15:27 -0400
Date: Tue, 10 Apr 2012 17:15:26 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Jeff Layton <jlayton@redhat.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH] nfsd: don't use locks_in_grace to determine whether to
 call nfs4_grace_end
Message-ID: <20120410211526.GJ18465@fieldses.org>
References: <1334070528-16019-1-git-send-email-jlayton@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1334070528-16019-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Apr 10, 2012 at 11:08:48AM -0400, Jeff Layton wrote:
> It's possible that lockd or another lock manager might still be on the
> list after we call nfsd4_end_grace. If the laundromat thread runs
> again at that point, then we could end up calling nfsd4_end_grace more
> than once.
> 
> That's not only inefficient, but calling nfsd4_recdir_purge_old more
> than once could be problematic. Fix this by adding a new global
> "grace_ended" flag and use that to determine whether we've already
> called nfsd4_grace_end.

Looks good to me, applying, thanks.--b.

> 
> Signed-off-by: Jeff Layton <jlayton@redhat.com>
> ---
>  fs/nfsd/nfs4state.c |   11 +++++++++--
>  1 files changed, 9 insertions(+), 2 deletions(-)
> 
> diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
> index a822e31..277c989 100644
> --- a/fs/nfsd/nfs4state.c
> +++ b/fs/nfsd/nfs4state.c
> @@ -3155,10 +3155,17 @@ out:
>  static struct lock_manager nfsd4_manager = {
>  };
>  
> +static bool grace_ended;
> +
>  static void
>  nfsd4_end_grace(void)
>  {
> +	/* do nothing if grace period already ended */
> +	if (grace_ended)
> +		return;
> +
>  	dprintk("NFSD: end of grace period\n");
> +	grace_ended = true;
>  	nfsd4_record_grace_done(&init_net, boot_time);
>  	locks_end_grace(&nfsd4_manager);
>  	/*
> @@ -3183,8 +3190,7 @@ nfs4_laundromat(void)
>  	nfs4_lock_state();
>  
>  	dprintk("NFSD: laundromat service - starting\n");
> -	if (locks_in_grace())
> -		nfsd4_end_grace();
> +	nfsd4_end_grace();
>  	INIT_LIST_HEAD(&reaplist);
>  	spin_lock(&client_lock);
>  	list_for_each_safe(pos, next, &client_lru) {
> @@ -4718,6 +4724,7 @@ nfs4_state_start(void)
>  	nfsd4_client_tracking_init(&init_net);
>  	boot_time = get_seconds();
>  	locks_start_grace(&nfsd4_manager);
> +	grace_ended = false;
>  	printk(KERN_INFO "NFSD: starting %ld-second grace period\n",
>  	       nfsd4_grace);
>  	ret = set_callback_cred();
> -- 
> 1.7.7.6
> 
