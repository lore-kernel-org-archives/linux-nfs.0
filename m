From: Zhang Jingwang <yyalone@gmail.com>
Subject: Re: [PATCH] pnfs: devide put_lseg and return_layout_barrier into
	different workqueue
Date: Mon, 24 May 2010 10:14:09 +0800
Message-ID: <AANLkTinBBVKwRVtRSvXeo_Jz-tjvxfF4UDsBq6n4JdeH@mail.gmail.com>
References: <20100517095941.GA10823@MDS-78.localdomain>
	 <4BF11B7F.2090800@panasas.com>
	 <AANLkTimhsjIISik5KvAHDwbEWVdU_wrRPepfXYy30Brl@mail.gmail.com>
	 <4BF973ED.9020807@panasas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Zhang Jingwang <zhangjingwang-U4AKAne5IzAR5TUyvShJeg@public.gmane.org>,
	linux-nfs@vger.kernel.org, bhalevy@panasas.com
To: Boaz Harrosh <bharrosh@panasas.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pv0-f174.google.com ([74.125.83.174]:61860 "EHLO
	mail-pv0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754793Ab0EXCOK convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 23 May 2010 22:14:10 -0400
Received: by pvg4 with SMTP id 4so572064pvg.19
        for <linux-nfs@vger.kernel.org>; Sun, 23 May 2010 19:14:09 -0700 (PDT)
In-Reply-To: <4BF973ED.9020807@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

2010/5/24 Boaz Harrosh <bharrosh@panasas.com>:
> On 05/17/2010 08:37 PM, Zhang Jingwang wrote:
>> 2010/5/17 Boaz Harrosh <bharrosh@panasas.com>:
>>> On 05/17/2010 12:59 PM, Zhang Jingwang wrote:
>>>> These two functions mustn't be called from the same workqueue. Oth=
erwise
>>>> deadlock may occur. So we schedule the return_layout_barrier to nf=
siod.
>>>> nfsiod may not be a good choice, maybe we should setup a new workq=
ueue
>>>> to do the job.
>>>
>>> Please give more information. When does it happen that pnfs_XXX_don=
e will
>>> return -EAGAIN?
>> network error or something else.
>>
>>>
>>> What is the stack trace of the deadlock?
>>>
>> http://linux-nfs.org/pipermail/pnfs/2010-January/009939.html
>>
>
> I wish you would send me the real stack trace and not the explanation=
s
> because some things has changed and I could find a way to solve it wi=
th
> the new code.
>
> Boaz
>
There is stack dump info in the reply to this message, its URL is
http://linux-nfs.org/pipermail/pnfs/2010-January/010014.html

>>> And please rebase that patch on the latest changes to _pnfs_return_=
layout().
>>> but since in the new code _pnfs_return_layout() must be called with=
 NO_WAIT
>>> if called from the nfsiod then you cannot call pnfs_initiate_write/=
read() right
>>> after. For writes you can get by with doing nothing because the wri=
te-back
>>> thread will kick in soon enough. For reads I'm not sure, you'll nee=
d to send
>>> me more information, stack trace.
>>>
>>> Or you can wait for the new state machine.
>> I think the reason of this deadlock is that the put and the wait are
>> in the same workqueue and run serially. So the state machine will no=
t
>> help.
>>>
>>> Boaz
>>>
>>>>
>>>> Signed-off-by: Zhang Jingwang <zhangjingwang-U4AKAne5IzAR5TUyvShJeg@public.gmane.org>
>>>> ---
>>>> =A0fs/nfs/pnfs.c | =A0 58 +++++++++++++++++++++++++++++++++++++++-=
----------------
>>>> =A01 files changed, 40 insertions(+), 18 deletions(-)
>>>>
>>>> diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
>>>> index 5ad7fc6..d2b72be 100644
>>>> --- a/fs/nfs/pnfs.c
>>>> +++ b/fs/nfs/pnfs.c
>>>> @@ -1655,6 +1655,24 @@ pnfs_call_done(struct pnfs_call_data *pdata=
, struct rpc_task *task, void *data)
>>>> =A0 * cleanup.
>>>> =A0 */
>>>> =A0static void
>>>> +pnfs_write_retry(struct work_struct *work)
>>>> +{
>>>> + =A0 =A0 struct rpc_task *task;
>>>> + =A0 =A0 struct nfs_write_data *wdata;
>>>> + =A0 =A0 struct nfs4_pnfs_layout_segment range;
>>>> +
>>>> + =A0 =A0 dprintk("%s enter\n", __func__);
>>>> + =A0 =A0 task =3D container_of(work, struct rpc_task, u.tk_work);
>>>> + =A0 =A0 wdata =3D container_of(task, struct nfs_write_data, task=
);
>>>> + =A0 =A0 range.iomode =3D IOMODE_RW;
>>>> + =A0 =A0 range.offset =3D wdata->args.offset;
>>>> + =A0 =A0 range.length =3D wdata->args.count;
>>>> + =A0 =A0 _pnfs_return_layout(wdata->inode, &range, NULL, RETURN_F=
ILE);
>>>> + =A0 =A0 pnfs_initiate_write(wdata, NFS_CLIENT(wdata->inode),
>>>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 wdata->pdata.cal=
l_ops, wdata->pdata.how);
>>>> +}
>>>> +
>>>> +static void
>>>> =A0pnfs_writeback_done(struct nfs_write_data *data)
>>>> =A0{
>>>> =A0 =A0 =A0 struct pnfs_call_data *pdata =3D &data->pdata;
>>>> @@ -1674,15 +1692,8 @@ pnfs_writeback_done(struct nfs_write_data *=
data)
>>>> =A0 =A0 =A0 }
>>>>
>>>> =A0 =A0 =A0 if (pnfs_call_done(pdata, &data->task, data) =3D=3D -E=
AGAIN) {
>>>> - =A0 =A0 =A0 =A0 =A0 =A0 struct nfs4_pnfs_layout_segment range =3D=
 {
>>>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 .iomode =3D IOMODE_RW,
>>>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 .offset =3D data->args.o=
ffset,
>>>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 .length =3D data->args.c=
ount,
>>>> - =A0 =A0 =A0 =A0 =A0 =A0 };
>>>> - =A0 =A0 =A0 =A0 =A0 =A0 dprintk("%s: retrying\n", __func__);
>>>> - =A0 =A0 =A0 =A0 =A0 =A0 _pnfs_return_layout(data->inode, &range,=
 NULL, RETURN_FILE);
>>>> - =A0 =A0 =A0 =A0 =A0 =A0 pnfs_initiate_write(data, NFS_CLIENT(dat=
a->inode),
>>>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
pdata->call_ops, pdata->how);
>>>> + =A0 =A0 =A0 =A0 =A0 =A0 INIT_WORK(&data->task.u.tk_work, pnfs_wr=
ite_retry);
>>>> + =A0 =A0 =A0 =A0 =A0 =A0 queue_work(nfsiod_workqueue, &data->task=
=2Eu.tk_work);
>>>> =A0 =A0 =A0 }
>>>> =A0}
>>>>
>>>> @@ -1798,6 +1809,24 @@ out:
>>>> =A0 * read_pagelist is done
>>>> =A0 */
>>>> =A0static void
>>>> +pnfs_read_retry(struct work_struct *work)
>>>> +{
>>>> + =A0 =A0 struct rpc_task *task;
>>>> + =A0 =A0 struct nfs_read_data *rdata;
>>>> + =A0 =A0 struct nfs4_pnfs_layout_segment range;
>>>> +
>>>> + =A0 =A0 dprintk("%s enter\n", __func__);
>>>> + =A0 =A0 task =3D container_of(work, struct rpc_task, u.tk_work);
>>>> + =A0 =A0 rdata =3D container_of(task, struct nfs_read_data, task)=
;
>>>> + =A0 =A0 range.iomode =3D IOMODE_RW;
>>>> + =A0 =A0 range.offset =3D rdata->args.offset;
>>>> + =A0 =A0 range.length =3D rdata->args.count;
>>>> + =A0 =A0 _pnfs_return_layout(rdata->inode, &range, NULL, RETURN_F=
ILE);
>>>> + =A0 =A0 pnfs_initiate_read(rdata, NFS_CLIENT(rdata->inode),
>>>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0rdata->pdata.call=
_ops);
>>>> +}
>>>> +
>>>> +static void
>>>> =A0pnfs_read_done(struct nfs_read_data *data)
>>>> =A0{
>>>> =A0 =A0 =A0 struct pnfs_call_data *pdata =3D &data->pdata;
>>>> @@ -1805,15 +1834,8 @@ pnfs_read_done(struct nfs_read_data *data)
>>>> =A0 =A0 =A0 dprintk("%s: Begin (status %d)\n", __func__, data->tas=
k.tk_status);
>>>>
>>>> =A0 =A0 =A0 if (pnfs_call_done(pdata, &data->task, data) =3D=3D -E=
AGAIN) {
>>>> - =A0 =A0 =A0 =A0 =A0 =A0 struct nfs4_pnfs_layout_segment range =3D=
 {
>>>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 .iomode =3D IOMODE_ANY,
>>>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 .offset =3D data->args.o=
ffset,
>>>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 .length =3D data->args.c=
ount,
>>>> - =A0 =A0 =A0 =A0 =A0 =A0 };
>>>> - =A0 =A0 =A0 =A0 =A0 =A0 dprintk("%s: retrying\n", __func__);
>>>> - =A0 =A0 =A0 =A0 =A0 =A0 _pnfs_return_layout(data->inode, &range,=
 NULL, RETURN_FILE);
>>>> - =A0 =A0 =A0 =A0 =A0 =A0 pnfs_initiate_read(data, NFS_CLIENT(data=
->inode),
>>>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0p=
data->call_ops);
>>>> + =A0 =A0 =A0 =A0 =A0 =A0 INIT_WORK(&data->task.u.tk_work, pnfs_re=
ad_retry);
>>>> + =A0 =A0 =A0 =A0 =A0 =A0 queue_work(nfsiod_workqueue, &data->task=
=2Eu.tk_work);
>>>> =A0 =A0 =A0 }
>>>> =A0}
>>>>
>>>
>>> --
>>> To unsubscribe from this list: send the line "unsubscribe linux-nfs=
" in
>>> the body of a message to majordomo@vger.kernel.org
>>> More majordomo info at =A0http://vger.kernel.org/majordomo-info.htm=
l
>>>
>>
>>
>>
>
>



--=20
Zhang Jingwang
National Research Centre for High Performance Computers
Institute of Computing Technology, Chinese Academy of Sciences
No. 6, South Kexueyuan Road, Haidian District
Beijing, China
