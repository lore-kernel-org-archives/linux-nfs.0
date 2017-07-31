Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from scorn.kernelslacker.org ([45.56.101.199]:52208 "EHLO
        scorn.kernelslacker.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751046AbdGaPn1 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 31 Jul 2017 11:43:27 -0400
Date: Mon, 31 Jul 2017 11:43:22 -0400
From: "davej@codemonkey.org.uk" <davej@codemonkey.org.uk>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Trond Myklebust <trondmy@primarydata.com>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "bfields@fieldses.org" <bfields@fieldses.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "schumaker.anna@gmail.com" <schumaker.anna@gmail.com>,
        "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>
Subject: Re: [GIT PULL] Please pull NFS client changes for Linux 4.13
Message-ID: <20170731154322.tfzkukscda4fe7wm@codemonkey.org.uk>
References: <cf7efbe6-899c-368d-6d56-c2cb3eb28acc@gmail.com>
 <20170714142543.k5xcbnb4mww3sxpy@codemonkey.org.uk>
 <20170716211530.sx7mn35f2mhmykug@codemonkey.org.uk>
 <1500245845.13893.3.camel@primarydata.com>
 <20170717030504.qca74wsswct26ytn@codemonkey.org.uk>
 <CA+55aFy6kUwPTbzKebO4=BovEc_Nq3XCoYMeofgCM3ypxrkvJg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <CA+55aFy6kUwPTbzKebO4=BovEc_Nq3XCoYMeofgCM3ypxrkvJg@mail.gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Another NFSv4 KASAN splat, this time from rc3.


==================================================================
BUG: KASAN: use-after-free in nfs4_exchange_id_done+0x3d7/0x8e0 [nfsv4]
Read of size 8 at addr ffff8804508af528 by task kworker/2:1/34

CPU: 2 PID: 34 Comm: kworker/2:1 Not tainted 4.13.0-rc3-think+ #1 
Workqueue: rpciod rpc_async_schedule [sunrpc]
Call Trace:
 dump_stack+0x68/0xa1
 print_address_description+0xd9/0x270
 kasan_report+0x257/0x370
 ? nfs4_exchange_id_done+0x3d7/0x8e0 [nfsv4]
 check_memory_region+0x13a/0x1a0
 __asan_loadN+0xf/0x20
 nfs4_exchange_id_done+0x3d7/0x8e0 [nfsv4]
 ? nfs4_exchange_id_release+0xb0/0xb0 [nfsv4]
 rpc_exit_task+0x69/0x110 [sunrpc]
 ? rpc_destroy_wait_queue+0x20/0x20 [sunrpc]
 ? rpc_destroy_wait_queue+0x20/0x20 [sunrpc]
 __rpc_execute+0x1a0/0x840 [sunrpc]
 ? rpc_wake_up_queued_task+0x50/0x50 [sunrpc]
 ? __lock_is_held+0x9a/0x100
 ? debug_lockdep_rcu_enabled.part.16+0x1a/0x30
 rpc_async_schedule+0x12/0x20 [sunrpc]
 process_one_work+0x4d5/0xa70
 ? flush_delayed_work+0x70/0x70
 ? lock_acquire+0xfc/0x220
 worker_thread+0x88/0x630
 ? pci_mmcfg_check_reserved+0xc0/0xc0
 kthread+0x1a6/0x1f0
 ? process_one_work+0xa70/0xa70
 ? kthread_create_on_node+0xc0/0xc0
 ret_from_fork+0x27/0x40

Allocated by task 1:
 save_stack_trace+0x1b/0x20
 save_stack+0x46/0xd0
 kasan_kmalloc+0xad/0xe0
 kasan_slab_alloc+0x12/0x20
 kmem_cache_alloc+0xe0/0x2f0
 getname_flags+0x43/0x220
 getname+0x12/0x20
 do_sys_open+0x14c/0x2b0
 SyS_open+0x1e/0x20
 do_syscall_64+0xea/0x260
 return_from_SYSCALL_64+0x0/0x7a

Freed by task 1:
 save_stack_trace+0x1b/0x20
 save_stack+0x46/0xd0
 kasan_slab_free+0x72/0xc0
 kmem_cache_free+0xa8/0x300
 putname+0x80/0x90
 do_sys_open+0x22f/0x2b0
 SyS_open+0x1e/0x20
 do_syscall_64+0xea/0x260
 return_from_SYSCALL_64+0x0/0x7a

The buggy address belongs to the object at ffff8804508aeac0\x0a which belongs to the cache names_cache of size 4096
The buggy address is located 2664 bytes inside of\x0a 4096-byte region [ffff8804508aeac0, ffff8804508afac0)
The buggy address belongs to the page:
page:ffffea0011422a00 count:1 mapcount:0 mapping:          (null) index:0x0
[CONT START]  compound_mapcount: 0
flags: 0x8000000000008100(slab|head)
raw: 8000000000008100 0000000000000000 0000000000000000 0000000100070007
raw: ffffea00113d6020 ffffea001136e220 ffff8804664f8040 0000000000000000
page dumped because: kasan: bad access detected

Memory state around the buggy address:
 ffff8804508af400: fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb
 ffff8804508af480: fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb
>ffff8804508af500: fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb
                                  ^
 ffff8804508af580: fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb
 ffff8804508af600: fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb
==================================================================

