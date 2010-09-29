Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp-out-2.desy.de ([131.169.56.85]:48276 "EHLO
	smtp-out-2.desy.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751037Ab0I2OIL (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 29 Sep 2010 10:08:11 -0400
Received: from smtp-map-2.desy.de (smtp-map-2.desy.de [131.169.56.67])
	by smtp-out-2.desy.de (DESY_OUT_1) with ESMTP id 6C4AEDDB
	for <linux-nfs@vger.kernel.org>; Wed, 29 Sep 2010 16:08:10 +0200 (MEST)
Received: from adserv72.win.desy.de (adserv72.win.desy.de [131.169.97.58])
	by smtp-map-2.desy.de (DESY_MAP_2) with ESMTP id 5D819DE1
	for <linux-nfs@vger.kernel.org>; Wed, 29 Sep 2010 16:08:10 +0200 (MEST)
Message-ID: <4CA34830.1040703@desy.de>
Date: Wed, 29 Sep 2010 16:07:44 +0200
From: Tigran Mkrtchyan <tigran.mkrtchyan@desy.de>
To: Benny Halevy <bhalevy@panasas.com>
CC: NFS list <linux-nfs@vger.kernel.org>
Subject: Re: pnfs git tree status pnfs-all-2.6.36-rc6-2010-09-29
References: <4C7BDD8C.40509@panasas.com> <4CA31DC3.8070300@panasas.com>
In-Reply-To: <4CA31DC3.8070300@panasas.com>
Content-Type: multipart/mixed;
 boundary="------------060505090204080505020107"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

--------------060505090204080505020107
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit


I am support to publish first kernel crash.....

this is
pnfs-all-2.6.36-rc6-2010-09-29 git c2b3b75c6b1db1dfc3f236200de1763e14c514d8

Regards,
    Tigran.


On 09/29/2010 01:06 PM, Benny Halevy wrote:
> This version includes Fred's pnfs-submit RFC patches (v5).
> and is rebased onto v2.6.36-rc6
>
> Cumulative patches can be generated from
> git://linux-nfs.org/~bhalevy/linux-pnfs.git
> using
> git diff v2.6.36-rc6 pnfs-all-2.6.36-rc6-2010-09-29
>
> Or, they can be downloaded from the wiki at:
> http://wiki.linux-nfs.org/wiki/index.php/PNFS_Development_Git_tree
>
> Latest patches (since pnfs-all-2.6.36-rc3-2010-08-30):
>
> upstream:
>    Boaz Harrosh     cc59b6a um: Proper Fix for f25c80a4: remove duplicate structure field initialization
>
> pnfs-submit:
>    The pNFS Team    1851dbc RFC: pnfsd, pnfs: protocol level pnfs constants
>    The pNFS Team    a1b60af RFC: nfs: change stateid to be a union
>    The pNFS Team    ff38ee4 RFC: nfs: ask for layouttypes during fsinfo call
>    The pNFS Team    01f09aa RFC: nfs: set layout driver
>    The pNFS Team    f7893b6 RFC: pnfs: full mount/umount infrastructure
>    The pNFS Team    1cef5e0 RFC: pnfs: filelayout: introduce minimal file layout driver
>    The pNFS Team    b7e2a3d RFC: nfs: create and destroy inode's layout cache
>    The pNFS Team    34d2802 RFC: nfs: client needs to maintain list of inodes with active layouts
>    The pNFS Team    292b90e RFC: pnfs: add LAYOUTGET and GETDEVICEINFO infrastructure
>    The pNFS Team    bf610f6 RFC: pnfs: filelayout: add driver's LAYOUTGET and GETDEVICEINFO infrastructure
>    Fred Isaman      068e761 pnfs-submit: revert range simplifications made by submission patches
>    Benny Halevy     7c58c3d SQUASHME: pnfs-submit: add missing include file in nfs4filelayoutdev.c
>    Benny Halevy     9a5956f SQUASHME: move nfs4_deviceid definitions to include/linux/nfs4.h
>    Benny Halevy     bb2afce SQUASHME: pnfs-submit: handle non-pnfs case in set_pnfs_layoutdriver
>    Benny Halevy     998fe4a pnfs-submit: file needs layout commit, server attributes may be stale
>    Benny Halevy     f18cdf8 NFS: clear fsinfo before sendign rpc
>
> pnfs:
>    Benny Halevy     52a6277 pnfs: alloc and free layout_hdr layoutdriver methods
>    Benny Halevy     6dd521e pnfs: allow nfs4_proc_layoutget to sleep on invalid lsegs
>    Benny Halevy     ba1dd5b SQUASHME: pnfs: refactor put_lseg{_locked}
>    Benny Halevy     bb03ecf SQUASHME: pnfs: get rid of lo_waitq
>
> pnfs-block:
>    Benny Halevy     73b1db9 SQUASHME: pnfsblock: remove obsolete include file from blocklayout.h
>    Benny Halevy     d9ebc26 SQUASHME: pnfsblock: use nfs4_deviceid
>    Benny Halevy     90e2af1 SQUASHME: pnfsblock: no callback ops
>    Benny Halevy     0953b90 SQAUSHME: pnfsblock: no PNFS_NFS_SERVER
>    Benny Halevy     7ab3774 SQUASHME: pnfsblock: no dev_notify_types
>    Benny Halevy     f08f966 SQUASHME: pnfsblock: use new struct pnfs_layout_hdr
>
> pnfs-obj-all:
>    Benny Halevy     41a70b7 SQUASHME: pnfs-obj: fix REQ flags usage
>    Benny Halevy     6057701 SQUASHME: pnfs-obj: convert to new pnfs-submit changes
>
> pnfs-exofs-all:
>    Benny Halevy     10d8e6e SQUASHME: pnfsd-exofs: convert to new pnfs-submit changes
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html


--------------060505090204080505020107
Content-Type: text/plain;
 name="crash"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename="crash"

[   71.450371] FS-Cache: Loaded
[   71.504142] FS-Cache: Netfs 'nfs' registered for caching
[   71.553022] nfs4filelayout_init: NFSv4 File Layout Driver Registering...
[  110.788743] BUG: unable to handle kernel NULL pointer dereference at 0000000000000040
[  110.788749] IP: [<ffffffffa006d416>] filelayout_get_stripesize+0x26/0x40 [nfs_layout_nfsv41_files]
[  110.788760] PGD 32b54067 PUD 2321a067 PMD 0 
[  110.788764] Oops: 0000 [#1] SMP 
[  110.788766] last sysfs file: /sys/block/sda/sda1/stat
[  110.788769] CPU 0 
[  110.788770] Modules linked in: nfs_layout_nfsv41_files nfs lockd fscache nfs_acl auth_rpcgss sunrpc ipv6 af_packet binfmt_misc dm_mirror dm_multipath scsi_dh video output sbs sbshc pci_slot fan container battery lp ac sg option usb_wwan usbserial thermal thermal_sys button parport_pc serio_raw parport tpm_tis tpm tpm_bios i2c_piix4 e1000 pata_mpiix dm_region_hash dm_log dm_mod [last unloaded: mperf]
[  110.788794] 
[  110.788797] Pid: 2162, comm: ls Not tainted 2.6.36-rc6.pnfs.1 #1 /VirtualBox
[  110.788799] RIP: 0010:[<ffffffffa006d416>]  [<ffffffffa006d416>] filelayout_get_stripesize+0x26/0x40 [nfs_layout_nfsv41_files]
[  110.788804] RSP: 0018:ffff880023219cc8  EFLAGS: 00010296
[  110.788807] RAX: 0000000000000000 RBX: ffffffffa006fa00 RCX: 7fffffffffffffff
[  110.788809] RDX: 0000000000002726 RSI: ffff880023219cc8 RDI: ffff88003ec892c0
[  110.788811] RBP: ffff880022851330 R08: 0000000000000000 R09: ffff880022851448
[  110.788813] R10: 0000000000000001 R11: ffffffffa0228570 R12: ffff8800228513dc
[  110.788815] R13: ffff880023219d50 R14: ffff880022851448 R15: ffff880022851150
[  110.788823] FS:  00007f9387c5a710(0000) GS:ffff880001800000(0000) knlGS:0000000000000000
[  110.788826] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
[  110.788828] CR2: 0000000000000040 CR3: 0000000026f2e000 CR4: 00000000000006f0
[  110.788834] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
[  110.788837] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
[  110.788840] Process ls (pid: 2162, threadinfo ffff880023218000, task ffff880028372e30)
[  110.788841] Stack:
[  110.788842]  ffff880000000001 0000000000000000 ffffffffffffffff ffffffff810d7864
[  110.788845] <0> ffffffffa006fa00 ffffffffa024a28e ffff880023219d78 ffff880022851330
[  110.788849] <0> ffff88002316a400 ffffffffa024b638 ffff880022851330 ffff880022851330
[  110.788853] Call Trace:
[  110.788858]  [<ffffffff810d7864>] ? do_lookup+0xb4/0x170
[  110.788882]  [<ffffffffa024a28e>] ? pnfs_getboundary+0x6e/0x80 [nfs]
[  110.788892]  [<ffffffffa024b638>] ? pnfs_pageio_init_write+0x78/0xa0 [nfs]
[  110.788901]  [<ffffffffa022725f>] ? nfs_pageio_init_write+0x3f/0x90 [nfs]
[  110.788909]  [<ffffffffa02285f0>] ? nfs_writepages+0x80/0x130 [nfs]
[  110.788913]  [<ffffffff810dac2a>] ? path_walk+0x6a/0xd0
[  110.788917]  [<ffffffff810949d4>] ? __filemap_fdatawrite_range+0x54/0x60
[  110.788920]  [<ffffffff81094c35>] ? filemap_write_and_wait+0x35/0x50
[  110.788928]  [<ffffffffa021b904>] ? nfs_getattr+0xf4/0x100 [nfs]
[  110.788932]  [<ffffffff810d267a>] ? vfs_fstatat+0x6a/0x80
[  110.788935]  [<ffffffff810d271f>] ? sys_newlstat+0x1f/0x50
[  110.788938]  [<ffffffff81002c6b>] ? system_call_fastpath+0x16/0x1b
[  110.788940] Code: 80 00 00 00 00 53 48 83 ec 20 48 89 e6 c7 04 24 01 00 00 00 48 c7 44 24 08 00 00 00 00 48 c7 44 24 10 ff ff ff ff e8 9a d2 1d 00 <8b> 58 40 48 89 c7 e8 0f d6 1d 00 48 83 c4 20 48 89 d8 5b c3 66 
[  110.788965] RIP  [<ffffffffa006d416>] filelayout_get_stripesize+0x26/0x40 [nfs_layout_nfsv41_files]
[  110.788969]  RSP <ffff880023219cc8>
[  110.788971] CR2: 0000000000000040
[  110.788973] ---[ end trace f509369417b82255 ]---

--------------060505090204080505020107--
