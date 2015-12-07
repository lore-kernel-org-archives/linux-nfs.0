Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp.opengridcomputing.com ([72.48.136.20]:34431 "EHLO
	smtp.opengridcomputing.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S964859AbbLGPi3 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 7 Dec 2015 10:38:29 -0500
From: "Steve Wise" <swise@opengridcomputing.com>
To: "Chuck Lever" <chuck.lever@oracle.com>
Cc: <linux-rdma@vger.kernel.org>,
        "Veeresh U. Kokatnur" <veereshuk@chelsio.com>,
        <linux-nfs@vger.kernel.org>
Subject: warning in ext4 with nfs/rdma server
Date: Mon, 7 Dec 2015 09:38:40 -0600
Message-ID: <005001d13105$58a486f0$09ed94d0$@opengridcomputing.com>
MIME-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hey Chuck/NFS developers,

We're hitting this warning in ext4 on the linux-4.3 nfs server running over RDMA/cxgb4.  We're still gathering data, like if it
happens with NFS/TCP.  But has anyone seen this warning on 4.3?  Is it likely to indicate some bug in the xprtrdma transport or
above it in NFS?

We can hit this running cthon tests over 2 mount points:

-------------
#!/bin/bash
rm -rf /root/cthon04/loop_iter.txt
while [ 1 ]
do
{

./server -s -m /mnt/share1 -o rdma,port=20049,vers=4 -p /mnt/share1 -N 100
102.1.1.162 &
./server -s -m /mnt/share2 -o rdma,port=20049,vers=3,rsize=65535,wsize=65535 -p
/mnt/share2 -N 100 102.2.2.162 &
wait
echo "iteration $i" >>/root/cthon04/loop_iter.txt
date >>/root/cthon04/loop_iter.txt
}
done
--------------

Thanks,

Steve.

------------[ cut here ]------------
WARNING: CPU: 14 PID: 6689 at fs/ext4/inode.c:231 ext4_evict_inode+0x41e/0x490
[ext4]()
Modules linked in: nfsd(E) lockd(E) grace(E) nfs_acl(E) exportfs(E)
auth_rpcgss(E) rpcrdma(E) sunrpc(E) rdma_ucm(E) ib_uverbs(E) rdma_cm(E)
ib_cm(E) ib_sa(E) ib_mad(E) iw_cxgb4(E) iw_cm(E) ib_core(E) ib_addr(E) cxgb4(E)
autofs4(E) target_core_iblock(E) target_core_file(E) target_core_pscsi(E)
target_core_mod(E) configfs(E) bnx2fc(E) cnic(E) uio(E) fcoe(E) libfcoe(E)
8021q(E) libfc(E) garp(E) stp(E) llc(E) cpufreq_ondemand(E) cachefiles(E)
fscache(E) ipv6(E) dm_mirror(E) dm_region_hash(E) dm_log(E) vhost_net(E)
macvtap(E) macvlan(E) vhost(E) tun(E) kvm(E) uinput(E) microcode(E) sg(E)
pcspkr(E) serio_raw(E) fam15h_power(E) k10temp(E) amd64_edac_mod(E)
edac_core(E) edac_mce_amd(E) i2c_piix4(E) igb(E) dca(E) i2c_algo_bit(E)
i2c_core(E) ptp(E) pps_core(E) scsi_transport_fc(E) acpi_cpufreq(E) dm_mod(E)
ext4(E) jbd2(E) mbcache(E) sr_mod(E) cdrom(E) sd_mod(E) ahci(E) libahci(E)
[last unloaded: cxgb4]
CPU: 14 PID: 6689 Comm: nfsd Tainted: G            E   4.3.0 #1
Hardware name: Supermicro H8QGL/H8QGL, BIOS 3.5        12/19/2013
 00000000000000e7 ffff88400634fad8 ffffffff812a4084 ffffffffa00c96eb
 0000000000000000 ffff88400634fb18 ffffffff81059fd5 ffff88400634fbd8
 ffff880fd1a460c8 ffff880fd1a461d8 ffff880fd1a46008 ffff88400634fbd8
Call Trace:
 [<ffffffff812a4084>] dump_stack+0x48/0x64
 [<ffffffff81059fd5>] warn_slowpath_common+0x95/0xe0
 [<ffffffff8105a03a>] warn_slowpath_null+0x1a/0x20
 [<ffffffffa007dd6e>] ext4_evict_inode+0x41e/0x490 [ext4]
 [<ffffffff811bcaae>] evict+0xae/0x1a0
 [<ffffffff811bcd45>] iput_final+0xe5/0x170
 [<ffffffff811bce73>] iput+0xa3/0xf0
 [<ffffffff811e14a4>] ? fsnotify_destroy_marks+0x64/0x80
 [<ffffffff811bafc9>] dentry_unlink_inode+0xa9/0xe0
 [<ffffffff811bb0a6>] d_delete+0xa6/0xb0
 [<ffffffff811b3308>] vfs_unlink+0x138/0x140
 [<ffffffffa0717835>] nfsd_unlink+0x165/0x200 [nfsd]
 [<ffffffffa071aa7c>] ? lru_put_end+0x5c/0x70 [nfsd]
 [<ffffffffa071e323>] nfsd3_proc_remove+0x83/0x120 [nfsd]
 [<ffffffffa07105ec>] nfsd_dispatch+0xdc/0x210 [nfsd]
 [<ffffffffa021c931>] svc_process_common+0x311/0x620 [sunrpc]
 [<ffffffffa0710bf0>] ? nfsd_set_nrthreads+0x1b0/0x1b0 [nfsd]
 [<ffffffffa021d078>] svc_process+0x128/0x1b0 [sunrpc]
 [<ffffffffa0710ce3>] nfsd+0xf3/0x160 [nfsd]
 [<ffffffff8107770c>] kthread+0xcc/0xf0
 [<ffffffff8108282e>] ? schedule_tail+0x1e/0xc0
 [<ffffffff81077640>] ? kthread_freezable_should_stop+0x70/0x70
 [<ffffffff815d44ef>] ret_from_fork+0x3f/0x70
 [<ffffffff81077640>] ? kthread_freezable_should_stop+0x70/0x70
---[ end trace 39afe9aeef2cfb34 ]---
------------[ cut here ]------------

