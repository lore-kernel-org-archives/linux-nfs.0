Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:49205 "EHLO
        userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1425602AbdDUTwF (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 21 Apr 2017 15:52:05 -0400
Date: Fri, 21 Apr 2017 22:51:53 +0300
From: Dan Carpenter <dan.carpenter@oracle.com>
To: neilb@suse.com
Cc: linux-nfs@vger.kernel.org
Subject: [bug report] sunrpc: don't check for failure from mempool_alloc()
Message-ID: <20170421195153.vzfthyjiaatc7t7k@mwanda>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hello NeilBrown,

The patch 62b2417e84ba: "sunrpc: don't check for failure from
mempool_alloc()" from Apr 10, 2017, leads to the following static
checker warning:

	fs/nfs/unlink.c:111 nfs_do_call_unlink()
	warn: 'task' isn't an ERR_PTR

fs/nfs/unlink.c
   106  
   107          NFS_PROTO(dir)->unlink_setup(&msg, dir);
   108  
   109          task_setup_data.rpc_client = NFS_CLIENT(dir);
   110          task = rpc_run_task(&task_setup_data);
   111          if (!IS_ERR(task))
   112                  rpc_put_task_async(task);

This code is obviously harmless, but I get a ball of new warnings today.
I haven't published this check because it has too many false positives
so it only affects me.

fs/nfs/unlink.c:111 nfs_do_call_unlink() warn: 'task' isn't an ERR_PTR
fs/nfs/pagelist.c:602 nfs_initiate_pgio() warn: 'task' isn't an ERR_PTR
fs/nfs/write.c:1627 nfs_initiate_commit() warn: 'task' isn't an ERR_PTR
fs/nfs/nfs4proc.c:976 nfs4_call_sync_sequence() warn: 'task' isn't an ERR_PTR
fs/nfs/nfs4proc.c:2023 _nfs4_proc_open_confirm() warn: 'task' isn't an ERR_PTR
fs/nfs/nfs4proc.c:2190 nfs4_run_open_task() warn: 'task' isn't an ERR_PTR
fs/nfs/nfs4proc.c:3208 nfs4_do_close() warn: 'task' isn't an ERR_PTR
fs/nfs/nfs4proc.c:5475 nfs4_proc_setclientid() warn: 'task' isn't an ERR_PTR
fs/nfs/nfs4proc.c:5694 _nfs4_proc_delegreturn() warn: 'task' isn't an ERR_PTR
fs/nfs/nfs4proc.c:6193 _nfs4_do_setlk() warn: 'task' isn't an ERR_PTR
fs/nfs/nfs4proc.c:7169 nfs4_proc_bind_one_conn_to_session() warn: 'task' isn't an ERR_PTR
fs/nfs/nfs4proc.c:7527 _nfs4_proc_exchange_id() warn: 'task' isn't an ERR_PTR
fs/nfs/nfs4proc.c:7758 nfs4_proc_get_lease_time() warn: 'task' isn't an ERR_PTR
fs/nfs/nfs4proc.c:8233 nfs41_proc_reclaim_complete() warn: 'task' isn't an ERR_PTR
fs/nfs/nfs4proc.c:8467 nfs4_proc_layoutget() warn: 'task' isn't an ERR_PTR
fs/nfs/nfs4proc.c:8585 nfs4_proc_layoutreturn() warn: 'task' isn't an ERR_PTR
fs/nfs/nfs4proc.c:8732 nfs4_proc_layoutcommit() warn: 'task' isn't an ERR_PTR
fs/nfs/nfs42proc.c:456 nfs42_proc_layoutstats_generic() warn: 'task' isn't an ERR_PTR
drivers/clk/x86/clk-pmc-atom.c:342 plt_clk_probe() warn: 'data->mclk_lookup' isn't an ERR_PTR
net/sunrpc/svc.c:1452 bc_svc_process() warn: 'task' isn't an ERR_PTR
net/sunrpc/clnt.c:1083 rpc_call_sync() warn: 'task' isn't an ERR_PTR
net/sunrpc/clnt.c:1113 rpc_call_async() warn: 'task' isn't an ERR_PTR
net/sunrpc/clnt.c:2585 rpc_clnt_test_and_add_xprt() warn: 'task' isn't an ERR_PTR
net/sunrpc/clnt.c:2632 rpc_clnt_setup_test_and_add_xprt() warn: 'task' isn't an ERR_PTR
net/sunrpc/rpcb_clnt.c:784 rpcb_getport_async() warn: 'child' isn't an ERR_PTR

regards,
dan carpenter
