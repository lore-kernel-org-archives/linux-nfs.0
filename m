From: Kamalesh Babulal <kamalesh@linux.vnet.ibm.com>
Subject: [BUG] 2.6.24-rc2-mm1 - kernel bug on nfs v4
Date: Fri, 16 Nov 2007 19:45:36 +0530
Message-ID: <473DA608.1020804@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: Andrew Morton <akpm@linux-foundation.org>,
	LKML <linux-kernel@vger.kernel.org>, linuxppc-dev@ozlabs.org,
	nfs@lists.sourceforge.net, Andy Whitcroft <apw@shadowen.org>,
	Balbir Singh <ba
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1It1zs-00083H-UV
	for nfs@lists.sourceforge.net; Fri, 16 Nov 2007 06:16:41 -0800
Received: from e23smtp04.au.ibm.com ([202.81.18.173])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1It1zv-0006tU-9Y
	for nfs@lists.sourceforge.net; Fri, 16 Nov 2007 06:16:46 -0800
Received: from d23relay03.au.ibm.com (d23relay03.au.ibm.com [202.81.18.234])
	by e23smtp04.au.ibm.com (8.13.1/8.13.1) with ESMTP id lAGEFvZ3015067
	for <nfs@lists.sourceforge.net>; Sat, 17 Nov 2007 01:15:57 +1100
Received: from d23av04.au.ibm.com (d23av04.au.ibm.com [9.190.235.139])
	by d23relay03.au.ibm.com (8.13.8/8.13.8/NCO v8.6) with ESMTP id
	lAGEG4Bs1519822
	for <nfs@lists.sourceforge.net>; Sat, 17 Nov 2007 01:16:04 +1100
Received: from d23av04.au.ibm.com (loopback [127.0.0.1])
	by d23av04.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id
	lAGEFlM7030555
	for <nfs@lists.sourceforge.net>; Sat, 17 Nov 2007 01:15:47 +1100
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

Hi Andrew,

The kernel enters the xmon state while running the file system
stress on nfs v4 mounted partition.
 
0:mon> e
cpu 0x0: Vector: 300 (Data Access) at [c0000000dbd4f820]
    pc: c000000000065be4: .__wake_up_common+0x44/0xe8
    lr: c000000000069768: .__wake_up+0x54/0x88
    sp: c0000000dbd4faa0
   msr: 8000000000001032
   dar: 0
 dsisr: 40010000
  current = 0xc0000000dfb6f680
  paca    = 0xc000000000574580
    pid   = 1865, comm = rpciod/0
0:mon> t
[c0000000dbd4fb50] c000000000069768 .__wake_up+0x54/0x88
[c0000000dbd4fc00] d00000000086b890 .nfs_sb_deactive+0x44/0x58 [nfs]
[c0000000dbd4fc80] d000000000872658 .nfs_free_unlinkdata+0x2c/0x74 [nfs]
[c0000000dbd4fd10] d000000000598510 .rpc_release_calldata+0x50/0x74 [sunrpc]
[c0000000dbd4fda0] c00000000008d960 .run_workqueue+0x10c/0x1f4
[c0000000dbd4fe50] c00000000008ec70 .worker_thread+0x118/0x138
[c0000000dbd4ff00] c0000000000939f4 .kthread+0x78/0xc4
[c0000000dbd4ff90] c00000000002b060 .kernel_thread+0x4c/0x68
0:mon> r
R00 = c000000000069768   R16 = 4000000001c00000
R01 = c0000000dbd4faa0   R17 = c0000000004410c0
R02 = c0000000006752d8   R18 = 0000000000000000
R03 = c0000000ace4ffc0   R19 = 000000000019c000
R04 = 0000000000000003   R20 = c00000000050af08
R05 = 0000000000000001   R21 = 000000000210af08
R06 = 0000000000000000   R22 = 000000000210b178
R07 = 0000000000000000   R23 = c00000000050b178
R08 = 0000000000000000   R24 = 0000000000000003
R09 = 0000000000000000   R25 = 0000000000000000
R10 = 0000000000000001   R26 = 0000000000000000
R11 = ffffffffffffffe8   R27 = c0000000ace4ffc0
R12 = 0000000000004000   R28 = 0000000000000001
R13 = c000000000574580   R29 = 0000000000000003
R14 = 0000000000000000   R30 = c00000000061bad8
R15 = c000000000442888   R31 = d0000000008baa50
pc  = c000000000065be4 .__wake_up_common+0x44/0xe8
lr  = c000000000069768 .__wake_up+0x54/0x88
msr = 8000000000001032   cr  = 24000022
ctr = 80000000001af404   xer = 0000000000000002   trap =  300
dar = 0000000000000000   dsisr = 40010000
0:mon>

-- 
Thanks & Regards,
Kamalesh Babulal,
Linux Technology Center,
IBM, ISTL.

-------------------------------------------------------------------------
This SF.net email is sponsored by: Microsoft
Defy all challenges. Microsoft(R) Visual Studio 2005.
http://clk.atdmt.com/MRT/go/vse0120000070mrt/direct/01/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
_______________________________________________
Please note that nfs@lists.sourceforge.net is being discontinued.
Please subscribe to linux-nfs@vger.kernel.org instead.
    http://vger.kernel.org/vger-lists.html#linux-nfs
