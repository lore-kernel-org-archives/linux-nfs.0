Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from userp2120.oracle.com ([156.151.31.85]:35778 "EHLO
        userp2120.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752399AbeFDMXV (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 4 Jun 2018 08:23:21 -0400
Date: Mon, 4 Jun 2018 15:23:08 +0300
From: Dan Carpenter <dan.carpenter@oracle.com>
To: Trond.Myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org
Subject: [bug report] NFSv4: Convert nfs41_free_stateid to use an
 asynchronous RPC call
Message-ID: <20180604122308.in3wyoy4m4yl4sb6@kili.mountain>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hello Trond Myklebust,

The patch 7c1d5fae4a87: "NFSv4: Convert nfs41_free_stateid to use an
asynchronous RPC call" from May 3, 2013, leads to the following
static checker warning:

	fs/nfs/nfs4proc.c:9395 nfs41_free_stateid()
	warn: 'task' isn't an ERR_PTR

fs/nfs/nfs4proc.c
  9376          struct nfs_free_stateid_data *data;
  9377          struct rpc_task *task;
  9378  
  9379          nfs4_state_protect(server->nfs_client, NFS_SP4_MACH_CRED_STATEID,
  9380                  &task_setup.rpc_client, &msg);
  9381  
  9382          dprintk("NFS call  free_stateid %p\n", stateid);
  9383          data = kmalloc(sizeof(*data), GFP_NOFS);
  9384          if (!data)
  9385                  return -ENOMEM;
  9386          data->server = server;
  9387          nfs4_stateid_copy(&data->args.stateid, stateid);
  9388  
  9389          task_setup.callback_data = data;
  9390  
  9391          msg.rpc_argp = &data->args;
  9392          msg.rpc_resp = &data->res;
  9393          nfs4_init_sequence(&data->args.seq_args, &data->res.seq_res, 1, privileged);
  9394          task = rpc_run_task(&task_setup);
  9395          if (IS_ERR(task))
                           ^^^^
Apparently rpc_run_task() can't ever fail so this warning stating true
facts...

  9396                  return PTR_ERR(task);
  9397          rpc_put_task(task);
  9398          return 0;

regards,
dan carpenter
