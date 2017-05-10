Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx143.netapp.com ([216.240.21.24]:62842 "EHLO mx143.netapp.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752285AbdEJRqs (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 10 May 2017 13:46:48 -0400
From: Anna Schumaker <Anna.Schumaker@Netapp.com>
To: <fstests@vger.kernel.org>
CC: <Anna.Schumaker@Netapp.com>, <linux-nfs@vger.kernel.org>,
        <hch@infradead.org>
Subject: [PATCH v6 5/5] generic/433: Add a copy test for invalid input
Date: Wed, 10 May 2017 13:46:28 -0400
Message-ID: <20170510174628.22895-6-Anna.Schumaker@Netapp.com>
In-Reply-To: <20170510174628.22895-1-Anna.Schumaker@Netapp.com>
References: <20170510174628.22895-1-Anna.Schumaker@Netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This test passes invalid argumnt combinations to the copy_file_range()
system call to test that input is verified before attempting to copy.

Signed-off-by: Anna Schumaker <Anna.Schumaker@Netapp.com>
---
 tests/generic/433     | 79 +++++++++++++++++++++++++++++++++++++++++++++++++++
 tests/generic/433.out | 14 +++++++++
 tests/generic/group   |  1 +
 3 files changed, 94 insertions(+)
 create mode 100644 tests/generic/433
 create mode 100644 tests/generic/433.out

diff --git a/tests/generic/433 b/tests/generic/433
new file mode 100644
index 00000000..11b936eb
--- /dev/null
+++ b/tests/generic/433
@@ -0,0 +1,79 @@
+#!/bin/bash
+# FS QA Test No. 433
+#
+# Tests vfs_copy_file_range() error checking
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
+echo "Create the original files"
+$XFS_IO_PROG -f -c 'pwrite -S 0x61 0 1000' $testdir/file >> $seqres.full 2>&1
+mknod $testdir/dev1 c 1 3
+mkfifo $testdir/fifo
+
+echo "Try to copy when source pos > source size"
+$XFS_IO_PROG -f -c "copy_range -s 1000 -l 100 $testdir/file" "$testdir/copy" 2>&1
+md5sum $testdir/copy | _filter_test_dir
+
+echo "Try to copy to a read-only file"
+$XFS_IO_PROG -r -f -c "copy_range -s 0 -l 100 $testdir/file" "$testdir/copy" 2>&1
+md5sum $testdir/copy | _filter_test_dir
+
+echo "Try to copy to an append-only file"
+$XFS_IO_PROG -a -f -c "copy_range -s 0 -l 100 $testdir/file" "$testdir/copy" 2>&1
+md5sum $testdir/copy | _filter_test_dir
+
+echo "Try to copy to a device"
+$XFS_IO_PROG -a -f -c "copy_range -s 0 -l 100 $testdir/file" "$testdir/dev1" 2>&1
+
+echo "Try to copy to a fifo"
+$XFS_IO_PROG -a -f -c "copy_range -s 0 -l 100 $testdir/file" "$testdir/fifo" 2>&1
+
+#success, all done
+status=0
+exit
diff --git a/tests/generic/433.out b/tests/generic/433.out
new file mode 100644
index 00000000..da6f5e9c
--- /dev/null
+++ b/tests/generic/433.out
@@ -0,0 +1,14 @@
+QA output created by 433
+Create the original files
+Try to copy when source pos > source size
+d41d8cd98f00b204e9800998ecf8427e  TEST_DIR/test-433/copy
+Try to copy to a read-only file
+copy_range: Bad file descriptor
+d41d8cd98f00b204e9800998ecf8427e  TEST_DIR/test-433/copy
+Try to copy to an append-only file
+copy_range: Bad file descriptor
+d41d8cd98f00b204e9800998ecf8427e  TEST_DIR/test-433/copy
+Try to copy to a device
+copy_range: Invalid argument
+Try to copy to a fifo
+copy_range: Invalid argument
diff --git a/tests/generic/group b/tests/generic/group
index 43aac9fd..fc00405f 100644
--- a/tests/generic/group
+++ b/tests/generic/group
@@ -435,3 +435,4 @@
 430 auto quick copy
 431 auto quick copy
 432 auto quick copy
+433 auto quick copy
-- 
2.12.2

