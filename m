From: <Nikolaos.Michalakis@nokia.com>
Subject: Unable to handle kernel NULL pointer dereference at virtual address 00000000
Date: Wed, 2 Jul 2003 12:40:20 -0400
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <A6D9D7495456414BA08DB655C2AC6712013667D4@bsebe001.americas.nokia.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from mgw-x4.nokia.com ([131.228.20.27])
	by sc8-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 19Xkf0-0002lC-00
	for <nfs@lists.sourceforge.net>; Wed, 02 Jul 2003 09:40:46 -0700
Received: from esvir04nok.ntc.nokia.com (esvir04nokt.ntc.nokia.com [172.21.143.36])
	by mgw-x4.nokia.com (Switch-2.2.6/Switch-2.2.6) with ESMTP id h62Geg918052
	for <nfs@lists.sourceforge.net>; Wed, 2 Jul 2003 19:40:42 +0300 (EET DST)
Received: from esebh001.NOE.Nokia.com (unverified) by esvir04nok.ntc.nokia.com
 (Content Technologies SMTPRS 4.2.5) with ESMTP id <T6330f09b7fac158f24078@esvir04nok.ntc.nokia.com> for <nfs@lists.sourceforge.net>;
 Wed, 2 Jul 2003 19:40:37 +0300
To: <nfs@lists.sourceforge.net>
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

I got the latest nfs-utils from the sourceforge website and I am trying =
to get a working nfs-kernel-server on an ARM processor running intimate =
linux (Debian clone). I compiled the source code, installed the =
binaries, setup=20
/etc/exports but when I try to access the server the kernel oops.

Here is the scenario:
1. I can mount the exported directory successfully.
2. When I try to 'ls' the contents of the directory I get on the client:
	ls: <filename1>: Input/Output error
	ls: <filename2>: Input/Output error
	...
	ls: <filenameN>: Input/Output error
	(the filenames are the exact ones on the server)
3. When I try to stop the nfs server from the script, it get's stuck =
trying to unexport the exported
filesystems even if the client has successfully unmounted.
Exportfs -auv shows:
unexporting <fs> from kernel=20
(and waits there forever)
I have to reboot the machine to clean up nfs.

My kernel version is:
Linux version 2.4.18-rmk3 (andyc@rockhopper.crl.dec.com) (gcc version
2.95.2 19991024 (release)) #13 Wed May 1 19:38:27 EDT 2002


This is what the server prints when I try 'ls' after successfully =
mounting:
Unable to handle kernel NULL pointer dereference at virtual address
00000000
pgd =3D c0004000
*pgd =3D 00000000, *pmd =3D 00000000
Internal error: Oops: ffffffff
CPU: 0
pc : [<c0024468>]    lr : [<c001ba48>]    Not tainted
sp : c25e7e38  ip : 40000013  fp : c25e7e44
r10: c4a9f7a0  r9 : c24cc214  r8 : c037ca00
r7 : c25e6000  r6 : c1a81000  r5 : c037ccb4  r4 : c25e7e48
r3 : 00000000  r2 : c25e7e50  r1 : c25e7e48  r0 : c037ccc0
Flags: nZcv  IRQs off  FIQs on  Mode SVC_32  Segment user
Control: C000F17F  Table: C000F17F  DAC: 00000015
Process nfsd (pid: 280, stackpage=3Dc25e7000)
Stack: (0xc25e7e28 to 0xc25e8000)
7e20:                   c001ba48 c0024468 40000093 ffffffff c25e7e78 =
c25e7e48
7e40: c001ba48 c0024438 00000001 c25e6000 c037ccc0 00000000 c037ccb4 =
c24cc214
7e60: c1a81000 c24cc204 c037ca00 c25e7ec8 c25e7e7c c001bccc c001ba0c =
c037ca00
7e80: c24cc214 c4a9f7a0 00000001 c4a8e800 c25e7e9c c00f9a64 00000006 =
00000006
7ea0: 00000006 c24cc214 c1a81000 c24cc204 c24f0e00 00000000 11270000 =
c25e7f18
7ec0: c25e7ecc c4a8ee04 c4a8e7b0 00000001 c25e6000 c24f0f4c c25e7f14 =
c25e7ee8
7ee0: 00000000 c0022d1c 00000003 c26180c0 c24cc204 c24cc204 c4a7b790 =
c24cc000
7f00: c24cc200 c3fa56e0 c24f0e00 c25e7f54 c25e7f1c c4a96bb8 c4a8eb88 =
c24f0e00
7f20: c25fc014 c3fa56e0 c25e7f54 c25e7f38 c24f0e00 c4a9eb94 c4a7b790 =
00000001
7f40: c25fc014 c4a9e618 c25e7f78 c25e7f58 c4a8c6ac c4a96b00 c24f0f38 =
c24f0e00
7f60: c25fc014 00000001 c4a9eb94 c25e7fb4 c25e7f7c c4a72ed8 c4a8c5dc =
c4a9eb74
7f80: 00000020 00000000 00000000 c4a9f334 c015c284 0003d570 c4a9f338 =
c25e6000
7fa0: c25e6000 c4a9f7a0 c25e7ffc c25e7fb8 c4a8c408 c4a72bcc c25e6344 =
c25e6334
7fc0: c3fa56e0 c24f0e00 c2509fc8 c256bfc8 c25e6000 c24f0e00 c3fa56e0 =
00000000
7fe0: fffffff4 c4a8c1c4 00000000 00000000 00000000 c25e8000 c001ac5c =
c4a8c1d0
Backtrace:
Function entered at [<c002442c>] from [<c001ba48>]
Function entered at [<c001ba00>] from [<c001bccc>]
 r8 =3D C037CA00  r7 =3D C24CC204  r6 =3D C1A81000  r5 =3D C24CC214
 r4 =3D C037CCB4
Function entered at [<c4a8e7a4>] from [<c4a8ee04>]
Function entered at [<c4a8eb7c>] from [<c4a96bb8>]
Function entered at [<c4a96af4>] from [<c4a8c6ac>]
Function entered at [<c4a8c5d0>] from [<c4a72ed8>]
 r8 =3D C4A9EB94  r7 =3D 00000001  r6 =3D C25FC014  r5 =3D C24F0E00
 r4 =3D C24F0F38
Function entered at [<c4a72bc0>] from [<c4a8c408>]
Function entered at [<c4a8c1c4>] from [<c001ac5c>]
Code: e5903004 e5802004 e5810008 e5823004 (e5832000)


Is there a patch for this problem?
I am kind of new to kernel programming, so does anyone know=20
how to use this debug information to figure out where in the source code =
the problem appears?
Also, should I look into updating the kernel or this is not necessary?

Please, I couldn't find anything useful from the mail archive so any =
help or suggestion even to get me started on something would be =
immensely appreciated.

Thank you,
Nikos


-------------------------------------------------------
This SF.Net email sponsored by: Free pre-built ASP.NET sites including
Data Reports, E-commerce, Portals, and Forums are available now.
Download today and enter to win an XBOX or Visual Studio .NET.
http://aspnet.click-url.com/go/psa00100006ave/direct;at.asp_061203_01/01
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
