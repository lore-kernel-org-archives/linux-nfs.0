From: Rob Gardner <rob.gardner@hp.com>
Subject: Re: lockd and lock cancellation
Date: Thu, 01 Apr 2010 15:07:00 +0100
Message-ID: <4BB4A884.4080901@hp.com>
References: <1270124202.3354.40.camel@localhost>  <4BB4945B.4040106@hp.com> <1270127630.3354.52.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Cc: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
	"eshel@almaden.ibm.com" <eshel@almaden.ibm.com>
To: Steven Whitehouse <swhiteho@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from g4t0017.houston.hp.com ([15.201.24.20]:18860 "EHLO
	g4t0017.houston.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756729Ab0DAOG1 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 1 Apr 2010 10:06:27 -0400
In-Reply-To: <1270127630.3354.52.camel@localhost>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Steven Whitehouse wrote:
> Hi,
>
> Thanks for the fast response...
>
> On Thu, 2010-04-01 at 13:40 +0100, Rob Gardner wrote:
>   
>> Steven Whitehouse wrote:
>>     
>>> Hi,
>>>
>>> I'm trying to find my way around the lockd code and I'm currently a bit
>>> stumped by the code relating to lock cancellation. There is only one
>>> call to vfs_cancel_lock() in lockd/svclock.c and its return value isn't
>>> checked.
>>>
>>> It is used in combination with nlmsvc_unlink_block() which
>>> unconditionally calls posix_unblock_lock(). There are also other places
>>> where the code also calls nlmsvc_unlink_block() without first canceling
>>> the lock. The way in which vfs_cancel_lock() is used suggests that
>>> canceling a lock is a synchronous operation, and that it must succeed
>>> before returning.
>>>
>>> I'd have expected to see (pseudo code) something more like the
>>> following:
>>>
>>> ret = vfs_cancel_lock();
>>> if (ret == -ENOENT) /* never had the lock in the first place */
>>>     do_something_appropriate();
>>> else if (ret == -EINVAL) /* we raced with a grant */
>>>     unlock_lock();
>>> else /* lock successfully canceled */
>>>     nlmsvc_unlink_block();
>>>
>>> Is there a reason why that is not required? and indeed, is there a
>>> reason why its safe to call nlmsvc_unlink_block() in the cases where the
>>> lock isn't canceled first? I'm trying to work out how the underlying fs
>>> can tell that a lock has gone away in those particular cases,
>>>   
>>>       
>> Steve,
>>
>> I noticed the missing cancel scenario some time ago and reported on it 
>> here. Bruce agreed that it was a bug, but I regret that I haven't had 
>> time to follow up on it. The problem was that vfs_cancel_lock was not 
>> being called in all cases where it should be, possibly resulting in an 
>> orphaned lock in the filesystem. See attached message for more detail. 
>> (Or http://marc.info/?l=linux-nfs&m=125849395630496&w=2)
>>
>>     
> I have one question relating to that message (see below)
>
>   
>> By the way, if a lock grant wins a race with a cancel, I do not think it 
>> is "safe" to simply unlock the lock at that point.
>>
>>     
> Why not? If the cancel has failed, then we are left holding the lock
> just as if we'd requested it and no cancel had been issued. Or another
> way to ask the same question, if that does occur, what would be the
> correct way to dispose of the unwanted lock?
>   

If the lock were actually granted, then unlocking in lieu of a cancel 
can potentially leave a range unlocked that should be left locked. This 
can happen in the case of a lock upgrade or a coalesce operation; For 
instance, suppose the client holds a lock on bytes 0-100, then issues 
another lock request for bytes 50-150, but sends a cancel just after the 
lock is actually granted. If you now simply unlock 50-150, then the 
client is left holding only 0-50, and has "lost" the lock on bytes 
51-100. In other words, the client will *believe* that he has 0-100 
locked, but in reality, only 0-50 are locked.

As for what to do in this situation... well it would be nice if the 
filesystem treated the cancel request as an "undo" if the grant won the 
race. But seriously, I think this is just one of the (many) flaws in the 
protocol and we probably have to live with it. My personal feeling is 
that it's safer to leave bytes locked rather than have a client believe 
it holds a lock when it doesn't.

> [snip]
>   
>> Seems reasonable, though it is a bit annoying trying to determine which
>> of these should be called where, so...
>>
>>     
>>> Another possibility is to change nlmsvc_unlink_block() to make the call to
>>> vfs_cancel_lock() and then remove the call to vfs_cancel_lock in
>>> nlmsvc_cancel_blocked(). But I don't really like this as most other
>>> calls to nlmsvc_unlink_block() do not require a call to vfs_cancel_lock().
>>>       
>> ..yes, I understand why the ideal initially appeals, but don't have a
>> better suggestion.
>>
>> --b.
>>
>>     
>
> Can we not use a flag to figure out when a cancel needs to be sent? We
> could set the flag when an async request was sent to the underlying fs
> and clear it when the reply arrives. It would thus only be valid to send
> a vfs_cancel_lock() request when the flag was set.
>   
We could do all this, but I don't see the point, since there is still a 
race window you could sail a boat through. It's the period of time 
between when the client sends a cancel request and the time that lockd 
sends the cancel request to the filesystem. If a grant happens during 
this time, what can be done? The protocol just doesn't have a way to 
deal with this.

> My other thought is whether or not posix_unblock_lock() could be merged
> into vfs_cancel_lock() or whether there are really cases where that
> needs to be called without a cancellation having taken place,

I think that the filesystem should do the posix_unblock_lock call when 
it (successfully?) processes a cancel request. After all, the fs is 
already calling posix_lock_file when it successfully grants a lock. And 
just as vfs_lock_file falls through to posix_lock_file when the fs 
doesn't provide a lock function, so should vfs_cancel_lock fall through 
to posix_unblock_lock in that situation.


Rob Gardner

