Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qt0-f170.google.com ([209.85.216.170]:36016 "EHLO
        mail-qt0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753679AbeDKOVV (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 11 Apr 2018 10:21:21 -0400
MIME-Version: 1.0
In-Reply-To: <1522445280-7767-2-git-send-email-longman@redhat.com>
References: <1522445280-7767-1-git-send-email-longman@redhat.com> <1522445280-7767-2-git-send-email-longman@redhat.com>
From: Arnd Bergmann <arnd@arndb.de>
Date: Wed, 11 Apr 2018 16:21:16 +0200
Message-ID: <CAK8P3a1yJG7VfJbXFkv4G-BQk7PMUu0kTJwtNiDin7RzaZKZcQ@mail.gmail.com>
Subject: Re: [PATCH v5 1/3] locking/rwsem: Add DEBUG_RWSEMS to look for
 lock/unlock mismatches
To: Waiman Long <longman@redhat.com>
Cc: Ingo Molnar <mingo@redhat.com>,
        Peter Zijlstra <peterz@infradead.org>,
        Thomas Gleixner <tglx@linutronix.de>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
        Davidlohr Bueso <dave@stgolabs.net>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Mar 30, 2018 at 11:27 PM, Waiman Long <longman@redhat.com> wrote:
> For a rwsem, locking can either be exclusive or shared. The corresponding
> exclusive or shared unlock must be used. Otherwise, the protected data
> structures may get corrupted or the lock may be in an inconsistent state.
>
> In order to detect such anomaly, a new configuration option DEBUG_RWSEMS
> is added which can be enabled to look for such mismatches and print
> warnings that that happens.
>
> Signed-off-by: Waiman Long <longman@redhat.com>
> Acked-by: Davidlohr Bueso <dave@stgolabs.net>

The new warning triggered in NFS, see
https://bugs.linaro.org/show_bug.cgi?id=3731

[   52.651490] DEBUG_LOCKS_WARN_ON(sem->owner != ((struct task_struct *)1UL))
[   52.651506] WARNING: CPU: 2 PID: 1457 at
/srv/oe/build/tmp-rpb-glibc/work-shared/intel-core2-32/kernel-source/kernel/locking/rwsem.c:217
up_read_non_owner+0x5d/0x70
[   52.674398] Modules linked in: x86_pkg_temp_thermal fuse
[   52.679719] CPU: 2 PID: 1457 Comm: kworker/2:2 Not tainted 4.16.0 #1
[   52.687448] Hardware name: Supermicro SYS-5019S-ML/X11SSH-F, BIOS
2.0b 07/27/2017
[   52.694922] Workqueue: nfsiod rpc_async_release
[   52.699454] RIP: 0010:up_read_non_owner+0x5d/0x70
[   52.704157] RSP: 0018:ffff9cbf81a23dd0 EFLAGS: 00010282
[   52.709376] RAX: 0000000000000000 RBX: ffff8dc1983c76c0 RCX: 0000000000000000
[   52.716500] RDX: ffffffffbd2d26c9 RSI: 0000000000000001 RDI: ffffffffbd2d2889
[   52.723652] RBP: ffff9cbf81a23dd8 R08: 0000000000000000 R09: 0000000000000000
[   52.730782] R10: ffff9cbf81a23dd0 R11: 0000000000000000 R12: ffff8dc19abf8600
[   52.737906] R13: ffff8dc19b6c0000 R14: 0000000000000000 R15: ffff8dc19bacad80
[   52.745029] FS:  0000000000000000(0000) GS:ffff8dc1afd00000(0000)
knlGS:0000000000000000
[   52.753108] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[   52.758845] CR2: 00007f33794665d8 CR3: 000000016c41e006 CR4: 00000000003606e0
[   52.765968] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
[   52.773091] DR3: 0000000000000000 DR6: 00000000fffe0ff0 DR7: 0000000000000400
[   52.780215] Call Trace:
[   52.782695]  nfs_async_unlink_release+0x32/0x80
[   52.787220]  rpc_free_task+0x30/0x50
[   52.790789]  rpc_async_release+0x12/0x20
[   52.794707]  process_one_work+0x25e/0x660
[   52.798713]  worker_thread+0x4b/0x410
[   52.802377]  kthread+0x10d/0x140
[   52.805600]  ? rescuer_thread+0x3a0/0x3a0
[   52.809652]  ? kthread_create_worker_on_cpu+0x70/0x70
[   52.814702]  ? do_syscall_64+0x69/0x1b0
[   52.818540]  ret_from_fork+0x3a/0x50
[   52.822112] Code: ad 00 5b 5d c3 e8 74 ac 38 00 85 c0 74 de 8b 05
02 e3 48 02 85 c0 75 d4 48 c7 c6 c8 eb 4d be 48 c7 c7 5b ae 4c be e8
03 ae fa ff <0f> 0b eb bd 0f 1f 44 00 00 66 2e 0f 1f 84 00 00 00 00 00
0f 1f

I don't see anything immediately wrong with rmdir_sem (it's not that
complicated),
and there are only three users of up_read_non_owner(), so my first
suspicion would
be that something is wrong with the debug code, but please take a look
for yourself.

I also see that Bruce reported the same warning in
https://www.spinics.net/lists/linux-nfs/msg68064.html but apparently got no
reply.

      Arnd
