From: "William A. (Andy) Adamson" <androsadamson@gmail.com>
Subject: Re: [PATCH 7/8] SQUASHME pnfs-submit: add error handlers to layout
	get
Date: Wed, 23 Jun 2010 15:23:43 -0400
Message-ID: <AANLkTim_Eua0HIGxD_DIRo1XqW_bolgRx8WdEOa37LaL@mail.gmail.com>
References: <1277243798-8181-1-git-send-email-andros@netapp.com>
	<1277243798-8181-2-git-send-email-andros@netapp.com>
	<1277243798-8181-3-git-send-email-andros@netapp.com>
	<1277243798-8181-4-git-send-email-andros@netapp.com>
	<1277243798-8181-5-git-send-email-andros@netapp.com>
	<1277243798-8181-6-git-send-email-andros@netapp.com>
	<1277243798-8181-7-git-send-email-andros@netapp.com>
	<1277243798-8181-8-git-send-email-andros@netapp.com>
	<4C21BAA8.7030900@panasas.com>
	<AANLkTinew-MgRJeswY3x7gJS-GBE_WMHhJdkWnrNGuo4@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: linux-nfs@vger.kernel.org
To: Benny Halevy <bhalevy@panasas.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-gx0-f174.google.com ([209.85.161.174]:61888 "EHLO
	mail-gx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753055Ab0FWTXo convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 23 Jun 2010 15:23:44 -0400
Received: by gxk28 with SMTP id 28so354412gxk.19
        for <linux-nfs@vger.kernel.org>; Wed, 23 Jun 2010 12:23:43 -0700 (PDT)
In-Reply-To: <AANLkTinew-MgRJeswY3x7gJS-GBE_WMHhJdkWnrNGuo4-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Jun 23, 2010 at 9:04 AM, William A. (Andy) Adamson
<androsadamson@gmail.com> wrote:
> On Wed, Jun 23, 2010 at 3:41 AM, Benny Halevy <bhalevy@panasas.com> w=
rote:
>> On Jun. 23, 2010, 0:56 +0300, andros@netapp.com wrote:
>>> From: Andy Adamson <andros@netapp.com>
>>>
>>> Redo pnfs4_proc_layoutget() logic to match the other async operatio=
ns that call
>>> nfs4_wait_for_completion_rpc_task.
>>>
>>> pnfs_get_layout_done passes session and delay errors. Handle them w=
ith the
>>> generic error handlers.
>>>
>>> Signed-off-by: Andy Adamson <andros@netapp.com>
>>> ---
>>> =A0fs/nfs/nfs4proc.c | =A0 45 +++++++++++++++++++++++++++++--------=
--------
>>> =A01 files changed, 29 insertions(+), 16 deletions(-)
>>>
>>> diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
>>> index 35e8a56..6283996 100644
>>> --- a/fs/nfs/nfs4proc.c
>>> +++ b/fs/nfs/nfs4proc.c
>>> @@ -5446,6 +5446,10 @@ static void nfs4_pnfs_layoutget_done(struct =
rpc_task *task, void *calldata)
>>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 return;
>>>
>>> =A0 =A0 =A0 pnfs_get_layout_done(lgp, task->tk_status);
>>> +
>>> + =A0 =A0 if (nfs4_async_handle_error(task, server, NULL, NULL) =3D=
=3D -EAGAIN)
>>> + =A0 =A0 =A0 =A0 =A0 =A0 nfs_restart_rpc(task, server->nfs_client)=
;
>>> +
>>> =A0 =A0 =A0 dprintk("<-- %s\n", __func__);
>>> =A0}
>>>
>>> @@ -5471,10 +5475,9 @@ static const struct rpc_call_ops nfs4_pnfs_l=
ayoutget_call_ops =3D {
>>> =A0 * and deal with retries.
>>> =A0 * Currently we can't since we release lgp and its contents.
>>> =A0 */
>>> -int pnfs4_proc_layoutget(struct nfs4_pnfs_layoutget *lgp)
>>> +static int _pnfs4_proc_layoutget(struct nfs4_pnfs_layoutget *lgp)
>>> =A0{
>>> - =A0 =A0 struct inode *ino =3D lgp->args.inode;
>>> - =A0 =A0 struct nfs_server *server =3D NFS_SERVER(ino);
>>> + =A0 =A0 struct nfs_server *server =3D NFS_SERVER(lgp->args.inode)=
;
>>> =A0 =A0 =A0 struct rpc_task *task;
>>> =A0 =A0 =A0 struct rpc_message msg =3D {
>>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 .rpc_proc =3D &nfs4_procedures[NFSPROC4=
_CLNT_PNFS_LAYOUTGET],
>>> @@ -5488,35 +5491,45 @@ int pnfs4_proc_layoutget(struct nfs4_pnfs_l=
ayoutget *lgp)
>>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 .callback_data =3D lgp,
>>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 .flags =3D RPC_TASK_ASYNC,
>>> =A0 =A0 =A0 };
>>> - =A0 =A0 int status;
>>> + =A0 =A0 int status =3D 0;
>>>
>>> =A0 =A0 =A0 dprintk("--> %s\n", __func__);
>>>
>>> =A0 =A0 =A0 lgp->res.layout.buf =3D (void *)__get_free_page(GFP_NOF=
S);
>>> =A0 =A0 =A0 if (lgp->res.layout.buf =3D=3D NULL) {
>>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 nfs4_pnfs_layoutget_release(lgp);
>>> - =A0 =A0 =A0 =A0 =A0 =A0 status =3D -ENOMEM;
>>> - =A0 =A0 =A0 =A0 =A0 =A0 goto out;
>>> + =A0 =A0 =A0 =A0 =A0 =A0 return -ENOMEM;
>>
>> This will bypass the dprintk.
>> How about adding a out_no_task label after the call to rpc_put_task?
>
> Actually, I think we need to lose all of these dprintk's. Look at
> _nfs4_proc_delegreturn for example...


Since pnfs4_proc_layoutget is only called by send_layout which prints
the status, I'll leave this alone for now.

Sometime soon we will need to purge the pnfs-submit branch of dprintks

-->Andy
>
> -->Andy
>
>>
>>> =A0 =A0 =A0 }
>>>
>>> =A0 =A0 =A0 lgp->res.seq_res.sr_slotid =3D NFS4_MAX_SLOT_TABLE;
>>> =A0 =A0 =A0 task =3D rpc_run_task(&task_setup_data);
>>> - =A0 =A0 if (IS_ERR(task)) {
>>> - =A0 =A0 =A0 =A0 =A0 =A0 status =3D PTR_ERR(task);
>>> - =A0 =A0 =A0 =A0 =A0 =A0 goto out;
>>> - =A0 =A0 }
>>> + =A0 =A0 if (IS_ERR(task))
>>> + =A0 =A0 =A0 =A0 =A0 =A0 return PTR_ERR(task);
>>
>> ditto
>
>>
>> Benny
>>
>>> =A0 =A0 =A0 status =3D nfs4_wait_for_completion_rpc_task(task);
>>> - =A0 =A0 if (status =3D=3D 0) {
>>> - =A0 =A0 =A0 =A0 =A0 =A0 status =3D lgp->status;
>>> - =A0 =A0 =A0 =A0 =A0 =A0 if (status =3D=3D 0)
>>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 status =3D pnfs_layout_pr=
ocess(lgp);
>>> - =A0 =A0 }
>>> - =A0 =A0 rpc_put_task(task);
>>> + =A0 =A0 if (status !=3D 0)
>>> + =A0 =A0 =A0 =A0 =A0 =A0 goto out;
>>> + =A0 =A0 status =3D lgp->status;
>>> + =A0 =A0 if (status !=3D 0)
>>> + =A0 =A0 =A0 =A0 =A0 =A0 goto out;
>>> + =A0 =A0 status =3D pnfs_layout_process(lgp);
>>> =A0out:
>>> + =A0 =A0 rpc_put_task(task);
>>> =A0 =A0 =A0 dprintk("<-- %s status=3D%d\n", __func__, status);
>>> =A0 =A0 =A0 return status;
>>> =A0}
>>>
>>> +int pnfs4_proc_layoutget(struct nfs4_pnfs_layoutget *lgp)
>>> +{
>>> + =A0 =A0 struct nfs_server *server =3D NFS_SERVER(lgp->args.inode)=
;
>>> + =A0 =A0 struct nfs4_exception exception =3D { };
>>> + =A0 =A0 int err;
>>> + =A0 =A0 do {
>>> + =A0 =A0 =A0 =A0 =A0 =A0 err =3D nfs4_handle_exception(server, _pn=
fs4_proc_layoutget(lgp),
>>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 &exception);
>>> + =A0 =A0 } while (exception.retry);
>>> + =A0 =A0 return err;
>>> +}
>>> +
>>> =A0static void pnfs_layoutcommit_prepare(struct rpc_task *task, voi=
d *data)
>>> =A0{
>>> =A0 =A0 =A0 struct pnfs_layoutcommit_data *ldata =3D
>>
>> --
>> To unsubscribe from this list: send the line "unsubscribe linux-nfs"=
 in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at =A0http://vger.kernel.org/majordomo-info.html
>>
>
