Return-Path: linux-kernel-owner@vger.kernel.org
From: Nix <nix@esperi.org.uk>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: Bruno =?utf-8?Q?Pr=C3=A9mont?= <bonbons@linux-vserver.org>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        "Eric W. Biederman" <ebiederm@xmission.com>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: [Patch] sunrpc: NULL utsname dereference on NFS umount during namespace cleanup
References: <20150125220604.090121ae@neptune.home>
	<CAHQdGtSNmera4P6ocFGbLhjmESB8oV9zKE_x_zTm=5qUg7e7Ug@mail.gmail.com>
	<1422661761.21259.5.camel@primarydata.com>
	<87zj8z7p99.fsf@spindle.srvr.nix>
Date: Mon, 02 Feb 2015 17:41:53 +0000
In-Reply-To: <87zj8z7p99.fsf@spindle.srvr.nix> (nix@esperi.org.uk's message of
	"Sat, 31 Jan 2015 00:44:18 +0000")
Message-ID: <87d25s2ota.fsf@spindle.srvr.nix>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-kernel-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 31 Jan 2015, nix@esperi.org.uk told this:
> I'll let it run overnight and give it a reboot in the morning.

Alas, my latest reboot hit:

[  215.245158] BUG: unable to handle kernel NULL pointer dereference at 00000004
[  215.251602] IP: [<c034fb8c>] rpc_new_client+0x13b/0x1f2
[  215.251602] *pde = 00000000
[  215.251602] Oops: 0000 [#1]
[  215.251602] CPU: 0 PID: 398 Comm: bash Not tainted 3.18.5+ #1
[  215.251602] task: de1fcfc0 ti: de1fa000 task.ti: de1fa000
[  215.251602] EIP: 0060:[<c034fb8c>] EFLAGS: 00010246 CPU: 0
[  215.251602] EIP is at rpc_new_client+0x13b/0x1f2
[  215.251602] EAX: 00000000 EBX: df70f000 ECX: 0000bae0 EDX: 00000005
[  215.251602] ESI: 00000000 EDI: df6cc000 EBP: 00000007 ESP: de1fbcac
[  215.251602]  DS: 007b ES: 007b FS: 0000 GS: 0000 SS: 0068
[  215.251602] CR0: 8005003b CR2: 00000004 CR3: 1f645000 CR4: 00000090
[  215.251602] Stack:
[  215.251602]  000000d0 df6cc000 de1fbd4c 00000000 de1fbd4c de1fbd4c de1fbd10 de1fbf8c
[  215.251602]  c0350196 de1fbd4c de2056d0 de1fbd10 c0350300 c0262e32 c0263841 df528000
[  215.251602]  a2e0b542 00000006 c044b178 00000000 de1fbddc 00000010 de2056d0 00000000
[  215.251602] Call Trace:
[  215.251602]  [<c0350196>] ? rpc_create_xprt+0xc/0x74
[  215.251602]  [<c0350300>] ? rpc_create+0x102/0x10f
[  215.251602]  [<c0262e32>] ? ata_sff_check_status+0x8/0x9
[  215.251602]  [<c0263841>] ? ata_dev_select.constprop.20+0x83/0x95
[  215.251602]  [<c019ec6a>] ? __block_commit_write.isra.25+0x56/0x7f
[  215.251602]  [<c0359f04>] ? rpcb_create+0x6e/0x7c
[  215.251602]  [<c035a677>] ? rpcb_getport_async+0x124/0x25a
[  215.251602]  [<c0133bdf>] ? update_curr+0x81/0xb3
[  215.251602]  [<c0133e97>] ? check_preempt_wakeup+0xf0/0x134
[  215.251602]  [<c013110f>] ? check_preempt_curr+0x21/0x59
[  215.251602]  [<c0355294>] ? rpcauth_lookupcred+0x3f/0x47
[  215.251602]  [<c017ebb6>] ? __kmalloc+0xa3/0xc4
[  215.251602]  [<c0354c09>] ? rpc_malloc+0x39/0x48
[  215.251602]  [<c034ef05>] ? call_bind+0x2d/0x2e
[  215.251602]  [<c0354a71>] ? __rpc_execute+0x5c/0x187
[  215.251602]  [<c03500be>] ? rpc_run_task+0x55/0x5a
[  215.251602]  [<c035012c>] ? rpc_call_sync+0x69/0x81
[  215.251602]  [<c01e219e>] ? nsm_mon_unmon+0x8c/0xa0
[  215.251602]  [<c01e23c5>] ? nsm_unmonitor+0x5f/0xd3
[  215.251602]  [<c016b3cc>] ? bdi_unregister+0xf2/0x100
[  215.251602]  [<c01df4cc>] ? nlm_destroy_host_locked+0x4f/0x7c
[  215.251602]  [<c01df703>] ? nlmclnt_release_host+0xd8/0xe5
[  215.251602]  [<c01dddd5>] ? nlmclnt_done+0xc/0x14
[  215.251602]  [<c01ce621>] ? nfs_free_server+0x16/0x72
[  215.251602]  [<c01837a4>] ? deactivate_locked_super+0x26/0x37
[  215.251602]  [<c019493e>] ? cleanup_mnt+0x40/0x59
[  215.251602]  [<c012e185>] ? task_work_run+0x4f/0x5f
[  215.251602]  [<c0121373>] ? do_exit+0x264/0x670
[  215.251602]  [<c0127a2b>] ? __set_current_blocked+0xd/0xf
[  215.251602]  [<c0127b26>] ? sigprocmask+0x77/0x87
[  215.251602]  [<c012e097>] ? __task_pid_nr_ns+0x3a/0x41
[  215.251602]  [<c012e019>] ? find_vpid+0xd/0x17
[  215.251602]  [<c01217cc>] ? do_group_exit+0x2b/0x5d
[  215.251602]  [<c012180d>] ? SyS_exit_group+0xf/0xf
[  215.251602]  [<c03679b6>] ? syscall_call+0x7/0x7
[  215.251602] Code: 89 43 40 8b 44 24 04 89 43 18 8d 43 78 8b 53 40 89 43 3c 8b 12 e8 32 ac 00 00 c7 03 01 00 00 00 a1 dc f0 42 c0 8b 80 00 03 00 00 <8b> 70 04 83 c6 45 89 f0 e8 ab d1 eb ff 83 f8 20 7f 05 89 43 44
[  215.251602] EIP: [<c034fb8c>] rpc_new_client+0x13b/0x1f2 SS:ESP 0068:de1fbcac
[  215.251602] CR2: 0000000000000004
[  215.251602] ---[ end trace 4b9e971f6b3f2dc8 ]---
[  215.251602] Kernel panic - not syncing: Fatal exception
[  215.251602] Kernel Offset: 0x0 from 0xc0100000 (relocation range: 0xc0000000-0xe07fffff)
[  215.251602] Rebooting in 5 seconds..

so clearly the bug is still there; also the connection I thought might
exist with the "xprt_adjust_timeout: rq_timeout = 0!" was illusory: that
message hadn't recurred since before the last reboot but one, but the
crash happened anyway.

-- 
NULL && (void)
