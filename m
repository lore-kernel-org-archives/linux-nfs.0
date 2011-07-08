Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:43027 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751872Ab1GHPDn (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 8 Jul 2011 11:03:43 -0400
Message-ID: <4E171C49.7070504@candelatech.com>
Date: Fri, 08 Jul 2011 08:03:37 -0700
From: Ben Greear <greearb@candelatech.com>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
CC: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
Subject: Re: [RFC] sunrpc:  Fix race between work-queue and rpc_killall_tasks.
References: <1309992581-25199-1-git-send-email-greearb@candelatech.com> <1309995932.5447.6.camel@lade.trondhjem.org> <4E161942.4070907@candelatech.com>
In-Reply-To: <4E161942.4070907@candelatech.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 07/07/2011 01:38 PM, Ben Greear wrote:
> On 07/06/2011 04:45 PM, Trond Myklebust wrote:
>> On Wed, 2011-07-06 at 15:49 -0700, greearb@candelatech.com wrote:
>>> From: Ben Greear<greearb@candelatech.com>
>>>
>>> The rpc_killall_tasks logic is not locked against
>>> the work-queue thread, but it still directly modifies
>>> function pointers and data in the task objects.
>>>
>>> This patch changes the killall-tasks logic to set a flag
>>> that tells the work-queue thread to terminate the task
>>> instead of directly calling the terminate logic.
>>>
>>> Signed-off-by: Ben Greear<greearb@candelatech.com>
>>> ---
>>>
>>> NOTE: This needs review, as I am still struggling to understand
>>> the rpc code, and it's quite possible this patch either doesn't
>>> fully fix the problem or actually causes other issues. That said,
>>> my nfs stress test seems to run a bit more stable with this patch applied.
>>
>> Yes, but I don't see why you are adding a new flag, nor do I see why we
>> want to keep checking for that flag in the rpc_execute() loop.
>> rpc_killall_tasks() is not a frequent operation that we want to optimise
>> for.
>>
>> How about the following instead?
>>
>> 8<----------------------------------------------------------------------------------
>> From ecb7244b661c3f9d2008ef6048733e5cea2f98ab Mon Sep 17 00:00:00 2001
>> From: Trond Myklebust<Trond.Myklebust@netapp.com>
>> Date: Wed, 6 Jul 2011 19:44:52 -0400
>> Subject: [PATCH] SUNRPC: Fix a race between work-queue and rpc_killall_tasks
>>
>> Since rpc_killall_tasks may modify the rpc_task's tk_action field
>> without any locking, we need to be careful when dereferencing it.
>>
>> Reported-by: Ben Greear<greearb@candelatech.com>
>> Signed-off-by: Trond Myklebust<Trond.Myklebust@netapp.com>
>
> I've been testing this for 4+ hours, and it seems to fix the problem. We'll
> continue to burn on it for a day or two just in case we're
> getting (un)lucky in our testing.
>
> Thanks,
> Ben

Well, we still hit the bug in over-night testing.  Maybe there are other races...

=============================================================================
BUG kmalloc-64: Object is on free-list
-----------------------------------------------------------------------------

INFO: Allocated in rpcb_getport_async+0x39c/0x5a5 [sunrpc] age=52 cpu=6 pid=18908
         __slab_alloc+0x348/0x3ba
         kmem_cache_alloc_trace+0x67/0xe7
         rpcb_getport_async+0x39c/0x5a5 [sunrpc]
         call_bind+0x70/0x75 [sunrpc]
         __rpc_execute+0x80/0x253 [sunrpc]
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
INFO: Freed in rpcb_map_release+0x3f/0x44 [sunrpc] age=119 cpu=5 pid=13934
         __slab_free+0x57/0x150
         kfree+0x107/0x13a
         rpcb_map_release+0x3f/0x44 [sunrpc]
         rpc_release_calldata+0x12/0x14 [sunrpc]
         rpc_free_task+0x72/0x7a [sunrpc]
         rpc_final_put_task+0x82/0x8a [sunrpc]
         __rpc_execute+0x244/0x253 [sunrpc]
         rpc_async_schedule+0x10/0x12 [sunrpc]
         process_one_work+0x230/0x41d
         worker_thread+0x133/0x217
         kthread+0x7d/0x85
         kernel_thread_helper+0x4/0x10
INFO: Slab 0xffffea0002c38b90 objects=20 used=13 fp=0xffff8800ca27e620 flags=0x20000000004081
INFO: Object 0xffff8800ca27e620 @offset=1568 fp=0xffff8800ca27f880
Bytes b4 0xffff8800ca27e610:  d0 c4 1a 02 01 00 00 00 5a 5a 5a 5a 5a 5a 5a 5a ÐÄ......ZZZZZZZZ
   Object 0xffff8800ca27e620:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
   Object 0xffff8800ca27e630:  6b 6b 6b 6b 00 00 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkk..kkkkkkkkkk
   Object 0xffff8800ca27e640:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
   Object 0xffff8800ca27e650:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b a5 kkkkkkkkkkkkkkk¥
  Redzone 0xffff8800ca27e660:  bb bb bb bb bb bb bb bb                         »»»»»»»»
  Padding 0xffff8800ca27e7a0:  5a 5a 5a 5a 5a 5a 5a 5a                         ZZZZZZZZ
Pid: 13035, comm: kworker/0:1 Not tainted 3.0.0-rc6+ #13
Call Trace:
  [<ffffffff81105907>] print_trailer+0x131/0x13a
  [<ffffffff81105945>] object_err+0x35/0x3e
  [<ffffffff811077b3>] verify_mem_not_deleted+0x7a/0xb7
  [<ffffffffa02891e5>] rpcb_getport_done+0x23/0x126 [sunrpc]
  [<ffffffffa02810df>] rpc_exit_task+0x3f/0x6d [sunrpc]
  [<ffffffffa02814d8>] __rpc_execute+0x80/0x253 [sunrpc]
  [<ffffffffa02816ed>] ? rpc_execute+0x42/0x42 [sunrpc]
  [<ffffffffa02816fd>] rpc_async_schedule+0x10/0x12 [sunrpc]
  [<ffffffff81061343>] process_one_work+0x230/0x41d
  [<ffffffff8106128e>] ? process_one_work+0x17b/0x41d
  [<ffffffff8106379f>] worker_thread+0x133/0x217
  [<ffffffff8106366c>] ? manage_workers+0x191/0x191
  [<ffffffff81066f9c>] kthread+0x7d/0x85
  [<ffffffff81485ee4>] kernel_thread_helper+0x4/0x10
  [<ffffffff8147f0d8>] ? retint_restore_args+0x13/0x13
  [<ffffffff81066f1f>] ? __init_kthread_worker+0x56/0x56
  [<ffffffff81485ee0>] ? gs_change+0x13/0x13

Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
