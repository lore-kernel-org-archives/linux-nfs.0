Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet10.oracle.com ([148.87.113.121]:17450 "EHLO
	rcsinet10.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752530Ab1ASMzz (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 19 Jan 2011 07:55:55 -0500
Message-Id: <201101191255.p0JCtneP008444@rcsinet15.oracle.com>
Date: Wed, 19 Jan 2011 20:53:54 +0800
From: Wengang Wang <wen.gang.wang@oracle.com>
Subject: [PATCH] nfs: don't drop kiocb->ki_users in error case
To: Chuck Lever <chuck.lever@oracle.com>
Cc: Nick Piggin <npiggin@gmail.com>,
        Trond Myklebust <Trond.Myklebust@netapp.com>,
        linux-fsdevel <linux-fsdevel@vger.kernel.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>, joe.jin@oracle.com,
        greg.marsden@oracle.com
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

I got the crash when test with fio + (ctrl-C). The panic info is like this:

------------[ cut here ]------------
kernel BUG at fs/aio.c:558!
invalid opcode: 0000 [#1] SMP
last sysfs file: /sys/devices/system/cpu/cpu0/cache/index0/coherency_line_size
CPU 0
Modules linked in: netconsole(U) configfs(U) hidp(U) l2cap(U) bluetooth(U) rfkill(U) ipv6(U) nfs(U) lockd(U) fscache(U) nfs_acl(U) auth_rpcgss(U) sunrpc(U) cpufreq_ondemand(U) acpi_cpufreq(U) freq_table(U) dm_multipath(U) sbs(U) sbshc(U) lp(U) snd_hda_codec_analog(U) snd_hda_intel(U) snd_hda_codec(U) snd_hwdep(U) snd_seq_dummy(U) snd_seq_oss(U) i915(U) snd_seq_midi_event(U) snd_seq(U) snd_seq_device(U) snd_pcm_oss(U) drm_kms_helper(U) snd_mixer_oss(U) drm(U) tg3(U) snd_pcm(U) snd_timer(U) snd(U) parport_pc(U) i2c_algo_bit(U) i2c_i801(U) serio_raw(U) parport(U) iTCO_wdt(U) shpchp(U) soundcore(U) video(U) i2c_core(U) dcdbas(U) iTCO_vendor_support(U) snd_page_alloc(U) pcspkr(U) output(U) pata_acpi(U) ata_piix(U) ata_generic(U) uhci_hcd(U) ohci_hcd(U) ehci_hcd(U) [last unloaded: netconsole]
Pid: 3112, comm: fio Tainted: G        W  2.6.32.21 #3 OptiPlex 745
RIP: 0010:[<ffffffff8114eb30>]  [<ffffffff8114eb30>] __aio_put_req+0x6e/0x150
RSP: 0018:ffff88006cd7be38  EFLAGS: 00010092
RAX: 0000000000000038 RBX: ffff880078f2b9c0 RCX: 0000000000007da3
RDX: 0000000000000000 RSI: 0000000000000082 RDI: 0000000000000046
RBP: ffff88006cd7be58 R08: 0000000000000001 R09: 0000000000000020
R10: ffff88006cd7bdb8 R11: 0000000000000001 R12: ffff880078f2b9c0
R13: ffff880037ef3e40 R14: ffff880037ef3e40 R15: 0000000000000000
FS:  0000000042eb4940(0063) GS:ffff880001c00000(0000) knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
CR2: 00007fa172484000 CR3: 000000006ce48000 CR4: 00000000000006f0
DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
Process fio (pid: 3112, threadinfo ffff88006cd7a000, task ffff88007a7de040)
Stack:
 ffff880037ef3e40 ffff880037ef3e40 ffff880078f2b9c0 ffff88006cd7bf40
<0> ffff88006cd7be88 ffffffff8114ec3d ffff88006bc11ed0 ffff880078f2b9c0
<0> ffff88006bc11ed0 ffff880078f2b9c0 ffff88006cd7bf78 ffffffff81150a15
Call Trace:
 [<ffffffff8114ec3d>] aio_put_req+0x2b/0x43
 [<ffffffff81150a15>] sys_io_submit+0x56a/0x6f1
 [<ffffffff81011db2>] system_call_fastpath+0x16/0x1b
Code: 7f 45 81 e8 a9 8d f0 ff e8 32 6d ec ff 83 7b 18 00 7d 1c 48 89 da 48 c7 c6 58 7f 45 81 48 c7 c7 d4 b1 5d 81 31 c0 e8 86 8d f0 ff <0f> 0b eb fe 74 07 31 c0 e9 cd 00 00 00 4c 8d a3 d8 00 00 00 48
RIP  [<ffffffff8114eb30>] __aio_put_req+0x6e/0x150
 RSP <ffff88006cd7be38>
---[ end trace 52431c8b3d9e71ba ]---
Kernel panic - not syncing: Fatal exception

The number 558 should be 552 in original codes. It is the
	BUG_ON(req->ki_users < 0);
in __aio_put_req().

My analysis is(correct me):
In the sys_io_submit path, the vfs doesn't hope the FS under ground drop the
ki_users in "error" case. The error is -ERESTARTSYS, in my test, instead of
-EIOCBQUEUED. But seems the nfs drops ki_users in error case as well as
in successful cases too.

So my first attempt is coming for discussion.
Basically, it makes nfs don't drop(actually it gets then puts) ki_users in error
cases.
Let the nfs_direct_req.error records the error from get_user_pages() and
rpc_run_task() in nfs_direct_read/write path, assuming both the two function
returns all error they hit. And in nfs_direct_complete(), if error occured(per
nfs_direct_req.error), take another ref on kiocb->ki_users. (and then drop it in
aio_complete in existing codes).

Signed-off-by: Wengang Wang <wen.gang.wang@oracle.com>
---
 fs/nfs/direct.c |   21 +++++++++++++++++++--
 1 files changed, 19 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/direct.c b/fs/nfs/direct.c
index e6ace0d..fa5e5f9 100644
--- a/fs/nfs/direct.c
+++ b/fs/nfs/direct.c
@@ -219,6 +219,17 @@ static void nfs_direct_complete(struct nfs_direct_req *dreq)
 		long res = (long) dreq->error;
 		if (!res)
 			res = (long) dreq->count;
+		/*
+		 * vfs doesn't want us drop kiocb->ki_users in error case.
+		 * we get an extra ref on it then later drop it in aio_complete
+		 */
+		if (dreq->error) {
+			struct kioctx *ctx = dreq->iocb->ki_ctx;
+
+			spin_lock_irq(&ctx->ctx_lock);
+			dreq->iocb->ki_users ++;
+			spin_unlock_irq(&ctx->ctx_lock);
+		}
 		aio_complete(dreq->iocb, res, 0);
 	}
 	complete_all(&dreq->completion);
@@ -319,6 +330,7 @@ static ssize_t nfs_direct_read_schedule_segment(struct nfs_direct_req *dreq,
 					data->npages, 1, 0, data->pagevec, NULL);
 		up_read(&current->mm->mmap_sem);
 		if (result < 0) {
+			dreq->error = result;
 			nfs_readdata_free(data);
 			break;
 		}
@@ -357,8 +369,10 @@ static ssize_t nfs_direct_read_schedule_segment(struct nfs_direct_req *dreq,
 		NFS_PROTO(inode)->read_setup(data, &msg);
 
 		task = rpc_run_task(&task_setup_data);
-		if (IS_ERR(task))
+		if (IS_ERR(task)) {
+			dreq->error = PTR_ERR(task);
 			break;
+		}
 		rpc_put_task(task);
 
 		dprintk("NFS: %5u initiated direct read call "
@@ -748,6 +762,7 @@ static ssize_t nfs_direct_write_schedule_segment(struct nfs_direct_req *dreq,
 					data->npages, 0, 0, data->pagevec, NULL);
 		up_read(&current->mm->mmap_sem);
 		if (result < 0) {
+			dreq->error = result;
 			nfs_writedata_free(data);
 			break;
 		}
@@ -789,8 +804,10 @@ static ssize_t nfs_direct_write_schedule_segment(struct nfs_direct_req *dreq,
 		NFS_PROTO(inode)->write_setup(data, &msg);
 
 		task = rpc_run_task(&task_setup_data);
-		if (IS_ERR(task))
+		if (IS_ERR(task)) {
+			dreq->error = PTR_ERR(task);
 			break;
+		}
 		rpc_put_task(task);
 
 		dprintk("NFS: %5u initiated direct write call "
-- 
1.7.2.3

