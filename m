Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx142.netapp.com ([216.240.21.19]:11514 "EHLO mx142.netapp.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752285AbdEJRqp (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 10 May 2017 13:46:45 -0400
From: Anna Schumaker <Anna.Schumaker@Netapp.com>
To: <fstests@vger.kernel.org>
CC: <Anna.Schumaker@Netapp.com>, <linux-nfs@vger.kernel.org>,
        <hch@infradead.org>
Subject: [PATCH v6 2/5] generic/430: Add small copies to new file test
Date: Wed, 10 May 2017 13:46:25 -0400
Message-ID: <20170510174628.22895-3-Anna.Schumaker@Netapp.com>
In-Reply-To: <20170510174628.22895-1-Anna.Schumaker@Netapp.com>
References: <20170510174628.22895-1-Anna.Schumaker@Netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This test copies single bytes from a source file into various new files
just to make sure that we can handle very small copies.

Signed-off-by: Anna Schumaker <Anna.Schumaker@Netapp.com>
---
 tests/generic/430     | 83 +++++++++++++++++++++++++++++++++++++++++++++++++++
 tests/generic/430.out | 15 ++++++++++
 tests/generic/group   |  1 +
 3 files changed, 99 insertions(+)
 create mode 100755 tests/generic/430
 create mode 100644 tests/generic/430.out

diff --git a/tests/generic/430 b/tests/generic/430
new file mode 100755
index 00000000..750f8522
--- /dev/null
+++ b/tests/generic/430
@@ -0,0 +1,83 @@
+#!/bin/bash
+# FS QA Test No. 430
+#
+# Tests vfs_copy_file_range():
+#   - Copy a small file
+#   - Small copies from various points in the original file
+#-----------------------------------------------------------------------
+# Copyright (c) 2017 Netapp, Inc. All rights reserved.
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
+_supported_fs generic
+_supported_os Linux
+
+_require_xfs_io_command "copy_range"
+_require_test
+
+testdir=$TEST_DIR/test-$seq
+rm -rf $testdir
+mkdir $testdir
+rm -f $seqres.full
+
+echo "Create the original file and then copy"
+echo -n "abcde" > $testdir/file
+$XFS_IO_PROG -f -c "copy_range $testdir/file" "$testdir/copy"
+echo -n "abcde" | cmp $testdir/copy
+echo "Original md5sums:"
+md5sum $testdir/{file,copy} | _filter_test_dir
+
+echo "Small copies from various points in the original file"
+$XFS_IO_PROG -f -c "copy_range -s 0 -l 1      $testdir/file" "$testdir/a" 2>&1
+$XFS_IO_PROG -f -c "copy_range -s 1 -l 1      $testdir/file" "$testdir/b" 2>&1
+$XFS_IO_PROG -f -c "copy_range -s 2 -l 1      $testdir/file" "$testdir/c" 2>&1
+$XFS_IO_PROG -f -c "copy_range -s 3 -l 1      $testdir/file" "$testdir/d" 2>&1
+$XFS_IO_PROG -f -c "copy_range -s 4 -l 1      $testdir/file" "$testdir/e" 2>&1
+$XFS_IO_PROG -f -c "copy_range -s 4 -l 1 -d 1 $testdir/file" "$testdir/f" 2>&1
+$XFS_IO_PROG -f -c "copy_range -s 5 -l 1      $testdir/file" "$testdir/g" 2>&1
+echo -n "a"    | cmp $testdir/a
+echo -n "b"    | cmp $testdir/b
+echo -n "c"    | cmp $testdir/c
+echo -n "d"    | cmp $testdir/d
+echo -n "e"    | cmp $testdir/e
+echo -en "\0e" | cmp $testdir/f
+echo -n ""     | cmp $testdir/g
+echo "md5sums after small copies"
+md5sum $testdir/{file,a,b,c,d,e,f,g} | _filter_test_dir
+
+#success, all done
+status=0
+exit
diff --git a/tests/generic/430.out b/tests/generic/430.out
new file mode 100644
index 00000000..1bdfbf6f
--- /dev/null
+++ b/tests/generic/430.out
@@ -0,0 +1,15 @@
+QA output created by 430
+Create the original file and then copy
+Original md5sums:
+ab56b4d92b40713acc5af89985d4b786  TEST_DIR/test-430/file
+ab56b4d92b40713acc5af89985d4b786  TEST_DIR/test-430/copy
+Small copies from various points in the original file
+md5sums after small copies
+ab56b4d92b40713acc5af89985d4b786  TEST_DIR/test-430/file
+0cc175b9c0f1b6a831c399e269772661  TEST_DIR/test-430/a
+92eb5ffee6ae2fec3ad71c777531578f  TEST_DIR/test-430/b
+4a8a08f09d37b73795649038408b5f33  TEST_DIR/test-430/c
+8277e0910d750195b448797616e091ad  TEST_DIR/test-430/d
+e1671797c52e15f763380b45e841ec32  TEST_DIR/test-430/e
+2015eb238d706eceefc784742928054f  TEST_DIR/test-430/f
+d41d8cd98f00b204e9800998ecf8427e  TEST_DIR/test-430/g
diff --git a/tests/generic/group b/tests/generic/group
index 1c0fbb73..b5f115af 100644
--- a/tests/generic/group
+++ b/tests/generic/group
@@ -432,3 +432,4 @@
 427 auto quick aio rw
 428 auto quick
 429 auto quick copy
+430 auto quick copy
-- 
2.12.2

