From: Damien CLERMONTE <damien.clermonte@free.fr>
Subject: nfs_put_unlinkdata oops with 2.6.13
Date: Thu, 08 Sep 2005 17:29:43 +0200
Message-ID: <432058E7.7070202@free.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1EDOLW-0008Ce-M3
	for nfs@lists.sourceforge.net; Thu, 08 Sep 2005 08:29:50 -0700
Received: from hrun.sitadelle.com ([213.223.184.201] helo=defiant.tech.sitadelle.com)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44)
	id 1EDOLU-0001VV-1p
	for nfs@lists.sourceforge.net; Thu, 08 Sep 2005 08:29:50 -0700
Received: from [127.0.0.1] (localhost [127.0.0.1])
	by defiant.tech.sitadelle.com (8.13.4/8.13.4) with ESMTP id j88FTh1D019400
	for <nfs@lists.sourceforge.net>; Thu, 8 Sep 2005 17:29:43 +0200
To: nfs@lists.sourceforge.net
Sender: nfs-admin@lists.sourceforge.net
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

Hi.
I'm having frequent oops in nfs_put_unlinkdata with linux 2.6.13 nfs
clients with a netapp nfs server.
The oops kills nfs completely, but the host continues to run.
Please CC me as I'm not on the list.

Thanks in advance.
Regards,
Damien

/proc/mounts options:
rw,nosuid,nodev,noexec,v3,rsize=32768,wsize=32768,hard,intr,tcp,lock

[...]
CONFIG_NFS_FS=y
CONFIG_NFS_V3=y
CONFIG_NFS_V3_ACL=y
CONFIG_NFS_V4=y
CONFIG_NFS_DIRECTIO=y
# CONFIG_NFSD is not set
CONFIG_ROOT_NFS=y
CONFIG_LOCKD=y
CONFIG_LOCKD_V4=y
CONFIG_NFS_ACL_SUPPORT=y
CONFIG_NFS_COMMON=y
CONFIG_SUNRPC=y
CONFIG_SUNRPC_GSS=y
CONFIG_RPCSEC_GSS_KRB5=y
# CONFIG_RPCSEC_GSS_SPKM3 is not set
[...]

