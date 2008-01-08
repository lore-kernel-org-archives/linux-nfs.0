From: Peter Staubach <staubach@redhat.com>
Subject: Re: [PATCH 6/6] NLM: Add reference counting to lockd
Date: Tue, 08 Jan 2008 11:13:03 -0500
Message-ID: <4783A10F.1080604@redhat.com>
References: <1199534542-3384-1-git-send-email-jlayton@redhat.com>	<1199534542-3384-2-git-send-email-jlayton@redhat.com>	<1199534542-3384-3-git-send-email-jlayton@redhat.com>	<1199534542-3384-4-git-send-email-jlayton@redhat.com>	<1199534542-3384-5-git-send-email-jlayton@redhat.com>	<1199534542-3384-6-git-send-email-jlayton@redhat.com>	<1199534542-3384-7-git-send-email-jlayton@redhat.com>	<18307.7241.831689.998668@notabene.brown> <20080108082603.089718fc@tleilax.poochiereds.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Cc: Neil Brown <neilb@suse.de>, akpm@linux-foundation.org,
	linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
To: Jeff Layton <jlayton@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:33384 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750918AbYAHQNN (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 8 Jan 2008 11:13:13 -0500
In-Reply-To: <20080108082603.089718fc-RtJpwOs3+0O+kQycOl6kW4xkIHaj4LzF@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Jeff Layton wrote:
> On Tue, 8 Jan 2008 17:46:33 +1100
> Neil Brown <neilb@suse.de> wrote:
>
> The comments about patch 5/6 seem sane. I'll plan to incorporate them
> in the respin...
>
>   
>> On Saturday January 5, jlayton@redhat.com wrote:
>>     
>>> @@ -357,7 +375,18 @@ lockd_down(void)
>>>  		goto out;
>>>  	}
>>>  	warned = 0;
>>> -	kthread_stop(nlmsvc_task);
>>> +	if (atomic_sub_return(1, &nlmsvc_ref) != 0)
>>> +		printk(KERN_WARNING "lockd_down: lockd is waiting
>>> for "
>>> +			"outstanding requests to complete before
>>> exiting.\n");
>>>       
>> Why not "atomic_dec_and_test" ??
>>
>>     
>
> Temporary amnesia? :-) I'll change that, atomic_dec_and_test will be
> clearer.
>
>   
>>> +
>>> +	/*
>>> +	 * Sending a signal is necessary here. If we get to this
>>> point and
>>> +	 * nlm_blocked isn't empty then lockd may be held hostage
>>> by clients
>>> +	 * that are still blocking. Sending the signal makes sure
>>> that lockd
>>> +	 * invalidates all of its locks so that it's just waiting
>>> on RPC
>>> +	 * callbacks to complete
>>> +	 */
>>> +	kill_proc(nlmsvc_task->pid, SIGKILL, 1);
>>>       
>> The previous patch removes a kill_proc(... SIGKILL),  this one adds it
>> back.
>> That makes me wonder if the intermediate state is 'correct'.
>>
>> But I also wonder what "correct" means.
>> Do we want all locks to be dropped when the last nfsd thread dies?
>> The answer is presumably either "yes" or "no".
>> If "yes", then we don't have that because if there are any NFS mounts
>> active, lockd will not be killed.
>> If "no", then we don't want this kill_proc here.
>>
>> The comment in lockd() which currently reads:
>>
>> 	/*
>> 	 * The main request loop. We don't terminate until the last
>> 	 * NFS mount or NFS daemon has gone away, and we've been sent
>> a
>> 	 * signal, or else another process has taken over our job.
>> 	 */
>>
>> suggests that someone once thought that lockd could hang around after
>> all nfsd threads and nfs mounts had gone, but I don't think it does.
>>
>> We really should think this through and get it right, because if lockd
>> ever drops it's locks, then we really need to make sure sm_notify gets
>> run.  So it needs to be a well defined event.
>>
>> Thoughts?
>>
>>     
>
> This is the part I've been struggling with the most -- defining what
> proper behavior should be when lockd is restarted. As you point out,
> restarting lockd without doing a sm_notify could be bad news for data
> integrity.
>
> Then again, we'd like someone to be able to shut down the NFS "service"
> and be able to unmount underlying filesystems without jumping through
> special hoops....
>
> Overall, I think I'd vote "yes". We need to drop locks when the last
> nfsd goes down. If userspace brings down nfsd, then it's userspace's
> responsibility to make sure that a sm_notify is sent when nfsd and lockd
> are restarted.
>   

I would vote for the simplest possible model that makes sense.
We need a simple model for admins as well as a simple model
which is easy to implement in as bug free way as possible.  The
trick is not making it too simple because that can cost
performance, but not making it too complicated to implement
reasonably and for admins to be able to figure out.

So, I would vote for "yes" as well.  That will yield an
architecture where we can shutdown systems cleanly and will
be easy to understand when locks for clients exist and when
they do not.

    Thanx...

       ps



> As a side note, I'm not thrilled with this design that mixes signals
> and kthreads, but didn't see another way to do this. I'm open to
> suggestions if anyone has them...
>
>   
>> Also, it is sad that the inc/dec of nlmsvc_ref is called in somewhat
>> non-obvious ways.
>> e.g.
>>
>>     
>>> +	if (!nlmsvc_users && error)
>>> +		atomic_dec(&nlmsvc_ref);
>>>       
>> and
>>
>>     
>>> +	if (list_empty(&nlm_blocked))
>>> +		atomic_inc(&nlmsvc_ref);
>>> +
>>>  	if (list_empty(&block->b_list)) {
>>>  		kref_get(&block->b_count);
>>>  	} else {
>>>       
>> where if we moved the atomic_inc a little bit later next to the
>> "list_add_tail" (which seems to make more sense) it would actually be
>> wrong... But I think that code is correct as it is - just non-obvious.
>>
>>     
>
> The nlmsvc_ref logic is pretty convoluted, unfortunately. I'll plan to
> add some comments to clarify what I'm doing there.
>
> Thanks for the review, Neil. I'll see if I can get a new patchset done
> in the next few days.
>
> Cheers,
>   

