From: "Marco Schwarz" <marco.schwarz@gmx.net>
Subject: Re: do_vfs_lock Messages
Date: Thu, 09 Nov 2006 10:06:52 +0100
Message-ID: <20061109090652.18840@gmx.net>
References: <20061108144900.241780@gmx.net>
	<1163007231.5712.42.camel@lade.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Gi5yg-0001r4-BV
	for nfs@lists.sourceforge.net; Thu, 09 Nov 2006 01:13:42 -0800
Received: from mail.gmx.net ([213.165.64.20])
	by mail.sourceforge.net with smtp (Exim 4.44) id 1Gi5ye-0000BF-Oy
	for nfs@lists.sourceforge.net; Thu, 09 Nov 2006 01:13:43 -0800
In-Reply-To: <1163007231.5712.42.camel@lade.trondhjem.org>
To: Trond Myklebust <trond.myklebust@fys.uio.no>
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

> > Hi,
> > 
> > I am getting A LOT of messages like
> > 
> > Nov  8 15:34:56 linux kernel: do_vfs_lock: VFS is out of sync with lock
> manager!
> > Nov  8 15:35:06 linux last message repeated 156 times
> > 
> > on a discless client system (root on NFS) with Kernel 2.6.18
> > 
> > Is this critical ? If not, can I supress it somehow ? It doesnt happen
> with the same server and my older clients (running 2.4.something).
> 
> It isn't critical. Usually it just means that someone is interrupting
> NFS lock calls. You can suppress it by changing the 'console_loglevel'
> field in /proc/sys/kernel/printk. Use something like
> 
> echo "3       3       1       7" > /proc/sys/kernel/printk
> 
> Cheers,
>   Trond

Maybe these message are somehow related to the kernel error message that I get when doing heavy IO ? Here's one of them:

Nov  8 16:24:55 linux kernel: BUG: unable to handle kernel paging request at virtual address 6e696c43
Nov  8 16:24:55 linux kernel:  printing eip:
Nov  8 16:24:55 linux kernel: c041e445
Nov  8 16:24:55 linux kernel: *pde = 00000000
Nov  8 16:24:55 linux kernel: Oops: 0000 [#1]
Nov  8 16:24:55 linux kernel: Modules linked in:
Nov  8 16:24:55 linux kernel: CPU:    0
Nov  8 16:24:55 linux kernel: EIP:    0060:[<c041e445>]    Not tainted VLI
Nov  8 16:24:55 linux kernel: EFLAGS: 00010246   (2.6.18.2 #9)
Nov  8 16:24:55 linux kernel: EIP is at rpcauth_refreshcred+0x15/0x50
Nov  8 16:24:55 linux kernel: eax: df082c80   ebx: df082c80   ecx: 00000001   edx: 6e696c2f
Nov  8 16:24:55 linux kernel: esi: d9266000   edi: df082ce8   ebp: dd905d20   esp: dd905d04
Nov  8 16:24:55 linux kernel: ds: 007b   es: 007b   ss: 0068
Nov  8 16:24:55 linux kernel: Process ln (pid: 11347, ti=dd904000 task=df332560 task.ti=dd904000)
Nov  8 16:24:55 linux kernel: Stack: df082c80 00000000 c041d116 df082c80 00000000 dd905d48 c041825c 00000000
Nov  8 16:24:55 linux kernel:        00000000 d9266000 dee303e0 dd905d58 00000006 c01ec175 d78ad270 dee302d0
Nov  8 16:24:55 linux kernel:        dee302c8 c04ead60 dd905d68 00000006 d9266000 00000017 dd905ed8 00000001
Nov  8 16:24:55 linux kernel: Call Trace:
Nov  8 16:24:55 linux kernel:  [<c041d116>] __rpc_execute+0x46/0x1d0
Nov  8 16:24:55 linux kernel:  [<c041825c>] rpc_call_sync+0x8c/0xb0
Nov  8 16:24:55 linux kernel:  [<c01ec175>] nfs_proc_symlink+0xd5/0x140
Nov  8 16:24:55 linux kernel:  [<c0111a80>] do_page_fault+0x0/0x540
Nov  8 16:24:55 linux kernel:  [<c01e4f34>] nfs_symlink+0x84/0x160
Nov  8 16:24:55 linux kernel:  [<c0166689>] dput+0x99/0x140
Nov  8 16:24:55 linux kernel:  [<c01e3d32>] nfs_lookup_revalidate+0x172/0x450
Nov  8 16:24:55 linux kernel:  [<c0166d3b>] d_alloc+0x1b/0x170
Nov  8 16:24:55 linux kernel:  [<c016728b>] d_lookup+0x1b/0x40
Nov  8 16:24:55 linux kernel:  [<c01666b5>] dput+0xc5/0x140
Nov  8 16:24:55 linux kernel:  [<c016a6a3>] mntput_no_expire+0x13/0x60
Nov  8 16:24:55 linux kernel:  [<c015db90>] __link_path_walk+0x3e0/0xd30
Nov  8 16:24:55 linux kernel:  [<c01e55c2>] nfs_permission+0xf2/0x120
Nov  8 16:24:55 linux kernel:  [<c01e54d0>] nfs_permission+0x0/0x120
Nov  8 16:24:55 linux kernel:  [<c015d25a>] permission+0xba/0xe0
Nov  8 16:24:55 linux kernel:  [<c015db35>] __link_path_walk+0x385/0xd30
Nov  8 16:24:55 linux kernel:  [<c016a6a3>] mntput_no_expire+0x13/0x60
Nov  8 16:24:55 linux kernel:  [<c015e549>] link_path_walk+0x69/0xd0
Nov  8 16:24:55 linux kernel:  [<c01e54d0>] nfs_permission+0x0/0x120
Nov  8 16:24:55 linux kernel:  [<c015d25a>] permission+0xba/0xe0
Nov  8 16:24:55 linux kernel:  [<c01601e1>] vfs_symlink+0x91/0x100
Nov  8 16:24:55 linux kernel:  [<c01602c7>] sys_symlinkat+0x77/0xc0
Nov  8 16:24:55 linux kernel:  [<c0160321>] sys_symlink+0x11/0x20
Nov  8 16:24:55 linux kernel:  [<c0102d1d>] sysenter_past_esp+0x56/0x79
Nov  8 16:24:55 linux kernel: Code: e8 21 91 cf ff 83 c4 10 eb a2 8d b6 00 00 00 00 8d bf 00 00 00 00 56 53 8b 70 28 89 c3 f6 05 a8 27 63 c0 10 75 16 8b 56 08 89 d8 <ff> 52 14 8
5 c0 78 04 5b 5e c3 90 89 43 18 5b 5e c3 56 8b 40 10
Nov  8 16:24:55 linux kernel: EIP: [<c041e445>] rpcauth_refreshcred+0x15/0x50 SS:ESP 0068:dd905d04

They are quite annoying, and even worse sometimes the whole machine stops working - it looks like it looses its NFS root and can no longer access it ...

Best regards,
Marco Schwarz

-------------------------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
