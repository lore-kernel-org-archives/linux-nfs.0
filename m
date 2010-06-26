From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH 1/3] nfsd: don't try to shut down nfs4 state handling unless it's up
Date: Sat, 26 Jun 2010 11:53:51 -0400
Message-ID: <20100626155351.GA16951@pig.fieldses.org>
References: <1275924800-5214-1-git-send-email-jlayton@redhat.com> <1275924800-5214-2-git-send-email-jlayton@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Cc: <linux-nfs@vger.kernel.org>
To: "Jeff Layton" <jlayton@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.g-wis.com ([204.250.154.18]:2670 "EHLO mail.g-wis.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753187Ab0FZUlS (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sat, 26 Jun 2010 16:41:18 -0400
In-Reply-To: <1275924800-5214-2-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Jun 07, 2010 at 11:33:18AM -0400, Jeff Layton wrote:
> If someone tries to shut down the laundry_wq while it isn't up it'll
> cause an oops.

Sorry for getting behind....

I'm not seeing how this can happen: nfs4_state_shutdown() is called from
nfsd_last_thread(), which can't be called until after nfsd_create_serv()
is called.  But nfsd_create_serv() is called after nfs4_state_start().

Oh, I see, I'm overlooking __write_ports_add{fd,xprt}(), which can call
nfsd_create_serv() without first calling nfs4_state_start().  Argh.

--b.

> 
> Signed-off-by: Jeff Layton <jlayton@redhat.com>
> ---
>  fs/nfsd/nfs4state.c |    2 ++
>  1 files changed, 2 insertions(+), 0 deletions(-)
> 
> diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
> index 1176708..fc52920 100644
> --- a/fs/nfsd/nfs4state.c
> +++ b/fs/nfsd/nfs4state.c
> @@ -4124,6 +4124,8 @@ __nfs4_state_shutdown(void)
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
