From: James Pearson <james-p@moving-picture.com>
Subject: nfsd oops
Date: Tue, 05 Aug 2003 11:42:05 +0100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <3F2F89FD.BAE37A08@moving-picture.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from mpc-26.sohonet.co.uk ([193.203.82.251] helo=moving-picture.com)
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 19jzH9-0001Vl-00
	for <nfs@lists.sourceforge.net>; Tue, 05 Aug 2003 03:42:43 -0700
Received: from darke.mpc.local ([172.16.11.6] helo=moving-picture.com)
	by moving-picture.com with esmtp (Exim 3.22 #1)
	id 19jzGX-0001C0-00
	for nfs@lists.sourceforge.net; Tue, 05 Aug 2003 11:42:05 +0100
To: nfs@lists.sourceforge.net
Errors-To: nfs-admin@lists.sourceforge.net
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

I had the following oops on a machine that is an NFS server to diskless
clients.

The machine is running a rather old kernel - 2.4.18 with XFS v1.1 -
upgrading the kernel will not be a problem, although I would appreciate
if anyone knows if this a known problem (and fixed in a later kernel)
...

Thanks

James Pearson

Aug  5 04:30:58 mpcboot-b kernel: Unable to handle kernel NULL pointer
dereference at virtual address 00000000
Aug  5 04:30:58 mpcboot-b kernel: 00000000
Aug  5 04:30:58 mpcboot-b kernel: *pde = 00000000
Aug  5 04:30:58 mpcboot-b kernel: Oops: 0000
Aug  5 04:30:58 mpcboot-b kernel: CPU:    0
Aug  5 04:30:58 mpcboot-b kernel: EIP:    0010:[<00000000>]    Not
tainted
Using defaults from ksymoops -t elf32-i386 -a i386
Aug  5 04:30:58 mpcboot-b kernel: EFLAGS: 00010282
Aug  5 04:30:58 mpcboot-b kernel: eax: 00000000   ebx: c209ad40   ecx:
00000000   edx: c0361360
Aug  5 04:30:58 mpcboot-b kernel: esi: c209ab40   edi: c209ad40   ebp:
c209ad40   esp: c6de5e80
Aug  5 04:30:58 mpcboot-b kernel: ds: 0018   es: 0018   ss: 0018
Aug  5 04:30:58 mpcboot-b kernel: Process nfsd (pid: 879,
stackpage=c6de5000)
Aug  5 04:30:58 mpcboot-b kernel: Stack: c88c3054 c7e3a960 c209ab40
c6cc6c00 c7e87800 c88c34c9 c209ad40 c6cc6c00 
Aug  5 04:30:58 mpcboot-b kernel:        00000005 c6b78800 46000000
c6f430c0 c7e87a10 00000005 c88c37f2 c7e87800 
Aug  5 04:30:58 mpcboot-b kernel:        c6cc6c10 00000005 00000001
00000000 00000007 c6cc6a00 c3838850 c6cc6c00 
Aug  5 04:30:58 mpcboot-b kernel: Call Trace: [<c88c3054>] [<c88c34c9>]
[<c88c37f2>] [<c023ff2c>] [<c88c4242>] 
Aug  5 04:30:58 mpcboot-b kernel:    [<c88c8c1d>] [<c88c1dc1>]
[<c88d1020>] [<c88c15d3>] [<c88d1020>] [<c8890f89>] 
Aug  5 04:30:58 mpcboot-b kernel:    [<c88d1440>] [<c88d0ee8>]
[<c88c1349>] [<c88d0ee0>] [<c01057db>] 
Aug  5 04:30:58 mpcboot-b kernel: Code:  Bad EIP value.

>>EIP; 00000000 Before first symbol
Trace; c88c3054 <[nfsd]nfsd_findparent+34/fc>
Trace; c88c34c9 <[nfsd]find_fh_dentry+201/324>
Trace; c88c37f2 <[nfsd]fh_verify+206/3e4>
Trace; c023ff2c <skb_checksum+4c/2f8>
Trace; c88c4242 <[nfsd]nfsd_lookup+72/3e8>
Trace; c88c8c1d <[nfsd]nfssvc_decode_diropargs+5d/c4>
Trace; c88c1dc1 <[nfsd]nfsd_proc_lookup+8d/a0>
Trace; c88d1020 <[nfsd]nfsd_procedures2+80/240>
Trace; c88c15d3 <[nfsd]nfsd_dispatch+d3/19a>
Trace; c88d1020 <[nfsd]nfsd_procedures2+80/240>
Trace; c8890f89 <[sunrpc]svc_process+28d/51c>
Trace; c88d1440 <[nfsd]nfsd_svcstats+0/20>
Trace; c88d0ee8 <[nfsd]nfsd_version2+0/10>
Trace; c88c1349 <[nfsd]nfsd+1b9/370>
Trace; c88d0ee0 <[nfsd]nfsd_list+0/0>
Trace; c01057db <kernel_thread+23/1a4>

Aug  5 10:29:20 mpcboot-b kernel: cpu: 0, clocks: 1002270, slice: 501135
Aug  5 10:29:20 mpcboot-b kernel: SGI XFS with quota, no debug enabled


-------------------------------------------------------
This SF.Net email sponsored by: Free pre-built ASP.NET sites including
Data Reports, E-commerce, Portals, and Forums are available now.
Download today and enter to win an XBOX or Visual Studio .NET.
http://aspnet.click-url.com/go/psa00100003ave/direct;at.aspnet_072303_01/01
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
