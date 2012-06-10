Return-Path: linux-nfs-owner@vger.kernel.org
Received: from audible.transient.net ([216.254.12.79]:53183 "HELO
	audible.transient.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1751205Ab2FJJLE (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 10 Jun 2012 05:11:04 -0400
Date: Sun, 10 Jun 2012 09:03:42 +0000
From: Jamie Heilman <jamie@audible.transient.net>
To: "J. Bruce Fields" <bfields@redhat.com>
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
Subject: NFSv4 regression, kernel BUG at fs/nfsd/nfs4state.c:1044!
Message-ID: <20120610090342.GA5076@cucamonga.audible.transient.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Upgrading my NFSv4 server from 3.3.8 to 3.4.2 I've managed to
reproduce this reliably:

------------[ cut here ]------------
kernel BUG at fs/nfsd/nfs4state.c:1044!
invalid opcode: 0000 [#1] 
Modules linked in: md5 cpufreq_conservative cpufreq_stats cpufreq_powersave cpufreq_ondemand autofs4 quota_v2 quota_tree nfsd nfs_acl exportfs nfs lockd fscache auth_rpcgss sunrpc xt_mark xt_dscp cls_fw sch_htb iptable_nat nf_nat ipt_REJECT xt_multiport xt_mac xt_tcpudp iptable_mangle nf_conntrack_ipv4 nf_defrag_ipv4 xt_state nf_conntrack xt_LOG xt_limit iptable_filter ip_tables x_tables dm_crypt dm_mod snd_hda_codec_via tpm_tis tpm via_rhine snd_hda_intel snd_hda_codec tpm_bios mii via_velocity snd_hwdep snd_pcm snd_timer snd soundcore snd_page_alloc evdev crc_ccitt via_agp agpgart button

Pid: 1804, comm: nfsd Not tainted 3.4.2 #3 To Be Filled By O.E.M. To Be Filled By O.E.M./To be filled by O.E.M.
EIP: 0060:[<f86ac683>] EFLAGS: 00010246 CPU: 0
EIP is at free_client.isra.47+0x3/0x5 [nfsd]
EAX: 00000000 EBX: e9d48800 ECX: e9d48030 EDX: f86b20f8
ESI: e9d48810 EDI: e9cf9ec0 EBP: e9cf9eb4 ESP: e9cf9eb4
 DS: 007b ES: 007b FS: 0000 GS: 00e0 SS: 0068
CR0: 8005003b CR2: b760bee0 CR3: 34d04000 CR4: 000006b0
DR0: 00000000 DR1: 00000000 DR2: 00000000 DR3: 00000000
DR6: ffff0ff0 DR7: 00000400
Process nfsd (pid: 1804, ti=e9cf8000 task=e9cf4000 task.ti=e9cf8000)
Stack:
 e9cf9ed4 f86a6c00 e9d48828 e9cf9ec0 e9cf9ec0 e9d48800 e9d48000 00000000
 e9cf9f00 f86a6d36 00000000 000555c0 f53c0001 4fd43f69 00000001 7ad0b2a0
 f4c45000 f4c44060 00000360 e9cf9f3c f869f63c f86aff20 e9cb9000 00000000
Call Trace:
 [<f86a6c00>] expire_client+0xb1/0xb9 [nfsd]
 [<f86a6d36>] nfsd4_setclientid_confirm+0x12e/0x1c7 [nfsd]
 [<f869f63c>] nfsd4_proc_compound+0x1fd/0x354 [nfsd]
 [<f86946e3>] nfsd_dispatch+0x89/0x134 [nfsd]
 [<f86c6d64>] svc_process+0x327/0x4e3 [sunrpc]
 [<f86940d2>] nfsd+0xd2/0x10b [nfsd]
 [<f8694000>] ? 0xf8693fff
 [<c102d53a>] kthread+0x66/0x6b
 [<c102d4d4>] ? flush_kthread_worker+0x74/0x74
 [<c123193e>] kernel_thread_helper+0x6/0xd
Code: 01 80 3e 00 74 04 89 f2 eb a2 8b 4d e8 8b 55 ec 8b 45 f0 0f c8 89 19 89 02 31 c0 83 c4 18 5b 5e 5f 5d c3 55 89 e5 0f 0b 55 89 e5 <0f> 0b 55 89 e5 57 56 89 d6 53 89 c3 8b 78 34 89 d0 e8 b4 8f ff 
EIP: [<f86ac683>] free_client.isra.47+0x3/0x5 [nfsd] SS:ESP 0068:e9cf9eb4
---[ end trace bf1613e00e6f3bbe ]---

System is a 32-bit Via C7; to reproduce I need only establish a NFSv4
mount from a client, then reboot the client.  The BUG happens when the
client attempts to reconnect.  At this point nfs service on the server
becomes something of a lost cause.  Userspace is Debian stable
(nfs-utils 1.2.2 based).  I haven't had a chance to bisect the issue
yet, I'll give that shot in the coming week if nobody knows of any
obvious fixes.  Let me know if there's any other info I can provide
that's useful.

-- 
Jamie Heilman                     http://audible.transient.net/~jamie/
