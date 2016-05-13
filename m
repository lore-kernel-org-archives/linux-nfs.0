Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx143.netapp.com ([216.240.21.24]:1096 "EHLO mx143.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753545AbcEMUu6 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 13 May 2016 16:50:58 -0400
From: Anna Schumaker <Anna.Schumaker@netapp.com>
To: <fstests@vger.kernel.org>
CC: <Anna.Schumaker@netapp.com>, <linux-nfs@vger.kernel.org>,
        <hch@infradead.org>
Subject: [PATCH 2/5] generic/343: Add copy to new file test
Date: Fri, 13 May 2016 16:50:49 -0400
Message-ID: <1463172652-22361-3-git-send-email-Anna.Schumaker@Netapp.com>
In-Reply-To: <1463172652-22361-1-git-send-email-Anna.Schumaker@Netapp.com>
References: <1463172652-22361-1-git-send-email-Anna.Schumaker@Netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This test copies data from various points in a source file to a new
file.  This is useful for testing the basics of copy_file_range().

Signed-off-by: Anna Schumaker <Anna.Schumaker@Netapp.com>
---
 tests/generic/343     | 96 +++++++++++++++++++++++++++++++++++++++++++++++++++
 tests/generic/343.out | 17 +++++++++
 tests/generic/group   |  1 +
 3 files changed, 114 insertions(+)
 create mode 100644 tests/generic/343
 create mode 100644 tests/generic/343.out

diff --git a/tests/generic/343 b/tests/generic/343
new file mode 100644
index 0000000..948b758
--- /dev/null
+++ b/tests/generic/343
@@ -0,0 +1,96 @@
+#!/bin/bash
+# FS QA Test No. 343
+#
+# Tests vfs_copy_file_range():
+#   - Copy a file
+#   - Copy beginning of original to new file
+#   - Copy middle of original to a new file
+#   - Copy end of original to new file
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
+$XFS_IO_PROG -f -c 'pwrite -S 0x61 0    1000' $testdir/file >> $seqres.full 2>&1
+$XFS_IO_PROG -f -c 'pwrite -S 0x62 1000 1000' $testdir/file >> $seqres.full 2>&1
+$XFS_IO_PROG -f -c 'pwrite -S 0x63 2000 1000' $testdir/file >> $seqres.full 2>&1
+$XFS_IO_PROG -f -c 'pwrite -S 0x64 3000 1000' $testdir/file >> $seqres.full 2>&1
+$XFS_IO_PROG -f -c 'pwrite -S 0x65 4000 1000' $testdir/file >> $seqres.full 2>&1
+$COPY_FILE_RANGE_PROG $testdir/file $testdir/copy
+cmp $testdir/file $testdir/copy
+echo "Original md5sums:"
+_checksum_files file copy
+
+echo "Copy beginning of original file"
+$COPY_FILE_RANGE_PROG -l 1000 $testdir/file $testdir/beginning
+cmp -n 1000 $testdir/file $testdir/beginning
+echo "md5sums after copying beginning:"
+_checksum_files file beginning
+
+echo "Copy middle of original file"
+$COPY_FILE_RANGE_PROG -s 1000 -l 3000 $testdir/file $testdir/middle
+cmp -n 3000 $testdir/file $testdir/middle 1000
+echo "md5sums after copying middle:"
+_checksum_files file middle
+
+echo "Copy end of original file"
+$COPY_FILE_RANGE_PROG -s 4000 -l 1000 $testdir/file $testdir/end
+cmp -n 1000 $testdir/file $testdir/end 4000
+echo "md5sums after copying end:"
+_checksum_files file end
+
+#success, all done
+status=0
+exit
diff --git a/tests/generic/343.out b/tests/generic/343.out
new file mode 100644
index 0000000..f9b54aa
--- /dev/null
+++ b/tests/generic/343.out
@@ -0,0 +1,17 @@
+QA output created by 343
+Create the original file and then copy
+Original md5sums:
+e11fbace556cba26bf0076e74cab90a3  TEST_DIR/test-343/file
+e11fbace556cba26bf0076e74cab90a3  TEST_DIR/test-343/copy
+Copy beginning of original file
+md5sums after copying beginning:
+e11fbace556cba26bf0076e74cab90a3  TEST_DIR/test-343/file
+cabe45dcc9ae5b66ba86600cca6b8ba8  TEST_DIR/test-343/beginning
+Copy middle of original file
+md5sums after copying middle:
+e11fbace556cba26bf0076e74cab90a3  TEST_DIR/test-343/file
+4197de9da5badfc302715486b82bcdf1  TEST_DIR/test-343/middle
+Copy end of original file
+md5sums after copying end:
+e11fbace556cba26bf0076e74cab90a3  TEST_DIR/test-343/file
+e68d4a150c4e42f4f9ea3ffe4c9cf4ed  TEST_DIR/test-343/end
diff --git a/tests/generic/group b/tests/generic/group
index ef1a423..d5e5242 100644
--- a/tests/generic/group
+++ b/tests/generic/group
@@ -345,3 +345,4 @@
 340 auto
 341 auto quick metadata
 342 auto quick metadata
+343 auto quick copy
-- 
2.8.2

