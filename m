Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail.ims.co.at ([81.223.138.19]:51195 "EHLO mail.ims.co.at"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1162376AbaDCHZk (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 3 Apr 2014 03:25:40 -0400
Received: from localhost (localhost [127.0.0.1])
	by mail.ims.co.at (Postfix) with ESMTP id 6715613D5B
	for <linux-nfs@vger.kernel.org>; Thu,  3 Apr 2014 09:19:38 +0200 (CEST)
Received: from mail.ims.co.at ([127.0.0.1])
	by localhost (mail.ims.co.at [127.0.0.1]) (amavisd-new, port 10024)
	with LMTP id FNXZNfJEpU1c for <linux-nfs@vger.kernel.org>;
	Thu,  3 Apr 2014 09:19:26 +0200 (CEST)
Received: from imap.ims.co.at (imap.ims.co.at [192.168.100.12])
	by mail.ims.co.at (Postfix) with ESMTP id B956213D5B
	for <linux-nfs@vger.kernel.org>; Thu,  3 Apr 2014 09:19:26 +0200 (CEST)
Received: from [192.168.100.167] (pc-52-ks.ims.co.at [192.168.100.167])
	by imap.ims.co.at (Postfix) with ESMTPSA id C382A210D3AB
	for <linux-nfs@vger.kernel.org>; Thu,  3 Apr 2014 09:19:26 +0200 (CEST)
Message-ID: <533D0B7E.50806@ims.co.at>
Date: Thu, 03 Apr 2014 09:19:26 +0200
From: Klemens Senn <klemens.senn@ims.co.at>
MIME-Version: 1.0
To: linux-nfs@vger.kernel.org
Subject: kernel soft lockup after stopping nfsd
References: <md5:9sC4QT4T8lFPdsGxv8Rq+w==>
In-Reply-To: <md5:9sC4QT4T8lFPdsGxv8Rq+w==>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi,

I am getting a kernel soft lockup on the server side if the client reads
data from a rdma mount after stopping the nfs server.

The export on the server side is done with
/data	*(fsid=0,crossmnt,rw,mp,no_root_squash,sync,no_subtree_check,insecure)

Following command is used for mounting the NFSv4 share:
mount -t nfs -o port=20049,rdma,vers=4.0,timeo=900 172.16.100.19:/ /mnt/

For my tests I used the vanilla kernel 3.10.34 with the nfsd patches
from Kinglong Mee and the nfsd-next kernel.

The traceback of the nfs-next kernel is

[  545.442326] BUG: soft lockup - CPU#0 stuck for 22s! [kworker/0:2:3124]
[  545.448861] Modules linked in: md5 nfsd auth_rpcgss oid_registry
svcrdma cpuid af_packet 8021q garp stp llc rdma_ucm ib_ucm rdma_cm iw_cm
ib_ipoib ib_cm ib_uverbs ib_umad mlx4_en mlx4_ib ib_sa ib_mad ib_core
ib_addr joydev usbhid mlx4_core x86_pkg_temp_thermal coretemp kvm_intel
kvm crc32c_intel ghash_clmulni_intel aesni_intel isci ehci_pci ehci_hcd
ablk_helper cryptd usbcore libsas lrw gf128mul glue_helper iTCO_wdt
aes_x86_64 iTCO_vendor_support sb_edac ioatdma edac_core lpc_ich
scsi_transport_sas i2c_i801 acpi_cpufreq sg pcspkr mfd_core tpm_tis
microcode usb_common tpm ipmi_si wmi ipmi_msghandler processor
thermal_sys button edd autofs4 xfs libcrc32c nfsv3 nfs fscache lockd
nfs_acl sunrpc igb dca i2c_algo_bit ptp pps_core
[  545.448920] CPU: 0 PID: 3124 Comm: kworker/0:2 Not tainted
3.14.0-rc8-net-next-master-20140323+ #1
[  545.448921] Hardware name: Supermicro B9DRG-E/B9DRG-E, BIOS 3.0
09/04/2013
[  545.448925] Workqueue: ib_cm cm_work_handler [ib_cm]
[  545.448926] task: ffff88085de02690 ti: ffff88087c056000 task.ti:
ffff88087c056000
[  545.448927] RIP: 0010:[<ffffffff815a5e37>]  [<ffffffff815a5e37>]
_raw_spin_lock_bh+0x27/0x40
[  545.448932] RSP: 0018:ffff88087c057c38  EFLAGS: 00000297
[  545.448933] RAX: 0000000000008810 RBX: ffffffff00000048 RCX:
0000000000000000
[  545.448934] RDX: 000000000000ffff RSI: 0000000000000000 RDI:
ffff8810590b0204
[  545.448935] RBP: ffff88087c057c38 R08: 000000000000000a R09:
0000000000000890
[  545.448936] R10: 0000000000000000 R11: 000000000000088f R12:
0000000000000246
[  545.448937] R13: ffff88087c057c18 R14: 0000000000000006 R15:
0000000000000048
[  545.448938] FS:  0000000000000000(0000) GS:ffff88087fc00000(0000)
knlGS:0000000000000000
[  545.448939] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[  545.448940] CR2: 0000000000eb90f8 CR3: 0000000001a0c000 CR4:
00000000000407f0
[  545.448941] Stack:
[  545.448942]  ffff88087c057c78 ffffffffa007be50 ffff88087c057c88
ffff880858679400
[  545.448944]  ffff88085879ec00 ffff88087c057cb0 0000000000000000
0000000000000000
[  545.448947]  ffff88087c057c98 ffffffffa04dbd5b ffff88085879ec00
ffff88085ddd1ce8
[  545.448949] Call Trace:
[  545.448963]  [<ffffffffa007be50>] svc_xprt_enqueue+0x50/0x220 [sunrpc]
[  545.448967]  [<ffffffffa04dbd5b>] rdma_cma_handler+0xdb/0x180 [svcrdma]
[  545.448970]  [<ffffffffa04bbd61>] cma_ib_handler+0xe1/0x210 [rdma_cm]
[  545.448972]  [<ffffffffa03825e0>] cm_process_work+0x20/0x110 [ib_cm]
[  545.448975]  [<ffffffffa0384a7b>] cm_work_handler+0x98b/0x10a8 [ib_cm]
[  545.448979]  [<ffffffff8106b5b7>] process_one_work+0x177/0x410
[  545.448981]  [<ffffffff8106bcda>] worker_thread+0x11a/0x370
[  545.448983]  [<ffffffff8106bbc0>] ? rescuer_thread+0x330/0x330
[  545.448985]  [<ffffffff810727d4>] kthread+0xc4/0xe0
[  545.448987]  [<ffffffff81072710>] ? flush_kthread_worker+0x70/0x70
[  545.448990]  [<ffffffff815addfc>] ret_from_fork+0x7c/0xb0
[  545.448991]  [<ffffffff81072710>] ? flush_kthread_worker+0x70/0x70
[  545.448992] Code: 75 f6 5d c3 55 65 81 04 25 e0 b8 00 00 00 02 00 00
48 89 e5 b8 00 00 01 00 f0 0f c1 07 89 c2 c1 ea 10 66 39 c2 75 04 5d c3
f3 90 <0f> b7 07 66 39 d0 75 f6 5d c3 66 66 66 66 66 66 2e 0f 1f 84 00

The last log messages are
[  507.831530] svc: __svc_unregister(nfsaclv3), error -107
[  507.831531] RPC:       shutting down rpcbind client for localhost
[  507.831532] RPC:       rpc_release_client(ffff88105d7b6600)
[  507.831533] RPC:       destroying rpcbind client for localhost
[  507.831537] RPC:       shutting down rpcbind client for localhost
[  507.831538] RPC:       rpc_release_client(ffff88105d939e00)
[  507.831539] RPC:       destroying rpcbind client for localhost
[  507.831540] RPC:       destroying transport ffff88105d81d800
[  507.831542] RPC:       xs_destroy xprt ffff88105d81d800
[  507.831543] RPC:       xs_close xprt ffff88105d81d800
[  507.831544] RPC:       disconnected transport ffff88105d81d800
[  507.831547] nfsd: last server has exited, flushing export cache
[  507.831563] svc: svc_destroy(nfsd, 1)
[  518.809147] svcrdma: Disconnect on DTO xprt=ffff880858679400,
cm_id=ffff88085879ec00


Following patch fixed the problem on both kernels:

---
 net/sunrpc/svc_xprt.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/net/sunrpc/svc_xprt.c b/net/sunrpc/svc_xprt.c
index 06c6ff0..0b68f32 100644
--- a/net/sunrpc/svc_xprt.c
+++ b/net/sunrpc/svc_xprt.c
@@ -328,6 +328,8 @@ static void svc_thread_dequeue(struct svc_pool
*pool, struct svc_rqst *rqstp)

 static bool svc_xprt_has_something_to_do(struct svc_xprt *xprt)
 {
+	if (xprt->xpt_flags & (1<<XPT_DEAD))
+		return false;
 	if (xprt->xpt_flags & ((1<<XPT_CONN)|(1<<XPT_CLOSE)))
 		return true;
 	if (xprt->xpt_flags & ((1<<XPT_DATA)|(1<<XPT_DEFERRED)))
-- 
1.8.1.4

Is this the correct place to fix the soft lockup?

Kind regards,
Klemens


