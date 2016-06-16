Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([198.137.202.9]:50838 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754622AbcFPPBr (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 16 Jun 2016 11:01:47 -0400
Received: from hch by bombadil.infradead.org with local (Exim 4.80.1 #2 (Red Hat Linux))
	id 1bDYnj-0004xy-1u
	for linux-nfs@vger.kernel.org; Thu, 16 Jun 2016 15:01:47 +0000
Date: Thu, 16 Jun 2016 08:01:47 -0700
From: Christoph Hellwig <hch@infradead.org>
To: linux-nfs@vger.kernel.org
Subject: odd sillyrename bug in 4.6 / 4.7-rc
Message-ID: <20160616150146.GA14015@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

I've run into an odd bug when testing the clone / reflink functionality,
and managed to isolate a testcase not relying on clones.  The issue is
that after a lot of direct I/O hitting ENOSPC on a NFS mount I run
into a silly rename that never gets cleaned up after cleaning up the
directory.

Note that so far I've only managed to reproduce it against a Linux
server running XFS (ext4 and btrfs seem fine) despite looking like
a client bug, and although once in a while a single run of the testcase
cause the bug I usually need a few iterations.

All over it seems like some odd dentry refcount race where we see
a spurious reference for one reason or another.


Below is a patch to xfstests to add this reproducer:


diff --git a/tests/generic/700 b/tests/generic/700
new file mode 100755
index 0000000..33505b0
--- /dev/null
+++ b/tests/generic/700
@@ -0,0 +1,130 @@
+#! /bin/bash
+# FS QA Test No. 700
+#
+# Dumbed down Copy of the original version of generic/187 that reproduced
+# NFS silly rename issues.
+#-----------------------------------------------------------------------
+# Copyright (c) 2015, Oracle and/or its affiliates.  All Rights Reserved.
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
+    cd /
+    rm -rf $tmp.* $testdir
+}
+
+# get standard environment, filters and checks
+. ./common/rc
+. ./common/filter
+
+# real QA test starts here
+_supported_os Linux
+_require_xfs_io_command "falloc"
+_require_xfs_io_command "fpunch"
+test $FSTYP = "btrfs" && _notrun "Can't fragment free space on btrfs."
+_require_odirect
+
+rm -f $seqres.full
+
+_fragment_freesp()
+{
+	file=$1
+
+	# consume nearly all available space (leave ~1MB)
+	avail=`_get_available_space $SCRATCH_MNT`
+	echo "$avail bytes left"
+	filesize=$((avail - 1048576))
+	$XFS_IO_PROG -fc "truncate $filesize" $file
+
+	chunks=20
+	chunksizemb=$((filesize / chunks / 1048576))
+	seq 1 $chunks | while read f; do
+		echo "$((f * chunksizemb)) file size $f / 20"
+		$XFS_IO_PROG -fc "falloc -k $(( (f - 1) * chunksizemb))m ${chunksizemb}m" $file
+	done
+
+	chunks=100
+	chunksizemb=$((filesize / chunks / 1048576))
+	seq 80 $chunks | while read f; do
+		echo "$((f * chunksizemb)) file size $f / $chunks"
+		$XFS_IO_PROG -fc "falloc -k $(( (f - 1) * chunksizemb))m ${chunksizemb}m" $file
+	done
+
+	filesizemb=$((filesize / 1048576))
+	$XFS_IO_PROG -fc "falloc -k 0 ${filesizemb}m" $file
+
+	# Try again anyway
+	avail=`_get_available_space $SCRATCH_MNT`
+	$XFS_IO_PROG -fc "pwrite -S 0x65 0 $avail" ${file}.${i}
+
+	# Punch out whatever we need
+	seq 1 $((nr * 4)) | while read f; do
+		$XFS_IO_PROG -f -c "fpunch $((f * 2 * blksz)) $blksz" $file
+	done
+}
+
+echo "Format and mount"
+_scratch_mkfs > $seqres.full 2>&1
+_scratch_mount >> $seqres.full 2>&1
+
+testdir=$SCRATCH_MNT/test-$seq
+mkdir $testdir
+
+echo "Create the original files"
+blksz=65536
+nr=1024
+filesize=$((blksz * nr))
+_pwrite_byte 0x61 0 $filesize $testdir/file1 >> $seqres.full
+_pwrite_byte 0x62 0 $filesize $testdir/file2 >> $seqres.full
+seq 0 2 $((nr-1)) | while read f; do
+#	_reflink_range $testdir/file1 $((blksz * f)) $testdir/file3 $((blksz * f)) $blksz >> $seqres.full
+	touch $testdir/file3
+	_pwrite_byte 0x61 $((blksz * f)) $blksz $testdir/file3.chk >> $seqres.full
+done
+seq 1 2 $((nr-1)) | while read f; do
+	touch $testdir/file3
+#	_reflink_range $testdir/file2 $((blksz * f)) $testdir/file3 $((blksz * f)) $blksz >> $seqres.full
+	_pwrite_byte 0x62 $((blksz * f)) $blksz $testdir/file3.chk >> $seqres.full
+done
+_scratch_cycle_mount
+_fragment_freesp $testdir/bigfile >> $seqres.full 2>&1
+filesize=$((blksz * nr))
+_scratch_cycle_mount
+
+echo "Overwrite"
+cowoff=$((filesize / 4))
+cowsz=$((filesize / 2))
+$XFS_IO_PROG -d -f -c "pwrite -S 0x63 -b $cowsz $cowoff $cowsz" $testdir/file3 >> $seqres.full
+_pwrite_byte 0x63 $cowoff $cowsz $testdir/file3.chk >> $seqres.full
+
+# mount / unmount
+_scratch_cycle_mount
+
+echo "Deleting"
+rm -r $testdir
+
+# success, all done
+status=0
+exit
diff --git a/tests/generic/700.out b/tests/generic/700.out
new file mode 100644
index 0000000..9f7ce0f
--- /dev/null
+++ b/tests/generic/700.out
@@ -0,0 +1,5 @@
+QA output created by 700
+Format and mount
+Create the original files
+Overwrite
+Deleting
diff --git a/tests/generic/group b/tests/generic/group
index 2bd40a1..46a796a 100644
--- a/tests/generic/group
+++ b/tests/generic/group
@@ -354,6 +354,7 @@
 349 blockdev quick rw
 350 blockdev quick rw
 351 blockdev quick rw
+700 auto nfs
 923 auto quick clone
 924 auto quick clone
 925 auto quick clone
