Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([173.255.197.46]:52352 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750777AbdKIPp0 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 9 Nov 2017 10:45:26 -0500
Date: Thu, 9 Nov 2017 10:45:25 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Vasily Averin <vvs@virtuozzo.com>
Cc: linux-nfs@vger.kernel.org, Jeff Layton <jlayton@kernel.org>
Subject: Re: [PATCH] lockd: lost rollback of set_grace_period() in
 lockd_down_net()
Message-ID: <20171109154525.GH8773@fieldses.org>
References: <fb8ccaec-e163-0b47-6fa0-e85de7abd6a8@virtuozzo.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <fb8ccaec-e163-0b47-6fa0-e85de7abd6a8@virtuozzo.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Applied for 4.15 and stable, thanks.--b.

On Thu, Nov 02, 2017 at 01:03:42PM +0300, Vasily Averin wrote:
> Commit efda760fe95ea ("lockd: fix lockd shutdown race") is incorrect,
> it removes lockd_manager and disarm grace_period_end for init_net only. 
> 
> If nfsd was started from another net namespace lockd_up_net() calls 
> set_grace_period() that adds lockd_manager into per-netns list
> and queues grace_period_end delayed work.
> 
> These action should be reverted in lockd_down_net().
> Otherwise it can lead to double list_add on after restart nfsd in netns,
> and to use-after-free if non-disarmed delayed work will be executed after netns destroy.  
> 
> Fixes commit efda760fe95e ("lockd: fix lockd shutdown race")
> 
> Signed-off-by: Vasily Averin <vvs@virtuozzo.com>
> ---
>  fs/lockd/svc.c | 2 ++
>  1 file changed, 2 insertions(+)
> 
> diff --git a/fs/lockd/svc.c b/fs/lockd/svc.c
> index c1573860..809cbcc 100644
> --- a/fs/lockd/svc.c
> +++ b/fs/lockd/svc.c
> @@ -277,6 +277,8 @@ static void lockd_down_net(struct svc_serv *serv, struct net *net)
>  	if (ln->nlmsvc_users) {
>  		if (--ln->nlmsvc_users == 0) {
>  			nlm_shutdown_hosts_net(net);
> +			cancel_delayed_work_sync(&ln->grace_period_end);
> +			locks_end_grace(&ln->lockd_manager);
>  			svc_shutdown_net(serv, net);
>  			dprintk("lockd_down_net: per-net data destroyed; net=%p\n", net);
>  		}
> -- 
> 2.7.4
