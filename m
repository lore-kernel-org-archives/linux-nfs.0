Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:38431 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752070Ab1GHRSc (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 8 Jul 2011 13:18:32 -0400
Message-ID: <4E173BE6.9000005@candelatech.com>
Date: Fri, 08 Jul 2011 10:18:30 -0700
From: Ben Greear <greearb@candelatech.com>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
CC: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
Subject: Re: [RFC] sunrpc:  Fix race between work-queue and rpc_killall_tasks.
References: <1309992581-25199-1-git-send-email-greearb@candelatech.com> <1309995932.5447.6.camel@lade.trondhjem.org>
In-Reply-To: <1309995932.5447.6.camel@lade.trondhjem.org>
Content-Type: text/plain; charset=UTF-8; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 07/06/2011 04:45 PM, Trond Myklebust wrote:
> On Wed, 2011-07-06 at 15:49 -0700, greearb@candelatech.com wrote:
>> From: Ben Greear<greearb@candelatech.com>
>>
>> The rpc_killall_tasks logic is not locked against
>> the work-queue thread, but it still directly modifies
>> function pointers and data in the task objects.
>>
>> This patch changes the killall-tasks logic to set a flag
>> that tells the work-queue thread to terminate the task
>> instead of directly calling the terminate logic.
>>
>> Signed-off-by: Ben Greear<greearb@candelatech.com>
>> ---
>>
>> NOTE:  This needs review, as I am still struggling to understand
>> the rpc code, and it's quite possible this patch either doesn't
>> fully fix the problem or actually causes other issues.  That said,
>> my nfs stress test seems to run a bit more stable with this patch applied.
>
> Yes, but I don't see why you are adding a new flag, nor do I see why we
> want to keep checking for that flag in the rpc_execute() loop.
> rpc_killall_tasks() is not a frequent operation that we want to optimise
> for.
>
> How about the following instead?

Ok, I looked at your patch closer.  I think it can still cause
bad race conditions.

For instance:

Assume that tk_callback is NULL at beginning of while loop in __rpc_execute,
and tk_action is rpc_exit_task.

While do_action(task) is being called, tk_action is set to NULL in rpc_exit_task.

But, right after tk_action is set to NULL in rpc_exit_task, the rpc_killall_tasks
method calls rpc_exit, which sets tk_action back to rpc_exit_task.

I believe this could cause the xprt_release(task) logic to be called in the
work-queue's execution of rpc_exit_task due to tk_action != NULL when
it should not be.

I have no hard evidence this exact scenario is happening in my case, but I
believe the code is still racy with your patch.

For that matter, is it safe to modify the flags in rpc_killall_tasks:

rovr->tk_flags |= RPC_TASK_KILLED;

Is that guaranteed to be atomic with any other modification of flags?

Thanks,
Ben


-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com

