From: Stephen Hemminger <shemminger@osdl.org>
Subject: Crash in NFS on 2.5.41
Date: 10 Oct 2002 13:01:24 -0700
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <1034280084.8583.53.camel@dell_ss3.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from air-2.osdl.org ([65.172.181.6] helo=mail.osdl.org)
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17zjUU-0002t6-00
	for <nfs@lists.sourceforge.net>; Thu, 10 Oct 2002 13:01:02 -0700
Received: from dell_ss3.pdx.osdl.net (dell_ss3.pdx.osdl.net [172.20.1.60])
	by mail.osdl.org (8.11.6/8.11.6) with ESMTP id g9AK12B15159
	for <nfs@lists.sourceforge.net>; Thu, 10 Oct 2002 13:01:02 -0700
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
List-Archive: <http://sourceforge.net/mailarchives/forum.php?forum=nfs>

This happened when doing a bash completion on an NFS mounted directory.
The server was (at least every other machine still thinks so).


nfs: server osdlab not responding, timed out
-----------[ cut here ]------------
kernel BUG at mm/highmem.c:177!
invalid operand: 0000
ide-cd cdrom soundcore mga agpgart autofs nfs lockd sunrpc eepro100 mii
mousede
CPU:    1
EIP:    0060:[<c014df77>]    Not tainted
EFLAGS: 00013246
EIP is at kunmap_high+0x47/0xe0
eax: 00000000   ebx: c19bc7b0   ecx: 00000000   edx: c040fa00
esi: f7c05dd0   edi: f5635f18   ebp: c19bc7b0   esp: f5635d48
ds: 0068   es: 0068   ss: 0068
Process bash (pid: 10674, threadinfo=f5634000 task=f6816000)
Stack: c19bc7b0 c19bc7b0 f7c05dd0 f5635f18 fffffffb f8ace19e f7c05dd0
f672bd20
       00000000 00000000 c19bc7b0 00001000 00000002 f672bd20 c19bc7b0
00000000
       00000000 f7c05e58 c013eb84 f5635f18 c19bc7b0 00000000 f7c05dd0
00000000
Call Trace:
 [<f8ace19e>] nfs_readdir_filler+0x13e/0x1a0 [nfs]
 [<c013eb84>] __read_cache_page+0x64/0x140
 [<c013dd38>] read_cache_page+0x38/0x110
 [<f8ace060>] nfs_readdir_filler+0x0/0x1a0 [nfs]
 [<f8ad0d40>] find_dirent_page+0x40/0x190 [nfs]
 [<f8ace060>] nfs_readdir_filler+0x0/0x1a0 [nfs]
 [<f8ad0a58>] readdir_search_pagecache+0x28/0x90 [nfs]
 [<f8ace4f8>] nfs_readdir+0x148/0x2b0 [nfs]
 [<c0145fad>] __alloc_pages+0x7d/0x280
 [<c01399b7>] do_anonymous_page+0x2b7/0x310
 [<c0139a5d>] do_no_page+0x4d/0x410
 [<c0139ed4>] handle_mm_fault+0xb4/0x1b0
 [<f8aded70>] nfs3_decode_dirent+0x0/0x1f0 [nfs]
 [<c0169c52>] vfs_readdir+0xb2/0xc0
 [<c0169f60>] filldir64+0x0/0x110
 [<c016a0cb>] sys_getdents64+0x5b/0x1d9
 [<c0169f60>] filldir64+0x0/0x110
 [<c012f1ed>] sys_rt_sigprocmask+0x10d/0x270
 [<c01099df>] syscall_call+0x7/0xb

Code: 0f 0b b1 00 2f 12 2a c0 05 00 00 00 02 ba 40 e6 40 c0 c1 e8





-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
