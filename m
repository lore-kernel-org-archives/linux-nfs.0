Return-Path: linux-nfs-owner@vger.kernel.org
Received: from smtprelay06.ispgateway.de ([80.67.31.96]:49545 "EHLO
	smtprelay06.ispgateway.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755550Ab2HNKGd (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 14 Aug 2012 06:06:33 -0400
Received: from [62.43.225.238] (helo=localhost)
	by smtprelay06.ispgateway.de with esmtpsa (TLSv1:AES256-SHA:256)
	(Exim 4.68)
	(envelope-from <richard.ems@cape-horn-eng.com>)
	id 1T1Dus-0006Gt-8C
	for linux-nfs@vger.kernel.org; Tue, 14 Aug 2012 12:00:02 +0200
Message-ID: <502A21A1.7020206@cape-horn-eng.com>
Date: Tue, 14 Aug 2012 12:00:01 +0200
From: Richard Ems <richard.ems@cape-horn-eng.com>
MIME-Version: 1.0
To: linux-nfs@vger.kernel.org
Subject: nfs_lookup_revalidate BUG ?
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi all !

We got the following BUG already 9 times in the last 6 days on 9 different nodes of our HPC cluster.
I searched but couldn't find this same BUG anywhere, but a similar one related to ecryptfs which we are not using.

The servers are running openSUSE 12.1 with kernel 3.3.6.
The nodes were updated from openSUSE 11.3 and kernel 2.6.34.7-0.5-default to openSUSE 12.1 and kernel 3.5.0.
Servers and nodes are running util-linux-2.20.1 and are all 64 bit systems.

The error appeared only after this update. Also after updating to kernel 3.5.1 we are getting the same error.


The BUG is triggered by a java application that runs as a batch job for hours on the nodes.
We are using autofs-5.0.7 on the HPC nodes and mounting only using NFS_V3, not using NFS_V4 at all.

On one of these nodes the mount options are:

c5n12:~ # mount | grep nfs
nfsd on /proc/fs/nfsd type nfsd (rw,relatime)
fs1:/data_4/ on /net/fs1/data_4 type nfs (rw,nosuid,nodev,relatime,vers=3,rsize=1048576,wsize=1048576,namlen=255,hard,proto=tcp,timeo=600,retrans=2,sec=sys,mountaddr=10.0.3.203,mountvers=3,mountport=58521,mountproto=udp,local_lock=none,addr=10.0.3.203)
fs1:/data_1/ on /net/fs1/data_1 type nfs (rw,nosuid,nodev,relatime,vers=3,rsize=1048576,wsize=1048576,namlen=255,hard,proto=tcp,timeo=600,retrans=2,sec=sys,mountaddr=10.0.3.203,mountvers=3,mountport=58521,mountproto=udp,local_lock=none,addr=10.0.3.203)
c3m:/opt/ on /net/c3m/opt type nfs (rw,nosuid,nodev,relatime,vers=3,rsize=1048576,wsize=1048576,namlen=255,hard,proto=tcp,timeo=600,retrans=2,sec=sys,mountaddr=10.0.3.201,mountvers=3,mountport=35374,mountproto=udp,local_lock=none,addr=10.0.3.201)


exportfs -v on the servers show all lines like:
/data_1         *.c5.xxx.com(rw,wdelay,no_root_squash,no_subtree_check)


Aug 14 06:25:00 c5n12 kernel: [53043.599388] BUG: unable to handle kernel NULL pointer dereference at 0000000000000038
Aug 14 06:25:00 c5n12 kernel: [53043.599523] IP: [<ffffffffa03789cd>] nfs_lookup_revalidate+0x2d/0x480 [nfs]
Aug 14 06:25:00 c5n12 kernel: [53043.599604] PGD 337c63067 PUD 0 
Aug 14 06:25:00 c5n12 kernel: [53043.599668] Oops: 0000 [#1] SMP 
Aug 14 06:25:00 c5n12 kernel: [53043.599732] CPU 5 
Aug 14 06:25:00 c5n12 kernel: [53043.599737] Modules linked in: nfs fscache nfsd lockd nfs_acl auth_rpcgss sunrpc af_packet binfmt_misc cpufreq_conservative cpufreq_userspace cpufreq_powersave dm_mod acpi_cpufreq mperf coretemp gpio_ich kvm_intel joydev kvm ioatdma hid_generic igb lpc_ich i7core_edac edac_core ptp serio_raw dca pcspkr i2c_i801 mfd_core sg pps_core usbhid crc32c_intel microcode button autofs4 uhci_hcd ttm drm_kms_helper drm i2c_algo_bit sysimgblt sysfillrect syscopyarea ehci_hcd usbcore usb_common scsi_dh_rdac scsi_dh_emc scsi_dh_hp_sw scsi_dh_alua scsi_dh edd fan ata_piix thermal processor thermal_sys
Aug 14 06:25:00 c5n12 kernel: [53043.600411] 
Aug 14 06:25:00 c5n12 kernel: [53043.600466] Pid: 30431, comm: java Not tainted 3.5.1-2-default #1 Supermicro X8DTT/X8DTT
Aug 14 06:25:00 c5n12 kernel: [53043.600594] RIP: 0010:[<ffffffffa03789cd>]  [<ffffffffa03789cd>] nfs_lookup_revalidate+0x2d/0x480 [nfs]
Aug 14 06:25:00 c5n12 kernel: [53043.600723] RSP: 0018:ffff8801b418bd38  EFLAGS: 00010292
Aug 14 06:25:00 c5n12 kernel: [53043.600787] RAX: 00000000fffffff6 RBX: ffff88032016d800 RCX: 0000000000000020
Aug 14 06:25:00 c5n12 kernel: [53043.600854] RDX: ffffffff00000000 RSI: 0000000000000000 RDI: ffff8801824a7b00
Aug 14 06:25:00 c5n12 kernel: [53043.600921] RBP: ffff8801b418bdf8 R08: 7fffff0034323030 R09: fffffffff04c03ed
Aug 14 06:25:00 c5n12 kernel: [53043.600989] R10: ffff8801824a7b00 R11: 0000000000000002 R12: ffff8801824a7b00
Aug 14 06:25:00 c5n12 kernel: [53043.601055] R13: ffff8801824a7b00 R14: 0000000000000000 R15: ffff8803201725d0
Aug 14 06:25:00 c5n12 kernel: [53043.601122] FS:  00002b53a46cb700(0000) GS:ffff88033fc20000(0000) knlGS:0000000000000000
Aug 14 06:25:00 c5n12 kernel: [53043.601241] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
Aug 14 06:25:00 c5n12 kernel: [53043.601335] CR2: 0000000000000038 CR3: 000000020a426000 CR4: 00000000000007e0
Aug 14 06:25:00 c5n12 kernel: [53043.601401] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
Aug 14 06:25:00 c5n12 kernel: [53043.601466] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
Aug 14 06:25:00 c5n12 kernel: [53043.601532] Process java (pid: 30431, threadinfo ffff8801b418a000, task ffff8801b5d20600)
Aug 14 06:25:00 c5n12 kernel: [53043.601650] Stack:
Aug 14 06:25:00 c5n12 kernel: [53043.601706]  ffff8801b418be44 ffff88032016d800 ffff8801b418bdf8 0000000000000000
Aug 14 06:25:00 c5n12 kernel: [53043.601829]  ffff8801824a7b00 ffff8801b418bdd7 ffff8803201725d0 ffffffff8116a9c0
Aug 14 06:25:00 c5n12 kernel: [53043.601952]  ffff8801b5c38dc0 0000000000000007 ffff88032016d800 0000000000000000
Aug 14 06:25:00 c5n12 kernel: [53043.602076] Call Trace:
Aug 14 06:25:00 c5n12 kernel: [53043.602153]  [<ffffffff8116a9c0>] lookup_dcache+0x80/0xe0
Aug 14 06:25:00 c5n12 kernel: [53043.602220]  [<ffffffff8116aa43>] __lookup_hash+0x23/0x90
Aug 14 06:25:00 c5n12 kernel: [53043.602284]  [<ffffffff8116b4a5>] lookup_one_len+0xc5/0x100
Aug 14 06:25:00 c5n12 kernel: [53043.602355]  [<ffffffffa03869a3>] nfs_sillyrename+0xe3/0x210 [nfs]
Aug 14 06:25:00 c5n12 kernel: [53043.602439]  [<ffffffff8116cadf>] vfs_unlink.part.25+0x7f/0xe0
Aug 14 06:25:00 c5n12 kernel: [53043.602504]  [<ffffffff8116f22c>] do_unlinkat+0x1ac/0x1d0
Aug 14 06:25:00 c5n12 kernel: [53043.602570]  [<ffffffff815717b9>] system_call_fastpath+0x16/0x1b
Aug 14 06:25:00 c5n12 kernel: [53043.602637]  [<00002b5348b5f527>] 0x2b5348b5f526
Aug 14 06:25:00 c5n12 kernel: [53043.602699] Code: ec 38 b8 f6 ff ff ff 4c 89 64 24 18 4c 89 74 24 28 49 89 fc 48 89 5c 24 08 48 89 6c 24 10 49 89 f6 4c 89 6c 24 20 4c 89 7c 24 30 <f6> 46 38 40 0f 85 d1 00 00 00 e8 c4 c4 df e0 48 8b 58 30 49 89 
Aug 14 06:25:00 c5n12 kernel: [53043.603008] RIP  [<ffffffffa03789cd>] nfs_lookup_revalidate+0x2d/0x480 [nfs]
Aug 14 06:25:00 c5n12 kernel: [53043.603080]  RSP <ffff8801b418bd38>
Aug 14 06:25:00 c5n12 kernel: [53043.603140] CR2: 0000000000000038
Aug 14 06:25:00 c5n12 kernel: [53043.603517] ---[ end trace 845113ed191985dd ]---


Is this a known BUG ?
Which other information or test can I do to contribute searching/resolving this issue?

Many thanks,
Richard



-- 
Richard Ems       mail: Richard.Ems@Cape-Horn-Eng.com

Cape Horn Engineering S.L.
C/ Dr. J.J. Dómine 1, 5º piso
46011 Valencia
Tel : +34 96 3242923 / Fax 924
http://www.cape-horn-eng.com
