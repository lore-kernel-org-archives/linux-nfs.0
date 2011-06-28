Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:54195 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756275Ab1F1QnV (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 28 Jun 2011 12:43:21 -0400
Received: from [192.168.100.195] (firewall.candelatech.com [70.89.124.249])
	(authenticated bits=0)
	by ns3.lanforge.com (8.14.2/8.14.2) with ESMTP id p5SGhKTR017501
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <linux-nfs@vger.kernel.org>; Tue, 28 Jun 2011 09:43:21 -0700
Message-ID: <4E0A04A8.6040600@candelatech.com>
Date: Tue, 28 Jun 2011 09:43:20 -0700
From: Ben Greear <greearb@candelatech.com>
To: linux-nfs@vger.kernel.org
Subject: More nfs/rpc debugging questions.
Content-Type: text/plain; charset=UTF-8; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

I instrumented slub to get a better backtrace.  I am definitely
getting deleted memory passed in the rpcb_getport_done method.

While trying to figure out how this could happen, I started
looking at the task->tk_count variable.

In particular, the line below with !RPC_IS_ASYNC in it looks
quite subtle.

Could someone explain what the tk_count is supposed to
represent for async v/s sync tasks?

static void rpc_release_task(struct rpc_task *task)
{
	dprintk("RPC: %5u release task\n", task->tk_pid);

	BUG_ON (RPC_IS_QUEUED(task));

	rpc_release_resources_task(task);

	/*
	 * Note: at this point we have been removed from rpc_clnt->cl_tasks,
	 * so it should be safe to use task->tk_count as a test for whether
	 * or not any other processes still hold references to our rpc_task.
	 */
	if (atomic_read(&task->tk_count) != 1 + !RPC_IS_ASYNC(task)) {
		/* Wake up anyone who may be waiting for task completion */
		if (!rpc_complete_task(task))
			return;
	} else {
		if (!atomic_dec_and_test(&task->tk_count))
			return;
	}
	rpc_final_put_task(task, task->tk_workqueue);
}


The trace for the code I'm debugging (the nfs client IP binding patches posted
recenly) is below, in case this provides a clue that I'm not seeing yet.


=============================================================================
BUG kmalloc-64: Object is on free-list
-----------------------------------------------------------------------------

INFO: Allocated in rpcb_getport_async+0x39c/0x5a5 [sunrpc] age=381 cpu=3 pid=3750
         __slab_alloc+0x348/0x3ba
         kmem_cache_alloc_trace+0x67/0xe7
         rpcb_getport_async+0x39c/0x5a5 [sunrpc]
         call_bind+0x70/0x75 [sunrpc]
         __rpc_execute+0x78/0x24b [sunrpc]
         rpc_execute+0x3d/0x42 [sunrpc]
         rpc_run_task+0x79/0x81 [sunrpc]
         rpc_call_sync+0x3f/0x60 [sunrpc]
         rpc_ping+0x42/0x58 [sunrpc]
         rpc_create+0x4aa/0x527 [sunrpc]
         nfs_create_rpc_client+0xb1/0xf6 [nfs]
         nfs_init_client+0x3b/0x7d [nfs]
         nfs_get_client+0x453/0x5ab [nfs]
         nfs_create_server+0x10b/0x437 [nfs]
         nfs_fs_mount+0x4ca/0x708 [nfs]
         mount_fs+0x6b/0x152
INFO: Freed in rpcb_map_release+0x3f/0x44 [sunrpc] age=30 cpu=2 pid=29049
         __slab_free+0x57/0x150
         kfree+0x107/0x13a
         rpcb_map_release+0x3f/0x44 [sunrpc]
         rpc_release_calldata+0x12/0x14 [sunrpc]
         rpc_free_task+0x59/0x61 [sunrpc]
         rpc_final_put_task+0x82/0x8a [sunrpc]
         __rpc_execute+0x23c/0x24b [sunrpc]
         rpc_async_schedule+0x10/0x12 [sunrpc]
         process_one_work+0x230/0x41d
         worker_thread+0x133/0x217
         kthread+0x7d/0x85
         kernel_thread_helper+0x4/0x10
INFO: Slab 0xffffea00029aa470 objects=20 used=9 fp=0xffff8800be7830d8 flags=0x20000000004081
INFO: Object 0xffff8800be7830d8 @offset=4312 fp=0xffff8800be7827a8

Bytes b4 0xffff8800be7830c8:  87 a8 96 00 01 00 00 00 5a 5a 5a 5a 5a 5a 5a 5a .�......ZZZZZZZZ
   Object 0xffff8800be7830d8:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
   Object 0xffff8800be7830e8:  6b 6b 6b 6b 01 08 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkk..kkkkkkkkkk
   Object 0xffff8800be7830f8:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
   Object 0xffff8800be783108:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b a5 kkkkkkkkkkkkkkk�
  Redzone 0xffff8800be783118:  bb bb bb bb bb bb bb bb                         �������������
  Padding 0xffff8800be783258:  5a 5a 5a 5a 5a 5a 5a 5a                         ZZZZZZZZ
Pid: 29049, comm: kworker/2:2 Not tainted 3.0.0-rc4+ #8
Call Trace:
  [<ffffffff811055c3>] print_trailer+0x131/0x13a
  [<ffffffff81105601>] object_err+0x35/0x3e
  [<ffffffff8110746f>] verify_mem_not_deleted+0x7a/0xb7
  [<ffffffffa02851b5>] rpcb_getport_done+0x23/0x126 [sunrpc]
  [<ffffffffa027d0ba>] rpc_exit_task+0x3f/0x6d [sunrpc]
  [<ffffffffa027d4ab>] __rpc_execute+0x78/0x24b [sunrpc]
  [<ffffffffa027d6c0>] ? rpc_execute+0x42/0x42 [sunrpc]
  [<ffffffffa027d6d0>] rpc_async_schedule+0x10/0x12 [sunrpc]
  [<ffffffff810611b7>] process_one_work+0x230/0x41d
  [<ffffffff81061102>] ? process_one_work+0x17b/0x41d
  [<ffffffff81063613>] worker_thread+0x133/0x217
  [<ffffffff810634e0>] ? manage_workers+0x191/0x191
  [<ffffffff81066e10>] kthread+0x7d/0x85
  [<ffffffff81485924>] kernel_thread_helper+0x4/0x10
  [<ffffffff8147eb18>] ? retint_restore_args+0x13/0x13
  [<ffffffff81066d93>] ? __init_kthread_worker+0x56/0x56
  [<ffffffff81485920>] ? gs_change+0x13/0x13

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com

