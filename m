From: Bas van der Vlies <basv@sara.nl>
Subject: NFSD crashes with oops
Date: Wed, 8 Mar 2006 09:00:24 +0100
Message-ID: <5F4E2391-4553-4A5A-8A92-1033CE717267@sara.nl>
Mime-Version: 1.0 (Apple Message framework v746.2)
Content-Type: text/plain; charset=US-ASCII; delsp=yes; format=flowed
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1FGtat-0008Mv-7E
	for nfs@lists.sourceforge.net; Wed, 08 Mar 2006 00:00:27 -0800
Received: from smtp-vbr15.xs4all.nl ([194.109.24.35])
	by mail.sourceforge.net with esmtp (Exim 4.44)
	id 1FGtas-0003y6-Te
	for nfs@lists.sourceforge.net; Wed, 08 Mar 2006 00:00:27 -0800
Received: from [192.168.1.2] (bastiaan.xs4all.nl [82.93.6.142])
	by smtp-vbr15.xs4all.nl (8.13.3/8.13.3) with ESMTP id k2880Psl034470
	for <nfs@lists.sourceforge.net>; Wed, 8 Mar 2006 09:00:25 +0100 (CET)
	(envelope-from basv@sara.nl)
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

At our side we have an 4 node GFS cluster. The nodes act as an NFS- 
server to +/- 640 nodes.

GFS -nodes :
  * Debian sarge
  * 2.6.14.7
  * nfs-common 1:1.0.6-3.1
  * nfs-kernel-server 1:1.0.6-3.1
  * 128 NFSD-threads

clients:
  * Debian sarge
  * 2.6.15.6
  * nfs-common 1:1.0.6-3.1


After a while a nfsd-daemon will crash with the following error  
message. Sometimes it will survive a crash an go on and have
one thread less. But after a while all nfsd-daemons freezes. GFS and  
the machine is still working, but the server will not response to NFS- 
requests anymore. We have to reboot to fix the problem.

Has anybody seen this before or have an solution?

---- kernel Oops ----
Unable to handle kernel NULL pointer dereference at virtual address  
00000038
printing eip:
f89bf999
*pde = 37bff001
*pte = 00000000
Oops: 0000 [#1]
SMP
Modules linked in: lock_dlm dlm cman dm_round_robin dm_multipath sg  
ide_floppy ide_cd cdrom qla2300 qla2xxx_conf qla2xxx firmware_class  
siimage piix e1000 gfs lock_harness dm_mod
CPU:    0
EIP:    0060:[<f89bf999>]    Tainted: GF     VLI
EFLAGS: 00010246   (2.6.14.7-sara1)
EIP is at gfs_create+0xa9/0x1e0 [gfs]
eax: ffffffef   ebx: ffffffef   ecx: 00000001   edx: 00000000
esi: f296e24c   edi: ebf01e18   ebp: ebf01e84   esp: ebf01df8
ds: 007b   es: 007b   ss: 0068
Process nfsd (pid: 16924, threadinfo=ebf00000 task=ebe84540)
Stack: ebf01e48 f296e24c 00000001 00008180 ebf01e18 00000001 f8cb9000  
dd042254
        ebf01e18 ebf01e18 00000000 ebe84540 00000001 00000120  
00000000 000000c2
        00000000 00000001 ebf01e40 ebf01e40 ebf01e48 ebf01e48  
df0bd858 ebe84540
Call Trace:
[<c0103e5f>] show_stack+0x7f/0xa0
[<c0104012>] show_registers+0x162/0x1d0
[<c0104224>] die+0xf4/0x180
[<c035f697>] do_page_fault+0x2e7/0x6b2
[<c0103b03>] error_code+0x4f/0x54
[<c016b663>] vfs_create+0x83/0xf0
[<c01b81ce>] nfsd_create_v3+0x40e/0x550
[<c01bed2d>] nfsd3_proc_create+0x11d/0x180
[<c01b2f87>] nfsd_dispatch+0xd7/0x200
[<c0353a96>] svc_process+0x536/0x670
[<c01b2d1d>] nfsd+0x1bd/0x350
[<c010127d>] kernel_thread_helper+0x5/0x18
Code: 24 08 8d 45 c4 89 54 24 0c 89 74 24 04 89 04 24 e8 1d c3 fe ff  
85 c0 89 c3 0f 84 2e 01 00 00 83 f8 ef 0f 85 13 01 00 00 8b 55 14  
<80> 7a 38 00 0f 88 06 01 00 00 89 7c 24 0c 31 c0 8d 55 c4 89 44

--
Bas van der Vlies
basv@sara.nl





-------------------------------------------------------
This SF.Net email is sponsored by xPML, a groundbreaking scripting language
that extends applications into web and mobile media. Attend the live webcast
and join the prime developer group breaking into this new coding territory!
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=110944&bid=241720&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
