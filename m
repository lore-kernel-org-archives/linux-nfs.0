From: Stuart Anderson <anderson@ligo.caltech.edu>
Subject: Kernel NFS nfs_update_inode Oops in 2.6.20.11
Date: Sat, 23 Jun 2007 08:33:45 -0700
Message-ID: <20070623153345.GA22117@ligo.caltech.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1I27cT-0005a7-Lm
	for nfs@lists.sourceforge.net; Sat, 23 Jun 2007 08:33:49 -0700
Received: from acrux.ligo.caltech.edu ([131.215.115.14])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1I27cV-0003JU-KQ
	for nfs@lists.sourceforge.net; Sat, 23 Jun 2007 08:33:53 -0700
Received: from alphard.ligo.caltech.edu (alphard [131.215.114.160])
	by acrux.ligo.caltech.edu (8.12.11/8.12.11) with ESMTP id
	l5NFXohd019138
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NOT)
	for <nfs@lists.sourceforge.net>; Sat, 23 Jun 2007 08:33:50 -0700 (PDT)
Received: from alphard.ligo.caltech.edu (localhost.localdomain [127.0.0.1])
	by alphard.ligo.caltech.edu (8.13.7/8.13.4) with ESMTP id
	l5NFXj3P022200
	for <nfs@lists.sourceforge.net>; Sat, 23 Jun 2007 08:33:45 -0700
Received: (from anderson@localhost)
	by alphard.ligo.caltech.edu (8.13.7/8.13.4/Submit) id l5NFXjV4022199
	for nfs@lists.sourceforge.net; Sat, 23 Jun 2007 08:33:45 -0700
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

We started receiving frequent kernel (2.6.20.11) Oops messages in
nfs:nfs_update_inode on a pair of Sun X4600M2 machines once we started
mounting an NFS V4 filesystem from a Solaris x86 ZFS server.

Any help in tracking this down would be greatly appreciated.

Thanks.

Jun 22 18:15:49 ldas-grid kernel: Unable to handle kernel NULL pointer dereference at 0000000000000020 RIP: 
Jun 22 18:15:49 ldas-grid kernel:  [<ffffffff88170989>] :nfs:nfs_update_inode+0x99/0x5a0
Jun 22 18:15:49 ldas-grid kernel: PGD 3edd83067 PUD 3edd8b067 PMD 0 
Jun 22 18:15:49 ldas-grid kernel: Oops: 0000 [1] SMP 
Jun 22 18:15:49 ldas-grid kernel: CPU 7 
Jun 22 18:15:49 ldas-grid kernel: Modules linked in: nfsd exportfs autofs4 eeprom adm1026 hwmon_vid hwmon i2c_isa i2c_amd756
 i2c_amd8111 nfs lockd nfs_acl sunrpc ipt_REJECT xt_state usb_storage ip_conntrack nfnetlink xt_tcpudp iptable_filter ip_tab
