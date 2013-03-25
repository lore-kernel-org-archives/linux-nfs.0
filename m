Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:37191 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933365Ab3CYWBo convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 25 Mar 2013 18:01:44 -0400
Date: Mon, 25 Mar 2013 18:01:43 -0400
To: Toralf =?utf-8?Q?F=C3=B6rster?= <toralf.foerster@gmx.de>
Cc: Linux NFS mailing list <linux-nfs@vger.kernel.org>,
        Linux Kernel <linux-kernel@vger.kernel.org>
Subject: Re: kernel 3.8.4 : kernel BUG at fs/locks.c:2093!   part #2
Message-ID: <20130325220143.GD10887@fieldses.org>
References: <514F31AF.3080709@gmx.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
In-Reply-To: <514F31AF.3080709@gmx.de>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sun, Mar 24, 2013 at 06:02:39PM +0100, Toralf Förster wrote:
> The following bug was triggered twice under a stable 3.8.4 kernel if I export a NFS (v4) directory
> and mount it within a user mode linux (running at the same system) and run within that UML trinity
> (16 UML trinity processes at a 4-core host CPU) with victim files+directories within that NFS directory.
> 
> I could not trigger that bug at the host kernel if I run trinity within UML without victim files
> - therefore the issue seems to be tied to NFS. The syslog messages are :

Thanks!

fs/locks.c:2093 says that we did the final fput of a file that still had
posix locks held on it.

I can't see how that would happen, but admittedly the nfsd4 code here is
much too complicated for its own good.

If it were possible it would be useful to know what lead up to this.  A
network trace (tcpdump -s0 -wtmp.pcap, then send me tmp.pcap) would be
useful for that, but I fear it's probably too huge by the time you hit
the bug.

(The following warning ("rcu_sched self-detected stall") looks like the
result of BUGing while holding file_lock_lock.  That BUG should probably
be downgraded to a WARN_ON_ONCE.)

--b.

