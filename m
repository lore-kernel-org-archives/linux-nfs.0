From: Jim Eshleman <jce0@Lehigh.EDU>
Subject: 2.4.18 rpciod oops [xdr_encode_netobj]
Date: Fri, 15 Mar 2002 12:14:30 -0500
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <3C922BF6.8050405@Lehigh.EDU>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Received: from rain.cc.lehigh.edu ([128.180.39.20])
	by usw-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 16lvHl-0004EE-00
	for <nfs@lists.sourceforge.net>; Fri, 15 Mar 2002 09:14:34 -0800
To: nfs@lists.sourceforge.net, linux-xfs@oss.sgi.com
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
List-Archive: <http://www.geocrawler.com/redir-sf.php3?list=nfs>

   FYI.  There was no apparent effect on the running system, an 8-way
8.5G (64G HIGHMEM) P3 Xeon, running 2.4.18 + XFS, NIS, NFS, sendmail,
etc.  Let me know if more info is needed.

Jim

ksymoops 2.4.0 on i686 2.4.18-xfs.  Options used
      -v /usr/src/linux-2.4.18-xfs/vmlinux (specified)
      -K (specified)
      -L (specified)
      -O (specified)
      -m /usr/src/linux-2.4.18-xfs/System.map (specified)

kernel: Unable to handle kernel paging request at virtual address 40020045
kernel: c02e3d51
kernel: *pde = 1a3f3001
kernel: Oops: 0000
kernel: CPU:    7
kernel: EIP:    0010:[xdr_encode_netobj+49/80]    Not tainted
kernel: EIP:    0010:[<c02e3d51>]    Not tainted
Using defaults from ksymoops -t elf32-i386 -a i386
kernel: EFLAGS: 00010212
kernel: eax: eb46b468   ebx: cc6c20b0   ecx: 00020df4   edx: 000837d1
kernel: esi: 40020045   edi: cc6c20b0   ebp: eb46b41c   esp: f71ebef4
kernel: ds: 0018   es: 0018   ss: 0018
kernel: Process rpciod (pid: 728, stackpage=f71eb000)
kernel: Stack: eb46b470 f56fa05c c0197590 c0196c63 cc6c20ac eb46b468 
c0196e2a cc6c20ac
kernel:        eb46b468 eb46b41c f56fa05c c0197590 cd88dae0 eb46b41c 
f56fa05c c0197590
kernel:        cd88dae0 c01975d1 cc6c2078 eb46b41c f56fa05c f1ea7de0 
c02da78c f56fa05c
kernel: Call Trace: [nlm4clt_encode_testargs+0/96] 
[nlm4_encode_oh+15/20] [nlm4_encode_lock+66/360] 
[nlm4clt_encode_testargs+0/96] [nlm4clt_encode_testargs+0/96]
kernel: Call Trace: [<c0197590>] [<c0196c63>] [<c0196e2a>] [<c0197590>] 
[<c0197590>]
kernel:    [<c01975d1>] [<c02da78c>] [<c02de45c>] [<c02de8bd>] 
[<c02df20d>] [<c01057db>]
kernel: Code: f3 a5 f6 c2 02 74 02 66 a5 f6 c2 01 74 01 a4 8b 00 83 c0 03

 >>EIP; c02e3d51 <xdr_encode_netobj+31/50>   <=====
Trace; c0197590 <nlm4clt_encode_testargs+0/60>
Trace; c0196c63 <nlm4_encode_oh+f/14>
Trace; c0196e2a <nlm4_encode_lock+42/168>
Trace; c0197590 <nlm4clt_encode_testargs+0/60>
Trace; c0197590 <nlm4clt_encode_testargs+0/60>
Trace; c01975d1 <nlm4clt_encode_testargs+41/60>
Trace; c02da78c <call_encode+d8/108>
Trace; c02de45c <__rpc_execute+ac/310>
Trace; c02de8bd <__rpc_schedule+18d/1dc>
Trace; c02df20d <rpciod+111/284>
Trace; c01057db <kernel_thread+23/30>
Code;  c02e3d51 <xdr_encode_netobj+31/50>
00000000 <_EIP>:
Code;  c02e3d51 <xdr_encode_netobj+31/50>   <=====
    0:   f3 a5                     repz movsl %ds:(%esi),%es:(%edi)   <=====
Code;  c02e3d53 <xdr_encode_netobj+33/50>
    2:   f6 c2 02                  test   $0x2,%dl
Code;  c02e3d56 <xdr_encode_netobj+36/50>
    5:   74 02                     je     9 <_EIP+0x9> c02e3d5a 
<xdr_encode_netobj+3a/50>
Code;  c02e3d58 <xdr_encode_netobj+38/50>
    7:   66 a5                     movsw  %ds:(%esi),%es:(%edi)
Code;  c02e3d5a <xdr_encode_netobj+3a/50>
    9:   f6 c2 01                  test   $0x1,%dl
Code;  c02e3d5d <xdr_encode_netobj+3d/50>
    c:   74 01                     je     f <_EIP+0xf> c02e3d60 
<xdr_encode_netobj+40/50>
Code;  c02e3d5f <xdr_encode_netobj+3f/50>
    e:   a4                        movsb  %ds:(%esi),%es:(%edi)
Code;  c02e3d60 <xdr_encode_netobj+40/50>
    f:   8b 00                     mov    (%eax),%eax
Code;  c02e3d62 <xdr_encode_netobj+42/50>
   11:   83 c0 03                  add    $0x3,%eax


_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
