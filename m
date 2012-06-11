Return-Path: linux-nfs-owner@vger.kernel.org
Received: from audible.transient.net ([216.254.12.79]:55884 "HELO
	audible.transient.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1753427Ab2FKDmV (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 10 Jun 2012 23:42:21 -0400
Date: Mon, 11 Jun 2012 03:41:39 +0000
From: Jamie Heilman <jamie@audible.transient.net>
To: "J. Bruce Fields" <bfields@redhat.com>
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
Subject: Re: NFSv4 regression, kernel BUG at fs/nfsd/nfs4state.c:1044!
Message-ID: <20120611034139.GA26717@cucamonga.audible.transient.net>
References: <20120610090342.GA5076@cucamonga.audible.transient.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20120610090342.GA5076@cucamonga.audible.transient.net>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Jamie Heilman wrote:
> Upgrading my NFSv4 server from 3.3.8 to 3.4.2 I've managed to
> reproduce this reliably:
> 
> ------------[ cut here ]------------
> kernel BUG at fs/nfsd/nfs4state.c:1044!
> invalid opcode: 0000 [#1] 
> Modules linked in: md5 cpufreq_conservative cpufreq_stats cpufreq_powersave cpufreq_ondemand autofs4 quota_v2 quota_tree nfsd nfs_acl exportfs nfs lockd fscache auth_rpcgss sunrpc xt_mark xt_dscp cls_fw sch_htb iptable_nat nf_nat ipt_REJECT xt_multiport xt_mac xt_tcpudp iptable_mangle nf_conntrack_ipv4 nf_defrag_ipv4 xt_state nf_conntrack xt_LOG xt_limit iptable_filter ip_tables x_tables dm_crypt dm_mod snd_hda_codec_via tpm_tis tpm via_rhine snd_hda_intel snd_hda_codec tpm_bios mii via_velocity snd_hwdep snd_pcm snd_timer snd soundcore snd_page_alloc evdev crc_ccitt via_agp agpgart button
> 
> Pid: 1804, comm: nfsd Not tainted 3.4.2 #3 To Be Filled By O.E.M. To Be Filled By O.E.M./To be filled by O.E.M.
> EIP: 0060:[<f86ac683>] EFLAGS: 00010246 CPU: 0
> EIP is at free_client.isra.47+0x3/0x5 [nfsd]
> EAX: 00000000 EBX: e9d48800 ECX: e9d48030 EDX: f86b20f8
> ESI: e9d48810 EDI: e9cf9ec0 EBP: e9cf9eb4 ESP: e9cf9eb4
>  DS: 007b ES: 007b FS: 0000 GS: 00e0 SS: 0068
> CR0: 8005003b CR2: b760bee0 CR3: 34d04000 CR4: 000006b0
> DR0: 00000000 DR1: 00000000 DR2: 00000000 DR3: 00000000
> DR6: ffff0ff0 DR7: 00000400
> Process nfsd (pid: 1804, ti=e9cf8000 task=e9cf4000 task.ti=e9cf8000)
> Stack:
>  e9cf9ed4 f86a6c00 e9d48828 e9cf9ec0 e9cf9ec0 e9d48800 e9d48000 00000000
>  e9cf9f00 f86a6d36 00000000 000555c0 f53c0001 4fd43f69 00000001 7ad0b2a0
>  f4c45000 f4c44060 00000360 e9cf9f3c f869f63c f86aff20 e9cb9000 00000000
> Call Trace:
>  [<f86a6c00>] expire_client+0xb1/0xb9 [nfsd]
>  [<f86a6d36>] nfsd4_setclientid_confirm+0x12e/0x1c7 [nfsd]
>  [<f869f63c>] nfsd4_proc_compound+0x1fd/0x354 [nfsd]
>  [<f86946e3>] nfsd_dispatch+0x89/0x134 [nfsd]
>  [<f86c6d64>] svc_process+0x327/0x4e3 [sunrpc]
>  [<f86940d2>] nfsd+0xd2/0x10b [nfsd]
>  [<f8694000>] ? 0xf8693fff
>  [<c102d53a>] kthread+0x66/0x6b
>  [<c102d4d4>] ? flush_kthread_worker+0x74/0x74
>  [<c123193e>] kernel_thread_helper+0x6/0xd
> Code: 01 80 3e 00 74 04 89 f2 eb a2 8b 4d e8 8b 55 ec 8b 45 f0 0f c8 89 19 89 02 31 c0 83 c4 18 5b 5e 5f 5d c3 55 89 e5 0f 0b 55 89 e5 <0f> 0b 55 89 e5 57 56 89 d6 53 89 c3 8b 78 34 89 d0 e8 b4 8f ff 
> EIP: [<f86ac683>] free_client.isra.47+0x3/0x5 [nfsd] SS:ESP 0068:e9cf9eb4
> ---[ end trace bf1613e00e6f3bbe ]---
> 
> System is a 32-bit Via C7; to reproduce I need only establish a NFSv4
> mount from a client, then reboot the client.  The BUG happens when the
> client attempts to reconnect.  At this point nfs service on the server
> becomes something of a lost cause.  Userspace is Debian stable
> (nfs-utils 1.2.2 based).  I haven't had a chance to bisect the issue
> yet, I'll give that shot in the coming week if nobody knows of any
> obvious fixes.  Let me know if there's any other info I can provide
> that's useful.

Turns out bisection isn't going to be straightforward as between v3.3
and v3.4-rc1 there was some other issue introduced and fixed that
prevents my test system from booting at all, it freezes up after the
MSR00000000: 0000000000000000 ... spew, and I haven't figured out what
it was.  I tried 3.5-rc2 to see if the issue had been fixed by further
nfs tree merges, and no it hasn't been.  I was also able to trigger
this a couple of times, just by attempting to mv a ~4M file onto a
recovered nfs volume after an NFS server reboot:

RPC: fragment too large: 0x000800cc
RPC: fragment too large: 0x000800cc
RPC: fragment too large: 0x000800cc
RPC: fragment too large: 0x000800cc
RPC: fragment too large: 0x000800cc
RPC: fragment too large: 0x000800cc
RPC: fragment too large: 0x000800cc
RPC: fragment too large: 0x000800cc
RPC: fragment too large: 0x000800cc
RPC: fragment too large: 0x000800cc
RPC: fragment too large: 0x000800cc
RPC: fragment too large: 0x000800cc
RPC: fragment too large: 0x000800cc
RPC: fragment too large: 0x000800cc
RPC: fragment too large: 0x000800cc
RPC: fragment too large: 0x000800cc
RPC: fragment too large: 0x000800cc
RPC: fragment too large: 0x000800cc
RPC: fragment too large: 0x000800cc
RPC: fragment too large: 0x000800cc
RPC: fragment too large: 0x000800cc
RPC: fragment too large: 0x000800cc
RPC: fragment too large: 0x000800cc
RPC: fragment too large: 0x000800cc
RPC: fragment too large: 0x000800cc
RPC: fragment too large: 0x000800cc
RPC: fragment too large: 0x000800cc
RPC: fragment too large: 0x000800cc
RPC: fragment too large: 0x000800cc
RPC: fragment too large: 0x000800cc
------------[ cut here ]------------
kernel BUG at fs/nfsd/nfs4state.c:1083!
invalid opcode: 0000 [#1]
Modules linked in: md5 cpufreq_conservative cpufreq_stats cpufreq_powersave cpufreq_ondemand autofs4 quota_v2 quota_tree nfsd nfs_acl exportfs nfs fscache auth_rpcgss lockd sunrpc xt_mark xt_dscp cls_fw sch_htb iptable_nat nf_nat ipt_REJECT xt_multiport xt_mac xt_tcpudp iptable_mangle nf_conntrack_ipv4 nf_defrag_ipv4 xt_state nf_conntrack xt_LOG xt_limit iptable_filter ip_tables x_tables dm_crypt dm_mod snd_hda_codec_via snd_hda_intel snd_hda_codec snd_hwdep tpm_tis tpm tpm_bios snd_pcm snd_timer snd soundcore via_rhine evdev snd_page_alloc mii via_agp via_velocity crc_ccitt agpgart button

Pid: 515, comm: kworker/u:5 Not tainted 3.5.0-rc2 #7 To Be Filled By O.E.M. To Be Filled By O.E.M./To be filled by O.E.M.
EIP: 0060:[<f8740eb5>] EFLAGS: 00010246 CPU: 0
EIP is at free_client.isra.46+0x3/0x5 [nfsd]
EAX: 00000000 EBX: f5be9000 ECX: f5ba5f58 EDX: f5ba5f58
ESI: f5be9010 EDI: f5ba5f28 EBP: f5ba5f1c ESP: f5ba5f1c
 DS: 007b ES: 007b FS: 0000 GS: 00e0 SS: 0068
CR0: 8005003b CR2: b7732000 CR3: 3513b000 CR4: 000006b0
DR0: 00000000 DR1: 00000000 DR2: 00000000 DR3: 00000000
DR6: ffff0ff0 DR7: 00000400
Process kworker/u:5 (pid: 515, ti=f5ba4000 task=f59e5d00 task.ti=f5ba4000)
Stack:
 f5ba5f3c f873a72b f5be9028 f5ba5f28 f5ba5f28 00000029 f5ba5f58 f5be9000
 f5ba5f6c f873b434 f59e5d00 00000000 f5be9030 4fd5563d f5ba5f58 f5ba5f58
 f5ba5f58 f59ffb00 f8746368 00000000 f5ba5fa0 c102b950 0000007b 00000000
Call Trace:
 [<f873a72b>] expire_client+0xb1/0xb9 [nfsd]
 [<f873b434>] laundromat_main+0x132/0x1fa [nfsd]
 [<c102b950>] process_one_work+0xe0/0x1aa
 [<f873b302>] ? nfsd4_exchange_id+0x292/0x292 [nfsd]
 [<c102bbd3>] worker_thread+0xa4/0x12c
 [<c102bb2f>] ? rescuer_thread+0xf4/0xf4
 [<c102edda>] kthread+0x66/0x6b
 [<c102ed74>] ? flush_kthread_worker+0x74/0x74
 [<c12392fe>] kernel_thread_helper+0x6/0xd
Code: 03 8d 73 01 8a 06 84 c0 75 84 8b 45 e4 89 10 8b 55 ec 8b 45 f0 0f c8 89 02 31 c0 83 c4 20 5b 5e 5f 5d c3 55 89 e5 0f 0b 55 89 e5 <0f> 0b 55 89 e5 57 56 89 d6 53 53 89 c3 8b 78 34 89 d0 e8 cb 82
EIP: [<f8740eb5>] free_client.isra.46+0x3/0x5 [nfsd] SS:ESP 0068:f5ba5f1c
---[ end trace 59132c98eb4d8731 ]---
RPC: fragment too large: 0x000800cc
BUG: unable to handle kernel paging request at fffffffc
IP: [<c102ede9>] kthread_data+0xa/0xe
*pdpt = 0000000001397001 *pde = 000000000139b067 *pte = 0000000000000000
Oops: 0000 [#2]
Modules linked in: md5 cpufreq_conservative cpufreq_stats cpufreq_powersave cpufreq_ondemand autofs4 quota_v2 quota_tree nfsd nfs_acl exportfs nfs fscache auth_rpcgss lockd sunrpc xt_mark xt_dscp cls_fw sch_htb iptable_nat nf_nat ipt_REJECT xt_multiport xt_mac xt_tcpudp iptable_mangle nf_conntrack_ipv4 nf_defrag_ipv4 xt_state nf_conntrack xt_LOG xt_limit iptable_filter ip_tables x_tables dm_crypt dm_mod snd_hda_codec_via snd_hda_intel snd_hda_codec snd_hwdep tpm_tis tpm tpm_bios snd_pcm snd_timer snd soundcore via_rhine evdev snd_page_alloc mii via_agp via_velocity crc_ccitt agpgart button

Pid: 515, comm: kworker/u:5 Tainted: G      D      3.5.0-rc2 #7 To Be Filled By O.E.M. To Be Filled By O.E.M./To be filled by O.E.M.
EIP: 0060:[<c102ede9>] EFLAGS: 00010046 CPU: 0
EIP is at kthread_data+0xa/0xe
EAX: 00000000 EBX: c13b49a4 ECX: ffd23940 EDX: 00000000
ESI: 00000000 EDI: f59e5e70 EBP: f5ba5d20 ESP: f5ba5d14
 DS: 007b ES: 007b FS: 0000 GS: 00e0 SS: 0068
CR0: 8005003b CR2: fffffffc CR3: 34da6000 CR4: 000006b0
DR0: 00000000 DR1: 00000000 DR2: 00000000 DR3: 00000000
DR6: ffff0ff0 DR7: 00000400   
Process kworker/u:5 (pid: 515, ti=f5ba4000 task=f59e5d00 task.ti=f5ba4000)
Stack:
 c102c884 f59e5d00 f5ba5ce4 f5ba5d9c c1237e5d f5fe9600 00000046 f5ba5d58
 c102c587 00000000 f59e5d00 f514b2f8 f5bee600 f59e5d00 00000000 00000000
 00000202 f5ba5d64 c102c5d2 f4a07c80 f5ba5d6c c102c5fe f5ba5d74 00000202
Call Trace:
 [<c102c884>] ? wq_worker_sleeping+0x11/0x5b
 [<c1237e5d>] __schedule+0xa8/0x3bf
 [<c102c587>] ? __queue_work+0x163/0x181
 [<c102c5d2>] ? queue_work_on+0x13/0x1f
 [<c102c5fe>] ? queue_work+0xe/0x10
 [<c1100bc7>] ? put_io_context+0x3e/0x55
 [<c1100c55>] ? put_io_context_active+0x40/0x45
 [<c1238219>] schedule+0x51/0x53
 [<c10208c7>] do_exit+0x5c6/0x5c8
 [<c100430d>] oops_end+0x6b/0x70
 [<c100444c>] die+0x54/0x5c   
 [<c10025c6>] do_trap+0x8a/0xa3
 [<c1002814>] ? do_bounds+0x69/0x69
 [<c100289c>] do_invalid_op+0x88/0x92
 [<f8740eb5>] ? free_client.isra.46+0x3/0x5 [nfsd]
 [<c1238219>] ? schedule+0x51/0x53
 [<c1237540>] ? schedule_timeout+0x15/0x96
 [<c10346a8>] ? check_preempt_curr+0x27/0x62
 [<c1237cea>] ? wait_for_common+0x5c/0xa4
 [<c1034753>] ? try_to_wake_up+0x70/0x70
 [<c1237db3>] ? wait_for_completion+0x12/0x14
 [<c1238b45>] error_code+0x65/0x6c
 [<f8740eb5>] ? free_client.isra.46+0x3/0x5 [nfsd]
 [<f873a72b>] expire_client+0xb1/0xb9 [nfsd]
 [<f873b434>] laundromat_main+0x132/0x1fa [nfsd]
 [<c102b950>] process_one_work+0xe0/0x1aa
 [<f873b302>] ? nfsd4_exchange_id+0x292/0x292 [nfsd]
 [<c102bbd3>] worker_thread+0xa4/0x12c
 [<c102bb2f>] ? rescuer_thread+0xf4/0xf4
 [<c102edda>] kthread+0x66/0x6b
 [<c102ed74>] ? flush_kthread_worker+0x74/0x74
 [<c12392fe>] kernel_thread_helper+0x6/0xd
Code: 8d 43 10 e8 fe 53 00 00 e8 fd 93 20 00 b8 fc ff ff ff 83 7d e0 00 75 04 89 f0 ff d7 e8 22 15 ff ff 55 8b 80 44 01 00 00 89 e5 5d <8b> 40 fc c3 55 31 c0 89 e5 5d c3 55 ba fa 11 2b c1 89 e5 57 56
EIP: [<c102ede9>] kthread_data+0xa/0xe SS:ESP 0068:f5ba5d14
CR2: 00000000fffffffc
---[ end trace 59132c98eb4d8732 ]---
Fixing recursive fault but reboot is needed!
BUG: unable to handle kernel paging request at fffffffc
IP: [<c102ede9>] kthread_data+0xa/0xe
*pdpt = 0000000001397001 *pde = 000000000139b067 *pte = 0000000000000000
Oops: 0000 [#3]

and at this point the system gets thrown into a loop and spews errors
until it eventually reboots, which may be due to my watchdog going
off or something, I'm not sure, I couldn't capture all of the output.


-- 
Jamie Heilman                     http://audible.transient.net/~jamie/
