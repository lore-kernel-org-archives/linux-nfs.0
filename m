From: =?iso-8859-1?Q?Brasseur_Val=E9ry?= <Valery.Brasseur@atosorigin.com>
Subject: linux 2.4.20 oops
Date: Tue, 29 Apr 2003 11:18:20 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <8147E1B07201DD41B6B9F0D31E07B384449055@srv-grp-s07.dev.atos.fr>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from hermes4.atos-group.com ([160.92.18.11])
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 19ARFu-00038c-00
	for <nfs@lists.sourceforge.net>; Tue, 29 Apr 2003 02:18:31 -0700
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

I have got this oops in my kernel (2.4.20 + NFS-ALL )
note : the oops are not log in syslog (don't know why !)
but the oops seems nfs-related, any ideas ?

Warning (compare_maps): mismatch on symbol ixp_mac_cache_timer_active  ,
rxp.2.4.20-xfs.mp says f8b3161c, /usr/local/resonate/etc/rxp.2.4.20-xfs.mp
says f8b31404.  Ignoring /usr/local/resonate/etc/rxp.2.4.20-xfs.mp entry
Reading Oops report from the terminal
Call Trace: [<c02b8dd4>] [<c02ba007>] [<c02b9f90>] [<c012268f>] [<c011e7cf>]
[<c010a30b>]
[<c0106d7c>] [<c0106dcb>] [<c011a019>] [<c011a29b>] [<c011a10>]
Code: 8b 40 2c 47 89 7c 24 10 b9 08 00 00 00 83 f8 09 0f 4c c8 b8
Using defaults from ksymoops -t elf32-i386 -a i386

Trace; c02b8dd4 <rpc_restart_call+1fec/28ec>
Trace; c02ba007 <xprt_destroy+3b3/80c>
Trace; c02b9f90 <xprt_destroy+33c/80c>
Trace; c012268f <del_timer_sync+75f/9c0>
Trace; c011e7cf <do_softirq+6f/cc>
Trace; c010a30b <enable_irq+17f/190>
Trace; c0106d7c <enable_hlt+34/150>
Trace; c0106dcb <enable_hlt+83/150>
Trace; c011a019 <__out_of_line_bug+579/5e8>
Trace; c011a29b <acquire_console_sem+d3/100>
Trace; c011a1a0 <printk+118/140>

Code;  00000000 Before first symbol
00000000 <_EIP>:
Code;  00000000 Before first symbol
   0:   8b 40 2c                  mov    0x2c(%eax),%eax
Code;  00000003 Before first symbol
   3:   47                        inc    %edi
Code;  00000004 Before first symbol
   4:   89 7c 24 10               mov    %edi,0x10(%esp,1)
Code;  00000008 Before first symbol
   8:   b9 08 00 00 00            mov    $0x8,%ecx
Code;  0000000d Before first symbol
   d:   83 f8 09                  cmp    $0x9,%eax
Code;  00000010 Before first symbol
  10:   0f 4c c8                  cmovl  %eax,%ecx
Code;  00000013 Before first symbol
  13:   b8 00 00 00 00            mov    $0x0,%eax

thanks in advance
valery


-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
