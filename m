From: miyoshi@hpc.bs1.fc.nec.co.jp
Subject: NFS client stall within __lock_page()
Date: Fri, 10 Jan 2003 15:19:29 +0900
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20030110151929Z.miyoshi@hpc.bs1.fc.nec.co.jp>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Cc: tanaka-h@mxm.nes.nec.co.jp
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from tyo201.gate.nec.co.jp ([210.143.35.51])
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 18WsUU-0003mf-00
	for <nfs@lists.sourceforge.net>; Thu, 09 Jan 2003 22:18:02 -0800
Received: from mailgate3.nec.co.jp ([10.7.69.194])
	by TYO201.gate.nec.co.jp (8.11.6/3.7W01080315) with ESMTP id h0A6Hvw10556
	for <nfs@lists.sourceforge.net>; Fri, 10 Jan 2003 15:17:57 +0900 (JST)
Received: from mailsv.nec.co.jp (mailgate52.nec.co.jp [10.7.69.198]) by mailgate3.nec.co.jp (8.11.6/3.7W-MAILGATE-NEC) with ESMTP
	id h0A6Hui02717 for <nfs@lists.sourceforge.net>; Fri, 10 Jan 2003 15:17:56 +0900 (JST)
Received: from mailsv.bs1.fc.nec.co.jp (venus.d2.bs1.fc.nec.co.jp [10.34.77.164]) by mailsv.nec.co.jp (8.11.6/3.7W-MAILSV-NEC) with ESMTP
	id h0A6Htq19382 for <nfs@lists.sourceforge.net>; Fri, 10 Jan 2003 15:17:56 +0900 (JST)
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


Hi, all.

I am using kernel 2.4.17 as an NFS client (server is HP-UX)
and one of client processes hangs and never wakes up.

>From kdb backtrace (attached), I found that the client process
stalls within nfs write and never returns (kill -9 is not accepted.)
It sleeps on __lock_page.

sys_write
  ->nfs_file_write
    ->generic_file_write
      ->__find_lock_page
        ->lock_page
          -> __lock_page

I am not so sure that this is actually the nfs problem (because the
process stalls on upper layer than nfs) but other processes or kernel
daemons seem to sleep normally, compared with live-and-well system.
So, I think the acitivity of the NFS client just before the stall
may be suspicious (?)

The machine itself is alive and I can log into it and get information
via lcrash. I appreciate if you provide me where to investigate.

BTW, Filesystem in question is mounted as:

     file:/xxxx/yyyy on /xxxx/yyyy type nfs
       (rw,rsize=16384,wsize=16384,timeo=14,nfsvers=3,intr,
       bg,addr=zzz.zzz.zzz.zzz)

Do you have any idea??


- whole backtrace of the client in question

Stack traceback for pid 5172
0xe0000000044ee740 schedule+0xbe0
        args (0xe000000102faf618, 0xe00000000452b140, 0x50c, 0xe0000004a5e94ec0, 0x0)
        kernel .text 0xe000000004400000 0xe0000000044edb60 0xe0000000044ee920
0xe00000000452b160 __lock_page+0x160
        args (0xe000000102faf600, 0xe000000004c4f340, 0xe0000001176b0000, 0xe000000102faf630, 0xe000000102faf610)
        kernel .text 0xe000000004400000 0xe00000000452b000 0xe00000000452b220
0xe00000000452b2a0 lock_page+0x80
        args (0xe000000102faf600, 0xe00000000452b6e0, 0x307)
        kernel .text 0xe000000004400000 0xe00000000452b220 0xe00000000452b2c0
0xe00000000452b6e0 __find_lock_page_helper+0x140
        args (0xe0000004a5e95000, 0x5c78, 0xe000000102faf600, 0xe000000102faf600, 0xe00000000452b860)
        kernel .text 0xe000000004400000 0xe00000000452b5a0 0xe00000000452b7e0
0xe00000000452b860 __find_lock_page+0x80
        args (0xe0000004a5e95000, 0x5c78, 0xe0000002fd6c7e18, 0xe000000004cb4d80, 0xe000000004531ad0)
        kernel .text 0xe000000004400000 0xe00000000452b7e0 0xe00000000452b880
0xe000000004531ad0 generic_file_write+0x750
        args (0xe0000006fd760900, 0x6000000000718cb0, 0x4000, 0xe0000006fd760938, 0x0)
        kernel .text 0xe000000004400000 0xe000000004531380 0xe000000004532080
0xe0000000045f2130 nfs_file_write+0x230
        args (0xe0000006fd760900, 0x6000000000718cb0, 0x4000, 0xe0000006fd760938, 0xe0000004a5e94ec0)
        kernel .text 0xe000000004400000 0xe0000000045f1f00 0xe0000000045f2160
0xe000000004551bf0 sys_write+0x210
        args (0x8, 0x6000000000718cb0, 0x4000, 0x60000000005d7afc, 0x2fa11)
        kernel .text 0xe000000004400000 0xe0000000045519e0 0xe000000004551ca0
0xe0000000044922e0 ia64_ret_from_syscall
        args (0x8, 0x6000000000718cb0, 0x4000)
        kernel .text 0xe000000004400000 0xe0000000044922e0 0xe000000004492300


Regards,
--
MIYOSHI Kazuto <miyoshi@hpc.bs1.fc.nec.co.jp>
 HPC Operating System Group, 1st Computers Software Division,
 Computers Software Operations Unit, NEC Solutions.


-------------------------------------------------------
This SF.NET email is sponsored by:
SourceForge Enterprise Edition + IBM + LinuxWorld = Something 2 See!
http://www.vasoftware.com
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
