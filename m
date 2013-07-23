Return-Path: linux-nfs-owner@vger.kernel.org
Received: from stator.leun.net ([85.214.203.199]:39204 "EHLO stator.leun.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933733Ab3GWTSx (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 23 Jul 2013 15:18:53 -0400
Date: Tue, 23 Jul 2013 21:16:22 +0200
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
Message-ID: <20130723211622.50f75087@xenia.leun.net>
In-Reply-To: <CAMbhsRT6zOKLhG_uh=nA8H_3d7afhG+4jvWjvidY3fEguryP_Q@mail.gmail.com>
References: <1367884221-20462-1-git-send-email-ccross@android.com>
	<1367884221-20462-14-git-send-email-ccross@android.com>
	<20130723010250.5a3465ec@xenia.leun.net>
	<CAMbhsRQv+W897_5qGuNJD47jQ9ozN6KxeCa6UJAvZpqVuBpQ4w@mail.gmail.com>
	<20130723200854.2046296b@xenia.leun.net>
	<CAMbhsRT6zOKLhG_uh=nA8H_3d7afhG+4jvWjvidY3fEguryP_Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 23 Jul 2013 11:29:57 -0700
Colin Cross <ccross@android.com> wrote:

> On Tue, Jul 23, 2013 at 11:08 AM, Michael Leun
> <lkml20130126@newton.leun.net> wrote:
> > On Mon, 22 Jul 2013 16:55:58 -0700
> > Colin Cross <ccross@android.com> wrote:
> >
> >> On Mon, Jul 22, 2013 at 4:02 PM, Michael Leun
> >> <lkml20130126@newton.leun.net> wrote:
> >> > On Mon,  6 May 2013 16:50:18 -0700
> >> > Colin Cross <ccross@android.com> wrote:
> >> >
> >> >> Avoid waking up every thread sleeping in a futex_wait call
> >> >> during
> >> > [...]
> >> >
> >> > With 3.11-rc s2disk from suspend-utils stopped working: Frozen at
> >> > displaying 0% of saving image to disk.
> >> >
> >> > echo "1" >/sys/power/state still works.
> >> >
> >> > Bisecting yielded 88c8004fd3a5fdd2378069de86b90b21110d33a4,
> >> > reverting that from 3.11-rc2 makes s2disk working again.
> >> >
> >>
> >> I think the expanded use of the freezable_* helpers is exposing an
> >> existing bug in hibernation.  The SNAPSHOT_FREEZE ioctl calls
> >> freeze_processes(), which sets the global system_freezing_cnt and
> >> pm_freezing.  try_to_freeze_tasks then sends every process except
> >> current a signal which causes them all to end up in the
> >> refrigerator. The current task then returns back to userspace and
> >> continues its work to suspend to disk.  If that task ever hits a
> >> call to try_to_freeze() in the kernel, it will see
> >> system_freezing_cnt and pm_freezing=true and freeze, and suspend
> >> to disk will hang forever.  It could hit try_to_freeze() because
> >> of a signal delivered to the task, or from calling any syscall
> >> that uses a freezable_* helper like the one I added to sys_futex.
> >>
> >> I think the right solution is to add a flag to the freezing task
> >> that marks it unfreezable.  I  think PF_NOFREEZE would work,
> >> although it is normally used on kernel threads, can you see if the
> >> attached patch helps?
> >
> > That patch helps.
> >
> > BTW, the only machine I can reproduce this bug with is an i7-3630QM
> > notebook. Cannot reproduce on an Core Duo U1400 and cannot
> > reproduce on an i7 M 620.
> >
> > Are the sysreq backtraces still wanted? If so, any tip, how I could
> > get them saved?

Darren Hart <dvhart@linux.intel.com> wrote:

> Typically by setting up a serial console or a netconsole and saving
[...]
> Is this what you are asking?

Yes, and it indeed works - I halfway expected the net / netconsole
stuff being already frozen in that situation...

Thanks, Darren - see below for the backtraces.

> 
> Any chance that the failing machine has threads=y in the suspend.conf
> file?

Yes, that indeed is the trigger / difference, enabling that on the
U4100 (its not a U1400) machine makes that fail also and disabling
makes it work on the i7-3630QM.

[ 1405.527138] SysRq : Changing Loglevel
[ 1405.527220] Loglevel set to 9
[ 1407.845730] SysRq : Show backtrace of all active CPUs
[ 1407.845818] sending NMI to all CPUs:
[ 1407.845835] NMI backtrace for cpu 4
[ 1407.845870] CPU: 4 PID: 0 Comm: swapper/4 Not tainted 3.11.0-rc2 #1
[ 1407.845911] Hardware name: CLEVO                             P15xEMx/P15xEMx, BIOS 4.6.5 01/24/2013
[ 1407.845967] task: ffff880803540000 ti: ffff88080353a000 task.ti: ffff88080353a000
[ 1407.846002] RIP: 0010:[<ffffffff812ac403>]  [<ffffffff812ac403>] intel_idle+0xa3/0xf0
[ 1407.846046] RSP: 0000:ffff88080353bde8  EFLAGS: 00000046
[ 1407.846072] RAX: 0000000000000030 RBX: 0000000000000010 RCX: 0000000000000001
[ 1407.846104] RDX: 0000000000000000 RSI: ffff88080353bfd8 RDI: 0000000000000004
[ 1407.846137] RBP: ffff88080353be18 R08: 0000000000000057 R09: 000000000fde67ee
[ 1407.846169] R10: 0000000000000000 R11: 00000000003567bb R12: 0000000000000005
[ 1407.846201] R13: 0000000000000030 R14: 0000000000000004 R15: ffffffff81a56dd0
[ 1407.846246] FS:  0000000000000000(0000) GS:ffff88082f300000(0000) knlGS:0000000000000000
[ 1407.846283] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[ 1407.846310] CR2: 0000000000000000 CR3: 0000000001a0b000 CR4: 00000000001407e0
[ 1407.846342] Stack:
[ 1407.846355]  ffff88080353be18 0000000481098d4d ffff88082f319e00 ffffffff81a56c00
[ 1407.846401]  000001473bc66eed 0000000000000005 ffff88080353be78 ffffffff81371eea
[ 1407.846452]  000000000000010a 000000000df017f3 000000000000010a 000000000df017f3
[ 1407.846498] Call Trace:
[ 1407.846520]  [<ffffffff81371eea>] cpuidle_enter_state+0x4a/0xd0
[ 1407.846550]  [<ffffffff81372026>] cpuidle_idle_call+0xb6/0x260
[ 1407.846580]  [<ffffffff8100c699>] arch_cpu_idle+0x9/0x20
[ 1407.846607]  [<ffffffff81097800>] cpu_startup_entry+0x80/0x280
[ 1407.846637]  [<ffffffff8109f301>] ? clockevents_config_and_register+0x21/0x30
[ 1407.846672]  [<ffffffff8102cc2c>] start_secondary+0x1cc/0x270
[ 1407.846709] Code: 28 e0 ff ff 83 e2 08 75 22 31 d2 48 83 c0 10 48 89 d1 0f 01 c8 0f ae f0 48 8b 86 38 e0 ff ff a8 08 75 08 b1 01 4c 89 e8 0f 01 c9 <85> 1d 8f ab 7a 00 75 0e 48 8d 75 dc bf 05 00 00 00 e8 37 2a df 
[ 1407.847137] NMI backtrace for cpu 0
[ 1407.847140] INFO: NMI handler (arch_trigger_all_cpu_backtrace_handler) took too long to run: 1.301 msecs
[ 1407.847198] CPU: 0 PID: 0 Comm: swapper/0 Not tainted 3.11.0-rc2 #1
[ 1407.847220] Hardware name: CLEVO                             P15xEMx/P15xEMx, BIOS 4.6.5 01/24/2013
[ 1407.847254] task: ffffffff81a10440 ti: ffffffff81a00000 task.ti: ffffffff81a00000
[ 1407.847283] RIP: 0010:[<ffffffff8126667f>] [ 1407.847387] RBP: ffff88082f203b98 R08: 0000000000000001 R09: 000000000000066c
[ 1407.847414] R10: ffffffff81a1ec40 R11: 0000000000000000 R12: 000000000000006c
[ 1407.847441] R13: 0000000000000086 R14: 0000000000000001 R15: 0000000000000009
[ 1407.847467] FS:  0000000000000000(0000) GS:ffff88082f200000(0000) knlGS:0000000000000000
[ 1407.847495] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[ 1407.847516] CR2: 00007fffb526ebdc CR3: 0000000001a0b000 CR4: 00000000001407f0
[ 1407.847540] Stack:
[ 1407.847550]  ffff88082f203bb8 ffffffff81030500 0000000000000000 ffffffff81a5bd40
[ 1407.847589]  ffff88082f203bc8 ffffffff812ec099 ffff88082f203c08 ffffffff812ec547
[ 1407.847624]  ffff88082f203c88 ffff88080e80b400 0000000000000026 0000000000000001
[ 1407.848858] Call Trace:
[ 1407.850070]  <IRQ> 
[ 1407.850079]  [<ffffffff81030500>] arch_trigger_all_cpu_backtrace+0x80/0xa0
[ 1407.852518]  [<ffffffff812ec099>] sysrq_handle_showallcpus+0x9/0x10
[ 1407.853731]  [<ffffffff812ec547>] __handle_sysrq+0x127/0x190
[ 1407.854922]  [<ffffffff812ec92e>] sysrq_filter+0x33e/0x380
[ 1407.856114]  [<ffffffff81335522>] input_to_handler+0x52/0xf0
[ 1407.857308]  [<ffffffff813375a9>] input_pass_values.part.9+0x169/0x170
[ 1407.858508]  [<ffffffff813388c7>] input_handle_event+0x117/0x530
[ 1407.859706]  [<ffffffff81338de2>] input_event+0x52/0x70
[ 1407.860910]  [<ffffffff81340457>] atkbd_interrupt+0x5e7/0x6b0
[ 1407.862117]  [<ffffffff813329ed>] serio_interrupt+0x4d/0xa0
[ 1407.863317]  [<ffffffff81333e4a>] i8042_interrupt+0x1ba/0x3a0
[ 1407.864513]  [<ffffffff810708a1>] ? raw_notifier_call_chain+0x11/0x20
[ 1407.865716]  [<ffffffff810984f8>] ? timekeeping_update.constprop.8+0x38/0x80
[ 1407.866926]  [<ffffffff812a1bb0>] ? fbcon_add_cursor_timer+0x100/0x100
[ 1407.868139]  [<ffffffff810cc78d>] handle_irq_event_percpu+0x6d/0x240
[ 1407.869357]  [<ffffffff810cc9a3>] handle_irq_event+0x43/0x70
[ 1407.870572]  [<ffffffff810cf07f>] handle_edge_irq+0x6f/0x110
[ 1407.871788]  [<ffffffff81004aed>] handle_irq+0x1d/0x30
[ 1407.872996]  [<ffffffff810045c5>] do_IRQ+0x55/0xd0
[ 1407.874202]  [<ffffffff814989ea>] common_interrupt+0x6a/0x6a
[ 1407.875410]  <EOI> 
[ 1407.875419]  [<ffffffff810a0b7f>] ? tick_program_event+0x1f/0x30
[ 1407.877811]  [<ffffffff81371ef6>] ? cpuidle_enter_state+0x56/0xd0
[ 1407.879001]  [<ffffffff81371ef2>] ? cpuidle_enter_state+0x52/0xd0
[ 1407.880171]  [<ffffffff81372026>] cpuidle_idle_call+0xb6/0x260
[ 1407.881330]  [<ffffffff8100c699>] arch_cpu_idle+0x9/0x20
[ 1407.882484]  [<ffffffff81097800>] cpu_startup_entry+0x80/0x280
[ 1407.883642]  [<ffffffff81485380>] rest_init+0x80/0x90
[ 1407.884795]  [<ffffffff81ab2e49>] start_kernel+0x3aa/0x3b7
[ 1407.885944]  [<ffffffff81ab289e>] ? repair_env_string+0x5e/0x5e
[ 1407.887093]  [<ffffffff81ab25a3>] x86_64_start_reservations+0x2a/0x2c
[ 1407.888236]  [<ffffffff81ab269d>] x86_64_start_kernel+0xf8/0xfc
[ 1407.889366] Code: 4c 89 4d f8 c7 45 b8 10 00 00 00 48 89 45 c8 e8 38 ff ff ff c9 c3 66 0f 1f 44 00 00 8d 4e 3f 85 f6 55 0f 49 ce 48 89 e5 c1 f9 06 <85> c9 7e 61 48 83 3f 00 75 57 48 8d 57 08 31 c0 eb 12 0f 1f 80 
[ 1407.890771] NMI backtrace for cpu 1
[ 1407.890773] INFO: NMI handler (arch_trigger_all_cpu_backtrace_handler) took too long to run: 44.935 msecs
[ 1407.894228] CPU: 1 PID: 0 Comm: swapper/1 Not tainted 3.11.0-rc2 #1
[ 1407.895746] Hardware name: CLEVO                             P15xEMx/P15xEMx, BIOS 4.6.5 01/24/2013
[ 1407.897286] task: ffff88080350aea0 ti: ffff880803534000 task.ti: ffff880803534000
[ 1407.899298] RIP: 0010:[<ffffffff812ac403>]  [<ffffffff812ac403>] intel_idle+0xa3/0xf0
[ 1407.901326] RSP: 0018:ffff880803535de8  EFLAGS: 00000046
[ 1407.902884] RAX: 0000000000000030 RBX: 0000000000000010 RCX: 0000000000000001
[ 1407.904456] RDX: 0000000000000000 RSI: ffff880803535fd8 RDI: 0000000000000001
[ 1407.906026] RBP: ffff880803535e18 R08: 0000000000000057 R09: 000000000ff56e74
[ 1407.907597] R10: 0000000000000000 R11: 00000000003567c1 R12: 0000000000000005
[ 1407.909164] R13: 0000000000000030 R14: 0000000000000004 R15: ffffffff81a56dd0
[ 1407.910669] FS:  0000000000000000(0000) GS:ffff88082f240000(0000) knlGS:0000000000000000
[ 1407.912575] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[ 1407.914455] CR2: 00007ff17fd28000 CR3: 0000000001a0b000 CR4: 00000000001407e0
[ 1407.915879] Stack:
[ 1407.917716]  ffff880803535e18 0000000181098d4d ffff88082f259e00 ffffffff81a56c00
[ 1407.919152]  00000146e25e4673 0000000000000005 ffff880803535e78 ffffffff81371eea
[ 1407.920573]  000000000000010b 000000002c46c98c 000000000000010b 000000002c46c98c
[ 1407.921986] Call Trace:
[ 1407.923370]  [<ffffffff81371eea>] cpuidle_enter_state+0x4a/0xd0
[ 1407.924769]  [<ffffffff81372026>] cpuidle_idle_call+0xb6/0x260
[ 1407.926166]  [<ffffffff8100c699>] arch_cpu_idle+0x9/0x20
[ 1407.927561]  [<ffffffff81097800>] cpu_startup_entry+0x80/0x280
[ 1407.928963]  [<ffffffff8109f301>] ? clockevents_config_and_register+0x21/0x30
[ 1407.930368]  [<ffffffff8102cc2c>] start_secondary+0x1cc/0x270
[ 1407.932200] Code: 28 e0 ff ff 83 e2 08 75 22 31 d2 48 83 c0 10 48 89 d1 0f 01 c8 0f ae f0 48 8b 86 38 e0 ff ff a8 08 75 08 b1 01 4c 89 e8 0f 01 c9 <85> 1d 8f ab 7a 00 75 0e 48 8d 75 dc bf 05 00 00 00 e8 37 2a df 
[ 1407.933922] NMI backtrace for cpu 5
[ 1407.933924] INFO: NMI handler (arch_trigger_all_cpu_backtrace_handler) took too long to run: 88.055 msecs
[ 1407.936433] CPU: 5 PID: 0 Comm: swapper/5 Not tainted 3.11.0-rc2 #1
[ 1407.937700] Hardware name: CLEVO                             P15xEMx/P15xEMx, BIOS 4.6.5 01/24/2013
[ 1407.938987] task: ffff880803541750 ti: ffff88080353c000 task.ti: ffff88080353c000
[ 1407.940270] RIP: 0010:[<ffffffff812ac403>]  [<ffffffff812ac403>] intel_idle+0xa3/0xf0
[ 1407.941576] RSP: 0000:ffff88080353dde8  EFLAGS: 00000046
[ 1407.942873] RAX: 0000000000000030 RBX: 0000000000000010 RCX: 0000000000000001
[ 1407.944181] RDX: 0000000000000000 RSI: ffff88080353dfd8 RDI: 0000000000000005
[ 1407.945488] RBP: ffff88080353de18 R08: 0000000000000057 R09: 000000000fd6bb17
[ 1407.946798] R10: 0000000000000000 R11: 00000000003567d7 R12: 0000000000000005
[ 1407.948105] R13: 0000000000000030 R14: 0000000000000004 R15: ffffffff81a56dd0
[ 1407.949415] FS:  0000000000000000(0000) GS:ffff88082f340000(0000) knlGS:0000000000000000
[ 1407.950735] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[ 1407.952055] CR2: 0000000000000000 CR3: 0000000001a0b000 CR4: 00000000001407e0
[ 1407.953389] Stack:
[ 1407.954719]  ffff88080353de18 0000000581098d4d ffff88082f359e00 ffffffff81a56c00
[ 1407.956084]  000001475993cee2 0000000000000005 ffff88080353de78 ffffffff81371eea
[ 1407.957448]  0000000000000109 000000002b8fbaa2 0000000000000109 000000002b8fbaa2
[ 1407.958812] Call Trace:
[ 1407.960160]  [<ffffffff81371eea>] cpuidle_enter_state+0x4a/0xd0
[ 1407.961519]  [<ffffffff81372026>] cpuidle_idle_call+0xb6/0x260
[ 1407.962879]  [<ffffffff8100c699>] arch_cpu_idle+0x9/0x20
[ 1407.964240]  [<ffffffff81097800>] cpu_startup_entry+0x80/0x280
[ 1407.965602]  [<ffffffff8109f301>] ? clockevents_config_and_register+0x21/0x30
[ 1407.966978]  [<ffffffff8102cc2c>] start_secondary+0x1cc/0x270
[ 1407.968352] Code: 28 e0 ff ff 83 e2 08 75 22 31 d2 48 83 c0 10 48 89 d1 0f 01 c8 0f ae f0 48 8b 86 38 e0 ff ff a8 08 75 08 b1 01 4c 89 e8 0f 01 c9 <85> 1d 8f ab 7a 00 75 0e 48 8d 75 dc bf 05 00 00 00 e8 37 2a df 
[ 1407.970046] NMI backtrace for cpu 6
[ 1407.970048] INFO: NMI handler (arch_trigger_all_cpu_backtrace_handler) took too long to run: 124.179 msecs
[ 1407.974761] CPU: 6 PID: 0 Comm: swapper/6 Not tainted 3.11.0-rc2 #1
[ 1407.976613] Hardware name: CLEVO                             P15xEMx/P15xEMx, BIOS 4.6.5 01/24/2013
[ 1407.978491] task: ffff880803542ea0 ti: ffff88080353e000 task.ti: ffff88080353e000
[ 1407.980381] RIP: 0010:[<ffffffff812ac403>]  [<ffffffff812ac403>] intel_idle+0xa3/0xf0
[ 1407.982855] RSP: 0018:ffff88080353fde8  EFLAGS: 00000046
[ 1407.984756] RAX: 0000000000000030 RBX: 0000000000000010 RCX: 0000000000000001
[ 1407.986674] RDX: 0000000000000000 RSI: ffff88080353ffd8 RDI: 0000000000000006
[ 1407.988590] RBP: ffff88080353fe18 R08: 0000000000000057 R09: 000000000fcf0e3f
[ 1407.991088] R10: 0000000000000000 R11: 00000000003567da R12: 0000000000000005
[ 1407.993018] R13: 0000000000000030 R14: 0000000000000004 R15: ffffffff81a56dd0
[ 1407.994875] FS:  0000000000000000(0000) GS:ffff88082f380000(0000) knlGS:0000000000000000
[ 1407.996698] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[ 1407.998485] CR2: 0000000000000000 CR3: 0000000001a0b000 CR4: 00000000001407e0
[ 1408.000272] Stack:
[ 1408.002572]  ffff88080353fe18 0000000681098d4d ffff88082f399e00 ffffffff81a56c00
[ 1408.004361]  0000014777613532 0000000000000005 ffff88080353fe78 ffffffff81371eea
[ 1408.006674]  0000000000000109 000000000d948c6f 0000000000000109 000000000d948c6f
[ 1408.008443] Call Trace:
[ 1408.010189]  [<ffffffff81371eea>] cpuidle_enter_state+0x4a/0xd0
[ 1408.011951]  [<ffffffff81372026>] cpuidle_idle_call+0xb6/0x260
[ 1408.014250]  [<ffffffff8100c699>] arch_cpu_idle+0x9/0x20
[ 1408.016546]  [<ffffffff81097800>] cpu_startup_entry+0x80/0x280
[ 1408.018843]  [<ffffffff8109f301>] ? clockevents_config_and_register+0x21/0x30
[ 1408.021144]  [<ffffffff8102cc2c>] start_secondary+0x1cc/0x270
[ 1408.022885] Code: 28 e0 ff ff 83 e2 08 75 22 31 d2 48 83 c0 10 48 89 d1 0f 01 c8 0f ae f0 48 8b 86 38 e0 ff ff a8 08 75 08 b1 01 4c 89 e8 0f 01 c9 <85> 1d 8f ab 7a 00 75 0e 48 8d 75 dc bf 05 00 00 00 e8 37 2a df 
[ 1408.024957] INFO: NMI handler (arch_trigger_all_cpu_backtrace_handler) took too long to run: 179.088 msecs
[ 1408.024958] NMI backtrace for cpu 2
[ 1408.024960] CPU: 2 PID: 0 Comm: swapper/2 Not tainted 3.11.0-rc2 #1
[ 1408.024961] Hardware name: CLEVO                             P15xEMx/P15xEMx, BIOS 4.6.5 01/24/2013
[ 1408.024962] task: ffff88080350c5f0 ti: ffff880803536000 task.ti: ffff880803536000
[ 1408.024964] RIP: 0010:[<ffffffff812ac403>]  [<ffffffff812ac403>] intel_idle+0xa3/0xf0
[ 1408.024965] RSP: 0000:ffff880803537de8  EFLAGS: 00000046
[ 1408.024966] RAX: 0000000000000030 RBX: 0000000000000010 RCX: 0000000000000001
[ 1408.024967] RDX: 0000000000000000 RSI: ffff880803537fd8 RDI: 0000000000000002
[ 1408.024967] RBP: ffff880803537e18 R08: 0000000000000057 R09: 000000000fedc1a1
[ 1408.024968] R10: 0000000000000000 R11: 00000000003567d7 R12: 0000000000000005
[ 1408.024969] R13: 0000000000000030 R14: 0000000000000004 R15: ffffffff81a56dd0
[ 1408.024970] FS:  0000000000000000(0000) GS:ffff88082f280000(0000) knlGS:0000000000000000
[ 1408.024971] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[ 1408.024971] CR2: 0000000000000000 CR3: 0000000001a0b000 CR4: 00000000001407e0
[ 1408.024972] Stack:
[ 1408.024974]  ffff880803537e18 0000000281098d4d ffff88082f299e00 ffffffff81a56c00
[ 1408.024975]  00000147002b9b55 0000000000000005 ffff880803537e78 ffffffff81371eea
[ 1408.024976]  000000000000010b 000000000e4baf99 000000000000010b 000000000e4baf99
[ 1408.024977] Call Trace:
[ 1408.024979]  [<ffffffff81371eea>] cpuidle_enter_state+0x4a/0xd0
[ 1408.024982]  [<ffffffff81372026>] cpuidle_idle_call+0xb6/0x260
[ 1408.024984]  [<ffffffff8100c699>] arch_cpu_idle+0x9/0x20
[ 1408.024985]  [<ffffffff81097800>] cpu_startup_entry+0x80/0x280
[ 1408.024987]  [<ffffffff8109f301>] ? clockevents_config_and_register+0x21/0x30
[ 1408.024989]  [<ffffffff8102cc2c>] start_secondary+0x1cc/0x270
[ 1408.025006] Code: 28 e0 ff ff 83 e2 08 75 22 31 d2 48 83 c0 10 48 89 d1 0f 01 c8 0f ae f0 48 8b 86 38 e0 ff ff a8 08 75 08 b1 01 4c 89 e8 0f 01 c9 <85> 1d 8f ab 7a 00 75 0e 48 8d 75 dc bf 05 00 00 00 e8 37 2a df 
[ 1408.025008] INFO: NMI handler (arch_trigger_all_cpu_backtrace_handler) took too long to run: 179.139 msecs
[ 1408.025009] NMI backtrace for cpu 7
[ 1408.025011] CPU: 7 PID: 0 Comm: swapper/7 Not tainted 3.11.0-rc2 #1
[ 1408.025011] Hardware name: CLEVO                             P15xEMx/P15xEMx, BIOS 4.6.5 01/24/2013
[ 1408.025013] task: ffff8808035445f0 ti: ffff880803550000 task.ti: ffff880803550000
[ 1408.025016] RIP: 0010:[<ffffffff812ac403>]  [<ffffffff812ac403>] intel_idle+0xa3/0xf0
[ 1408.025016] RSP: 0000:ffff880803551de8  EFLAGS: 00000046
[ 1408.025017] RAX: 0000000000000030 RBX: 0000000000000010 RCX: 0000000000000001
[ 1408.025018] RDX: 0000000000000000 RSI: ffff880803551fd8 RDI: 0000000000000007
[ 1408.025018] RBP: ffff880803551e18 R08: 0000000000000057 R09: 000000000007a079
[ 1408.025019] R10: 0000000000000000 R11: 000000000020e8dc R12: 0000000000000005
[ 1408.025020] R13: 0000000000000030 R14: 0000000000000004 R15: ffffffff81a56dd0
[ 1408.025021] FS:  0000000000000000(0000) GS:ffff88082f3c0000(0000) knlGS:0000000000000000
[ 1408.025022] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[ 1408.025022] CR2: 0000000000000000 CR3: 0000000001a0b000 CR4: 00000000001407e0
[ 1408.025023] Stack:
[ 1408.025025]  ffff880803551e18 0000000781098d4d ffff88082f3d9e00 ffffffff81a56c00
[ 1408.025026]  0000014777614583 0000000000000005 ffff880803551e78 ffffffff81371eea
[ 1408.025027]  0000000000000000 000000001dcad99a 0000000000000000 000000001dcad99a
[ 1408.025028] Call Trace:
[ 1408.025030]  [<ffffffff81371eea>] cpuidle_enter_state+0x4a/0xd0
[ 1408.025032]  [<ffffffff81372026>] cpuidle_idle_call+0xb6/0x260
[ 1408.025035]  [<ffffffff8100c699>] arch_cpu_idle+0x9/0x20
[ 1408.025036]  [<ffffffff81097800>] cpu_startup_entry+0x80/0x280
[ 1408.025038]  [<ffffffff8109f301>] ? clockevents_config_and_register+0x21/0x30
[ 1408.025040]  [<ffffffff8102cc2c>] start_secondary+0x1cc/0x270
[ 1408.025057] Code: 28 e0 ff ff 83 e2 08 75 22 31 d2 48 83 c0 10 48 89 d1 0f 01 c8 0f ae f0 48 8b 86 38 e0 ff ff a8 08 75 08 b1 01 4c 89 e8 0f 01 c9 <85> 1d 8f ab 7a 00 75 0e 48 8d 75 dc bf 05 00 00 00 e8 37 2a df 
[ 1408.025057] NMI backtrace for cpu 3
[ 1408.025059] INFO: NMI handler (arch_trigger_all_cpu_backtrace_handler) took too long to run: 179.189 msecs
[ 1408.025061] CPU: 3 PID: 0 Comm: swapper/3 Not tainted 3.11.0-rc2 #1
[ 1408.025061] Hardware name: CLEVO                             P15xEMx/P15xEMx, BIOS 4.6.5 01/24/2013
[ 1408.025062] task: ffff88080350dd40 ti: ffff880803538000 task.ti: ffff880803538000
[ 1408.025064] RIP: 0010:[<ffffffff812ac403>]  [<ffffffff812ac403>] intel_idle+0xa3/0xf0
[ 1408.025065] RSP: 0000:ffff880803539de8  EFLAGS: 00000046
[ 1408.025065] RAX: 0000000000000030 RBX: 0000000000000010 RCX: 0000000000000001
[ 1408.025066] RDX: 0000000000000000 RSI: ffff880803539fd8 RDI: 0000000000000003
[ 1408.025066] RBP: ffff880803539e18 R08: 0000000000000057 R09: 00000000001e939c
[ 1408.025067] R10: 0000000000000000 R11: 00000000001c6983 R12: 0000000000000005
[ 1408.025067] R13: 0000000000000030 R14: 0000000000000004 R15: ffffffff81a56dd0
[ 1408.025068] FS:  0000000000000000(0000) GS:ffff88082f2c0000(0000) knlGS:0000000000000000
[ 1408.025068] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[ 1408.025069] CR2: 0000000000000000 CR3: 0000000001a0b000 CR4: 00000000001407e0
[ 1408.025069] Stack:
[ 1408.025070]  ffff880803539e18 0000000381098d4d ffff88082f2d9e00 ffffffff81a56c00
[ 1408.025071]  0000014780148c27 0000000000000005 ffff880803539e78 ffffffff81371eea
[ 1408.025071]  0000000000000002 00000000003b0659 0000000000000002 00000000003b0659
[ 1408.025072] Call Trace:
[ 1408.025073]  [<ffffffff81371eea>] cpuidle_enter_state+0x4a/0xd0
[ 1408.025075]  [<ffffffff81372026>] cpuidle_idle_call+0xb6/0x260
[ 1408.025076]  [<ffffffff8100c699>] arch_cpu_idle+0x9/0x20
[ 1408.025078]  [<ffffffff81097800>] cpu_startup_entry+0x80/0x280
[ 1408.025079]  [<ffffffff8109f301>] ? clockevents_config_and_register+0x21/0x30
[ 1408.025080]  [<ffffffff8102cc2c>] start_secondary+0x1cc/0x270
[ 1408.025090] Code: 28 e0 ff ff 83 e2 08 75 22 31 d2 48 83 c0 10 48 89 d1 0f 01 c8 0f ae f0 48 8b 86 38 e0 ff ff a8 08 75 08 b1 01 4c 89 e8 0f 01 c9 <85> 1d 8f ab 7a 00 75 0e 48 8d 75 dc bf 05 00 00 00 e8 37 2a df 
[ 1408.025091] INFO: NMI handler (arch_trigger_all_cpu_backtrace_handler) took too long to run: 179.222 msecs




-- 
MfG,

Michael Leun

