From: Boaz Harrosh <bharrosh@panasas.com>
Subject: Re: [PATCH] pnfs: devide put_lseg and return_layout_barrier into
 	different workqueue
Date: Sun, 23 May 2010 12:36:20 +0300
Message-ID: <4BF8F714.8000002@panasas.com>
References: <20100517095941.GA10823@MDS-78.localdomain>	 <4BF11B7F.2090800@panasas.com> <AANLkTimhsjIISik5KvAHDwbEWVdU_wrRPepfXYy30Brl@mail.gmail.com> <4BF1890E.90606@panasas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Zhang Jingwang <yyalone@gmail.com>,
	Zhang Jingwang <zhangjingwang-U4AKAne5IzAR5TUyvShJeg@public.gmane.org>,
	linux-nfs@vger.kernel.org
To: Benny Halevy <bhalevy@panasas.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:62972 "EHLO
	daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753882Ab0EWJgX (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 23 May 2010 05:36:23 -0400
In-Reply-To: <4BF1890E.90606@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 05/17/2010 09:21 PM, Benny Halevy wrote:
> On 2010-05-17 20:37, Zhang Jingwang wrote:
>> 2010/5/17 Boaz Harrosh <bharrosh@panasas.com>:
>>> On 05/17/2010 12:59 PM, Zhang Jingwang wrote:
>>>> These two functions mustn't be called from the same workqueue. Otherwise
>>>> deadlock may occur. So we schedule the return_layout_barrier to nfsiod.
>>>> nfsiod may not be a good choice, maybe we should setup a new workqueue
>>>> to do the job.
>>>
>>> Please give more information. When does it happen that pnfs_XXX_done will
>>> return -EAGAIN?
>> network error or something else.
>>
>>>
>>> What is the stack trace of the deadlock?
>>>
>> http://linux-nfs.org/pipermail/pnfs/2010-January/009939.html
>>
>>> And please rebase that patch on the latest changes to _pnfs_return_layout().
>>> but since in the new code _pnfs_return_layout() must be called with NO_WAIT
>>> if called from the nfsiod then you cannot call pnfs_initiate_write/read() right
>>> after. For writes you can get by with doing nothing because the write-back
>>> thread will kick in soon enough. For reads I'm not sure, you'll need to send
>>> me more information, stack trace.
>>>
>>> Or you can wait for the new state machine.
>> I think the reason of this deadlock is that the put and the wait are
>> in the same workqueue and run serially. So the state machine will not
>> help.
> 
> I think what you did is right for the time being and I'll merge
> it until we have something better.
> The state machine should help in this case since it will effectively
> switch contexts between two tasks rather than blocking synchronously.
> 
> Benny
> 

No! it is not. The patch below is based on the old code.
If it was done over new code then you would have seen that
the pnfs_{write,read}_retry must call _pnfs_return_layout(,NO_WAIT)
without waiting because it is called from the nfsiod_workqueue.
But if it is not waiting then there is no point in calling
pnfs_initiate_{write,read}().

For writes we can safely remove the call, for reads I would need
to check what's best to do.

Boaz
