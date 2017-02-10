Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f41.google.com ([209.85.214.41]:37294 "EHLO
        mail-it0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752075AbdBJVLd (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 10 Feb 2017 16:11:33 -0500
Received: by mail-it0-f41.google.com with SMTP id x75so2559654itb.0
        for <linux-nfs@vger.kernel.org>; Fri, 10 Feb 2017 13:11:33 -0800 (PST)
MIME-Version: 1.0
From: Olga Kornievskaia <aglo@umich.edu>
Date: Fri, 10 Feb 2017 16:11:32 -0500
Message-ID: <CAN-5tyEE3GnoUKGNiwiApKGpcP+5pj68nLAh9SLSTSJ=OuPcMw@mail.gmail.com>
Subject: question about current code in async op
To: linux-nfs <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi folks,

As I was writing a new async operation I was looking at other async
functions for guidance (i.e.., nfs4_do_close()) and I noticed what
looks to me like a memory leak. Am I missing something?

I don=E2=80=99t see that =E2=80=9Ccalldata=E2=80=9D is freed if rpc_run_tas=
k() fails.

Thoughts?

Here=E2=80=99s what I have to fix it:

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index d293f06..408cb5b 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -3317,8 +3317,10 @@ int nfs4_do_close(struct nfs4_state *state,
gfp_t gfp_mask, int wait)
  msg.rpc_resp =3D &calldata->res;
  task_setup_data.callback_data =3D calldata;
  task =3D rpc_run_task(&task_setup_data);
- if (IS_ERR(task))
+ if (IS_ERR(task)) {
+ kfree(calldata);
  return PTR_ERR(task);
+ }
  status =3D 0;
  if (wait)
  status =3D rpc_wait_for_completion_task(task);
@@ -6023,6 +6025,7 @@ static struct rpc_task *nfs4_do_unlck(struct
file_lock *fl,
  .workqueue =3D nfsiod_workqueue,
  .flags =3D RPC_TASK_ASYNC,
  };
+ struct rpc_task *task;



  nfs4_state_protect(NFS_SERVER(lsp->ls_state->inode)->nfs_client,
  NFS_SP4_MACH_CRED_CLEANUP, &task_setup_data.rpc_client, &msg);
@@ -6042,7 +6045,10 @@ static struct rpc_task *nfs4_do_unlck(struct
file_lock *fl,
  msg.rpc_argp =3D &data->arg;
  msg.rpc_resp =3D &data->res;
  task_setup_data.callback_data =3D data;
- return rpc_run_task(&task_setup_data);
+ task =3D rpc_run_task(&task_setup_data);
+ if (IS_ERR(task))
+ kfree(data);
+ return task;
 }



 static int nfs4_proc_unlck(struct nfs4_state *state, int cmd, struct
file_lock *request)
@@ -6311,8 +6317,10 @@ static int _nfs4_do_setlk(struct nfs4_state
*state, int cmd, struct file_lock *f
  } else
  data->arg.new_lock =3D 1;
  task =3D rpc_run_task(&task_setup_data);
- if (IS_ERR(task))
+ if (IS_ERR(task)) {
+ kfree(data);
  return PTR_ERR(task);
+ }
  ret =3D nfs4_wait_for_completion_rpc_task(task);
  if (ret =3D=3D 0) {
  ret =3D data->rpc_status;
