Return-Path: linux-nfs-owner@vger.kernel.org
Received: from natasha.panasas.com ([67.152.220.90]:34710 "EHLO
	natasha.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750825Ab2CWEtX (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 23 Mar 2012 00:49:23 -0400
Message-ID: <4F6C0092.1010901@panasas.com>
Date: Thu, 22 Mar 2012 21:48:18 -0700
From: Boaz Harrosh <bharrosh@panasas.com>
MIME-Version: 1.0
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
CC: <oleg@redhat.com>, <akpm@linux-foundation.org>, <rjw@sisk.pl>,
        <keyrings@linux-nfs.org>, <linux-security-module@vger.kernel.org>,
        <linux-fsdevel@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
        <linux-nfs@vger.kernel.org>, <Trond.Myklebust@netapp.com>,
        <sbhamare@panasas.com>, <dhowells@redhat.com>, <eparis@redhat.com>,
        <srivatsa.bhat@linux.vnet.ibm.com>, <kay.sievers@vrfy.org>,
        <jmorris@namei.org>, <ebiederm@xmission.com>,
        <gregkh@linuxfoundation.org>, <rusty@rustcorp.com.au>, <tj@kernel.org>,
        <rientjes@google.com>
Subject: Re: [RFC 4/4] {RFC} kmod.c: Add new call_usermodehelper_timeout()API
References: <4F691059.30405@panasas.com> <4F691383.5040506@panasas.com> <4F6A92FC.6060702@panasas.com> <20120322142758.GA12370@redhat.com> <4F6B789C.8020201@panasas.com> <201203230716.GFE32712.StOJOVFHMQOFFL@I-love.SAKURA.ne.jp>
In-Reply-To: <201203230716.GFE32712.StOJOVFHMQOFFL@I-love.SAKURA.ne.jp>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 03/22/2012 03:16 PM, Tetsuo Handa wrote:

> Boaz Harrosh wrote:
>>> And please explain the use-case for the new API.
>>>
>>
>> The reason I need a timeout, is because: Calling from Kernel to
>> user-mode gives me the creeps. I don't trust user-mode programs,
> 
> If you can't trust user-mode programs executed via call_usermodehelper(),
> you should not use call_usermodehelper(). It is executed with full privileges.
> What if the program executed via call_usermodehelper() was
> 
>   #! /bin/sh
>   exec /bin/rm -fr /
> 
> ?
> 


You missed my point. I meant unintentional bugs, heavy load, mis-configuration
Administrator mistake. If the admin *wants*  /bin/rm -fr / that's
fine he does not need me.

>> specially when in final Control by a Distribution. Bugs can happen
>> and deadlocks are a possibility.
> 
> Userspace process can be killed at any time.
> Deadlock in userspace is less problematic than deadlock in kernel.
> 

>> An operation that should take

>> 1/2 second and could max to at most 1.5 seconds, I can say in
>> confidence that after 15 seconds, a dmesg and a clean error recovery
>> is better.
> 
> Userspace process can block for long time. For example, under heavy load and
> memory slashing. It is hardly possible to embed appropriate timeout value into
> kernel code.
> 


That's fine. I will fail totally gracefully, and nothing will happen. I like this
example if the system is under heavy load and there is no memory and the
iscsi auto-login takes more then 15 second (Settable by module param) then I'd
rather fail the login and revert to plain NFS-MDS IO, instead of the direct osd-target
IO. Believe me.

>> I don't want any chance of D stating IO operations.
>> (My code is in the IO path, either fsync or write-back. There is not
>>  always a killable target)
> 
> Then, isn't UMH_NO_WAIT better than UMH_WAIT_PROC?
> 


No I need to wait for the application to finish the iscsi login before
I can continue IO to the target. Otherwise what's the point.

>> The code path I have is easily recoverable, and if not for the scary
>> message in dmesg the user will not notice.
> 
> What does your code path do if it raced with timeout (i.e. kernel code begins
> recovery operation (thinking that the request failed) while userspace code
> completes what the userspace code was asked to do (thinking that the request
> succeeded))?
> 


As I said that's completely fine. Please give me a bit of Credit.
The IO in question would revert to NFS-MDS IO. Since the login succeeded
eventually, the next time the device is looked for it will be found and future
IO will be fast direct to storage. Perfectly fine.

They can race as much as they want. 

> I think you should use a fork()ed wrapper in userspace for implementing
> timeout.
> 


I did that actually. But I would like not to be dependent on it. I would like
the Kernel to be independent and simple timeout and recover, as you said
even the very first execv can timeout in an overloaded system. In that case
I'd like to fail as well and revert to slower IO.

>   Userspace process - Create child and wait for appropriate timeout and exit.
>     Child of userspace process - Create grandchild and wait for completion of
>                                  grandchild. Tell (or recreate) grandchild to
>                                  undo what the grandchild was supposed to do
>                                  if parent dies before grandchild dies.
> 
>       Grandchild of userspace process - Do what parent told me to do. Undo if
>                                         parent told me to undo.


We did that here:
	http://thread.gmane.org/gmane.linux.nfs/47921/focus=48182

But again I'd prefer Kernel independence in those matters

Cheers
Boaz
