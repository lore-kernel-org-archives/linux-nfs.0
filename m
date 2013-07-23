Return-Path: linux-nfs-owner@vger.kernel.org
Received: from stator.leun.net ([85.214.203.199]:39227 "EHLO stator.leun.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933353Ab3GWUBD (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 23 Jul 2013 16:01:03 -0400
Date: Tue, 23 Jul 2013 21:58:12 +0200
From: Michael Leun <lkml20130126@newton.leun.net>
To: Colin Cross <ccross@android.com>
Cc: lkml <linux-kernel@vger.kernel.org>, Pavel Machek <pavel@ucw.cz>,
        "Rafael J. Wysocki" <rjw@sisk.pl>,
        Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@redhat.com>,
        Andrew Morton <akpm@linux-foundation.org>,
        Mandeep Singh Baines <msb@chromium.org>,
        Oleg Nesterov <oleg@redhat.com>, linux-nfs <linux-nfs@vger.kernel.org>,
        Linux PM list <linux-pm@vger.kernel.org>,
        netdev <netdev@vger.kernel.org>,
        Linus Torvalds <torvalds@linux-foundation.org>,
        Tejun Heo <tj@kernel.org>, Darren Hart <dvhart@linux.intel.com>,
        Thomas Gleixner <tglx@linutronix.de>,
        Randy Dunlap <rdunlap@infradead.org>,
        Al Viro <viro@zeniv.linux.org.uk>
Subject: Re: 3.11-rc regression bisected: s2disk does not work (was Re:
 [PATCH v3 13/16] futex: use freezable blocking call)
Message-ID: <20130723215812.3a4b4411@xenia.leun.net>
In-Reply-To: <CAMbhsRQU=TswYg-2WqHmzt-_GpfMFpYHPSU4eFd5XMw7DRGXJA@mail.gmail.com>
References: <1367884221-20462-1-git-send-email-ccross@android.com>
	<1367884221-20462-14-git-send-email-ccross@android.com>
	<20130723010250.5a3465ec@xenia.leun.net>
	<CAMbhsRQv+W897_5qGuNJD47jQ9ozN6KxeCa6UJAvZpqVuBpQ4w@mail.gmail.com>
	<20130723200854.2046296b@xenia.leun.net>
	<CAMbhsRT6zOKLhG_uh=nA8H_3d7afhG+4jvWjvidY3fEguryP_Q@mail.gmail.com>
	<20130723211622.50f75087@xenia.leun.net>
	<CAMbhsRQU=TswYg-2WqHmzt-_GpfMFpYHPSU4eFd5XMw7DRGXJA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 23 Jul 2013 12:29:57 -0700
Colin Cross <ccross@android.com> wrote:

> On Tue, Jul 23, 2013 at 12:16 PM, Michael Leun
> <lkml20130126@newton.leun.net> wrote:
> > On Tue, 23 Jul 2013 11:29:57 -0700
> > Colin Cross <ccross@android.com> wrote:
> >
> >> On Tue, Jul 23, 2013 at 11:08 AM, Michael Leun
> >> <lkml20130126@newton.leun.net> wrote:
> >> > On Mon, 22 Jul 2013 16:55:58 -0700
> >> > Colin Cross <ccross@android.com> wrote:
> >> >
> >> >> On Mon, Jul 22, 2013 at 4:02 PM, Michael Leun
> >> >> <lkml20130126@newton.leun.net> wrote:
> >> >> > On Mon,  6 May 2013 16:50:18 -0700
> >> >> > Colin Cross <ccross@android.com> wrote:
> >> >> >
> >> >> >> Avoid waking up every thread sleeping in a futex_wait call
> >> >> >> during
> >> >> > [...]
> >> >> >
> >> >> > With 3.11-rc s2disk from suspend-utils stopped working:
> >> >> > Frozen at displaying 0% of saving image to disk.
> >> >> >
> >> >> > echo "1" >/sys/power/state still works.
> >> >> >
> >> >> > Bisecting yielded 88c8004fd3a5fdd2378069de86b90b21110d33a4,
> >> >> > reverting that from 3.11-rc2 makes s2disk working again.
> >> >> >
> >> >>
> >> >> I think the expanded use of the freezable_* helpers is exposing
> >> >> an existing bug in hibernation.  The SNAPSHOT_FREEZE ioctl calls
> >> >> freeze_processes(), which sets the global system_freezing_cnt
> >> >> and pm_freezing.  try_to_freeze_tasks then sends every process
> >> >> except current a signal which causes them all to end up in the
> >> >> refrigerator. The current task then returns back to userspace
> >> >> and continues its work to suspend to disk.  If that task ever
> >> >> hits a call to try_to_freeze() in the kernel, it will see
> >> >> system_freezing_cnt and pm_freezing=true and freeze, and suspend
> >> >> to disk will hang forever.  It could hit try_to_freeze() because
> >> >> of a signal delivered to the task, or from calling any syscall
> >> >> that uses a freezable_* helper like the one I added to
> >> >> sys_futex.
> >> >>
> >> >> I think the right solution is to add a flag to the freezing task
> >> >> that marks it unfreezable.  I  think PF_NOFREEZE would work,
> >> >> although it is normally used on kernel threads, can you see if
> >> >> the attached patch helps?
> >> >
> >> > That patch helps.
> >> >
> >> > BTW, the only machine I can reproduce this bug with is an
> >> > i7-3630QM notebook. Cannot reproduce on an Core Duo U1400 and
> >> > cannot reproduce on an i7 M 620.
> >> >
> >> > Are the sysreq backtraces still wanted? If so, any tip, how I
> >> > could get them saved?
> >
> > Darren Hart <dvhart@linux.intel.com> wrote:
> >
> >> Typically by setting up a serial console or a netconsole and saving
> > [...]
> >> Is this what you are asking?
> >
> > Yes, and it indeed works - I halfway expected the net / netconsole
> > stuff being already frozen in that situation...
> >
> > Thanks, Darren - see below for the backtraces.
> >
> >>
> >> Any chance that the failing machine has threads=y in the
> >> suspend.conf file?
> >
> > Yes, that indeed is the trigger / difference, enabling that on the
> > U4100 (its not a U1400) machine makes that fail also and disabling
> > makes it work on the i7-3630QM.
> 
> Thanks, if you get a chance sysrq w might be interesting but I think
> we have enough info to solve the problem.
> 

Now that I've set up everything this is no big effort...

[  343.801889] Loglevel set to 9
[  347.336205]  [<ffffffff81496df4>] schedule+0x24/0x70
[  347.337184]  [<ffffffff81097aad>] __refrigerator+0x4d/0x140
[  347.338170]  [<ffffffff8107601e>] ? __wake_up+0x4e/0x70
[  347.339163]  [<ffffffffa0198866>] kjournald2+0x236/0x240 [jbd2]
[  347.340156]  [<ffffffff8106ba70>] ? finish_wait+0x80/0x80
[  347.341162]  [<ffffffffa0198630>] ? journal_init_common+0x160/0x160 [jbd2]
[  347.342162]  [<ffffffff8106b27b>] kthread+0xbb/0xc0
[  347.343143]  [<ffffffff8106b1c0>] ? kthread_create_on_node+0x130/0x130
[  347.344116]  [<ffffffff814990ac>] ret_from_fork+0x7c/0xb0
[  347.345059]  [<ffffffff8106b1c0>] ? kthread_create_on_node+0x130/0x130
[  347.345983] systemd-journal D ffff88082f252d40     0   526      1 0x00000000
[  347.346919]  ffff8807f63e7dd8 0000000000000082 ffff8807f72e1750 ffff8807f63e7fd8
[  347.347871]  ffff8807f63e7fd8 ffff8807f63e7fd8 ffff88080350aea0 ffff8807f72e1750
[  347.348827]  ffff8807f63e7dc8 ffff8807f72e1750 ffff8807f72e1750 ffff8807f72e1750
[  347.349784] Call Trace:
[  347.350733]  [<ffffffff81496df4>] schedule+0x24/0x70
[  347.351688]  [<ffffffff81097aad>] __refrigerator+0x4d/0x140
[  347.352641]  [<ffffffff810bab88>] ? cgroup_freezing+0x28/0x40
[  347.353592]  [<ffffffff811b3a30>] ep_poll+0x320/0x340
[  347.354533]  [<ffffffff81392361>] ? sock_ioctl+0x71/0x2a0
[  347.355473]  [<ffffffff8107b120>] ? try_to_wake_up+0x2b0/0x2b0
[  347.356414]  [<ffffffff811b4aa5>] SyS_epoll_wait+0xd5/0x100
[  347.357350]  [<ffffffff81499152>] system_call_fastpath+0x16/0x1b
[  347.358286] kauditd         D ffff88082f312d40     0   527      2 0x00000000
[  347.359236]  ffff8807f618bde8 0000000000000046 ffff8807f7361750 ffff8807f618bfd8
[  347.360198]  ffff8807f618bfd8 ffff8807f618bfd8 ffff880803540000 ffff8807f7361750
[  347.361165]  ffff8807f7259380 ffff8807f7361750 ffff8807f7361750 ffff8807f7361750
[  347.362132] Call Trace:
[  347.363084]  [<ffffffff81496df4>] schedule+0x24/0x70
[  347.364043]  [<ffffffff81097aad>] __refrigerator+0x4d/0x140
[  347.365001]  [<ffffffff8107601e>] ? __wake_up+0x4e/0x70
[  347.365959]  [<ffffffff810c0c5a>] kauditd_thread+0x1aa/0x1b0
[  347.366913]  [<ffffffff8107b120>] ? try_to_wake_up+0x2b0/0x2b0
[  347.367860]  [<ffffffff810c0ab0>] ? audit_printk_skb+0x70/0x70
[  347.368805]  [<ffffffff8106b27b>] kthread+0xbb/0xc0
[  347.369746]  [<ffffffff8106b1c0>] ? kthread_create_on_node+0x130/0x130
[  347.370685]  [<ffffffff814990ac>] ret_from_fork+0x7c/0xb0
[  347.371621]  [<ffffffff8106b1c0>] ? kthread_create_on_node+0x130/0x130
[  347.372565] systemd-udevd   D ffff88082f252d40     0   553      1 0x00000000
[  347.373524]  ffff8807f5fdbdd8 0000000000000086 ffff8807f72b5d40 ffff8807f5fdbfd8
[  347.374496]  ffff8807f5fdbfd8 ffff8807f5fdbfd8 ffff88080350aea0 ffff8807f72b5d40
[  347.375471]  0000000000000000 ffff8807f72b5d40 ffff8807f72b5d40 ffff8807f72b5d40
[  347.376444] Call Trace:
[  347.377402]  [<ffffffff81496df4>] schedule+0x24/0x70
[  347.378369]  [<ffffffff81097aad>] __refrigerator+0x4d/0x140
[  347.379333]  [<ffffffff811b3a30>] ep_poll+0x320/0x340
[  347.380296]  [<ffffffff8107b120>] ? try_to_wake_up+0x2b0/0x2b0
[  347.381254]  [<ffffffff811b4aa5>] SyS_epoll_wait+0xd5/0x100
[  347.382206]  [<ffffffff81499152>] system_call_fastpath+0x16/0x1b
[  347.383158] haveged         D ffff88082f352d40     0   858      1 0x00000000
[  347.384129]  ffff8807f641b908 0000000000000082 ffff8807f45add40 ffff8807f641bfd8[  347.385106]  ffff8807f641bfd8 ffff8807f641bfd8 ffff880803541750 ffff8807f45add40
[  347.386083]  ffff8807f641b8f8 ffff8807f45add40 ffff8807f45add40 ffff8807f45add40[  347.389000]  [<ffffffff81097aad>] __refrigerator+0x4d/0x140
[  347.389976]  [<ffffffff810bab88>] ? cgroup_freezing+0x28/0x40
[  347.390949]  [<ffffffff81180699>] poll_schedule_timeout+0xa9/0xb0
[  347.391915]  [<ffffffff81180fd5>] do_select+0x6f5/0x840
[  347.393845]  [<ffffffff81180580>] ? __pollwait+0xf0/0xf0
[  347.396686]  [<ffffffff81105834>] ? filemap_fault+0x84/0x460
[  347.397623]  [<ffffffff81103512>] ? unlock_page+0x22/0x30
[  347.401351]  [<ffffffff81181303>] core_sys_select+0x1e3/0x310
[  347.402278]  [<ffffffff81306c7b>] ? credit_entropy_bits.part.7+0x18b/0x1f0
[  347.403209]  [<ffffffff8130710a>] ? random_ioctl+0x16a/0x190
[  347.404140]  [<ffffffff8130710a>] ? random_ioctl+0x16a/0x190
[  347.540893]  ffff8807f7378d00 ffff8808029f8000 ffff8808029f8000[  347.543682]  [<ffffffff81097aad>] __refrigerator+0x4d/0x140
[  347.544609]  [<ffffffff8107601e>] ? __wake_up+0x4e/0x70
[  347.546466]  [<ffffffff8106ba70>] ? finish_wait+0x80/0x80
[  347.549269]  [<ffffffff8106b1c0>] ? kthread_create_on_node+0x130/0x130
[  347.553048]  ffff8807f4de7d18 0000000000000086 ffff8807f6e02ea0 ffff8807f4de7fd8[  347.554022]  ffff8807f4de7fd8
 ffff8807f6e02ea0 ffff8807f6e02ea0
[  347.556887]  [<ffffffff81496df4>] schedule+0x24/0x70
[  347.557837]  [<ffffffff81097aad>] __refrigerator+0x4d/0x140
[  347.559725]  [<ffffffff8105b14c>] get_signal_to_deliver+0x5fc/0x650
 ffff88082f212d40 


[  347.577740]  [<ffffffff81180fd5>] do_select+0x6f5/0x840
[  347.584244]  [<ffffffff81128d6e>] ? __do_fault+0x1ee/0x520
[  347.590613]  [<ffffffff81499152>] system_call_fastpath+0x16/0x1b
[  347.592425]  ffff8807f5ce9908 ffff8807f4a82ea0 ffff8807f5ce9fd8[  347.594265]  0000000000007530 ffff8807f4a82ea0
[  347.597922]  [<ffffffff8106ed7f>] ? hrtimer_start_range_ns+0xf/0x20
 ffff88082f212d40 [  347.813797]  ffff8807fc6d5a68 0000000000000086 ffff8807fc6d5fd8
[  347.814556]  ffff8807fc6d5fd8 ffffffff81a10440[  347.956796]  [<ffffffff81097aad>] __refrigerator+0x4d/0x140
[  347.957668]  [<ffffffff810bab88>] ? cgroup_freezing+0x28/0x40
[  347.958543]  [<ffffffff8105b14c>] get_signal_to_deliver+0x5fc/0x650
[  347.959418]  [<ffffffff81002392>] do_signal+0x52/0x5a0
[  347.960290]  [<ffffffff8107b120>] ? try_to_wake_up+0x2b0/0x2b0
[  347.961160]  [<ffffffff812e7857>] ? tty_ldisc_deref+0x37/0xa0
[  347.962029]  [<ffffffff812dfd61>] ? tty_read+0xa1/0x100
[  347.962894]  [<ffffffff81002945>] do_notify_resume+0x65/0x80
[  347.963762]  [<ffffffff8116e21d>] ? SyS_read+0x4d/0xa0
[  347.964627]  [<ffffffff814993da>] int_signal+0x12/0x17
[  347.965489] bash            D ffff88082f212d40     0  2780   2707 0x00000004
[  347.966369]  ffff8807f99b7d18 0000000000000086 ffff8807f9cfc5f0 ffff8807f99b7fd8
[  347.967258]  ffff8807f99b7fd8 ffff8807f99b7fd8 ffffffff81a10440 ffff8807f9cfc5f0
[  347.968140]  ffff8807f99b7d08 ffff8807f9cfc5f0 ffff8807f9cfc5f0 ffff8807f9cfc5f0
[  347.969014] Call Trace:
[  347.969873]  [<ffffffff81496df4>] schedule+0x24/0x70
[  347.970743]  [<ffffffff81097aad>] __refrigerator+0x4d/0x140
[  347.971606]  [<ffffffff810bab88>] ? cgroup_freezing+0x28/0x40
[  347.972469]  [<ffffffff8105b14c>] get_signal_to_deliver+0x5fc/0x650
[  347.973333]  [<ffffffff81002392>] do_signal+0x52/0x5a0
[  347.974193]  [<ffffffff8107b120>] ? try_to_wake_up+0x2b0/0x2b0
[  347.975056]  [<ffffffff812e7857>] ? tty_ldisc_deref+0x37/0xa0
[  347.975917]  [<ffffffff812dfd61>] ? tty_read+0xa1/0x100
[  347.976774]  [<ffffffff81002945>] do_notify_resume+0x65/0x80
[  347.977634]  [<ffffffff8116e21d>] ? SyS_read+0x4d/0xa0
[  347.978492]  [<ffffffff814993da>] int_signal+0x12/0x17
[  347.979348] bash            D ffff88082f252d40     0  2786   2700 0x00000004
[  347.980221]  ffff8807f98d3d18 0000000000000086 ffff8807f9f92ea0 ffff8807f98d3fd8
[  347.981113]  ffff8807f98d3fd8 ffff8807f98d3fd8 ffff8807f9de0000 ffff8807f9f92ea0
[  347.981996]  ffff8807f98d3d08 ffff8807f9f92ea0 ffff8807f9f92ea0 ffff8807f9f92ea0
[  347.982868] Call Trace:
[  347.983722]  [<ffffffff81496df4>] schedule+0x24/0x70
[  347.984587]  [<ffffffff81097aad>] __refrigerator+0x4d/0x140
[  347.985448]  [<ffffffff810bab88>] ? cgroup_freezing+0x28/0x40
[  347.986306]  [<ffffffff8105b14c>] get_signal_to_deliver+0x5fc/0x650
[  347.987168]  [<ffffffff81002392>] do_signal+0x52/0x5a0
[  347.988027]  [<ffffffff8107b120>] ? try_to_wake_up+0x2b0/0x2b0
[  347.988890]  [<ffffffff812e7857>] ? tty_ldisc_deref+0x37/0xa0
[  347.989748]  [<ffffffff812dfd61>] ? tty_read+0xa1/0x100
[  347.990603]  [<ffffffff81002945>] do_notify_resume+0x65/0x80
[  347.991460]  [<ffffffff8116e21d>] ? SyS_read+0x4d/0xa0
[  347.992316]  [<ffffffff814993da>] int_signal+0x12/0x17
[  347.993170] bash            D ffff88082f352d40     0  2792   2707 0x00000004
[  347.994042]  ffff8807f9f25d18 0000000000000086 ffff8807f9cf8000 ffff8807f9f25fd8
[  347.994930]  ffff8807f9f25fd8 ffff8807f9f25fd8 ffff8807fa300000 ffff8807f9cf8000
[  347.995810]  ffff8807f9f25d08 ffff8807f9cf8000 ffff8807f9cf8000 ffff8807f9cf8000
[  347.996680] Call Trace:
[  347.997533]  [<ffffffff81496df4>] schedule+0x24/0x70
[  347.998397]  [<ffffffff81097aad>] __refrigerator+0x4d/0x140
[  347.999254]  [<ffffffff810bab88>] ? cgroup_freezing+0x28/0x40
[  348.000111]  [<ffffffff8105b14c>] get_signal_to_deliver+0x5fc/0x650
[  348.000971]  [<ffffffff81002392>] do_signal+0x52/0x5a0
[  348.001831]  [<ffffffff8107b120>] ? try_to_wake_up+0x2b0/0x2b0
[  348.002687]  [<ffffffff812e7857>] ? tty_ldisc_deref+0x37/0xa0
[  348.003540]  [<ffffffff812dfd61>] ? tty_read+0xa1/0x100
[  348.004395]  [<ffffffff81002945>] do_notify_resume+0x65/0x80
[  348.005248]  [<ffffffff8116e21d>] ? SyS_read+0x4d/0xa0
[  348.006102]  [<ffffffff814993da>] int_signal+0x12/0x17
[  348.006955] bash            D ffff88082f252d40     0  2798   2700 0x00000004
[  348.007823]  ffff8807f9e41d18 0000000000000082 ffff8807f9de0000 ffff8807f9e41fd8
[  348.008709]  ffff8807f9e41fd8 ffff8807f9e41fd8 ffff88080350aea0 ffff8807f9de0000
[  348.009588]  ffff8807f9e41d08 ffff8807f9de0000 ffff8807f9de0000 ffff8807f9de0000
[  348.010460] Call Trace:
[  348.011313]  [<ffffffff81496df4>] schedule+0x24/0x70
[  348.012179]  [<ffffffff81097aad>] __refrigerator+0x4d/0x140
[  348.013036]  [<ffffffff810bab88>] ? cgroup_freezing+0x28/0x40
[  348.013893]  [<ffffffff8105b14c>] get_signal_to_deliver+0x5fc/0x650
[  348.014755]  [<ffffffff81002392>] do_signal+0x52/0x5a0
[  348.015611]  [<ffffffff8107b120>] ? try_to_wake_up+0x2b0/0x2b0
[  348.016469]  [<ffffffff812e7857>] ? tty_ldisc_deref+0x37/0xa0
[  348.017325]  [<ffffffff812dfd61>] ? tty_read+0xa1/0x100
[  348.018179]  [<ffffffff81002945>] do_notify_resume+0x65/0x80

[  348.158814]  ffff8807fc441fd8 ffff8807fc441fd8 ffff880803540000 ffff8807f9c4dd40
[  348.159718]  ffff8807fc441a58 ffff8807f9c4dd40 ffff8807f9c4dd40 ffff8807f9c4dd40
[  348.160622] Call Trace:
[  348.161503]  [<ffffffff81496df4>] schedule+0x24/0x70
[  348.162386]  [<ffffffff81097aad>] __refrigerator+0x4d/0x140
[  348.163269]  [<ffffffff8106ed7f>] ? hrtimer_start_range_ns+0xf/0x20
[  348.164158]  [<ffffffff810bab88>] ? cgroup_freezing+0x28/0x40
[  348.165039]  [<ffffffff81180699>] poll_schedule_timeout+0xa9/0xb0
[  348.165921]  [<ffffffff81181b3d>] do_sys_poll+0x3ed/0x5b0
[  348.166798]  [<ffffffff81180580>] ? __pollwait+0xf0/0xf0
[  348.167676]  [<ffffffff81180580>] ? __pollwait+0xf0/0xf0
[  348.168544]  [<ffffffff81180580>] ? __pollwait+0xf0/0xf0
[  348.169405]  [<ffffffff81180580>] ? __pollwait+0xf0/0xf0
[  348.170255]  [<ffffffff81180580>] ? __pollwait+0xf0/0xf0
[  348.171096]  [<ffffffff81394c28>] ? SYSC_recvfrom+0x118/0x140
[  348.171938]  [<ffffffff81098e17>] ? ktime_get_ts+0x47/0xe0
[  348.172781]  [<ffffffff811808c2>] ? poll_select_set_timeout+0x72/0x90
[  348.173624]  [<ffffffff81181dcd>] SyS_poll+0x6d/0x100
[  348.174468]  [<ffffffff81499152>] system_call_fastpath+0x16/0x1b
[  348.175314] systemd-sleep   D ffff88082f292d40     0  3262      1 0x00000004
[  348.176167]  ffff8807fc7e1d18 0000000000000086 ffff8807f6fa8000 ffff8807fc7e1fd8
[  348.177024]  ffff8807fc7e1fd8 ffff8807fc7e1fd8 ffff88080350c5f0 ffff8807f6fa8000
[  348.177881]  ffff8807fc7e1d08 ffff8807f6fa8000 ffff8807f6fa8000 ffff8807f6fa8000
[  348.178740] Call Trace:
[  348.179575]  [<ffffffff81496df4>] schedule+0x24/0x70
[  348.180418]  [<ffffffff81097aad>] __refrigerator+0x4d/0x140
[  348.181264]  [<ffffffff810bab88>] ? cgroup_freezing+0x28/0x40
[  348.182109]  [<ffffffff8105b14c>] get_signal_to_deliver+0x5fc/0x650
[  348.182956]  [<ffffffff81075ba4>] ? finish_task_switch+0x44/0xd0
[  348.183803]  [<ffffffff81002392>] do_signal+0x52/0x5a0
[  348.184647]  [<ffffffff8106bda1>] ? remove_wait_queue+0x51/0x60
[  348.185494]  [<ffffffff8104acd3>] ? do_wait+0x123/0x280
[  348.186335]  [<ffffffff8107b27b>] ? wake_up_new_task+0xfb/0x1a0
[  348.187181]  [<ffffffff81002945>] do_notify_resume+0x65/0x80
[  348.188028]  [<ffffffff81049a70>] ? task_stopped_code+0x50/0x50
[  348.188880]  [<ffffffff814993da>] int_signal+0x12/0x17
[  348.189725] pm-hibernate    D ffff88082f3d2d40     0  3264   3262 0x00000004
[  348.190576]  ffff8807fc16bd18 0000000000000086 ffff8807fa2eaea0 ffff8807fc16bfd8
[  348.191439]  ffff8807fc16bfd8 ffff8807fc16bfd8 ffff8808035445f0 ffff8807fa2eaea0
[  348.192307]  ffff8807fc16bd08 ffff8807fa2eaea0 ffff8807fa2eaea0 ffff8807fa2eaea0
[  348.193163] Call Trace:
[  348.194004]  [<ffffffff81496df4>] schedule+0x24/0x70
[  348.194852]  [<ffffffff81097aad>] __refrigerator+0x4d/0x140
[  348.195704]  [<ffffffff810bab88>] ? cgroup_freezing+0x28/0x40
[  348.196554]  [<ffffffff8105b14c>] get_signal_to_deliver+0x5fc/0x650
[  348.197406]  [<ffffffff810801e3>] ? pick_next_task_fair+0x63/0x180
[  348.198258]  [<ffffffff81075ba4>] ? finish_task_switch+0x44/0xd0
[  348.199114]  [<ffffffff81002392>] do_signal+0x52/0x5a0
[  348.199968]  [<ffffffff8106bda1>] ? remove_wait_queue+0x51/0x60
[  348.200817]  [<ffffffff8104acd3>] ? do_wait+0x123/0x280
[  348.201657]  [<ffffffff8107b27b>] ? wake_up_new_task+0xfb/0x1a0
[  348.202494]  [<ffffffff81002945>] do_notify_resume+0x65/0x80
[  348.203331]  [<ffffffff81049a70>] ? task_stopped_code+0x50/0x50
[  348.204166]  [<ffffffff814993da>] int_signal+0x12/0x17
[  348.204999] s2disk          D ffff88082f392d40     0  3483   3264 0x00000000
[  348.205841]  ffff8807fc10fbf8 0000000000000082 ffff8807fa5d0000 ffff8807fc10ffd8
[  348.206699]  ffff8807fc10ffd8 ffff8807fc10ffd8 ffff880803542ea0 ffff8807fa5d0000
[  348.207563]  ffff8807f725de40 ffff8807fa5d0000 ffff8807fa5d0000 ffff8807fa5d0000
[  348.208423] Call Trace:
[  348.209270]  [<ffffffff81496df4>] schedule+0x24/0x70
[  348.210124]  [<ffffffff81097aad>] __refrigerator+0x4d/0x140
[  348.210979]  [<ffffffff810a2ba5>] futex_wait_queue_me+0x125/0x140
[  348.211838]  [<ffffffff810a3381>] futex_wait+0x181/0x290
[  348.212691]  [<ffffffff810a4e3c>] do_futex+0x11c/0xb30
[  348.213545]  [<ffffffff810a58e3>] SyS_futex+0x93/0x1a0
[  348.214389]  [<ffffffff81075ba4>] ? finish_task_switch+0x44/0xd0
[  348.215229]  [<ffffffff81079572>] ? schedule_tail+0x22/0xa0
[  348.216063]  [<ffffffff81499152>] system_call_fastpath+0x16/0x1b
[  348.216907] Sched Debug Version: v0.10, 3.11.0-rc2 #1
[  348.217736] ktime                                   : 347737.351160
[  348.218572] sched_clk                               : 348216.906329
[  348.219406] cpu_clk                                 : 348216.906356
[  348.220232] jiffies                                 : 4295015036
[  348.221053] sched_clock_stable                      : 1
[  348.221871] 
[  348.222674] sysctl_sched
[  348.223478]   .sysctl_sched_latency                    : 24.000000
[  348.345542]   .nr_running                    : 0
[  348.346103]   .load                          : 0
[  348.346660]   .runnable_load_avg             : 0
[  348.347219]   .blocked_load_avg              : 0
[  348.347774]   .tg_load_contrib               : 0
[  348.348327]   .tg_runnable_contrib           : 0
[  348.348878]   .tg_load_avg                   : 0
[  348.349429]   .tg->runnable_avg              : 5
[  348.349985]   .avg->runnable_avg_sum         : 36
[  348.350539]   .avg->runnable_avg_period      : 48194
[  348.351092] 
[  348.351092] rt_rq[1]:/system/systemd-hibernate.service
[  348.352186]   .rt_nr_running                 : 0
[  348.352747]   .rt_throttled                  : 0
[  348.353307]   .rt_time                       : 0.000000
[  348.353867]   .rt_runtime                    : 0.000000
[  348.354421] 
[  348.354421] rt_rq[1]:/system/bluetooth.service
[  348.355507]   .rt_nr_running                 : 0
[  348.356066]   .rt_throttled                  : 0
[  348.356625]   .rt_time                       : 0.000000
[  348.357183]   .rt_runtime                    : 0.000000
[  348.357740] 
[  348.357740] rt_rq[1]:/system/udisks2.service
[  348.358841]   .rt_nr_running                 : 0
[  348.359406]   .rt_throttled                  : 0
[  348.359972]   .rt_time                       : 0.000000
[  348.360540]   .rt_runtime                    : 0.000000
[  348.361108] 
[  348.361108] rt_rq[1]:/system/polkit.service
[  348.362228]   .rt_nr_running                 : 0
[  348.362801]   .rt_throttled                  : 0
[  348.363375]   .rt_time                       : 0.000000
[  348.363948]   .rt_runtime                    : 0.000000
[  348.364521] 
[  348.364521] rt_rq[1]:/system/upower.service
[  348.365605]   .rt_nr_running                 : 0
[  348.366130]   .rt_throttled                  : 0
[  348.366657]   .rt_time                       : 0.000000
[  348.367179]   .rt_runtime                    : 0.000000
[  348.367702] 
[  348.367702] rt_rq[1]:/system/postfix.service/control
[  348.368740]   .rt_nr_running                 : 0
[  348.369269]   .rt_throttled                  : 0
[  348.369799]   .rt_time                       : 0.000000
[  348.370323]   .rt_runtime                    : 0.000000
[  348.370844] 
[  348.370844] rt_rq[1]:/system/sshd.service
[  348.371876]   .rt_nr_running                 : 0
[  348.372408]   .rt_throttled                  : 0
[  348.372946]   .rt_time                       : 0.000000
[  348.373489]   .rt_runtime                    : 0.000000
[  348.374028] 
[  348.374028] rt_rq[1]:/system/postfix.service
[  348.375095]   .rt_nr_running                 : 0
[  348.375641]   .rt_throttled                  : 0
[  348.376184]   .rt_time                       : 0.000000
[  348.376732]   .rt_runtime                    : 0.000000
[  348.377276] 
[  348.377276] rt_rq[1]:/system/cron.service
[  348.378354]   .rt_nr_running                 : 0
[  348.378900]   .rt_throttled                  : 0
[  348.379447]   .rt_time                       : 0.000000
[  348.379994]   .rt_runtime                    : 0.000000
[  348.380541] 
[  348.380541] rt_rq[1]:/system/xdm.service
[  348.381614]   .rt_nr_running                 : 0
[  348.382163]   .rt_throttled                  : 0
[  348.382714]   .rt_time                       : 0.000000
[  348.383264]   .rt_runtime                    : 0.000000
[  348.383811] 
[  348.383811] rt_rq[1]:/system/dbus.service
[  348.384893]   .rt_nr_running                 : 0
[  348.385448]   .rt_throttled                  : 0
[  348.386000]   .rt_time                       : 0.000000
[  348.386554]   .rt_runtime                    : 0.000000
[  348.387105] 
[  348.387105] rt_rq[1]:/system/getty@.service/tty1
[  348.388188]   .rt_nr_running                 : 0
[  348.388735]   .rt_throttled                  : 0
[  348.389284]   .rt_time                       : 0.000000
[  348.389834]   .rt_runtime                    : 0.000000
[  348.390385] 
[  348.390385] rt_rq[1]:/system/getty@.service
[  348.391467]   .rt_nr_running                 : 0
[  348.392015]   .rt_throttled                  : 0
[  348.392562]   .rt_time                       : 0.000000
[  348.393112]   .rt_runtime                    : 0.000000
[  348.393661] 
[  348.393661] rt_rq[1]:/system/systemd-logind.service
[  348.394744]   .rt_nr_running                 : 0
[  348.395291]   .rt_throttled                  : 0
[  348.395836]   .rt_time                       : 0.000000
[  348.396385]   .rt_runtime                    : 0.000000
[  348.396934] 
[  348.396934] rt_rq[1]:/system/rsyslog.service
[  348.398015]   .rt_nr_running                 : 0
[  348.398564]   .rt_throttled                  : 0
[  348.399110]   .rt_time                       : 0.000000
[  348.399659]   .rt_runtime                    : 0.000000
[  348.400211] 
[  348.400211] rt_rq[1]:/system/haveged.service
[  348.401292]   .rt_nr_running                 : 0
[  348.401842]   .rt_throttled                  : 0
[  348.402390]   .rt_time                       : 0.000000
[  348.402940]   .rt_runtime                    : 0.000000
[  348.403487] 
[  348.403487] rt_rq[1]:/system/systemd-fsck@.service
[  348.404567]   .rt_nr_running                 : 0
[  348.405111]   .rt_throttled                  : 0
[  348.405656]   .rt_time                       : 0.000000
[  348.406202]   .rt_runtime                    : 0.000000
[  348.406750] 
[  348.406750] rt_rq[1]:/system/systemd-udevd.service
[  348.407831]   .rt_nr_running                 : 0
[  348.408379]   .rt_throttled                  : 0
[  348.408926]   .rt_time                       : 0.000000
[  348.409475]   .rt_runtime                    : 0.000000
[  348.410024] 
[  348.410024] rt_rq[1]:/system/systemd-journald.service
[  348.411110]   .rt_nr_running                 : 0
[  348.411659]   .rt_throttled                  : 0
[  348.412207]   .rt_time                       : 0.000000
[  348.412756]   .rt_runtime                    : 0.000000
[  348.413308] 
[  348.413308] rt_rq[1]:/system
[  348.414385]   .rt_nr_running                 : 0
[  348.414931]   .rt_throttled                  : 0
[  348.415473]   .rt_time                       : 0.000000
[  348.416019]   .rt_runtime                    : 0.000000
[  348.416564] 
[  348.416564] rt_rq[1]:/
[  348.417627]   .rt_nr_running                 : 0
[  348.418163]   .rt_throttled                  : 0
[  348.418700]   .rt_time                       : 0.000000
[  348.419240]   .rt_runtime                    : 950.000000
[  348.419782] 
[  348.419782] runnable tasks:
[  348.419782]             task   PID         tree-key  switches  prio     exec-runtime         sum-exec        sum-sleep
[  348.419782] ----------------------------------------------------------------------------------------------------------
[  348.421983] 
[  348.422555] cpu#2, 2394.479 MHz
[  348.423140]   .nr_running                    : 0
[  348.423729]   .load                          : 0
[  348.424313]   .nr_switches                   : 46347
[  348.424893]   .nr_load_updates               : 12960
[  348.425473]   .nr_uninterruptible            : -42
[  348.426053]   .next_balance                  : 4295.014754
[  348.426641]   .curr->pid                     : 0
[  348.427228]   .clock                         : 347934.367461
[  348.427814]   .cpu_load[0]                   : 0
[  348.428394]   .cpu_load[1]                   : 0
[  348.552446]   .rt_nr_running                 : 0
[  348.552973]   .rt_throttled                  : 0
[  348.636728]   .rt_time                       : 0.000000
[  348.554024]   .rt_runtime                    : 0.000000
[  348.560864] 
[  348.560864] rt_rq[3]:/system/postfix.service
[  348.561921]   .rt_nr_running                 : 0
[  348.562464]   .rt_throttled                  : 0
[  348.780964]   .rt_nr_running                 : 0
[  348.563556]   .rt_runtime                    : 0.000000
[  348.564097] 
[  348.564097] rt_rq[3]:/system/cron.service
[  348.566793]   .rt_runtime                    : 0.000000
[  348.567332] 
[  348.567332] rt_rq[3]:/system/xdm.service
[  348.568396]   .rt_nr_running                 : 0
[  348.568941]   .rt_throttled                  : 0
[  348.570035]   .rt_runtime                    : 0.000000
[  348.570581] 
[  348.570581] rt_rq[3]:/system/dbus.service
[  348.571659]   .rt_nr_running                 : 0
[  348.803324]   .cpu_load[4]                   : 0
[  348.573864] 
[  348.573864] rt_rq[3]:/system/getty@.service/tty1
[  348.576024]   .rt_time                       : 0.000000
[  348.576568]   .rt_runtime                    : 0.000000
[  348.578181]   .rt_nr_running                 : 0
[  348.578722]   .rt_throttled                  : 0
[  348.579263]   .rt_time                       : 0.000000
[  348.580349] 
[  348.580349] rt_rq[3]:/system/systemd-logind.service
[  348.583049]   .rt_runtime                    : 0.000000
[  348.583592] 
[  348.583592] rt_rq[3]:/system/rsyslog.service
[  348.586294]   .rt_runtime                    : 0.000000
[  348.586841] 
[  348.586841] rt_rq[3]:/system/haveged.service
[  348.588455]   .rt_throttled                  : 0
[  348.588998]   .rt_time                       : 0.000000
[  348.590087] 
[  348.590087] rt_rq[3]:/system/systemd-fsck@.service
[  348.591164]   .rt_nr_running                 : 0
[  348.591706]   .rt_throttled                  : 0
[  348.592247]   .rt_time                       : 0.000000
[  348.592791]   .rt_runtime                    : 0.000000
[  348.593335] 
[  348.593335] rt_rq[3]:/system/systemd-udevd.service
[  348.594409]   .rt_nr_running                 : 0
[  348.594956]   .rt_throttled                  : 0
[  348.596046]   .rt_runtime                    : 0.000000
[  348.596592] 
[  348.596592] rt_rq[3]:/system/systemd-journald.service
[  348.597675]   .rt_nr_running                 : 0
[  348.598224]   .rt_throttled                  : 0
[  348.598769]   .rt_time                       : 0.000000
[  348.599317]   .rt_runtime                    : 0.000000
[  348.599868] 
[  348.599868] rt_rq[3]:/system
[  348.600942]   .rt_nr_running                 : 0
[  348.601485]   .rt_throttled                  : 0
[  348.602027]   .rt_time                       : 0.000000
[  348.602571]   .rt_runtime                    : 0.000000
[  348.603115] 
[  348.603115] rt_rq[3]:/
[  348.604181]   .rt_nr_running                 : 0
[  348.604715]   .rt_throttled                  : 0
[  348.605252]   .rt_time                       : 0.000000
[  348.605791]   .rt_runtime                    : 950.000000
[  348.606331] 
[  348.606331] runnable tasks:
[  348.606331]             task   PID         tree-key  switches  prio     exec-runtime         sum-exec        sum-sleep
[  348.606331] ----------------------------------------------------------------------------------------------------------
[  348.609111] cpu#4, 2394.479 MHz
[  348.609693]   .nr_running                    : 0
[  348.610281]   .load                          : 0
[  348.610866]   .nr_switches                   : 26395
[  348.611446]   .nr_load_updates               : 9172
[  348.612608]   .next_balance                  : 4295.011756
[  348.613786]   .clock                         : 348434.750881
[  348.614956]   .cpu_load[1]                   : 0
[  348.615536]   .cpu_load[2]                   : 0
[  348.616690]   .cpu_load[4]                   : 0
[  348.617263]   .yld_count                     : 2324
[  348.618398]   .sched_goidle                  : 11227
[  348.619530]   .ttwu_count                    : 16564
[  348.620668] 
[  348.620668] cfs_rq[4]:/
[  348.621770]   .exec_clock                    : 2510.563054
[  348.624032]   .spread                        : 0.000000
[  348.624597]   .spread0                       : 673.526556
[  348.626834]   .runnable_load_avg             : 0
[  348.627389]   .blocked_load_avg              : 0
[  348.629587]   .tg->runnable_avg              : 4
[  348.630138]   .avg->runnable_avg_sum         : 0
[  348.632321]   .rt_nr_running                 : 0
[  348.633430]   .rt_time                       : 0.000000
[  348.763005]   .rt_runtime                    : 0.000000
[  348.769521]   .rt_runtime                    : 0.000000
[  348.776606] 
[  348.776606] rt_rq[5]:/system/systemd-fsck@.service
[  348.777683]   .rt_nr_running                 : 0
[  348.782614]   .rt_runtime                    : 0.000000
[  348.785355]   .rt_time                       : 0.000000
[  348.787539]   .rt_nr_running                 : 0
[  348.788081]   .rt_throttled                  : 0
[  348.792389]   .rt_runtime                    : 950.000000
[  348.796880]   .load                          : 0
[  348.797467]   .nr_switches                   : 20163
[  348.963314]   .rt_runtime                    : 0.000000
[  348.966042]   .rt_time                       : 0.000000
[  348.968773]   .rt_throttled                  : 0
[  348.971503]   .rt_nr_running                 : 0
[  348.976949] 
[  348.976949] rt_rq[7]:/
[  348.979618]   .rt_runtime                    : 950.000000
[  348.980156] 
[  348.980156] runnable tasks:
[  348.980156]             task   PID         tree-key  switches  prio     exec-runtime         sum-exec        sum-sleep
[  348.980156] ----------------------------------------------------------------------------------------------------------
[  348.982352] 



-- 
MfG,

Michael Leun

