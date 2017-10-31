Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:38516 "EHLO relay.sw.ru"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752838AbdJaHbx (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 31 Oct 2017 03:31:53 -0400
Subject: Re: [PATCH] grace: only add lock_manager to grace_list if it's not
 already there
To: Jeff Layton <jlayton@kernel.org>
Cc: bfields@fieldses.org, linux-nfs@vger.kernel.org
References: <20171030182932.3282-1-jlayton@kernel.org>
From: Vasily Averin <vvs@virtuozzo.com>
Message-ID: <d6d32171-c5a7-07eb-ec81-4d59c997ac0e@virtuozzo.com>
Date: Tue, 31 Oct 2017 10:31:35 +0300
MIME-Version: 1.0
In-Reply-To: <20171030182932.3282-1-jlayton@kernel.org>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 2017-10-30 21:29, Jeff Layton wrote:
> Vasily, would this patch fix the panic you're seeing? We may still
> need to do something saner here, but this seems like it should at
> least prevent a double list_add.

Jeff, I think your patch is wrong.

Double list_add is not a real problem, it is just a marker of its presence.
It's great that such marker exist, it allows to detect the problems.

Yes, your patch prevent a double list_add and fix the reported panic,
however it does not fix the root of problems, and it still can cause another troubles.

I see 2 separate problems here:

1) when nfsd is started in new net namespace it enables delayed_work grace_period_end
and adds lockd_manager into list of this net namespace.
However nobody revert these actions on stop of this nfsd.

It can lead to double list_add if nfsd is started again.
Also we can remove net namespace, then not disarmed delayed_work can access freed memory.

It was broken by Commit efda760fe95ea ("lockd: fix lockd shutdown race"):
you cannot move cancel_delayed_work_sync() and lock_end_grace() into lockd().
lockd can be not executed at all (if nfsd was started in init_net or in any other net namespace)
and even if it was executed -- it calls these functions with wrong net:
lockd uses hardcoded init_net and does not know which net was provided to lockd_up on start.

My patch "[PATCH] lockd: fix lockd shutdown race with signal" fixes this problem.

2) restart_grace() works with init_net only.
It can call set_grace_period() for init_net when it was not required
(i.e. when nfsd in init_net was stopped) and cause double list_add on its start.

However main problem here is that it does nothing for any other net namespaces.
This part of lockd was not namespace-ified, and I would like to clarify how it's better to complete this task.

