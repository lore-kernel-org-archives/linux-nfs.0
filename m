From: Andrew Zhukov <zhukov@tst.spb.su>
Subject: nfs-utils 1.0.8 build failure
Date: 13 Apr 2006 10:59:06 +0300
Message-ID: <1144915146.32160.26.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1FTvoK-0000cu-LR
	for nfs@lists.sourceforge.net; Thu, 13 Apr 2006 00:00:12 -0700
Received: from techsystems-2.ip.peterstar.net ([82.140.85.18] helo=tst.spb.su)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44)
	id 1FTvoJ-0004JA-9v
	for nfs@lists.sourceforge.net; Thu, 13 Apr 2006 00:00:12 -0700
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

Hello

I tried to build fine "mount" for "mount -t nfs". I mean the one which
wouldn't complain "mount is older/newer than the kernel"...

First I tried to build it on x86 RedHat 9.

1. ./configure without restriction won't work... I have to use: 

./configure --build=arm-linux-uclibc --enable-nfsv4=no --enable-nfsv3=no
--enable-gss=no

2. make fails:

...
Making all in include
make[2]: Entering directory `/tmp/nfs-utils-1.0.8/support/include'
cd ../.. && /bin/sh /tmp/nfs-utils-1.0.8/missing --run autoheader
configure.in:8: error: Autoconf version 2.58 or higher is required
aclocal.m4:6960: AM_INIT_AUTOMAKE is expanded from...
configure.in:8: the top level
autom4te: /usr/bin/m4 failed with exit status: 1
autoheader: /usr/bin/autom4te failed with exit status: 1
make[2]: *** [config.h.in] Error 1
make[2]: Leaving directory `/tmp/nfs-utils-1.0.8/support/include'
make[1]: *** [all-recursive] Error 1
make[1]: Leaving directory `/tmp/nfs-utils-1.0.8/support'
make: *** [all-recursive] Error 1

Second, I tried to build for my target board - ARM (at91rm9200dk), with
kernel 2.6.10. There's uClibc on the target instead of libc, so I had to
use arm native compiler via NFS.

./configure fails... I used this version:

./configure --build=arm-linux-uclibc --enable-nfsv4=no --enable-nfsv3=no
--enable-gss=no

--------------------output:--------------------------

checking build system type... arm-unknown-linux-uclibc
checking host system type... arm-unknown-linux-uclibc
checking for a BSD-compatible install... /usr/bin/install -c
checking whether build environment is sane... yes
checking for gawk... gawk
checking whether make sets $(MAKE)... yes
checking for style of inc)lude used by maGNU
checking for gcc... gcc
checking for C compiler default output file name... a.out
checking whether the C compiler works... yes
checking whether we are cross compiling... no
checking for suffix of executables...
checking for suffix of object files... o
checking whether we are using the GNU C compiler... yes
checking whether gcc accepts -g... yes
checking for gcc option to accept ANSI C... none needed
checking dependency style of gcc... none
checking for g++... g++
checking whether we are using the GNU C++ compiler... yes
checking whether g++ accepts -g... Unable to handle kernel NULL pointer
dereference at virtual address 00000000
pgd = c15f0000
[00000000] *pgd=218ca011, *pte=00000000, *ppte=00000000
Internal error: Oops: 807 [#1]
CPU: 0
PC is at nfs_lookup+0x160/0x178
LR is at 0xc1d7bca0
pc : [<c009b5cc>]    lr : [<c1d7bca0>]    Not tainted
sp : c1d53d30  ip : 0000001c  fp : c1d53e64
r10: c1d53ea4  r9 : c1d53e9c  r8 : 00000000
r7 : c1d53d30  r6 : c1d53dc0  r5 : c1e531d0  r4 : c1bbe5dc
r3 : 00000000  r2 : c1d52000  r1 : 0000001c  r0 : 0000001c
Flags: nzCv  IRQs on  FIQs on  Mode SVC_32  Segment user
Control: C000317F  Table: 215F0000  DAC: 00000015
Process g++ (pid: 741, stack limit = 0xc1d52190)
Stack: (0xc1d53d30 to 0xc1d54000)
3d20:                                     c1d50000 c02908e0 c01afc38
c0291eb8
3d40: c1d52000 00000002 000041ed 00000003 00000000 00000000 00001000
00000000
3d60: 00001000 00000008 ffffffff 00000307 00000000 c1d53dd4 c1d53d84
00324436
3d80: 00000000 443dfe05 00000000 443dfe05 00000000 443dfe05 00000000
c1c9c040
3da0: c0042248 c1d53da4 c1d53da4 c1d53dd4 c1d53dbc ffffd176 00010020
03000100
3dc0: c3c30700 44360007 ea510032 00006540 00000000 00000000 00000000
00000000
3de0: c1d53e40 c1bbe288 c1d53e18 c1d53e30 c1e29858 c01afc3c c1d53e6c
c1d53e08
3e00: c00a2264 c0148838 c017bc4c c1d53e30 00000000 c1bbe640 c1bbe5dc
c1d53ea4
3e20: c1bbe640 c1bbe19c c01a692c c1d53e9c c1d53e64 c1d53e40 c0079104
c00bef50
3e40: c00794e4 fffffff4 c1bbe5dc c1e53238 c1e531d0 c1d53f34 c1d53e94
c1d53e68
3e60: c006e9e4 c009b47c c02152a0 c1d53f34 c1e531d0 00000000 c1cc6000
00000003
3e80: c1d53e9c c1cc6011 c1d53ed8 c1d53e98 c006f598 c006e920 00000101
c02152a0
3ea0: c1bbe19c 137e7db2 00000005 c1cc600c c1d52000 c1d53f34 c1cc6000
c1cc6000
3ec0: 00000003 00000043 00000004 c1d53ef4 c1d53edc c006fbe0 c006ec7c
c1d53f34
3ee0: 00000004 00000002 c1d53f30 c1d53ef8 c0070420 c006fa3c c1bb5000
00000000
3f00: 00000006 067faf51 00000002 00000004 00000002 c1cc6000 c001c864
c1d52000
3f20: 00000004 c1d53f84 c1d53f34 c00614c4 c00703b0 c1bbe19c c02152a0
c1e27b2c
3f40: c02152a0 63774016 00000101 00000001 00000000 00022328 c1d53f84
c1d53f68
3f60: c006e304 c004c74c 00000043 00000003 00000043 00000043 c1d53fa4
c1d53f88
3f80: c00616a8 c00614a4 00000000 befffb34 000176b0 00000005 00000000
c1d53fa8
3fa0: c001c6e0 c0061674 00000000 c0022ad4 00022328 00000002 00000043
00000002
3fc0: 00000000 befffb34 000176b0 00022328 00000000 000176cc 00000004
000176e4
3fe0: 000173b8 befffa14 0000bde0 4005eac4 60000010 00022328 20002011
20002411
Backtrace:
[<c009b46c>] (nfs_lookup+0x0/0x178) from [<c006e9e4>]
(do_lookup+0xd4/0x1c0)
 r8 = C1D53F34  r7 = C1E531D0  r6 = C1E53238  r5 = C1BBE5DC
 r4 = FFFFFFF4
[<c006e910>] (do_lookup+0x0/0x1c0) from [<c006f598>]
(link_path_walk+0x92c/0xdc0)
[<c006ec6c>] (link_path_walk+0x0/0xdc0) from [<c006fbe0>]
(path_lookup+0x1b4/0x1b8)
[<c006fa2c>] (path_lookup+0x0/0x1b8) from [<c0070420>]
(open_namei+0x80/0x6a0)
 r6 = 00000002  r5 = 00000004  r4 = C1D53F34
[<c00703a0>] (open_namei+0x0/0x6a0) from [<c00614c4>]
(filp_open+0x30/0x4c)
[<c0061494>] (filp_open+0x0/0x4c) from [<c00616a8>] (sys_open+0x44/0x88)
 r4 = 00000043
[<c0061664>] (sys_open+0x0/0x88) from [<c001c6e0>]
(ret_fast_syscall+0x0/0x2c)
 r7 = 00000005  r6 = 000176B0  r5 = BEFFFB34  r4 = 00000000
Code: e5153054 e5843048 ea000001 c3a03000 (c5833000)
 no
<1>Unable to handle kernel NULL pointer dereference at virtual address
00000000
pgd = c177c000
[00000000] *pgd=214fd011, *pte=00000000, *ppte=00000000
Internal error: Oops: 807 [#2]
CPU: 0
PC is at nfs_lookup+0x160/0x178
LR is at 0xc1d7bca0
pc : [<c009b5cc>]    lr : [<c1d7bca0>]    Not tainted
sp : c1d53d10  ip : 0000001c  fp : c1d53e44
r10: c1d53e84  r9 : c1d53e7c  r8 : 00000000
r7 : c1d53d10  r6 : c1d53da0  r5 : c1446878  r4 : c1b37d4c
r3 : 00000000  r2 : c1d52000  r1 : 0000001c  r0 : 0000001c
Flags: nzCv  IRQs on  FIQs on  Mode SVC_32  Segment user
Control: C000317F  Table: 2177C000  DAC: 00000015
Process g++ (pid: 799, stack limit = 0xc1d52190)
Stack: (0xc1d53d10 to 0xc1d54000)
3d00:                                     c1d50000 c1d53d38 c1d53d24
c009d5a8
3d20: c00bef50 00000002 000041ed 00000002 00000000 00000000 00001000
00000000
3d40: 00001000 00000008 ffffffff 00000307 00000000 c1d53d90 c1d53d64
00324439
3d60: 00000000 443dfe0c 00000000 443dfe0c 00000000 443dfe0c 00000000
00000000
3d80: c1d53e3c c1d53db0 c1d53d94 c009ba40 c00784ec ffffd406 00010020
03000100
3da0: c3c30700 44390007 ea7a0032 00006540 00000000 00000000 00010000
03000100
3dc0: c3c30700 44390007 ea7a0032 00006540 00000000 00000000 00000000
c1cfe700
3de0: 00000001 c1d53ea4 c1d53e44 c1d53e40 c1d53dfc c1b37db0 c1b37d4c
c1d53e84
3e00: c1b37db0 c1b7208c c01a692c c1d53e7c c1d53e44 c1d53e20 c0079104
c00bef50
3e20: c00794e4 fffffff4 c1b37d4c c14468e0 c1446878 c1d53ef4 c1d53e74
c1d53e48
3e40: c006e9e4 c009b47c c02152a0 c1d53ef4 c1446878 00000000 0000006a
c001c864
3e60: c1d53e7c c1bb500d c1d53eb8 c1d53e78 c006f598 c006e920 00000001
c02152a0
3e80: c1b7208c 00002541 00000001 c1bb500c c1d52000 c1d53ef4 c1bb5000
0000006a
3ea0: c001c864 c1d52000 000176d4 c1d53ed4 c1d53ebc c006fbe0 c006ec7c
c1bb5000
3ec0: c1d53ef4 c1bb5000 c1d53ef0 c1d53ed8 c006fe9c c006fa3c c1d53f4c
c1d53ef4
3ee0: 0001e288 c1d53f48 c1d53ef4 c006b084 c006fe78 c1b7208c c02152a0
c0053b70
3f00: c00535b0 c14fd894 00000001 00000001 00000000 00100077 c177c000
00000000
3f20: 00000800 c1c9c040 ffffffeb 000253a4 c1d19610 befffa08 c1d53f4c
c1d53fa4
3f40: c1d53f4c c006b324 c006b070 c00bcdfc c1d19610 00000800 c0015b0c
c1d53fb0
3f60: 00000807 c1d53fec c01773d0 000253a4 c1d53fb0 ffffffff 4006f440
c1d53fac
3f80: c1d53f8c c0022b00 c00227a8 ffffffff 00023330 00000002 00000000
c1d53fa8
3fa0: c001c6e0 c006b314 00023330 c0022ad4 00023330 befffa08 40074c4c
befffa50
3fc0: 00023330 00000002 0001e288 00000002 000176b8 000176cc 000176d4
000176e4
3fe0: 00017394 befffa08 0000b964 4005fa3c 60000010 00023330 20002011
20002411
Backtrace:
[<c009b46c>] (nfs_lookup+0x0/0x178) from [<c006e9e4>]
(do_lookup+0xd4/0x1c0)
 r8 = C1D53EF4  r7 = C1446878  r6 = C14468E0  r5 = C1B37D4C
 r4 = FFFFFFF4
[<c006e910>] (do_lookup+0x0/0x1c0) from [<c006f598>]
(link_path_walk+0x92c/0xdc0)
[<c006ec6c>] (link_path_walk+0x0/0xdc0) from [<c006fbe0>]
(path_lookup+0x1b4/0x1b8)
[<c006fa2c>] (path_lookup+0x0/0x1b8) from [<c006fe9c>]
(__user_walk+0x34/0x54)
 r6 = C1BB5000  r5 = C1D53EF4  r4 = C1BB5000
[<c006fe68>] (__user_walk+0x0/0x54) from [<c006b084>]
(vfs_stat+0x24/0x54)
 r6 = 0001E288  r5 = C1D53EF4  r4 = C1D53F4C
[<c006b060>] (vfs_stat+0x0/0x54) from [<c006b324>]
(sys_newstat+0x20/0x44)
 r5 = C1D53F4C  r4 = BEFFFA08
[<c006b304>] (sys_newstat+0x0/0x44) from [<c001c6e0>]
(ret_fast_syscall+0x0/0x2c)
 r5 = 00000002  r4 = 00023330
Code: e5153054 e5843048 ea000001 c3a03000 (c5833000)
 checking dependency style of g++...




-----Variant (no restriction)-------------------

# ./configure --build=arm-linux-uclibc

checking build system type... arm-unknown-linux-uclibc
checking host system type... arm-unknown-linux-uclibc
checking for a BSD-compatible install... /usr/bin/install -c
checking whether build environment is sane... yes
checking for gawk... gawk
checking whether make sets $(MAKE)... yes
checking for style of inc.lude used by maGNU
checking for gcc... gcc
checking for C compiler default output file name... a.out
checking whether the C compiler works... yes
checking whether we are cross compiling... no
checking for suffix of executables...
checking for suffix of object files... o
checking whether we are using the GNU C compiler... yes
checking whether gcc accepts -g... yes
checking for gcc option to accept ANSI C... none needed
checking dependency style of gcc... none
checking for g++... g++
checking whether we are using the GNU C++ compiler... yes
checking whether g++ accepts -g... yes
checking dependency style of g++... none
checking for gcc... (cached) gcc
checking whether we are using the GNU C compiler... (cached) yes
checking whether gcc accepts -g... (cached) yes
checking for gcc option to accept ANSI C... (cached) none needed
checking dependency style of gcc... (cached) none
checking how to run the C preprocessor... gcc -E
checking for a BSD-compatible install... /usr/bin/install -c
checking whether ln -s works... yes
checking whether make sets $(MAKE)... (cached) yes
checking for a sed that does not truncate output... /bin/sed
checking for egrep... grep -E
checking for ld used by gcc... /usr/bin/ld
checking if the linker (/usr/bin/ld) is GNU ld... yes
checking for /usr/bin/ld option to reload object files... -r
checking for BSD-compatible nm... /usr/bin/nm -B
checking how to recognise dependent libraries... pass_all
checking for ANSI C header files... yes
checking for sys/types.h... yes
checking for sys/stat.h... yes
checking for stdlib.h... yes
checking for string.h... yes
checking for memory.h... yes
checking for strings.h... yes
checking for inttypes.h... yes
checking for stdint.h... yes
checking for unistd.h... yes
checking dlfcn.h usability... yes
checking dlfcn.h presence... yes
checking for dlfcn.h... yes
checking how to run the C++ preprocessor... g++ -E
checking for g77... no
checking for f77... no
checking for xlf... no
checking for frt... no
checking for pgf77... no
checking for fort77... no
checking for fl32... no
checking for af77... no
checking for f90... no
checking for xlf90... no
checking for pgf90... no
checking for epcf90... no
checking for f95... no
checking for fort... no
checking for xlf95... no
checking for ifc... no
checking for efc... no
checking for pgf95... no
checking for lf95... no
checking for gfortran... no
checking whether we are using the GNU Fortran 77 compiler... no
checking whether  accepts -g... no
checking the maximum length of command line arguments... Unable to
handle kernel NULL pointer dereference at virtual address 00000000
pgd = c16e8000
[00000000] *pgd=21cd0011, *pte=00000000, *ppte=00000000
Internal error: Oops: 807 [#1]
CPU: 0
PC is at nfs_lookup+0x160/0x178
LR is at 0xc0208260
pc : [<c009b5cc>]    lr : [<c0208260>]    Not tainted
sp : c15fbd10  ip : 0000001c  fp : c15fbe44
r10: c15fbe84  r9 : c15fbe7c  r8 : 00000000
r7 : c15fbd10  r6 : c15fbda0  r5 : c1cde448  r4 : c1da8e5c
r3 : 00000000  r2 : c15fa000  r1 : 0000001c  r0 : 0000001c
Flags: nzCv  IRQs on  FIQs on  Mode SVC_32  Segment user
Control: C000317F  Table: 216E8000  DAC: 00000015
Process ln (pid: 1805, stack limit = 0xc15fa190)
Stack: (0xc15fbd10 to 0xc15fc000)
bd00:                                     c15f0000 c001c39c c0022ad4
40007000
bd20: c01b7f20 00000000 00001000 00001000 c15fbe08 c01b7f20 00000000
00001000
bd40: 00000000 00000000 c15fbd84 00001000 00001000 c15fbe08 c01b7f20
00000000
bd60: c004538c c15fbda4 00001000 00000000 00000000 00001000 c15fbdf8
c15fbd88
bd80: c00452f4 c007abac c02d45d4 00000000 0000004c c15fbee0 c1d20aa0
c1d20ae8
bda0: c02d4638 00000000 00000007 00000007 00000000 00000000 00000000
00000001
bdc0: 00000007 0000000f 00000000 c15fbe9c c15fbe9c 00000001 c15fbe0c
c15fbde8
bde0: c002c0ec c0020af8 c01a3090 c15fbe9c 00000000 c1da8ec0 c1da8e5c
c15fbe84
be00: c1da8ec0 c1c973bc c01a692c c15fbe7c c15fbe44 c15fbe20 c0079104
c00bef50
be20: c00794e4 fffffff4 c1da8e5c c1cde4b0 c1cde448 c15fbef4 c15fbe74
c15fbe48
be40: c006e9e4 c009b47c c02152a0 c15fbef4 c1cde448 00000000 000000c3
c001c864
be60: c15fbe7c c1d1f008 c15fbeb8 c15fbe78 c006f598 c006e920 00000001
c15fbe88
be80: c00224d4 3be461c8 00000008 c1d1f000 c15fa000 c15fbef4 c1d1f000
000000c3
bea0: c001c864 c15fa000 00014e28 c15fbed4 c15fbebc c006fbe0 c006ec7c
c1d1f000
bec0: c15fbef4 c1d1f000 c15fbef0 c15fbed8 c006fe9c c006fa3c c15fbf4c
c15fbef4
bee0: befffcb4 c15fbf48 c15fbef4 c006b084 c006fe78 c1c973bc c02152a0
c0053b70
bf00: c00535b0 c148f99c 00000001 00000001 00000000 c0014ae0 c16e8000
00001000
bf20: 00000000 c0016840 ffffffeb 40067014 c1da4274 befffac8 c15fbf4c
c15fbfa4
bf40: c15fbf4c c006b630 c006b070 c00bcdfc 40061888 00000000 c0014b0c
c15fbfb0
bf60: 00000007 c15fbfec c01773d0 40067014 c15fbfb0 00000000 4006f440
c15fbfac
bf80: c15fbf8c c0022b00 c00227a8 ffffffff 00000002 00000000 00000000
c15fbfa8
bfa0: c001c6e0 c006b620 00000002 c0022ad4 befffde5 befffac8 00000002
befffb30
bfc0: 00000002 00000000 befffcb4 befffcbc befffde5 00000000 00014e28
befffc34
bfe0: 4005fa78 befffac8 00009fcc 4005fa8c 20000010 befffde5 20002011
20002411
Backtrace:
[<c009b46c>] (nfs_lookup+0x0/0x178) from [<c006e9e4>]
(do_lookup+0xd4/0x1c0)
 r8 = C15FBEF4  r7 = C1CDE448  r6 = C1CDE4B0  r5 = C1DA8E5C
 r4 = FFFFFFF4
[<c006e910>] (do_lookup+0x0/0x1c0) from [<c006f598>]
(link_path_walk+0x92c/0xdc0)
[<c006ec6c>] (link_path_walk+0x0/0xdc0) from [<c006fbe0>]
(path_lookup+0x1b4/0x1b8)
[<c006fa2c>] (path_lookup+0x0/0x1b8) from [<c006fe9c>]
(__user_walk+0x34/0x54)
 r6 = C1D1F000  r5 = C15FBEF4  r4 = C1D1F000
[<c006fe68>] (__user_walk+0x0/0x54) from [<c006b084>]
(vfs_stat+0x24/0x54)
 r6 = BEFFFCB4  r5 = C15FBEF4  r4 = C15FBF4C
[<c006b060>] (vfs_stat+0x0/0x54) from [<c006b630>]
(sys_stat64+0x20/0x44)
 r5 = C15FBF4C  r4 = BEFFFAC8
[<c006b610>] (sys_stat64+0x0/0x44) from [<c001c6e0>]
(ret_fast_syscall+0x0/0x2c)
 r5 = 00000000  r4 = 00000002
Code: e5153054 e5843048 ea000001 c3a03000 (c5833000)




-------------------------------------------------------
This SF.Net email is sponsored by xPML, a groundbreaking scripting language
that extends applications into web and mobile media. Attend the live webcast
and join the prime developer group breaking into this new coding territory!
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=110944&bid=241720&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
