Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([173.255.197.46]:52256 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750777AbdKIPGY (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 9 Nov 2017 10:06:24 -0500
Date: Thu, 9 Nov 2017 10:06:24 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Vasily Averin <vvs@virtuozzo.com>
Cc: netdev@vger.kernel.org, Jeff Layton <jlayton@poochiereds.net>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH v3 02/21] lockd: added cleanup checks in exit_net hook
Message-ID: <20171109150624.GE8773@fieldses.org>
References: <4fdc4264-e338-6ee8-a662-7d98b45733a1@virtuozzo.com>
 <a43dae6a-2f3f-cd72-3384-f22b28494eb0@virtuozzo.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <a43dae6a-2f3f-cd72-3384-f22b28494eb0@virtuozzo.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Applied.--b.

On Mon, Nov 06, 2017 at 04:23:24PM +0300, Vasily Averin wrote:
> Signed-off-by: Vasily Averin <vvs@virtuozzo.com>
> ---
>  fs/lockd/svc.c | 11 +++++++++++
>  1 file changed, 11 insertions(+)
> 
> diff --git a/fs/lockd/svc.c b/fs/lockd/svc.c
> index 809cbcc..2a48558 100644
> --- a/fs/lockd/svc.c
> +++ b/fs/lockd/svc.c
> @@ -690,6 +690,17 @@ static int lockd_init_net(struct net *net)
>  
>  static void lockd_exit_net(struct net *net)
>  {
> +	struct lockd_net *ln = net_generic(net, lockd_net_id);
> +
> +	WARN_ONCE(!list_empty(&ln->lockd_manager.list),
> +		  "net %x %s: lockd_manager.list is not empty\n",
> +		  net->ns.inum, __func__);
> +	WARN_ONCE(!list_empty(&ln->nsm_handles),
> +		  "net %x %s: nsm_handles list is not empty\n",
> +		  net->ns.inum, __func__);
> +	WARN_ONCE(delayed_work_pending(&ln->grace_period_end),
> +		  "net %x %s: grace_period_end was not cancelled\n",
> +		  net->ns.inum, __func__);
>  }
>  
>  static struct pernet_operations lockd_net_ops = {
> -- 
> 2.7.4
