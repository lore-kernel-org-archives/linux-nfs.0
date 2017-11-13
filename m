Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:37459 "EHLO relay.sw.ru"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753188AbdKMO6D (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 13 Nov 2017 09:58:03 -0500
Subject: Re: [PATCH] lockd: fix "list_add double add" caused by legacy signal
 interface
To: Jeff Layton <jlayton@kernel.org>,
        "J. Bruce Fields" <bfields@fieldses.org>, linux-nfs@vger.kernel.org
References: <20171109154444.GG8773@fieldses.org>
 <75f4472c-b9e2-6353-3af0-c4939ecfca41@virtuozzo.com>
 <1510573758.4536.8.camel@kernel.org>
From: Vasily Averin <vvs@virtuozzo.com>
Message-ID: <48cdbeb3-b364-17c1-aaf9-948525e33f38@virtuozzo.com>
Date: Mon, 13 Nov 2017 17:57:54 +0300
MIME-Version: 1.0
In-Reply-To: <1510573758.4536.8.camel@kernel.org>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 2017-11-13 14:49, Jeff Layton wrote:
> On Mon, 2017-11-13 at 07:25 +0300, Vasily Averin wrote:
>> --- a/fs/nfs_common/grace.c
>> +++ b/fs/nfs_common/grace.c
>> @@ -30,7 +30,11 @@ locks_start_grace(struct net *net, struct lock_manager *lm)
>>  	struct list_head *grace_list = net_generic(net, grace_net_id);
>>  
>>  	spin_lock(&grace_lock);
>> -	list_add(&lm->list, grace_list);
>> +	if (list_empty(&lm->list))
>> +		list_add(&lm->list, grace_list);
>> +	else
>> +		WARN(1, "double list_add attempt detected in net %x %s\n",
>> +		     net->ns.inum, (net == &init_net) ? "(init_net)" : "");
>>  	spin_unlock(&grace_lock);
>>  }
> 
> I'm not sure that warning really means much.
> 
> It's not _really_ a bug to request that a new grace period start while
> it's already in one. In general, it's ok to request a new grace period
> while it's currently enforcing one. That should just have the effect of
> extending the existing grace period.

"double list_add" can happen in init_net when legacy signal in lockd was used.
It should not happen during usual extending of existing grace period,
because restart_grace() calls locks_end_grace() before set_grace_period()
but it can race with start of lockd_up_net() in init_net.
I'm agree: we do not have any bugs in this scenario, all should work correctly.

However I would like to keep WARN to properly detect lost locks_end_grace()/
cancel_delayed_work().

If you worry about real false positive and do not worry about abstract
future troubles in init_net, I can move WARN under (net != &init_net) check.

However I would like to keep this warning here.

On the other hand if you disagree and still believe that WARN is not required here
I'm ready to agree with your original patch version.
