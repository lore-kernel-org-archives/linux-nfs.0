Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:7587 "EHLO relay.sw.ru"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753056AbdKAKKt (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 1 Nov 2017 06:10:49 -0400
Subject: Re: [PATCH] grace: only add lock_manager to grace_list if it's not
 already there
To: "J. Bruce Fields" <bfields@fieldses.org>,
        Jeff Layton <jlayton@kernel.org>
Cc: linux-nfs@vger.kernel.org
References: <20171030182932.3282-1-jlayton@kernel.org>
 <d6d32171-c5a7-07eb-ec81-4d59c997ac0e@virtuozzo.com>
 <20171031211851.GB15605@fieldses.org>
From: Vasily Averin <vvs@virtuozzo.com>
Message-ID: <62d9a66b-abd3-aba9-121f-e9dac7c8f1b4@virtuozzo.com>
Date: Wed, 1 Nov 2017 13:10:36 +0300
MIME-Version: 1.0
In-Reply-To: <20171031211851.GB15605@fieldses.org>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 2017-11-01 00:18, J. Bruce Fields wrote:
> On Tue, Oct 31, 2017 at 10:31:35AM +0300, Vasily Averin wrote:
>> On 2017-10-30 21:29, Jeff Layton wrote:
>>> Vasily, would this patch fix the panic you're seeing? We may still
>>> need to do something saner here, but this seems like it should at
>>> least prevent a double list_add.
>>
>> Jeff, I think your patch is wrong.
>>
>> Double list_add is not a real problem, it is just a marker of its presence.
>> It's great that such marker exist, it allows to detect the problems.

Jeff, what do you about about following hunk ?

--- a/fs/nfs_common/grace.c
+++ b/fs/nfs_common/grace.c
@@ -30,7 +30,11 @@ locks_start_grace(struct net *net, struct lock_manager *lm)
        struct list_head *grace_list = net_generic(net, grace_net_id);
 
        spin_lock(&grace_lock);
-       list_add(&lm->list, grace_list);
+       if (list_empty(&lm->list))
+               list_add(&lm->list, grace_list);
+       else
+               WARN(1, "double list_add attempt detected in %s %p\n",
+                    (net == &init_net) ? "init_net" : "net", net);
        spin_unlock(&grace_lock);
 }
 EXPORT_SYMBOL_GPL(locks_start_grace);

It allows to avoid list corruption and panic
but will report about detected problem

[  344.722040] double list_add attempt detected in init_net ffffffffa4fd9800
[  344.722108] ------------[ cut here ]------------
[  344.722142] WARNING: CPU: 3 PID: 1505 at fs/nfs_common/grace.c:37 locks_start_grace+0xa2/0xb0 [grace]


I think by same way we can also detect and disarm lost delayed_work on stop of network namespace.
(in lockd_exit_net)

>> 2) restart_grace() works with init_net only.
>> It can call set_grace_period() for init_net when it was not required
>> (i.e. when nfsd in init_net was stopped) and cause double list_add on its start.
>>
>> However main problem here is that it does nothing for any other net namespaces.
>> This part of lockd was not namespace-ified, and I would like to clarify how it's better to complete this task.
> 
> I'm not sure.  The original idea was that the grace period is global to
> the host (hypervisor), so as long as a server in any network namespace
> needs a grace period, normal locking should be blocked across all
> namespaces.  (This is really only necessarily if we know that a
> filesystem is exported from all namespaces; but since we don't keep
> track of that, we assume the worst.)
> 
> The signal interface to lockd I think of as a legacy interface.  As you
> say it might be risky to just rip it out completely.  But I'd be fine
> with it being limited to legacy use cases.  So if it doesn't play well
> with network namespaces, that's OK (as long as it doesn't crash).

Dear Bruce, thank you very much for explanation.