les x_tables usbhid dm_mod ohci_hcd ehci_hcd i2c_nforce2 i2c_core e1000 usbcore mptsas scsi_transport_sas mptscsih mptbase s
d_mod scsi_mod
Jun 22 18:15:49 ldas-grid kernel: Pid: 33, comm: events/7 Not tainted 2.6.20.11-CIT #1
Jun 22 18:15:49 ldas-grid kernel: RIP: 0010:[<ffffffff88170989>]  [<ffffffff88170989>] :nfs:nfs_update_inode+0x99/0x5a0
Jun 22 18:15:49 ldas-grid kernel: RSP: 0018:ffff8103fbc3dc10  EFLAGS: 00010246
Jun 22 18:15:49 ldas-grid kernel: RAX: 0000000000000000 RBX: ffff81035d704ce8 RCX: 0000000000008180
Jun 22 18:15:49 ldas-grid kernel: RDX: ffff8101003cf8c0 RSI: ffff8103ace9c8d0 RDI: ffff81035d704ce8
Jun 22 18:15:49 ldas-grid kernel: RBP: ffff8103ace9c8d0 R08: 0000000000008180 R09: ffff8103eddf0030
Jun 22 18:15:49 ldas-grid kernel: R10: 0000000000000026 R11: 0000000000000003 R12: ffff81035d704b10
Jun 22 18:15:49 ldas-grid kernel: R13: ffff81035d704ce8 R14: ffff8101fbc3e6c0 R15: ffff8103ace9c8d0
Jun 22 18:15:49 ldas-grid kernel: FS:  00002b526bf797a0(0000) GS:ffff810300141d40(0000) knlGS:00000000f7dbb6c0
Jun 22 18:15:49 ldas-grid kernel: CS:  0010 DS: 0018 ES: 0018 CR0: 000000008005003b
Jun 22 18:15:49 ldas-grid kernel: CR2: 0000000000000020 CR3: 00000003edd89000 CR4: 00000000000006e0
Jun 22 18:15:49 ldas-grid kernel: Process events/7 (pid: 33, threadinfo ffff8103fbc3c000, task ffff8102fbcb90c0)
Jun 22 18:15:49 ldas-grid kernel: Stack:  ffff81035d704ce8 ffff8103ace9c8d0 ffff81035d704da0 ffff81035d704ce8
Jun 22 18:15:49 ldas-grid kernel:  ffff8101fbc3e6c0 ffffffff88170edb 0000000000000000 ffff8103ace9c800
Jun 22 18:15:49 ldas-grid kernel:  ffff810322664c00 ffffffff881817f0 ffff810376445de0 ffff8101003cf8c0
Jun 22 18:15:49 ldas-grid kernel: Call Trace:
Jun 22 18:15:49 ldas-grid kernel:  [<ffffffff88170edb>] :nfs:nfs_post_op_update_inode+0x4b/0x70
Jun 22 18:15:49 ldas-grid kernel:  [<ffffffff881817f0>] :nfs:nfs4_proc_delegreturn+0x160/0x1e0
Jun 22 18:15:49 ldas-grid kernel:  [<ffffffff8818e2ae>] :nfs:nfs_do_return_delegation+0x1e/0x40
Jun 22 18:15:50 ldas-grid kernel:  [<ffffffff8816d0e3>] :nfs:nfs_dentry_iput+0x23/0x70
Jun 22 18:15:50 ldas-grid kernel:  [<ffffffff802999a2>] shrink_dcache_for_umount_subtree+0x212/0x270
Jun 22 18:15:50 ldas-grid kernel:  [<ffffffff80299a53>] shrink_dcache_for_umount+0x53/0x70
Jun 22 18:15:50 ldas-grid kernel:  [<ffffffff80288ce9>] generic_shutdown_super+0x19/0x100
Jun 22 18:15:50 ldas-grid kernel:  [<ffffffff80288e29>] kill_anon_super+0x9/0x40
Jun 22 18:15:50 ldas-grid kernel:  [<ffffffff881724ad>] :nfs:nfs_kill_super+0xd/0x20
Jun 22 18:15:50 ldas-grid kernel:  [<ffffffff80289046>] deactivate_super+0x76/0xb0
Jun 22 18:15:50 ldas-grid kernel:  [<ffffffff802a1573>] expire_mount_list+0x133/0x180
Jun 22 18:15:50 ldas-grid kernel:  [<ffffffff8817a7a0>] :nfs:nfs_expire_automounts+0x0/0x40
Jun 22 18:15:50 ldas-grid kernel:  [<ffffffff802a176b>] mark_mounts_for_expiry+0xab/0xc0
Jun 22 18:15:50 ldas-grid kernel:  [<ffffffff8817a7b0>] :nfs:nfs_expire_automounts+0x10/0x40
Jun 22 18:15:50 ldas-grid kernel:  [<ffffffff8023fd6e>] run_workqueue+0xae/0x160
Jun 22 18:15:50 ldas-grid kernel:  [<ffffffff8023fee0>] worker_thread+0x0/0x190
Jun 22 18:15:50 ldas-grid kernel:  [<ffffffff80240031>] worker_thread+0x151/0x190
Jun 22 18:15:50 ldas-grid kernel:  [<ffffffff80229490>] default_wake_function+0x0/0x10
Jun 22 18:15:50 ldas-grid kernel:  [<ffffffff8023fee0>] worker_thread+0x0/0x190
Jun 22 18:15:50 ldas-grid kernel:  [<ffffffff80243b79>] kthread+0xd9/0x120
Jun 22 18:15:50 ldas-grid kernel:  [<ffffffff802298cc>] schedule_tail+0x4c/0xb0
Jun 22 18:15:50 ldas-grid kernel:  [<ffffffff8020a998>] child_rip+0xa/0x12
Jun 22 18:15:50 ldas-grid kernel:  [<ffffffff80219250>] flat_send_IPI_mask+0x0/0x60
Jun 22 18:15:50 ldas-grid kernel:  [<ffffffff80243aa0>] kthread+0x0/0x120
Jun 22 18:15:50 ldas-grid kernel:  [<ffffffff8020a98e>] child_rip+0x0/0x12
Jun 22 18:15:50 ldas-grid kernel: 
Jun 22 18:15:50 ldas-grid kernel: 
Jun 22 18:15:50 ldas-grid kernel: Code: 48 3b 58 20 75 31 48 8b 45 60 48 39 82 b0 00 00 00 48 8d 75 
Jun 22 18:15:50 ldas-grid kernel: RIP  [<ffffffff88170989>] :nfs:nfs_update_inode+0x99/0x5a0
Jun 22 18:15:50 ldas-grid kernel:  RSP <ffff8103fbc3dc10>
Jun 22 18:15:50 ldas-grid kernel: CR2: 0000000000000020

-- 
Stuart Anderson  anderson@ligo.caltech.edu
http://www.ligo.caltech.edu/~anderson

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
