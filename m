Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:52346 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752969AbdKIPoo (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 9 Nov 2017 10:44:44 -0500
Date: Thu, 9 Nov 2017 10:44:44 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Vasily Averin <vvs@virtuozzo.com>
Cc: Jeff Layton <jlayton@kernel.org>, linux-nfs@vger.kernel.org
Subject: Re: [PATCH] grace: only add lock_manager to grace_list if it's not
 already there
Message-ID: <20171109154444.GG8773@fieldses.org>
References: <20171030182932.3282-1-jlayton@kernel.org>
 <d6d32171-c5a7-07eb-ec81-4d59c997ac0e@virtuozzo.com>
 <20171031211851.GB15605@fieldses.org>
 <62d9a66b-abd3-aba9-121f-e9dac7c8f1b4@virtuozzo.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <62d9a66b-abd3-aba9-121f-e9dac7c8f1b4@virtuozzo.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Nov 01, 2017 at 01:10:36PM +0300, Vasily Averin wrote:
> 
> 
> On 2017-11-01 00:18, J. Bruce Fields wrote:
> > On Tue, Oct 31, 2017 at 10:31:35AM +0300, Vasily Averin wrote:
> >> On 2017-10-30 21:29, Jeff Layton wrote:
> >>> Vasily, would this patch fix the panic you're seeing? We may still
> >>> need to do something saner here, but this seems like it should at
> >>> least prevent a double list_add.
> >>
> >> Jeff, I think your patch is wrong.
> >>
> >> Double list_add is not a real problem, it is just a marker of its presence.
> >> It's great that such marker exist, it allows to detect the problems.
> 
> Jeff, what do you about about following hunk ?
> 
> --- a/fs/nfs_common/grace.c
> +++ b/fs/nfs_common/grace.c
> @@ -30,7 +30,11 @@ locks_start_grace(struct net *net, struct lock_manager *lm)
>         struct list_head *grace_list = net_generic(net, grace_net_id);
>  
>         spin_lock(&grace_lock);
> -       list_add(&lm->list, grace_list);
> +       if (list_empty(&lm->list))
> +               list_add(&lm->list, grace_list);
> +       else
> +               WARN(1, "double list_add attempt detected in %s %p\n",
> +                    (net == &init_net) ? "init_net" : "net", net);
>         spin_unlock(&grace_lock);
>  }
>  EXPORT_SYMBOL_GPL(locks_start_grace);
> 
> It allows to avoid list corruption and panic
> but will report about detected problem
> 
> [  344.722040] double list_add attempt detected in init_net ffffffffa4fd9800
> [  344.722108] ------------[ cut here ]------------
> [  344.722142] WARNING: CPU: 3 PID: 1505 at fs/nfs_common/grace.c:37 locks_start_grace+0xa2/0xb0 [grace]
> 
> 
> I think by same way we can also detect and disarm lost delayed_work on stop of network namespace.
> (in lockd_exit_net)

Jeff, were you planning to resend this?

--b.
