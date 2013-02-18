Return-Path: linux-nfs-owner@vger.kernel.org
Received: from eu1sys200aog101.obsmtp.com ([207.126.144.111]:56575 "HELO
	eu1sys200aog101.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1751073Ab3BRLow convert rfc822-to-8bit
	(ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 18 Feb 2013 06:44:52 -0500
From: Yan Burman <yanb@mellanox.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "swise@opengridcomputing.com" <swise@opengridcomputing.com>,
        "linux-rdma@vger.kernel.org" <linux-rdma@vger.kernel.org>,
        Or Gerlitz <ogerlitz@mellanox.com>
Subject: RE: NFS over RDMA crashing
Date: Mon, 18 Feb 2013 11:44:43 +0000
Message-ID: <0EE9A1CDC8D6434DB00095CD7DB87346115194CE@MTLDAG01.mtl.com>
References: <51127B3F.2090200@mellanox.com>
 <20130206222435.GL16417@fieldses.org> <20130207164134.GK3222@fieldses.org>
 <0EE9A1CDC8D6434DB00095CD7DB8734611518A44@MTLDAG01.mtl.com>
 <20130215152746.GI8343@fieldses.org>
In-Reply-To: <20130215152746.GI8343@fieldses.org>
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


> -----Original Message-----
> From: J. Bruce Fields [mailto:bfields@fieldses.org]
> Sent: Friday, February 15, 2013 17:28
> To: Yan Burman
> Cc: linux-nfs@vger.kernel.org; swise@opengridcomputing.com; linux-
> rdma@vger.kernel.org; Or Gerlitz
> Subject: Re: NFS over RDMA crashing
> 
> On Mon, Feb 11, 2013 at 03:19:42PM +0000, Yan Burman wrote:
> > > -----Original Message-----
> > > From: J. Bruce Fields [mailto:bfields@fieldses.org]
> > > Sent: Thursday, February 07, 2013 18:42
> > > To: Yan Burman
> > > Cc: linux-nfs@vger.kernel.org; swise@opengridcomputing.com; linux-
> > > rdma@vger.kernel.org; Or Gerlitz
> > > Subject: Re: NFS over RDMA crashing
> > >
> > > On Wed, Feb 06, 2013 at 05:24:35PM -0500, J. Bruce Fields wrote:
> > > > On Wed, Feb 06, 2013 at 05:48:15PM +0200, Yan Burman wrote:
> > > > > When killing mount command that got stuck:
> > > > > -------------------------------------------
> > > > >
> > > > > BUG: unable to handle kernel paging request at ffff880324dc7ff8
> > > > > IP: [<ffffffffa05f3dfb>] rdma_read_xdr+0x8bb/0xd40 [svcrdma] PGD
> > > > > 1a0c063 PUD 32f82e063 PMD 32f2fd063 PTE 8000000324dc7161
> > > > > Oops: 0003 [#1] PREEMPT SMP
> > > > > Modules linked in: md5 ib_ipoib xprtrdma svcrdma rdma_cm ib_cm
> > > iw_cm
> > > > > ib_addr nfsd exportfs netconsole ip6table_filter ip6_tables
> > > > > iptable_filter ip_tables ebtable_nat nfsv3 nfs_acl ebtables
> > > > > x_tables
> > > > > nfsv4 auth_rpcgss nfs lockd autofs4 sunrpc target_core_iblock
> > > > > target_core_file target_core_pscsi target_core_mod configfs
> > > > > 8021q bridge stp llc ipv6 dm_mirror dm_region_hash dm_log
> > > > > vhost_net macvtap macvlan tun uinput iTCO_wdt
> > > > > iTCO_vendor_support kvm_intel kvm crc32c_intel microcode pcspkr
> > > > > joydev i2c_i801 lpc_ich mfd_core ehci_pci ehci_hcd sg ioatdma
> > > > > ixgbe mdio mlx4_ib ib_sa ib_mad ib_core mlx4_en mlx4_core igb
> > > > > hwmon dca ptp pps_core button dm_mod ext3
> > > jbd
> > > > > sd_mod ata_piix libata uhci_hcd megaraid_sas scsi_mod CPU 6
> > > > > Pid: 4744, comm: nfsd Not tainted 3.8.0-rc5+ #4 Supermicro
> > > > > X8DTH-i/6/iF/6F/X8DTH
> > > > > RIP: 0010:[<ffffffffa05f3dfb>]  [<ffffffffa05f3dfb>]
> > > > > rdma_read_xdr+0x8bb/0xd40 [svcrdma]
> > > > > RSP: 0018:ffff880324c3dbf8  EFLAGS: 00010297
> > > > > RAX: ffff880324dc8000 RBX: 0000000000000001 RCX:
> > > > > ffff880324dd8428
> > > > > RDX: ffff880324dc7ff8 RSI: ffff880324dd8428 RDI:
> > > > > ffffffff81149618
> > > > > RBP: ffff880324c3dd78 R08: 000060f9c0000860 R09:
> > > > > 0000000000000001
> > > > > R10: ffff880324dd8000 R11: 0000000000000001 R12:
> > > > > ffff8806299dcb10
> > > > > R13: 0000000000000003 R14: 0000000000000001 R15:
> > > > > 0000000000000010
> > > > > FS:  0000000000000000(0000) GS:ffff88063fc00000(0000)
> > > > > knlGS:0000000000000000
> > > > > CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
> > > > > CR2: ffff880324dc7ff8 CR3: 0000000001a0b000 CR4:
> > > > > 00000000000007e0
> > > > > DR0: 0000000000000000 DR1: 0000000000000000 DR2:
> > > > > 0000000000000000
> > > > > DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7:
> > > > > 0000000000000400 Process nfsd (pid: 4744, threadinfo
> > > > > ffff880324c3c000, task
> > > > > ffff880330550000)
> > > > > Stack:
> > > > >  ffff880324c3dc78 ffff880324c3dcd8 0000000000000282
> > > > > ffff880631cec000
> > > > >  ffff880324dd8000 ffff88062ed33040 0000000124c3dc48
> > > > > ffff880324dd8000
> > > > >  ffff88062ed33058 ffff880630ce2b90 ffff8806299e8000
> > > > > 0000000000000003 Call Trace:
> > > > >  [<ffffffffa05f466e>] svc_rdma_recvfrom+0x3ee/0xd80 [svcrdma]
> > > > > [<ffffffff81086540>] ? try_to_wake_up+0x2f0/0x2f0
> > > > > [<ffffffffa045963f>] svc_recv+0x3ef/0x4b0 [sunrpc]
> > > > > [<ffffffffa0571db0>] ? nfsd_svc+0x740/0x740 [nfsd]
> > > > > [<ffffffffa0571e5d>] nfsd+0xad/0x130 [nfsd]  [<ffffffffa0571db0>] ?
> > > > > nfsd_svc+0x740/0x740 [nfsd]  [<ffffffff81071df6>]
> > > > > kthread+0xd6/0xe0 [<ffffffff81071d20>] ?
> > > > > __init_kthread_worker+0x70/0x70 [<ffffffff814b462c>]
> ret_from_fork+0x7c/0xb0  [<ffffffff81071d20>] ?
> > > > > __init_kthread_worker+0x70/0x70
> > > > > Code: 63 c2 49 8d 8c c2 18 02 00 00 48 39 ce 77 e1 49 8b 82 40
> > > > > 0a 00
> > > > > 00 48 39 c6 0f 84 92 f7 ff ff 90 48 8d 50 f8 49 89 92 40 0a 00
> > > > > 00 <48> c7 40 f8 00 00 00 00 49 8b 82 40 0a 00 00 49 3b 82 30 0a
> > > > > 00 RIP [<ffffffffa05f3dfb>] rdma_read_xdr+0x8bb/0xd40 [svcrdma]
> > > > > RSP <ffff880324c3dbf8>
> > > > > CR2: ffff880324dc7ff8
> > > > > ---[ end trace 06d0384754e9609a ]---
> > > > >
> > > > >
> > > > > It seems that commit afc59400d6c65bad66d4ad0b2daf879cbff8e23e
> > > > > "nfsd4: cleanup: replace rq_resused count by rq_next_page pointer"
> > > > > is responsible for the crash (it seems to be crashing in
> > > > > net/sunrpc/xprtrdma/svc_rdma_recvfrom.c:527)
> > > > > It may be because I have CONFIG_DEBUG_SET_MODULE_RONX and
> > > > > CONFIG_DEBUG_RODATA enabled. I did not try to disable them yet.
> > > > >
> > > > > When I moved to commit
> 79f77bf9a4e3dd5ead006b8f17e7c4ff07d8374e
> > > > > I was no longer getting the server crashes, so the reset of my
> > > > > tests were done using that point (it is somewhere in the middle
> > > > > of 3.7.0-rc2).
> > > >
> > > > OK, so this part's clearly my fault--I'll work on a patch, but the
> > > > rdma's use of the ->rq_pages array is pretty confusing.
> > >
> > > Does this help?
> > >
> > > They must have added this for some reason, but I'm not seeing how it
> > > could have ever done anything....
> > >
> > > --b.
> > >
> > > diff --git a/net/sunrpc/xprtrdma/svc_rdma_recvfrom.c
> > > b/net/sunrpc/xprtrdma/svc_rdma_recvfrom.c
> > > index 0ce7552..e8f25ec 100644
> > > --- a/net/sunrpc/xprtrdma/svc_rdma_recvfrom.c
> > > +++ b/net/sunrpc/xprtrdma/svc_rdma_recvfrom.c
> > > @@ -520,13 +520,6 @@ next_sge:
> > >  	for (ch_no = 0; &rqstp->rq_pages[ch_no] < rqstp->rq_respages;
> > > ch_no++)
> > >  		rqstp->rq_pages[ch_no] = NULL;
> > >
> > > -	/*
> > > -	 * Detach res pages. If svc_release sees any it will attempt to
> > > -	 * put them.
> > > -	 */
> > > -	while (rqstp->rq_next_page != rqstp->rq_respages)
> > > -		*(--rqstp->rq_next_page) = NULL;
> > > -
> > >  	return err;
> > >  }
> > >
> >
> > I've been trying to reproduce the problem, but for some reason it does not
> happen anymore.
> > The crash is not happening even without the patch now, but NFS over RDMA
> in 3.8.0-rc5 from net-next is not working.
> > When running server and client in VM with SRIOV, it times out when trying
> to mount and oopses on the client when mount command is interrupted.
> > When running two physical hosts, I get to mount the remote directory, but
> reading or writing fails with IO error.
> >
> > I am still doing some checks - I will post my findings when I will have more
> information.
> >
> 
> Any luck reproducing the problem or any results running with the above
> patch?
> 
> --b.

Right now I am not being able to reproduce the error - I am starting to suspect that it was a compilation issue.
I do get a crash in VM, but in a different place.

RPC: Registered rdma transport module.
rpcrdma: connection to 192.168.20.210:2050 on mlx4_0, memreg 5 slots 32 ird 16
kernel tried to execute NX-protected page - exploit attempt? (uid: 0)
BUG: unable to handle kernel paging request at ffff88007ae98998
IP: [<ffff88007ae98998>] 0xffff88007ae98997
PGD 180c063 PUD 1fffc067 PMD 7bd7c063 PTE 800000007ae98163
Oops: 0011 [#1] PREEMPT SMP
Modules linked in: xprtrdma netconsole configfs nfsv3 nfs_acl nfsv4 auth_rpcgss nfs lockd ib_ipoib rdma_ucm ib_ucm ib_uverbs ib_umad rdma_cm ib_cm iw_cm ib_addr autofs4 sunrpc 8021q ipv6 dm_mirror dm_region_hash dm_log uinput joydev microcode pcspkr mlx4_ib ib_sa ib_mad ib_core mlx4_en mlx4_core virtio_balloon cirrus ttm drm_kms_helper sysimgblt sysfillrect syscopyarea i2c_piix4 button dm_mod ext3 jbd virtio_blk virtio_net virtio_pci virtio_ring virtio uhci_hcd
CPU 1
Pid: 2885, comm: mount.nfs Tainted: G        W    3.7.6 #2 Red Hat KVM
RIP: 0010:[<ffff88007ae98998>]  [<ffff88007ae98998>] 0xffff88007ae98997
RSP: 0018:ffff88007fd03e38  EFLAGS: 00010282
RAX: 0000000000000004 RBX: ffff88007ae98998 RCX: 0000000000000002
RDX: 0000000000000002 RSI: ffff8800715b8610 RDI: ffff88007a5d41b0
RBP: ffff88007fd03e60 R08: 0000000000000003 R09: 0000000000000000
R10: 0000000000000000 R11: 0000000000000000 R12: ffff88007a5d41b0
R13: ffff88007a5d41d0 R14: 0000000000000282 R15: ffff88007126ba10
FS:  00007f02ac5da700(0000) GS:ffff88007fd00000(0000) knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
CR2: ffff88007ae98998 CR3: 0000000079aa8000 CR4: 00000000000006e0
DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
Process mount.nfs (pid: 2885, threadinfo ffff880071452000, task ffff8800715b8000)
Stack:
 ffffffffa037afe0 ffffffffa03813e0 ffffffffa03813e8 0000000000000000
 0000000000000030 ffff88007fd03e90 ffffffff81052685 0000000000000040
 0000000000000001 ffffffff818040b0 0000000000000006 ffff88007fd03f30
Call Trace:
 <IRQ>
 [<ffffffffa037afe0>] ? rpcrdma_run_tasklet+0x60/0x90 [xprtrdma]
 [<ffffffff81052685>] tasklet_action+0xd5/0xe0
 [<ffffffff810530b1>] __do_softirq+0xf1/0x3b0
 [<ffffffff814a6c0c>] call_softirq+0x1c/0x30
 [<ffffffff81004345>] do_softirq+0x85/0xc0
 [<ffffffff81052cee>] irq_exit+0x9e/0xc0
 [<ffffffff81003ad1>] do_IRQ+0x61/0xd0
 [<ffffffff8149e26f>] common_interrupt+0x6f/0x6f
 <EOI>
 [<ffffffff8123a090>] ? delay_loop+0x20/0x30
 [<ffffffff8123a20c>] __const_udelay+0x2c/0x30
 [<ffffffff8106f2f4>] __rcu_read_unlock+0x54/0xa0
 [<ffffffff8116f23d>] __d_lookup+0x16d/0x320
 [<ffffffff8116f0d0>] ? d_delete+0x190/0x190
 [<ffffffff8149b1cb>] ? mutex_lock_nested+0x2db/0x3a0
 [<ffffffff8116f420>] d_lookup+0x30/0x50
 [<ffffffffa024d5cc>] ? rpc_depopulate.clone.3+0x3c/0x70 [sunrpc]
 [<ffffffffa024d350>] __rpc_depopulate.clone.1+0x50/0xd0 [sunrpc]
 [<ffffffffa024d600>] ? rpc_depopulate.clone.3+0x70/0x70 [sunrpc]
 [<ffffffffa024d5da>] rpc_depopulate.clone.3+0x4a/0x70 [sunrpc]
 [<ffffffffa024d600>] ? rpc_depopulate.clone.3+0x70/0x70 [sunrpc]
 [<ffffffffa024d615>] rpc_clntdir_depopulate+0x15/0x20 [sunrpc]
 [<ffffffffa024c41d>] rpc_rmdir_depopulate+0x4d/0x90 [sunrpc]
 [<ffffffffa024c490>] rpc_remove_client_dir+0x10/0x20 [sunrpc]
 [<ffffffffa022fb02>] __rpc_clnt_remove_pipedir+0x42/0x60 [sunrpc]
 [<ffffffffa022fb51>] rpc_clnt_remove_pipedir+0x31/0x50 [sunrpc]
 [<ffffffffa022fc8d>] rpc_free_client+0x11d/0x3f0 [sunrpc]
 [<ffffffffa022fb9e>] ? rpc_free_client+0x2e/0x3f0 [sunrpc]
 [<ffffffffa022ffc8>] rpc_release_client+0x68/0xa0 [sunrpc]
 [<ffffffffa0230512>] rpc_shutdown_client+0x52/0x240 [sunrpc]
 [<ffffffffa0230f60>] ? rpc_new_client+0x3a0/0x550 [sunrpc]
 [<ffffffffa0230468>] ? rpc_ping+0x58/0x70 [sunrpc]
 [<ffffffffa0231646>] rpc_create+0x186/0x1f0 [sunrpc]
 [<ffffffff810aaf79>] ? __module_address+0x119/0x160
 [<ffffffffa02eb314>] nfs_create_rpc_client+0xc4/0x100 [nfs]
 [<ffffffffa035a5c7>] nfs4_init_client+0x77/0x310 [nfsv4]
 [<ffffffffa02ec060>] ? nfs_get_client+0x110/0x640 [nfs]
 [<ffffffffa02ec424>] nfs_get_client+0x4d4/0x640 [nfs]
 [<ffffffffa02ec060>] ? nfs_get_client+0x110/0x640 [nfs]
 [<ffffffff810a0475>] ? lockdep_init_map+0x65/0x540
 [<ffffffff810a0475>] ? lockdep_init_map+0x65/0x540
 [<ffffffffa0358df5>] nfs4_set_client+0x75/0xf0 [nfsv4]
 [<ffffffffa023add8>] ? __rpc_init_priority_wait_queue+0xa8/0xf0 [sunrpc]
 [<ffffffffa02ea916>] ? nfs_alloc_server+0xf6/0x130 [nfs]
 [<ffffffffa03592ab>] nfs4_create_server+0xdb/0x360 [nfsv4]
 [<ffffffffa0350623>] nfs4_remote_mount+0x33/0x60 [nfsv4]
 [<ffffffff8115a11e>] mount_fs+0x3e/0x1a0
 [<ffffffff8111f08b>] ? __alloc_percpu+0xb/0x10
 [<ffffffff8117b12d>] vfs_kern_mount+0x6d/0x100
 [<ffffffffa0350270>] nfs_do_root_mount+0x90/0xe0 [nfsv4]
 [<ffffffffa035056f>] nfs4_try_mount+0x3f/0xc0 [nfsv4]
 [<ffffffffa02ecefc>] ? get_nfs_version+0x2c/0x80 [nfs]
 [<ffffffffa02f5d2c>] nfs_fs_mount+0x19c/0xc10 [nfs]
 [<ffffffffa02f6e60>] ? nfs_clone_super+0x140/0x140 [nfs]
 [<ffffffffa02f6c20>] ? nfs_clone_sb_security+0x60/0x60 [nfs]
 [<ffffffff8115a11e>] mount_fs+0x3e/0x1a0
 [<ffffffff8111f08b>] ? __alloc_percpu+0xb/0x10
 [<ffffffff8117b12d>] vfs_kern_mount+0x6d/0x100
 [<ffffffff8117b23d>] do_kern_mount+0x4d/0x110
 [<ffffffff8105623f>] ? ns_capable+0x3f/0x80
 [<ffffffff8117b54c>] do_mount+0x24c/0x800
 [<ffffffff81179c7d>] ? copy_mount_options+0xfd/0x1b0
 [<ffffffff8117bb8b>] sys_mount+0x8b/0xe0
 [<ffffffff814a5a52>] system_call_fastpath+0x16/0x1b
Code: ff ff ff 00 00 00 00 00 00 00 00 00 02 38 a0 ff ff ff ff 01 00 00 00 00 00 00 00 00 01 00 00 00 00 00 00 20 00 00 00 00 00 00 00 <a0> 41 5d 7a 00 88 ff ff c8 41 5d 7a 00 88 ff ff 00 00 00 00 00
RIP  [<ffff88007ae98998>] 0xffff88007ae98997
 RSP <ffff88007fd03e38>
CR2: ffff88007ae98998
---[ end trace 5ff8c4860160ebd8 ]---
Kernel panic - not syncing: Fatal exception in interrupt
panic occurred, switching back to text console

Sorry for the delayed answers, I just had to switch to something with higher priority right now.
I plan to get back to this issue in a week or two.

Yan

