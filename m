Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cn.fujitsu.com ([222.73.24.84]:61926 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1756445Ab1LBDFF (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 1 Dec 2011 22:05:05 -0500
Received: from tang.cn.fujitsu.com (tang.cn.fujitsu.com [10.167.250.3])
	by song.cn.fujitsu.com (Postfix) with ESMTP id B6F31170095
	for <linux-nfs@vger.kernel.org>; Fri,  2 Dec 2011 11:05:02 +0800 (CST)
Received: from mailserver.fnst.cn.fujitsu.com (tang.cn.fujitsu.com [127.0.0.1])
	by tang.cn.fujitsu.com (8.14.3/8.13.1) with ESMTP id pB23519m003856
	for <linux-nfs@vger.kernel.org>; Fri, 2 Dec 2011 11:05:02 +0800
Message-ID: <4ED841EF.2010509@cn.fujitsu.com>
Date: Fri, 02 Dec 2011 11:11:43 +0800
From: Fu Liankun <fuliankun@cn.fujitsu.com>
MIME-Version: 1.0
To: linux-nfs@vger.kernel.org
Subject: [PATCH] pnfsd:use NULL pointer cause kernel oops in function __nfs4_lock_state
Content-Type: text/plain; charset=ISO-2022-JP
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

When I use PNFS to create an big file, the DS oops。Using NULL
pointer "client_mutex_owner" in function __nfs4_lock_state caused
the kernel oops.

Below is the log:

kernel: [  950.164182] state lock taken by pid=1354 func=nfsd4_write
kernel: [  950.731544] BUG: unable to handle kernel NULL pointer dereference at
00000204
kernel: [  950.731606] IP: [<fa2fe533>] __nfs4_lock_state+0x2a/0x61 [nfsd]
kernel: [  950.731682] *pde = 00000000
kernel: [  950.731694] Oops: 0000 [#1] SMP
kernel: [  950.731711] Modules linked in: nfsd lockd exportfs nfs_acl
auth_rpcgss sunrpc p4_clockmod freq_table speedstep_lib ipv6 uinput snd_intel8x0
snd_ac97_codec ac97_bus snd_seq snd_seq_device snd_pcm ppdev snd_timer sis900
parport_pc parport snd r8169 mii soundcore snd_page_alloc microcode serio_raw
pcspkr sata_sis ata_generic pata_acpi pata_sis [last unloaded: mperf]
kernel: [  950.731840]
kernel: [  950.731847] Pid: 1359, comm: nfsd Not tainted 3.1.0-rc8-pnfs+ #1 Acer
Aspire SA80/E661GXM
kernel: [  950.731877] EIP: 0060:[<fa2fe533>] EFLAGS: 00010246 CPU: 0
kernel: [  950.731907] EIP is at __nfs4_lock_state+0x2a/0x61 [nfsd]
kernel: [  950.731922] EAX: 00000000 EBX: fa30c1f0 ECX: 00000000 EDX: fa313468
kernel: [  950.731939] ESI: f46f7820 EDI: fa2f4e1c EBP: f4753e74 ESP: f4753e64
kernel: [  950.731956]  DS: 007b ES: 007b FS: 00d8 GS: 00e0 SS: 0068
kernel: [  950.731971] Process nfsd (pid: 1359, ti=f4752000 task=f5677110
task.ti=f4752000)
kernel: [  950.731990] Stack:
kernel: [  950.732014]  f6b414e0 f47a7ac0 fa30c1f0 f46f7220 f4753ecc fa2f4e5b
00000002 f46f782c
kernel: [  950.732014]  f601d000 f46f7800 f46f7050 fa2f5fde f4753ecc fa2fcf7c
f9a0a2dc fffffffe
kernel: [  950.732014]  f601d000 f40900ac f46f7834 f4753ecc fa2f5396 00000000
f407b054 f46f7800
kernel: [  950.732014] Call Trace:
kernel: [  950.732014]  [<fa2f4e5b>] nfsd4_write+0x3f/0x1ba [nfsd]
kernel: [  950.732014]  [<fa2f5fde>] ? encode_seqid_op_tail+0x48/0x48 [nfsd]
kernel: [  950.732014]  [<fa2fcf7c>] ? nfsd4_encode_operation+0x57/0x132 [nfsd]
kernel: [  950.732014]  [<fa2f5396>] ? nfsd4_putfh+0x3d/0x44 [nfsd]
kernel: [  950.732014]  [<fa2f4e1c>] ? nfsd4_get_verifier+0x33/0x33 [nfsd]
kernel: [  950.732014]  [<fa2f4303>] nfsd4_proc_compound+0x212/0x3bf [nfsd]
kernel: [  950.732014]  [<c105727a>] ? groups_alloc+0x35/0x9f
kernel: [  950.732014]  [<fa2e8750>] nfsd_dispatch+0xd5/0x1ab [nfsd]
kernel: [  950.732014]  [<f99f7595>] svc_process_common+0x289/0x487 [sunrpc]
kernel: [  950.732014]  [<f9a01dcf>] ? svc_xprt_received+0x2f/0x32 [sunrpc]
kernel: [  950.732014]  [<f9a02886>] ? svc_recv+0x63c/0x689 [sunrpc]
kernel: [  950.732014]  [<f99f7964>] svc_process+0xe2/0x100 [sunrpc]
kernel: [  950.732014]  [<fa2e8108>] nfsd+0xdf/0x119 [nfsd]
kernel: [  950.732014]  [<c102911c>] ? complete+0x47/0x4e
kernel: [  950.732014]  [<fa2e8029>] ? nfsd_shutdown+0x29/0x29 [nfsd]
kernel: [  950.732014]  [<c1050cd5>] kthread+0x67/0x6c
kernel: [  950.732014]  [<c1050c6e>] ? kthread_worker_fn+0x11d/0x11d
kernel: [  950.732014]  [<c13ee03e>] kernel_thread_helper+0x6/0x10
kernel: [  950.732014] Code: c3 55 89 e5 53 83 ec 0c 3e 8d 74 26 00 89 c3 b8 68
34 31 fa e8 4c 91 0e c7 85 c0 75 2e a1 50 af 31 fa 89 44 24 08 a1 88 54 31 fa
<8b> 80 04 02 00 00 c7 04 24 c4 ee 30 fa 89 44 24 04 e8 e7 82 0e
kernel: [  950.732014] EIP: [<fa2fe533>] __nfs4_lock_state+0x2a/0x61 [nfsd]
SS:ESP 0068:f4753e64
kernel: [  950.732014] CR2: 0000000000000204
kernel: [  950.735220] ---[ end trace b1bae82b987c9a28 ]---

The kernel run as like below will caused oops.

void
nfs4_unlock_state(void)
{
	client_mutex_owner = NULL;   ===>after this sentence, CPU schedule.
	mutex_unlock(&client_mutex);
}

void
__nfs4_lock_state(const char *func)
{
	if (!mutex_trylock(&client_mutex)) {    =========> will fail here.

 ****"client_mutex_owner" is NULL,.then kernel oops when execute "printk "****

		printk("state lock taken by pid=%d func=%s\n",
		      task_pid_nr(client_mutex_owner),
		       client_mutex_func);
		mutex_lock(&client_mutex);
	}
	client_mutex_owner = current;
	client_mutex_func = func;
}

Signed-off-by: Fu Liankun <fuliankun@cn.fujitsu.com>
---
 fs/nfsd/nfs4state.c |    7 +------
 1 files changed, 1 insertions(+), 6 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 5181598..71f00b7 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -88,12 +88,7 @@ static struct kmem_cache *deleg_slab = NULL;
 void
 __nfs4_lock_state(const char *func)
 {
-	if (!mutex_trylock(&client_mutex)) {
-		printk("state lock taken by pid=%d func=%s\n",
-		       task_pid_nr(client_mutex_owner),
-		       client_mutex_func);
-		mutex_lock(&client_mutex);
-	}
+	mutex_lock(&client_mutex);
 	client_mutex_owner = current;
 	client_mutex_func = func;
 }
-- 1.7.3.1
