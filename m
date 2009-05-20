From: Tom Talpey <tmtalpey@gmail.com>
Subject: Re: Huge race in lockd for async lock requests?
Date: Wed, 20 May 2009 10:14:45 -0400
Message-ID: <4a14106e.48c3f10a.7ce3.0e55@mx.google.com>
References: <4A0D80B6.4070101@redhat.com>
 <4A0D9D63.1090102@hp.com>
 <4A11657B.4070002@redhat.com>
 <4A1168E0.3090409@hp.com>
 <4A1319F9.90304@hp.com>
 <4A13A973.4050703@hp.com>
 <4a140d0a.85c2f10a.53bc.0979@mx.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
To: Rob Gardner <rob.gardner@hp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qy0-f180.google.com ([209.85.221.180]:42567 "EHLO
	mail-qy0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753281AbZETOPL (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 20 May 2009 10:15:11 -0400
Received: by qyk10 with SMTP id 10so715665qyk.33
        for <linux-nfs@vger.kernel.org>; Wed, 20 May 2009 07:15:11 -0700 (PDT)
In-Reply-To: <4a140d0a.85c2f10a.53bc.0979-ATjtLOhZ0NVl57MIdRCFDg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

At 10:00 AM 5/20/2009, Tom Talpey wrote:
>At 02:55 AM 5/20/2009, Rob Gardner wrote:
>>Tom Talpey wrote:
>>> At 04:43 PM 5/19/2009, Rob Gardner wrote:
>>> >I've got a question about lockd in conjunction with a filesystem that 
>>> >provides its own (async) locking.
>>> >
>>> >After nlmsvc_lock() calls vfs_lock_file(), it seems to be that we might 
>>> >get the async callback (nlmsvc_grant_deferred) at any time. What's to 
>>> >stop it from arriving before we even put the block on the nlm_block 
>>> >list? If this happens, then nlmsvc_grant_deferred() will print "grant 
>>> >for unknown block" and then we'll wait forever for a grant that will 
>>> >never come.
>>>
>>> Yes, there's a race but the client will retry every 30 seconds, so it won't
>>> wait forever.
>>OK, a blocking lock request will get retried in 30 seconds and work out 
>>"ok". But a non-blocking request will get in big trouble. Let's say the 
>
>A non-blocking lock doesn't request, and won't get, a callback. So I
>don't understand...
>
>>callback is invoked immediately after the vfs_lock_file call returns 
>>FILE_LOCK_DEFERRED. At this point, the block is not on the nlm_block 
>>list, so the callback routine will not be able to find it and mark it as 
>>granted. Then nlmsvc_lock() will call nlmsvc_defer_lock_rqst(), put the 
>>block on the nlm_block list, and eventually the request will timeout and 
>>the client will get lck_denied. Meanwhile, the lock has actually been 
>>granted, but nobody knows about it.
>
>Yes, this can happen, I've seen it too. Again, it's a bug in the protocol
>more than a bug in the clients. It gets even worse when retries occur.
>If the reply cache doesn't catch the duplicates (and it never does), all
>heck breaks out.
>
>>
>>>  Depending on the kernel client version, there are some
>>> improvements we've tried over time to close the raciness a little. What
>>> exact client version are you working with?
>>>   
>>
>>I maintain nfs/nlm server code for a NAS product, and so there is no 
>>"exact client" but rather a multitude of clients that I have no control 
>>over. All I can do is hack the server. We have been working around this 
>
>I feel for ya (been there, done that) :-)
>
>>by using a semaphore to cover the vfs_lock_file() to 
>>nlmsvc_insert_block() sequence in nlmsvc_lock() and also 
>>nlmsvc_grant_deferred(). So if the callback arrives at a bad time, it 
>>has to wait until the lock actually makes it onto the nlm_block list, 
>>and so the status of the lock gets updated properly.
>
>Can you explain this further? If you're implementing the server, how do
>you know your callback "arrives at a bad time", by the DENIED result
>from the client?
>
>Another thing to worry about is the presence of NLM_CANCEL calls
>from the client which cross the callbacks. 
>
>I sent a patch which improves the situation at the client, some time
>ago. Basically it was more willing to positively acknowledge a callback
>which didn't match the nlm_blocked list, by also checking whether the
>lock was actually being held. This was only half the solution however,
>it didn't close the protocol race, just the client one. You want the
>patch? I'll look for it.

Found it, on the old nfs list:

http://thread.gmane.org/gmane.linux.nfs/16611

Tom.

>
>>
>>> Use NFSv4? ;-)
>>>   
>>
>>I had a feeling you were going to say that. ;-)  Unfortunately that 
>>doesn't make NFSv3 and lockd go away.
>
>Yes, I know. Unfortunately there aren't any elegant solutions to
>the NLM protocol's flaws.
>
>Tom.

