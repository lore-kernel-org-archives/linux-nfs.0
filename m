From: canon@nersc.gov
Subject: Re: [PATCH] SGI 882960: Busy inodes after unmount, oops
Date: Fri, 13 Feb 2004 08:26:17 -0800
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <200402131626.i1DGQHUS019127@pookie.nersc.gov>
References: <gnb@melbourne.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1ArgAq-0002bI-K2
	for nfs@lists.sourceforge.net; Fri, 13 Feb 2004 08:28:16 -0800
Received: from pookie.nersc.gov ([128.55.16.113])
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.30)
	id 1Arg61-0006tC-7w
	for nfs@lists.sourceforge.net; Fri, 13 Feb 2004 08:23:17 -0800
Received: from pookie.nersc.gov (localhost [127.0.0.1])
	by pookie.nersc.gov (8.12.8/8.12.8) with ESMTP id i1DGQI32019131
	for <nfs@lists.sourceforge.net>; Fri, 13 Feb 2004 08:26:18 -0800
Received: from pookie.nersc.gov (canon@localhost)
	by pookie.nersc.gov (8.12.8/8.12.8/Submit) with ESMTP id i1DGQHUS019127
	for <nfs@lists.sourceforge.net>; Fri, 13 Feb 2004 08:26:18 -0800
To: Linux NFS Mailing List <nfs@lists.sourceforge.net>
In-Reply-To: Message from Greg Banks <gnb@melbourne.sgi.com>
   of "Fri, 06 Feb 2004 16:50:44 +1100." <40232B34.2AB2307A@melbourne.sgi.com>
Errors-To: nfs-admin@lists.sourceforge.net
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>


Greetings,

I'm seeing a similar oops and its starting to become a serious issue.
I'm loosing dozens of nodes a day to it.  See the oops below.  I'm
not seeing any errors before the oops, so I'm not sure if it is this
VFS unmount sequence.  I'll try to get more info and I will test out
the patch to see if it makes a difference.

Thanks,

--Shane

20:45:06 pdsflx301 login: Unable to handle kernel NULL pointer dereference at virtual address 00000004
20:45:06 *pde = 00000000
20:45:06 Oops: 0000
20:45:06 nfs lockd sunrpc autofs e1000 ipchains ext3 jbd raid0
20:45:06 CPU:    1
20:45:06 EIP:    0010:[<c015b5a1>]    Not tainted
20:45:06 EFLAGS: 00010246
20:45:06
20:45:06 EIP is at destroy_inode [kernel] 0x21 (2.4.20-28.7smp)
20:45:06 eax: 00000000   ebx: f6f1f6c0   ecx: f6f1f6c0   edx: f6f1f6c0
20:45:06 esi: f6f1f6c0   edi: f6f1f6c0   ebp: 00000295   esp: c2c2df3c
20:45:06 ds: 0018   es: 0018   ss: 0018
20:45:06 Process kswapd (pid: 5, stackpage=c2c2d000)
20:45:06 Stack: c03085d4 c015d096 f6f1f6c0 c0159f27 c47541c0 000002c9 f8a54cf9 e672ac58
20:45:06        e672ac40 f6f1f6c0 c015a320 f6f1f6c0 f6f1f6c0 c2c2df84 01186213 c0118bb3
20:45:06        c2c2df84 c2c2df84 00000000 00000000 01186213 ffff82a2 c0305820 000001d0
20:45:06 Call Trace:   [<c015d096>] iput [kernel] 0x2a6 (0xc2c2df40))
20:45:06 [<c0159f27>] dput [kernel] 0x47 (0xc2c2df48))
20:45:06 [<f8a54cf9>] nfs_dentry_iput [nfs] 0x59 (0xc2c2df54))
20:45:06 [<c015a320>] prune_dcache [kernel] 0xe0 (0xc2c2df64))
20:45:06 [<c0118bb3>] schedule_timeout [kernel] 0x83 (0xc2c2df78))
20:45:06 [<c015a720>] shrink_dcache_memory [kernel] 0x20 (0xc2c2dfa0))
20:45:06 [<c013c213>] do_try_to_free_pages_kswapd [kernel] 0x13 (0xc2c2dfa8))
20:45:06 [<c013c6d8>] kswapd [kernel] 0x138 (0xc2c2dfd4))
20:45:06 [<c0105000>] stext [kernel] 0x0 (0xc2c2dfe8))
20:45:06 [<c0107216>] arch_kernel_thread [kernel] 0x26 (0xc2c2dff0))
20:45:06 [<c013c5a0>] kswapd [kernel] 0x0 (0xc2c2dff8))
20:45:06
20:45:06
20:45:06 Code: 8b 40 04 85 c0 74 08 53 ff d0 5a eb 10 89 f6 53 ff 35 b8 91


------------------------------------------------------------------------
Shane Canon                             voice: 510-486-6981
PSDF Project Lead                       fax:   510-486-7520
National Energy Research Scientific
  Computing Center
1 Cyclotron Road Mailstop 943-256
Berkeley, CA 94720                      canon@nersc.gov
------------------------------------------------------------------------





-------------------------------------------------------
SF.Net is sponsored by: Speed Start Your Linux Apps Now.
Build and deploy apps & Web services for Linux with
a free DVD software kit from IBM. Click Now!
http://ads.osdn.com/?ad_id=1356&alloc_id=3438&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
