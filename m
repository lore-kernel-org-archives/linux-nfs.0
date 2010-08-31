Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from lo.gmane.org ([80.91.229.12]:60702 "EHLO lo.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752753Ab0HaWKH (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 31 Aug 2010 18:10:07 -0400
Received: from list by lo.gmane.org with local (Exim 4.69)
	(envelope-from <glN-linux-nfs@m.gmane.org>)
	id 1OqZ1o-0001zf-Hs
	for linux-nfs@vger.kernel.org; Wed, 01 Sep 2010 00:10:04 +0200
Received: from host130.bluearc.com ([host130.bluearc.com])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <linux-nfs@vger.kernel.org>; Wed, 01 Sep 2010 00:10:04 +0200
Received: from sjoshi by host130.bluearc.com with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <linux-nfs@vger.kernel.org>; Wed, 01 Sep 2010 00:10:04 +0200
To: linux-nfs@vger.kernel.org
From: Sandeep Joshi <sjoshi@bluearc.com>
Subject: layout commit crash with 2.6.35.2-9
Date: Tue, 31 Aug 2010 21:43:57 +0000 (UTC)
Message-ID: <loom.20100831T232214-350@post.gmane.org>
Content-Type: text/plain; charset=us-ascii
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

I am observing following crash with with 2.6.35.2-9 on client side.
(I used rpm from Fedora site, dated Aug 24)

Aug 27 13:54:13 pnfs-client1 kernel: R13: ffff880079b34b00
 R14: ffff88007993c240
R15: 0000000000000000
Aug 27 13:54:13 pnfs-client1 kernel: 
FS:  00007f9051956720(0000)
GS:ffff880002c00000(0000) knlGS:000000000000000
0
Aug 27 13:54:13 pnfs-client1 kernel: CS:  0010 DS: 0000 ES: 0000 CR0:
0000000080050033
Aug 27 13:54:13 pnfs-client1 kernel: CR2: 00007fa9b0b9f198 
CR3: 000000007921d000
CR4: 00000000000006f0
Aug 27 13:54:13 pnfs-client1 kernel: DR0: 0000000000000000 
DR1: 0000000000000000
DR2: 0000000000000000
Aug 27 13:54:13 pnfs-client1 kernel: DR3: 0000000000000000 
DR6: 00000000ffff0ff0
DR7: 0000000000000400
Aug 27 13:54:13 pnfs-client1 kernel: Process test (pid: 3433, threadinfo
ffff880079d40000, task ffff88005690
8000)
Aug 27 13:54:13 pnfs-client1 kernel: Stack:
Aug 27 13:54:13 pnfs-client1 kernel: ffff880079d41bf8 ffffffff814a4f13
ffffffffa01e8130 ffffffff810e7958
Aug 27 13:54:13 pnfs-client1 kernel: <0> 6b6b6b6b6b6b6c1b 6b6b6b6b6b6b6b6b
ffff880079d41c18 ffffffffa01e8130
Aug 27 13:54:13 pnfs-client1 kernel: <0> ffff880079b34b00 ffffffffa01ed190
ffff880079d41c38 ffffffffa01d1759
Aug 27 13:54:13 pnfs-client1 kernel: Call Trace:
Aug 27 13:54:13 pnfs-client1 kernel: [<ffffffff814a4f13>] 
_raw_spin_lock+0x3e/0x69
Aug 27 13:54:13 pnfs-client1 kernel: [<ffffffffa01e8130>] 
? put_layout+0x1e/0x35
[nfs]
Aug 27 13:54:13 pnfs-client1 kernel: [<ffffffff810e7958>] 
? mempool_free+0x7d/0x85
Aug 27 13:54:13 pnfs-client1 kernel: [<ffffffffa01e8130>] 
put_layout+0x1e/0x35 [nfs]
Aug 27 13:54:13 pnfs-client1 kernel: [<ffffffffa01d1759>]
pnfs_layoutcommit_release+0x39/0x3e [nfs]
Aug 27 13:54:13 pnfs-client1 kernel: [<ffffffffa0185631>]
rpc_release_calldata+0x17/0x19 [sunrpc]
Aug 27 13:54:13 pnfs-client1 kernel: [<ffffffffa0185691>]
rpc_free_task+0x5e/0x67 [sunrpc]
Aug 27 13:54:13 pnfs-client1 kernel: [<ffffffffa018575d>] 
rpc_put_task+0xc3/0xc8
[sunrpc]
Aug 27 13:54:13 pnfs-client1 kernel: [<ffffffffa01cf3ee>]
_pnfs4_proc_layoutcommit+0x124/0x131 [nfs]
Aug 27 13:54:13 pnfs-client1 kernel: [<ffffffffa01e9680>]
 ?
pnfs_layoutcommit_inode+0x83/0x1a4 [nfs]
Aug 27 13:54:13 pnfs-client1 kernel: [<ffffffffa01d66b8>]
pnfs4_proc_layoutcommit+0x4b/0x6b [nfs]
Aug 27 13:54:13 pnfs-client1 kernel: [<ffffffffa01e975f>]
pnfs_layoutcommit_inode+0x162/0x1a4 [nfs]
Aug 27 13:54:13 pnfs-client1 kernel: [<ffffffffa01c82e2>]
nfs_write_inode+0xb8/0xc8 [nfs]
Aug 27 13:54:13 pnfs-client1 kernel: [<ffffffff81148bb1>]
writeback_single_inode+0x12b/0x1ec
Aug 27 13:54:13 pnfs-client1 kernel: [<ffffffff81148c9f>]
 sync_inode+0x2d/0x46
Aug 27 13:54:13 pnfs-client1 kernel: [<ffffffffa01c8334>] 
nfs_wb_all+0x42/0x44 [nfs]
Aug 27 13:54:13 pnfs-client1 kernel: [<ffffffffa01b99ce>]
 nfs_do_fsync+0x20/0x3b
[nfs]
Aug 27 13:54:13 pnfs-client1 kernel: [<ffffffffa01b9d6a>]
nfs_file_flush+0x6c/0x75 [nfs]
Aug 27 13:54:13 pnfs-client1 kernel: [<ffffffff8112a4c1>] 
? sys_close+0x32/0x12b
Aug 27 13:54:13 pnfs-client1 kernel: [<ffffffff8112a464>] 
filp_close+0x45/0x70
Aug 27 13:54:13 pnfs-client1 kernel: [<ffffffff814a5897>] 
?_raw_spin_unlock+0x2b/0x2f
Aug 27 13:54:13 pnfs-client1 kernel: [<ffffffff8112a578>]
 sys_close+0xe9/0x12b
Aug 27 13:54:13 pnfs-client1 kernel: [<ffffffff81009d32>]
system_call_fastpath+0x16/0x1b
Aug 27 13:54:13 pnfs-client1 kernel:
Code: 65 8b 04 25 20 eb 00 00 89 43 08 65
48 8b 04 25 00 cc 00 00 48 89 43 10 48 83 c4 18 5b 41 5c 41 5d 41 
5e 41 5f c9 c3
55 48 89 e5 <8b> 07 89 c2 c1 c0 10 39 c2 8d 90 00 00 01 00 75 04 
3e 0f b1 17
Aug 27 13:54:13 pnfs-client1 kernel: RIP  [<ffffffff812458ce>]
do_raw_spin_trylock+0x4/0x3d

Aug 27 13:54:13 pnfs-client1 kernel: RSP <ffff880079d41bc8>
Aug 27 13:54:13 pnfs-client1 kernel: ---[ end trace 1a8b3929210529eb ]---
Aug 27 13:54:21 pnfs-client1 abrt: Kerneloops: Reported 1 kernel oopses 
to Abrt
Aug 27 13:54:21 pnfs-client1 abrtd: Directory 'kerneloops-1282942461-1' 
creation detected


regards
Sandeep



