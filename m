From: Egon Alter <egon.alter@gmx.net>
Subject: Re: nfs oops in 2.6.32-rc5-00041-g1d91624
Date: Tue, 20 Oct 2009 10:49:40 +0200
Message-ID: <200910201049.40760.egon.alter@gmx.net>
References: <200910191803.26845.egon.alter@gmx.net> <200910200151.55016.elendil@planet.nl> <1255997511.2892.8.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="us-ascii"
Cc: linux-nfs@vger.kernel.org
To: Trond Myklebust <trond.myklebust@fys.uio.no>,
	linux-kernel@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.gmx.net ([213.165.64.20]:59851 "HELO mail.gmx.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1751335AbZJTIti (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 20 Oct 2009 04:49:38 -0400
In-Reply-To: <1255997511.2892.8.camel-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


Hi,

> On Tue, 2009-10-20 at 01:51 +0200, Frans Pop wrote:
> > Adding CC to linux-nfs.
> >
> > =================
> > Hi,
> >
> > I got this oops while doing a grep on an nfs4 share.
> >
> >  kernel: general protection fault: 0000 [#1] SMP
> >  kernel: last sysfs file:
> > /sys/devices/system/cpu/cpu1/cache/index2/shared_cpu_map kernel: CPU 0
> >  kernel: Modules linked in: nfs lockd nfs_acl auth_rpcgss sunrpc sit
> > tunnel4 analog it87 hwmon_vid joydev snd_pcm_oss snd_mixer_o ss
> > snd_seq_midi snd_emu10k1_synth snd_emux_synth snd_seq_virmidi
> > snd_seq_midi_event snd_seq_midi_emul snd_seq cpufreq_conservative
> > cpufreq_userspace cpufreq_ powersave snd_hda_codec_realtek snd_emu10k1
> > snd_rawmidi snd_ac97_codec ac97_bus snd_seq_device snd_hda_intel
> > snd_util_mem snd_hda_codec radeon ttm snd_pcm sn d_timer snd_hwdep
> > emu10k1_gp drm_kms_helper snd k8temp r8169 gameport pcspkr drm soundcore
> > mii snd_page_alloc i2c_piix4 i2c_algo_bit kernel: Pid: 4337, comm:
> > rpciod/0 Tainted: G        W  2.6.32-rc5-00041-g1d91624 #1 GA-MA69VM-S2
> 
>                                                       ^^^
> What is the warning that preceded this Oops?

there was another oops from the network during boot (45 minutes before this oops). 
Don't know if this is related:

kernel: ------------[ cut here ]------------
kernel: WARNING: at net/sched/sch_generic.c:261 dev_watchdog+0x201/0x210()
kernel: Hardware name: GA-MA69VM-S2
kernel: NETDEV WATCHDOG: eth0 (r8169): transmit queue 0 timed out
kernel: Modules linked in: sit tunnel4 analog it87 hwmon_vid joydev snd_pcm_oss snd_mixer_oss snd_seq_midi snd_emu10k1_synth snd
kernel: Pid: 0, comm: swapper Not tainted 2.6.32-rc5-00041-g1d91624 #1
kernel: Call Trace:
kernel:  <IRQ>  [<ffffffff81052928>] warn_slowpath_common+0x78/0xb0
kernel:  [<ffffffff810529bc>] warn_slowpath_fmt+0x3c/0x40
kernel:  [<ffffffff8139af31>] dev_watchdog+0x201/0x210
kernel:  [<ffffffff81012539>] ? sched_clock+0x9/0x10
kernel:  [<ffffffff81069e8a>] ? __queue_work+0x3a/0x50
kernel:  [<ffffffff810609d6>] run_timer_softirq+0x186/0x320
kernel:  [<ffffffff8107776b>] ? ktime_get+0x5b/0xe0
kernel:  [<ffffffff81059850>] __do_softirq+0xb0/0x1e0
kernel:  [<ffffffff8107bf05>] ? tick_program_event+0x25/0x30
kernel:  [<ffffffff8100cfac>] call_softirq+0x1c/0x30
kernel:  [<ffffffff8100e7d5>] do_softirq+0x65/0xa0
kernel:  [<ffffffff8105965d>] irq_exit+0x7d/0x90
kernel:  [<ffffffff8102534c>] smp_apic_timer_interrupt+0x6c/0xa0
kernel:  [<ffffffff8100c973>] apic_timer_interrupt+0x13/0x20
kernel:  <EOI>  [<ffffffff8102d6e6>] ? native_safe_halt+0x6/0x10
kernel:  [<ffffffff810136c6>] ? default_idle+0x36/0x90
kernel:  [<ffffffff8101382e>] ? c1e_idle+0x5e/0x120
kernel:  [<ffffffff8100b04b>] ? cpu_idle+0x5b/0xb0
kernel:  [<ffffffff81439525>] ? start_secondary+0x1b2/0x1b7
kernel: ---[ end trace 667f1c1d6e9b9475 ]---

6 minutes before, idmap reported
rpc.idmapd[4348]: nss_getpwnam: name 'nobody' does not map into domain 'localdomain'

> >  kernel: RIP: 0010:[<ffffffffa028d9c2>]  [<ffffffffa028d9c2>]
> > rpcauth_checkverf+0x32/0x70 [sunrpc] kernel: RSP: 0000:ffff8800371add60 
> > EFLAGS: 00010246
> >  kernel: RAX: 6b6b6b6b6b6b6b6b RBX: ffff880017380070 RCX:
> > 000000000000200f kernel: RDX: 0000000000000000 RSI: ffff880034418290 RDI:
> > ffff880017380070 kernel: RBP: ffff8800371add80 R08: ffff8800371ac000 R09:
> > 0000010f683033fc kernel: R10: 0000000000000000 R11: ffff880001c14318 R12:
> > ffff880035d54590 kernel: R13: ffff880034418290 R14: ffff88003472dad0 R15:
> > ffff880034c87260 kernel: FS:  000000007ffd8000(0000)
> > GS:ffff880001c00000(0000) knlGS:00000000f73ff6c0 kernel: CS:  0010 DS:
> > 0018 ES: 0018 CR0: 000000008005003b
> >  kernel: CR2: 000000000e966004 CR3: 00000000140fe000 CR4:
> > 00000000000006f0 kernel: DR0: 0000000000000000 DR1: 0000000000000000 DR2:
> > 0000000000000000 kernel: DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7:
> > 0000000000000400 kernel: Process rpciod/0 (pid: 4337, threadinfo
> > ffff8800371ac000, task ffff8800345f66c0) kernel: Stack:
> >  kernel:  ffff880038cd2588 ffff880017380070 ffff880034c87260
> > ffffffffa0320ed0 kernel: <0> ffff8800371adde0 ffffffffa0285449
> > ffff8800371addb0 ffffffffa0284cba kernel: <0> 0000000000000000
> > ffff880017387a38 ffff8800345f6c38 ffff880017380070 kernel: Call Trace:
> >  kernel:  [<ffffffffa0320ed0>] ? nfs4_xdr_dec_read+0x0/0x110 [nfs]
> >  kernel:  [<ffffffffa0285449>] call_decode+0x2d9/0x790 [sunrpc]
> >  kernel:  [<ffffffffa0284cba>] ? call_transmit_status+0x3a/0x80 [sunrpc]
> >  kernel:  [<ffffffffa028cc82>] __rpc_execute+0xb2/0x2b0 [sunrpc]
> >  kernel:  [<ffffffffa028ceb0>] ? rpc_async_schedule+0x0/0x20 [sunrpc]
> >  kernel:  [<ffffffffa028cec0>] rpc_async_schedule+0x10/0x20 [sunrpc]
> >  kernel:  [<ffffffff8106969d>] worker_thread+0x15d/0x280
> >  kernel:  [<ffffffff8106de50>] ? autoremove_wake_function+0x0/0x40
> >  kernel:  [<ffffffff81069540>] ? worker_thread+0x0/0x280
> >  kernel:  [<ffffffff8106da4e>] kthread+0x8e/0xa0
> >  kernel:  [<ffffffff8100ceaa>] child_rip+0xa/0x20
> >  kernel:  [<ffffffff8106d9c0>] ? kthread+0x0/0xa0
> >  kernel:  [<ffffffff8100cea0>] ? child_rip+0x0/0x20
> >  kernel: Code: 20 f6 05 d9 d5 01 00 10 48 89 5d e8 4c 89 6d f8 48 89 fb
> > 4c 89 65 f0 49 89 f5 4c 8b 67 50 75 1c 49 8b 44 24 38 4c 89 ee 48 89 df
> > <ff> 50 38 48 8b 5d e8 4c 8b 65 f0 4c 8b 6d f8 c9 c3 49 8b 44 24
> >  kernel: RIP  [<ffffffffa028d9c2>] rpcauth_checkverf+0x32/0x70 [sunrpc]
> >  kernel:  RSP <ffff8800371add60>
> >  kernel: ---[ end trace 667f1c1d6e9b9476 ]---
> 
> Hmm...It looks as though the credential doesn't have a crvalidate
> method. I'll see if I can track this down...

mountinfo says:
27 18 0:16 / /imports/mostly-harmless rw,nodiratime,relatime - nfs4 192.168.0.11:/ 
rw,vers=4,rsize=8192,wsize=8192,namlen=255,hard,proto=tcp,timeo=600,retrans=2,sec=sys,clientaddr=192.168.0.10,addr=192.168.0.11

exports on server is:
/exports        192.168.0.0/24(rw,nohide,async,subtree_check,fsid=0)
/exports/work   192.168.0.0/24(rw,nohide,no_root_squash,async,subtree_check)

Egon
