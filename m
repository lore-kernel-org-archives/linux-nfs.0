Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mailhub.sw.ru ([195.214.232.25]:34871 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754338Ab2DJOLX (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 10 Apr 2012 10:11:23 -0400
Message-ID: <4F843F53.9050301@parallels.com>
Date: Tue, 10 Apr 2012 18:10:27 +0400
From: Stanislav Kinsbursky <skinsbursky@parallels.com>
MIME-Version: 1.0
To: "bfields@fieldses.org" <bfields@fieldses.org>
CC: "Trond.Myklebust@netapp.com" <Trond.Myklebust@netapp.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
Subject: Re: Grace period
References: <4F7F230A.6080506@parallels.com> <20120406234039.GA20940@fieldses.org> <4F82C6E3.3030009@parallels.com> <20120409232618.GI10508@fieldses.org> <4F841987.6090909@parallels.com> <20120410133735.GE18465@fieldses.org>
In-Reply-To: <20120410133735.GE18465@fieldses.org>
Content-Type: text/plain; charset=UTF-8; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

10.04.2012 17:37, bfields@fieldses.org пишет:
> On Tue, Apr 10, 2012 at 03:29:11PM +0400, Stanislav Kinsbursky wrote:
>> 10.04.2012 03:26, bfields@fieldses.org пишет:
>>> On Mon, Apr 09, 2012 at 03:24:19PM +0400, Stanislav Kinsbursky wrote:
>>>> 07.04.2012 03:40, bfields@fieldses.org пишет:
>>>>> On Fri, Apr 06, 2012 at 09:08:26PM +0400, Stanislav Kinsbursky wrote:
>>>>>> Hello, Bruce.
>>>>>> Could you, please, clarify this reason why grace list is used?
>>>>>> I.e. why list is used instead of some atomic variable, for example?
>>>>>
>>>>> Like just a reference count?  Yeah, that would be OK.
>>>>>
>>>>> In theory it could provide some sort of debugging help.  (E.g. we could
>>>>> print out the list of "lock managers" currently keeping us in grace.)  I
>>>>> had some idea we'd make those lock manager objects more complicated, and
>>>>> might have more for individual containerized services.
>>>>
>>>> Could you share this idea, please?
>>>>
>>>> Anyway, I have nothing against lists. Just was curious, why it was used.
>>>> I added Trond and lists to this reply.
>>>>
>>>> Let me explain, what is the problem with grace period I'm facing
>>>> right know, and what I'm thinking about it.
>>>> So, one of the things to be containerized during "NFSd per net ns"
>>>> work is the grace period, and these are the basic components of it:
>>>> 1) Grace period start.
>>>> 2) Grace period end.
>>>> 3) Grace period check.
>>>> 3) Grace period restart.
>>>
>>> For restart, you're thinking of the fs/lockd/svc.c:restart_grace()
>>> that's called on aisngal in lockd()?
>>>
>>> I wonder if there's any way to figure out if that's actually used by
>>> anyone?  (E.g. by any distro init scripts).  It strikes me as possibly
>>> impossible to use correctly.  Perhaps we could deprecate it....
>>>
>>
>> Or (since lockd kthread is visible only from initial pid namespace)
>> we can just hardcode "init_net" in this case. But it means, that
>> this "kill" logic will be broken if two containers shares one pid
>> namespace, but have separated networks namespaces.
>> Anyway, both (this one or Bruce's) solutions suits me.
>>
>>>> So, the simplest straight-forward way is to make all internal stuff:
>>>> "grace_list", "grace_lock", "grace_period_end" work and both
>>>> "lockd_manager" and "nfsd4_manager" - per network namespace. Also,
>>>> "laundromat_work" have to be per-net as well.
>>>> In this case:
>>>> 1) Start - grace period can be started per net ns in
>>>> "lockd_up_net()" (thus has to be moves there from "lockd()") and
>>>> "nfs4_state_start()".
>>>> 2) End - grace period can be ended per net ns in "lockd_down_net()"
>>>> (thus has to be moved there from "lockd()"), "nfsd4_end_grace()" and
>>>> "fs4_state_shutdown()".
>>>> 3) Check - looks easy. There is either svc_rqst or net context can
>>>> be passed to function.
>>>> 4) Restart - this is a tricky place. It would be great to restart
>>>> grace period only for the networks namespace of the sender of the
>>>> kill signal. So, the idea is to check siginfo_t for the pid of
>>>> sender, then try to locate the task, and if found, then get sender's
>>>> networks namespace, and restart grace period only for this namespace
>>>> (of course, if lockd was started for this namespace - see below).
>>>
>>> If it's really the signalling that's the problem--perhaps we can get
>>> away from the signal-based interface.
>>>
>>> At least in the case of lockd I suspect we could.
>>>
>>
>> I'm ok with that. So, if no objections will follow, I'll drop it and
>> send the patch. Or you want to do it?
>
> Please do go ahead.
>
> The safest approach might be:
> 	- leave lockd's signal handling there (just accept that it may
> 	  behave incorrectly in container case), assuming that's safe.
> 	- add a printk ("signalling lockd to restart is deprecated",
> 	  or something) if it's used.
>
> Then eventually we'll remove it entirely.
>
> (But if that doesn't work, it'd likely also be OK just to remove it
> completely now.)
>

Well, I can do this to restart grace only for "init_net" and a printk with your 
message and information, that it affect only init_net.
Looks good to you?

-- 
Best regards,
Stanislav Kinsbursky
