From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: Huge race in lockd for async lock requests?
Date: Thu, 28 May 2009 20:26:36 -0400
Message-ID: <20090529002636.GA19184@fieldses.org>
References: <4A0D80B6.4070101@redhat.com> <4A0D9D63.1090102@hp.com> <4A11657B.4070002@redhat.com> <4A1168E0.3090409@hp.com> <4A1319F9.90304@hp.com> <4A13A973.4050703@hp.com> <4a140d0a.85c2f10a.53bc.0979@mx.google.com> <4A1431B1.6080708@hp.com> <20090528200523.GE13860@fieldses.org> <4A1F035B.4040306@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "tmtalpey@gmail.com" <tmtalpey@gmail.com>,
	"linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
To: Rob Gardner <rob.gardner@hp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([141.211.133.115]:51454 "EHLO
	pickle.fieldses.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751394AbZE2A0f (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 28 May 2009 20:26:35 -0400
In-Reply-To: <4A1F035B.4040306@hp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, May 28, 2009 at 03:34:19PM -0600, Rob Gardner wrote:
> J. Bruce Fields wrote:
>>>>>> At 04:43 PM 5/19/2009, Rob Gardner wrote:
>>>>>>                 
>>>>>>> I've got a question about lockd in conjunction with a 
>>>>>>> filesystem that provides its own (async) locking.
>>>>>>>
>>>>>>> After nlmsvc_lock() calls vfs_lock_file(), it seems to be 
>>>>>>> that we might get the async callback (nlmsvc_grant_deferred) 
>>>>>>> at any time. What's to stop it from arriving before we even 
>>>>>>> put the block on the nlm_block list? If this happens, then 
>>>>>>> nlmsvc_grant_deferred() will print "grant for unknown block" 
>>>>>>> and then we'll wait forever for a grant that will never come.
>>>>>>>     
>>> dealing with a filesystem that provides its own locking functions via 
>>>  file->f_op->lock(). Such a filesystem might easily defer a 
>>> non-blocking  lock request and invoke the callback later. At least I 
>>> don't know of any  rule that says that it can't do this, and clearly 
>>> the code expects this  possibility:
>>>
>>>              case FILE_LOCK_DEFERRED:
>>>                        if (wait)
>>>                                break;
>>>                        /* Filesystem lock operation is in progress
>>>                           Add it to the queue waiting for callback */
>>>                        ret = nlmsvc_defer_lock_rqst(rqstp, block);
>>>
>>>     It looks to me like a bug in the server. The server must be able 
>>> to deal  with async filesystem callbacks happening at any time, 
>>> however inconvenient.
>>>     
>>
>> Absolutely, if that's possible then it's a server bug.
>>
>> --b.
>>   
>
> It's definitely possible for the async filesystem callback to occur at  
> any time.

Looking at the code....  This is all under the BKL, and as far as I can
tell there aren't any blocking operations anywhere there, so I don't
think this should happen if the filesystem is careful.  Have you seen it
happen?

Of course this may be fragile--we'll have to think about what to do when
we eventually remove the BKL.

--b.

> I think at the very least, nlmsvc_lock() ought to put the  
> block on the nlm_block list *before* calling vfs_lock_file(), and then  
> remove it immediately if the lock is granted synchronously. I would like  
> to develop and submit a patch for this, but I am currently working with  
> a much older kernel and it will take some time before I get to work with  
> newer bits.
