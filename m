From: Daniel J Blueman <daniel.blueman@gmail.com>
Subject: Re: [2.6.31] NFS4ERR_GRACE unhandled...
Date: Sat, 3 Oct 2009 16:59:11 +0100
Message-ID: <6278d2220910030859s1fb8d200n7d032e2c1b235ce@mail.gmail.com>
References: <6278d2220909261114g2e1529dfn4961d450460b00dc@mail.gmail.com>
	 <1254161800.3308.1.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: linux-nfs@vger.kernel.org
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ew0-f211.google.com ([209.85.219.211]:50528 "EHLO
	mail-ew0-f211.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752530AbZJCP7w convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 3 Oct 2009 11:59:52 -0400
Received: by ewy7 with SMTP id 7so2191083ewy.17
        for <linux-nfs@vger.kernel.org>; Sat, 03 Oct 2009 08:59:12 -0700 (PDT)
In-Reply-To: <1254161800.3308.1.camel-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Trond,

On Mon, Sep 28, 2009 at 7:16 PM, Trond Myklebust
<Trond.Myklebust@netapp.com> wrote:
> On Sat, 2009-09-26 at 19:14 +0100, Daniel J Blueman wrote:
>> Hi Trond,
>>
>> After rebooting my 2.6.31 NFS4 server, I see a list of NFS kernel
>> errors [1] on the 2.6.31 client corresponding to NFS4ERR_GRACE, so
>> lock or file state recovery failed. Is this expected noting that I
>> have an internal firewall allowing incoming TCP port 2049 on the
>> server, and no firewall on the client, however I can't see how it ca=
n
>> thus be callback related?
>
> No. It looks as if your server rebooted while the client was recoveri=
ng
> an expired lease.
>
> The following patch should prevent future occurrences of this bug...
>
> Cheers
> =A0Trond
> ------------------------------------------------------------------
> NFSv4: Handle NFS4ERR_GRACE when recovering an expired lease.
>
> From: Trond Myklebust <Trond.Myklebust@netapp.com>
>
> If our lease expires, and the server subsequently reboot, we need to =
be
> able to handle the case where the server refuses to let us recover st=
ate,
> because it is in the grace period.

On the client, I didn't see the error messages with this patch,
however I did see firefox (via sqlite) continue to hang [1] (after
other processes continued), and an unusual level of activity with
rpciod/0 and rpciod/1 kernel threads. Other NFS-related kernel thread
state is given.

I'm able to reproduce [2] this behaviour with 2.6.31-rc1 and your
patch; let me know if you're unable to.

Thanks,
  Daniel

--- [1]

# echo t >/proc/sysrq-trigger
# dmesg
<aargh, missing rpciod/0 and rpciod/1 which are in a unexpected state,
since CONFIG_LOG_BUF_SHIFT is only 18 by default and crashdump doesn't
work without the vmcoreinfo file>
nfsv4.0-svc   S ffff880126e3ed70  4600  2628      2 0x00000000
 ffff88011fe25d20 0000000000000046 000000000000031a ffff88011fd5a5d8
 ffff88011fd5a5a0 ffffffff825cb770 ffff88011fd5af68 ffffffff00000320
 0000000000000001 ffffffff8220e0a0 ffff88011fe24000 0000000000017768
Call Trace:
 [<ffffffff8112e7ea>] ? kfree+0xea/0x1c0
 [<ffffffff816394e5>] schedule_timeout+0x275/0x360
 [<ffffffff8109044a>] ? get_lock_stats+0x2a/0x60
 [<ffffffff81067158>] ? local_bh_enable_ip+0x98/0x130
 [<ffffffff81095abd>] ? trace_hardirqs_on_caller+0x14d/0x1a0
 [<ffffffff815ff433>] ? svc_recv+0x793/0x8a0
 [<ffffffff81095b1d>] ? trace_hardirqs_on+0xd/0x10
 [<ffffffff815ff43c>] svc_recv+0x79c/0x8a0
 [<ffffffff81054c00>] ? default_wake_function+0x0/0x10
 [<ffffffff8121b803>] nfs4_callback_svc+0x43/0xb0
 [<ffffffff8121b7c0>] ? nfs4_callback_svc+0x0/0xb0
 [<ffffffff8107eb3e>] kthread+0x8e/0xa0
 [<ffffffff8100d15a>] child_rip+0xa/0x20
 [<ffffffff8100ca94>] ? restore_args+0x0/0x30
 [<ffffffff8107eab0>] ? kthread+0x0/0xa0
 [<ffffffff8100d150>] ? child_rip+0x0/0x20
firefox       S 0000000000000000  2512  2695      1 0x00000000
 ffff880117229c38 0000000000000046 0000000000000000 00000055b199802a
 ffff8801171daf30 ffffffff821f0210 0000000000019400 ffff88002efe0bd8
 0000000000000000 00000000ffffe926 ffff880117228000 0000000000017768
Call Trace:
 [<ffffffff8109aa0d>] futex_wait_queue_me+0xbd/0x100
 [<ffffffff8109b068>] futex_wait+0x168/0x2f0
 [<ffffffff8109caa9>] do_futex+0x109/0xac0
 [<ffffffff8107ef60>] ? autoremove_wake_function+0x0/0x40
 [<ffffffff8109044a>] ? get_lock_stats+0x2a/0x60
 [<ffffffff8109d526>] sys_futex+0xc6/0x170
 [<ffffffff81095abd>] ? trace_hardirqs_on_caller+0x14d/0x1a0
 [<ffffffff8163b30e>] ? trace_hardirqs_on_thunk+0x3a/0x3f
 [<ffffffff8100bfc2>] system_call_fastpath+0x16/0x1b
firefox       S 0000000000000000  4824  2698      1 0x00000000
 ffff880129d71a58 0000000000000046 0000000000000000 ffffffff81096872
 0000000000000002 ffffffff82204790 0000000000000042 ffff88002efe0bd8
 0000000000000000 00000000ffffe731 ffff880129d70000 0000000000017768
Call Trace:
 [<ffffffff81096872>] ? __lock_acquire+0x482/0x1440
 [<ffffffff8163a445>] schedule_hrtimeout_range+0x145/0x170
 [<ffffffff8163bf35>] ? _spin_unlock_irqrestore+0x45/0x80
 [<ffffffff8107f2a1>] ? add_wait_queue+0x41/0x50
 [<ffffffff8114dbdf>] ? __pollwait+0x6f/0xf0
 [<ffffffff8114da94>] poll_schedule_timeout+0x34/0x50
 [<ffffffff8114e89f>] do_sys_poll+0x40f/0x520
 [<ffffffff815536a2>] ? dev_queue_xmit+0x52/0x520
 [<ffffffff8114db70>] ? __pollwait+0x0/0xf0
 [<ffffffff8114dc60>] ? pollwake+0x0/0x60
 [<ffffffff8109044a>] ? get_lock_stats+0x2a/0x60
 [<ffffffff810925de>] ? put_lock_stats+0xe/0x30
 [<ffffffff8163bf55>] ? _spin_unlock_irqrestore+0x65/0x80
 [<ffffffff810645d2>] ? current_fs_time+0x22/0x30
 [<ffffffff81157118>] ? mnt_drop_write+0x38/0x60
 [<ffffffff81152bf5>] ? touch_atime+0x135/0x180
 [<ffffffff81145925>] ? pipe_read+0x2d5/0x4e0
 [<ffffffff8113ce12>] ? do_sync_read+0xf2/0x130
 [<ffffffff8107ef60>] ? autoremove_wake_function+0x0/0x40
 [<ffffffff8109044a>] ? get_lock_stats+0x2a/0x60
 [<ffffffff8100bffa>] ? sysret_check+0x2e/0x69
 [<ffffffff8114eb97>] sys_poll+0x77/0x110
 [<ffffffff8100bfc2>] system_call_fastpath+0x16/0x1b
firefox       S ffff880126c28000  5944  2699      1 0x00000000
 ffff88011729bc38 0000000000000046 ffff88011729bb88 ffffffff8163bf35
 ffff88011729bd28 0000024240c36955 ffff88011729bc28 ffffffff81082b30
 ffff88011729bbb8 ffffffff8109044a ffff88011729a000 0000000000017768
Call Trace:
 [<ffffffff8163bf35>] ? _spin_unlock_irqrestore+0x45/0x80
 [<ffffffff81082b30>] ? __hrtimer_start_range_ns+0x170/0x480
 [<ffffffff8109044a>] ? get_lock_stats+0x2a/0x60
 [<ffffffff8109aa0d>] futex_wait_queue_me+0xbd/0x100
 [<ffffffff8109b068>] futex_wait+0x168/0x2f0
 [<ffffffff81082380>] ? hrtimer_wakeup+0x0/0x30
 [<ffffffff8109caa9>] do_futex+0x109/0xac0
 [<ffffffff8163bf9b>] ? _spin_unlock_irq+0x2b/0x60
 [<ffffffff81095abd>] ? trace_hardirqs_on_caller+0x14d/0x1a0
 [<ffffffff81095b1d>] ? trace_hardirqs_on+0xd/0x10
 [<ffffffff8163bfac>] ? _spin_unlock_irq+0x3c/0x60
 [<ffffffff81049baf>] ? finish_task_switch+0x6f/0xf0
 [<ffffffff81049b40>] ? finish_task_switch+0x0/0xf0
 [<ffffffff816388bb>] ? thread_return+0x98/0x82d
 [<ffffffff8163b30e>] ? trace_hardirqs_on_thunk+0x3a/0x3f
 [<ffffffff8109d526>] sys_futex+0xc6/0x170
 [<ffffffff81095a01>] ? trace_hardirqs_on_caller+0x91/0x1a0
 [<ffffffff8100bfc2>] system_call_fastpath+0x16/0x1b
firefox       S 0000000000000000  5944  2700      1 0x00000000
 ffff8801170b9c38 0000000000000046 0000000000000000 ffffffff8163bf35
 ffff8801170b9d28 0000035df665233f ffff8801170b9c28 ffff88002efe0bd8
 0000000000000000 0000000100016139 ffff8801170b8000 0000000000017768
Call Trace:
 [<ffffffff8163bf35>] ? _spin_unlock_irqrestore+0x45/0x80
 [<ffffffff8109aa0d>] futex_wait_queue_me+0xbd/0x100
 [<ffffffff8109b068>] futex_wait+0x168/0x2f0
 [<ffffffff81082380>] ? hrtimer_wakeup+0x0/0x30
 [<ffffffff8109caa9>] do_futex+0x109/0xac0
 [<ffffffff8107ef60>] ? autoremove_wake_function+0x0/0x40
 [<ffffffff8109044a>] ? get_lock_stats+0x2a/0x60
 [<ffffffff8109d526>] sys_futex+0xc6/0x170
 [<ffffffff81095a01>] ? trace_hardirqs_on_caller+0x91/0x1a0
 [<ffffffff8100bfc2>] system_call_fastpath+0x16/0x1b
firefox       D 0000000000000002  3832  2710      1 0x00000000
 ffff880117283b58 0000000000000046 ffff88011fd72fa0 ffffffff821e0250
 0000000000019400 ffff88011fd725a0 0000000000000001 0000000000000007
 0000000000000006 0000000000000002 ffff880117282000 0000000000017768
Call Trace:
 [<ffffffff81095b1d>] ? trace_hardirqs_on+0xd/0x10
 [<ffffffff810ef7e0>] ? sync_page+0x0/0x60
 [<ffffffff81639092>] io_schedule+0x42/0x60
 [<ffffffff810ef825>] sync_page+0x45/0x60
 [<ffffffff816397c7>] __wait_on_bit+0x57/0x80
 [<ffffffff810f1e00>] ? find_get_pages_tag+0x130/0x1d0
 [<ffffffff810f1cd0>] ? find_get_pages_tag+0x0/0x1d0
 [<ffffffff810ef95e>] wait_on_page_bit+0x6e/0x80
 [<ffffffff8107efa0>] ? wake_bit_function+0x0/0x40
 [<ffffffff810fb150>] ? pagevec_lookup_tag+0x20/0x30
 [<ffffffff810efad4>] wait_on_page_writeback_range+0xf4/0x1a0
 [<ffffffff81096872>] ? __lock_acquire+0x482/0x1440
 [<ffffffff810fa1bf>] ? do_writepages+0x1f/0x40
 [<ffffffff810efc2b>] ? __filemap_fdatawrite_range+0x5b/0x60
 [<ffffffff810efba6>] filemap_fdatawait+0x26/0x30
 [<ffffffff810efed4>] filemap_write_and_wait+0x44/0x50
 [<ffffffff811f2794>] nfs_setattr+0x174/0x190
 [<ffffffff8109044a>] ? get_lock_stats+0x2a/0x60
 [<ffffffff810925de>] ? put_lock_stats+0xe/0x30
 [<ffffffff81154d12>] ? notify_change+0x1b2/0x2e0
 [<ffffffff81154c64>] notify_change+0x104/0x2e0
 [<ffffffff8113bf91>] do_truncate+0x61/0x90
 [<ffffffff8113c620>] sys_ftruncate+0xd0/0xe0
 [<ffffffff8100bfc2>] system_call_fastpath+0x16/0x1b
firefox       S 0000000000000000  5048  2713      1 0x00000000
 ffff88011727fc38 0000000000000046 0000000000000000 000000209bf0709a
 ffff88011febd4d0 ffffffff821f0210 0000000000019400 ffff88002efe0bd8
 0000000000000000 00000000ffffbe3c ffff88011727e000 0000000000017768
Call Trace:
 [<ffffffff8109aa0d>] futex_wait_queue_me+0xbd/0x100
 [<ffffffff8109b068>] futex_wait+0x168/0x2f0
 [<ffffffff8109caa9>] do_futex+0x109/0xac0
 [<ffffffff8153d795>] ? sockfd_lookup_light+0x25/0x80
 [<ffffffff8107ef60>] ? autoremove_wake_function+0x0/0x40
 [<ffffffff8109044a>] ? get_lock_stats+0x2a/0x60
 [<ffffffff8109d526>] sys_futex+0xc6/0x170
 [<ffffffff81095abd>] ? trace_hardirqs_on_caller+0x14d/0x1a0
 [<ffffffff8163b30e>] ? trace_hardirqs_on_thunk+0x3a/0x3f
 [<ffffffff8100bfc2>] system_call_fastpath+0x16/0x1b
firefox       S ffff880126c2a5a0  6216  2714      1 0x00000000
 ffff880117275c38 0000000000000046 ffff880117275b88 00000012ae79dbd1
 ffff880126c2af30 ffffffff821f0210 0000000000019400 ffff880126c2a5a0
 ffff880117275bb8 ffffffff8109044a ffff880117274000 0000000000017768
Call Trace:
 [<ffffffff8109044a>] ? get_lock_stats+0x2a/0x60
 [<ffffffff812d4f7e>] ? _raw_spin_unlock+0x5e/0xb0
 [<ffffffff8109aa0d>] futex_wait_queue_me+0xbd/0x100
 [<ffffffff8109b068>] futex_wait+0x168/0x2f0
 [<ffffffff8109caa9>] do_futex+0x109/0xac0
 [<ffffffff8109044a>] ? get_lock_stats+0x2a/0x60
 [<ffffffff810925de>] ? put_lock_stats+0xe/0x30
 [<ffffffff8163bf9b>] ? _spin_unlock_irq+0x2b/0x60
 [<ffffffff81095abd>] ? trace_hardirqs_on_caller+0x14d/0x1a0
 [<ffffffff81095b1d>] ? trace_hardirqs_on+0xd/0x10
 [<ffffffff8109d526>] sys_futex+0xc6/0x170
 [<ffffffff81095abd>] ? trace_hardirqs_on_caller+0x14d/0x1a0
 [<ffffffff8163b30e>] ? trace_hardirqs_on_thunk+0x3a/0x3f
 [<ffffffff8100bfc2>] system_call_fastpath+0x16/0x1b
firefox       S 0000000000000000  2864  2715      1 0x00000000
 ffff880117297c38 0000000000000046 0000000000000000 000000209b22fd4e
 ffff8801347ad4d0 ffffffff821f0210 0000000000019400 ffff88002efe0bd8
 0000000000000000 00000000ffffbe3c ffff880117296000 0000000000017768
Call Trace:
 [<ffffffff8109aa0d>] futex_wait_queue_me+0xbd/0x100
 [<ffffffff8109b068>] futex_wait+0x168/0x2f0
 [<ffffffff8109caa9>] do_futex+0x109/0xac0
 [<ffffffff8107ef60>] ? autoremove_wake_function+0x0/0x40
 [<ffffffff8109044a>] ? get_lock_stats+0x2a/0x60
 [<ffffffff8109d526>] sys_futex+0xc6/0x170
 [<ffffffff81095abd>] ? trace_hardirqs_on_caller+0x14d/0x1a0
 [<ffffffff8163b30e>] ? trace_hardirqs_on_thunk+0x3a/0x3f
 [<ffffffff8100bfc2>] system_call_fastpath+0x16/0x1b
kthreadd      D 00000000ffffffff  6816 23477      2 0x00000000
 ffff8801344b9eb0 0000000000000046 ffff8801344b9e78 ffff8801344b9e74
 ffff8801344b9e00 ffff88002ee17cc0 ffff88002f1e0bc0 ffff88002efe0bd8
 0000000000000000 00000001000354b3 ffff8801344b8000 0000000000017768
Call Trace:
 [<ffffffff812181f0>] ? nfs4_run_state_manager+0x0/0x4c0
 [<ffffffff8107eb22>] kthread+0x72/0xa0
 [<ffffffff8100d15a>] child_rip+0xa/0x20
 [<ffffffff8100ca94>] ? restore_args+0x0/0x30
 [<ffffffff8107eab0>] ? kthread+0x0/0xa0
 [<ffffffff8100d150>] ? child_rip+0x0/0x20

--- [2]

1. ensure NFS4 client processes are updating databases/files (eg run
firefox or renderer)
2. reboot server (perhaps unneeded)
3. on server, stop nfs-kernel service for some minutes
4. start nfs-kernel service again
5. verify client application resume without dataloss
--=20
Daniel J Blueman
