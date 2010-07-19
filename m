From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH 1/5] nfsd: don't try to shut down nfs4 state handling
 unless it's up
Date: Mon, 19 Jul 2010 18:08:37 -0400
Message-ID: <20100719220837.GA31074@fieldses.org>
References: <1279572608-7234-1-git-send-email-jlayton@redhat.com>
 <1279572608-7234-2-git-send-email-jlayton@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org
To: Jeff Layton <jlayton@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:52961 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965985Ab0GSWJR (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 19 Jul 2010 18:09:17 -0400
In-Reply-To: <1279572608-7234-2-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Jul 19, 2010 at 04:50:04PM -0400, Jeff Layton wrote:
> If someone tries to shut down the laundry_wq while it isn't up it'll
> cause an oops.

nfs4_state_shutdown is called only from nfsd_last_thread, which is
called only after svc_create_pooled, which is called only when
nfs4_state_start() succeeds.

If you've actually seen this happen then there's something going on that
I don't understand.

--b.

> 
> Signed-off-by: Jeff Layton <jlayton@redhat.com>
> ---
>  fs/nfsd/nfs4state.c |    2 ++
>  1 files changed, 2 insertions(+), 0 deletions(-)
> 
> diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
> index 4a27347..0b396f8 100644
> --- a/fs/nfsd/nfs4state.c
> +++ b/fs/nfsd/nfs4state.c
> @@ -4116,6 +4116,8 @@ __nfs4_state_shutdown(void)
>  void
>  nfs4_state_shutdown(void)
>  {
> +	if (!nfs4_init)
> +		return;
>  	cancel_rearming_delayed_workqueue(laundry_wq, &laundromat_work);
>  	destroy_workqueue(laundry_wq);
>  	locks_end_grace(&nfsd4_manager);
> -- 
> 1.5.5.6
> 
