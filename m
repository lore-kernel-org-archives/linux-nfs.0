From: Philippe =?ISO-8859-15?Q?Gramoull=E9?= <philippe.gramoulle@mmania.com>
Subject: 2.4.21 - Oops in rpciod
Date: Fri, 14 Nov 2003 12:10:05 +0100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20031114121005.5dceb59a.philippe.gramoulle@mmania.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 1AKbq8-0007Bc-00
	for <nfs@lists.sourceforge.net>; Fri, 14 Nov 2003 03:10:12 -0800
Received: from pgramoul.net2.nerim.net ([80.65.227.234] helo=philou.aspic.com)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.24)
	id 1AKbq7-0002is-RH
	for nfs@lists.sourceforge.net; Fri, 14 Nov 2003 03:10:12 -0800
To: nfs <nfs@lists.sourceforge.net>, linux-kernel@vger.kernel.org
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


 Hi,

I happened to get this oops with a 2.4.21 (Dell 2650) running as an NFS server.
The exported partition is ~ 700Gb/reiserfs and was 99.99% full (only few dozens of megabytes left).
(Distro is Debian Sid/Unstable, RAID driver is megaraid.o v 2.00.5)

Oops occured while also running a rsync process to move data to another server.

I'd like to have your opinion on this.

Thanks,

Philippe

Unable to handle kernel paging request at virtual address 6f79670a
c0113cd3
*pde = 00000000
Oops: 0002
CPU:    1
EIP:    0010:[<c0113cd3>]    Not tainted
Using defaults from ksymoops -t elf32-i386 -a i386
EFLAGS: 00010006
eax: 6f79670a   ebx: 6f796562   ecx: 00000001   edx: 00000003
esi: c9d787e0   edi: 6f79670a   ebp: ecf15f48   esp: ecf15f2c
ds: 0018   es: 0018   ss: 0018
Process rpciod (pid: 29302, stackpage=ecf15000)
Stack: 6f796562 c9d787e0 e5a77814 c0c50020 00000010 00000206 00000003 e5a77810 
       c0236cc5 e5a77800 e5a77814 c016bfb6 c9d787e0 e5a77800 00001770 d614f780 
       ecf14000 c02f0408 00000000 e5a77808 c0233f01 d614f780 d614f780 ecf14000 
Call Trace:    [<c0236cc5>] [<c016bfb6>] [<c0233f01>] [<c02340f7>] [<c0234a29>]
  [<c0105684>]
Code: f0 fe 0f 0f 88 74 10 00 00 89 4d f4 8b 5f 04 8b 03 0f 18 00 


>>EIP; c0113cd3 <__wake_up+1b/c4>   <=====

>>esi; c9d787e0 <_end+9a5743c/38634cbc>
>>ebp; ecf15f48 <_end+2cbf4ba4/38634cbc>
>>esp; ecf15f2c <_end+2cbf4b88/38634cbc>

Trace; c0236cc5 <svc_wake_up+59/98>
Trace; c016bfb6 <nlmsvc_grant_callback+fa/118>
Trace; c0233f01 <__rpc_execute+2d1/370>
Trace; c02340f7 <__rpc_schedule+e7/16c>
Trace; c0234a29 <rpciod+e5/21c>
Trace; c0105684 <arch_kernel_thread+28/38>

Code;  c0113cd3 <__wake_up+1b/c4>
00000000 <_EIP>:
Code;  c0113cd3 <__wake_up+1b/c4>   <=====
   0:   f0 fe 0f                  lock decb (%edi)   <=====
Code;  c0113cd6 <__wake_up+1e/c4>
   3:   0f 88 74 10 00 00         js     107d <_EIP+0x107d> c0114d50 <.text.lock.sched+8a/1da>
Code;  c0113cdc <__wake_up+24/c4>
   9:   89 4d f4                  mov    %ecx,0xfffffff4(%ebp)
Code;  c0113cdf <__wake_up+27/c4>
   c:   8b 5f 04                  mov    0x4(%edi),%ebx
Code;  c0113ce2 <__wake_up+2a/c4>
   f:   8b 03                     mov    (%ebx),%eax
Code;  c0113ce4 <__wake_up+2c/c4>
  11:   0f 18 00                  prefetchnta (%eax)

 <0>Kernel panic: Aiee, killing interrupt handler!


-------------------------------------------------------
This SF.Net email sponsored by: ApacheCon 2003,
16-19 November in Las Vegas. Learn firsthand the latest
developments in Apache, PHP, Perl, XML, Java, MySQL,
WebDAV, and more! http://www.apachecon.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
