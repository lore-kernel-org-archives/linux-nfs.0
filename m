From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: Huge race in lockd for async lock requests?
Date: Thu, 28 May 2009 16:05:23 -0400
Message-ID: <20090528200523.GE13860@fieldses.org>
References: <4A0D80B6.4070101@redhat.com> <4A0D9D63.1090102@hp.com> <4A11657B.4070002@redhat.com> <4A1168E0.3090409@hp.com> <4A1319F9.90304@hp.com> <4A13A973.4050703@hp.com> <4a140d0a.85c2f10a.53bc.0979@mx.google.com> <4A1431B1.6080708@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: tmtalpey@gmail.com,
	"linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
To: Rob Gardner <rob.gardner@hp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([141.211.133.115]:54298 "EHLO
	pickle.fieldses.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760865AbZE1UFX (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 28 May 2009 16:05:23 -0400
In-Reply-To: <4A1431B1.6080708@hp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, May 20, 2009 at 10:37:05AM -0600, Rob Gardner wrote:
> Tom Talpey wrote:
>> At 02:55 AM 5/20/2009, Rob Gardner wrote:
>>   
>>> Tom Talpey wrote:
>>>     
>>>> At 04:43 PM 5/19/2009, Rob Gardner wrote:
>>>>       
>>>>> I've got a question about lockd in conjunction with a filesystem 
>>>>> that provides its own (async) locking.
>>>>>
>>>>> After nlmsvc_lock() calls vfs_lock_file(), it seems to be that we 
>>>>> might get the async callback (nlmsvc_grant_deferred) at any time. 
>>>>> What's to stop it from arriving before we even put the block on 
>>>>> the nlm_block list? If this happens, then nlmsvc_grant_deferred() 
>>>>> will print "grant for unknown block" and then we'll wait forever 
>>>>> for a grant that will never come.
>>>>>         
>>>> Yes, there's a race but the client will retry every 30 seconds, so it won't
>>>> wait forever.
>>>>       
>>> OK, a blocking lock request will get retried in 30 seconds and work 
>>> out "ok". But a non-blocking request will get in big trouble. Let's 
>>> say the     
>>
>> A non-blocking lock doesn't request, and won't get, a callback. So I
>> don't understand...
>>
>>   
>
> What do you mean a non-blocking lock doesn't request? Remember that I'm  
> dealing with a filesystem that provides its own locking functions via  
> file->f_op->lock(). Such a filesystem might easily defer a non-blocking  
> lock request and invoke the callback later. At least I don't know of any  
> rule that says that it can't do this, and clearly the code expects this  
> possibility:
>
>              case FILE_LOCK_DEFERRED:
>                        if (wait)
>                                break;
>                        /* Filesystem lock operation is in progress
>                           Add it to the queue waiting for callback */
>                        ret = nlmsvc_defer_lock_rqst(rqstp, block);
>
>
>>> callback is invoked immediately after the vfs_lock_file call returns  
>>> FILE_LOCK_DEFERRED. At this point, the block is not on the nlm_block  
>>> list, so the callback routine will not be able to find it and mark it 
>>> as granted. Then nlmsvc_lock() will call nlmsvc_defer_lock_rqst(), 
>>> put the block on the nlm_block list, and eventually the request will 
>>> timeout and the client will get lck_denied. Meanwhile, the lock has 
>>> actually been granted, but nobody knows about it.
>>>     
>>
>> Yes, this can happen, I've seen it too. Again, it's a bug in the protocol
>> more than a bug in the clients. 
> It looks to me like a bug in the server. The server must be able to deal  
> with async filesystem callbacks happening at any time, however 
> inconvenient.

Absolutely, if that's possible then it's a server bug.

--b.
