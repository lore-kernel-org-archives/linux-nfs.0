Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp-out-2.desy.de ([131.169.56.85]:58745 "EHLO
	smtp-out-2.desy.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751942Ab0KRPVD (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 18 Nov 2010 10:21:03 -0500
Received: from smtp-map-2.desy.de (smtp-map-2.desy.de [131.169.56.67])
	by smtp-out-2.desy.de (DESY_OUT_1) with ESMTP id 275CDDE1
	for <linux-nfs@vger.kernel.org>; Thu, 18 Nov 2010 16:21:01 +0100 (MET)
Received: from adserv71.win.desy.de (adserv71.win.desy.de [131.169.97.57])
	by smtp-map-2.desy.de (DESY_MAP_2) with ESMTP id 22625DA7
	for <linux-nfs@vger.kernel.org>; Thu, 18 Nov 2010 16:21:01 +0100 (MET)
Received: from smtp-intra-3.desy.de (lb-40-26.desy.de) by adserv71.win.desy.de
 (Clearswift SMTPRS 5.3.4) with ESMTP id <T996c32bdbf83a961390cc@adserv71.win.desy.de> for <linux-nfs@vger.kernel.org>;
 Thu, 18 Nov 2010 16:21:00 +0100
Received: from [131.169.185.68] (anahit.desy.de [131.169.185.68])
	by smtp-intra-3.desy.de (DESY-INTRA-3) with ESMTP id E62DC1196
	for <linux-nfs@vger.kernel.org>; Thu, 18 Nov 2010 16:21:00 +0100 (MET)
Message-ID: <4CE54463.7070805@desy.de>
Date: Thu, 18 Nov 2010 16:21:07 +0100
From: Tigran Mkrtchyan <tigran.mkrtchyan@desy.de>
To: NFS list <linux-nfs@vger.kernel.org>
Subject: 2.6.37-rc1 krash
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0


During dead client recovery procedure you client crashed in did.

The procedure was: during IO disconnect network cable. We was testing
server cleanup sequence.  Then we have connected  client back. After some
time client reconnected...and crashed. The last thing I have seen was 
BAD_SESSION
from the server on READ call:



Nov 18 16:04:29 slinux kernel: [  555.385877] Got error -10052 from the 
server on DESTROY_SESSION. Session has been destroyed regardless...
Nov 18 16:04:29 slinux kernel: [  555.395300] ------------[ cut here 
]------------
Nov 18 16:04:29 slinux kernel: [  555.395321] WARNING: at 
fs/nfs/pnfs.c:477 pnfs_destroy_layout+0xd6/0x100 [nfs]()
Nov 18 16:04:29 slinux kernel: [  555.395323] Hardware name: VirtualBox
Nov 18 16:04:29 slinux kernel: [  555.395324] Modules linked in: 
nfs_layout_nfsv41_files nfs lockd fscache nfs_acl auth_rpcgss sunrpc 
ipv6 af_packet binfmt_misc dm_mirror dm_multipath scsi_dh video output 
thermal sbs sbshc pci_slot fan container battery lp sg ac option 
usb_wwan usbserial thermal_sys button parport_pc tpm_tis tpm serio_raw 
tpm_bios parport e1000 i2c_piix4 pata_mpiix dm_region_hash dm_log dm_mod 
[last unloaded: mperf]
Nov 18 16:04:29 slinux kernel: [  555.395425] Pid: 2259, comm: 
131.169.40.35-m Not tainted 2.6.37-rc1.pnfs.1 #1
Nov 18 16:04:29 slinux kernel: [  555.395427] Call Trace:
Nov 18 16:04:29 slinux kernel: [  555.395434]  [<ffffffffa024a256>] ? 
pnfs_destroy_layout+0xd6/0x100 [nfs]
Nov 18 16:04:29 slinux kernel: [  555.395440]  [<ffffffffa024a256>] ? 
pnfs_destroy_layout+0xd6/0x100 [nfs]
Nov 18 16:04:29 slinux kernel: [  555.395444]  [<ffffffff81041fbc>] ? 
warn_slowpath_common+0x8c/0xc0
Nov 18 16:04:29 slinux kernel: [  555.395450]  [<ffffffffa024a256>] ? 
pnfs_destroy_layout+0xd6/0x100 [nfs]
Nov 18 16:04:29 slinux kernel: [  555.395456]  [<ffffffffa024a302>] ? 
pnfs_destroy_all_layouts+0x82/0xc0 [nfs]
Nov 18 16:04:29 slinux kernel: [  555.395462]  [<ffffffffa0242b93>] ? 
nfs4_run_state_manager+0x4e3/0x540 [nfs]
Nov 18 16:04:29 slinux kernel: [  555.395469]  [<ffffffffa02426b0>] ? 
nfs4_run_state_manager+0x0/0x540 [nfs]
Nov 18 16:04:29 slinux kernel: [  555.395471]  [<ffffffff8105b466>] ? 
kthread+0x96/0xa0
Nov 18 16:04:29 slinux kernel: [  555.395474]  [<ffffffff81003a14>] ? 
kernel_thread_helper+0x4/0x10
Nov 18 16:04:29 slinux kernel: [  555.395476]  [<ffffffff8105b3d0>] ? 
kthread+0x0/0xa0
Nov 18 16:04:29 slinux kernel: [  555.395478]  [<ffffffff81003a10>] ? 
kernel_thread_helper+0x0/0x10
Nov 18 16:04:29 slinux kernel: [  555.395479] ---[ end trace 
8f55223a1de06cc6 ]---
Nov 18 16:04:29 slinux kernel: [  555.395480] ------------[ cut here 
]------------
Nov 18 16:04:29 slinux kernel: [  555.395486] WARNING: at 
fs/nfs/pnfs.c:478 pnfs_destroy_layout+0xfc/0x100 [nfs]()
Nov 18 16:04:29 slinux kernel: [  555.395487] Hardware name: VirtualBox
Nov 18 16:04:29 slinux kernel: [  555.395488] Modules linked in: 
nfs_layout_nfsv41_files nfs lockd fscache nfs_acl auth_rpcgss sunrpc 
ipv6 af_packet binfmt_misc dm_mirror dm_multipath scsi_dh video output 
thermal sbs sbshc pci_slot fan container battery lp sg ac option 
usb_wwan usbserial thermal_sys button parport_pc tpm_tis tpm serio_raw 
tpm_bios parport e1000 i2c_piix4 pata_mpiix dm_region_hash dm_log dm_mod 
[last unloaded: mperf]
Nov 18 16:04:29 slinux kernel: [  555.395503] Pid: 2259, comm: 
131.169.40.35-m Tainted: G        W   2.6.37-rc1.pnfs.1 #1
Nov 18 16:04:29 slinux kernel: [  555.395504] Call Trace:
Nov 18 16:04:29 slinux kernel: [  555.395510]  [<ffffffffa024a27c>] ? 
pnfs_destroy_layout+0xfc/0x100 [nfs]
Nov 18 16:04:29 slinux kernel: [  555.395516]  [<ffffffffa024a27c>] ? 
pnfs_destroy_layout+0xfc/0x100 [nfs]
Nov 18 16:04:29 slinux kernel: [  555.395518]  [<ffffffff81041fbc>] ? 
warn_slowpath_common+0x8c/0xc0
Nov 18 16:04:29 slinux kernel: [  555.395523]  [<ffffffffa024a27c>] ? 
pnfs_destroy_layout+0xfc/0x100 [nfs]
Nov 18 16:04:29 slinux kernel: [  555.395529]  [<ffffffffa024a302>] ? 
pnfs_destroy_all_layouts+0x82/0xc0 [nfs]
Nov 18 16:04:29 slinux kernel: [  555.395536]  [<ffffffffa0242b93>] ? 
nfs4_run_state_manager+0x4e3/0x540 [nfs]
Nov 18 16:04:29 slinux kernel: [  555.395542]  [<ffffffffa02426b0>] ? 
nfs4_run_state_manager+0x0/0x540 [nfs]
Nov 18 16:04:29 slinux kernel: [  555.395544]  [<ffffffff8105b466>] ? 
kthread+0x96/0xa0
Nov 18 16:04:29 slinux kernel: [  555.395546]  [<ffffffff81003a14>] ? 
kernel_thread_helper+0x4/0x10
Nov 18 16:04:29 slinux kernel: [  555.395548]  [<ffffffff8105b3d0>] ? 
kthread+0x0/0xa0
Nov 18 16:04:29 slinux kernel: [  555.395550]  [<ffffffff81003a10>] ? 
kernel_thread_helper+0x0/0x10
Nov 18 16:04:29 slinux kernel: [  555.395551] ---[ end trace 
8f55223a1de06cc7 ]---
Nov 18 16:04:29 slinux kernel: [  555.395552] ------------[ cut here 
]------------
Nov 18 16:04:29 slinux kernel: [  555.395558] WARNING: at 
fs/nfs/pnfs.c:479 pnfs_destroy_layout+0xe9/0x100 [nfs]()
Nov 18 16:04:29 slinux kernel: [  555.395559] Hardware name: VirtualBox
Nov 18 16:04:29 slinux kernel: [  555.395560] Modules linked in: 
nfs_layout_nfsv41_files nfs lockd fscache nfs_acl auth_rpcgss sunrpc 
ipv6 af_packet binfmt_misc dm_mirror dm_multipath scsi_dh video output 
thermal sbs sbshc pci_slot fan container battery lp sg ac option 
usb_wwan usbserial thermal_sys button parport_pc tpm_tis tpm serio_raw 
tpm_bios parport e1000 i2c_piix4 pata_mpiix dm_region_hash dm_log dm_mod 
[last unloaded: mperf]
Nov 18 16:04:29 slinux kernel: [  555.395575] Pid: 2259, comm: 
131.169.40.35-m Tainted: G        W   2.6.37-rc1.pnfs.1 #1
Nov 18 16:04:29 slinux kernel: [  555.395576] Call Trace:

this is

pnfs-all-2.6.37-rc1-2010-11-03 from Banny's tree (git
  6a1df873544d146fcdc493034b170879985909e8) +
http://git.kernel.org/?p=linux/kernel/git/torvalds/linux-2.6.git;a=blobdiff;f=mm/vmstat.c;h=42eac4d33216b81c307a87016e821051bc86146e;hp=cd2e42be7b68f73dc60f40631f2b9f87708d3b47;hb=ff8b16d7e15a8ba2a6086645614a483e048e3fbf;hpb=81a6cff678ecee7cdc0658285d3150660c07cfce



Regards,
    Tigran.
