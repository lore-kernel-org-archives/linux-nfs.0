From: "William A. (Andy) Adamson" <androsadamson@gmail.com>
Subject: Re: [PATCH 07/10] SQUASHME pnfs-submit: add error handlers to layout
	get
Date: Wed, 30 Jun 2010 15:23:54 -0400
Message-ID: <AANLkTinq4Sp75m5-fEFNR-L79aOPcUCRV_YIukchYqr0@mail.gmail.com>
References: <1277320878-3726-1-git-send-email-andros@netapp.com>
	<1277320878-3726-2-git-send-email-andros@netapp.com>
	<1277320878-3726-3-git-send-email-andros@netapp.com>
	<1277320878-3726-4-git-send-email-andros@netapp.com>
	<1277320878-3726-5-git-send-email-andros@netapp.com>
	<1277320878-3726-6-git-send-email-andros@netapp.com>
	<1277320878-3726-7-git-send-email-andros@netapp.com>
	<1277320878-3726-8-git-send-email-andros@netapp.com>
	<4C2B6097.2000909@panasas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: bhalevy@panasas.com, linux-nfs@vger.kernel.org
To: Boaz Harrosh <bharrosh@panasas.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-gx0-f174.google.com ([209.85.161.174]:58347 "EHLO
	mail-gx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755877Ab0F3TXz convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 30 Jun 2010 15:23:55 -0400
Received: by gxk23 with SMTP id 23so652018gxk.19
        for <linux-nfs@vger.kernel.org>; Wed, 30 Jun 2010 12:23:54 -0700 (PDT)
In-Reply-To: <4C2B6097.2000909@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Jun 30, 2010 at 11:19 AM, Boaz Harrosh <bharrosh@panasas.com> w=
rote:
> On 06/23/2010 10:21 PM, andros@netapp.com wrote:
>> From: Andy Adamson <andros@netapp.com>
>>
>> Redo pnfs4_proc_layoutget() logic to match the other async operation=
s that call
>> nfs4_wait_for_completion_rpc_task.
>>
>> pnfs_get_layout_done passes session and delay errors. Handle them wi=
th the
>> generic error handlers.
>>
>> Signed-off-by: Andy Adamson <andros@netapp.com>
>> ---
>> =A0fs/nfs/nfs4proc.c | =A0 45 +++++++++++++++++++++++++++++---------=
-------
>> =A01 files changed, 29 insertions(+), 16 deletions(-)
>>
>> diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
>> index 35e8a56..6283996 100644
>> --- a/fs/nfs/nfs4proc.c
>> +++ b/fs/nfs/nfs4proc.c
>> @@ -5446,6 +5446,10 @@ static void nfs4_pnfs_layoutget_done(struct r=
pc_task *task, void *calldata)
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 return;
>>
>> =A0 =A0 =A0 pnfs_get_layout_done(lgp, task->tk_status);
>> +
>> + =A0 =A0 if (nfs4_async_handle_error(task, server, NULL, NULL) =3D=3D=
 -EAGAIN)
>> + =A0 =A0 =A0 =A0 =A0 =A0 nfs_restart_rpc(task, server->nfs_client);
>> +
>
> Andy high.
>
> In pnfs_get_layout_done() it is working hard to do "lgp->status =3D X=
XX"
>
> I never understood, what gets to look at that later on?

HI Boaz

_pnfs4_proc_layoutget will return it if it is set, then send_layoutget
returns it to pnfs_update_layout.

-->Andy

>
> Thanks
> Boaz
>
>> =A0 =A0 =A0 dprintk("<-- %s\n", __func__);
>> =A0}
>>
>> @@ -5471,10 +5475,9 @@ static const struct rpc_call_ops nfs4_pnfs_la=
youtget_call_ops =3D {
>> =A0 * and deal with retries.
>> =A0 * Currently we can't since we release lgp and its contents.
>> =A0 */
>> -int pnfs4_proc_layoutget(struct nfs4_pnfs_layoutget *lgp)
>> +static int _pnfs4_proc_layoutget(struct nfs4_pnfs_layoutget *lgp)
>> =A0{
>> - =A0 =A0 struct inode *ino =3D lgp->args.inode;
>> - =A0 =A0 struct nfs_server *server =3D NFS_SERVER(ino);
>> + =A0 =A0 struct nfs_server *server =3D NFS_SERVER(lgp->args.inode);
>> =A0 =A0 =A0 struct rpc_task *task;
>> =A0 =A0 =A0 struct rpc_message msg =3D {
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 .rpc_proc =3D &nfs4_procedures[NFSPROC4_=
CLNT_PNFS_LAYOUTGET],
>> @@ -5488,35 +5491,45 @@ int pnfs4_proc_layoutget(struct nfs4_pnfs_la=
youtget *lgp)
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 .callback_data =3D lgp,
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 .flags =3D RPC_TASK_ASYNC,
>> =A0 =A0 =A0 };
>> - =A0 =A0 int status;
>> + =A0 =A0 int status =3D 0;
>>
>> =A0 =A0 =A0 dprintk("--> %s\n", __func__);
>>
>> =A0 =A0 =A0 lgp->res.layout.buf =3D (void *)__get_free_page(GFP_NOFS=
);
>> =A0 =A0 =A0 if (lgp->res.layout.buf =3D=3D NULL) {
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 nfs4_pnfs_layoutget_release(lgp);
>> - =A0 =A0 =A0 =A0 =A0 =A0 status =3D -ENOMEM;
>> - =A0 =A0 =A0 =A0 =A0 =A0 goto out;
>> + =A0 =A0 =A0 =A0 =A0 =A0 return -ENOMEM;
>> =A0 =A0 =A0 }
>>
>> =A0 =A0 =A0 lgp->res.seq_res.sr_slotid =3D NFS4_MAX_SLOT_TABLE;
>> =A0 =A0 =A0 task =3D rpc_run_task(&task_setup_data);
>> - =A0 =A0 if (IS_ERR(task)) {
>> - =A0 =A0 =A0 =A0 =A0 =A0 status =3D PTR_ERR(task);
>> - =A0 =A0 =A0 =A0 =A0 =A0 goto out;
>> - =A0 =A0 }
>> + =A0 =A0 if (IS_ERR(task))
>> + =A0 =A0 =A0 =A0 =A0 =A0 return PTR_ERR(task);
>> =A0 =A0 =A0 status =3D nfs4_wait_for_completion_rpc_task(task);
>> - =A0 =A0 if (status =3D=3D 0) {
>> - =A0 =A0 =A0 =A0 =A0 =A0 status =3D lgp->status;
>> - =A0 =A0 =A0 =A0 =A0 =A0 if (status =3D=3D 0)
>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 status =3D pnfs_layout_pro=
cess(lgp);
>> - =A0 =A0 }
>> - =A0 =A0 rpc_put_task(task);
>> + =A0 =A0 if (status !=3D 0)
>> + =A0 =A0 =A0 =A0 =A0 =A0 goto out;
>> + =A0 =A0 status =3D lgp->status;
>> + =A0 =A0 if (status !=3D 0)
>> + =A0 =A0 =A0 =A0 =A0 =A0 goto out;
>> + =A0 =A0 status =3D pnfs_layout_process(lgp);
>> =A0out:
>> + =A0 =A0 rpc_put_task(task);
>> =A0 =A0 =A0 dprintk("<-- %s status=3D%d\n", __func__, status);
>> =A0 =A0 =A0 return status;
>> =A0}
>>
>> +int pnfs4_proc_layoutget(struct nfs4_pnfs_layoutget *lgp)
>> +{
>> + =A0 =A0 struct nfs_server *server =3D NFS_SERVER(lgp->args.inode);
>> + =A0 =A0 struct nfs4_exception exception =3D { };
>> + =A0 =A0 int err;
>> + =A0 =A0 do {
>> + =A0 =A0 =A0 =A0 =A0 =A0 err =3D nfs4_handle_exception(server, _pnf=
s4_proc_layoutget(lgp),
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 &exception);
>> + =A0 =A0 } while (exception.retry);
>> + =A0 =A0 return err;
>> +}
>> +
>> =A0static void pnfs_layoutcommit_prepare(struct rpc_task *task, void=
 *data)
>> =A0{
>> =A0 =A0 =A0 struct pnfs_layoutcommit_data *ldata =3D
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" =
in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at =A0http://vger.kernel.org/majordomo-info.html
>
