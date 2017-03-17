Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx144.netapp.com ([216.240.21.25]:38477 "EHLO mx144.netapp.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751179AbdCQUE0 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 17 Mar 2017 16:04:26 -0400
From: Anna Schumaker <Anna.Schumaker@Netapp.com>
To: <fstests@vger.kernel.org>
CC: <Anna.Schumaker@Netapp.com>, <linux-nfs@vger.kernel.org>,
        <hch@infradead.org>
Subject: [PATCH v5 3/5] generic/418: Add copy test that overwrites data
Date: Fri, 17 Mar 2017 15:52:31 -0400
Message-ID: <20170317195233.4042-4-Anna.Schumaker@Netapp.com>
In-Reply-To: <20170317195233.4042-1-Anna.Schumaker@Netapp.com>
References: <20170317195233.4042-1-Anna.Schumaker@Netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Using copy to overwrite data in the destination file is perfectly valid,
so let's make sure this case works as expected.

Signed-off-by: Anna Schumaker <Anna.Schumaker@Netapp.com>
---
 tests/generic/418     | 100 ++++++++++++++++++++++++++++++++++++++++++++++++++
 tests/generic/418.out |  17 +++++++++
 tests/generic/group   |   1 +
 3 files changed, 118 insertions(+)
 create mode 100755 tests/generic/418
 create mode 100644 tests/generic/418.out

diff --git a/tests/generic/418 b/tests/generic/418
new file mode 100755
index 00000000..b64504e8
--- /dev/null
+++ b/tests/generic/418
@@ -0,0 +1,100 @@
+#!/bin/bash
+# FS QA Test No. 418
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
+$XFS_IO_PROG -f -c 'pwrite -S 0x61 0    1000' $testdir/file >> $seqres.full 2>&1
+$XFS_IO_PROG -f -c 'pwrite -S 0x62 1000 1000' $testdir/file >> $seqres.full 2>&1
+$XFS_IO_PROG -f -c 'pwrite -S 0x63 2000 1000' $testdir/file >> $seqres.full 2>&1
+$XFS_IO_PROG -f -c 'pwrite -S 0x64 3000 1000' $testdir/file >> $seqres.full 2>&1
+$XFS_IO_PROG -f -c 'pwrite -S 0x65 4000 1000' $testdir/file >> $seqres.full 2>&1
+$XFS_IO_PROG -f -c "copy_range $testdir/file" "$testdir/copy"
+cmp $testdir/file  $testdir/copy
+echo "Original md5sums:"
+md5sum $testdir/{file,copy} | _filter_test_dir
+
+echo "Swap beginning and end of original file"
+$XFS_IO_PROG -f -c "copy_range -s 4000 -l 1000 $testdir/file" "$testdir/copy" 2>&1
+$XFS_IO_PROG -f -c "copy_range -d 4000 -l 1000 $testdir/file" "$testdir/copy" 2>&1
+cmp -n 1000 $testdir/file $testdir/copy 4000
+cmp -n 3000 $testdir/file $testdir/copy 1000 1000
+cmp -n 1000 $testdir/file $testdir/copy 0 4000
+echo "md5sums after swapping beginning and end:"
+md5sum $testdir/{file,copy} | _filter_test_dir
+
+echo "Swap middle parts of original file"
+$XFS_IO_PROG -f -c "copy_range -s 1000 -d 3000 -l 1000 $testdir/file" "$testdir/copy" 2>&1
+$XFS_IO_PROG -f -c "copy_range -s 3000 -d 1000 -l 1000 $testdir/file" "$testdir/copy" 2>&1
+cmp -n 1000 $testdir/file $testdir/copy 4000
+cmp -n 1000 $testdir/file $testdir/copy 3000 1000
+cmp -n 1000 $testdir/file $testdir/copy 2000 2000
+cmp -n 1000 $testdir/file $testdir/copy 1000 3000
+cmp -n 1000 $testdir/file $testdir/copy 0 4000
+echo "md5sums after swapping middle:"
+md5sum $testdir/{file,copy} | _filter_test_dir
+
+echo "Copy tail of original file onto copy"
+$XFS_IO_PROG -f -c "copy_range -s 1000 -d 3000 -l 4000 $testdir/file" "$testdir/copy" 2>&1
+cmp -n 1000 $testdir/file $testdir/copy 4000
+cmp -n 1000 $testdir/file $testdir/copy 3000 1000
+cmp -n 1000 $testdir/file $testdir/copy 2000 2000
+cmp -n 4000 $testdir/file $testdir/copy 1000 3000
+echo "md5sums after copying tail:"
+md5sum $testdir/{file,copy} | _filter_test_dir
+
+#success, all done
+status=0
+exit
diff --git a/tests/generic/418.out b/tests/generic/418.out
new file mode 100644
index 00000000..a0d1a4df
--- /dev/null
+++ b/tests/generic/418.out
@@ -0,0 +1,17 @@
+QA output created by 418
+Create the original file and then copy
+Original md5sums:
+e11fbace556cba26bf0076e74cab90a3  TEST_DIR/test-418/file
+e11fbace556cba26bf0076e74cab90a3  TEST_DIR/test-418/copy
+Swap beginning and end of original file
+md5sums after swapping beginning and end:
+e11fbace556cba26bf0076e74cab90a3  TEST_DIR/test-418/file
+5f4e111811dd9a810143c9db9bec6d80  TEST_DIR/test-418/copy
+Swap middle parts of original file
+md5sums after swapping middle:
+e11fbace556cba26bf0076e74cab90a3  TEST_DIR/test-418/file
+8c81889a5a50b311197110bcf769a695  TEST_DIR/test-418/copy
+Copy tail of original file onto copy
+md5sums after copying tail:
+e11fbace556cba26bf0076e74cab90a3  TEST_DIR/test-418/file
+e5fbacd993eaa5e80ebc2b14b969887d  TEST_DIR/test-418/copy
diff --git a/tests/generic/group b/tests/generic/group
index 57ef9d22..f55b2b49 100644
--- a/tests/generic/group
+++ b/tests/generic/group
@@ -420,3 +420,4 @@
 415 auto clone
 416 auto quick copy
 417 auto quick copy
+418 auto quick copy
-- 
2.12.0

