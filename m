From: Ingo Molnar <mingo@elte.hu>
Subject: Re: 2.6.31-rc2 soft lockups; traces point at rpc_wake_up,
	nfs4_run_state_manager, bit_waitqueue
Date: Sun, 5 Jul 2009 10:12:25 +0200
Message-ID: <20090705081225.GA12783@elte.hu>
References: <87eisv7g5p.fsf@bulky.wgtn.ondioline.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org
To: Paul Collins <paul-dsjeNyW6Qm/D+ROgJ3VA+kB+6BGkLq7r@public.gmane.org>,
	Trond Myklebust <Trond.Myklebust@netapp.com>,
	linux-nfs@vger.kernel.org, Andy Adamson <andros@netapp.com>,
	Benny Halevy <bhalevy@panasas.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx3.mail.elte.hu ([157.181.1.138]:50763 "EHLO mx3.mail.elte.hu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752739AbZGEIMd convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 5 Jul 2009 04:12:33 -0400
In-Reply-To: <87eisv7g5p.fsf-5OL5Ig5HWxBLdt5/z87VRY6ehsQQaF5K@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

(added more Cc:s)

potential suspects are:

1f84603: Merge branch 'devel-for-2.6.31' into for-2.6.31
3f09df7: NFS: Ensure we always hold the BKL when dereferencing inode->i_flock
965b5d6: NFSv4: Handle more errors when recovering open file and locking state
34dc1ad: nfs41: increment_{open,lock}_seqid
78722e9: nfs41: only retry EXCHANGE_ID on recoverable errors
b4b8260: nfs41: get_clid_cred for EXCHANGE_ID
90a1661: nfs41: add a get_clid_cred function to nfs4_state_recovery_ops
591d71c: nfs41: establish sessions-based clientid
a7b7210: nfs41: introduce get_state_renewal_cred
8e69514f: nfs41: support minorversion 1 for nfs4_check_lease
c3fad1b: nfs41: add session reset to state manager
76db6d95: nfs41: add session setup to the state manager
c2e713d: nfs41: translate NFS4ERR_MINOR_VERS_MISMATCH to EPROTONOSUPPORT

In case the bug is in fs/nfs/nfs4proc.c you could perhaps do a 
pretty quick ~5 reboots bisection using:

   git bisect start fs/nfs/nfs4proc.c

	Ingo

* Paul Collins <paul-dsjeNyW6Qm/D+ROgJ3VA+kB+6BGkLq7r@public.gmane.org> wrote:

> I just tried 2.6.31-rc2 but I had to give up after a few minutes due to
> a bunch of soft lockups.  Quite a bunch of processes got stuck in D,
> including emacs starting up and xterms I was attempting to close.
> 
> Jul  5 18:36:51 bulky kernel: [  526.136006] BUG: soft lockup - CPU#0 stuck for 61s! [10.2.4.3-manage:3991]
> Jul  5 18:36:51 bulky kernel: [  526.136006] Modules linked in: des_generic hidp hid tun ipt_MASQUERADE iptable_nat nf_nat nf_conntrack_ipv4 nf_defrag_ipv4 xt_state nf_conntrack ipt_REJECT xt_tcpudp iptable_filter ip_tables x_tables bridge stp llc bnep sco rfcomm l2cap kvm_intel kvm acpi_cpufreq cpufreq_powersave cpufreq_stats cpufreq_userspace cpufreq_conservative rpcsec_gss_krb5 nfsd exportfs nfs lockd fscache nfs_acl auth_rpcgss sunrpc ext2 loop btusb bluetooth snd_hda_codec_conexant arc4 ecb snd_hda_intel snd_hda_codec iwlagn iwlcore snd_hwdep snd_pcm snd_seq snd_timer mac80211 thinkpad_acpi snd_seq_device led_class wmi psmouse cfg80211 serio_raw i2c_i801 snd evdev soundcore nvram rfkill snd_page_alloc ac battery button processor ext3 jbd mbcache sha256_generic aes_x86_64 aes_generic
  cbc dm_crypt dm_mirror dm_region_hash dm_log dm_snapshot dm_mod sd_mod crc_t10dif uhci_hcd ahci libata scsi_mod ehci_hcd e1000e thermal fan i915 i2c_algo_bit cfbcopyarea video thermal_sys output cfbimgblt cfbfillrect drm i2c_co
> Jul  5 18:36:51 bulky kernel: re intel_agp
> Jul  5 18:36:51 bulky kernel: [  526.136006] CPU 0:
> Jul  5 18:36:51 bulky kernel: [  526.136006] Modules linked in: des_generic hidp hid tun ipt_MASQUERADE iptable_nat nf_nat nf_conntrack_ipv4 nf_defrag_ipv4 xt_state nf_conntrack ipt_REJECT xt_tcpudp iptable_filter ip_tables x_tables bridge stp llc bnep sco rfcomm l2cap kvm_intel kvm acpi_cpufreq cpufreq_powersave cpufreq_stats cpufreq_userspace cpufreq_conservative rpcsec_gss_krb5 nfsd exportfs nfs lockd fscache nfs_acl auth_rpcgss sunrpc ext2 loop btusb bluetooth snd_hda_codec_conexant arc4 ecb snd_hda_intel snd_hda_codec iwlagn iwlcore snd_hwdep snd_pcm snd_seq snd_timer mac80211 thinkpad_acpi snd_seq_device led_class wmi psmouse cfg80211 serio_raw i2c_i801 snd evdev soundcore nvram rfkill snd_page_alloc ac battery button processor ext3 jbd mbcache sha256_generic aes_x86_64 aes_generic
  cbc dm_crypt dm_mirror dm_region_hash dm_log dm_snapshot dm_mod sd_mod crc_t10dif uhci_hcd ahci libata scsi_mod ehci_hcd e1000e thermal fan i915 i2c_algo_bit cfbcopyarea video thermal_sys output cfbimgblt cfbfillrect drm i2c_co
> Jul  5 18:36:51 bulky kernel: re intel_agp
> Jul  5 18:36:51 bulky kernel: [  526.136006] Pid: 3991, comm: 10.2.4.3-manage Not tainted 2.6.31-rc2 #1 7454CTO
> Jul  5 18:36:51 bulky kernel: [  526.136006] RIP: 0010:[<ffffffffa036394f>]  [<ffffffffa036394f>] rpc_wake_up+0x27/0x7a [sunrpc]
> Jul  5 18:36:51 bulky kernel: [  526.136006] RSP: 0018:ffff880113573e80  EFLAGS: 00000246
> Jul  5 18:36:51 bulky kernel: [  526.136006] RAX: ffff880127c2b1b0 RBX: ffff880127c2b1a8 RCX: ffffffffffffffcf
> Jul  5 18:36:51 bulky kernel: [  526.136006] RDX: 0000000000002151 RSI: ffff880127c2b0f0 RDI: ffff880127c2b1a8
> Jul  5 18:36:51 bulky kernel: [  526.136006] RBP: ffffffff810115ae R08: 0000000000000000 R09: 0000000000000000
> Jul  5 18:36:51 bulky kernel: [  526.136006] R10: ffff880028026f18 R11: ffff880028026f18 R12: ffffffffffffffcf
> Jul  5 18:36:51 bulky kernel: [  526.136006] R13: 0000000000000000 R14: ffff880028026f18 R15: ffff880028026f18
> Jul  5 18:36:51 bulky kernel: [  526.136006] FS:  0000000000000000(0000) GS:ffff880028023000(0000) knlGS:0000000000000000
> Jul  5 18:36:51 bulky kernel: [  526.136006] CS:  0010 DS: 0018 ES: 0018 CR0: 000000008005003b
> Jul  5 18:36:51 bulky kernel: [  526.136006] CR2: 0000000001ff3930 CR3: 0000000001001000 CR4: 00000000000426e0
> Jul  5 18:36:51 bulky kernel: [  526.136006] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
> Jul  5 18:36:51 bulky kernel: [  526.136006] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
> Jul  5 18:36:51 bulky kernel: [  526.136006] Call Trace:
> Jul  5 18:36:51 bulky kernel: [  526.136006]  [<ffffffffa03dec0f>] ? nfs4_run_state_manager+0x232/0x2a1 [nfs]
> Jul  5 18:36:51 bulky kernel: [  526.136006]  [<ffffffffa03de9dd>] ? nfs4_run_state_manager+0x0/0x2a1 [nfs]
> Jul  5 18:36:51 bulky kernel: [  526.136006]  [<ffffffff8105d797>] ? kthread+0x84/0x8c
> Jul  5 18:36:51 bulky kernel: [  526.136006]  [<ffffffff81011aea>] ? child_rip+0xa/0x20
> Jul  5 18:36:51 bulky kernel: [  526.136006]  [<ffffffffa039008a>] ? gss_unwrap_resp+0x0/0x1c4 [auth_rpcgss]
> Jul  5 18:36:51 bulky kernel: [  526.136006]  [<ffffffff8105d713>] ? kthread+0x0/0x8c
> Jul  5 18:36:51 bulky kernel: [  526.136006]  [<ffffffff81011ae0>] ? child_rip+0x0/0x20
> Jul  5 18:37:57 bulky kernel: [  591.632007] BUG: soft lockup - CPU#0 stuck for 61s! [10.2.4.3-manage:3991]
> Jul  5 18:37:57 bulky kernel: [  591.632008] Modules linked in: des_generic hidp hid tun ipt_MASQUERADE iptable_nat nf_nat nf_conntrack_ipv4 nf_defrag_ipv4 xt_state nf_conntrack ipt_REJECT xt_tcpudp iptable_filter ip_tables x_tables bridge stp llc bnep sco rfcomm l2cap kvm_intel kvm acpi_cpufreq cpufreq_powersave cpufreq_stats cpufreq_userspace cpufreq_conservative rpcsec_gss_krb5 nfsd exportfs nfs lockd fscache nfs_acl auth_rpcgss sunrpc ext2 loop btusb bluetooth snd_hda_codec_conexant arc4 ecb snd_hda_intel snd_hda_codec iwlagn iwlcore snd_hwdep snd_pcm snd_seq snd_timer mac80211 thinkpad_acpi snd_seq_device led_class wmi psmouse cfg80211 serio_raw i2c_i801 snd evdev soundcore nvram rfkill snd_page_alloc ac battery button processor ext3 jbd mbcache sha256_generic aes_x86_64 aes_generic
  cbc dm_crypt dm_mirror dm_region_hash dm_log dm_snapshot dm_mod sd_mod crc_t10dif uhci_hcd ahci libata scsi_mod ehci_hcd e1000e thermal fan i915 i2c_algo_bit cfbcopyarea video thermal_sys output cfbimgblt cfbfillrect drm i2c_co
> Jul  5 18:37:57 bulky kernel: re intel_agp
> Jul  5 18:37:57 bulky kernel: [  591.632008] CPU 0:
> Jul  5 18:37:57 bulky kernel: [  591.632008] Modules linked in: des_generic hidp hid tun ipt_MASQUERADE iptable_nat nf_nat nf_conntrack_ipv4 nf_defrag_ipv4 xt_state nf_conntrack ipt_REJECT xt_tcpudp iptable_filter ip_tables x_tables bridge stp llc bnep sco rfcomm l2cap kvm_intel kvm acpi_cpufreq cpufreq_powersave cpufreq_stats cpufreq_userspace cpufreq_conservative rpcsec_gss_krb5 nfsd exportfs nfs lockd fscache nfs_acl auth_rpcgss sunrpc ext2 loop btusb bluetooth snd_hda_codec_conexant arc4 ecb snd_hda_intel snd_hda_codec iwlagn iwlcore snd_hwdep snd_pcm snd_seq snd_timer mac80211 thinkpad_acpi snd_seq_device led_class wmi psmouse cfg80211 serio_raw i2c_i801 snd evdev soundcore nvram rfkill snd_page_alloc ac battery button processor ext3 jbd mbcache sha256_generic aes_x86_64 aes_generic
  cbc dm_crypt dm_mirror dm_region_hash dm_log dm_snapshot dm_mod sd_mod crc_t10dif uhci_hcd ahci libata scsi_mod ehci_hcd e1000e thermal fan i915 i2c_algo_bit cfbcopyarea video thermal_sys output cfbimgblt cfbfillrect drm i2c_co
> Jul  5 18:37:57 bulky kernel: re intel_agp
> Jul  5 18:37:57 bulky kernel: [  591.632008] Pid: 3991, comm: 10.2.4.3-manage Not tainted 2.6.31-rc2 #1 7454CTO
> Jul  5 18:37:57 bulky kernel: [  591.632008] RIP: 0010:[<ffffffffa03dec20>]  [<ffffffffa03dec20>] nfs4_run_state_manager+0x243/0x2a1 [nfs]
> Jul  5 18:37:57 bulky kernel: [  591.632008] RSP: 0018:ffff880113573eb0  EFLAGS: 00000202
> Jul  5 18:37:57 bulky kernel: [  591.632008] RAX: ffff880127c2b0f0 RBX: ffff880127c2b000 RCX: 0000000000000010
> Jul  5 18:37:57 bulky kernel: [  591.632008] RDX: 0000000000009b11 RSI: ffff880127c2b108 RDI: ffffffffa03dec0f
> Jul  5 18:37:57 bulky kernel: [  591.632008] RBP: ffffffff810115ae R08: 0000000000000010 R09: 0000000000000000
> Jul  5 18:37:57 bulky kernel: [  591.632008] R10: ffff880136de4000 R11: 0000000000000040 R12: ffff880127c2b000
> Jul  5 18:37:57 bulky kernel: [  591.632008] R13: ffffffff8101140e R14: ffff880127c2b1a8 R15: ffffffff8101140e
> Jul  5 18:37:57 bulky kernel: [  591.632008] FS:  0000000000000000(0000) GS:ffff880028023000(0000) knlGS:0000000000000000
> Jul  5 18:37:57 bulky kernel: [  591.632008] CS:  0010 DS: 0018 ES: 0018 CR0: 000000008005003b
> Jul  5 18:37:57 bulky kernel: [  591.632008] CR2: 0000000001ff3930 CR3: 0000000001001000 CR4: 00000000000426e0
> Jul  5 18:37:57 bulky kernel: [  591.632008] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
> Jul  5 18:37:57 bulky kernel: [  591.632008] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
> Jul  5 18:37:57 bulky kernel: [  591.632008] Call Trace:
> Jul  5 18:37:57 bulky kernel: [  591.632008]  [<ffffffffa03de9dd>] ? nfs4_run_state_manager+0x0/0x2a1 [nfs]
> Jul  5 18:37:57 bulky kernel: [  591.632008]  [<ffffffff8105d797>] ? kthread+0x84/0x8c
> Jul  5 18:37:57 bulky kernel: [  591.632008]  [<ffffffff81011aea>] ? child_rip+0xa/0x20
> Jul  5 18:37:57 bulky kernel: [  591.632008]  [<ffffffffa039008a>] ? gss_unwrap_resp+0x0/0x1c4 [auth_rpcgss]
> Jul  5 18:37:57 bulky kernel: [  591.632008]  [<ffffffff8105d713>] ? kthread+0x0/0x8c
> Jul  5 18:37:57 bulky kernel: [  591.632008]  [<ffffffff81011ae0>] ? child_rip+0x0/0x20
> Jul  5 18:39:01 bulky kernel: [  657.132006] BUG: soft lockup - CPU#0 stuck for 61s! [10.2.4.3-manage:3991]
> Jul  5 18:39:01 bulky kernel: [  657.132006] Modules linked in: des_generic hidp hid tun ipt_MASQUERADE iptable_nat nf_nat nf_conntrack_ipv4 nf_defrag_ipv4 xt_state nf_conntrack ipt_REJECT xt_tcpudp iptable_filter ip_tables x_tables bridge stp llc bnep sco rfcomm l2cap kvm_intel kvm acpi_cpufreq cpufreq_powersave cpufreq_stats cpufreq_userspace cpufreq_conservative rpcsec_gss_krb5 nfsd exportfs nfs lockd fscache nfs_acl auth_rpcgss sunrpc ext2 loop btusb bluetooth snd_hda_codec_conexant arc4 ecb snd_hda_intel snd_hda_codec iwlagn iwlcore snd_hwdep snd_pcm snd_seq snd_timer mac80211 thinkpad_acpi snd_seq_device led_class wmi psmouse cfg80211 serio_raw i2c_i801 snd evdev soundcore nvram rfkill snd_page_alloc ac battery button processor ext3 jbd mbcache sha256_generic aes_x86_64 aes_generic
  cbc dm_crypt dm_mirror dm_region_hash dm_log dm_snapshot dm_mod sd_mod crc_t10dif uhci_hcd ahci libata scsi_mod ehci_hcd e1000e thermal fan i915 i2c_algo_bit cfbcopyarea video thermal_sys output cfbimgblt cfbfillrect drm i2c_co
> Jul  5 18:39:01 bulky kernel: re intel_agp
> Jul  5 18:39:01 bulky kernel: [  657.132006] CPU 0:
> Jul  5 18:39:01 bulky kernel: [  657.132006] Modules linked in: des_generic hidp hid tun ipt_MASQUERADE iptable_nat nf_nat nf_conntrack_ipv4 nf_defrag_ipv4 xt_state nf_conntrack ipt_REJECT xt_tcpudp iptable_filter ip_tables x_tables bridge stp llc bnep sco rfcomm l2cap kvm_intel kvm acpi_cpufreq cpufreq_powersave cpufreq_stats cpufreq_userspace cpufreq_conservative rpcsec_gss_krb5 nfsd exportfs nfs lockd fscache nfs_acl auth_rpcgss sunrpc ext2 loop btusb bluetooth snd_hda_codec_conexant arc4 ecb snd_hda_intel snd_hda_codec iwlagn iwlcore snd_hwdep snd_pcm snd_seq snd_timer mac80211 thinkpad_acpi snd_seq_device led_class wmi psmouse cfg80211 serio_raw i2c_i801 snd evdev soundcore nvram rfkill snd_page_alloc ac battery button processor ext3 jbd mbcache sha256_generic aes_x86_64 aes_generic
  cbc dm_crypt dm_mirror dm_region_hash dm_log dm_snapshot dm_mod sd_mod crc_t10dif uhci_hcd ahci libata scsi_mod ehci_hcd e1000e thermal fan i915 i2c_algo_bit cfbcopyarea video thermal_sys output cfbimgblt cfbfillrect drm i2c_co
> Jul  5 18:39:01 bulky kernel: re intel_agp
> Jul  5 18:39:01 bulky kernel: [  657.132006] Pid: 3991, comm: 10.2.4.3-manage Not tainted 2.6.31-rc2 #1 7454CTO
> Jul  5 18:39:01 bulky kernel: [  657.132006] RIP: 0010:[<ffffffffa03debf4>]  [<ffffffffa03debf4>] nfs4_run_state_manager+0x217/0x2a1 [nfs]
> Jul  5 18:39:01 bulky kernel: [  657.132006] RSP: 0018:ffff880113573eb0  EFLAGS: 00000246
> Jul  5 18:39:01 bulky kernel: [  657.132006] RAX: 0000000000000000 RBX: ffff880127c2b000 RCX: ffff880113573e98
> Jul  5 18:39:01 bulky kernel: [  657.132006] RDX: 000000000000cec9 RSI: ffff880127c2b108 RDI: ffffffffa03dec0f
> Jul  5 18:39:01 bulky kernel: [  657.132006] RBP: ffffffff810115ae R08: ffff880113573e98 R09: 0000000000000000
> Jul  5 18:39:01 bulky kernel: [  657.132006] R10: ffff880028026f18 R11: ffff880028026f18 R12: ffff880028026f18
> Jul  5 18:39:01 bulky kernel: [  657.132006] R13: ffff880028026f18 R14: ffff880127c2b000 R15: ffffffff8101178e
> Jul  5 18:39:01 bulky kernel: [  657.132006] FS:  0000000000000000(0000) GS:ffff880028023000(0000) knlGS:0000000000000000
> Jul  5 18:39:01 bulky kernel: [  657.132006] CS:  0010 DS: 0018 ES: 0018 CR0: 000000008005003b
> Jul  5 18:39:01 bulky kernel: [  657.132006] CR2: 0000000001ff3930 CR3: 0000000001001000 CR4: 00000000000426e0
> Jul  5 18:39:01 bulky kernel: [  657.132006] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
> Jul  5 18:39:01 bulky kernel: [  657.132006] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
> Jul  5 18:39:01 bulky kernel: [  657.132006] Call Trace:
> Jul  5 18:39:01 bulky kernel: [  657.132542]  [<ffffffffa03de9dd>] ? nfs4_run_state_manager+0x0/0x2a1 [nfs]
> Jul  5 18:39:01 bulky kernel: [  657.132542]  [<ffffffff8105d797>] ? kthread+0x84/0x8c
> Jul  5 18:39:01 bulky kernel: [  657.132542]  [<ffffffff81011aea>] ? child_rip+0xa/0x20
> Jul  5 18:39:01 bulky kernel: [  657.132542]  [<ffffffffa039008a>] ? gss_unwrap_resp+0x0/0x1c4 [auth_rpcgss]
> Jul  5 18:39:01 bulky kernel: [  657.132542]  [<ffffffff8105d713>] ? kthread+0x0/0x8c
> Jul  5 18:39:01 bulky kernel: [  657.132542]  [<ffffffff81011ae0>] ? child_rip+0x0/0x20
> Jul  5 18:40:07 bulky kernel: [  722.632006] BUG: soft lockup - CPU#0 stuck for 61s! [10.2.4.3-manage:3991]
> Jul  5 18:40:07 bulky kernel: [  722.632006] Modules linked in: des_generic hidp hid tun ipt_MASQUERADE iptable_nat nf_nat nf_conntrack_ipv4 nf_defrag_ipv4 xt_state nf_conntrack ipt_REJECT xt_tcpudp iptable_filter ip_tables x_tables bridge stp llc bnep sco rfcomm l2cap kvm_intel kvm acpi_cpufreq cpufreq_powersave cpufreq_stats cpufreq_userspace cpufreq_conservative rpcsec_gss_krb5 nfsd exportfs nfs lockd fscache nfs_acl auth_rpcgss sunrpc ext2 loop btusb bluetooth snd_hda_codec_conexant arc4 ecb snd_hda_intel snd_hda_codec iwlagn iwlcore snd_hwdep snd_pcm snd_seq snd_timer mac80211 thinkpad_acpi snd_seq_device led_class wmi psmouse cfg80211 serio_raw i2c_i801 snd evdev soundcore nvram rfkill snd_page_alloc ac battery button processor ext3 jbd mbcache sha256_generic aes_x86_64 aes_generic
  cbc dm_crypt dm_mirror dm_region_hash dm_log dm_snapshot dm_mod sd_mod crc_t10dif uhci_hcd ahci libata scsi_mod ehci_hcd e1000e thermal fan i915 i2c_algo_bit cfbcopyarea video thermal_sys output cfbimgblt cfbfillrect drm i2c_co
> Jul  5 18:40:07 bulky kernel: re intel_agp
> Jul  5 18:40:07 bulky kernel: [  722.632006] CPU 0:
> Jul  5 18:40:07 bulky kernel: [  722.632006] Modules linked in: des_generic hidp hid tun ipt_MASQUERADE iptable_nat nf_nat nf_conntrack_ipv4 nf_defrag_ipv4 xt_state nf_conntrack ipt_REJECT xt_tcpudp iptable_filter ip_tables x_tables bridge stp llc bnep sco rfcomm l2cap kvm_intel kvm acpi_cpufreq cpufreq_powersave cpufreq_stats cpufreq_userspace cpufreq_conservative rpcsec_gss_krb5 nfsd exportfs nfs lockd fscache nfs_acl auth_rpcgss sunrpc ext2 loop btusb bluetooth snd_hda_codec_conexant arc4 ecb snd_hda_intel snd_hda_codec iwlagn iwlcore snd_hwdep snd_pcm snd_seq snd_timer mac80211 thinkpad_acpi snd_seq_device led_class wmi psmouse cfg80211 serio_raw i2c_i801 snd evdev soundcore nvram rfkill snd_page_alloc ac battery button processor ext3 jbd mbcache sha256_generic aes_x86_64 aes_generic
  cbc dm_crypt dm_mirror dm_region_hash dm_log dm_snapshot dm_mod sd_mod crc_t10dif uhci_hcd ahci libata scsi_mod ehci_hcd e1000e thermal fan i915 i2c_algo_bit cfbcopyarea video thermal_sys output cfbimgblt cfbfillrect drm i2c_co
> Jul  5 18:40:07 bulky kernel: re intel_agp
> Jul  5 18:40:07 bulky kernel: [  722.632006] Pid: 3991, comm: 10.2.4.3-manage Not tainted 2.6.31-rc2 #1 7454CTO
> Jul  5 18:40:07 bulky kernel: [  722.632006] RIP: 0010:[<ffffffffa0363984>]  [<ffffffffa0363984>] rpc_wake_up+0x5c/0x7a [sunrpc]
> Jul  5 18:40:07 bulky kernel: [  722.632006] RSP: 0018:ffff880113573e80  EFLAGS: 00000246
> Jul  5 18:40:07 bulky kernel: [  722.632006] RAX: ffff880127c2b1b0 RBX: ffff880127c2b1a8 RCX: ffffffffffffff46
> Jul  5 18:40:07 bulky kernel: [  722.632006] RDX: 0000000000004a07 RSI: ffff880127c2b108 RDI: ffff880127c2b1a8
> Jul  5 18:40:07 bulky kernel: [  722.632006] RBP: ffffffff810115ae R08: 0000000000000000 R09: 0000000000000000
> Jul  5 18:40:07 bulky kernel: [  722.632006] R10: ffff880028026f18 R11: ffff880028026f18 R12: ffff880127c2b1a8
> Jul  5 18:40:07 bulky kernel: [  722.632006] R13: ffffffff8101140e R14: 0000000000000000 R15: ffffffff810115ae
> Jul  5 18:40:07 bulky kernel: [  722.632006] FS:  0000000000000000(0000) GS:ffff880028023000(0000) knlGS:0000000000000000
> Jul  5 18:40:07 bulky kernel: [  722.632006] CS:  0010 DS: 0018 ES: 0018 CR0: 000000008005003b
> Jul  5 18:40:07 bulky kernel: [  722.632006] CR2: 0000000001ff3930 CR3: 0000000001001000 CR4: 00000000000426e0
> Jul  5 18:40:07 bulky kernel: [  722.632006] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
> Jul  5 18:40:07 bulky kernel: [  722.632006] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
> Jul  5 18:40:07 bulky kernel: [  722.632006] Call Trace:
> Jul  5 18:40:07 bulky kernel: [  722.632006]  [<ffffffffa03dec0f>] ? nfs4_run_state_manager+0x232/0x2a1 [nfs]
> Jul  5 18:40:07 bulky kernel: [  722.632006]  [<ffffffffa03de9dd>] ? nfs4_run_state_manager+0x0/0x2a1 [nfs]
> Jul  5 18:40:07 bulky kernel: [  722.632006]  [<ffffffff8105d797>] ? kthread+0x84/0x8c
> Jul  5 18:40:07 bulky kernel: [  722.632006]  [<ffffffff81011aea>] ? child_rip+0xa/0x20
> Jul  5 18:40:07 bulky kernel: [  722.632006]  [<ffffffffa039008a>] ? gss_unwrap_resp+0x0/0x1c4 [auth_rpcgss]
> Jul  5 18:40:07 bulky kernel: [  722.632006]  [<ffffffff8105d713>] ? kthread+0x0/0x8c
> Jul  5 18:40:07 bulky kernel: [  722.632006]  [<ffffffff81011ae0>] ? child_rip+0x0/0x20
> Jul  5 18:41:12 bulky kernel: [  788.128005] BUG: soft lockup - CPU#0 stuck for 61s! [10.2.4.3-manage:3991]
> Jul  5 18:41:12 bulky kernel: [  788.128006] Modules linked in: des_generic hidp hid tun ipt_MASQUERADE iptable_nat nf_nat nf_conntrack_ipv4 nf_defrag_ipv4 xt_state nf_conntrack ipt_REJECT xt_tcpudp iptable_filter ip_tables x_tables bridge stp llc bnep sco rfcomm l2cap kvm_intel kvm acpi_cpufreq cpufreq_powersave cpufreq_stats cpufreq_userspace cpufreq_conservative rpcsec_gss_krb5 nfsd exportfs nfs lockd fscache nfs_acl auth_rpcgss sunrpc ext2 loop btusb bluetooth snd_hda_codec_conexant arc4 ecb snd_hda_intel snd_hda_codec iwlagn iwlcore snd_hwdep snd_pcm snd_seq snd_timer mac80211 thinkpad_acpi snd_seq_device led_class wmi psmouse cfg80211 serio_raw i2c_i801 snd evdev soundcore nvram rfkill snd_page_alloc ac battery button processor ext3 jbd mbcache sha256_generic aes_x86_64 aes_generic
  cbc dm_crypt dm_mirror dm_region_hash dm_log dm_snapshot dm_mod sd_mod crc_t10dif uhci_hcd ahci libata scsi_mod ehci_hcd e1000e thermal fan i915 i2c_algo_bit cfbcopyarea video thermal_sys output cfbimgblt cfbfillrect drm i2c_co
> Jul  5 18:41:12 bulky kernel: re intel_agp
> Jul  5 18:41:12 bulky kernel: [  788.128006] CPU 0:
> Jul  5 18:41:12 bulky kernel: [  788.128006] Modules linked in: des_generic hidp hid tun ipt_MASQUERADE iptable_nat nf_nat nf_conntrack_ipv4 nf_defrag_ipv4 xt_state nf_conntrack ipt_REJECT xt_tcpudp iptable_filter ip_tables x_tables bridge stp llc bnep sco rfcomm l2cap kvm_intel kvm acpi_cpufreq cpufreq_powersave cpufreq_stats cpufreq_userspace cpufreq_conservative rpcsec_gss_krb5 nfsd exportfs nfs lockd fscache nfs_acl auth_rpcgss sunrpc ext2 loop btusb bluetooth snd_hda_codec_conexant arc4 ecb snd_hda_intel snd_hda_codec iwlagn iwlcore snd_hwdep snd_pcm snd_seq snd_timer mac80211 thinkpad_acpi snd_seq_device led_class wmi psmouse cfg80211 serio_raw i2c_i801 snd evdev soundcore nvram rfkill snd_page_alloc ac battery button processor ext3 jbd mbcache sha256_generic aes_x86_64 aes_generic
  cbc dm_crypt dm_mirror dm_region_hash dm_log dm_snapshot dm_mod sd_mod crc_t10dif uhci_hcd ahci libata scsi_mod ehci_hcd e1000e thermal fan i915 i2c_algo_bit cfbcopyarea video thermal_sys output cfbimgblt cfbfillrect drm i2c_co
> Jul  5 18:41:12 bulky kernel: re intel_agp
> Jul  5 18:41:12 bulky kernel: [  788.128006] Pid: 3991, comm: 10.2.4.3-manage Not tainted 2.6.31-rc2 #1 7454CTO
> Jul  5 18:41:12 bulky kernel: [  788.128006] RIP: 0010:[<ffffffffa03dec20>]  [<ffffffffa03dec20>] nfs4_run_state_manager+0x243/0x2a1 [nfs]
> Jul  5 18:41:12 bulky kernel: [  788.128006] RSP: 0018:ffff880113573eb0  EFLAGS: 00000202
> Jul  5 18:41:12 bulky kernel: [  788.128006] RAX: ffff880127c2b0f0 RBX: ffff880127c2b000 RCX: ffffffffffffff10
> Jul  5 18:41:12 bulky kernel: [  788.128006] RDX: 000000000000ed8a RSI: ffff880127c2b108 RDI: ffffffffa03dec0f
> Jul  5 18:41:12 bulky kernel: [  788.128006] RBP: ffffffff810115ae R08: ffffffffffffff10 R09: 0000000000000000
> Jul  5 18:41:12 bulky kernel: [  788.128006] R10: ffff880028026f18 R11: ffff880028026f18 R12: 0000000000000000
> Jul  5 18:41:12 bulky kernel: [  788.128006] R13: 0000000000000002 R14: 0000000000000000 R15: 1eba3d9900ac3c00
> Jul  5 18:41:12 bulky kernel: [  788.128006] FS:  0000000000000000(0000) GS:ffff880028023000(0000) knlGS:0000000000000000
> Jul  5 18:41:12 bulky kernel: [  788.128006] CS:  0010 DS: 0018 ES: 0018 CR0: 000000008005003b
> Jul  5 18:41:12 bulky kernel: [  788.128006] CR2: 0000000001ff3930 CR3: 0000000001001000 CR4: 00000000000426e0
> Jul  5 18:41:12 bulky kernel: [  788.128006] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
> Jul  5 18:41:12 bulky kernel: [  788.128006] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
> Jul  5 18:41:12 bulky kernel: [  788.128006] Call Trace:
> Jul  5 18:41:12 bulky kernel: [  788.128538]  [<ffffffffa03de9dd>] ? nfs4_run_state_manager+0x0/0x2a1 [nfs]
> Jul  5 18:41:12 bulky kernel: [  788.128538]  [<ffffffff8105d797>] ? kthread+0x84/0x8c
> Jul  5 18:41:12 bulky kernel: [  788.128538]  [<ffffffff81011aea>] ? child_rip+0xa/0x20
> Jul  5 18:41:12 bulky kernel: [  788.128538]  [<ffffffffa039008a>] ? gss_unwrap_resp+0x0/0x1c4 [auth_rpcgss]
> Jul  5 18:41:12 bulky kernel: [  788.128538]  [<ffffffff8105d713>] ? kthread+0x0/0x8c
> Jul  5 18:41:12 bulky kernel: [  788.128538]  [<ffffffff81011ae0>] ? child_rip+0x0/0x20
> Jul  5 18:42:05 bulky kernel: [  840.396622] INFO: task apt-get:4011 blocked for more than 120 seconds.
> Jul  5 18:42:05 bulky kernel: [  840.396629] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
> Jul  5 18:42:05 bulky kernel: [  840.396635] apt-get       D ffff8800280547c0     0  4011   3824 0x00000000
> Jul  5 18:42:05 bulky kernel: [  840.396646]  ffff88013a4b8800 0000000000000082 ffff88013a4b8800 ffff880028055100
> Jul  5 18:42:05 bulky kernel: [  840.396656]  ffffffff81016fe3 00000000000147c0 000000000000f7f0 ffff88011353a800
> Jul  5 18:42:05 bulky kernel: [  840.396666]  ffff88011353aaf8 0000000181045646 0000000000000001 0000000000000046
> Jul  5 18:42:05 bulky kernel: [  840.396675] Call Trace:
> Jul  5 18:42:05 bulky kernel: [  840.396691]  [<ffffffff81016fe3>] ? sched_clock+0x5/0x8
> Jul  5 18:42:05 bulky kernel: [  840.396704]  [<ffffffff812d2b56>] ? schedule_timeout+0x1e/0xb8
> Jul  5 18:42:05 bulky kernel: [  840.396712]  [<ffffffff812d20b2>] ? wait_for_common+0xd7/0x148
> Jul  5 18:42:05 bulky kernel: [  840.396722]  [<ffffffff81045658>] ? default_wake_function+0x0/0x9
> Jul  5 18:42:05 bulky kernel: [  840.396731]  [<ffffffff8105a0a0>] ? flush_cpu_workqueue+0x6c/0x75
> Jul  5 18:42:05 bulky kernel: [  840.396739]  [<ffffffff8105a17b>] ? wq_barrier_func+0x0/0x9
> Jul  5 18:42:05 bulky kernel: [  840.396746]  [<ffffffff8105a273>] ? flush_workqueue+0x33/0x55
> Jul  5 18:42:05 bulky kernel: [  840.396755]  [<ffffffff811d4d60>] ? tty_ldisc_release+0x3f/0x7e
> Jul  5 18:42:05 bulky kernel: [  840.396765]  [<ffffffff811d0ae0>] ? tty_release_dev+0x45d/0x48e
> Jul  5 18:42:05 bulky kernel: [  840.396776]  [<ffffffff810e2dc2>] ? vfs_ioctl+0x21/0x6c
> Jul  5 18:42:05 bulky kernel: [  840.396783]  [<ffffffff811d0b22>] ? tty_release+0x11/0x1a
> Jul  5 18:42:05 bulky kernel: [  840.396792]  [<ffffffff810d8828>] ? __fput+0xe8/0x190
> Jul  5 18:42:05 bulky kernel: [  840.396799]  [<ffffffff810d5d26>] ? filp_close+0x5b/0x62
> Jul  5 18:42:05 bulky kernel: [  840.396807]  [<ffffffff810d5dc1>] ? sys_close+0x94/0xcd
> Jul  5 18:42:05 bulky kernel: [  840.396817]  [<ffffffff81010a02>] ? system_call_fastpath+0x16/0x1b
> Jul  5 18:42:05 bulky kernel: [  840.396824] INFO: task mcelog:4218 blocked for more than 120 seconds.
> Jul  5 18:42:05 bulky kernel: [  840.396829] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
> Jul  5 18:42:05 bulky kernel: [  840.396833] mcelog        D ffff8800280547c0     0  4218   4217 0x00000000
> Jul  5 18:42:05 bulky kernel: [  840.396843]  ffff88013a4710c0 0000000000000082 0000000100000041 0000000000000286
> Jul  5 18:42:05 bulky kernel: [  840.396852]  ffff880113532c00 00000000000147c0 000000000000f7f0 ffff8801105a4080
> Jul  5 18:42:05 bulky kernel: [  840.396862]  ffff8801105a4378 0000000100010808 000000024a504ac1 0000000000000000
> Jul  5 18:42:05 bulky kernel: [  840.396871] Call Trace:
> Jul  5 18:42:05 bulky kernel: [  840.396880]  [<ffffffff812d2b56>] ? schedule_timeout+0x1e/0xb8
> Jul  5 18:42:05 bulky kernel: [  840.396889]  [<ffffffff8108bc3f>] ? rcu_implicit_dynticks_qs+0x6c/0x91
> Jul  5 18:42:05 bulky kernel: [  840.396897]  [<ffffffff8108c1be>] ? rcu_process_dyntick+0xd2/0xf2
> Jul  5 18:42:05 bulky kernel: [  840.396904]  [<ffffffff8108bbd3>] ? rcu_implicit_dynticks_qs+0x0/0x91
> Jul  5 18:42:05 bulky kernel: [  840.396913]  [<ffffffff812d20b2>] ? wait_for_common+0xd7/0x148
> Jul  5 18:42:05 bulky kernel: [  840.396920]  [<ffffffff81045658>] ? default_wake_function+0x0/0x9
> Jul  5 18:42:05 bulky kernel: [  840.396929]  [<ffffffff8105bb4a>] ? synchronize_rcu+0x45/0x4b
> Jul  5 18:42:05 bulky kernel: [  840.396937]  [<ffffffff8105ba4c>] ? wakeme_after_rcu+0x0/0x9
> Jul  5 18:42:05 bulky kernel: [  840.396946]  [<ffffffff8101d6cf>] ? mce_read+0x12f/0x1d6
> Jul  5 18:42:05 bulky kernel: [  840.396954]  [<ffffffff810d8160>] ? vfs_read+0xa6/0xff
> Jul  5 18:42:05 bulky kernel: [  840.396961]  [<ffffffff810d8275>] ? sys_read+0x45/0x6e
> Jul  5 18:42:05 bulky kernel: [  840.396970]  [<ffffffff81010a02>] ? system_call_fastpath+0x16/0x1b
> Jul  5 18:42:18 bulky kernel: [  853.628005] BUG: soft lockup - CPU#0 stuck for 61s! [10.2.4.3-manage:3991]
> Jul  5 18:42:18 bulky kernel: [  853.628006] Modules linked in: des_generic hidp hid tun ipt_MASQUERADE iptable_nat nf_nat nf_conntrack_ipv4 nf_defrag_ipv4 xt_state nf_conntrack ipt_REJECT xt_tcpudp iptable_filter ip_tables x_tables bridge stp llc bnep sco rfcomm l2cap kvm_intel kvm acpi_cpufreq cpufreq_powersave cpufreq_stats cpufreq_userspace cpufreq_conservative rpcsec_gss_krb5 nfsd exportfs nfs lockd fscache nfs_acl auth_rpcgss sunrpc ext2 loop btusb bluetooth snd_hda_codec_conexant arc4 ecb snd_hda_intel snd_hda_codec iwlagn iwlcore snd_hwdep snd_pcm snd_seq snd_timer mac80211 thinkpad_acpi snd_seq_device led_class wmi psmouse cfg80211 serio_raw i2c_i801 snd evdev soundcore nvram rfkill snd_page_alloc ac battery button processor ext3 jbd mbcache sha256_generic aes_x86_64 aes_generic
  cbc dm_crypt dm_mirror dm_region_hash dm_log dm_snapshot dm_mod sd_mod crc_t10dif uhci_hcd ahci libata scsi_mod ehci_hcd e1000e thermal fan i915 i2c_algo_bit cfbcopyarea video thermal_sys output cfbimgblt cfbfillrect drm i2c_co
> Jul  5 18:42:18 bulky kernel: re intel_agp
> Jul  5 18:42:18 bulky kernel: [  853.628006] CPU 0:
> Jul  5 18:42:18 bulky kernel: [  853.628006] Modules linked in: des_generic hidp hid tun ipt_MASQUERADE iptable_nat nf_nat nf_conntrack_ipv4 nf_defrag_ipv4 xt_state nf_conntrack ipt_REJECT xt_tcpudp iptable_filter ip_tables x_tables bridge stp llc bnep sco rfcomm l2cap kvm_intel kvm acpi_cpufreq cpufreq_powersave cpufreq_stats cpufreq_userspace cpufreq_conservative rpcsec_gss_krb5 nfsd exportfs nfs lockd fscache nfs_acl auth_rpcgss sunrpc ext2 loop btusb bluetooth snd_hda_codec_conexant arc4 ecb snd_hda_intel snd_hda_codec iwlagn iwlcore snd_hwdep snd_pcm snd_seq snd_timer mac80211 thinkpad_acpi snd_seq_device led_class wmi psmouse cfg80211 serio_raw i2c_i801 snd evdev soundcore nvram rfkill snd_page_alloc ac battery button processor ext3 jbd mbcache sha256_generic aes_x86_64 aes_generic
  cbc dm_crypt dm_mirror dm_region_hash dm_log dm_snapshot dm_mod sd_mod crc_t10dif uhci_hcd ahci libata scsi_mod ehci_hcd e1000e thermal fan i915 i2c_algo_bit cfbcopyarea video thermal_sys output cfbimgblt cfbfillrect drm i2c_co
> Jul  5 18:42:18 bulky kernel: re intel_agp
> Jul  5 18:42:18 bulky kernel: [  853.628006] Pid: 3991, comm: 10.2.4.3-manage Not tainted 2.6.31-rc2 #1 7454CTO
> Jul  5 18:42:18 bulky kernel: [  853.628006] RIP: 0010:[<ffffffff8105da90>]  [<ffffffff8105da90>] bit_waitqueue+0x95/0xa0
> Jul  5 18:42:18 bulky kernel: [  853.628006] RSP: 0018:ffff880113573e60  EFLAGS: 00000212
> Jul  5 18:42:18 bulky kernel: [  853.628006] RAX: 0000000000000b70 RBX: 0000000000000000 RCX: 0000000000000036
> Jul  5 18:42:18 bulky kernel: [  853.628006] RDX: ffff88000000dc00 RSI: 0000000000000000 RDI: 0000000000000000
> Jul  5 18:42:18 bulky kernel: [  853.628006] RBP: ffffffff810115ae R08: 0000000000000000 R09: 0000000000000000
> Jul  5 18:42:18 bulky kernel: [  853.628006] R10: ffff880028026f18 R11: ffff880028026f18 R12: 0000000000000000
> Jul  5 18:42:18 bulky kernel: [  853.628006] R13: ffffffff810115ae R14: 0000000000000082 R15: ffff880127c2b100
> Jul  5 18:42:18 bulky kernel: [  853.628006] FS:  0000000000000000(0000) GS:ffff880028023000(0000) knlGS:0000000000000000
> Jul  5 18:42:18 bulky kernel: [  853.628006] CS:  0010 DS: 0018 ES: 0018 CR0: 000000008005003b
> Jul  5 18:42:18 bulky kernel: [  853.628006] CR2: 0000000001ff3930 CR3: 0000000001001000 CR4: 00000000000426e0
> Jul  5 18:42:18 bulky kernel: [  853.628006] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
> Jul  5 18:42:18 bulky kernel: [  853.628006] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
> Jul  5 18:42:18 bulky kernel: [  853.628006] Call Trace:
> Jul  5 18:42:18 bulky kernel: [  853.628006]  [<ffffffff8105dad9>] ? wake_up_bit+0x11/0x22
> Jul  5 18:42:18 bulky kernel: [  853.628006]  [<ffffffffa03dd97c>] ? nfs4_clear_state_manager_bit+0x21/0x2a [nfs]
> Jul  5 18:42:18 bulky kernel: [  853.628006]  [<ffffffffa03dec0f>] ? nfs4_run_state_manager+0x232/0x2a1 [nfs]
> Jul  5 18:42:18 bulky kernel: [  853.628006]  [<ffffffffa03de9dd>] ? nfs4_run_state_manager+0x0/0x2a1 [nfs]
> Jul  5 18:42:18 bulky kernel: [  853.628006]  [<ffffffff8105d797>] ? kthread+0x84/0x8c
> Jul  5 18:42:18 bulky kernel: [  853.628006]  [<ffffffff81011aea>] ? child_rip+0xa/0x20
> Jul  5 18:42:18 bulky kernel: [  853.628006]  [<ffffffffa039008a>] ? gss_unwrap_resp+0x0/0x1c4 [auth_rpcgss]
> Jul  5 18:42:18 bulky kernel: [  853.628006]  [<ffffffff8105d713>] ? kthread+0x0/0x8c
> Jul  5 18:42:18 bulky kernel: [  853.628006]  [<ffffffff81011ae0>] ? child_rip+0x0/0x20
> 
> 
> -- 
> Paul Collins
> Wellington, New Zealand
> 
> Dag vijandelijk luchtschip de huismeester is dood
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/
