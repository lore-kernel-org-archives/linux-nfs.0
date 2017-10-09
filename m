Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from foss.arm.com ([217.140.101.70]:33532 "EHLO foss.arm.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751635AbdJISRp (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 9 Oct 2017 14:17:45 -0400
Date: Mon, 9 Oct 2017 19:17:38 +0100
From: Lorenzo Pieralisi <lorenzo.pieralisi@arm.com>
To: linux-kernel@vger.kernel.org, linux-nfs@vger.kernel.org
Cc: Trond Myklebust <trond.myklebust@primarydata.com>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        Jeff Layton <jlayton@poochiereds.net>
Subject: net/sunrpc: v4.14-rc4 lockdep warning
Message-ID: <20171009181738.GA30680@red-moon>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi,

I have run into the lockdep warning below while running v4.14-rc3/rc4
on an ARM64 defconfig Juno dev board - reporting it to check whether
it is a known/genuine issue.

Please let me know if you need further debug data or need some
specific tests.

Thanks,
Lorenzo

[    6.209384] ======================================================
[    6.215569] WARNING: possible circular locking dependency detected
[    6.221755] 4.14.0-rc4 #54 Not tainted
[    6.225503] ------------------------------------------------------
[    6.231689] kworker/4:0H/32 is trying to acquire lock:
[    6.236830]  ((&task->u.tk_work)){+.+.}, at: [<ffff0000080e64cc>] process_one_work+0x1cc/0x3f0
[    6.245472] 
               but task is already holding lock:
[    6.251309]  ("xprtiod"){+.+.}, at: [<ffff0000080e64cc>] process_one_work+0x1cc/0x3f0
[    6.259158] 
               which lock already depends on the new lock.

[    6.267345] 
               the existing dependency chain (in reverse order) is:
[    6.274836] 
               -> #1 ("xprtiod"){+.+.}:
[    6.279903]        lock_acquire+0x6c/0xb8
[    6.283914]        flush_work+0x188/0x270
[    6.287926]        __cancel_work_timer+0x120/0x198
[    6.292720]        cancel_work_sync+0x10/0x18
[    6.297081]        xs_destroy+0x34/0x58
[    6.300917]        xprt_destroy+0x84/0x90
[    6.304927]        xprt_put+0x34/0x40
[    6.308589]        rpc_task_release_client+0x6c/0x80
[    6.313557]        rpc_release_resources_task+0x2c/0x38
[    6.318786]        __rpc_execute+0x9c/0x210
[    6.322971]        rpc_async_schedule+0x10/0x18
[    6.327504]        process_one_work+0x240/0x3f0
[    6.332036]        worker_thread+0x48/0x420
[    6.336222]        kthread+0x12c/0x158
[    6.339972]        ret_from_fork+0x10/0x18
[    6.344068] 
               -> #0 ((&task->u.tk_work)){+.+.}:
[    6.349920]        __lock_acquire+0x12ec/0x14a8
[    6.354451]        lock_acquire+0x6c/0xb8
[    6.358462]        process_one_work+0x22c/0x3f0
[    6.362994]        worker_thread+0x48/0x420
[    6.367180]        kthread+0x12c/0x158
[    6.370929]        ret_from_fork+0x10/0x18
[    6.375025] 
               other info that might help us debug this:

[    6.383038]  Possible unsafe locking scenario:

[    6.388962]        CPU0                    CPU1
[    6.393493]        ----                    ----
[    6.398023]   lock("xprtiod");
[    6.401080]                                lock((&task->u.tk_work));
[    6.407444]                                lock("xprtiod");
[    6.413024]   lock((&task->u.tk_work));
[    6.416863] 
                *** DEADLOCK ***

[    6.422789] 1 lock held by kworker/4:0H/32:
[    6.426972]  #0:  ("xprtiod"){+.+.}, at: [<ffff0000080e64cc>] process_one_work+0x1cc/0x3f0
[    6.435258] 
               stack backtrace:
[    6.439618] CPU: 4 PID: 32 Comm: kworker/4:0H Not tainted 4.14.0-rc4 #54
[    6.446325] Hardware name: ARM Juno development board (r2) (DT)
[    6.452252] Workqueue: xprtiod rpc_async_schedule
[    6.456959] Call trace:
[    6.459406] [<ffff000008089430>] dump_backtrace+0x0/0x3c8
[    6.464810] [<ffff00000808980c>] show_stack+0x14/0x20
[    6.469866] [<ffff000008a01a30>] dump_stack+0xb8/0xf0
[    6.474922] [<ffff0000081194ac>] print_circular_bug+0x224/0x3a0
[    6.480849] [<ffff00000811a304>] check_prev_add+0x304/0x860
[    6.486426] [<ffff00000811c8c4>] __lock_acquire+0x12ec/0x14a8
[    6.492177] [<ffff00000811d144>] lock_acquire+0x6c/0xb8
[    6.497406] [<ffff0000080e652c>] process_one_work+0x22c/0x3f0
[    6.503156] [<ffff0000080e6738>] worker_thread+0x48/0x420
[    6.508560] [<ffff0000080ed5bc>] kthread+0x12c/0x158
[    6.513528] [<ffff000008084d48>] ret_from_fork+0x10/0x18
