From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [NFS] [BUG] 2.6.24-rc3-mm2 kernel bug on nfs & cifs mounted
 partitions
Date: Thu, 29 Nov 2007 01:09:06 -0800
Message-ID: <20071129010906.772e0c15.akpm__30252.8656473898$1196327509$gmane$org@linux-foundation.org>
References: <20071128034140.648383f0.akpm@linux-foundation.org>
	<474E7F9E.9000601@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Jan Kara <jack@suse.cz>, Balbir Singh <balbir@in.ibm.com>,
	samba-technical@lists.samba.org, linux-kernel@vger.kernel.org,
	linuxppc-dev-mnsaURCQ41sdnm+yROfE0A@public.gmane.org, nfs@lists.sourceforge.net,
	Andy Whitcroft <apw-26w3C0LaAnFg9hUCZPvPmw@public.gmane.org>
To: Kamalesh Babulal <kamalesh@linux.vnet.ibm.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IxfPM-0000TE-SE
	for nfs@lists.sourceforge.net; Thu, 29 Nov 2007 01:10:09 -0800
Received: from smtp2.linux-foundation.org ([207.189.120.14])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1IxfPR-00010N-OT
	for nfs@lists.sourceforge.net; Thu, 29 Nov 2007 01:10:15 -0800
In-Reply-To: <474E7F9E.9000601@linux.vnet.ibm.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <nfs.lists.sourceforge.net>

On Thu, 29 Nov 2007 14:30:14 +0530 Kamalesh Babulal <kamalesh@linux.vnet.ibm.com> wrote:

> Hi Andrew,
> 
> While running file system stress on nfs and cifs mounted partitions, the machine
> drops to xmon
> 
> 1:mon> e
> cpu 0x1: Vector: 300 (Data Access) at [c000000080a9f880]
>     pc: c0000000001392c8: .inotify_inode_queue_event+0x50/0x158
>     lr: c0000000001074d0: .vfs_link+0x204/0x298
>     sp: c000000080a9fb00
>    msr: 8000000000009032
>    dar: 280 
>  dsisr: 40010000
>   current = 0xc0000000c8e6f670
>   paca    = 0xc000000000512c00
>     pid   = 2848, comm = fsstress
> 1:mon> t
> [c000000080a9fbd0] c0000000001074d0 .vfs_link+0x204/0x298
> [c000000080a9fc70] c00000000010b6e0 .sys_linkat+0x134/0x1b4
> [c000000080a9fe30] c00000000000872c syscall_exit+0x0/0x40
> --- Exception: c00 (System Call) at 000000000ff1bdfc
> SP (ffeaed10) is in userspace
> 1:mon> r
> R00 = c0000000001074d0   R16 = 0000000000000000
> R01 = c000000080a9fb00   R17 = 0000000000000000
> R02 = c00000000060c380   R18 = 0000000000000000
> R03 = 0000000000000000   R19 = 0000000000000000
> R04 = 0000000000000004   R20 = 0000000000000000
> R05 = 0000000000000000   R21 = 0000000000000000
> R06 = 0000000000000000   R22 = 0000000000000000
> R07 = 0000000000000000   R23 = 0000000000000004
> R08 = 0000000000000000   R24 = 0000000000000280
> R09 = 0000000000000000   R25 = fffffffffffff000
> R10 = 0000000000000001   R26 = c000000082827790
> R11 = c0000000003963e8   R27 = c0000000828275a0
> R12 = d000000000deec78   R28 = 0000000000000000
> R13 = c000000000512c00   R29 = c00000007b18fcf0
> R14 = 0000000000000000   R30 = c0000000005bc088
> R15 = 0000000000000000   R31 = 0000000000000000
> pc  = c0000000001392c8 .inotify_inode_queue_event+0x50/0x158
> lr  = c0000000001074d0 .vfs_link+0x204/0x298
> msr = 8000000000009032   cr  = 24000882
> ctr = c0000000003963e8   xer = 0000000000000000   trap =  300 
> dar = 0000000000000280   dsisr = 40010000
> 
> 
> The gdb output shows 
> 
> 0xc0000000001076d4 is in vfs_symlink (include/linux/fsnotify.h:108).
> 103      * fsnotify_create - 'name' was linked in
> 104      */  
> 105     static inline void fsnotify_create(struct inode *inode, struct dentry *dentry)
> 106     {   
> 107             inode_dir_notify(inode, DN_CREATE);
> 108             inotify_inode_queue_event(inode, IN_CREATE, 0, dentry->d_name.name,
> 109                                       dentry->d_inode);
> 110             audit_inode_child(dentry->d_name.name, dentry, inode);
> 111     }   
> 112
> 

If it is reproducible can you please try reverting
inotify-send-in_attrib-events-when-link-count-changes.patch?

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

