From: Philippe Troin <phil@fifi.org>
Subject: 2.4.20rc2: sunrpc oops in xdr_decode_string_inplace()
Date: 22 Nov 2002 07:16:12 -0800
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <87hee9vdmr.fsf@ceramic.fifi.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from tantale.fifi.org ([216.27.190.146] ident=root)
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 18FFY1-0005cE-00
	for <nfs@lists.sourceforge.net>; Fri, 22 Nov 2002 07:16:49 -0800
Received: from ceramic.fifi.org (mail@ceramic.fifi.org [216.27.190.147])
	by tantale.fifi.org (8.9.3/8.9.3/Debian 8.9.3-21) with ESMTP id HAA05827
	for <nfs@lists.sourceforge.net>; Fri, 22 Nov 2002 07:16:13 -0800
Received: from phil by ceramic.fifi.org with local (Exim 3.35 #1 (Debian))
	id 18FFXQ-0001ej-00
	for <nfs@lists.sourceforge.net>; Fri, 22 Nov 2002 07:16:12 -0800
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

Has anyone seen this oops?
Spotted on sparc32.

Phil.

ksymoops 2.4.5 on sparc 2.4.20-rc2.  Options used
     -V (default)
     -k /proc/ksyms (default)
     -l /proc/modules (default)
     -o /lib/modules/2.4.20-rc2/ (default)
     -m /boot/System.map-2.4.20-rc2 (default)

Warning: You did not tell me where to find symbol information.  I will
assume that the log matches the kernel and modules that are running
right now and I'll use the default options above for symbol resolution.
If the current kernel and/or modules do not match the log, you can get
more accurate output by telling me the kernel version and where to find
map, modules, ksyms etc.  ksymoops -h explains the options.

Nov 22 06:57:07 mica kernel: Unable to handle kernel paging request in mna handler<1> at virtual address 1e4000e1
Nov 22 06:57:07 mica kernel:               \|/ ____ \|/
Nov 22 06:57:07 mica kernel:               "@'/ ,. \`@"
Nov 22 06:57:07 mica kernel:               /_| \__/ |_\
Nov 22 06:57:07 mica kernel:                  \__U_/
Nov 22 06:57:07 mica kernel: diff(2970): Oops
Nov 22 06:57:07 mica kernel: PSR: 1e0000c3 PC: fe327490 NPC: fe327494 Y: 00000000    Not tainted
Using defaults from ksymoops -t elf32-sparc -a sparc
Nov 22 06:57:07 mica kernel: g0: 00000000 g1: fbfae960 g2: 1e4000c9 g3: 1e8000e3 g4: fe32d190 g5: 00000001 g6: fb1d2000 g7: 0000000f
Nov 22 06:57:07 mica kernel: o0: 00000100 o1: fb1d3b10 o2: fb46bb10 o3: 00000001 o4: f0136fdc o5: 00000000 sp: fb1d3ab0 o7: fe34e130
Nov 22 06:57:07 mica kernel: l0: fb1d3b10 l1: fb46ba60 l2: fbfae960 l3: fe355c00 l4: fba5eb84 l5: 00000000 l6: f019e000 l7: 00000004
Nov 22 06:57:07 mica kernel: i0: fb1d3b98 i1: fba5e9e0 i2: fab4a910 i3: 00000001 i4: ffffffff i5: 00000000 fp: fb1d3b30 i7: fe34e1c8
Nov 22 06:57:08 mica kernel: Caller[fe34e1c8]
Nov 22 06:57:08 mica kernel: Caller[fe34e314]
Nov 22 06:57:08 mica kernel: Caller[fe34ddf0]
Nov 22 06:57:08 mica kernel: Caller[fe34e6bc]
Nov 22 06:57:08 mica kernel: Caller[f0039a94]
Nov 22 06:57:08 mica kernel: Caller[f003a378]
Nov 22 06:57:08 mica kernel: Caller[f003a610]
Nov 22 06:57:08 mica kernel: Caller[f003aca0]
Nov 22 06:57:08 mica kernel: Caller[fe348bcc]
Nov 22 06:57:08 mica kernel: Caller[f004a5a0]
Nov 22 06:57:08 mica kernel: Caller[f0011184]
Nov 22 06:57:08 mica kernel: Caller[000148a4]
Nov 22 06:57:08 mica kernel: Instruction DUMP: 90102100  c401a600  8400a004 <c600a018> 80a0e000  22800002  90102102  c400a030  80a0a000 


>>PC;  fe327490 <[sunrpc]__kstrtab_xdr_decode_string_inplace+10/20>   <=====

>>g1; fbfae960 <end+bdedd80/e141420>
>>g2; 1e4000c9 Before first symbol
>>g3; 1e8000e3 Before first symbol
>>g4; fe32d190 <[sunrpc]rpc_init_task+8/1e0>
>>g6; fb1d2000 <end+b011420/e141420>
>>o1; fb1d3b10 <end+b012f30/e141420>
>>o2; fb46bb10 <end+b2aaf30/e141420>
>>o4; f0136fdc <__bzero+b8/144>
>>sp; fb1d3ab0 <end+b012ed0/e141420>
>>o7; fe34e130 <[nfs]nfs_pagein_one+d8/120>
>>l0; fb1d3b10 <end+b012f30/e141420>
>>l1; fb46ba60 <end+b2aae80/e141420>
>>l2; fbfae960 <end+bdedd80/e141420>
>>l3; fe355c00 <[nfs].rodata.start+1228/2be7>
>>l4; fba5eb84 <end+b89dfa4/e141420>
>>l6; f019e000 <bh_task_vec+e0/280>
>>i0; fb1d3b98 <end+b012fb8/e141420>
>>i1; fba5e9e0 <end+b89de00/e141420>
>>i2; fab4a910 <end+a989d30/e141420>
>>i4; ffffffff <END_OF_CODE+1c7ab68/????>
>>fp; fb1d3b30 <end+b012f50/e141420>
>>i7; fe34e1c8 <[nfs]nfs_pagein_list+50/80>

Trace; fe34e1c8 <[nfs]nfs_pagein_list+50/80>
Trace; fe34e314 <[nfs]nfs_pagein_inode+40/64>
Trace; fe34ddf0 <[nfs]nfs_readpage_async+108/11c>
Trace; fe34e6bc <[nfs]nfs_readpage+90/c4>
Trace; f0039a94 <page_cache_read+e0/100>
Trace; f003a378 <generic_file_readahead+15c/1bc>
Trace; f003a610 <do_generic_file_read+1d8/4b0>
Trace; f003aca0 <generic_file_read+78/11c>
Trace; fe348bcc <[nfs]nfs_file_read+9c/ac>
Trace; f004a5a0 <sys_read+c4/14c>
Trace; f0011184 <syscall_is_too_hard+34/40>
Trace; 000148a4 Before first symbol

Code;  fe327484 <[sunrpc]__kstrtab_xdr_decode_string_inplace+4/20>
00000000 <_PC>:
Code;  fe327484 <[sunrpc]__kstrtab_xdr_decode_string_inplace+4/20>
   0:   90 10 21 00       mov  0x100, %o0
Code;  fe327488 <[sunrpc]__kstrtab_xdr_decode_string_inplace+8/20>
   4:   c4 01 a6 00       ld  [ %g6 + 0x600 ], %g2
Code;  fe32748c <[sunrpc]__kstrtab_xdr_decode_string_inplace+c/20>
   8:   84 00 a0 04       add  %g2, 4, %g2
Code;  fe327490 <[sunrpc]__kstrtab_xdr_decode_string_inplace+10/20>   <=====
   c:   c6 00 a0 18       ld  [ %g2 + 0x18 ], %g3   <=====
Code;  fe327494 <[sunrpc]__kstrtab_xdr_decode_string_inplace+14/20>
  10:   80 a0 e0 00       cmp  %g3, 0
Code;  fe327498 <[sunrpc]__kstrtab_xdr_decode_string_inplace+18/20>
  14:   22 80 00 02       be,a   1c <_PC+0x1c> fe3274a0 <[sunrpc]__kstrtab_xdr_decode_netobj+0/18>
Code;  fe32749c <[sunrpc]__kstrtab_xdr_decode_string_inplace+1c/20>
  18:   90 10 21 02       mov  0x102, %o0
Code;  fe3274a0 <[sunrpc]__kstrtab_xdr_decode_netobj+0/18>
  1c:   c4 00 a0 30       ld  [ %g2 + 0x30 ], %g2
Code;  fe3274a4 <[sunrpc]__kstrtab_xdr_decode_netobj+4/18>
  20:   80 a0 a0 00       cmp  %g2, 0

Nov 22 06:57:08 mica kernel: Unable to handle kernel paging request in mna handler<1> at virtual address 1e4000e6
Nov 22 06:57:08 mica kernel:               \|/ ____ \|/
Nov 22 06:57:08 mica kernel:               "@'/ ,. \`@"
Nov 22 06:57:08 mica kernel:               /_| \__/ |_\
Nov 22 06:57:08 mica kernel:                  \__U_/
Nov 22 06:57:08 mica kernel: diff(2970): Oops
Nov 22 06:57:08 mica kernel: PSR: 1e0000c7 PC: f00812d4 NPC: f00812d8 Y: 00000000    Not tainted
Nov 22 06:57:08 mica kernel: g0: fb1d2000 g1: fbb6710c g2: 00000000 g3: 1e1000e3 g4: f0026734 g5: 53545556 g6: fb1d2000 g7: 00000001
Nov 22 06:57:08 mica kernel: o0: 00000001 o1: 1e4000e7 o2: f0165c00 o3: f0165c5c o4: 00004000 o5: f019dc00 sp: fb1d3550 o7: f001239c
Nov 22 06:57:08 mica kernel: l0: 1e4000c0 l1: 1e4000e6 l2: f00812b0 l3: 00000001 l4: 00000000 l5: 53545556 l6: fb1d2000 l7: 0000001d
Nov 22 06:57:08 mica kernel: i0: fbe41e00 i1: 00000001 i2: f0143400 i3: fbec1000 i4: fbf81800 i5: 05ea4029 fp: fb1d35b8 i7: f007ab40
Nov 22 06:57:08 mica kernel: Caller[f007ab40]
Nov 22 06:57:08 mica kernel: Caller[f0060e4c]
Nov 22 06:57:08 mica kernel: Caller[f003cb44]
Nov 22 06:57:08 mica kernel: Caller[f0074e7c]
Nov 22 06:57:08 mica kernel: Caller[f002e2e0]
Nov 22 06:57:08 mica kernel: Caller[f002e324]
Nov 22 06:57:08 mica kernel: Caller[f0029ac8]
Nov 22 06:57:08 mica kernel: Caller[f001239c]
Nov 22 06:57:08 mica kernel: Caller[f001ab48]
Nov 22 06:57:08 mica kernel: Caller[f001ac20]
Nov 22 06:57:08 mica kernel: Caller[f001079c]
Nov 22 06:57:08 mica kernel: Caller[fe34e130]
Nov 22 06:57:08 mica kernel: Caller[fe34e1c8]
Nov 22 06:57:08 mica kernel: Caller[fe34e314]
Nov 22 06:57:08 mica kernel: Caller[fe34ddf0]
Nov 22 06:57:08 mica kernel: Caller[fe34e6bc]
Nov 22 06:57:08 mica kernel: Caller[f0039a94]
Nov 22 06:57:08 mica kernel: Caller[f003a378]
Nov 22 06:57:08 mica kernel: Caller[f003a610]
Nov 22 06:57:08 mica kernel: Caller[f003aca0]
Nov 22 06:57:08 mica kernel: Caller[fe348bcc]
Nov 22 06:57:08 mica kernel: Caller[f004a5a0]
Nov 22 06:57:08 mica kernel: Caller[f0011184]
Nov 22 06:57:08 mica kernel: Caller[000148a4]
Nov 22 06:57:08 mica kernel: Instruction DUMP: 80a46000  0280001c  01000000 <d0044000> d2020000  80a24018  02800012  213c0515  a0142240 


>>PC;  f00812d4 <journal_start+28/e0>   <=====

>>g0; fb1d2000 <end+b011420/e141420>
>>g1; fbb6710c <end+b9a652c/e141420>
>>g3; 1e1000e3 Before first symbol
>>g4; f0026734 <call_console_drivers+148/158>
>>g5; 53545556 Before first symbol
>>g6; fb1d2000 <end+b011420/e141420>
>>o1; 1e4000e7 Before first symbol
>>o2; f0165c00 <abi_root_table+c/58>
>>o3; f0165c5c <console_printk+0/10>
>>o4; 00004000 Before first symbol
>>o5; f019dc00 <log_buf+3dc8/4000>
>>sp; fb1d3550 <end+b012970/e141420>
>>o7; f001239c <die_if_kernel+104/114>
>>l0; 1e4000c0 Before first symbol
>>l1; 1e4000e6 Before first symbol
>>l2; f00812b0 <journal_start+4/e0>
>>l5; 53545556 Before first symbol
>>l6; fb1d2000 <end+b011420/e141420>
>>i0; fbe41e00 <end+bc81220/e141420>
>>i2; f0143400 <Unused_offset+4110/935c>
>>i3; fbec1000 <end+bd00420/e141420>
>>i4; fbf81800 <end+bdc0c20/e141420>
>>i5; 05ea4029 Before first symbol
>>fp; fb1d35b8 <end+b0129d8/e141420>
>>i7; f007ab40 <ext3_dirty_inode+54/108>

Trace; f007ab40 <ext3_dirty_inode+54/108>
Trace; f0060e4c <__mark_inode_dirty+3c/ac>
Trace; f003cb44 <generic_file_write+3b8/8c4>
Trace; f0074e7c <ext3_file_write+18/d4>
Trace; f002e2e0 <do_acct_process+1f8/210>
Trace; f002e324 <acct_process+2c/44>
Trace; f0029ac8 <do_exit+78/320>
Trace; f001239c <die_if_kernel+104/114>
Trace; f001ab48 <kernel_mna_trap_fault+240/260>
Trace; f001ac20 <kernel_unaligned_trap_fault+4/388>
Trace; f001079c <mna_handler+2c/3c>
Trace; fe34e130 <[nfs]nfs_pagein_one+d8/120>
Trace; fe34e1c8 <[nfs]nfs_pagein_list+50/80>
Trace; fe34e314 <[nfs]nfs_pagein_inode+40/64>
Trace; fe34ddf0 <[nfs]nfs_readpage_async+108/11c>
Trace; fe34e6bc <[nfs]nfs_readpage+90/c4>
Trace; f0039a94 <page_cache_read+e0/100>
Trace; f003a378 <generic_file_readahead+15c/1bc>
Trace; f003a610 <do_generic_file_read+1d8/4b0>
Trace; f003aca0 <generic_file_read+78/11c>
Trace; fe348bcc <[nfs]nfs_file_read+9c/ac>
Trace; f004a5a0 <sys_read+c4/14c>
Trace; f0011184 <syscall_is_too_hard+34/40>
Trace; 000148a4 Before first symbol

Code;  f00812c8 <journal_start+1c/e0>
00000000 <_PC>:
Code;  f00812c8 <journal_start+1c/e0>
   0:   80 a4 60 00       cmp  %l1, 0
Code;  f00812cc <journal_start+20/e0>
   4:   02 80 00 1c       be  74 <_PC+0x74> f008133c <journal_start+90/e0>
Code;  f00812d0 <journal_start+24/e0>
   8:   01 00 00 00       nop 
Code;  f00812d4 <journal_start+28/e0>   <=====
   c:   d0 04 40 00       ld  [ %l1 ], %o0   <=====
Code;  f00812d8 <journal_start+2c/e0>
  10:   d2 02 00 00       ld  [ %o0 ], %o1
Code;  f00812dc <journal_start+30/e0>
  14:   80 a2 40 18       cmp  %o1, %i0
Code;  f00812e0 <journal_start+34/e0>
  18:   02 80 00 12       be  60 <_PC+0x60> f0081328 <journal_start+7c/e0>
Code;  f00812e4 <journal_start+38/e0>
  1c:   21 3c 05 15       sethi  %hi(0xf0145400), %l0
Code;  f00812e8 <journal_start+3c/e0>
  20:   a0 14 22 40       or  %l0, 0x240, %l0  ! f0145640 <_PC+0xf0145640> e01c6908 Before first symbol

Nov 22 07:09:47 mica kernel: 16257MB HIGHMEM available.

1 warning issued.  Results may not be reliable.


-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
