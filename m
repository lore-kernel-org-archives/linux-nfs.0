From: Rob Gardner <rob.gardner@hp.com>
Subject: Re: Huge race in lockd for async lock requests?
Date: Wed, 20 May 2009 10:37:05 -0600
Message-ID: <4A1431B1.6080708@hp.com>
References: <4A0D80B6.4070101@redhat.com> <4A0D9D63.1090102@hp.com> <4A11657B.4070002@redhat.com> <4A1168E0.3090409@hp.com> <4A1319F9.90304@hp.com> <4A13A973.4050703@hp.com> <4a140d0a.85c2f10a.53bc.0979@mx.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
To: tmtalpey@gmail.com,
	"linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from g5t0006.atlanta.hp.com ([15.192.0.43]:9356 "EHLO
	g5t0006.atlanta.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754184AbZETQhF (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 20 May 2009 12:37:05 -0400
In-Reply-To: <4a140d0a.85c2f10a.53bc.0979-ATjtLOhZ0NVl57MIdRCFDg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Tom Talpey wrote:
> At 02:55 AM 5/20/2009, Rob Gardner wrote:
>   
>> Tom Talpey wrote:
>>     
>>> At 04:43 PM 5/19/2009, Rob Gardner wrote:
>>>       
>>>> I've got a question about lockd in conjunction with a filesystem that 
>>>> provides its own (async) locking.
>>>>
>>>> After nlmsvc_lock() calls vfs_lock_file(), it seems to be that we might 
>>>> get the async callback (nlmsvc_grant_deferred) at any time. What's to 
>>>> stop it from arriving before we even put the block on the nlm_block 
>>>> list? If this happens, then nlmsvc_grant_deferred() will print "grant 
>>>> for unknown block" and then we'll wait forever for a grant that will 
>>>> never come.
>>>>         
>>> Yes, there's a race but the client will retry every 30 seconds, so it won't
>>> wait forever.
>>>       
>> OK, a blocking lock request will get retried in 30 seconds and work out 
>> "ok". But a non-blocking request will get in big trouble. Let's say the 
>>     
>
> A non-blocking lock doesn't request, and won't get, a callback. So I
> don't understand...
>
>   

What do you mean a non-blocking lock doesn't request? Remember that I'm 
dealing with a filesystem that provides its own locking functions via 
file->f_op->lock(). Such a filesystem might easily defer a non-blocking 
lock request and invoke the callback later. At least I don't know of any 
rule that says that it can't do this, and clearly the code expects this 
possibility:

              case FILE_LOCK_DEFERRED:
                        if (wait)
                                break;
                        /* Filesystem lock operation is in progress
                           Add it to the queue waiting for callback */
                        ret = nlmsvc_defer_lock_rqst(rqstp, block);


>> callback is invoked immediately after the vfs_lock_file call returns 
>> FILE_LOCK_DEFERRED. At this point, the block is not on the nlm_block 
>> list, so the callback routine will not be able to find it and mark it as 
>> granted. Then nlmsvc_lock() will call nlmsvc_defer_lock_rqst(), put the 
>> block on the nlm_block list, and eventually the request will timeout and 
>> the client will get lck_denied. Meanwhile, the lock has actually been 
>> granted, but nobody knows about it.
>>     
>
> Yes, this can happen, I've seen it too. Again, it's a bug in the protocol
> more than a bug in the clients. 
It looks to me like a bug in the server. The server must be able to deal 
with async filesystem callbacks happening at any time, however inconvenient.



> It gets even worse when retries occur.
> If the reply cache doesn't catch the duplicates (and it never does), all
> heck breaks out.
>   
You'll have to explain further what scenario you're talking about. I 
don't understand what the reply cache has to do with lockd.

>> by using a semaphore to cover the vfs_lock_file() to 
>> nlmsvc_insert_block() sequence in nlmsvc_lock() and also 
>> nlmsvc_grant_deferred(). So if the callback arrives at a bad time, it 
>> has to wait until the lock actually makes it onto the nlm_block list, 
>> and so the status of the lock gets updated properly.
>>     
>
> Can you explain this further? If you're implementing the server, how do
> you know your callback "arrives at a bad time", by the DENIED result
> from the client?
>   

I sense a little confusion so let me be more precise. By "callback" I am 
talking about the callback from the filesystem to lockd via 
lock_manager_operations.fl_grant (ie, nlmsvc_grant_deferred). If this 
callback is invoked while the lockd thread is executing code in 
nlmsvc_lock() between the call to vfs_lock_file() and the call to 
nlmsvc_insert_block(), then the callback routine (nlmsvc_grant_deferred) 
will not find the block on the nlm_block list because it's not there 
yet, and thus the "grant" is effectively lost. We use a semaphore in 
nlmsvc_lock() and nlmsvc_grant_deferred() to avoid this race.


Rob Gardner



