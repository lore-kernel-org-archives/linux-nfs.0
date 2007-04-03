From: "Greg Bradner" <greg.bradner@gmail.com>
Subject: ROOT_NFS 2.6.20.4 kernel crash
Date: Tue, 3 Apr 2007 08:34:44 -0700
Message-ID: <57bc13580704030834n615eaf24tc3294e67916debcc@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HYl1w-0000B6-Ky
	for nfs@lists.sourceforge.net; Tue, 03 Apr 2007 08:34:48 -0700
Received: from wr-out-0506.google.com ([64.233.184.228])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HYl1y-0000ep-1x
	for nfs@lists.sourceforge.net; Tue, 03 Apr 2007 08:34:46 -0700
Received: by wr-out-0506.google.com with SMTP id i20so3234397wra
	for <nfs@lists.sourceforge.net>; Tue, 03 Apr 2007 08:34:45 -0700 (PDT)
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

I have booted into my NFS-Root and am trying to partition a drive.
But kernel is crashing while making dev names.

Kernel: 2.6.20.4
Motherboard: Intel S3000PT

The NFS server I'm mounted on is running: Suse 9.3 kernel 2.6.11.4-21.15-default

Any thoughts or need more info?

Apr  3 08:24:27 fbs2 kernel: SCSI device sda: 488397168 512-byte hdwr
sectors (250059 MB)
Apr  3 08:24:27 fbs2 kernel: sda: Write Protect is off
Apr  3 08:24:27 fbs2 kernel: sda: Mode Sense: 00 3a 00 00
Apr  3 08:24:27 fbs2 kernel: SCSI device sda: write cache: enabled,
read cache: enabled, doesn't support DPO or FUA
Apr  3 08:24:27 fbs2 kernel:  sda: sda1 sda2 sda3 sda4
Apr  3 08:24:27 fbs2 kernel: BUG: unable to handle kernel paging
request at virtual address 9e22d4d0
Apr  3 08:24:27 fbs2 kernel:  printing eip:
Apr  3 08:24:27 fbs2 syslog-ng[1749]: Changing permissions on special
file /dev/xconsole
Apr  3 08:24:27 fbs2 syslog-ng[1749]: Changing permissions on special
file /dev/tty10
Apr  3 08:24:27 fbs2 kernel: c0248c86
Apr  3 08:24:27 fbs2 kernel: *pde = 00000000
Apr  3 08:24:27 fbs2 kernel: Oops: 0000 [#1]
Apr  3 08:24:27 fbs2 kernel: SMP
Apr  3 08:24:27 fbs2 kernel: Modules linked in: evdev joydev st sr_mod
nvram edd parport_pc lp parport capability commoncap dm_mod
Apr  3 08:24:27 fbs2 kernel: CPU:    0
Apr  3 08:24:27 fbs2 kernel: EIP:    0060:[<c0248c86>]    Not tainted VLI
Apr  3 08:24:27 fbs2 kernel: EFLAGS: 00010297   (2.6.20.4-nfsroot #5)
Apr  3 08:24:27 fbs2 kernel: EIP is at radix_tree_gang_lookup_tag+0x66/0xc0
Apr  3 08:24:27 fbs2 kernel: eax: f773a230   ebx: 00000000   ecx:
00000015   edx: 00000000
Apr  3 08:24:27 fbs2 kernel: esi: f6e12ed0   edi: 00000000   ebp:
00000001   esp: f71f7d2c
Apr  3 08:24:27 fbs2 kernel: ds: 007b   es: 007b   ss: 0068
Apr  3 08:24:27 fbs2 kernel: Process udev (pid: 2624, ti=f71f6000
task=f780c550 task.ti=f71f6000)
Apr  3 08:24:27 fbs2 kernel: Stack: f71f7d70 c018c120 f71f7dec
c014e31e f71f7d68 0000000e f773a314 f773a140
Apr  3 08:24:27 fbs2 kernel:        00000000 ffffffff c01e8206
00000001 00000001 f773a22c 00000000 00000000
Apr  3 08:24:27 fbs2 kernel:        f773a314 f71f7dec f773a140
f71f7dec c01e9a30 00000002 f773a218 00000000
Apr  3 08:24:27 fbs2 kernel: Call Trace:
Apr  3 08:24:27 fbs2 kernel:  [<c018c120>] blkdev_writepage+0x0/0x10
Apr  3 08:24:27 fbs2 kernel:  [<c014e31e>] generic_writepages+0xee/0x350
Apr  3 08:24:27 fbs2 kernel:  [<c01e8206>] nfs_wait_on_requests_locked+0x86/0xb0
Apr  3 08:24:27 fbs2 kernel:  [<c01e9a30>] nfs_sync_mapping_wait+0xb0/0x1b0
Apr  3 08:24:27 fbs2 kernel:  [<c01e9bcd>] nfs_wb_all+0x9d/0xd0
Apr  3 08:24:27 fbs2 kernel:  [<c0115f20>] do_page_fault+0x460/0x590
Apr  3 08:24:27 fbs2 kernel:  [<c01e0585>] nfs_setattr+0x95/0x160
Apr  3 08:24:27 fbs2 kernel:  [<c016f1ee>] do_lookup+0x3e/0xb0
Apr  3 08:24:27 fbs2 kernel:  [<c0178659>] dput+0x99/0x150
Apr  3 08:24:27 fbs2 kernel:  [<c016fc8f>] __link_path_walk+0xa2f/0xcc0
Apr  3 08:24:27 fbs2 kernel:  [<c01796b1>] d_lookup+0x21/0x50
Apr  3 08:24:27 fbs2 kernel:  [<c01232a2>] current_fs_time+0x52/0x70
Apr  3 08:24:27 fbs2 kernel:  [<c017c2de>] notify_change+0x33e/0x390
Apr  3 08:24:27 fbs2 kernel:  [<c016714a>] chown_common+0x8a/0xc0
Apr  3 08:24:27 fbs2 kernel:  [<c01225e7>] sys_waitpid+0x27/0x30
Apr  3 08:24:27 fbs2 kernel:  [<c0170616>] __user_walk_fd+0x36/0x40
Apr  3 08:24:27 fbs2 kernel:  [<c01671b6>] sys_chown+0x36/0x50
Apr  3 08:24:27 fbs2 kernel:  [<c01225e7>] sys_waitpid+0x27/0x30
Apr  3 08:24:27 fbs2 kernel:  [<c0102d14>] sysenter_past_esp+0x5d/0x89
Apr  3 08:24:27 fbs2 kernel:  [<c0400033>] rpc_getport+0xc3/0x1b0
Apr  3 08:24:27 fbs2 kernel:  =======================
Apr  3 08:24:27 fbs2 kernel: Code: 8b 44 24 10 83 e6 fe ba 01 00 00 00
89 30 8d b4 26 00 00 00 00 83 c4 18 89 d0 5b 5e 5f 5d c3 8d b6 00 00
00 00 8b 06 31 db 39 eb <8b> 04 85 10 4c 54 c0 89 44 24 0c 73 3d 3b 7c
24 0c 77 37 8b 44
Apr  3 08:24:27 fbs2 kernel: EIP: [<c0248c86>]
radix_tree_gang_lookup_tag+0x66/0xc0 SS:ESP 0068:f71f7d2c
Apr  3 08:24:27 fbs2 kernel:  <1>BUG: unable to handle kernel paging
request at virtual address 9ebdc5d0
Apr  3 08:24:27 fbs2 kernel:  printing eip:
Apr  3 08:24:27 fbs2 kernel: c0248c86
Apr  3 08:24:27 fbs2 kernel: *pde = 00000000
Apr  3 08:24:27 fbs2 kernel: Oops: 0000 [#2]
Apr  3 08:24:27 fbs2 kernel: SMP
Apr  3 08:24:27 fbs2 kernel: Modules linked in: evdev joydev st sr_mod
nvram edd parport_pc lp parport capability commoncap dm_mod
Apr  3 08:24:27 fbs2 kernel: CPU:    0
Apr  3 08:24:27 fbs2 kernel: EIP:    0060:[<c0248c86>]    Not tainted VLI
Apr  3 08:24:27 fbs2 kernel: EFLAGS: 00010297   (2.6.20.4-nfsroot #5)
Apr  3 08:24:27 fbs2 kernel: EIP is at radix_tree_gang_lookup_tag+0x66/0xc0
Apr  3 08:24:27 fbs2 kernel: eax: f79a5e70   ebx: 00000000   ecx:
00000015   edx: 00000000
Apr  3 08:24:27 fbs2 kernel: esi: f6e129d8   edi: 00000000   ebp:
00000001   esp: f71ffd2c
Apr  3 08:24:27 fbs2 kernel: ds: 007b   es: 007b   ss: 0068
Apr  3 08:24:27 fbs2 kernel: Process udev (pid: 2626, ti=f71fe000
task=f7adb550 task.ti=f71fe000)
Apr  3 08:24:27 fbs2 kernel: Stack: f71ffd70 c018c120 f71ffdec
c014e31e f71ffd68 0000000e f79a5f54 f79a5d80
Apr  3 08:24:27 fbs2 kernel:        00000000 ffffffff c01e8206
00000001 00000001 f79a5e6c 00000000 00000000
Apr  3 08:24:27 fbs2 kernel:        f79a5f54 f71ffdec f79a5d80
f71ffdec c01e9a30 00000002 f79a5e58 00000000
Apr  3 08:24:27 fbs2 kernel: Call Trace:
Apr  3 08:24:27 fbs2 kernel:  [<c018c120>] blkdev_writepage+0x0/0x10
Apr  3 08:24:27 fbs2 kernel:  [<c014e31e>] generic_writepages+0xee/0x350
Apr  3 08:24:27 fbs2 kernel:  [<c01e8206>] nfs_wait_on_requests_locked+0x86/0xb0
Apr  3 08:24:27 fbs2 kernel:  [<c01e9a30>] nfs_sync_mapping_wait+0xb0/0x1b0
Apr  3 08:24:27 fbs2 kernel:  [<c01e9bcd>] nfs_wb_all+0x9d/0xd0
Apr  3 08:24:27 fbs2 kernel:  [<c0115f20>] do_page_fault+0x460/0x590
Apr  3 08:24:27 fbs2 kernel:  [<c01e0585>] nfs_setattr+0x95/0x160
Apr  3 08:24:27 fbs2 kernel:  [<c016f1ee>] do_lookup+0x3e/0xb0
Apr  3 08:24:27 fbs2 kernel:  [<c0178659>] dput+0x99/0x150
Apr  3 08:24:27 fbs2 kernel:  [<c016fc8f>] __link_path_walk+0xa2f/0xcc0
Apr  3 08:24:27 fbs2 kernel:  [<c014ce74>] __alloc_pages+0x54/0x2f0
Apr  3 08:24:27 fbs2 kernel:  [<c01232a2>] current_fs_time+0x52/0x70
Apr  3 08:24:27 fbs2 kernel:  [<c017c2de>] notify_change+0x33e/0x390
Apr  3 08:24:27 fbs2 kernel:  [<c016714a>] chown_common+0x8a/0xc0
Apr  3 08:24:27 fbs2 kernel:  [<c012007b>] read_profile+0xb/0xc0
Apr  3 08:24:27 fbs2 kernel:  [<c0170616>] __user_walk_fd+0x36/0x40
Apr  3 08:24:27 fbs2 kernel:  [<c01671b6>] sys_chown+0x36/0x50
Apr  3 08:24:27 fbs2 kernel:  [<c012007b>] read_profile+0xb/0xc0
Apr  3 08:24:27 fbs2 kernel:  [<c0102d14>] sysenter_past_esp+0x5d/0x89
Apr  3 08:24:27 fbs2 kernel:  =======================
Apr  3 08:24:27 fbs2 kernel: Code: 8b 44 24 10 83 e6 fe ba 01 00 00 00
89 30 8d b4 26 00 00 00 00 83 c4 18 89 d0 5b 5e 5f 5d c3 8d b6 00 00
00 00 8b 06 31 db 39 eb <8b> 04 85 10 4c 54 c0 89 44 24 0c 73 3d 3b 7c
24 0c 77 37 8b 44
Apr  3 08:24:27 fbs2 kernel: EIP: [<c0248c86>]
radix_tree_gang_lookup_tag+0x66/0xc0 SS:ESP 0068:f71ffd2c
Apr  3 08:24:27 fbs2 kernel:  <1>BUG: unable to handle kernel paging
request at virtual address 9e22cdd0
Apr  3 08:24:27 fbs2 kernel:  printing eip:
Apr  3 08:24:27 fbs2 kernel: c0248c86
Apr  3 08:24:27 fbs2 kernel: *pde = 00000000
Apr  3 08:24:27 fbs2 kernel: Oops: 0000 [#3]
Apr  3 08:24:27 fbs2 kernel: SMP
Apr  3 08:24:27 fbs2 kernel: Modules linked in: evdev joydev st sr_mod
nvram edd parport_pc lp parport capability commoncap dm_mod
Apr  3 08:24:27 fbs2 kernel: CPU:    0
Apr  3 08:24:27 fbs2 kernel: EIP:    0060:[<c0248c86>]    Not tainted VLI
Apr  3 08:24:27 fbs2 kernel: EFLAGS: 00010297   (2.6.20.4-nfsroot #5)
Apr  3 08:24:27 fbs2 kernel: EIP is at radix_tree_gang_lookup_tag+0x66/0xc0
Apr  3 08:24:27 fbs2 kernel: eax: f773a070   ebx: 00000000   ecx:
00000015   edx: 00000000
Apr  3 08:24:27 fbs2 kernel: esi: f76cd264   edi: 00000000   ebp:
00000001   esp: f79afd2c
Apr  3 08:24:27 fbs2 kernel: ds: 007b   es: 007b   ss: 0068
Apr  3 08:24:27 fbs2 kernel: Process udev (pid: 2622, ti=f79ae000
task=f7e9ba70 task.ti=f79ae000)
Apr  3 08:24:27 fbs2 kernel: Stack: f79afd70 c018c120 f79afdec
c014e31e f79afd68 0000000e f773a154 f7739f80
Apr  3 08:24:27 fbs2 kernel:        00000000 ffffffff c01e8206
00000001 00000001 f773a06c 00000000 00000000
Apr  3 08:24:27 fbs2 kernel:        f773a154 f79afdec f7739f80
f79afdec c01e9a30 000000aa f773a058 00000000
Apr  3 08:24:27 fbs2 kernel: Call Trace:
Apr  3 08:24:27 fbs2 kernel:  [<c018c120>] blkdev_writepage+0x0/0x10
Apr  3 08:24:27 fbs2 kernel:  [<c014e31e>] generic_writepages+0xee/0x350
Apr  3 08:24:27 fbs2 kernel:  [<c01e8206>] nfs_wait_on_requests_locked+0x86/0xb0
Apr  3 08:24:27 fbs2 kernel:  [<c01e9a30>] nfs_sync_mapping_wait+0xb0/0x1b0
Apr  3 08:24:27 fbs2 kernel:  [<c01e9bcd>] nfs_wb_all+0x9d/0xd0
Apr  3 08:24:27 fbs2 kernel:  [<c0115f20>] do_page_fault+0x460/0x590
Apr  3 08:24:27 fbs2 kernel:  [<c01e0585>] nfs_setattr+0x95/0x160
Apr  3 08:24:27 fbs2 kernel:  [<c016f1ee>] do_lookup+0x3e/0xb0
Apr  3 08:24:27 fbs2 kernel:  [<c0178659>] dput+0x99/0x150
Apr  3 08:24:27 fbs2 kernel:  [<c016fc8f>] __link_path_walk+0xa2f/0xcc0
Apr  3 08:24:27 fbs2 kernel:  [<c01796b1>] d_lookup+0x21/0x50
Apr  3 08:24:27 fbs2 kernel:  [<c01232a2>] current_fs_time+0x52/0x70
Apr  3 08:24:27 fbs2 kernel:  [<c017c2de>] notify_change+0x33e/0x390
Apr  3 08:24:27 fbs2 kernel:  [<c016714a>] chown_common+0x8a/0xc0
Apr  3 08:24:27 fbs2 kernel:  [<c01225e7>] sys_waitpid+0x27/0x30
Apr  3 08:24:27 fbs2 kernel:  [<c0170616>] __user_walk_fd+0x36/0x40
Apr  3 08:24:27 fbs2 kernel:  [<c01671b6>] sys_chown+0x36/0x50
Apr  3 08:24:27 fbs2 kernel:  [<c01225e7>] sys_waitpid+0x27/0x30
Apr  3 08:24:27 fbs2 kernel:  [<c0102d14>] sysenter_past_esp+0x5d/0x89
Apr  3 08:24:27 fbs2 kernel:  [<c0400033>] rpc_getport+0xc3/0x1b0
Apr  3 08:24:27 fbs2 kernel:  =======================
Apr  3 08:24:27 fbs2 kernel: Code: 8b 44 24 10 83 e6 fe ba 01 00 00 00
89 30 8d b4 26 00 00 00 00 83 c4 18 89 d0 5b 5e 5f 5d c3 8d b6 00 00
00 00 8b 06 31 db 39 eb <8b> 04 85 10 4c 54 c0 89 44 24 0c 73 3d 3b 7c
24 0c 77 37 8b 44
Apr  3 08:24:27 fbs2 kernel: EIP: [<c0248c86>]
radix_tree_gang_lookup_tag+0x66/0xc0 SS:ESP 0068:f79afd2c

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys-and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
