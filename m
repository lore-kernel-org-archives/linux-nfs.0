Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:43815 "EHLO
	daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1755204Ab0EQSVJ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 17 May 2010 14:21:09 -0400
Message-ID: <4BF1890E.90606@panasas.com>
Date: Mon, 17 May 2010 21:21:02 +0300
From: Benny Halevy <bhalevy@panasas.com>
To: Zhang Jingwang <yyalone@gmail.com>
CC: Boaz Harrosh <bharrosh@panasas.com>,
        Zhang Jingwang <zhangjingwang@nrchpc.ac.cn>, linux-nfs@vger.kernel.org
Subject: Re: [PATCH] pnfs: devide put_lseg and return_layout_barrier into
 	different workqueue
References: <20100517095941.GA10823@MDS-78.localdomain>	 <4BF11B7F.2090800@panasas.com> <AANLkTimhsjIISik5KvAHDwbEWVdU_wrRPepfXYy30Brl@mail.gmail.com>
In-Reply-To: <AANLkTimhsjIISik5KvAHDwbEWVdU_wrRPepfXYy30Brl@mail.gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 2010-05-17 20:37, Zhang Jingwang wrote:
> 2010/5/17 Boaz Harrosh <bharrosh@panasas.com>:
>> On 05/17/2010 12:59 PM, Zhang Jingwang wrote:
>>> These two functions mustn't be called from the same workqueue. Otherwise
>>> deadlock may occur. So we schedule the return_layout_barrier to nfsiod.
>>> nfsiod may not be a good choice, maybe we should setup a new workqueue
>>> to do the job.
>>
>> Please give more information. When does it happen that pnfs_XXX_done will
>> return -EAGAIN?
> network error or something else.
> 
>>
>> What is the stack trace of the deadlock?
>>
> http://linux-nfs.org/pipermail/pnfs/2010-January/009939.html
> 
>> And please rebase that patch on the latest changes to _pnfs_return_layout().
>> but since in the new code _pnfs_return_layout() must be called with NO_WAIT
>> if called from the nfsiod then you cannot call pnfs_initiate_write/read() right
>> after. For writes you can get by with doing nothing because the write-back
>> thread will kick in soon enough. For reads I'm not sure, you'll need to send
>> me more information, stack trace.
>>
>> Or you can wait for the new state machine.
> I think the reason of this deadlock is that the put and the wait are
> in the same workqueue and run serially. So the state machine will not
> help.

I think what you did is right for the time being and I'll merge
it until we have something better.
The state machine should help in this case since it will effectively
switch contexts between two tasks rather than blocking synchronously.

Benny

>>
>> Boaz
>>
>>>
>>> Signed-off-by: Zhang Jingwang <zhangjingwang@nrchpc.ac.cn>
>>> ---
>>>  fs/nfs/pnfs.c |   58 +++++++++++++++++++++++++++++++++++++++-----------------
>>>  1 files changed, 40 insertions(+), 18 deletions(-)
>>>
>>> diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
>>> index 5ad7fc6..d2b72be 100644
>>> --- a/fs/nfs/pnfs.c
>>> +++ b/fs/nfs/pnfs.c
>>> @@ -1655,6 +1655,24 @@ pnfs_call_done(struct pnfs_call_data *pdata, struct rpc_task *task, void *data)
>>>   * cleanup.
>>>   */
>>>  static void
>>> +pnfs_write_retry(struct work_struct *work)
>>> +{
>>> +     struct rpc_task *task;
>>> +     struct nfs_write_data *wdata;
>>> +     struct nfs4_pnfs_layout_segment range;
>>> +
>>> +     dprintk("%s enter\n", __func__);
>>> +     task = container_of(work, struct rpc_task, u.tk_work);
>>> +     wdata = container_of(task, struct nfs_write_data, task);
>>> +     range.iomode = IOMODE_RW;
>>> +     range.offset = wdata->args.offset;
>>> +     range.length = wdata->args.count;
>>> +     _pnfs_return_layout(wdata->inode, &range, NULL, RETURN_FILE);
>>> +     pnfs_initiate_write(wdata, NFS_CLIENT(wdata->inode),
>>> +                         wdata->pdata.call_ops, wdata->pdata.how);
>>> +}
>>> +
>>> +static void
>>>  pnfs_writeback_done(struct nfs_write_data *data)
>>>  {
>>>       struct pnfs_call_data *pdata = &data->pdata;
>>> @@ -1674,15 +1692,8 @@ pnfs_writeback_done(struct nfs_write_data *data)
>>>       }
>>>
>>>       if (pnfs_call_done(pdata, &data->task, data) == -EAGAIN) {
>>> -             struct nfs4_pnfs_layout_segment range = {
>>> -                     .iomode = IOMODE_RW,
>>> -                     .offset = data->args.offset,
>>> -                     .length = data->args.count,
>>> -             };
>>> -             dprintk("%s: retrying\n", __func__);
>>> -             _pnfs_return_layout(data->inode, &range, NULL, RETURN_FILE);
>>> -             pnfs_initiate_write(data, NFS_CLIENT(data->inode),
>>> -                                 pdata->call_ops, pdata->how);
>>> +             INIT_WORK(&data->task.u.tk_work, pnfs_write_retry);
>>> +             queue_work(nfsiod_workqueue, &data->task.u.tk_work);
>>>       }
>>>  }
>>>
>>> @@ -1798,6 +1809,24 @@ out:
>>>   * read_pagelist is done
>>>   */
>>>  static void
>>> +pnfs_read_retry(struct work_struct *work)
>>> +{
>>> +     struct rpc_task *task;
>>> +     struct nfs_read_data *rdata;
>>> +     struct nfs4_pnfs_layout_segment range;
>>> +
>>> +     dprintk("%s enter\n", __func__);
>>> +     task = container_of(work, struct rpc_task, u.tk_work);
>>> +     rdata = container_of(task, struct nfs_read_data, task);
>>> +     range.iomode = IOMODE_RW;
>>> +     range.offset = rdata->args.offset;
>>> +     range.length = rdata->args.count;
>>> +     _pnfs_return_layout(rdata->inode, &range, NULL, RETURN_FILE);
>>> +     pnfs_initiate_read(rdata, NFS_CLIENT(rdata->inode),
>>> +                        rdata->pdata.call_ops);
>>> +}
>>> +
>>> +static void
>>>  pnfs_read_done(struct nfs_read_data *data)
>>>  {
>>>       struct pnfs_call_data *pdata = &data->pdata;
>>> @@ -1805,15 +1834,8 @@ pnfs_read_done(struct nfs_read_data *data)
>>>       dprintk("%s: Begin (status %d)\n", __func__, data->task.tk_status);
>>>
>>>       if (pnfs_call_done(pdata, &data->task, data) == -EAGAIN) {
>>> -             struct nfs4_pnfs_layout_segment range = {
>>> -                     .iomode = IOMODE_ANY,
>>> -                     .offset = data->args.offset,
>>> -                     .length = data->args.count,
>>> -             };
>>> -             dprintk("%s: retrying\n", __func__);
>>> -             _pnfs_return_layout(data->inode, &range, NULL, RETURN_FILE);
>>> -             pnfs_initiate_read(data, NFS_CLIENT(data->inode),
>>> -                                pdata->call_ops);
>>> +             INIT_WORK(&data->task.u.tk_work, pnfs_read_retry);
>>> +             queue_work(nfsiod_workqueue, &data->task.u.tk_work);
>>>       }
>>>  }
>>>
>>
>> --
>> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>>
> 
> 
> 
