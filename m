Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx144.netapp.com ([216.240.21.25]:36377 "EHLO mx144.netapp.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751208AbdCQUVd (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 17 Mar 2017 16:21:33 -0400
From: Anna Schumaker <Anna.Schumaker@Netapp.com>
To: <fstests@vger.kernel.org>
CC: <Anna.Schumaker@Netapp.com>, <linux-nfs@vger.kernel.org>,
        <hch@infradead.org>
Subject: [PATCH v5 1/5] generic/416: Add copy to new file test
Date: Fri, 17 Mar 2017 15:52:29 -0400
Message-ID: <20170317195233.4042-2-Anna.Schumaker@Netapp.com>
In-Reply-To: <20170317195233.4042-1-Anna.Schumaker@Netapp.com>
References: <20170317195233.4042-1-Anna.Schumaker@Netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This test copies data from various points in a source file to a new
file.  This is useful for testing the basics of copy_file_range().

Signed-off-by: Anna Schumaker <Anna.Schumaker@Netapp.com>
---
 common/rc             |   6 +++
 tests/generic/416     | 102 ++++++++++++++++++++++++++++++++++++++++++++++++++
 tests/generic/416.out |  26 +++++++++++++
 tests/generic/group   |   1 +
 4 files changed, 135 insertions(+)
 create mode 100755 tests/generic/416
 create mode 100644 tests/generic/416.out

diff --git a/common/rc b/common/rc
index 109325df..98552a99 100644
--- a/common/rc
+++ b/common/rc
@@ -1976,6 +1976,12 @@ _require_xfs_io_command()
 	"chproj")
 		testio=`$XFS_IO_PROG -F -f -c "chproj 0" $testfile 2>&1`
 		;;
+	"copy_range")
+		testcopy=$TEST_DIR/$$.copy.xfs_io
+		$XFS_IO_PROG -F -f -c "pwrite 0 4k" $testfile 2>&1 > /dev/null
+		testio=`$XFS_IO_PROG -F -f -c "copy_range $testfile" $testcopy 2>&1`
+		rm -f $testcopy 2>&1 > /dev/null
+		;;
 	"falloc" )
 		testio=`$XFS_IO_PROG -F -f -c "falloc 0 1m" $testfile 2>&1`
 		;;
diff --git a/tests/generic/416 b/tests/generic/416
new file mode 100755
index 00000000..a669a6e7
--- /dev/null
+++ b/tests/generic/416
@@ -0,0 +1,102 @@
+#!/bin/bash
+# FS QA Test No. 416
+#
+# Tests vfs_copy_file_range():
+#   - Copy a file
+#   - Copy beginning of original to new file
+#   - Copy middle of original to a new file
+#   - Copy end of original to new file
+#   - Copy middle of original to a new file, creating a hole
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
+cmp $testdir/file $testdir/copy
+echo "Original md5sums:"
+md5sum $testdir/{file,copy} | _filter_test_dir
+
+echo "Copy beginning of original file"
+$XFS_IO_PROG -f -c "copy_range -l 1000 $testdir/file" "$testdir/beginning" 2>&1
+cmp -n 1000 $testdir/file $testdir/beginning
+echo "md5sums after copying beginning:"
+md5sum $testdir/{file,beginning} | _filter_test_dir
+
+echo "Copy middle of original file"
+$XFS_IO_PROG -f -c "copy_range -s 1000 -l 3000 $testdir/file" "$testdir/middle" 2>&1
+cmp -n 3000 $testdir/file $testdir/middle 1000
+echo "md5sums after copying middle:"
+md5sum $testdir/{file,middle} | _filter_test_dir
+
+echo "Copy end of original file"
+$XFS_IO_PROG -f -c "copy_range -s 4000 -l 1000 $testdir/file" "$testdir/end" 2>&1
+cmp -n 1000 $testdir/file $testdir/end 4000
+echo "md5sums after copying end:"
+md5sum $testdir/{file,end} | _filter_test_dir
+
+echo "Copy beyond end of original file"
+$XFS_IO_PROG -f -c "copy_range -s 4000 -l 2000 $testdir/file" "$testdir/beyond" 2>&1
+cmp -n 1000 $testdir/file $testdir/end 4000
+echo "md5sums after copying beyond:"
+md5sum $testdir/{file,beyond} | _filter_test_dir
+
+echo "Copy creates hole in target file"
+$XFS_IO_PROG -f -c "copy_range -s 1000 -l 3000 -d 1000 $testdir/file" "$testdir/hole" 2>&1
+cmp -n 3000 $testdir/file $testdir/hole 1000 1000
+echo "md5sums after creating hole:"
+md5sum $testdir/{file,hole} | _filter_test_dir
+
+#success, all done
+status=0
+exit
diff --git a/tests/generic/416.out b/tests/generic/416.out
new file mode 100644
index 00000000..107a156b
--- /dev/null
+++ b/tests/generic/416.out
@@ -0,0 +1,26 @@
+QA output created by 416
+Create the original file and then copy
+Original md5sums:
+e11fbace556cba26bf0076e74cab90a3  TEST_DIR/test-416/file
+e11fbace556cba26bf0076e74cab90a3  TEST_DIR/test-416/copy
+Copy beginning of original file
+md5sums after copying beginning:
+e11fbace556cba26bf0076e74cab90a3  TEST_DIR/test-416/file
+cabe45dcc9ae5b66ba86600cca6b8ba8  TEST_DIR/test-416/beginning
+Copy middle of original file
+md5sums after copying middle:
+e11fbace556cba26bf0076e74cab90a3  TEST_DIR/test-416/file
+4197de9da5badfc302715486b82bcdf1  TEST_DIR/test-416/middle
+Copy end of original file
+md5sums after copying end:
+e11fbace556cba26bf0076e74cab90a3  TEST_DIR/test-416/file
+e68d4a150c4e42f4f9ea3ffe4c9cf4ed  TEST_DIR/test-416/end
+Copy beyond end of original file
+copy_range: Invalid argument
+md5sums after copying beyond:
+e11fbace556cba26bf0076e74cab90a3  TEST_DIR/test-416/file
+e68d4a150c4e42f4f9ea3ffe4c9cf4ed  TEST_DIR/test-416/beyond
+Copy creates hole in target file
+md5sums after creating hole:
+e11fbace556cba26bf0076e74cab90a3  TEST_DIR/test-416/file
+3ae9aef0992f8cb51c90c9a0ff2dd9d2  TEST_DIR/test-416/hole
diff --git a/tests/generic/group b/tests/generic/group
index b510d410..9541fff5 100644
--- a/tests/generic/group
+++ b/tests/generic/group
@@ -418,3 +418,4 @@
 413 auto quick
 414 auto quick clone
 415 auto clone
+416 auto quick copy
-- 
2.12.0

