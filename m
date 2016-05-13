Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx144.netapp.com ([216.240.21.25]:20975 "EHLO mx144.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753557AbcEMUu7 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 13 May 2016 16:50:59 -0400
From: Anna Schumaker <Anna.Schumaker@netapp.com>
To: <fstests@vger.kernel.org>
CC: <Anna.Schumaker@netapp.com>, <linux-nfs@vger.kernel.org>,
        <hch@infradead.org>
Subject: [PATCH 3/5] generic/344: Add small copies to new file test
Date: Fri, 13 May 2016 16:50:50 -0400
Message-ID: <1463172652-22361-4-git-send-email-Anna.Schumaker@Netapp.com>
In-Reply-To: <1463172652-22361-1-git-send-email-Anna.Schumaker@Netapp.com>
References: <1463172652-22361-1-git-send-email-Anna.Schumaker@Netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This test copies single bytes from a source file into various new files
just to make sure that we can handle very small copies.

Signed-off-by: Anna Schumaker <Anna.Schumaker@Netapp.com>
---
 tests/generic/344     | 86 +++++++++++++++++++++++++++++++++++++++++++++++++++
 tests/generic/344.out | 13 ++++++++
 tests/generic/group   |  1 +
 3 files changed, 100 insertions(+)
 create mode 100644 tests/generic/344
 create mode 100644 tests/generic/344.out

diff --git a/tests/generic/344 b/tests/generic/344
new file mode 100644
index 0000000..4220293
--- /dev/null
+++ b/tests/generic/344
@@ -0,0 +1,86 @@
+#!/bin/bash
+# FS QA Test No. 344
+#
+# Tests vfs_copy_file_range():
+#   - Copy a small file
+#   - Small copies from various points in the original file
+#-----------------------------------------------------------------------
+# Copyright (c) 2016 Netapp, Inc. All rights reserved.
+#
+# This program is free software; you can redistribute it and/or
+# modify it under the terms of the GNU General Public License as
+# published by the Free Software Foundation.
+#
+# This program is distributed in the hope that it would be useful,
+# but WITHOUT ANY WARRANTY; without even the implied warranty of
+# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+# GNU General Public License for more details.
+#
+# You should have received a copy of the GNU General Public License
+# along with this program; if not, write the Free Software Foundation,
+# Inc.,  51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA
+#-----------------------------------------------------------------------
+#
+
+seq=`basename $0`
+seqres=$RESULT_DIR/$seq
+echo "QA output created by $seq"
+
+here=`pwd`
+tmp=/tmp/$$
+status=1    # failure is the default!
+trap "_cleanup; exit \$status" 0 1 2 3 15
+
+_cleanup()
+{
+	cd /
+	rm -rf $tmp.*
+}
+
+# get standard environment
+. common/rc
+. common/filter
+
+# real QA test starts here
+_supported_os Linux
+
+_require_copy_file_range
+_require_test
+
+testdir=$TEST_DIR/test-$seq
+rm -rf $testdir
+mkdir $testdir
+
+_checksum_files()
+{
+	for f in $*; do
+		md5sum $testdir/$f | _filter_test_dir
+	done
+}
+
+rm -f $seqres.full
+
+echo "Create the original file and then copy"
+echo -n "abcde" > $testdir/file
+$COPY_FILE_RANGE_PROG $testdir/file $testdir/copy
+echo -n "abcde" | cmp $testdir/copy
+echo "Original md5sums:"
+_checksum_files file copy
+
+echo "Small copies from various points in the original file"
+$COPY_FILE_RANGE_PROG -s 0 -l 1 $testdir/file $testdir/a
+$COPY_FILE_RANGE_PROG -s 1 -l 1 $testdir/file $testdir/b
+$COPY_FILE_RANGE_PROG -s 2 -l 1 $testdir/file $testdir/c
+$COPY_FILE_RANGE_PROG -s 3 -l 1 $testdir/file $testdir/d
+$COPY_FILE_RANGE_PROG -s 4 -l 1 $testdir/file $testdir/e
+echo -n "a" | cmp $testdir/a
+echo -n "b" | cmp $testdir/b
+echo -n "c" | cmp $testdir/c
+echo -n "d" | cmp $testdir/d
+echo -n "e" | cmp $testdir/e
+echo "md5sums after small copies"
+_checksum_files file a b c d e
+
+#success, all done
+status=0
+exit
diff --git a/tests/generic/344.out b/tests/generic/344.out
new file mode 100644
index 0000000..152fb2c
--- /dev/null
+++ b/tests/generic/344.out
@@ -0,0 +1,13 @@
+QA output created by 344
+Create the original file and then copy
+Original md5sums:
+ab56b4d92b40713acc5af89985d4b786  TEST_DIR/test-344/file
+ab56b4d92b40713acc5af89985d4b786  TEST_DIR/test-344/copy
+Small copies from various points in the original file
+md5sums after small copies
+ab56b4d92b40713acc5af89985d4b786  TEST_DIR/test-344/file
+0cc175b9c0f1b6a831c399e269772661  TEST_DIR/test-344/a
+92eb5ffee6ae2fec3ad71c777531578f  TEST_DIR/test-344/b
+4a8a08f09d37b73795649038408b5f33  TEST_DIR/test-344/c
+8277e0910d750195b448797616e091ad  TEST_DIR/test-344/d
+e1671797c52e15f763380b45e841ec32  TEST_DIR/test-344/e
diff --git a/tests/generic/group b/tests/generic/group
index d5e5242..323e42b 100644
--- a/tests/generic/group
+++ b/tests/generic/group
@@ -346,3 +346,4 @@
 341 auto quick metadata
 342 auto quick metadata
 343 auto quick copy
+344 auto quick copy
-- 
2.8.2

