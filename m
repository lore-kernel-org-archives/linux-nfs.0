Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:44366 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750828Ab1BVVyh (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 22 Feb 2011 16:54:37 -0500
Subject: BUG in xs_tcp_setup_socket in 2.6.38-rc5
From: Ben Hutchings <bhutchings@solarflare.com>
To: Trond Myklebust <Trond.Myklebust@netapp.com>,
        Pavel Emelyanov <xemul@parallels.com>
Cc: Ravi Aravapalli <raravapalli@solarflare.com>,
        linux-nfs <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
Date: Tue, 22 Feb 2011 21:54:34 +0000
Message-ID: <1298411674.14956.25.camel@bwh-desktop>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Ravi was running some automated stress tests on Linux 2.6.38-rc5,
primarily looking for regressions in the sfc driver.  However he saw the
following crash which doesn't look related to the driver.

The test systems mount various directories using NFSv3 and autofs, and
it looks as if sunrpc is handling an error condition wrongly.

BUG: unable to handle kernel NULL pointer dereference at 0000000000000020
IP: [<ffffffffa05b5e08>] xs_tcp_setup_socket+0x348/0x4a0 [sunrpc]
PGD 0 
Oops: 0000 [#1] SMP 
last sysfs file: /sys/devices/pci0000:00/0000:00:1c.0/0000:02:00.0/0000:03:00.0/irq
CPU 0 
Modules linked in: netconsole configfs nfs lockd fscache nfs_acl auth_rpcgss ip6table_filter ip6_tables ebtable_nat ebtables ipt_MASQUERADE iptable_nat nf_nat bridge stp llc autofs4 sunrpc be2iscsi iscsi_boot_sysfs bnx2i cnic uio cxgb3i libcxgbi cxgb3 ib_iser rdma_cm ib_cm iw_cm ib_sa ib_mad ib_core ib_addr ipv6 iscsi_tcp libiscsi_tcp libiscsi scsi_transport_iscsi ext2 dm_mirror dm_region_hash dm_log dm_mod vhost_net macvtap macvlan tun kvm_intel kvm uinput bnx2 sg dcdbas serio_raw pcspkr iTCO_wdt iTCO_vendor_support i5k_amb i5000_edac edac_core ioatdma dca sfc mtd mdio shpchp ext3 jbd mbcache sr_mod cdrom sd_mod crc_t10dif pata_acpi ata_generic ata_piix mptsas mptscsih mptbase scsi_transport_sas radeon ttm drm_kms_helper drm hwmon i2c_algo_bit i2c_core [last unloaded: speedstep_lib]
Pid: 10, comm: kworker/0:1 Not tainted 2.6.38-rc5 #3 Dell Inc. PowerEdge 2950/0CX396
RIP: 0010:[<ffffffffa05b5e08>]  [<ffffffffa05b5e08>] xs_tcp_setup_socket+0x348/0x4a0 [sunrpc]
RSP: 0018:ffff880126c11da0  EFLAGS: 00010246
RAX: 0000000000000000 RBX: ffff8801220ee000 RCX: 0000000100016909
RDX: 000000000000001e RSI: ffff880123065a80 RDI: 0000000000000000
RBP: ffff880126c11df0 R08: f018000000000000 R09: febef9edc98abe03
R10: 0000000000000480 R11: 0000000000000000 R12: ffff8801220ee680
R13: ffffe8ffffc0dd00 R14: 0000000000000000 R15: 0000000000000000
FS:  0000000000000000(0000) GS:ffff8800cf800000(0000) knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
CR2: 0000000000000020 CR3: 000000012191f000 CR4: 00000000000006f0
DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
Process kworker/0:1 (pid: 10, threadinfo ffff880126c10000, task ffff880126c0f560)
Stack:
 0000000000014e80 ffff880126c0f560 ffff880126c0faf0 00000000c17d7567
 ffff880126c0faf8 ffff8801273cbc40 ffff8800cf811040 ffffe8ffffc0dd00
 ffffffffa05b5ac0 0000000000000000 ffff880126c11e50 ffffffff8107b884
Call Trace:
 [<ffffffffa05b5ac0>] ? xs_tcp_setup_socket+0x0/0x4a0 [sunrpc]
 [<ffffffff8107b884>] process_one_work+0x124/0x430
 [<ffffffff8107e1d1>] worker_thread+0x181/0x3c0
 [<ffffffff8107e050>] ? worker_thread+0x0/0x3c0
 [<ffffffff810828c6>] kthread+0x96/0xa0
 [<ffffffff8100cdc4>] kernel_thread_helper+0x4/0x10
 [<ffffffff81082830>] ? kthread+0x0/0xa0
 [<ffffffff8100cdc0>] ? kernel_thread_helper+0x0/0x10
Code: 0f 1f 00 0f 84 3a ff ff ff e9 4b fe ff ff 0f 1f 44 00 00 41 83 fd 91 0f 85 3c fe ff ff 66 0f 1f 44 00 00 e9 1b ff ff ff 0f 1f 00 <4d> 8b 6e 20 4d 8d bd 68 01 00 00 4c 89 ff e8 45 99 f0 e0 49 8b 
RIP  [<ffffffffa05b5e08>] xs_tcp_setup_socket+0x348/0x4a0 [sunrpc]
 RSP <ffff880126c11da0>
CR2: 0000000000000020
---[ end trace 6efc43bb9b1264f8 ]---

The code dump alone is pretty useless as the IP is at the start of a
block, but having disassembled the entire sunrpc module it appears that
it corresponds to:

static int xs_tcp_finish_connecting(struct rpc_xprt *xprt, struct socket *sock)
{
	struct sock_xprt *transport = container_of(xprt, struct sock_xprt, xprt);

	if (!transport->inet) {
		struct sock *sk = sock->sk; /* <-- this line */

		write_lock_bh(&sk->sk_callback_lock);

I think the bug is that xs_create_sock() returns 0 if xs_bind() fails.

This bug appears to have been introduced in 2.6.37 by:

commit b65c0310611af73569f94c526a1e2323d99b380a
Author: Pavel Emelyanov <xemul@parallels.com>
Date:   Mon Oct 4 16:53:46 2010 +0400

    sunrpc: Factor out udp sockets creation

commit 22f793268de3b4dff8abfcd873ba7afc1f34224f
Author: Pavel Emelyanov <xemul@parallels.com>
Date:   Mon Oct 4 16:54:26 2010 +0400

    sunrpc: Factor out v4 sockets creation

commit 22d44a7d8a03456aa6d0a047c051aa28728e6ecd
Author: Pavel Emelyanov <xemul@parallels.com>
Date:   Mon Oct 4 16:54:55 2010 +0400

    sunrpc: Factor out v6 sockets creation

The following (untested) patch should fix this.

Ben.

---
From: Ben Hutchings <bhutchings@solarflare.com>
Date: Tue, 22 Feb 2011 21:49:44 +0000
Subject: [PATCH net-next-2.6] sunrpc: Propagate errors from xs_bind() through xs_create_sock()

xs_create_sock() is supposed to return a pointer or an ERR_PTR-encoded
error, but it currently returns 0 if xs_bind() fails.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
Cc: stable@kernel.org [v2.6.37]
---
 net/sunrpc/xprtsock.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
index c431f5a..be96d42 100644
--- a/net/sunrpc/xprtsock.c
+++ b/net/sunrpc/xprtsock.c
@@ -1631,7 +1631,8 @@ static struct socket *xs_create_sock(struct rpc_xprt *xprt,
 	}
 	xs_reclassify_socket(family, sock);
 
-	if (xs_bind(transport, sock)) {
+	err = xs_bind(transport, sock);
+	if (err) {
 		sock_release(sock);
 		goto out;
 	}
-- 
1.7.4


-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

