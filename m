Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f193.google.com ([209.85.223.193]:44171 "EHLO
        mail-io0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753559AbeEWBqS (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 22 May 2018 21:46:18 -0400
MIME-Version: 1.0
References: <1522445280-7767-1-git-send-email-longman@redhat.com>
 <1522445280-7767-2-git-send-email-longman@redhat.com> <CAK8P3a1yJG7VfJbXFkv4G-BQk7PMUu0kTJwtNiDin7RzaZKZcQ@mail.gmail.com>
In-Reply-To: <CAK8P3a1yJG7VfJbXFkv4G-BQk7PMUu0kTJwtNiDin7RzaZKZcQ@mail.gmail.com>
From: Dan Williams <dan.j.williams@intel.com>
Date: Tue, 22 May 2018 18:46:03 -0700
Message-ID: <CAA9_cmdJXA6VckCMXtqjzbZZ5pXNXhLVNh+YWL+sLs7yGACxYQ@mail.gmail.com>
Subject: Re: [PATCH v5 1/3] locking/rwsem: Add DEBUG_RWSEMS to look for
 lock/unlock mismatches
To: Arnd Bergmann <arnd@arndb.de>
Cc: longman@redhat.com, Ingo Molnar <mingo@redhat.com>,
        Peter Zijlstra <peterz@infradead.org>,
        Thomas Gleixner <tglx@linutronix.de>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
        dave@stgolabs.net, linux-nfs@vger.kernel.org,
        trond.myklebust@primarydata.com, anna.schumaker@netapp.com,
        Linus Torvalds <torvalds@linux-foundation.org>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Apr 11, 2018 at 7:24 AM Arnd Bergmann <arnd@arndb.de> wrote:

> On Fri, Mar 30, 2018 at 11:27 PM, Waiman Long <longman@redhat.com> wrote:
> > For a rwsem, locking can either be exclusive or shared. The
corresponding
> > exclusive or shared unlock must be used. Otherwise, the protected data
> > structures may get corrupted or the lock may be in an inconsistent
state.
> >
> > In order to detect such anomaly, a new configuration option DEBUG_RWSEMS
> > is added which can be enabled to look for such mismatches and print
> > warnings that that happens.
> >
> > Signed-off-by: Waiman Long <longman@redhat.com>
> > Acked-by: Davidlohr Bueso <dave@stgolabs.net>

> The new warning triggered in NFS, see
> https://bugs.linaro.org/show_bug.cgi?id=3731

> [   52.651490] DEBUG_LOCKS_WARN_ON(sem->owner != ((struct task_struct
*)1UL))
> [   52.651506] WARNING: CPU: 2 PID: 1457 at

/srv/oe/build/tmp-rpb-glibc/work-shared/intel-core2-32/kernel-source/kernel/locking/rwsem.c:217
> up_read_non_owner+0x5d/0x70
> [   52.674398] Modules linked in: x86_pkg_temp_thermal fuse
> [   52.679719] CPU: 2 PID: 1457 Comm: kworker/2:2 Not tainted 4.16.0 #1
> [   52.687448] Hardware name: Supermicro SYS-5019S-ML/X11SSH-F, BIOS
> 2.0b 07/27/2017
> [   52.694922] Workqueue: nfsiod rpc_async_release
> [   52.699454] RIP: 0010:up_read_non_owner+0x5d/0x70
> [   52.704157] RSP: 0018:ffff9cbf81a23dd0 EFLAGS: 00010282
> [   52.709376] RAX: 0000000000000000 RBX: ffff8dc1983c76c0 RCX:
0000000000000000
> [   52.716500] RDX: ffffffffbd2d26c9 RSI: 0000000000000001 RDI:
ffffffffbd2d2889
> [   52.723652] RBP: ffff9cbf81a23dd8 R08: 0000000000000000 R09:
0000000000000000
> [   52.730782] R10: ffff9cbf81a23dd0 R11: 0000000000000000 R12:
ffff8dc19abf8600
> [   52.737906] R13: ffff8dc19b6c0000 R14: 0000000000000000 R15:
ffff8dc19bacad80
> [   52.745029] FS:  0000000000000000(0000) GS:ffff8dc1afd00000(0000)
> knlGS:0000000000000000
> [   52.753108] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> [   52.758845] CR2: 00007f33794665d8 CR3: 000000016c41e006 CR4:
00000000003606e0
> [   52.765968] DR0: 0000000000000000 DR1: 0000000000000000 DR2:
0000000000000000
> [   52.773091] DR3: 0000000000000000 DR6: 00000000fffe0ff0 DR7:
0000000000000400
> [   52.780215] Call Trace:
> [   52.782695]  nfs_async_unlink_release+0x32/0x80
> [   52.787220]  rpc_free_task+0x30/0x50
> [   52.790789]  rpc_async_release+0x12/0x20
> [   52.794707]  process_one_work+0x25e/0x660
> [   52.798713]  worker_thread+0x4b/0x410
> [   52.802377]  kthread+0x10d/0x140
> [   52.805600]  ? rescuer_thread+0x3a0/0x3a0
> [   52.809652]  ? kthread_create_worker_on_cpu+0x70/0x70
> [   52.814702]  ? do_syscall_64+0x69/0x1b0
> [   52.818540]  ret_from_fork+0x3a/0x50
> [   52.822112] Code: ad 00 5b 5d c3 e8 74 ac 38 00 85 c0 74 de 8b 05
> 02 e3 48 02 85 c0 75 d4 48 c7 c6 c8 eb 4d be 48 c7 c7 5b ae 4c be e8
> 03 ae fa ff <0f> 0b eb bd 0f 1f 44 00 00 66 2e 0f 1f 84 00 00 00 00 00
> 0f 1f

> I don't see anything immediately wrong with rmdir_sem (it's not that
> complicated),
> and there are only three users of up_read_non_owner(), so my first
> suspicion would
> be that something is wrong with the debug code, but please take a look
> for yourself.

> I also see that Bruce reported the same warning in
> https://www.spinics.net/lists/linux-nfs/msg68064.html but apparently got
no
> reply.

I'm still seeing this regression on 4.17-rc6

[   93.481301] DEBUG_LOCKS_WARN_ON(sem->owner != ((struct task_struct
*)(1UL << 0)))
[   93.481318] WARNING: CPU: 14 PID: 320 at kernel/locking/rwsem.c:217
up_read_non_owner+0x58/0x60
[   93.486308] Modules linked in: ip6t_rpfilter(E) ip6t_REJECT(E)
nf_reject_ipv6(E) xt_conntrack(E) ebtable_nat(E) ebtable_broute(E)
bridge(E) stp(E) llc(E) ip6table_nat(E) nf_conntrack_ipv6(E)
nf_defrag_ipv6(E) nf_nat_ipv6(E) ip6table_mangle(E) ip6table_raw(E)
ip6table_security(E) iptable_nat(E) nf_conntrack_ipv4(E) nf_defrag_ipv4(E)
nf_nat_ipv4(E) nf_nat(E) nf_conntrack(E) iptable_mangle(E) iptable_raw(E)
iptable_security(E) ebtable_filter(E) ebtables(E) ip6table_filter(E)
ip6_tables(E) crct10dif_pclmul(E) crc32_pclmul(E) crc32c_intel(E)
ghash_clmulni_intel(E) dax_pmem(OE) nd_pmem(OE) device_dax(OE) nd_btt(OE)
serio_raw(E) nd_e820(OE) nfit(OE) libnvdimm(OE) nfit_test_iomap(OE)
[   93.499172] CPU: 14 PID: 320 Comm: kworker/14:1 Tainted: G           OE
     4.17.0-rc6+ #1921
[   93.500958] Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS
rel-1.11.1-0-g0551a4be2c-prebuilt.qemu-project.org 04/01/2014
[   93.503714] Workqueue: nfsiod rpc_async_release
[   93.504619] RIP: 0010:up_read_non_owner+0x58/0x60
[   93.505492] RSP: 0018:ffffc90004fbbe18 EFLAGS: 00010286
[   93.506658] RAX: 0000000000000000 RBX: ffff88040f339548 RCX:
0000000000000000
[   93.508135] RDX: 0000000000000002 RSI: 0000000000000001 RDI:
0000000000000247
[   93.509651] RBP: ffff88042ab5f308 R08: 0000000000000000 R09:
0000000000000001
[   93.511166] R10: ffffc90004fbbdf8 R11: ffff88042a84af40 R12:
ffff880429a94088
[   93.512630] R13: ffff8804317abd00 R14: 0000000000000000 R15:
0000000000000000
[   93.514215] FS:  0000000000000000(0000) GS:ffff880431780000(0000)
knlGS:0000000000000000
[   93.516016] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[   93.517414] CR2: 00007fd78ad448a0 CR3: 0000000002610000 CR4:
00000000000406e0
[   93.518930] Call Trace:
[   93.519612]  nfs_async_unlink_release+0x2d/0x80
[   93.520600]  rpc_free_task+0x2d/0x70
[   93.521495]  process_one_work+0x212/0x660
[   93.522553]  worker_thread+0x3a/0x390
[   93.523612]  ? process_one_work+0x660/0x660
[   93.524660]  kthread+0x11e/0x140
[   93.525766]  ? kthread_create_worker_on_cpu+0x70/0x70
