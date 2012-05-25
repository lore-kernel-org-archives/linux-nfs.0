Return-Path: linux-nfs-owner@vger.kernel.org
Received: from natasha.panasas.com ([67.152.220.90]:47033 "EHLO
	natasha.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752344Ab2EYKNJ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 25 May 2012 06:13:09 -0400
Received: from zenyatta.panasas.com (zenyatta.int.panasas.com [172.17.28.63])
	by natasha.panasas.com (8.13.1/8.13.1) with ESMTP id q4PAD6Zm007064
	for <linux-nfs@vger.kernel.org>; Fri, 25 May 2012 06:13:07 -0400
Message-ID: <4FBF5B1F.4050904@panasas.com>
Date: Fri, 25 May 2012 13:12:47 +0300
From: Boaz Harrosh <bharrosh@panasas.com>
MIME-Version: 1.0
To: NFS list <linux-nfs@vger.kernel.org>
Subject: BUG: At key_instantiate_and_link+0x2e/0xa0
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

I got the below on a 3.4-rc7 based Benny's pnfs tree.

During normal nfs4 only operations. (Just my development trees mounted on client machine)

If it will happen again I will investigate. I'll leave it off for now (busy with other stuff)

Just wanted to know if it might have already been fix or seen by someone else

[ 3830.441139] BUG: unable to handle kernel NULL pointer dereference at 0000000000000078
[ 3830.442024] IP: [<ffffffff812894ce>] key_instantiate_and_link+0x2e/0xa0
[ 3830.442024] PGD 0 
[ 3830.442024] Oops: 0000 [#1] SMP 
[ 3830.442024] CPU 1 
[ 3830.442024] Modules linked in: osd libosd nfsd nfs lockd fscache auth_rpcgss nfs_acl sunrpc ip6t_REJECT be2iscsi nf_conntrack_ipv6 nf_defrag_ipv6 iscsi_boot_sysfs xt_state bnx2i nf_conntrack cnic uio cxgb3i libcxgbi cxgb3 mdio ip6table_filter ib_iser rdma_cm ib_cm iw_cm ib_sa ib_mad ib_core ib_addr ip6_tables iscsi_tcp libiscsi_tcp libiscsi scsi_transport_iscsi joydev virtio_balloon i2c_piix4 i2c_core pcspkr virtio_net microcode floppy virtio_blk [last unloaded: libosd]
[ 3830.442024] 
[ 3830.442024] Pid: 1288, comm: rpc.idmapd Not tainted 3.4.0-rc7-pnfs+ #50 Bochs Bochs
[ 3830.442024] RIP: 0010:[<ffffffff812894ce>]  [<ffffffff812894ce>] key_instantiate_and_link+0x2e/0xa0
[ 3830.442024] RSP: 0018:ffff88003a327d98  EFLAGS: 00010286
[ 3830.442024] RAX: 0000000000000002 RBX: 0000000000000000 RCX: ffff8800378579c0
[ 3830.442024] RDX: 0000000000000003 RSI: ffff88003a327e75 RDI: 0000000000000000
[ 3830.442024] RBP: ffff88003a327dd8 R08: ffff88003a26a9c0 R09: 000000000000fffd
[ 3830.442024] R10: 000000000000000a R11: 0000000000000246 R12: ffff8800378579c0
[ 3830.442024] R13: 0000000000000003 R14: ffff88003a327e75 R15: ffff88003a26a9c0
[ 3830.442024] FS:  00007f8c539d1720(0000) GS:ffff88003e500000(0000) knlGS:0000000000000000
[ 3830.442024] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[ 3830.442024] CR2: 0000000000000078 CR3: 00000000379fe000 CR4: 00000000000006e0
[ 3830.442024] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
[ 3830.442024] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
[ 3830.442024] Process rpc.idmapd (pid: 1288, threadinfo ffff88003a326000, task ffff88003a329710)
[ 3830.442024] Stack:
[ 3830.442024]  ffff88003a327de8 ffff88003a327da8 ffff88003a327dd8 ffffffffa01bfe8d
[ 3830.442024]  ffff8800399ce930 ffff880039ff1340 ffff88003a327dea 0000000000000000
[ 3830.442024]  ffff88003a327eb8 ffffffffa026360b 4073726573750101 2e736173616e6170
[ 3830.442024] Call Trace:
[ 3830.442024]  [<ffffffffa01bfe8d>] ? rpc_pipe_poll+0x6d/0xa0 [sunrpc]
[ 3830.442024]  [<ffffffffa026360b>] idmap_pipe_downcall+0x1cb/0x1e0 [nfs]
[ 3830.442024]  [<ffffffffa01bff27>] rpc_pipe_write+0x67/0x90 [sunrpc]
[ 3830.442024]  [<ffffffff8117e8e3>] vfs_write+0xb3/0x180
[ 3830.442024]  [<ffffffff8117ec0a>] sys_write+0x4a/0x90
[ 3830.442024]  [<ffffffff81077811>] ? posix_ktime_get_ts+0x11/0x20
[ 3830.442024]  [<ffffffff816215e9>] system_call_fastpath+0x16/0x1b
[ 3830.442024] Code: e5 48 83 ec 40 48 89 5d e0 4c 89 65 e8 4c 89 6d f0 4c 89 75 f8 66 66 66 66 90 48 85 c9 48 89 fb 49 89 f6 49 89 d5 49 89 cc 74 62 <48> 8b 57 78 48 8b 77 20 48 8d 4d d8 4c 89 e7 4c 89 45 c8 e8 0a 
[ 3830.442024] RIP  [<ffffffff812894ce>] key_instantiate_and_link+0x2e/0xa0
[ 3830.442024]  RSP <ffff88003a327d98>
[ 3830.442024] CR2: 0000000000000078
[ 3830.492152] ---[ end trace a0dbf47ab1df84a5 ]---

Thanks
Boaz
