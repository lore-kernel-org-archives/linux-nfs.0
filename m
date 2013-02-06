Return-Path: linux-nfs-owner@vger.kernel.org
Received: from eu1sys200aog103.obsmtp.com ([207.126.144.115]:50527 "HELO
	eu1sys200aog103.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1753843Ab3BFPsW (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 6 Feb 2013 10:48:22 -0500
Message-ID: <51127B3F.2090200@mellanox.com>
Date: Wed, 6 Feb 2013 17:48:15 +0200
From: Yan Burman <yanb@mellanox.com>
MIME-Version: 1.0
To: <bfields@fieldses.org>
CC: <linux-nfs@vger.kernel.org>, <swise@opengridcomputing.com>,
        <linux-rdma@vger.kernel.org>, Or Gerlitz <ogerlitz@mellanox.com>
Subject: NFS over RDMA crashing
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi.

I have been trying to create a setup with NFS/RDMA, but I am getting 
crashes.

I am using Mellanox ConnectX 3 HCA with SRIOV enabled with two KVM VMs 
with RHEL 6.3 getting one VF each.
My test case is trying to use one VM's storage from another using NFS 
over RDMA (192.168.20.210 server, 192.168.20.211 client)
I started with two physical hosts, but because of crashes moved to VMs 
which are easier to debug.

I have functional ipoib connection between the two VMs and rping is 
working between them also.

My /etc/exports has the following entry:
/mnt/tmp        *(fsid=1,rw,async,insecure,all_squash)
while /mnt/tmp has tmpfs mounted on it.

My mount command is:
mount -t nfs -o rdma,port=2050 192.168.20.210:/mnt/tmp /mnt/tmp


I have tried latest net-next kernel first, but I was getting the 
following errors:

=============================================
[ INFO: possible recursive locking detected ]
3.8.0-rc5+ #4 Not tainted
---------------------------------------------
kworker/6:0/49 is trying to acquire lock:
  (&id_priv->handler_mutex){+.+.+.}, at: [<ffffffffa05e7813>] 
rdma_destroy_id+0x33/0x250 [rdma_cm]

but task is already holding lock:
  (&id_priv->handler_mutex){+.+.+.}, at: [<ffffffffa05e317b>] 
cma_disable_callback+0x2b/0x60 [rdma_cm]

other info that might help us debug this:
  Possible unsafe locking scenario:

        CPU0
        ----
   lock(&id_priv->handler_mutex);
   lock(&id_priv->handler_mutex);

  *** DEADLOCK ***

  May be due to missing lock nesting notation

3 locks held by kworker/6:0/49:
  #0:  (ib_cm){.+.+.+}, at: [<ffffffff81068f50>] 
process_one_work+0x160/0x720
  #1:  ((&(&work->work)->work)){+.+.+.}, at: [<ffffffff81068f50>] 
process_one_work+0x160/0x720
  #2:  (&id_priv->handler_mutex){+.+.+.}, at: [<ffffffffa05e317b>] 
cma_disable_callback+0x2b/0x60 [rdma_cm]

stack backtrace:
Pid: 49, comm: kworker/6:0 Not tainted 3.8.0-rc5+ #4
Call Trace:
  [<ffffffff8109f99c>] validate_chain+0xdcc/0x11f0
  [<ffffffff8109bdcf>] ? save_trace+0x3f/0xc0
  [<ffffffff810a0760>] __lock_acquire+0x440/0xc30
  [<ffffffff810a0760>] ? __lock_acquire+0x440/0xc30
  [<ffffffff810a0fe5>] lock_acquire+0x95/0x1e0
  [<ffffffffa05e7813>] ? rdma_destroy_id+0x33/0x250 [rdma_cm]
  [<ffffffffa05e7813>] ? rdma_destroy_id+0x33/0x250 [rdma_cm]
  [<ffffffff814a9aff>] mutex_lock_nested+0x5f/0x3b0
  [<ffffffffa05e7813>] ? rdma_destroy_id+0x33/0x250 [rdma_cm]
  [<ffffffff8109d68d>] ? trace_hardirqs_on_caller+0x10d/0x1a0
  [<ffffffff8109d72d>] ? trace_hardirqs_on+0xd/0x10
  [<ffffffff814aca3d>] ? _raw_spin_unlock_irqrestore+0x3d/0x80
  [<ffffffffa05e7813>] rdma_destroy_id+0x33/0x250 [rdma_cm]
  [<ffffffffa05e8f99>] cma_req_handler+0x719/0x730 [rdma_cm]
  [<ffffffff814aca04>] ? _raw_spin_unlock_irqrestore+0x4/0x80
  [<ffffffffa05d5772>] cm_process_work+0x22/0x170 [ib_cm]
  [<ffffffffa05d6acd>] cm_req_handler+0x67d/0xa70 [ib_cm]
  [<ffffffffa05d6fed>] cm_work_handler+0x12d/0x1218 [ib_cm]
  [<ffffffff81068fc2>] process_one_work+0x1d2/0x720
  [<ffffffff81068f50>] ? process_one_work+0x160/0x720
  [<ffffffffa05d6ec0>] ? cm_req_handler+0xa70/0xa70 [ib_cm]
  [<ffffffff81069930>] worker_thread+0x120/0x460
  [<ffffffff814ab4b4>] ? preempt_schedule+0x44/0x60
  [<ffffffff81069810>] ? manage_workers+0x300/0x300
  [<ffffffff81071df6>] kthread+0xd6/0xe0
  [<ffffffff81071d20>] ? __init_kthread_worker+0x70/0x70
  [<ffffffff814b462c>] ret_from_fork+0x7c/0xb0
  [<ffffffff81071d20>] ? __init_kthread_worker+0x70/0x70


When killing mount command that got stuck:
-------------------------------------------

BUG: unable to handle kernel paging request at ffff880324dc7ff8
IP: [<ffffffffa05f3dfb>] rdma_read_xdr+0x8bb/0xd40 [svcrdma]
PGD 1a0c063 PUD 32f82e063 PMD 32f2fd063 PTE 8000000324dc7161
Oops: 0003 [#1] PREEMPT SMP
Modules linked in: md5 ib_ipoib xprtrdma svcrdma rdma_cm ib_cm iw_cm 
ib_addr nfsd exportfs netconsole ip6table_filter ip6_tables 
iptable_filter ip_tables ebtable_nat nfsv3 nfs_acl ebtables x_tables 
nfsv4 auth_rpcgss nfs lockd autofs4 sunrpc target_core_iblock 
target_core_file target_core_pscsi target_core_mod configfs 8021q bridge 
stp llc ipv6 dm_mirror dm_region_hash dm_log vhost_net macvtap macvlan 
tun uinput iTCO_wdt iTCO_vendor_support kvm_intel kvm crc32c_intel 
microcode pcspkr joydev i2c_i801 lpc_ich mfd_core ehci_pci ehci_hcd sg 
ioatdma ixgbe mdio mlx4_ib ib_sa ib_mad ib_core mlx4_en mlx4_core igb 
hwmon dca ptp pps_core button dm_mod ext3 jbd sd_mod ata_piix libata 
uhci_hcd megaraid_sas scsi_mod
CPU 6
Pid: 4744, comm: nfsd Not tainted 3.8.0-rc5+ #4 Supermicro 
X8DTH-i/6/iF/6F/X8DTH
RIP: 0010:[<ffffffffa05f3dfb>]  [<ffffffffa05f3dfb>] 
rdma_read_xdr+0x8bb/0xd40 [svcrdma]
RSP: 0018:ffff880324c3dbf8  EFLAGS: 00010297
RAX: ffff880324dc8000 RBX: 0000000000000001 RCX: ffff880324dd8428
RDX: ffff880324dc7ff8 RSI: ffff880324dd8428 RDI: ffffffff81149618
RBP: ffff880324c3dd78 R08: 000060f9c0000860 R09: 0000000000000001
R10: ffff880324dd8000 R11: 0000000000000001 R12: ffff8806299dcb10
R13: 0000000000000003 R14: 0000000000000001 R15: 0000000000000010
FS:  0000000000000000(0000) GS:ffff88063fc00000(0000) knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
CR2: ffff880324dc7ff8 CR3: 0000000001a0b000 CR4: 00000000000007e0
DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
Process nfsd (pid: 4744, threadinfo ffff880324c3c000, task ffff880330550000)
Stack:
  ffff880324c3dc78 ffff880324c3dcd8 0000000000000282 ffff880631cec000
  ffff880324dd8000 ffff88062ed33040 0000000124c3dc48 ffff880324dd8000
  ffff88062ed33058 ffff880630ce2b90 ffff8806299e8000 0000000000000003
Call Trace:
  [<ffffffffa05f466e>] svc_rdma_recvfrom+0x3ee/0xd80 [svcrdma]
  [<ffffffff81086540>] ? try_to_wake_up+0x2f0/0x2f0
  [<ffffffffa045963f>] svc_recv+0x3ef/0x4b0 [sunrpc]
  [<ffffffffa0571db0>] ? nfsd_svc+0x740/0x740 [nfsd]
  [<ffffffffa0571e5d>] nfsd+0xad/0x130 [nfsd]
  [<ffffffffa0571db0>] ? nfsd_svc+0x740/0x740 [nfsd]
  [<ffffffff81071df6>] kthread+0xd6/0xe0
  [<ffffffff81071d20>] ? __init_kthread_worker+0x70/0x70
  [<ffffffff814b462c>] ret_from_fork+0x7c/0xb0
  [<ffffffff81071d20>] ? __init_kthread_worker+0x70/0x70
Code: 63 c2 49 8d 8c c2 18 02 00 00 48 39 ce 77 e1 49 8b 82 40 0a 00 00 
48 39 c6 0f 84 92 f7 ff ff 90 48 8d 50 f8 49 89 92 40 0a 00 00 <48> c7 
40 f8 00 00 00 00 49 8b 82 40 0a 00 00 49 3b 82 30 0a 00
RIP  [<ffffffffa05f3dfb>] rdma_read_xdr+0x8bb/0xd40 [svcrdma]
  RSP <ffff880324c3dbf8>
CR2: ffff880324dc7ff8
---[ end trace 06d0384754e9609a ]---


It seems that commit afc59400d6c65bad66d4ad0b2daf879cbff8e23e "nfsd4: 
cleanup: replace rq_resused count by rq_next_page pointer"
is responsible for the crash (it seems to be crashing in 
net/sunrpc/xprtrdma/svc_rdma_recvfrom.c:527)
It may be because I have CONFIG_DEBUG_SET_MODULE_RONX and 
CONFIG_DEBUG_RODATA enabled. I did not try to disable them yet.

When I moved to commit 79f77bf9a4e3dd5ead006b8f17e7c4ff07d8374e I was no 
longer getting the server crashes,
so the reset of my tests were done using that point (it is somewhere in 
the middle of 3.7.0-rc2).


Now, I was getting the client stuck on running following messages all 
over again:
rpcrdma: connection to 192.168.20.210:2050 on mlx4_0, memreg 6 slots 32 
ird 16
rpcrdma: connection to 192.168.20.210:2050 closed (-103)

The next step was to change the memory policy to RPCRDMA_ALLPHYSICAL, 
since there were IB_WC_LOC_ACCESS_ERR errors.
I found that doing "echo 6 > /proc/sys/sunrpc/rdma_memreg_strategy" was 
not enough.
We had to change the code a little bit for it to work. Here's the change 
for the test:

diff --git a/net/sunrpc/xprtrdma/svc_rdma_transport.c 
b/net/sunrpc/xprtrdma/svc_rdma_transport.c
index 62e4f9b..c660f61 100644
--- a/net/sunrpc/xprtrdma/svc_rdma_transport.c
+++ b/net/sunrpc/xprtrdma/svc_rdma_transport.c
@@ -970,6 +970,8 @@ static struct svc_xprt *svc_rdma_accept(struct 
svc_xprt *xprt)
  	 * NB:	iWARP requires remote write access for the data sink
  	 *	of an RDMA_READ. IB does not.
  	 */
+	devattr.device_cap_flags &= 
~(IB_DEVICE_MEM_MGT_EXTENSIONS|IB_DEVICE_LOCAL_DMA_LKEY);
+
  	if (devattr.device_cap_flags & IB_DEVICE_MEM_MGT_EXTENSIONS) {
  		newxprt->sc_frmr_pg_list_len =
  			devattr.max_fast_reg_page_list_len;
diff --git a/net/sunrpc/xprtrdma/verbs.c b/net/sunrpc/xprtrdma/verbs.c
index 745973b..0e3da28 100644
--- a/net/sunrpc/xprtrdma/verbs.c
+++ b/net/sunrpc/xprtrdma/verbs.c
@@ -488,10 +488,12 @@ rpcrdma_ia_open(struct rpcrdma_xprt *xprt, struct 
sockaddr *addr, int memreg)
  		goto out2;
  	}

+#if 0
  	if (devattr.device_cap_flags & IB_DEVICE_LOCAL_DMA_LKEY) {
  		ia->ri_have_dma_lkey = 1;
  		ia->ri_dma_lkey = ia->ri_id->device->local_dma_lkey;
  	}
+#endif

  	switch (memreg) {
  	case RPCRDMA_MEMWINDOWS:


Once changed to RPCRDMA_ALLPHYSICAL memory policy both on server and 
client, I was able to mount
successfully from the client, but when I tried to execute the following 
command: "dd if=/dev/zero of=/mnt/tmp/test bs=1M count=100"
I got crashes on the server side (worked fine with regular non-rdma mount).

Here's what I'm getting on the server with rpcdebug enabled:

svcrdma: rqstp=ffff88007bd76000
svcrdma: processing ctxt=ffff88007a3b9900 on xprt=ffff880079922000, 
rqstp=ffff88007bd76000, status=0
svc: transport ffff880079922000 busy, not enqueued
svc: got len=0
svc: transport ffff880079922000 served by daemon ffff88007bd74000
svc: transport ffff880079922000 busy, not enqueued
svc: server ffff88007bd76000 waiting for data (to = 900000)
svc: server ffff88007bd74000, pool 0, transport ffff880079922000, inuse=55
svcrdma: rqstp=ffff88007bd74000
svcrdma: deferred read ret=262312, rq_arg.len =263900, 
rq_arg.head[0].iov_base=ffff88007a3cb634, rq_arg.head[0].iov_len = 152
svc: got len=262312
svc: transport ffff880079922000 served by daemon ffff88007bd76000
svc: transport ffff880079922000 busy, not enqueued
general protection fault: 0000 [#1] PREEMPT SMP
Modules linked in: md5 xprtrdma svcrdma netconsole configfs nfsv3 nfsv4 
nfs ib_ipoib rdma_ucm ib_ucm ib_uverbs ib_umad rdma_cm ib_cm iw_cm 
ib_addr nfsd lockd nfs_acl auth_rpcgss exportfs autofs4 sunrpc 8021q 
ipv6 dm_mirror dm_region_hash dm_log uinput microcode joydev pcspkr 
mlx4_ib ib_sa ib_mad ib_core mlx4_en mlx4_core virtio_balloon cirrus ttm 
drm_kms_helper sysimgblt sysfillrect syscopyarea i2c_piix4 button dm_mod 
ext3 jbd virtio_blk virtio_net virtio_pci virtio_ring virtio uhci_hcd
CPU 1
Pid: 2479, comm: nfsd Not tainted 3.7.0-rc2+ #1 Red Hat KVM
RIP: 0010:[<ffffffffa024015f>]  [<ffffffffa024015f>] 
svc_process_common+0x6f/0x690 [sunrpc]
RSP: 0018:ffff88007b93fd98  EFLAGS: 00010212
RAX: 0000000000000000 RBX: ffff88007bd741d8 RCX: 000000003fbd438d
RDX: 0005080000000000 RSI: ffff88007bd74198 RDI: ffff88007bd74000
RBP: ffff88007b93fe08 R08: 0000000000000001 R09: 0000000000000000
R10: 0000000000000000 R11: 0000000000000000 R12: ffff88007bd74000
R13: ffff880037af2c70 R14: ffff88007b949000 R15: ffff88007bd74198
FS:  0000000000000000(0000) GS:ffff88007fd00000(0000) knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
CR2: 00007f8c86040000 CR3: 00000000799d7000 CR4: 00000000000006e0
DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
Process nfsd (pid: 2479, threadinfo ffff88007b93e000, task ffff880037af2c70)
Stack:
  ffff88007b949000 ffff880079922000 0000000000000000 ffff880079922038
  ffff88007b93fdd8 ffffffffa02524f4 0000000000000001 ffff88007bd74000
  ffff88007b93fe28 ffff88007bd74000 ffff88007b949000 ffff880037af2c70
Call Trace:
  [<ffffffffa02524f4>] ? svc_xprt_received+0x34/0x60 [sunrpc]
  [<ffffffffa029adb0>] ? nfsd_svc+0x740/0x740 [nfsd]
  [<ffffffffa0240abd>] svc_process+0xfd/0x150 [sunrpc]
  [<ffffffffa029ae6f>] nfsd+0xbf/0x130 [nfsd]
  [<ffffffffa029adb0>] ? nfsd_svc+0x740/0x740 [nfsd]
  [<ffffffff810724f6>] kthread+0xd6/0xe0
  [<ffffffff81072420>] ? __init_kthread_worker+0x70/0x70
  [<ffffffff814a9b6c>] ret_from_fork+0x7c/0xb0
  [<ffffffff81072420>] ? __init_kthread_worker+0x70/0x70
Code: 01 00 00 00 c7 87 88 01 00 00 01 00 00 00 c6 87 b8 1a 00 00 00 48 
8b 40 08 ff 50 20 48 8b 43 08 41 8b 8c 24 70 1a 00 00 48 8b 13 <89> 0c 
02 48 83 43 08 04 49 8b 17 8b 02 48 83 c2 04 49 83 6f 08
RIP  [<ffffffffa024015f>] svc_process_common+0x6f/0x690 [sunrpc]
  RSP <ffff88007b93fd98>
svc: transport ffff880079922000 busy, not enqueued
svc: transport ffff880079922000 busy, not enqueued
svc: server ffff88007bd76000, pool 0, transport ffff880079922000, inuse=4
svcrdma: rqstp=ffff88007bd76000
svcrdma: deferred read ret=262312, rq_arg.len =263900, 
rq_arg.head[0].iov_base=ffff88007a23a634, rq_arg.head[0].iov_len = 152
---[ end trace 46c56fc306f2fb0b ]---
svc: got len=262312
svc: transport ffff880079922000 served by daemon ffff88007bd72000
svc: server ffff88007bd72000, pool 0, transport ffff880079922000, inuse=5
svcrdma: rqstp=ffff88007bd72000
svcrdma: processing ctxt=ffff88007a3a4b00 on xprt=ffff880079922000, 
rqstp=ffff88007bd72000, status=0
svc: got len=0
svc: transport ffff880079922000 served by daemon ffff88007bd70000
svc: transport ffff880079922000 busy, not enqueued
svc: server ffff88007bd72000 waiting for data (to = 900000)
svc: server ffff88007bd70000, pool 0, transport ffff880079922000, inuse=70
svcrdma: rqstp=ffff88007bd70000
svcrdma: processing ctxt=ffff88007a3b8000 on xprt=ffff880079922000, 
rqstp=ffff88007bd70000, status=0

And the same crash continues...

Please advise

Yan

