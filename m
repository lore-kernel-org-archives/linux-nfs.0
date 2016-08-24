Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:60684 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1756515AbcHXOnA (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 24 Aug 2016 10:43:00 -0400
Date: Wed, 24 Aug 2016 10:43:00 -0400
To: Carlos Carvalho <carlos@fisica.ufpr.br>
Cc: linux-nfs@vger.kernel.org
Subject: Re: crashes in 4.6.5
Message-ID: <20160824144300.GI3938@fieldses.org>
References: <20160804203612.xqzevnqyzkfxwfv3@fisica.ufpr.br>
 <20160824134020.GE3938@fieldses.org>
 <20160824135725.5fcto7cy34zqhwsl@fisica.ufpr.br>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20160824135725.5fcto7cy34zqhwsl@fisica.ufpr.br>
From: bfields@fieldses.org (J. Bruce Fields)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Aug 24, 2016 at 10:57:26AM -0300, Carlos Carvalho wrote:
> J. Bruce Fields (bfields@fieldses.org) wrote on Wed, Aug 24, 2016 at 10:40:20AM BRT:
> > On Thu, Aug 04, 2016 at 05:36:12PM -0300, Carlos Carvalho wrote:
> > > Our nfs server, running 4.6.5, doesn't last more than 2-3 days. There are
> > > several errors in the log that seem to be nfs4 related.
> > 
> > What's the very first error of any kind?
> 
> I sent all that's in the log; the dumps start with general protection fault,
> and INFO: rcu_sched for the stalls.

Oh, got it, thanks.  I didn't undestand your first message.

> The latest one, 4.7.2 in a nfs3-only
> machine that I reported yesterday, just outputs a few lines with rcu_sched
> stall warnings, only to the console and nothing in logs. I didn't write them
> down this time. The machine still reacted to SysRq commands; I used a forced
> umount and then an immediate reboot. However there was still non-negligible
> filesystem corruption...

What kind of filesystem corruption, and what filesystem is this?  I'm a
little surprised that what looks like a crash in NFSv4 state code should
be corrupting the filesystem.

--b.

> 
> > --b.
> > 
> > > After many of these
> > > errors the machine eventually crashes:
> > > 
> > > Aug  4 07:39:57 urquell kernel: general protection fault: 0000 [#2] SMP 
> > > Aug  4 07:39:57 urquell kernel: Modules linked in:
> > > Aug  4 07:39:57 urquell kernel: CPU: 0 PID: 19621 Comm: nfsd Tainted: G      D   I     4.6.5 #1
> > > Aug  4 07:39:57 urquell kernel: Hardware name: SGI.COM SGI MIS Server/S2600JF, BIOS SE5C600.86B.01.03.0002.062020121504 06/20/2012
> > > Aug  4 07:39:57 urquell kernel: task: ffff881fe24dd940 ti: ffff880e61bd8000 task.ti: ffff880e61bd8000
> > > Aug  4 07:39:57 urquell kernel: RIP: 0010:[<ffffffff81252ef2>]  [<ffffffff81252ef2>] nfsd4_del_conns+0x72/0xc0
> > > Aug  4 07:39:57 urquell kernel: RSP: 0018:ffff880e61bdbce0  EFLAGS: 00010246
> > > Aug  4 07:39:57 urquell kernel: RAX: ffff880b8a34b758 RBX: ffff880b8a34b740 RCX: dead000000000100
> > > Aug  4 07:39:57 urquell kernel: RDX: dead000000000200 RSI: 0000000000000001 RDI: ffff880e22af6078
> > > Aug  4 07:39:57 urquell kernel: RBP: ffff880e22af6000 R08: 0000000000000001 R09: 00004c0ca729bd38
> > > Aug  4 07:39:57 urquell kernel: R10: 0000000000000001 R11: 0000000000000001 R12: ffff881aaa9c4800
> > > Aug  4 07:39:57 urquell kernel: R13: ffff880fe21ab298 R14: ffff881aaa9c4b30 R15: ffff880fe21ab200
> > > Aug  4 07:39:57 urquell kernel: FS:  0000000000000000(0000) GS:ffff880fffc00000(0000) knlGS:0000000000000000
> > > Aug  4 07:39:57 urquell kernel: CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> > > Aug  4 07:39:57 urquell kernel: CR2: 00007f716a49c000 CR3: 0000000001c06000 CR4: 00000000000406f0
> > > Aug  4 07:39:57 urquell kernel: Stack:
> > > Aug  4 07:39:57 urquell kernel: ffff880fe21ab218 ffff881aaa9c4800 ffff880fe21ab200 ffff881aaa9c4b38
> > > Aug  4 07:39:57 urquell kernel: ffff880c9ace8c80 0000000000000000 ffffffff812532a6 ffff881aaa9c4830
> > > Aug  4 07:39:57 urquell kernel: ffff881aaa9c4800 ffff880e61bdbd40 ffff881aaa9c4868 ffffffff81254c7f
> > > Aug  4 07:39:57 urquell kernel: Call Trace:
> > > Aug  4 07:39:57 urquell kernel: [<ffffffff812532a6>] ? free_client+0x26/0x150
> > > Aug  4 07:39:57 urquell kernel: [<ffffffff81254c7f>] ? __destroy_client+0x14f/0x160
> > > Aug  4 07:39:57 urquell kernel: [<ffffffff81255ad9>] ? nfsd4_create_session+0x659/0x850
> > > Aug  4 07:39:57 urquell kernel: [<ffffffff8124b1d2>] ? nfsd4_proc_compound+0x302/0x560
> > > Aug  4 07:39:57 urquell kernel: [<ffffffff8123c7ae>] ? nfsd_dispatch+0x7e/0x160
> > > Aug  4 07:39:57 urquell kernel: [<ffffffff8171f80d>] ? svc_process_common+0x38d/0x510
> > > Aug  4 07:39:57 urquell kernel: [<ffffffff8171fa6d>] ? svc_process+0xdd/0xf0
> > > Aug  4 07:39:57 urquell kernel: [<ffffffff8123c284>] ? nfsd+0xe4/0x150
> > > Aug  4 07:39:57 urquell kernel: [<ffffffff8123c1a0>] ? nfsd_destroy+0x60/0x60
> > > Aug  4 07:39:57 urquell kernel: [<ffffffff810976ca>] ? kthread+0xca/0xe0
> > > Aug  4 07:39:57 urquell kernel: [<ffffffff81252e00>] ? nfsd4_put_drc_mem+0x40/0x40
> > > Aug  4 07:39:57 urquell kernel: [<ffffffff81744192>] ? ret_from_fork+0x22/0x40
> > > Aug  4 07:39:57 urquell kernel: [<ffffffff81097600>] ? kthread_park+0x50/0x50
> > > Aug  4 07:39:57 urquell kernel: Code: 89 10 48 89 1b 48 89 5b 08 41 c6 84 24 30 03 00 00 00 48 8b 6b 10 48 8d 7d 78 e8 1a 0f 4f 00 48 8b 4b 18 48 8d 43 18 48 8b 53 20 <48> 89 51 08 48 89 0a 48 89 43 18 48 89 43 20 c6 45 78 00 48 8b 
> > > Aug  4 07:39:57 urquell kernel: RIP  [<ffffffff81252ef2>] nfsd4_del_conns+0x72/0xc0
> > > Aug  4 07:39:57 urquell kernel: RSP <ffff880e61bdbce0>
> > > Aug  4 07:39:57 urquell kernel: ---[ end trace bbec43f5aa22f6e3 ]---
> > > 
> > > There are also cpu stalls:
> > > 
> > > Aug  4 10:46:14 urquell kernel: INFO: rcu_sched self-detected stall on CPU
> > > Aug  4 10:46:14 urquell kernel: 	4-...: (14997 ticks this GP) idle=76b/140000000000001/0 softirq=30513439/30513439 fqs=13790 
> > > Aug  4 10:46:14 urquell kernel: 	 (t=15000 jiffies g=10123193 c=10123192 q=4324508)
> > > Aug  4 10:46:14 urquell kernel: Task dump for CPU 4:
> > > Aug  4 10:46:14 urquell kernel: nfsd            R  running task        0 19618      2 0x00000008
> > > Aug  4 10:46:14 urquell kernel: ffffffff81c37240 ffffffff810bfc4b ffff880fffc94880 ffffffff81c37240
> > > Aug  4 10:46:14 urquell kernel: 0000000000000000 ffff881fe24dbfc0 ffffffff810c2adc ffff880fffc93bc0
> > > Aug  4 10:46:14 urquell kernel: 0000000000013bc0 0000000000000004 ffff880fffc83e90 ffff880fffc83e90
> > > Aug  4 10:46:14 urquell kernel: Call Trace:
> > > Aug  4 10:46:14 urquell kernel: <IRQ>  [<ffffffff810bfc4b>] ? rcu_dump_cpu_stacks+0x7b/0xb0
> > > Aug  4 10:46:14 urquell kernel: [<ffffffff810c2adc>] ? rcu_check_callbacks+0x3bc/0x680
> > > Aug  4 10:46:14 urquell kernel: [<ffffffff810c467d>] ? update_process_times+0x2d/0x50
> > > Aug  4 10:46:14 urquell kernel: [<ffffffff810d1301>] ? tick_sched_timer+0x41/0x160
> > > Aug  4 10:46:14 urquell kernel: [<ffffffff810c4c13>] ? __hrtimer_run_queues+0xb3/0x150
> > > Aug  4 10:46:14 urquell kernel: [<ffffffff810c5124>] ? hrtimer_interrupt+0x94/0x170
> > > Aug  4 10:46:14 urquell kernel: [<ffffffff8106c4e4>] ? smp_apic_timer_interrupt+0x34/0x50
> > > Aug  4 10:46:14 urquell kernel: [<ffffffff81744b4f>] ? apic_timer_interrupt+0x7f/0x90
> > > Aug  4 10:46:14 urquell kernel: <EOI>  [<ffffffff81091a47>] ? queue_work_on+0x17/0x20
> > > Aug  4 10:46:14 urquell kernel: [<ffffffff81252e66>] ? nfsd4_conn_lost+0x66/0x80
> > > Aug  4 10:46:14 urquell kernel: [<ffffffff8172c9fd>] ? svc_delete_xprt+0xcd/0x130
> > > Aug  4 10:46:14 urquell kernel: [<ffffffff8172d1f9>] ? svc_recv+0x5f9/0x950
> > > Aug  4 10:46:14 urquell kernel: [<ffffffff8172c74f>] ? svc_xprt_release+0x8f/0xf0
> > > Aug  4 10:46:14 urquell kernel: [<ffffffff8123c272>] ? nfsd+0xd2/0x150
> > > Aug  4 10:46:14 urquell kernel: [<ffffffff8123c1a0>] ? nfsd_destroy+0x60/0x60
> > > Aug  4 10:46:14 urquell kernel: [<ffffffff810976ca>] ? kthread+0xca/0xe0
> > > Aug  4 10:46:14 urquell kernel: [<ffffffff81744192>] ? ret_from_fork+0x22/0x40
> > > Aug  4 10:46:14 urquell kernel: [<ffffffff81097600>] ? kthread_park+0x50/0x50
> > > Aug  4 10:46:14 urquell kernel: INFO: rcu_sched detected stalls on CPUs/tasks:
> > > Aug  4 10:46:14 urquell kernel: 	4-...: (14998 ticks this GP) idle=76b/140000000000000/0 softirq=30513439/30513439 fqs=13791 
> > > Aug  4 10:46:14 urquell kernel: 	(detected by 20, t=15004 jiffies, g=10123193, c=10123192, q=4324792)
> > > Aug  4 10:46:14 urquell kernel: Task dump for CPU 4:
> > > Aug  4 10:46:14 urquell kernel: nfsd            R  running task        0 19618      2 0x00000008
> > > Aug  4 10:46:14 urquell kernel: ffff880fff800060 ffff88029099cb00 0001881ff5bc4f00 ffff8805e78f6ac0
> > > Aug  4 10:46:14 urquell kernel: ffff8800bbbe8600 000000000000e3b0 0000000000000040 ffff880fff811800
> > > Aug  4 10:46:14 urquell kernel: ffffffff810917d9 ffffea002ec51bc0 0000000000000206 ffff881a63046800
> > > Aug  4 10:46:14 urquell kernel: Call Trace:
> > > Aug  4 10:46:14 urquell kernel: [<ffffffff810917d9>] ? __queue_work+0x119/0x370
> > > Aug  4 10:46:14 urquell kernel: [<ffffffff81091a40>] ? queue_work_on+0x10/0x20
> > > Aug  4 10:46:14 urquell kernel: [<ffffffff81252e66>] ? nfsd4_conn_lost+0x66/0x80
> > > Aug  4 10:46:14 urquell kernel: [<ffffffff8172c9fd>] ? svc_delete_xprt+0xcd/0x130
> > > Aug  4 10:46:14 urquell kernel: [<ffffffff8172d1f9>] ? svc_recv+0x5f9/0x950
> > > Aug  4 10:46:14 urquell kernel: [<ffffffff8172c74f>] ? svc_xprt_release+0x8f/0xf0
> > > Aug  4 10:46:14 urquell kernel: [<ffffffff8123c272>] ? nfsd+0xd2/0x150
> > > Aug  4 10:46:14 urquell kernel: [<ffffffff8123c1a0>] ? nfsd_destroy+0x60/0x60
> > > Aug  4 10:46:14 urquell kernel: [<ffffffff810976ca>] ? kthread+0xca/0xe0
> > > Aug  4 10:46:14 urquell kernel: [<ffffffff81744192>] ? ret_from_fork+0x22/0x40
> > > Aug  4 10:46:14 urquell kernel: [<ffffffff81097600>] ? kthread_park+0x50/0x50
> > > 
> > > This is the only machine with problems running 4.6.5, and the only one that
> > > uses nfs4.
> > > --
> > > To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> > > the body of a message to majordomo@vger.kernel.org
> > > More majordomo info at  http://vger.kernel.org/majordomo-info.html
> > --
> > To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> > the body of a message to majordomo@vger.kernel.org
> > More majordomo info at  http://vger.kernel.org/majordomo-info.html
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
