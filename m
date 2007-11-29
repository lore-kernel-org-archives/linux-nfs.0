From: Kamalesh Babulal <kamalesh@linux.vnet.ibm.com>
Subject: [NFS] [BUG] 2.6.24-rc3-mm2 kernel bug on nfs & cifs mounted
	partitions
Date: Thu, 29 Nov 2007 14:30:14 +0530
Message-ID: <474E7F9E.9000601__3387.13034657321$1196326968$gmane$org@linux.vnet.ibm.com>
References: <20071128034140.648383f0.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: samba-technical@lists.samba.org, linux-kernel@vger.kernel.org,
	linuxppc-dev-mnsaURCQ41sdnm+yROfE0A@public.gmane.org, nfs@lists.sourceforge.net,
	Andy Whitcroft <apw-26w3C0LaAnFg9hUCZPvPmw@public.gmane.org>,
	Balbir Singh <balbir@linux.vnet.ibm.com>
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IxfHX-0007sh-BA
	for nfs@lists.sourceforge.net; Thu, 29 Nov 2007 01:02:03 -0800
Received: from e28smtp06.in.ibm.com ([59.145.155.6] helo=e28esmtp06.in.ibm.com)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1IxfHZ-0003JV-77
	for nfs@lists.sourceforge.net; Thu, 29 Nov 2007 01:02:09 -0800
Received: from d28relay02.in.ibm.com (d28relay02.in.ibm.com [9.184.220.59])
	by e28esmtp06.in.ibm.com (8.13.1/8.13.1) with ESMTP id lAT90Fdl001508
	for <nfs@lists.sourceforge.net>; Thu, 29 Nov 2007 14:30:15 +0530
Received: from d28av01.in.ibm.com (d28av01.in.ibm.com [9.184.220.63])
	by d28relay02.in.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id
	lAT90FZo4276426
	for <nfs@lists.sourceforge.net>; Thu, 29 Nov 2007 14:30:15 +0530
Received: from d28av01.in.ibm.com (loopback [127.0.0.1])
	by d28av01.in.ibm.com (8.13.1/8.13.3) with ESMTP id lAT90Fag016357
	for <nfs@lists.sourceforge.net>; Thu, 29 Nov 2007 09:00:15 GMT
In-Reply-To: <20071128034140.648383f0.akpm@linux-foundation.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <nfs.lists.sourceforge.net>

Hi Andrew,

While running file system stress on nfs and cifs mounted partitions, the machine
drops to xmon

1:mon> e
cpu 0x1: Vector: 300 (Data Access) at [c000000080a9f880]
    pc: c0000000001392c8: .inotify_inode_queue_event+0x50/0x158
    lr: c0000000001074d0: .vfs_link+0x204/0x298
    sp: c000000080a9fb00
   msr: 8000000000009032
   dar: 280 
 dsisr: 40010000
  current = 0xc0000000c8e6f670
  paca    = 0xc000000000512c00
    pid   = 2848, comm = fsstress
1:mon> t
[c000000080a9fbd0] c0000000001074d0 .vfs_link+0x204/0x298
[c000000080a9fc70] c00000000010b6e0 .sys_linkat+0x134/0x1b4
[c000000080a9fe30] c00000000000872c syscall_exit+0x0/0x40
--- Exception: c00 (System Call) at 000000000ff1bdfc
SP (ffeaed10) is in userspace
1:mon> r
R00 = c0000000001074d0   R16 = 0000000000000000
R01 = c000000080a9fb00   R17 = 0000000000000000
R02 = c00000000060c380   R18 = 0000000000000000
R03 = 0000000000000000   R19 = 0000000000000000
R04 = 0000000000000004   R20 = 0000000000000000
R05 = 0000000000000000   R21 = 0000000000000000
R06 = 0000000000000000   R22 = 0000000000000000
R07 = 0000000000000000   R23 = 0000000000000004
R08 = 0000000000000000   R24 = 0000000000000280
R09 = 0000000000000000   R25 = fffffffffffff000
R10 = 0000000000000001   R26 = c000000082827790
R11 = c0000000003963e8   R27 = c0000000828275a0
R12 = d000000000deec78   R28 = 0000000000000000
R13 = c000000000512c00   R29 = c00000007b18fcf0
R14 = 0000000000000000   R30 = c0000000005bc088
R15 = 0000000000000000   R31 = 0000000000000000
pc  = c0000000001392c8 .inotify_inode_queue_event+0x50/0x158
lr  = c0000000001074d0 .vfs_link+0x204/0x298
msr = 8000000000009032   cr  = 24000882
ctr = c0000000003963e8   xer = 0000000000000000   trap =  300 
dar = 0000000000000280   dsisr = 40010000


The gdb output shows 

0xc0000000001076d4 is in vfs_symlink (include/linux/fsnotify.h:108).
103      * fsnotify_create - 'name' was linked in
104      */  
105     static inline void fsnotify_create(struct inode *inode, struct dentry *dentry)
106     {   
107             inode_dir_notify(inode, DN_CREATE);
108             inotify_inode_queue_event(inode, IN_CREATE, 0, dentry->d_name.name,
109                                       dentry->d_inode);
110             audit_inode_child(dentry->d_name.name, dentry, inode);
111     }   
112



-- 
Thanks & Regards,
Kamalesh Babulal,
Linux Technology Center,
IBM, ISTL.

-------------------------------------------------------------------------
SF.Net email is sponsored by: The Future of Linux Business White Paper
from Novell.  From the desktop to the data center, Linux is going
mainstream.  Let it simplify your IT future.
http://altfarm.mediaplex.com/ad/ck/8857-50307-18918-4
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
_______________________________________________
Please note that nfs@lists.sourceforge.net is being discontinued.
Please subscribe to linux-nfs@vger.kernel.org instead.
    http://vger.kernel.org/vger-lists.html#linux-nfs

