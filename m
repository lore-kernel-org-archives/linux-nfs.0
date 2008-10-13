From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: [git-KezNCC8cqm5ZN1qrTdtDg5Vzexx5G7lz@public.gmane.org: all 5e2e7721... NFS: fix
	nfs_parse_ip_address() corner case results]
Date: Mon, 13 Oct 2008 15:15:07 -0400
Message-ID: <20081013191507.GA31876@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org
To: Trond Myklebust <trond@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:51043 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752827AbYJMTPJ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 13 Oct 2008 15:15:09 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

I'm seeing cthon failures on your linux-mm branch again, this time
intermittent--and maybe only on v4?  I haven't tried to look any closer
yet.

--b.

Linux ying3 2.6.27-rc9-00034-g5e2e772 #89 PREEMPT Mon Oct 13 15:01:58 EDT 2008 i686 GNU/Linux
cthon: local filesystem
cthon: nfsv4
cthon: nfsv3
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
	./test7: (/mnt/TMP) newfile.9 has 1 links after link (expect 2) : No such file or directory
basic tests failed
cthon: nfsv3/krb5
cthon: nfsv4/krb5i
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
	./test7: (/mnt/TMP) newfile.2 has 1 links after link (expect 2) : No such file or directory
basic tests failed
