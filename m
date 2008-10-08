From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: connectathon test failures
Date: Wed, 8 Oct 2008 18:55:43 -0400
Message-ID: <20081008225543.GG14527@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org
To: Trond Myklebust <trond@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:37017 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756091AbYJHWzo (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 8 Oct 2008 18:55:44 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

I'm getting connectathon test failures with the latest merge of code
from both our trees, linux-to-linux over v3 and v4.

I just got this a moment ago, so haven't tried to track it down at all
yet--but I seem to recall in the past this sort of failure has been an
attribute revalidation problem (usually with the ext3 ctime resolution
at least partly to blame).

--b.

----- Forwarded message from git-KezNCC8cqm5ZN1qrTdtDg5Vzexx5G7lz@public.gmane.org -----

Linux ying3 2.6.27-rc9-00096-gb6ae157 #77 PREEMPT Wed Oct 8 18:24:11 EDT 2008 i686 GNU/Linux
cthon: local filesystem
cthon: nfsv4

Starting BASIC tests: test directory /mnt/TMP (arg: -f)

./test1: File and directory creation test
	created 6 files 6 directories 2 levels deep
	./test1 ok.

./test2: File and directory removal test
	removed 6 files 6 directories 2 levels deep
	./test2 ok.

./test3: lookups across mount point
	2 getcwd and stat calls
	./test3 ok.

./test4: setattr, getattr, and lookup
	20 chmods and stats on 10 files
	./test4 ok.

./test5: read and write
	wrote 1048576 byte file 1 times
	read 1048576 byte file 1 times
	./test5 ok.

./test6: readdir
	202 entries read, 200 files
	./test6 ok.

./test7: link and rename
	./test7: (/mnt/TMP) newfile.1 has 1 links after link (expect 2) : No such file or directory
basic tests failed
cthon: nfsv3

Starting BASIC tests: test directory /mnt/TMP (arg: -f)

./test1: File and directory creation test
	created 6 files 6 directories 2 levels deep
	./test1 ok.

./test2: File and directory removal test
	removed 6 files 6 directories 2 levels deep
	./test2 ok.

./test3: lookups across mount point
	2 getcwd and stat calls
	./test3 ok.

./test4: setattr, getattr, and lookup
	20 chmods and stats on 10 files
	./test4 ok.

./test5: read and write
	wrote 1048576 byte file 1 times
	read 1048576 byte file 1 times
	./test5 ok.

./test6: readdir
	202 entries read, 200 files
	./test6 ok.

./test7: link and rename
	./test7: (/mnt/TMP) newfile.0 has 1 links after link (expect 2) : No such file or directory
basic tests failed
cthon: nfsv4/krb5

Starting BASIC tests: test directory /mnt/TMP (arg: -f)

./test1: File and directory creation test
	created 6 files 6 directories 2 levels deep
	./test1 ok.

./test2: File and directory removal test
	removed 6 files 6 directories 2 levels deep
	./test2 ok.

./test3: lookups across mount point
	2 getcwd and stat calls
	./test3 ok.

./test4: setattr, getattr, and lookup
	20 chmods and stats on 10 files
	./test4 ok.

./test5: read and write
	wrote 1048576 byte file 1 times
	read 1048576 byte file 1 times
	./test5 ok.

./test6: readdir
	202 entries read, 200 files
	./test6 ok.

./test7: link and rename
	./test7: (/mnt/TMP) newfile.1 has 1 links after link (expect 2) : No such file or directory
basic tests failed
cthon: nfsv3/krb5

Starting BASIC tests: test directory /mnt/TMP (arg: -f)

./test1: File and directory creation test
	created 6 files 6 directories 2 levels deep
	./test1 ok.

./test2: File and directory removal test
	removed 6 files 6 directories 2 levels deep
	./test2 ok.

./test3: lookups across mount point
	2 getcwd and stat calls
	./test3 ok.

./test4: setattr, getattr, and lookup
	20 chmods and stats on 10 files
	./test4 ok.

./test5: read and write
	wrote 1048576 byte file 1 times
	read 1048576 byte file 1 times
	./test5 ok.

./test6: readdir
	202 entries read, 200 files
	./test6 ok.

./test7: link and rename
	./test7: (/mnt/TMP) newfile.0 has 1 links after link (expect 2) : No such file or directory
basic tests failed
cthon: nfsv4/krb5i

Starting BASIC tests: test directory /mnt/TMP (arg: -f)

./test1: File and directory creation test
	created 6 files 6 directories 2 levels deep
	./test1 ok.

./test2: File and directory removal test
	removed 6 files 6 directories 2 levels deep
	./test2 ok.

./test3: lookups across mount point
	2 getcwd and stat calls
	./test3 ok.

./test4: setattr, getattr, and lookup
	20 chmods and stats on 10 files
	./test4 ok.

./test5: read and write
	wrote 1048576 byte file 1 times
	read 1048576 byte file 1 times
	./test5 ok.

./test6: readdir
	202 entries read, 200 files
	./test6 ok.

./test7: link and rename
	./test7: (/mnt/TMP) newfile.1 has 1 links after link (expect 2) : No such file or directory
basic tests failed
cthon: nfsv4/krb5p

Starting BASIC tests: test directory /mnt/TMP (arg: -f)

./test1: File and directory creation test
	created 6 files 6 directories 2 levels deep
	./test1 ok.

./test2: File and directory removal test
	removed 6 files 6 directories 2 levels deep
	./test2 ok.

./test3: lookups across mount point
	2 getcwd and stat calls
	./test3 ok.

./test4: setattr, getattr, and lookup
	20 chmods and stats on 10 files
	./test4 ok.

./test5: read and write
	wrote 1048576 byte file 1 times
	read 1048576 byte file 1 times
	./test5 ok.

./test6: readdir
	202 entries read, 200 files
	./test6 ok.

./test7: link and rename
	./test7: (/mnt/TMP) newfile.1 has 1 links after link (expect 2) : No such file or directory
basic tests failed
