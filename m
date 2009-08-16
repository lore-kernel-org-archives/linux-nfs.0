From: Daniel J Blueman <daniel.blueman@gmail.com>
Subject: [2.6.31-rc5] oops: NFS4 client manager kthread...
Date: Sun, 16 Aug 2009 23:40:22 +0100
Message-ID: <6278d2220908161540h78f17424m592c5acf3420f906@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Linux Kernel <linux-kernel@vger.kernel.org>
To: linux-nfs@vger.kernel.org,
	Trond Myklebust <Trond.Myklebust@netapp.com>,
	Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ew0-f214.google.com ([209.85.219.214]:57331 "EHLO
	mail-ew0-f214.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751847AbZHPWkW (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 16 Aug 2009 18:40:22 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

After losing and regaining ethernet link a few times with 2.6.31-rc5
[1], I've hit an oops in the NFS4 client manager kthread [2] on my
client with NFS4 homedir mount.

Do you have a frequent test-case for when the client's manager kthread
gets invoked (with and without succeeding callbacks, due to eg a
firewall)? Server here is unpatched 2.6.30-rc6; I recall seeing
problems when the manager kthread gets invoked, across quite a few
kernel releases, just wasn't lucky enough to catch an oops.

Oppsing in allow_signal() suggests task state corruption perhaps? I'm
downloading the debug kernel to match up the disassembly and line
numbers, if that helps? This time, the client had no firewall (but
have seen other issues when the callback has failed due to the
firewall).

Thanks,
  Daniel

--- [1]

Karmic's 2.6.31-5-generic maps to 2.6.31-rc5, but oddly is missed out at:
http://kernel.ubuntu.com/~kernel-ppa/info/kernel-version-map.html

--- [2]

e1000e: eth0 NIC Link is Down

e1000e: eth0 NIC Link is Up 1000 Mbps Full Duplex, Flow Control: RX/TX

BUG: soft lockup - CPU#1 stuck for 61s! [192.168.1.250-m:7944]

Modules linked in: ppdev kvm_intel kvm microcode nfsd exportfs nfs
lockd nfs_acl auth_rpcgss sunrpc ipt_REJECT ipt_LOG xt_limit xt_tcpudp
xt_state ipt_addrtype ip6table_filter ip6_tables nf_nat_irc
nf_conntrack_irc nf_nat_ftp nf_nat nf_conntrack_ipv4 nf_defrag_ipv4
nf_conntrack_ftp nf_conntrack iptable_filter ip_tables x_tables
dm_crypt joydev lp parport snd_hda_codec_conexant snd_hda_intel
snd_hda_codec snd_pcm_oss snd_mixer_oss snd_pcm arc4 snd_seq_dummy
pcmcia ecb snd_seq_oss snd_seq_midi snd_rawmidi snd_seq_midi_event
snd_seq snd_timer snd_seq_device iwlagn iwlcore mac80211 psmouse
serio_raw snd yenta_socket soundcore rsrc_nonstatic snd_page_alloc
ricoh_mmc pcmcia_core sdhci_pci sdhci thinkpad_acpi led_class cfg80211
nvram radeon ttm heci(C) e1000e fbcon tileblit font bitblit softcursor
i915 drm i2c_algo_bit video output intel_agp

CPU 1:

Modules linked in: ppdev kvm_intel kvm microcode nfsd exportfs nfs
lockd nfs_acl auth_rpcgss sunrpc ipt_REJECT ipt_LOG xt_limit xt_tcpudp
xt_state ipt_addrtype ip6table_filter ip6_tables nf_nat_irc
nf_conntrack_irc nf_nat_ftp nf_nat nf_conntrack_ipv4 nf_defrag_ipv4
nf_conntrack_ftp nf_conntrack iptable_filter ip_tables x_tables
dm_crypt joydev lp parport snd_hda_codec_conexant snd_hda_intel
snd_hda_codec snd_pcm_oss snd_mixer_oss snd_pcm arc4 snd_seq_dummy
pcmcia ecb snd_seq_oss snd_seq_midi snd_rawmidi snd_seq_midi_event
snd_seq snd_timer snd_seq_device iwlagn iwlcore mac80211 psmouse
serio_raw snd yenta_socket soundcore rsrc_nonstatic snd_page_alloc
ricoh_mmc pcmcia_core sdhci_pci sdhci thinkpad_acpi led_class cfg80211
nvram radeon ttm heci(C) e1000e fbcon tileblit font bitblit softcursor
i915 drm i2c_algo_bit video output intel_agp

Pid: 7944, comm: 192.168.1.250-m Tainted: G         C 2.6.31-5-generic
#24-Ubuntu 276521G

RIP: 0010:[<ffffffff8151da29>]  [<ffffffff8151da29>] _spin_lock_bh+0x19/0x30

RSP: 0000:ffff88011d80fe30  EFLAGS: 00000246

RAX: 000000000000a5a5 RBX: ffff88011d80fe40 RCX: 0000000000000035

RDX: 0000000000000000 RSI: ffff88014b791cf0 RDI: ffff88014b791da8

RBP: ffffffff81012b6e R08: 0000000000000000 R09: e000000000000000

R10: fe968735ee473c00 R11: 0000000000000001 R12: ffff88011d80fe30

R13: ffffffff81012b6e R14: ffff88011d80fda0 R15: ffffffff8106e042

FS:  0000000000000000(0000) GS:ffff880028046000(0000) knlGS:0000000000000000

CS:  0010 DS: 0018 ES: 0018 CR0: 000000008005003b

CR2: 0000000002423000 CR3: 000000014b4bc000 CR4: 00000000000026a0

DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000

DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400

Call Trace:

 [<ffffffffa049d9f7>] ? rpc_wake_up+0x17/0xa0 [sunrpc]

 [<ffffffffa052d840>] ? nfs4_run_state_manager+0x0/0x40 [nfs]

 [<ffffffffa052c53e>] ? nfs4_clear_state_manager_bit+0x2e/0x40 [nfs]

 [<ffffffffa052d788>] ? nfs4_state_manager+0x138/0x1f0 [nfs]

 [<ffffffff8105af9d>] ? allow_signal+0x9d/0xb0

 [<ffffffffa052d85e>] ? nfs4_run_state_manager+0x1e/0x40 [nfs]

 [<ffffffff810729b6>] ? kthread+0x96/0xa0

 [<ffffffff8101308a>] ? child_rip+0xa/0x20

 [<ffffffff81072920>] ? kthread+0x0/0xa0

 [<ffffffff81013080>] ? child_rip+0x0/0x20

BUG: soft lockup - CPU#1 stuck for 61s! [192.168.1.250-m:7944]

Modules linked in: ppdev kvm_intel kvm microcode nfsd exportfs nfs
lockd nfs_acl auth_rpcgss sunrpc ipt_REJECT ipt_LOG xt_limit xt_tcpudp
xt_state ipt_addrtype ip6table_filter ip6_tables nf_nat_irc
nf_conntrack_irc nf_nat_ftp nf_nat nf_conntrack_ipv4 nf_defrag_ipv4
nf_conntrack_ftp nf_conntrack iptable_filter ip_tables x_tables
dm_crypt joydev lp parport snd_hda_codec_conexant snd_hda_intel
snd_hda_codec snd_pcm_oss snd_mixer_oss snd_pcm arc4 snd_seq_dummy
pcmcia ecb snd_seq_oss snd_seq_midi snd_rawmidi snd_seq_midi_event
snd_seq snd_timer snd_seq_device iwlagn iwlcore mac80211 psmouse
serio_raw snd yenta_socket soundcore rsrc_nonstatic snd_page_alloc
ricoh_mmc pcmcia_core sdhci_pci sdhci thinkpad_acpi led_class cfg80211
nvram radeon ttm heci(C) e1000e fbcon tileblit font bitblit softcursor
i915 drm i2c_algo_bit video output intel_agp

CPU 1:

Modules linked in: ppdev kvm_intel kvm microcode nfsd exportfs nfs
lockd nfs_acl auth_rpcgss sunrpc ipt_REJECT ipt_LOG xt_limit xt_tcpudp
xt_state ipt_addrtype ip6table_filter ip6_tables nf_nat_irc
nf_conntrack_irc nf_nat_ftp nf_nat nf_conntrack_ipv4 nf_defrag_ipv4
nf_conntrack_ftp nf_conntrack iptable_filter ip_tables x_tables
dm_crypt joydev lp parport snd_hda_codec_conexant snd_hda_intel
snd_hda_codec snd_pcm_oss snd_mixer_oss snd_pcm arc4 snd_seq_dummy
pcmcia ecb snd_seq_oss snd_seq_midi snd_rawmidi snd_seq_midi_event
snd_seq snd_timer snd_seq_device iwlagn iwlcore mac80211 psmouse
serio_raw snd yenta_socket soundcore rsrc_nonstatic snd_page_alloc
ricoh_mmc pcmcia_core sdhci_pci sdhci thinkpad_acpi led_class cfg80211
nvram radeon ttm heci(C) e1000e fbcon tileblit font bitblit softcursor
i915 drm i2c_algo_bit video output intel_agp

Pid: 7944, comm: 192.168.1.250-m Tainted: G         C 2.6.31-5-generic
#24-Ubuntu 276521G

RIP: 0010:[<ffffffffa052d66f>]  [<ffffffffa052d66f>]
nfs4_state_manager+0x1f/0x1f0 [nfs]

RSP: 0000:ffff88011d80fea0  EFLAGS: 00000246

RAX: 0000000000000000 RBX: ffff88011d80fec0 RCX: 0000000000000035

RDX: 0000000000000000 RSI: ffff88014b791d08 RDI: ffffffffa049da6b

RBP: ffffffff81012b6e R08: 0000000000000000 R09: e000000000000000

R10: fe968735ee473c00 R11: 0000000000000001 R12: ffffffffffffffc3

R13: ffff88014b791da8 R14: ffff88014b791d08 R15: 0000000000000000

FS:  0000000000000000(0000) GS:ffff880028046000(0000) knlGS:0000000000000000

CS:  0010 DS: 0018 ES: 0018 CR0: 000000008005003b

CR2: 0000000002423000 CR3: 0000000001001000 CR4: 00000000000026a0

DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000

DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400

Call Trace:

 [<ffffffff8105af9d>] ? allow_signal+0x9d/0xb0

 [<ffffffffa052d85e>] ? nfs4_run_state_manager+0x1e/0x40 [nfs]

 [<ffffffff810729b6>] ? kthread+0x96/0xa0

 [<ffffffff8101308a>] ? child_rip+0xa/0x20

 [<ffffffff81072920>] ? kthread+0x0/0xa0

 [<ffffffff81013080>] ? child_rip+0x0/0x20
-- 
Daniel J Blueman
