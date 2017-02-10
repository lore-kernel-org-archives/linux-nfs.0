Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f180.google.com ([209.85.223.180]:34304 "EHLO
        mail-io0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750874AbdBJVtK (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 10 Feb 2017 16:49:10 -0500
Received: by mail-io0-f180.google.com with SMTP id l66so61147926ioi.1
        for <linux-nfs@vger.kernel.org>; Fri, 10 Feb 2017 13:49:10 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <b3afb003-b0b2-8a15-7914-40674c6dffbb@gmail.com>
References: <CAN-5tyEE3GnoUKGNiwiApKGpcP+5pj68nLAh9SLSTSJ=OuPcMw@mail.gmail.com>
 <b3afb003-b0b2-8a15-7914-40674c6dffbb@gmail.com>
From: Olga Kornievskaia <aglo@umich.edu>
Date: Fri, 10 Feb 2017 16:49:09 -0500
Message-ID: <CAN-5tyEM9Q-6euq1XdUdcpFge5XnnuANOT_FcXy8mpxH+MP+Yw@mail.gmail.com>
Subject: Re: question about current code in async op
To: Anna Schumaker <schumaker.anna@gmail.com>
Cc: linux-nfs <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Feb 10, 2017 at 4:20 PM, Anna Schumaker
<schumaker.anna@gmail.com> wrote:
> Hi Olga,
>
> On 02/10/2017 04:11 PM, Olga Kornievskaia wrote:
>> Hi folks,
>>
>> As I was writing a new async operation I was looking at other async
>> functions for guidance (i.e.., nfs4_do_close()) and I noticed what
>> looks to me like a memory leak. Am I missing something?
>>
>> I don=E2=80=99t see that =E2=80=9Ccalldata=E2=80=9D is freed if rpc_run_=
task() fails.
>
> I think the current code is okay.  From what I can see, the only way rpc_=
run_task() can fail is if rpc_new_task() can't allocate the new task.  If t=
his happens, then rpc_new_task() calls rpc_release_calldata() to free the c=
alldata.
>
> Am I missing something?

That's what I was missing :) Ok that makes sense. So release of the
calldata should be in the rpc_release function. Thank you!

>
> Anna
>
>>
>> Thoughts?
>>
>> Here=E2=80=99s what I have to fix it:
>>
>> diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
>> diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
>> index d293f06..408cb5b 100644
>> --- a/fs/nfs/nfs4proc.c
>> +++ b/fs/nfs/nfs4proc.c
>> @@ -3317,8 +3317,10 @@ int nfs4_do_close(struct nfs4_state *state,
>> gfp_t gfp_mask, int wait)
>>   msg.rpc_resp =3D &calldata->res;
>>   task_setup_data.callback_data =3D calldata;
>>   task =3D rpc_run_task(&task_setup_data);
>> - if (IS_ERR(task))
>> + if (IS_ERR(task)) {
>> + kfree(calldata);
>>   return PTR_ERR(task);
>
> Isn't this handled by
>
>> + }
>>   status =3D 0;
>>   if (wait)
>>   status =3D rpc_wait_for_completion_task(task);
>> @@ -6023,6 +6025,7 @@ static struct rpc_task *nfs4_do_unlck(struct
>> file_lock *fl,
>>   .workqueue =3D nfsiod_workqueue,
>>   .flags =3D RPC_TASK_ASYNC,
>>   };
>> + struct rpc_task *task;
>>
>>
>>
>>   nfs4_state_protect(NFS_SERVER(lsp->ls_state->inode)->nfs_client,
>>   NFS_SP4_MACH_CRED_CLEANUP, &task_setup_data.rpc_client, &msg);
>> @@ -6042,7 +6045,10 @@ static struct rpc_task *nfs4_do_unlck(struct
>> file_lock *fl,
>>   msg.rpc_argp =3D &data->arg;
>>   msg.rpc_resp =3D &data->res;
>>   task_setup_data.callback_data =3D data;
>> - return rpc_run_task(&task_setup_data);
>> + task =3D rpc_run_task(&task_setup_data);
>> + if (IS_ERR(task))
>> + kfree(data);
>> + return task;
>>  }
>>
>>
>>
>>  static int nfs4_proc_unlck(struct nfs4_state *state, int cmd, struct
>> file_lock *request)
>> @@ -6311,8 +6317,10 @@ static int _nfs4_do_setlk(struct nfs4_state
>> *state, int cmd, struct file_lock *f
>>   } else
>>   data->arg.new_lock =3D 1;
>>   task =3D rpc_run_task(&task_setup_data);
>> - if (IS_ERR(task))
>> + if (IS_ERR(task)) {
>> + kfree(data);
>>   return PTR_ERR(task);
>> + }
>>   ret =3D nfs4_wait_for_completion_rpc_task(task);
>>   if (ret =3D=3D 0) {
>>   ret =3D data->rpc_status;
>> --
>> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>>
