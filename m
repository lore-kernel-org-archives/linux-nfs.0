Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx142.netapp.com ([216.240.21.19]:27109 "EHLO mx142.netapp.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1756470AbcIGT40 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 7 Sep 2016 15:56:26 -0400
From: Anna Schumaker <Anna.Schumaker@netapp.com>
To: <fstests@vger.kernel.org>
CC: <Anna.Schumaker@netapp.com>, <linux-nfs@vger.kernel.org>,
        <hch@infradead.org>
Subject: [PATCH v2 4/4] generic/380: Add a copy test for overwriting small amounts of data
Date: Wed, 7 Sep 2016 15:56:19 -0400
Message-ID: <20160907195619.25914-5-Anna.Schumaker@Netapp.com>
In-Reply-To: <20160907195619.25914-1-Anna.Schumaker@Netapp.com>
References: <20160907195619.25914-1-Anna.Schumaker@Netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This test is similar to 345, except that it copies one byte at a time to
make sure that this case works as expected.

Signed-off-by: Anna Schumaker <Anna.Schumaker@Netapp.com>
---
 tests/generic/380     | 94 +++++++++++++++++++++++++++++++++++++++++++++++++++
 tests/generic/380.out | 17 ++++++++++
 tests/generic/group   |  1 +
 3 files changed, 112 insertions(+)
 create mode 100644 tests/generic/380
 create mode 100644 tests/generic/380.out

diff --git a/tests/generic/380 b/tests/generic/380
new file mode 100644
index 0000000..8ca51e4
--- /dev/null
+++ b/tests/generic/380
@@ -0,0 +1,94 @@
+#!/bin/bash
+# FS QA Test No. 380
+#
+# Tests vfs_copy_file_range():
+#   - Copy a small file
+#   - Use copy to swap data at beginning and end
+#   - Use copy to swap data in the middle
+#   - Use copy to swap data in a small file
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
+	for f in file copy; do
+		md5sum $testdir/$f | _filter_test_dir
+	done
+}
+
+rm -f $seqres.full
+
+echo "Create the original file and then copy"
+echo -n "abcde" > $testdir/file
+$XFS_IO_PROG -f -c "copy_range $testdir/file" "$testdir/copy"
+cmp $testdir/file $testdir/copy
+echo "Original md5sums:"
+_checksum_files
+
+echo "Swap beginning and end of original file"
+$XFS_IO_PROG -f -c "copy_range -s 0 -d 4 -l 1 $testdir/file" "$testdir/copy"
+$XFS_IO_PROG -f -c "copy_range -s 4 -d 0 -l 1 $testdir/file" "$testdir/copy"
+echo -n "ebcda" | cmp $testdir/copy
+echo "md5sums after swapping beginning and end:"
+_checksum_files
+
+echo "Swap middle parts of original file"
+$XFS_IO_PROG -f -c "copy_range -s 1 -d 3 -l 1 $testdir/file" "$testdir/copy"
+$XFS_IO_PROG -f -c "copy_range -s 3 -d 1 -l 1 $testdir/file" "$testdir/copy"
+echo -n "edcba" | cmp $testdir/copy
+echo "md5sums after swapping middle:"
+_checksum_files
+
+echo "Copy tail of original file onto copy"
+$XFS_IO_PROG -f -c "copy_range -s 1 -d 3 -l 4 $testdir/file" "$testdir/copy"
+echo -n "edcbcde" | cmp $testdir/copy
+echo "md5sums after copying tail:"
+_checksum_files
+
+#success, all done
+status=0
+exit
diff --git a/tests/generic/380.out b/tests/generic/380.out
new file mode 100644
index 0000000..4159613
--- /dev/null
+++ b/tests/generic/380.out
@@ -0,0 +1,17 @@
+QA output created by 380
+Create the original file and then copy
+Original md5sums:
+ab56b4d92b40713acc5af89985d4b786  TEST_DIR/test-380/file
+ab56b4d92b40713acc5af89985d4b786  TEST_DIR/test-380/copy
+Swap beginning and end of original file
+md5sums after swapping beginning and end:
+ab56b4d92b40713acc5af89985d4b786  TEST_DIR/test-380/file
+32db1f6d06d15f7e38e1ab1c69da498a  TEST_DIR/test-380/copy
+Swap middle parts of original file
+md5sums after swapping middle:
+ab56b4d92b40713acc5af89985d4b786  TEST_DIR/test-380/file
+295228f3d82d344bbcf2f0030519c2ea  TEST_DIR/test-380/copy
+Copy tail of original file onto copy
+md5sums after copying tail:
+ab56b4d92b40713acc5af89985d4b786  TEST_DIR/test-380/file
+0c4aac952f72fa078e2f8419aca70b28  TEST_DIR/test-380/copy
diff --git a/tests/generic/group b/tests/generic/group
index 8accae0..2b3e4e0 100644
--- a/tests/generic/group
+++ b/tests/generic/group
@@ -382,3 +382,4 @@
 377 auto quick copy
 378 auto quick copy
 379 auto quick copy
+380 auto quick copy
-- 
2.9.3

