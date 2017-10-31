Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:34840 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751961AbdJaVSv (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 31 Oct 2017 17:18:51 -0400
Date: Tue, 31 Oct 2017 17:18:51 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Vasily Averin <vvs@virtuozzo.com>
Cc: Jeff Layton <jlayton@kernel.org>, linux-nfs@vger.kernel.org
Subject: Re: [PATCH] grace: only add lock_manager to grace_list if it's not
 already there
Message-ID: <20171031211851.GB15605@fieldses.org>
References: <20171030182932.3282-1-jlayton@kernel.org>
 <d6d32171-c5a7-07eb-ec81-4d59c997ac0e@virtuozzo.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <d6d32171-c5a7-07eb-ec81-4d59c997ac0e@virtuozzo.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Oct 31, 2017 at 10:31:35AM +0300, Vasily Averin wrote:
> On 2017-10-30 21:29, Jeff Layton wrote:
> > Vasily, would this patch fix the panic you're seeing? We may still
> > need to do something saner here, but this seems like it should at
> > least prevent a double list_add.
> 
> Jeff, I think your patch is wrong.
> 
> Double list_add is not a real problem, it is just a marker of its presence.
> It's great that such marker exist, it allows to detect the problems.
> 
> Yes, your patch prevent a double list_add and fix the reported panic,
> however it does not fix the root of problems, and it still can cause another troubles.
> 
> I see 2 separate problems here:
> 
> 1) when nfsd is started in new net namespace it enables delayed_work grace_period_end
> and adds lockd_manager into list of this net namespace.
> However nobody revert these actions on stop of this nfsd.
> 
> It can lead to double list_add if nfsd is started again.
> Also we can remove net namespace, then not disarmed delayed_work can access freed memory.
> 
> It was broken by Commit efda760fe95ea ("lockd: fix lockd shutdown race"):
> you cannot move cancel_delayed_work_sync() and lock_end_grace() into lockd().
> lockd can be not executed at all (if nfsd was started in init_net or in any other net namespace)
> and even if it was executed -- it calls these functions with wrong net:
> lockd uses hardcoded init_net and does not know which net was provided to lockd_up on start.
> 
> My patch "[PATCH] lockd: fix lockd shutdown race with signal" fixes this problem.
> 
> 2) restart_grace() works with init_net only.
> It can call set_grace_period() for init_net when it was not required
> (i.e. when nfsd in init_net was stopped) and cause double list_add on its start.
> 
> However main problem here is that it does nothing for any other net namespaces.
> This part of lockd was not namespace-ified, and I would like to clarify how it's better to complete this task.

I'm not sure.  The original idea was that the grace period is global to
the host (hypervisor), so as long as a server in any network namespace
needs a grace period, normal locking should be blocked across all
namespaces.  (This is really only necessarily if we know that a
filesystem is exported from all namespaces; but since we don't keep
track of that, we assume the worst.)

The signal interface to lockd I think of as a legacy interface.  As you
say it might be risky to just rip it out completely.  But I'd be fine
with it being limited to legacy use cases.  So if it doesn't play well
with network namespaces, that's OK (as long as it doesn't crash).

--b.
