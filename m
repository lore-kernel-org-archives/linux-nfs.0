From: Boaz Harrosh <bharrosh@panasas.com>
Subject: Re: [PATCH] pnfs: devide put_lseg and return_layout_barrier into
 	different workqueue
Date: Sun, 23 May 2010 21:27:08 +0300
Message-ID: <4BF9737C.6030907@panasas.com>
References: <20100517095941.GA10823@MDS-78.localdomain>	 <4BF11B7F.2090800@panasas.com> <AANLkTimhsjIISik5KvAHDwbEWVdU_wrRPepfXYy30Brl@mail.gmail.com> <4BF1890E.90606@panasas.com> <4BF8F714.8000002@panasas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Zhang Jingwang <yyalone@gmail.com>,
	Zhang Jingwang <zhangjingwang-U4AKAne5IzAR5TUyvShJeg@public.gmane.org>,
	linux-nfs@vger.kernel.org
To: Benny Halevy <bhalevy@panasas.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.154]:55495 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754921Ab0EWS1Q (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 23 May 2010 14:27:16 -0400
Received: by fg-out-1718.google.com with SMTP id 22so1010136fge.1
        for <linux-nfs@vger.kernel.org>; Sun, 23 May 2010 11:27:15 -0700 (PDT)
In-Reply-To: <4BF8F714.8000002@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 05/23/2010 12:36 PM, Boaz Harrosh wrote:
> On 05/17/2010 09:21 PM, Benny Halevy wrote:
>> On 2010-05-17 20:37, Zhang Jingwang wrote:
>>> 2010/5/17 Boaz Harrosh <bharrosh@panasas.com>:
>>>> On 05/17/2010 12:59 PM, Zhang Jingwang wrote:
>>>>> These two functions mustn't be called from the same workqueue. Otherwise
>>>>> deadlock may occur. So we schedule the return_layout_barrier to nfsiod.
>>>>> nfsiod may not be a good choice, maybe we should setup a new workqueue
>>>>> to do the job.
>>>>
>>>> Please give more information. When does it happen that pnfs_XXX_done will
>>>> return -EAGAIN?
>>> network error or something else.
>>>
>>>>
>>>> What is the stack trace of the deadlock?
>>>>
>>> http://linux-nfs.org/pipermail/pnfs/2010-January/009939.html
>>>
>>>> And please rebase that patch on the latest changes to _pnfs_return_layout().
>>>> but since in the new code _pnfs_return_layout() must be called with NO_WAIT
>>>> if called from the nfsiod then you cannot call pnfs_initiate_write/read() right
>>>> after. For writes you can get by with doing nothing because the write-back
>>>> thread will kick in soon enough. For reads I'm not sure, you'll need to send
>>>> me more information, stack trace.
>>>>
>>>> Or you can wait for the new state machine.
>>> I think the reason of this deadlock is that the put and the wait are
>>> in the same workqueue and run serially. So the state machine will not
>>> help.
>>
>> I think what you did is right for the time being and I'll merge
>> it until we have something better.
>> The state machine should help in this case since it will effectively
>> switch contexts between two tasks rather than blocking synchronously.
>>
>> Benny
>>
> 
> No! it is not. The patch below is based on the old code.
> If it was done over new code then you would have seen that
> the pnfs_{write,read}_retry must call _pnfs_return_layout(,NO_WAIT)
> without waiting because it is called from the nfsiod_workqueue.
> But if it is not waiting then there is no point in calling
> pnfs_initiate_{write,read}().
> 
> For writes we can safely remove the call, for reads I would need
> to check what's best to do.
> 
> Boaz

I want to summarize. I've looked at the patch Benny has commited in
the latest tree, quoted below please see comments. And it will clearly
lock once there is a layout to commit, just like the problem we had
recently with the return_layout changes. Since now we are calling
Layout_commit/return from the nfsiod.

What we could do for now is drop the calls to pnfs_initiate_*. Altogether
and let the pages VFS state machines kick in again later. For writes it
will work for sure for reads it should be tested. See below in comments
on submitted patch:

On 05/17/2010 09:21 PM, Benny Halevy wrote:
> df90b7b063154a9a603bafe21f0a9a39607d7b3d
>  fs/nfs/pnfs.c |   60 ++++++++++++++++++++++++++++++++++++++-------------------
>  1 files changed, 40 insertions(+), 20 deletions(-)
> 
> diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
> index a095b42..20285bc 100644
> --- a/fs/nfs/pnfs.c
> +++ b/fs/nfs/pnfs.c
> @@ -1497,6 +1497,24 @@ pnfs_call_done(struct pnfs_call_data *pdata, struct rpc_task *task, void *data)
>   * cleanup.
>   */
>  static void
> +pnfs_write_retry(struct work_struct *work)
> +{
> +	struct rpc_task *task;
> +	struct nfs_write_data *wdata;
> +	struct nfs4_pnfs_layout_segment range;
> +
> +	dprintk("%s enter\n", __func__);
> +	task = container_of(work, struct rpc_task, u.tk_work);
> +	wdata = container_of(task, struct nfs_write_data, task);
> +	range.iomode = IOMODE_RW;
> +	range.offset = wdata->args.offset;
> +	range.length = wdata->args.count;
> +	_pnfs_return_layout(wdata->inode, &range, NULL, RETURN_FILE, true);

This is on the nfsiod now. If we need a layoutcommit_ctx it will lock

All we need is:

+	_pnfs_return_layout(wdata->inode, &range, NULL, RETURN_FILE, true);
-	_pnfs_return_layout(wdata->inode, &range, NULL, RETURN_FILE, false);

> +	pnfs_initiate_write(wdata, NFS_CLIENT(wdata->inode),
> +			    wdata->pdata.call_ops, wdata->pdata.how);

and:

-	pnfs_initiate_write(wdata, NFS_CLIENT(wdata->inode),
-			    wdata->pdata.call_ops, wdata->pdata.how);

The VFS will reissue these writes soon enough

> +}
> +
> +static void
>  pnfs_writeback_done(struct nfs_write_data *data)
>  {
>  	struct pnfs_call_data *pdata = &data->pdata;
> @@ -1516,16 +1534,8 @@ pnfs_writeback_done(struct nfs_write_data *data)
>  	}
>  
>  	if (pnfs_call_done(pdata, &data->task, data) == -EAGAIN) {
> -		struct nfs4_pnfs_layout_segment range = {
> -			.iomode = IOMODE_RW,
> -			.offset = data->args.offset,
> -			.length = data->args.count,
> -		};
> -		dprintk("%s: retrying\n", __func__);
> -		_pnfs_return_layout(data->inode, &range, NULL, RETURN_FILE,
> -				    true);
> -		pnfs_initiate_write(data, NFS_CLIENT(data->inode),
> -				    pdata->call_ops, pdata->how);
> +		INIT_WORK(&data->task.u.tk_work, pnfs_write_retry);
> +		queue_work(nfsiod_workqueue, &data->task.u.tk_work);
>  	}
>  }
>  
> @@ -1641,6 +1651,24 @@ out:
>   * read_pagelist is done
>   */
>  static void
> +pnfs_read_retry(struct work_struct *work)
> +{
> +	struct rpc_task *task;
> +	struct nfs_read_data *rdata;
> +	struct nfs4_pnfs_layout_segment range;
> +
> +	dprintk("%s enter\n", __func__);
> +	task = container_of(work, struct rpc_task, u.tk_work);
> +	rdata = container_of(task, struct nfs_read_data, task);
> +	range.iomode = IOMODE_RW;
> +	range.offset = rdata->args.offset;
> +	range.length = rdata->args.count;
> +	_pnfs_return_layout(rdata->inode, &range, NULL, RETURN_FILE, true);

Same here though less likely since with reads we probably do not have to
layoutcommit unless file is double opened and was written to elsewhere.

But needs to be fixed anyway

> +	pnfs_initiate_read(rdata, NFS_CLIENT(rdata->inode),
> +			   rdata->pdata.call_ops);

Consider dropping here too, but needs to be tested.

If it does not work then we need to find a way to propagate
the -EAGAIN to the upper layer, the VFS will know what to do.

I do think there is a good chance we don't need to do anything.


> +}
> +
> +static void
>  pnfs_read_done(struct nfs_read_data *data)
>  {
>  	struct pnfs_call_data *pdata = &data->pdata;
> @@ -1648,16 +1676,8 @@ pnfs_read_done(struct nfs_read_data *data)
>  	dprintk("%s: Begin (status %d)\n", __func__, data->task.tk_status);
>  
>  	if (pnfs_call_done(pdata, &data->task, data) == -EAGAIN) {
> -		struct nfs4_pnfs_layout_segment range = {
> -			.iomode = IOMODE_ANY,
> -			.offset = data->args.offset,
> -			.length = data->args.count,
> -		};
> -		dprintk("%s: retrying\n", __func__);
> -		_pnfs_return_layout(data->inode, &range, NULL, RETURN_FILE,
> -				    true);

What happens now, if we call _pnfs_return_layout(,,,,false) does it still
wait on all lseg's ref? maybe just call with false here and drop the call to
pnfs_initiate_read.

> -		pnfs_initiate_read(data, NFS_CLIENT(data->inode),
> -				   pdata->call_ops);
> +		INIT_WORK(&data->task.u.tk_work, pnfs_read_retry);
> +		queue_work(nfsiod_workqueue, &data->task.u.tk_work);

Note that now the upper layers see the -EAGAIN before the return was attempted
and mark pending, and the reads will keep banging on old layout for a while.

>  	}
>  }
>  

Boaz
