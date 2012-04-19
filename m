Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mailhub.sw.ru ([195.214.232.25]:13876 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754604Ab2DSIal (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 19 Apr 2012 04:30:41 -0400
Message-ID: <4F8FCD20.1070103@openvz.org>
Date: Thu, 19 Apr 2012 12:30:24 +0400
From: Kinsbursky Stanislav <skinsbursky@openvz.org>
MIME-Version: 1.0
To: "bfields@fieldses.org" <bfields@fieldses.org>,
        "Trond.Myklebust@netapp.com" <Trond.Myklebust@netapp.com>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "devel@openvz.org" <devel@openvz.org>
Subject: Re: [PATCH] LockD: call per-net shutdown on every global shutdown
 call
References: <20120418131827.16800.33207.stgit@localhost6.localdomain6>
In-Reply-To: <20120418131827.16800.33207.stgit@localhost6.localdomain6>
Content-Type: text/plain; charset=UTF-8; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Please, ignore this patch.
The idea is correct, but current implementation hides few more things to be 
modified.
Otherwise kernel oopses.
Sorry.

18.04.2012 17:18, Stanislav Kinsbursky пишет:
> Per-net LockD shutdown call must be called regardless of global nlm users
> counter.
>
> Signed-off-by: Stanislav Kinsbursky<skinsbursky@parallels.com>
>
> ---
>   fs/lockd/svc.c |    5 ++---
>   1 files changed, 2 insertions(+), 3 deletions(-)
>
> diff --git a/fs/lockd/svc.c b/fs/lockd/svc.c
> index 1ead075..2ad3715 100644
> --- a/fs/lockd/svc.c
> +++ b/fs/lockd/svc.c
> @@ -381,10 +381,9 @@ lockd_down(struct net *net)
>   {
>   	mutex_lock(&nlmsvc_mutex);
>   	if (nlmsvc_users) {
> -		if (--nlmsvc_users) {
> -			lockd_down_net(net);
> +		lockd_down_net(net);
> +		if (--nlmsvc_users)
>   			goto out;
> -		}
>   	} else {
>   		printk(KERN_ERR "lockd_down: no users! task=%p\n",
>   			nlmsvc_task);
>


-- 
Best regards,
Stanislav Kinsbursky