> 
> 2013-03-24T17:33:16.380+01:00 n22 kernel: ------------[ cut here ]------------
> 2013-03-24T17:33:16.380+01:00 n22 kernel: kernel BUG at fs/locks.c:2093!
> 2013-03-24T17:33:16.380+01:00 n22 kernel: invalid opcode: 0000 [#1] SMP
> 2013-03-24T17:33:16.380+01:00 n22 kernel: Modules linked in: rc_dib0700_rc5 dvb_usb_dib0700 dib3000mc dib8000 dvb_usb dib0070 dib7000m dib7000p dvb_core dibx000_common dib0090 rc_core md5 nfsd auth_rpcgss ipt_MASQUERADE xt_owner xt_multiport ipt_REJECT xt_tcpudp xt_recent xt_conntrack nf_conntrack_ftp xt_limit xt_LOG iptable_nat nf_conntrack_ipv4 nf_defrag_ipv4 nf_nat_ipv4 nf_nat nf_conntrack iptable_filter ip_tables x_tables af_packet pppoe pppox ppp_generic slhc bridge stp llc tun msr i915 cfbfillrect cfbimgblt i2c_algo_bit cfbcopyarea intel_agp coretemp intel_gtt fbcon snd_hda_codec_conexant snd_hda_intel snd_hda_codec snd_pcm sdhci_pci acpi_cpufreq bitblit mperf softcursor font drm_kms_helper uvcvideo thinkpad_acpi drm arc4 iwldvm mac80211 sdhci videobuf2_vmalloc videobuf2_memops videobuf2_core agpgart videodev kvm_intel kvm processor i2c_i801 usblp iwlwifi cfg80211 thermal video nvram snd_page_alloc mmc_core snd_timer thermal_sys fb fbdev rfkill i2c_core snd hwmon e10!
 00e 8250_pci
>  8250_core serial_core soundcore tpm_tis tpm psmouse tpm_bios button ac evdev battery wmi aesni_intel ablk_helper cryptd lrw aes_i586 xts gf128mul cbc sha256_generic fuse nfs lockd sunrpc dm_crypt dm_mod hid_monterey hid_microsoft hid_logitech hid_ezkey hid_cypress hid_chicony hid_cherry hid_belkin hid_apple hid_a4tech hid_generic usbhid hid sr_mod cdrom sg [last unloaded: microcode]
> 2013-03-24T17:33:16.380+01:00 n22 kernel: Pid: 58, comm: kworker/3:1 Not tainted 3.8.4 #7 LENOVO 4180F65/4180F65
> 2013-03-24T17:33:16.380+01:00 n22 kernel: EIP: 0060:[<c11600c9>] EFLAGS: 00010246 CPU: 3
> 2013-03-24T17:33:16.380+01:00 n22 kernel: EIP is at locks_remove_flock+0xe9/0xf0
> 2013-03-24T17:33:16.380+01:00 n22 kernel: EAX: 00000001 EBX: e6c7f3c0 ECX: 0000002a EDX: 00002a2a
> 2013-03-24T17:33:16.380+01:00 n22 kernel: ESI: f1f6de88 EDI: e241f880 EBP: f190bec0 ESP: f190be44
> 2013-03-24T17:33:16.380+01:00 n22 kernel: DS: 007b ES: 007b FS: 00d8 GS: 00e0 SS: 0068
> 2013-03-24T17:33:16.382+01:00 n22 kernel: CR0: 80050033 CR2: 402f6060 CR3: 2140e000 CR4: 000407f0
> 2013-03-24T17:33:16.382+01:00 n22 kernel: DR0: 00000000 DR1: 00000000 DR2: 00000000 DR3: 00000000
> 2013-03-24T17:33:16.382+01:00 n22 kernel: DR6: ffff0ff0 DR7: 00000400
> 2013-03-24T17:33:16.382+01:00 n22 kernel: Process kworker/3:1 (pid: 58, ti=f190a000 task=f2124ec0 task.ti=f190a000)
> 2013-03-24T17:33:16.382+01:00 n22 kernel: Stack:
> 2013-03-24T17:33:16.382+01:00 n22 kernel: f1f6ddc8 f190be70 c1065355 f190be84 f37e0100 000062de 00000000 eddeba20
> 2013-03-24T17:33:16.382+01:00 n22 kernel: f37e0100 f2124ec0 f37e0100 0000000a ec84fa28 c13d6fc0 e17e6074 ec84fa00
> 2013-03-24T17:33:16.382+01:00 n22 kernel: e17e607c f190be9c c1066011 ec84fa00 e17e6074 e6c7f3c8 f1f6ddc8 00000008
> 2013-03-24T17:33:16.382+01:00 n22 kernel: Call Trace:
> 2013-03-24T17:33:16.382+01:00 n22 kernel: [<c1065355>] ? sched_clock_cpu+0xf5/0x160
> 2013-03-24T17:33:16.383+01:00 n22 kernel: [<c1066011>] ? set_next_entity+0x31/0x80
> 2013-03-24T17:33:16.383+01:00 n22 kernel: [<c111df59>] __fput+0x79/0x1f0
> 2013-03-24T17:33:16.383+01:00 n22 kernel: [<c111e15c>] delayed_fput+0x7c/0x90
> 2013-03-24T17:33:16.383+01:00 n22 kernel: [<c104d992>] process_one_work+0x132/0x3a0
> 2013-03-24T17:33:16.383+01:00 n22 kernel: [<c104f211>] worker_thread+0x121/0x350
> 2013-03-24T17:33:16.383+01:00 n22 kernel: [<c104f0f0>] ? manage_workers+0x270/0x270
> 2013-03-24T17:33:16.383+01:00 n22 kernel: [<c1053974>] kthread+0x94/0xa0
> 2013-03-24T17:33:16.383+01:00 n22 kernel: [<c13d0677>] ret_from_kernel_thread+0x1b/0x28
> 2013-03-24T17:33:16.383+01:00 n22 kernel: [<c10538e0>] ? flush_kthread_work+0xd0/0xd0
> 2013-03-24T17:33:16.383+01:00 n22 kernel: Code: f0 e8 6c de ff ff 8b 06 85 c0 75 de 8d b6 00 00 00 00 80 05 84 56 62 c1 01 83 c4 70 5b 5e 5f 5d c3 90 89 f0 e8 f9 dd ff ff eb b9 <0f> 0b 90 90 90 90 90 55 89 e5 53 81 ec 8c 00 00 00 66 66 66 66
> 2013-03-24T17:33:16.384+01:00 n22 kernel: EIP: [<c11600c9>] locks_remove_flock+0xe9/0xf0 SS:ESP 0068:f190be44
> 2013-03-24T17:33:16.384+01:00 n22 kernel: ---[ end trace 77babad7e3f33561 ]---
> 2013-03-24T17:34:16.406+01:00 n22 kernel: INFO: rcu_sched self-detected stall on CPU { 3}  (t=60000 jiffies g=753704 c=753703 q=3091)
> 2013-03-24T17:34:16.406+01:00 n22 kernel: Pid: 11464, comm: nfsd Tainted: G      D      3.8.4 #7
> 2013-03-24T17:34:16.406+01:00 n22 kernel: Call Trace:
> 2013-03-24T17:34:16.406+01:00 n22 kernel: [<c10a8d5b>] rcu_check_callbacks+0x1cb/0x680
> 2013-03-24T17:34:16.406+01:00 n22 kernel: [<c104384b>] update_process_times+0x3b/0x70
> 2013-03-24T17:34:16.406+01:00 n22 kernel: [<c1081745>] tick_sched_timer+0x65/0xa0
> 2013-03-24T17:34:16.406+01:00 n22 kernel: [<c1057450>] ? __remove_hrtimer+0x40/0xa0
> 2013-03-24T17:34:16.406+01:00 n22 kernel: [<c1057903>] __run_hrtimer+0x73/0x1a0
> 2013-03-24T17:34:16.406+01:00 n22 kernel: [<c10816e0>] ? tick_nohz_handler+0xe0/0xe0
> 2013-03-24T17:34:16.406+01:00 n22 kernel: [<c1058538>] hrtimer_interrupt+0xf8/0x2d0
> 2013-03-24T17:34:16.406+01:00 n22 kernel: [<c13d0e24>] smp_apic_timer_interrupt+0x54/0x88
> 2013-03-24T17:34:16.406+01:00 n22 kernel: [<c103bbcc>] ? irq_exit+0x5c/0xa0
> 2013-03-24T17:34:16.406+01:00 n22 kernel: [<c13d0200>] apic_timer_interrupt+0x34/0x3c
> 2013-03-24T17:34:16.406+01:00 n22 kernel: [<c13cfd52>] ? _raw_spin_lock+0x22/0x30
> 2013-03-24T17:34:16.406+01:00 n22 kernel: [<c115db42>] lock_flocks+0x12/0x20
> 2013-03-24T17:34:16.406+01:00 n22 kernel: [<f8c31c23>] check_for_locks.isra.64+0x13/0x60 [nfsd]
> 2013-03-24T17:34:16.406+01:00 n22 kernel: [<f8c377f8>] nfsd4_release_lockowner+0x168/0x1f0 [nfsd]
> 2013-03-24T17:34:16.406+01:00 n22 kernel: [<f8c37690>] ? nfsd4_locku+0x2e0/0x2e0 [nfsd]
> 2013-03-24T17:34:16.406+01:00 n22 kernel: [<f8c2894b>] nfsd4_proc_compound+0x41b/0x530 [nfsd]
> 2013-03-24T17:34:16.406+01:00 n22 kernel: [<f8c1aba0>] nfsd_dispatch+0xa0/0x1b0 [nfsd]
> 2013-03-24T17:34:16.407+01:00 n22 kernel: [<f857b8a8>] svc_process+0x3f8/0x6d0 [sunrpc]
> 2013-03-24T17:34:16.407+01:00 n22 kernel: [<f8586d5e>] ? svc_xprt_received+0x3e/0x80 [sunrpc]
> 2013-03-24T17:34:16.407+01:00 n22 kernel: [<f85879e1>] ? svc_recv+0x2d1/0x3c0 [sunrpc]
> 2013-03-24T17:34:16.407+01:00 n22 kernel: [<f8c1a65d>] nfsd+0xad/0x110 [nfsd]
> 2013-03-24T17:34:16.407+01:00 n22 kernel: [<f8c1a5b0>] ? nfsd_destroy+0x70/0x70 [nfsd]
> 2013-03-24T17:34:16.407+01:00 n22 kernel: [<c1053974>] kthread+0x94/0xa0
> 2013-03-24T17:34:16.407+01:00 n22 kernel: [<c13d0677>] ret_from_kernel_thread+0x1b/0x28
> 2013-03-24T17:34:16.407+01:00 n22 kernel: [<c10538e0>] ? flush_kthread_work+0xd0/0xd0
> 
> 
> -- 
> MfG/Sincerely
> Toralf Förster
> pgp finger print: 7B1A 07F4 EC82 0F90 D4C2 8936 872A E508 7DB6 9DA3
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
