Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f176.google.com ([209.85.223.176]:46964 "EHLO
        mail-io0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751518AbdKEIxe (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sun, 5 Nov 2017 03:53:34 -0500
Received: by mail-io0-f176.google.com with SMTP id 101so12751996ioj.3
        for <linux-nfs@vger.kernel.org>; Sun, 05 Nov 2017 01:53:34 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <001a113ee9baf95598055d384ecb@google.com>
References: <001a113ee9baf95598055d384ecb@google.com>
From: Dmitry Vyukov <dvyukov@google.com>
Date: Sun, 5 Nov 2017 11:53:13 +0300
Message-ID: <CACT4Y+aWdUXDV5-d=xJQ2VtQyFkPRKqVodpL38-nUQ9oS6+Y9A@mail.gmail.com>
Subject: Re: possible deadlock in flush_work (2)
To: syzbot
        <bot+d8fe95298ef830cd7d05e33eefa4a5a6f6f334d4@syzkaller.appspotmail.com>
Cc: Lai Jiangshan <jiangshanlai@gmail.com>,
        LKML <linux-kernel@vger.kernel.org>,
        syzkaller-bugs@googlegroups.com, Tejun Heo <tj@kernel.org>,
        Bruce Fields <bfields@fieldses.org>,
        Jeff Layton <jlayton@poochiereds.net>,
        trond.myklebust@primarydata.com, anna.schumaker@netapp.com,
        David Miller <davem@davemloft.net>, linux-nfs@vger.kernel.org,
        netdev <netdev@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sun, Nov 5, 2017 at 11:41 AM, syzbot
<bot+d8fe95298ef830cd7d05e33eefa4a5a6f6f334d4@syzkaller.appspotmail.com>
wrote:
> Hello,
>
> syzkaller hit the following crash on
> 0f611fb6dcc0d6d91b4e1fec911321f434a3b858
> git://git.cmpxchg.org/linux-mmots.git/master
> compiler: gcc (GCC) 7.1.1 20170620
> .config is attached
> Raw console output is attached.
>
> xs_tcp_setup_socket: connect returned unhandled error -113
> xs_tcp_setup_socket: connect returned unhandled error -113
> xs_tcp_setup_socket: connect returned unhandled error -113
>
> ======================================================
> WARNING: possible circular locking dependency detected
> 4.14.0-rc5-mm1+ #20 Not tainted
> ------------------------------------------------------
> kworker/0:3/3400 is trying to acquire lock:
>  ("xprtiod"){+.+.}, at: [<ffffffff8146adda>] start_flush_work
> kernel/workqueue.c:2850 [inline]
>  ("xprtiod"){+.+.}, at: [<ffffffff8146adda>] flush_work+0x55a/0x8a0
> kernel/workqueue.c:2882
>
> but task is already holding lock:
>  ((&task->u.tk_work)){+.+.}, at: [<ffffffff81471eb2>]
> process_one_work+0xb32/0x1bc0 kernel/workqueue.c:2087
>
> which lock already depends on the new lock.
>
>
> the existing dependency chain (in reverse order) is:
>
> -> #1 ((&task->u.tk_work)){+.+.}:
>        process_one_work+0xba2/0x1bc0 kernel/workqueue.c:2088
>        worker_thread+0x223/0x1990 kernel/workqueue.c:2246
>        kthread+0x38b/0x470 kernel/kthread.c:242
>        ret_from_fork+0x2a/0x40 arch/x86/entry/entry_64.S:431
>
> -> #0 ("xprtiod"){+.+.}:
>        lock_acquire+0x1d5/0x580 kernel/locking/lockdep.c:3991
>        start_flush_work kernel/workqueue.c:2851 [inline]
>        flush_work+0x57f/0x8a0 kernel/workqueue.c:2882
>        __cancel_work_timer+0x30a/0x7e0 kernel/workqueue.c:2954
>        cancel_work_sync+0x17/0x20 kernel/workqueue.c:2990
>        xprt_destroy+0xa1/0x130 net/sunrpc/xprt.c:1467
>        xprt_destroy_kref net/sunrpc/xprt.c:1477 [inline]
>        kref_put include/linux/kref.h:70 [inline]
>        xprt_put+0x38/0x40 net/sunrpc/xprt.c:1501
>        rpc_task_release_client+0x299/0x430 net/sunrpc/clnt.c:986
>        rpc_release_resources_task+0x7f/0xa0 net/sunrpc/sched.c:1020
>        rpc_release_task net/sunrpc/sched.c:1059 [inline]
>        __rpc_execute+0x4d9/0xe70 net/sunrpc/sched.c:824
>        rpc_async_schedule+0x16/0x20 net/sunrpc/sched.c:848
>        process_one_work+0xbf0/0x1bc0 kernel/workqueue.c:2112
>        worker_thread+0x223/0x1990 kernel/workqueue.c:2246
>        kthread+0x38b/0x470 kernel/kthread.c:242
>        ret_from_fork+0x2a/0x40 arch/x86/entry/entry_64.S:431
>
> other info that might help us debug this:
>
>  Possible unsafe locking scenario:
>
>        CPU0                    CPU1
>        ----                    ----
>   lock((&task->u.tk_work));
>                                lock("xprtiod");
>                                lock((&task->u.tk_work));
>   lock("xprtiod");
>
>  *** DEADLOCK ***
>
> 2 locks held by kworker/0:3/3400:
>  #0:  ("rpciod"){+.+.}, at: [<ffffffff81471e5f>] __write_once_size
> include/linux/compiler.h:305 [inline]
>  #0:  ("rpciod"){+.+.}, at: [<ffffffff81471e5f>] atomic64_set
> arch/x86/include/asm/atomic64_64.h:33 [inline]
>  #0:  ("rpciod"){+.+.}, at: [<ffffffff81471e5f>] atomic_long_set
> include/asm-generic/atomic-long.h:56 [inline]
>  #0:  ("rpciod"){+.+.}, at: [<ffffffff81471e5f>] set_work_data
> kernel/workqueue.c:618 [inline]
>  #0:  ("rpciod"){+.+.}, at: [<ffffffff81471e5f>]
> set_work_pool_and_clear_pending kernel/workqueue.c:645 [inline]
>  #0:  ("rpciod"){+.+.}, at: [<ffffffff81471e5f>]
> process_one_work+0xadf/0x1bc0 kernel/workqueue.c:2083
>  #1:  ((&task->u.tk_work)){+.+.}, at: [<ffffffff81471eb2>]
> process_one_work+0xb32/0x1bc0 kernel/workqueue.c:2087
>
> stack backtrace:
> CPU: 0 PID: 3400 Comm: kworker/0:3 Not tainted 4.14.0-rc5-mm1+ #20
> Hardware name: Google Google Compute Engine/Google Compute Engine, BIOS
> Google 01/01/2011
> Workqueue: rpciod rpc_async_schedule
> Call Trace:
>  __dump_stack lib/dump_stack.c:16 [inline]
>  dump_stack+0x194/0x257 lib/dump_stack.c:52
>  print_circular_bug.isra.41+0x342/0x36a kernel/locking/lockdep.c:1258
>  check_prev_add kernel/locking/lockdep.c:1901 [inline]
>  check_prevs_add kernel/locking/lockdep.c:2018 [inline]
>  validate_chain kernel/locking/lockdep.c:2460 [inline]
>  __lock_acquire+0x2f55/0x3d50 kernel/locking/lockdep.c:3487
>  lock_acquire+0x1d5/0x580 kernel/locking/lockdep.c:3991
>  start_flush_work kernel/workqueue.c:2851 [inline]
>  flush_work+0x57f/0x8a0 kernel/workqueue.c:2882
>  __cancel_work_timer+0x30a/0x7e0 kernel/workqueue.c:2954
>  cancel_work_sync+0x17/0x20 kernel/workqueue.c:2990
>  xprt_destroy+0xa1/0x130 net/sunrpc/xprt.c:1467
>  xprt_destroy_kref net/sunrpc/xprt.c:1477 [inline]
>  kref_put include/linux/kref.h:70 [inline]
>  xprt_put+0x38/0x40 net/sunrpc/xprt.c:1501
>  rpc_task_release_client+0x299/0x430 net/sunrpc/clnt.c:986
>  rpc_release_resources_task+0x7f/0xa0 net/sunrpc/sched.c:1020
>  rpc_release_task net/sunrpc/sched.c:1059 [inline]
>  __rpc_execute+0x4d9/0xe70 net/sunrpc/sched.c:824
>  rpc_async_schedule+0x16/0x20 net/sunrpc/sched.c:848
>  process_one_work+0xbf0/0x1bc0 kernel/workqueue.c:2112
>  worker_thread+0x223/0x1990 kernel/workqueue.c:2246
>  kthread+0x38b/0x470 kernel/kthread.c:242
>  ret_from_fork+0x2a/0x40 arch/x86/entry/entry_64.S:431


+sunrpc maintainers


> ---
> This bug is generated by a dumb bot. It may contain errors.
> See https://goo.gl/tpsmEJ for details.
> Direct all questions to syzkaller@googlegroups.com.
> Please credit me with: Reported-by: syzbot <syzkaller@googlegroups.com>
>
> syzbot will keep track of this bug report.
> Once a fix for this bug is committed, please reply to this email with:
> #syz fix: exact-commit-title
> To mark this as a duplicate of another syzbot report, please reply with:
> #syz dup: exact-subject-of-another-report
> If it's a one-off invalid bug report, please reply with:
> #syz invalid
> Note: if the crash happens again, it will cause creation of a new bug
> report.
> Note: all commands must start from beginning of the line.
>
> --
> You received this message because you are subscribed to the Google Groups
> "syzkaller-bugs" group.
> To unsubscribe from this group and stop receiving emails from it, send an
> email to syzkaller-bugs+unsubscribe@googlegroups.com.
> To view this discussion on the web visit
> https://groups.google.com/d/msgid/syzkaller-bugs/001a113ee9baf95598055d384ecb%40google.com.
> For more options, visit https://groups.google.com/d/optout.
