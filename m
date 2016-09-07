Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx142.netapp.com ([216.240.21.19]:27109 "EHLO mx142.netapp.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1756354AbcIGT4Y (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 7 Sep 2016 15:56:24 -0400
From: Anna Schumaker <Anna.Schumaker@netapp.com>
To: <fstests@vger.kernel.org>
CC: <Anna.Schumaker@netapp.com>, <linux-nfs@vger.kernel.org>,
        <hch@infradead.org>
Subject: [PATCH v2 2/4] generic/378: Add small copies to new file test
Date: Wed, 7 Sep 2016 15:56:17 -0400
Message-ID: <20160907195619.25914-3-Anna.Schumaker@Netapp.com>
In-Reply-To: <20160907195619.25914-1-Anna.Schumaker@Netapp.com>
References: <20160907195619.25914-1-Anna.Schumaker@Netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This test copies single bytes from a source file into various new files
just to make sure that we can handle very small copies.

Signed-off-by: Anna Schumaker <Anna.Schumaker@Netapp.com>
---
 tests/generic/378     | 88 +++++++++++++++++++++++++++++++++++++++++++++++++++
 tests/generic/378.out | 14 ++++++++
 tests/generic/group   |  1 +
 3 files changed, 103 insertions(+)
 create mode 100644 tests/generic/378
 create mode 100644 tests/generic/378.out

diff --git a/tests/generic/378 b/tests/generic/378
new file mode 100644
index 0000000..0b3ad50
--- /dev/null
+++ b/tests/generic/378
@@ -0,0 +1,88 @@
+#!/bin/bash
+# FS QA Test No. 378
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
+_require_xfs_io_command "copy_range"
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
+$XFS_IO_PROG -f -c "copy_range $testdir/file" "$testdir/copy"
+echo -n "abcde" | cmp $testdir/copy
+echo "Original md5sums:"
+_checksum_files file copy
+
+echo "Small copies from various points in the original file"
+$XFS_IO_PROG -f -c "copy_range -s 0 -l 1 $testdir/file" "$testdir/a"
+$XFS_IO_PROG -f -c "copy_range -s 1 -l 1 $testdir/file" "$testdir/b"
+$XFS_IO_PROG -f -c "copy_range -s 2 -l 1 $testdir/file" "$testdir/c"
+$XFS_IO_PROG -f -c "copy_range -s 3 -l 1 $testdir/file" "$testdir/d"
+$XFS_IO_PROG -f -c "copy_range -s 4 -l 1 $testdir/file" "$testdir/e"
+$XFS_IO_PROG -f -c "copy_range -s 5 -l 1 $testdir/file" "$testdir/f"
+echo -n "a" | cmp $testdir/a
+echo -n "b" | cmp $testdir/b
+echo -n "c" | cmp $testdir/c
+echo -n "d" | cmp $testdir/d
+echo -n "e" | cmp $testdir/e
+echo -n ""  | cmp $testdir/f
+echo "md5sums after small copies"
+_checksum_files file a b c d e f
+
+#success, all done
+status=0
+exit
diff --git a/tests/generic/378.out b/tests/generic/378.out
new file mode 100644
index 0000000..5d63a71
--- /dev/null
+++ b/tests/generic/378.out
@@ -0,0 +1,14 @@
+QA output created by 378
+Create the original file and then copy
+Original md5sums:
+ab56b4d92b40713acc5af89985d4b786  TEST_DIR/test-378/file
+ab56b4d92b40713acc5af89985d4b786  TEST_DIR/test-378/copy
+Small copies from various points in the original file
+md5sums after small copies
+ab56b4d92b40713acc5af89985d4b786  TEST_DIR/test-378/file
+0cc175b9c0f1b6a831c399e269772661  TEST_DIR/test-378/a
+92eb5ffee6ae2fec3ad71c777531578f  TEST_DIR/test-378/b
+4a8a08f09d37b73795649038408b5f33  TEST_DIR/test-378/c
+8277e0910d750195b448797616e091ad  TEST_DIR/test-378/d
+e1671797c52e15f763380b45e841ec32  TEST_DIR/test-378/e
+d41d8cd98f00b204e9800998ecf8427e  TEST_DIR/test-378/f
diff --git a/tests/generic/group b/tests/generic/group
index dec0d64..2147238 100644
--- a/tests/generic/group
+++ b/tests/generic/group
@@ -380,3 +380,4 @@
 375 auto quick acl
 376 auto quick metadata
 377 auto quick copy
+378 auto quick copy
-- 
2.9.3

