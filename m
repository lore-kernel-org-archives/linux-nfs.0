From: Benny Halevy <bhalevy@panasas.com>
Subject: [RFC 63/85] FIXME: nfs41: sunrpc: handle clnt==NULL in call_status
Date: Mon, 10 Nov 2008 22:29:28 +0200
Message-ID: <1226348968-9333-1-git-send-email-bhalevy@panasas.com>
References: <4918920E.3030301@panasas.com>
Cc: pnfs@linux-nfs.org, linux-nfs@vger.kernel.org
To: trond.myklebust@fys.uio.no
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from DSL212-235-53-3.bb.netvision.net.il ([212.235.53.3]:60022 "EHLO
	bh-buildlin1.bhalevy.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752412AbYKJU3f (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 10 Nov 2008 15:29:35 -0500
In-Reply-To: <4918920E.3030301@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

FIXME: pending discussion. This patch might not be needed if
backchannel usage of rpc mechanisms for sending bc_svc
replies (on the nfs client / callback svc side)

On the following error path task->tk_client == NULL causing NULL deref:

Nov  4 14:14:32 tl1 kernel: Callback slot table overflowed
Nov  4 14:14:32 tl1 kernel: BUG: unable to handle kernel NULL pointer dereference at 0000000000000078
Nov  4 14:14:32 tl1 kernel: IP: [<ffffffffa02b4dd2>] call_status+0xe1/0x145 [sunrpc]
Nov  4 14:14:32 tl1 kernel: PGD 2f973067 PUD 2f974067 PMD 0
Nov  4 14:14:32 tl1 kernel: Oops: 0000 [1] SMP
Nov  4 14:14:32 tl1 kernel: CPU 0
Nov  4 14:14:32 tl1 kernel: Modules linked in: panfs(P) panlayoutdriver nfslayoutdriver nfsd auth_rpcgss exportfs nfs lockd nfs_acl fuse sunrpc ipv6 cpufreq_ondemand powernow_k8 freq_table dm_mirror dm_log dm_multipath dm_mod snd_hda_intel snd_seq_dummy sr_mod snd_seq_oss cdrom snd_seq_midi_event snd_seq snd_seq_device snd_pcm_oss snd_mixer_oss snd_pcm snd_timer snd_page_alloc snd_hwdep snd pcspkr serio_raw k8temp hwmon forcedeth soundcore pata_amd sg jedec_probe cfi_probe gen_probe mtd i2c_nforce2 chipreg i2c_core button map_funcs sata_nv ata_generic pata_acpi libata sd_mod scsi_mod ext3 jbd mbcache uhci_hcd ohci_hcd ehci_hcd [last unloaded: scsi_wait_scan]
Nov  4 14:14:32 tl1 kernel: Pid: 3405, comm: nfsv4.1-svc Tainted: P          2.6.27-pnfs #1
Nov  4 14:14:32 tl1 kernel: RIP: 0010:[<ffffffffa02b4dd2>]  [<ffffffffa02b4dd2>] call_status+0xe1/0x145 [sunrpc]
Nov  4 14:14:32 tl1 kernel: RSP: 0018:ffff88002a70bd60  EFLAGS: 00010246
Nov  4 14:14:32 tl1 kernel: RAX: 0000000000000000 RBX: 00000000ffffff95 RCX: 0000000000000000
Nov  4 14:14:32 tl1 kernel: RDX: ffff88002a70bd10 RSI: ffff88002fc52dc0 RDI: ffff88002fc52dc0
Nov  4 14:14:32 tl1 kernel: RBP: ffff88002a70bd80 R08: ffff88002f9dae40 R09: ffffffff81489e60
Nov  4 14:14:32 tl1 kernel: R10: ffff880038497800 R11: ffff88002a70bd30 R12: ffff88002fc52dc0
Nov  4 14:14:32 tl1 kernel: R13: 0000000000000000 R14: ffff88002f57fa00 R15: ffff88002fc52e50
Nov  4 14:14:32 tl1 kernel: FS:  00007fe78ffac6f0(0000) GS:ffffffff8148da80(0000) knlGS:0000000000000000
Nov  4 14:14:32 tl1 kernel: CS:  0010 DS: 0018 ES: 0018 CR0: 000000008005003b
Nov  4 14:14:32 tl1 kernel: CR2: 0000000000000078 CR3: 000000002f971000 CR4: 00000000000006e0
Nov  4 14:14:32 tl1 kernel: DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
Nov  4 14:14:32 tl1 kernel: DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
Nov  4 14:14:32 tl1 kernel: Process nfsv4.1-svc (pid: 3405, threadinfo ffff88002a70a000, task ffff88003694d900)
Nov  4 14:14:32 tl1 kernel: Stack:  0000000000000000 ffff88002f57fa00 ffff88002fc52dc0 ffff880030450ce8
Nov  4 14:14:32 tl1 kernel: ffff88002a70bdc0 ffffffffa02bb9db ffff88002a70bdf0 ffff88002fc52dc0
Nov  4 14:14:32 tl1 kernel: ffff88002f57fa00 ffff88002f57fa00 ffff880030450ce8 ffff88002a734000
Nov  4 14:14:32 tl1 kernel: Call Trace:
Nov  4 14:14:32 tl1 kernel: [<ffffffffa02bb9db>] __rpc_execute+0x7e/0x21f [sunrpc]
Nov  4 14:14:32 tl1 kernel: [<ffffffffa02bbba4>] rpc_execute+0x28/0x2c [sunrpc]
Nov  4 14:14:32 tl1 kernel: [<ffffffffa02b5596>] rpc_run_bc_task+0x88/0xae [sunrpc]
Nov  4 14:14:32 tl1 kernel: [<ffffffffa02c923d>] bc_send+0x35/0x5a [sunrpc]
Nov  4 14:14:32 tl1 kernel: [<ffffffffa02bdc92>] bc_svc_process+0xf6/0x101 [sunrpc]
Nov  4 14:14:32 tl1 kernel: [<ffffffff81048a6c>] ? prepare_to_wait+0x5c/0x65
Nov  4 14:14:32 tl1 kernel: [<ffffffffa033a4c9>] nfs41_callback_svc+0xda/0x131 [nfs]
Nov  4 14:14:32 tl1 kernel: [<ffffffff810488a0>] ? autoremove_wake_function+0x0/0x38
Nov  4 14:14:32 tl1 kernel: [<ffffffffa033a3ef>] ? nfs41_callback_svc+0x0/0x131 [nfs]
Nov  4 14:14:32 tl1 kernel: [<ffffffff81048561>] kthread+0x49/0x76
Nov  4 14:14:32 tl1 kernel: [<ffffffff8100cf49>] child_rip+0xa/0x11
Nov  4 14:14:32 tl1 kernel: [<ffffffff8102a401>] ? pick_next_task_fair+0x93/0xa3
Nov  4 14:14:32 tl1 kernel: [<ffffffff81048518>] ? kthread+0x0/0x76
Nov  4 14:14:32 tl1 kernel: [<ffffffff8100cf3f>] ? child_rip+0x0/0x11
Nov  4 14:14:32 tl1 kernel:
Nov  4 14:14:32 tl1 kernel:
Nov  4 14:14:32 tl1 kernel: Code: e8 7c 70 00 00 49 8b 44 24 20 49 c7 44 24 68 dc 48 2b a0 f6 40 78 02 74 6d 41 8b b6 34 01 00 00 48 8b 78 30 e8 b9 2a 00 00 eb 5b <41> f6 45 78 04 74 13 49 8b 55 30 48 8d 82 80 04 00 00 f0 80 a2
Nov  4 14:14:32 tl1 kernel: RIP  [<ffffffffa02b4dd2>] call_status+0xe1/0x145 [sunrpc]
Nov  4 14:14:32 tl1 kernel: RSP <ffff88002a70bd60>
Nov  4 14:14:32 tl1 kernel: CR2: 0000000000000078
Nov  4 14:14:32 tl1 kernel: ---[ end trace 1584c489f2573aaf ]---

Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 net/sunrpc/clnt.c |    8 +++++---
 1 files changed, 5 insertions(+), 3 deletions(-)

diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
index f5418ac..fcadd8e 100644
--- a/net/sunrpc/clnt.c
+++ b/net/sunrpc/clnt.c
@@ -1204,7 +1204,8 @@ call_status(struct rpc_task *task)
 		break;
 	case -ECONNREFUSED:
 	case -ENOTCONN:
-		rpc_force_rebind(clnt);
+		if (clnt)
+			rpc_force_rebind(clnt);
 		task->tk_action = call_bind;
 		break;
 	case -EAGAIN:
@@ -1215,9 +1216,10 @@ call_status(struct rpc_task *task)
 		rpc_exit(task, status);
 		break;
 	default:
-		if (clnt->cl_chatty)
+		if (!clnt || clnt->cl_chatty)
 			printk("%s: RPC call returned error %d\n",
-			       clnt->cl_protname, -status);
+			       clnt ? clnt->cl_protname : "<unknown protocol>",
+			       -status);
 		rpc_exit(task, status);
 	}
 }
-- 
1.6.0.2

