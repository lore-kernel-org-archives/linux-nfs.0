Return-Path: linux-nfs-owner@vger.kernel.org
Received: from natasha.panasas.com ([67.152.220.90]:52466 "EHLO
	natasha.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759239Ab2CVTJR (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 22 Mar 2012 15:09:17 -0400
Message-ID: <4F6B789C.8020201@panasas.com>
Date: Thu, 22 Mar 2012 12:08:12 -0700
From: Boaz Harrosh <bharrosh@panasas.com>
MIME-Version: 1.0
To: Oleg Nesterov <oleg@redhat.com>
CC: Andrew Morton <akpm@linux-foundation.org>,
        Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>,
        "Rafael J. Wysocki" <rjw@sisk.pl>, <keyrings@linux-nfs.org>,
        <linux-security-module@vger.kernel.org>,
        linux-fsdevel <linux-fsdevel@vger.kernel.org>,
        linux-kernel <linux-kernel@vger.kernel.org>,
        NFS list <linux-nfs@vger.kernel.org>,
        Trond Myklebust <Trond.Myklebust@netapp.com>,
        "Bhamare, Sachin" <sbhamare@panasas.com>,
        David Howells <dhowells@redhat.com>, Eric Paris <eparis@redhat.com>,
        "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>,
        Kay Sievers <kay.sievers@vrfy.org>, James Morris <jmorris@namei.org>,
        "Eric W. Biederman" <ebiederm@xmission.com>,
        Greg KH <gregkh@linuxfoundation.org>,
        Rusty Russell <rusty@rustcorp.com.au>, Tejun Heo <tj@kernel.org>,
        David Rientjes <rientjes@google.com>
Subject: Re: [RFC 4/4] {RFC} kmod.c: Add new call_usermodehelper_timeout()
 API
References: <4F691059.30405@panasas.com> <4F691383.5040506@panasas.com> <4F6A92FC.6060702@panasas.com> <20120322142758.GA12370@redhat.com>
In-Reply-To: <20120322142758.GA12370@redhat.com>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 03/22/2012 07:27 AM, Oleg Nesterov wrote:
> On 03/21, Boaz Harrosh wrote:
>>
>>> @@ -258,7 +262,8 @@ static void __call_usermodehelper(struct work_struct *work)
>>>
>>>  	switch (wait) {
>>>  	case UMH_NO_WAIT:
>>> -		call_usermodehelper_freeinfo(sub_info);
>>> +		kref_put(&sub_info->kref,  call_usermodehelper_freeinfo);
>>> +		kref_put(&sub_info->kref,  call_usermodehelper_freeinfo);
>>>  		break;
> 
> This doesn't look very nice. If you add the refcounting, it should be
> consistent. Imho it is better to change call_usermodehelper_exec() so
> that UMH_NO_WAIT does kref_put() too. Just s/goto unlock/goto out/ afaics.
> 

Yes I've seen this. after I sent the patch. Hence the RFC tag

>>> @@ -452,22 +459,27 @@ int call_usermodehelper_exec(struct subprocess_info *sub_info,
>>>
>>>  	sub_info->complete = &done;
>>>  	sub_info->wait = wait;
>>> +	if (!sub_info->wait_timeout)
>>> +		sub_info->wait_timeout = MAX_SCHEDULE_TIMEOUT;
>>>
>>> +	/* Balanced in __call_usermodehelper or wait_for_helper */
>>> +	kref_get(&sub_info->kref);
>>>  	queue_work(khelper_wq, &sub_info->work);
>>>  	if (wait == UMH_NO_WAIT)	/* task has freed sub_info */
>>>  		goto unlock;
>>> -	wait_for_completion(&done);
>>> -	retval = sub_info->retval;
>>> -
>>> +	if (likely(wait_for_completion_timeout(&done, sub_info->wait_timeout)))
>>> +		retval = sub_info->retval;
>>> +	else
>>> +		retval = -ETIMEDOUT;
>>>  out:
>>> -	call_usermodehelper_freeinfo(sub_info);
>>> +	kref_put(&sub_info->kref, call_usermodehelper_freeinfo);
>>>  unlock:
>>>  	helper_unlock();
>>>  	return retval;
>>>  }
> 
> This looks obviously wrong. You also need to move *sub_info->complete
> into subprocess_info.
> 

Yes I caught that with farther testing. A stupid mistake. Again RFC

>> Author: Oleg Nesterov <oleg@redhat.com>
>> Date:   Wed Mar 21 10:57:41 2012 +1100
>>
>>     usermodehelper: implement UMH_KILLABLE
>>
>>     Implement UMH_KILLABLE, should be used along with UMH_WAIT_EXEC/PROC.  The
>>     caller must ensure that subprocess_info->path/etc can not go away until
>>     call_usermodehelper_freeinfo().
>> ...
>>
>> I think that my patch above does a much better/cleaner lifetime management of the
>> subprocess_info struct, with the use of a kref.
> 
> This is subjective, you know ;) I specially tried to avoid the
> refcounting.
> 

Why? 

The all kref_ abstraction comes to a simple atomic_inc/dec.
Which is in theory a more lite wait operation then xchg, no memory
bus locking, and in practice is the same. (Except on massively
parallel machines which it is)

The last time I submitted a patch with xchg I got clobbered on the head
so strong that I ran away from it as-fast-as-I-could.

For objects life cycle the kref_get/put pattern is a much simpler
more common and understood style in the Kernel, if just for that sake.

I don't see why it needs to be "avoided".

> In any case. I do not know why do we need timeout, but this is
> orthogonal to KILLABLE. Please redo your patches on top of -mm
> tree? Please note that in this case the change becomes trivial.
> 

Yes you are right. 

> And please explain the use-case for the new API.
> 

The reason I need a timeout, is because: Calling from Kernel to
user-mode gives me the creeps. I don't trust user-mode programs,
specially when in final Control by a Distribution. Bugs can happen
and deadlocks are a possibility. An operation that should take 
1/2 second and could max to at most 1.5 seconds, I can say in
confidence that after 15 seconds, a dmesg and a clean error recovery
is better. I don't want any chance of D stating IO operations.
(My code is in the IO path, either fsync or write-back. There is not
 always a killable target)

The code path I have is easily recoverable, and if not for the scary
message in dmesg the user will not notice.

So in short it is so I can sleep at night.

>> Anyway I thought that we are not
>> suppose to use xhcg() since it is not portable to all ARCHs. ;-)
> 
> Hmm. For example, exit_mm() does xchg().
> 

Again, Personally I like xchg, but not here, not for an object
life-time management. Two threads share a structure, that needs
to go when the last one ends. That's a kref_ abstraction. Kref,
inside, could be implemented with xchg(), But that's not for me to
decide, I should use good abstractions when they exist and do the
job (well). No?

> Oleg.
> 

Thanks Oleg, yes I'll rebase, Is there an mm git tree? I could not
find it on git://git.kernel.org/pub/scm/ . mean while I'll use a
random linux-next/master point. Which should do the job.

Thanks
Boaz
