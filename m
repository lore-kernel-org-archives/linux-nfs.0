Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx142.netapp.com ([216.240.21.19]:7427 "EHLO mx142.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932224AbcEMUu7 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 13 May 2016 16:50:59 -0400
From: Anna Schumaker <Anna.Schumaker@netapp.com>
To: <fstests@vger.kernel.org>
CC: <Anna.Schumaker@netapp.com>, <linux-nfs@vger.kernel.org>,
        <hch@infradead.org>
Subject: [PATCH 4/5] generic/345: Add copy test that overwrites data
Date: Fri, 13 May 2016 16:50:51 -0400
Message-ID: <1463172652-22361-5-git-send-email-Anna.Schumaker@Netapp.com>
In-Reply-To: <1463172652-22361-1-git-send-email-Anna.Schumaker@Netapp.com>
References: <1463172652-22361-1-git-send-email-Anna.Schumaker@Netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Using copy to overwrite data in the destination file is perfectly valid,
so let's make sure this case works as expected.

Signed-off-by: Anna Schumaker <Anna.Schumaker@Netapp.com>
---
 tests/generic/345     | 107 ++++++++++++++++++++++++++++++++++++++++++++++++++
 tests/generic/345.out |  17 ++++++++
 tests/generic/group   |   1 +
 3 files changed, 125 insertions(+)
 create mode 100644 tests/generic/345
 create mode 100644 tests/generic/345.out

diff --git a/tests/generic/345 b/tests/generic/345
new file mode 100644
index 0000000..ba96e4a
--- /dev/null
+++ b/tests/generic/345
@@ -0,0 +1,107 @@
+#!/bin/bash
+# FS QA Test No. 345
+#
+# Tests vfs_copy_file_range():
+#   - Copy a file
+#   - Use copy to swap data at beginning and end
+#   - Use copy to swap data in the middle
+#   - Use copy to simultaneously overwrite and append to destination file
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
+	for f in file copy; do
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
+$COPY_FILE_RANGE_PROG $testdir/file  $testdir/copy
+cmp $testdir/file  $testdir/copy
+echo "Original md5sums:"
+_checksum_files
+
+echo "Swap beginning and end of original file"
+$COPY_FILE_RANGE_PROG -s 4000 -l 1000 $testdir/file $testdir/copy
+$COPY_FILE_RANGE_PROG -d 4000 -l 1000 $testdir/file $testdir/copy
+cmp -n 1000 $testdir/file $testdir/copy 4000
+cmp -n 3000 $testdir/file $testdir/copy 1000 1000
+cmp -n 1000 $testdir/file $testdir/copy 0 4000
+echo "md5sums after swapping beginning and end:"
+_checksum_files
+
+echo "Swap middle parts of original file"
+$COPY_FILE_RANGE_PROG -s 1000 -d 3000 -l 1000 $testdir/file $testdir/copy
+$COPY_FILE_RANGE_PROG -s 3000 -d 1000 -l 1000 $testdir/file $testdir/copy
+cmp -n 1000 $testdir/file $testdir/copy 4000
+cmp -n 1000 $testdir/file $testdir/copy 3000 1000
+cmp -n 1000 $testdir/file $testdir/copy 2000 2000
+cmp -n 1000 $testdir/file $testdir/copy 1000 3000
+cmp -n 1000 $testdir/file $testdir/copy 0 4000
+echo "md5sums after swapping middle:"
+_checksum_files
+
+echo "Copy tail of original file onto copy"
+$COPY_FILE_RANGE_PROG -s 1000 -d 3000 -l 4000 $testdir/file $testdir/copy
+cmp -n 1000 $testdir/file $testdir/copy 4000
+cmp -n 1000 $testdir/file $testdir/copy 3000 1000
+cmp -n 1000 $testdir/file $testdir/copy 2000 2000
+cmp -n 4000 $testdir/file $testdir/copy 1000 3000
+echo "md5sums after copying tail:"
+_checksum_files
+
+#success, all done
+status=0
+exit
diff --git a/tests/generic/345.out b/tests/generic/345.out
new file mode 100644
index 0000000..0c0a505
--- /dev/null
+++ b/tests/generic/345.out
@@ -0,0 +1,17 @@
+QA output created by 345
+Create the original file and then copy
+Original md5sums:
+e11fbace556cba26bf0076e74cab90a3  TEST_DIR/test-345/file
+e11fbace556cba26bf0076e74cab90a3  TEST_DIR/test-345/copy
+Swap beginning and end of original file
+md5sums after swapping beginning and end:
+e11fbace556cba26bf0076e74cab90a3  TEST_DIR/test-345/file
+5f4e111811dd9a810143c9db9bec6d80  TEST_DIR/test-345/copy
+Swap middle parts of original file
+md5sums after swapping middle:
+e11fbace556cba26bf0076e74cab90a3  TEST_DIR/test-345/file
+8c81889a5a50b311197110bcf769a695  TEST_DIR/test-345/copy
+Copy tail of original file onto copy
+md5sums after copying tail:
+e11fbace556cba26bf0076e74cab90a3  TEST_DIR/test-345/file
+e5fbacd993eaa5e80ebc2b14b969887d  TEST_DIR/test-345/copy
diff --git a/tests/generic/group b/tests/generic/group
index 323e42b..69696c7 100644
--- a/tests/generic/group
+++ b/tests/generic/group
@@ -347,3 +347,4 @@
 342 auto quick metadata
 343 auto quick copy
 344 auto quick copy
+345 auto quick copy
-- 
2.8.2

