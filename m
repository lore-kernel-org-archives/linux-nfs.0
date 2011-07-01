Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:37627 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755293Ab1GASsc (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 1 Jul 2011 14:48:32 -0400
Message-ID: <4E0E166A.7080908@candelatech.com>
Date: Fri, 01 Jul 2011 11:48:10 -0700
From: Ben Greear <greearb@candelatech.com>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
CC: linux-nfs@vger.kernel.org
Subject: Re: Potential locking issue in sunrpc
References: <4E0CE5E9.2090401@candelatech.com> <1309545459.5230.25.camel@lade.trondhjem.org>
In-Reply-To: <1309545459.5230.25.camel@lade.trondhjem.org>
Content-Type: text/plain; charset=UTF-8; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 07/01/2011 11:37 AM, Trond Myklebust wrote:
> On Thu, 2011-06-30 at 14:08 -0700, Ben Greear wrote:
>> This method in sched.c says we should have a lock for ASYNC
>>
>> /*
>>    * Make an RPC task runnable.
>>    *
>>    * Note: If the task is ASYNC, this must be called with
>>    * the spinlock held to protect the wait queue operation.
>>    */
>> static void rpc_make_runnable(struct rpc_task *task)
>>
>> However, I don't think the lock is being taken for
>> the call path starting with rpcb_call_async in
>> rpcb_clnt.c:
>>
>> rpcb_call_async
>> rpc_run_task
>> rpc_execute
>> rpc_make_runnable
>>
>> Is the comment on the make_runnable method wrong, or are we missing locking?
>
> Neither. In the above case, we are not waking up from a wait queue, so
> there are no locks involved.

Ok.  That MUST in the comment could have a caveat, but either way,
looks like that locking isn't an issue so I'll have to look elsewhere.

I'm seeing a worker-thread making calls on tasks that have
already been freed.  Takes very long time (hours or days) to reproduce,
as well as my patches to support lots of client mounts by binding to IP.

Our test case is to create 200 client mounts, start low-speed O_DIRECT
traffic on each mount, run for 15-45 seconds, un-mount, repeat.

Do you have any suggestions for how this sort of thing might happen?

Like if something added the task to the work-queue, and then deleted it
before the task was run, or perhaps some sort of corruption/race while
adding it to the work-queue?

Calling memset to zero out the task right before giving it back to the
mempool makes it much harder to reproduce, but eventually we do see
a null-pointer exception with something trying to access that task's
memory.

It seems reliably related to rpcb_clnt logic that creates an async, dynamic
task.

I'll be happy to re-post the traces from slub debugging
if you have interest in seeing them.

Thanks,
Ben


>
> Trond
>


-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com

