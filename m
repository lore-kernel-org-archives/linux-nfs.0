From: Richard Ems <r.ems@gmx.net>
Subject: cat /proc/fs/nfs/exports hangs
Date: Tue, 02 Sep 2003 20:32:40 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <3F54E248.30102@gmx.net>
Reply-To: r.ems@gmx.net
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 19uFxP-0000eC-00
	for <nfs@lists.sourceforge.net>; Tue, 02 Sep 2003 11:32:47 -0700
Received: from boa.mtg-marinetechnik.de ([62.153.155.10] helo=anaconda.mtg-marinetechnik.de)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.22)
	id 19uFxO-0002um-14
	for nfs@lists.sourceforge.net; Tue, 02 Sep 2003 11:32:46 -0700
Received: from localhost (localhost [127.0.0.1])
	by anaconda.mtg-marinetechnik.de (Postfix) with ESMTP id 3F9A7100D1
	for <nfs@lists.sourceforge.net>; Tue,  2 Sep 2003 20:32:42 +0200 (CEST)
Received: from gmx.net (bingo.mtg-marinetechnik.de [128.1.3.96])
	by anaconda.mtg-marinetechnik.de (Postfix) with ESMTP id 03E68100C8
	for <nfs@lists.sourceforge.net>; Tue,  2 Sep 2003 20:32:40 +0200 (CEST)
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

Hi all!

This is a dual Athlon system with SuSE 8.2.
Kernel is SuSE's k_smp-2.4.21-4.

After 32 days of uptime nfs exports stopped working.
While trying to restart the nfs server them I found that running 
"rcnfsserver restart" hangs on exportfs (process ind D state)

Also a simple "cat /proc/fs/nfs/exports" hangs (process in D state).

The last lines from "strace cat /proc/fs/nfs/exports" show:

munmap(0x40016000, 59621)               = 0
open("/usr/lib/locale/locale-archive", O_RDONLY|O_LARGEFILE) = 3
fstat64(3, {st_mode=S_IFREG|0644, st_size=32058672, ...}) = 0
mmap2(NULL, 2097152, PROT_READ, MAP_PRIVATE, 3, 0) = 0x40158000
close(3)                                = 0
brk(0)                                  = 0x804c68c
brk(0x804d68c)                          = 0x804d68c
brk(0)                                  = 0x804d68c
brk(0x804e000)                          = 0x804e000
fstat64(1, {st_mode=S_IFCHR|0620, st_rdev=makedev(136, 2), ...}) = 0
open("/proc/fs/nfs/exports", O_RDONLY|O_LARGEFILE) = 3
fstat64(3, {st_mode=S_IFREG|0444, st_size=0, ...}) = 0
read(3,  <unfinished ...>

Here the process hangs.

What's happening? The nfs server was running for 32 days and suddenly this!

Thanks, Richard


-- 
    Richard Ems
    ... e-mail: r.ems@gmx.net
    ... Computer Science, University of Hamburg

    "Do or do not. There is no try" - Yoda
    Yoda never programmed in Java.



-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