Unable to handle kernel paging request at virtual address 40e10020
c0237508
*pgd =    0
Oops: 0000 [#1]
CPU:    0
EIP:    0060:[<c0237508>]    Not tainted VLI
Using defaults from ksymoops -t elf32-i386 -a i386
EFLAGS: 00010207   (2.6.13-grsec)
eax: 40e10020   ebx: f7bd3880   ecx: d4701180   edx: 40e10020
esi: 00000000   edi: f7bd3918   ebp: f7bd3898   esp: f744ef20
ds: 007b   es: 007b   ss: 0068
Stack: f7bd3898 c03904f4 f7bd3898 00000000 f7bd3898 c03900cc 00000003
f4ccd800
       d31ca000 f7bd3914 d31ca000 c01a5478 00000000 c200e560 00000000
d31ca020
       c0390190 00000296 f744e000 d31ca00c ffffffff ffffffff 00000001
00000000
Call Trace:
 [<c03904f4>]
 [<c03900cc>]
 [<c01a5478>]
 [<c0390190>]
 [<c0191f50>]
 [<c0191f50>]
 [<c01a52e0>]
 [<c01a90a4>]
 [<c01a9000>]
 [<c017bd75>]
Code: 83 d0 00 00 00 75 4c 8b 0d f4 d0 4e c0 ba f4 d0 4e c0 85 c9 74 1b
8d b6 00
 00 00 00 8d bc 27 00 00 00 00 8b 02 39 d8 74 1e 89 c2 <8b> 00 85 c0 75
f2 8b 43
 14 85 c0 75 08 89 d8 5b e9 f3 17 f8 ff


>>EIP; c0237508 <nfs_put_unlinkdata+38/70>   <=====

>>eax; 40e10020 <phys_startup_32+40c95020/bff86000>
>>ebx; f7bd3880 <pg0+376b2880/3fadd400>
>>ecx; d4701180 <pg0+141e0180/3fadd400>
>>edx; 40e10020 <phys_startup_32+40c95020/bff86000>
>>edi; f7bd3918 <pg0+376b2918/3fadd400>
>>ebp; f7bd3898 <pg0+376b2898/3fadd400>
>>esp; f744ef20 <pg0+36f2df20/3fadd400>

Trace; c03904f4 <rpc_release_task+94/f0>
Trace; c03900cc <__rpc_execute+19c/230>
Trace; c01a5478 <worker_thread+198/240>
Trace; c0390190 <rpc_async_schedule+0/10>
Trace; c0191f50 <default_wake_function+0/10>
Trace; c0191f50 <default_wake_function+0/10>
Trace; c01a52e0 <worker_thread+0/240>
Trace; c01a90a4 <kthread+a4/b0>
Trace; c01a9000 <kthread+0/b0>
Trace; c017bd75 <kernel_thread_helper+5/10>

This architecture has variable length instructions, decoding before eip
is unreliable, take these instructions with a pinch of salt.

Code;  c02374dd <nfs_put_unlinkdata+d/70>
00000000 <_EIP>:
Code;  c02374dd <nfs_put_unlinkdata+d/70>
   0:   83 d0 00                  adc    $0x0,%eax
Code;  c02374e0 <nfs_put_unlinkdata+10/70>
   3:   00 00                     add    %al,(%eax)
Code;  c02374e2 <nfs_put_unlinkdata+12/70>
   5:   75 4c                     jne    53 <_EIP+0x53>
Code;  c02374e4 <nfs_put_unlinkdata+14/70>
   7:   8b 0d f4 d0 4e c0         mov    0xc04ed0f4,%ecx
Code;  c02374ea <nfs_put_unlinkdata+1a/70>
   d:   ba f4 d0 4e c0            mov    $0xc04ed0f4,%edx
Code;  c02374ef <nfs_put_unlinkdata+1f/70>
  12:   85 c9                     test   %ecx,%ecx
Code;  c02374f1 <nfs_put_unlinkdata+21/70>
  14:   74 1b                     je     31 <_EIP+0x31>
Code;  c02374f3 <nfs_put_unlinkdata+23/70>
  16:   8d b6 00 00 00 00         lea    0x0(%esi),%esi
Code;  c02374f9 <nfs_put_unlinkdata+29/70>
  1c:   8d bc 27 00 00 00 00      lea    0x0(%edi,1),%edi
Code;  c0237500 <nfs_put_unlinkdata+30/70>
  23:   8b 02                     mov    (%edx),%eax
Code;  c0237502 <nfs_put_unlinkdata+32/70>
  25:   39 d8                     cmp    %ebx,%eax
Code;  c0237504 <nfs_put_unlinkdata+34/70>
  27:   74 1e                     je     47 <_EIP+0x47>
Code;  c0237506 <nfs_put_unlinkdata+36/70>
  29:   89 c2                     mov    %eax,%edx

This decode from eip onwards should be reliable

Code;  c0237508 <nfs_put_unlinkdata+38/70>
00000000 <_EIP>:
Code;  c0237508 <nfs_put_unlinkdata+38/70>   <=====
   0:   8b 00                     mov    (%eax),%eax   <=====
Code;  c023750a <nfs_put_unlinkdata+3a/70>
   2:   85 c0                     test   %eax,%eax
Code;  c023750c <nfs_put_unlinkdata+3c/70>
   4:   75 f2                     jne    fffffff8 <_EIP+0xfffffff8>
Code;  c023750e <nfs_put_unlinkdata+3e/70>
   6:   8b 43 14                  mov    0x14(%ebx),%eax
Code;  c0237511 <nfs_put_unlinkdata+41/70>
   9:   85 c0                     test   %eax,%eax
Code;  c0237513 <nfs_put_unlinkdata+43/70>
   b:   75 08                     jne    15 <_EIP+0x15>
Code;  c0237515 <nfs_put_unlinkdata+45/70>
   d:   89 d8                     mov    %ebx,%eax
Code;  c0237517 <nfs_put_unlinkdata+47/70>
   f:   5b                        pop    %ebx
Code;  c0237518 <nfs_put_unlinkdata+48/70>
  10:   e9 f3 17 f8 ff            jmp    fff81808 <_EIP+0xfff81808>



-------------------------------------------------------
This SF.Net email is sponsored by:
Power Architecture Resource Center: Free content, downloads, discussions,
and more. http://solutions.newsforge.com/ibmarch.tmpl
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
