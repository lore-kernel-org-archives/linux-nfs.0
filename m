Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:53961 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754017Ab1GGAHi (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 6 Jul 2011 20:07:38 -0400
Message-ID: <4E14F8C4.2010508@candelatech.com>
Date: Wed, 06 Jul 2011 17:07:32 -0700
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

I was hoping that if the killall logic never set anything that was also
set by the work-queue thread it would be lock-safe without needing
explicit locking.

I was a bit concerned that my flags |= KILLME logic would potentially
over-write flags that were being simultaneously written elsewhere
(so maybe I'd have to add a completely new variable for that KILLME flag
to really be safe.)

>
> How about the following instead?

I think it still races..more comments below.

>
> 8<----------------------------------------------------------------------------------
>  From ecb7244b661c3f9d2008ef6048733e5cea2f98ab Mon Sep 17 00:00:00 2001
> From: Trond Myklebust<Trond.Myklebust@netapp.com>
> Date: Wed, 6 Jul 2011 19:44:52 -0400
> Subject: [PATCH] SUNRPC: Fix a race between work-queue and rpc_killall_tasks
>
> Since rpc_killall_tasks may modify the rpc_task's tk_action field
> without any locking, we need to be careful when dereferencing it.

> +		do_action = task->tk_callback;
> +		task->tk_callback = NULL;
> +		if (do_action == NULL) {

I think the race still exists, though it would be harder to hit.
What if the killall logic sets task->tk_callback right after you assign do_action, but before
you set tk_callback to NULL?  Or after you set tk_callback to NULL for
that matter.

>   			/*
>   			 * Perform the next FSM step.
> -			 * tk_action may be NULL when the task has been killed
> -			 * by someone else.
> +			 * tk_action may be NULL if the task has been killed.
> +			 * In particular, note that rpc_killall_tasks may
> +			 * do this at any time, so beware when dereferencing.
>   			 */
> -			if (task->tk_action == NULL)
> +			do_action = task->tk_action;
> +			if (do_action == NULL)
>   				break;
> -			task->tk_action(task);
>   		}
> +		do_action(task);
>
>   		/*
>   		 * Lockless check for whether task is sleeping or not.

Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com

