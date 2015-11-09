Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([198.137.202.9]:38230 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752173AbbKIHwp (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 9 Nov 2015 02:52:45 -0500
From: Christoph Hellwig <hch@lst.de>
To: "Darrick J. Wong" <darrick.wong@oracle.com>
Cc: fstests@vger.kernel.org, linux-nfs@vger.kernel.org
Subject: [PATCH] xfstests: feature tests for reflink and dedup
Date: Mon,  9 Nov 2015 08:48:20 +0100
Message-Id: <1447055300-32470-2-git-send-email-hch@lst.de>
In-Reply-To: <1447055300-32470-1-git-send-email-hch@lst.de>
References: <1447055300-32470-1-git-send-email-hch@lst.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Add specific checks for reflink and dedup functionality in
_require_xfs_io_command().  This removes the static checks and allow
to run the tests on NFS, which supports reflink in the upcoming NFSv4.2
standard, but doesn't support dedup.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 common/rc         | 12 ++++++++++++
 tests/generic/800 |  2 +-
 tests/generic/801 |  2 +-
 tests/generic/802 |  2 +-
 tests/generic/803 |  1 -
 tests/generic/804 |  1 -
 tests/generic/805 |  1 -
 tests/generic/806 |  1 -
 tests/generic/807 |  1 -
 tests/generic/808 |  2 +-
 tests/generic/809 |  2 +-
 tests/generic/810 |  2 +-
 tests/generic/811 |  1 -
 tests/generic/812 |  2 +-
 tests/generic/813 |  2 +-
 tests/generic/814 |  2 +-
 tests/generic/815 |  2 +-
 tests/generic/816 |  2 +-
 tests/generic/817 |  1 -
 tests/generic/818 |  1 -
 tests/generic/819 |  1 -
 tests/generic/821 |  1 -
 tests/generic/822 |  1 -
 tests/generic/823 |  1 -
 tests/generic/824 |  1 -
 tests/generic/825 |  1 -
 tests/generic/826 |  1 -
 tests/generic/827 |  1 -
 tests/generic/828 |  1 -
 tests/generic/829 |  1 -
 tests/generic/830 |  2 +-
 tests/generic/831 |  2 +-
 tests/generic/832 |  2 +-
 tests/generic/833 |  2 +-
 tests/generic/834 |  2 +-
 tests/generic/835 |  2 +-
 tests/generic/836 |  2 +-
 tests/generic/837 |  2 +-
 tests/generic/838 |  2 +-
 tests/generic/839 |  2 --
 tests/generic/840 |  2 --
 tests/generic/841 |  2 --
 tests/generic/842 |  1 -
 tests/generic/843 |  1 -
 tests/generic/844 |  1 -
 tests/generic/845 |  1 -
 tests/xfs/800     |  2 +-
 tests/xfs/801     |  2 +-
 tests/xfs/802     |  1 -
 tests/xfs/803     |  3 ++-
 50 files changed, 36 insertions(+), 52 deletions(-)

diff --git a/common/rc b/common/rc
index 639f355..d381181 100644
--- a/common/rc
+++ b/common/rc
@@ -1678,6 +1678,18 @@ _require_xfs_io_command()
 		echo $testio | egrep -q "invalid option|Is a directory" && \
 			_notrun "xfs_io $command support is missing"
 		;;
+	"reflink")
+		testio=`$XFS_IO_PROG -F -f \
+			-c "truncate 4096" \
+			-c "reflink $testfile 0 4096 4096" \
+			$testfile 2>&1`
+		;;
+	"dedupe")
+		testio=`$XFS_IO_PROG -F -f \
+			-c "truncate 4096" \
+			-c "dedupe $testfile 0 4096 4096" \
+			$testfile 2>&1`
+		;;
 	*)
 		testio=`$XFS_IO_PROG -c "$command help" 2>&1`
 	esac
diff --git a/tests/generic/800 b/tests/generic/800
index 954f39d..c12b7ac 100755
--- a/tests/generic/800
+++ b/tests/generic/800
@@ -45,9 +45,9 @@ _cleanup()
 . common/filter
 
 # real QA test starts here
-_require_test_reflink
 _supported_os Linux
 
+_require_xfs_io_command "reflink"
 _require_xfs_io_command "fiemap"
 _require_cp_reflink
 _require_test
diff --git a/tests/generic/801 b/tests/generic/801
index aedb6e9..c5a6401 100755
--- a/tests/generic/801
+++ b/tests/generic/801
@@ -45,9 +45,9 @@ _cleanup()
 . common/filter
 
 # real QA test starts here
-_require_test_reflink
 _supported_os Linux
 
+_require_xfs_io_command "reflink"
 _require_xfs_io_command "fiemap"
 _require_cp_reflink
 _require_test
diff --git a/tests/generic/802 b/tests/generic/802
index 51d3414..57afda9 100755
--- a/tests/generic/802
+++ b/tests/generic/802
@@ -43,9 +43,9 @@ _cleanup()
 . ./common/filter
 
 # real QA test starts here
-_require_test_reflink
 _supported_os Linux
 
+_require_xfs_io_command "reflink"
 _require_xfs_io_command "fiemap"
 _require_cp_reflink
 _require_test
diff --git a/tests/generic/803 b/tests/generic/803
index d5595ed..04ec7a1 100755
--- a/tests/generic/803
+++ b/tests/generic/803
@@ -42,7 +42,6 @@ _cleanup()
 . ./common/filter
 
 # real QA test starts here
-_require_test_reflink
 _supported_os Linux
 
 _require_xfs_io_command "reflink"
diff --git a/tests/generic/804 b/tests/generic/804
index cc39e4d..af682bd 100755
--- a/tests/generic/804
+++ b/tests/generic/804
@@ -43,7 +43,6 @@ _cleanup()
 . ./common/filter
 
 # real QA test starts here
-_require_test_reflink
 _supported_os Linux
 
 _require_xfs_io_command "reflink"
diff --git a/tests/generic/805 b/tests/generic/805
index f926fb7..b52831e 100755
--- a/tests/generic/805
+++ b/tests/generic/805
@@ -44,7 +44,6 @@ _cleanup()
 . ./common/filter
 
 # real QA test starts here
-_require_test_reflink
 _supported_os Linux
 
 _require_xfs_io_command "reflink"
diff --git a/tests/generic/806 b/tests/generic/806
index defcc20..549a5b2 100755
--- a/tests/generic/806
+++ b/tests/generic/806
@@ -42,7 +42,6 @@ _cleanup()
 . ./common/filter
 
 # real QA test starts here
-_require_test_reflink
 _supported_os Linux
 
 _require_xfs_io_command "dedupe"
diff --git a/tests/generic/807 b/tests/generic/807
index e86339d..5ab2d31 100755
--- a/tests/generic/807
+++ b/tests/generic/807
@@ -42,7 +42,6 @@ _cleanup()
 . ./common/filter
 
 # real QA test starts here
-_require_test_reflink
 _supported_os Linux
 
 _require_xfs_io_command "dedupe"
diff --git a/tests/generic/808 b/tests/generic/808
index 8275bd9..4606fde 100755
--- a/tests/generic/808
+++ b/tests/generic/808
@@ -43,7 +43,7 @@ _cleanup()
 . ./common/filter
 
 # real QA test starts here
-_require_test_reflink
+_require_xfs_io_command "dedupe"
 _supported_os Linux
 
 _require_cp_reflink
diff --git a/tests/generic/809 b/tests/generic/809
index 09aac9b..156d38c 100755
--- a/tests/generic/809
+++ b/tests/generic/809
@@ -43,7 +43,7 @@ _cleanup()
 . ./common/filter
 
 # real QA test starts here
-_require_test_reflink
+_require_xfs_io_command "dedupe"
 _supported_os Linux
 
 _require_cp_reflink
diff --git a/tests/generic/810 b/tests/generic/810
index 3de0b69..8b82222 100755
--- a/tests/generic/810
+++ b/tests/generic/810
@@ -43,7 +43,7 @@ _cleanup()
 . ./common/filter
 
 # real QA test starts here
-_require_test_reflink
+_require_xfs_io_command "dedupe"
 _supported_os Linux
 
 _require_cp_reflink
diff --git a/tests/generic/811 b/tests/generic/811
index 8d3aa90..f241c5b 100755
--- a/tests/generic/811
+++ b/tests/generic/811
@@ -43,7 +43,6 @@ _cleanup()
 . ./common/filter
 
 # real QA test starts here
-_require_test_reflink
 _supported_os Linux
 
 _require_xfs_io_command "reflink"
diff --git a/tests/generic/812 b/tests/generic/812
index 0564ec3..1d74e43 100755
--- a/tests/generic/812
+++ b/tests/generic/812
@@ -44,9 +44,9 @@ _cleanup()
 . ./common/filter
 
 # real QA test starts here
-_require_test_reflink
 _supported_os Linux
 
+_require_xfs_io_command "reflink"
 _require_xfs_io_command "fcollapse"
 _require_cp_reflink
 _require_test
diff --git a/tests/generic/813 b/tests/generic/813
index ee399fc..f47edf5 100755
--- a/tests/generic/813
+++ b/tests/generic/813
@@ -44,9 +44,9 @@ _cleanup()
 . ./common/filter
 
 # real QA test starts here
-_require_test_reflink
 _supported_os Linux
 
+_require_xfs_io_command "reflink"
 _require_xfs_io_command "fpunch"
 _require_cp_reflink
 _require_test
diff --git a/tests/generic/814 b/tests/generic/814
index 55ac879..0c3fca5 100755
--- a/tests/generic/814
+++ b/tests/generic/814
@@ -44,9 +44,9 @@ _cleanup()
 . ./common/filter
 
 # real QA test starts here
-_require_test_reflink
 _supported_os Linux
 
+_require_xfs_io_command "reflink"
 _require_xfs_io_command "finsert"
 _require_cp_reflink
 _require_test
diff --git a/tests/generic/815 b/tests/generic/815
index eb835ef..26b47b4 100755
--- a/tests/generic/815
+++ b/tests/generic/815
@@ -45,9 +45,9 @@ _cleanup()
 . ./common/filter
 
 # real QA test starts here
-_require_test_reflink
 _supported_os Linux
 
+_require_xfs_io_command "reflink"
 _require_xfs_io_command "truncate"
 _require_cp_reflink
 _require_test
diff --git a/tests/generic/816 b/tests/generic/816
index 121cde0..dd0fcf4 100755
--- a/tests/generic/816
+++ b/tests/generic/816
@@ -44,9 +44,9 @@ _cleanup()
 . ./common/filter
 
 # real QA test starts here
-_require_test_reflink
 _supported_os Linux
 
+_require_xfs_io_command "reflink"
 _require_xfs_io_command "fzero"
 _require_cp_reflink
 _require_test
diff --git a/tests/generic/817 b/tests/generic/817
index 109a9d8..1cb2f10 100755
--- a/tests/generic/817
+++ b/tests/generic/817
@@ -46,7 +46,6 @@ _cleanup()
 . ./common/filter
 
 # real QA test starts here
-_require_test_reflink
 _supported_os Linux
 
 _require_xfs_io_command "reflink"
diff --git a/tests/generic/818 b/tests/generic/818
index 0a99768..63c5c47 100755
--- a/tests/generic/818
+++ b/tests/generic/818
@@ -46,7 +46,6 @@ _cleanup()
 . ./common/filter
 
 # real QA test starts here
-_require_test_reflink
 _supported_os Linux
 
 _require_xfs_io_command "dedupe"
diff --git a/tests/generic/819 b/tests/generic/819
index 08bc374..b0caafb 100755
--- a/tests/generic/819
+++ b/tests/generic/819
@@ -46,7 +46,6 @@ _cleanup()
 . ./common/filter
 
 # real QA test starts here
-_require_test_reflink
 _supported_os Linux
 
 _require_xfs_io_command "reflink"
diff --git a/tests/generic/821 b/tests/generic/821
index 77393cb..cbdf1b4 100755
--- a/tests/generic/821
+++ b/tests/generic/821
@@ -46,7 +46,6 @@ _supported_fs generic
 _supported_os Linux
 
 _require_scratch
-_require_scratch_reflink
 _require_cp_reflink
 _require_xfs_io_command "reflink"
 
diff --git a/tests/generic/822 b/tests/generic/822
index 6ee7a8c..a6ff9c5 100755
--- a/tests/generic/822
+++ b/tests/generic/822
@@ -46,7 +46,6 @@ _supported_fs generic
 _supported_os Linux
 
 _require_scratch
-_require_scratch_reflink
 _require_cp_reflink
 _require_xfs_io_command "reflink"
 
diff --git a/tests/generic/823 b/tests/generic/823
index bf3a712..3c8dd1e 100755
--- a/tests/generic/823
+++ b/tests/generic/823
@@ -46,7 +46,6 @@ _supported_fs generic
 _supported_os Linux
 
 _require_scratch
-_require_scratch_reflink
 _require_cp_reflink
 _require_xfs_io_command "reflink"
 
diff --git a/tests/generic/824 b/tests/generic/824
index 38737c6..27ff59c 100755
--- a/tests/generic/824
+++ b/tests/generic/824
@@ -46,7 +46,6 @@ _supported_fs generic
 _supported_os Linux
 
 _require_scratch
-_require_scratch_reflink
 _require_cp_reflink
 _require_xfs_io_command "reflink"
 
diff --git a/tests/generic/825 b/tests/generic/825
index 476527a..229d4ac 100755
--- a/tests/generic/825
+++ b/tests/generic/825
@@ -47,7 +47,6 @@ _supported_fs generic
 _supported_os Linux
 
 _require_scratch
-_require_scratch_reflink
 _require_cp_reflink
 _require_xfs_io_command "reflink"
 
diff --git a/tests/generic/826 b/tests/generic/826
index 1739778..52e1235 100755
--- a/tests/generic/826
+++ b/tests/generic/826
@@ -47,7 +47,6 @@ _supported_fs generic
 _supported_os Linux
 
 _require_scratch
-_require_scratch_reflink
 _require_cp_reflink
 _require_xfs_io_command "reflink"
 
diff --git a/tests/generic/827 b/tests/generic/827
index fa2ba2e..cc1bc52 100755
--- a/tests/generic/827
+++ b/tests/generic/827
@@ -47,7 +47,6 @@ _supported_fs generic
 _supported_os Linux
 
 _require_scratch
-_require_scratch_reflink
 _require_xfs_io_command "reflink"
 
 echo "Format and mount"
diff --git a/tests/generic/828 b/tests/generic/828
index 43b1682..1757985 100755
--- a/tests/generic/828
+++ b/tests/generic/828
@@ -47,7 +47,6 @@ _supported_fs generic
 _supported_os Linux
 
 _require_scratch
-_require_scratch_reflink
 _require_xfs_io_command "reflink"
 
 echo "Format and mount"
diff --git a/tests/generic/829 b/tests/generic/829
index 76fe937..a4b55a2 100755
--- a/tests/generic/829
+++ b/tests/generic/829
@@ -47,7 +47,6 @@ _supported_fs generic
 _supported_os Linux
 
 _require_scratch
-_require_scratch_reflink
 _require_cp_reflink
 _require_xfs_io_command "reflink"
 
diff --git a/tests/generic/830 b/tests/generic/830
index 2d9a7af..ab426a6 100755
--- a/tests/generic/830
+++ b/tests/generic/830
@@ -43,9 +43,9 @@ _cleanup()
 . ./common/filter
 
 # real QA test starts here
-_require_test_reflink
 _supported_os Linux
 
+_require_xfs_io_command "reflink"
 _require_cp_reflink
 _require_test
 
diff --git a/tests/generic/831 b/tests/generic/831
index cbf9723..a50a715 100755
--- a/tests/generic/831
+++ b/tests/generic/831
@@ -47,7 +47,7 @@ _cleanup()
 . ./common/filter
 
 # real QA test starts here
-_require_test_reflink
+_require_xfs_io_command "reflink"
 _supported_os Linux
 
 _require_cp_reflink
diff --git a/tests/generic/832 b/tests/generic/832
index 3b1e7d2..ce7509a 100755
--- a/tests/generic/832
+++ b/tests/generic/832
@@ -47,9 +47,9 @@ _cleanup()
 . ./common/filter
 
 # real QA test starts here
-_require_test_reflink
 _supported_os Linux
 
+_require_xfs_io_command "reflink"
 _require_xfs_io_command "fpunch"
 _require_cp_reflink
 _require_test
diff --git a/tests/generic/833 b/tests/generic/833
index bd635d7..c7017a5 100755
--- a/tests/generic/833
+++ b/tests/generic/833
@@ -47,9 +47,9 @@ _cleanup()
 . ./common/filter
 
 # real QA test starts here
-_require_test_reflink
 _supported_os Linux
 
+_require_xfs_io_command "reflink"
 _require_xfs_io_command "fcollapse"
 _require_cp_reflink
 _require_test
diff --git a/tests/generic/834 b/tests/generic/834
index 598cf8a..534aa97 100755
--- a/tests/generic/834
+++ b/tests/generic/834
@@ -47,7 +47,7 @@ _cleanup()
 . ./common/filter
 
 # real QA test starts here
-_require_test_reflink
+_require_xfs_io_command "reflink"
 _supported_os Linux
 
 _require_cp_reflink
diff --git a/tests/generic/835 b/tests/generic/835
index 22bd768..f3840e1 100755
--- a/tests/generic/835
+++ b/tests/generic/835
@@ -50,9 +50,9 @@ _cleanup()
 . ./common/filter
 
 # real QA test starts here
-_require_test_reflink
 _supported_os Linux
 
+_require_xfs_io_command "reflink"
 _require_xfs_io_command "fzero"
 _require_cp_reflink
 _require_test
diff --git a/tests/generic/836 b/tests/generic/836
index 9bc81c5..92b4ce6 100755
--- a/tests/generic/836
+++ b/tests/generic/836
@@ -53,9 +53,9 @@ if [ $FSTYP = "btrfs" ]; then
 fi
 
 # real QA test starts here
-_require_test_reflink
 _supported_os Linux
 
+_require_xfs_io_command "reflink"
 _require_xfs_io_command "funshare"
 _require_cp_reflink
 _require_test
diff --git a/tests/generic/837 b/tests/generic/837
index 1824ee0..9528df2 100755
--- a/tests/generic/837
+++ b/tests/generic/837
@@ -45,7 +45,7 @@ _cleanup()
 . ./common/filter
 
 # real QA test starts here
-_require_test_reflink
+_require_xfs_io_command "reflink"
 _supported_os Linux
 
 _require_cp_reflink
diff --git a/tests/generic/838 b/tests/generic/838
index 00977e5..a35c813 100755
--- a/tests/generic/838
+++ b/tests/generic/838
@@ -45,7 +45,7 @@ _cleanup()
 . ./common/filter
 
 # real QA test starts here
-_require_test_reflink
+_require_xfs_io_command "reflink"
 _supported_os Linux
 
 _require_cp_reflink
diff --git a/tests/generic/839 b/tests/generic/839
index fe32cfb..755b741 100755
--- a/tests/generic/839
+++ b/tests/generic/839
@@ -43,8 +43,6 @@ _cleanup()
 # real QA test starts here
 _require_test
 _require_scratch
-_require_scratch_reflink
-_require_test_reflink
 _supported_os Linux
 
 _require_xfs_io_command "reflink"
diff --git a/tests/generic/840 b/tests/generic/840
index 50ccae9..da5f040 100755
--- a/tests/generic/840
+++ b/tests/generic/840
@@ -45,8 +45,6 @@ _cleanup()
 # real QA test starts here
 _require_test
 _require_scratch
-_require_scratch_reflink
-_require_test_reflink
 _supported_os Linux
 
 _require_xfs_io_command "reflink"
diff --git a/tests/generic/841 b/tests/generic/841
index 5cc534e..09aaca1 100755
--- a/tests/generic/841
+++ b/tests/generic/841
@@ -42,8 +42,6 @@ _cleanup()
 
 # real QA test starts here
 _require_scratch
-_require_scratch_reflink
-_require_test_reflink
 _supported_os Linux
 
 _require_xfs_io_command "reflink"
diff --git a/tests/generic/842 b/tests/generic/842
index 9e46b6e..a5ab401 100755
--- a/tests/generic/842
+++ b/tests/generic/842
@@ -43,7 +43,6 @@ _cleanup()
 
 # real QA test starts here
 _require_scratch
-_require_scratch_reflink
 _supported_os Linux
 
 _require_xfs_io_command "reflink"
diff --git a/tests/generic/843 b/tests/generic/843
index 9349af1..04b9029 100755
--- a/tests/generic/843
+++ b/tests/generic/843
@@ -43,7 +43,6 @@ _cleanup()
 
 # real QA test starts here
 _require_scratch
-_require_scratch_reflink
 _supported_os Linux
 
 _require_xfs_io_command "reflink"
diff --git a/tests/generic/844 b/tests/generic/844
index ee834b3..486194d 100755
--- a/tests/generic/844
+++ b/tests/generic/844
@@ -43,7 +43,6 @@ _cleanup()
 
 # real QA test starts here
 _require_scratch
-_require_scratch_reflink
 _supported_os Linux
 
 _require_xfs_io_command "reflink"
diff --git a/tests/generic/845 b/tests/generic/845
index 5587687..b6e7cb3 100755
--- a/tests/generic/845
+++ b/tests/generic/845
@@ -43,7 +43,6 @@ _cleanup()
 
 # real QA test starts here
 _require_scratch
-_require_scratch_reflink
 _supported_os Linux
 
 _require_xfs_io_command "reflink"
diff --git a/tests/xfs/800 b/tests/xfs/800
index 58059f7..313f50c 100755
--- a/tests/xfs/800
+++ b/tests/xfs/800
@@ -43,9 +43,9 @@ _cleanup()
 # real QA test starts here
 _supported_fs xfs
 _require_scratch
-_require_scratch_reflink
 _supported_os Linux
 
+_require_xfs_io_command "reflink"
 _require_cp_reflink
 
 echo "Format and mount"
diff --git a/tests/xfs/801 b/tests/xfs/801
index 96a47e4..37c534c 100755
--- a/tests/xfs/801
+++ b/tests/xfs/801
@@ -43,9 +43,9 @@ _cleanup()
 # real QA test starts here
 _supported_fs xfs
 _require_scratch
-_require_scratch_reflink
 _supported_os Linux
 
+_require_xfs_io_command "reflink"
 _require_cp_reflink
 
 echo "Format and mount"
diff --git a/tests/xfs/802 b/tests/xfs/802
index 05c5004..359f317 100755
--- a/tests/xfs/802
+++ b/tests/xfs/802
@@ -45,7 +45,6 @@ _cleanup()
 _supported_fs xfs
 _require_test
 _require_scratch
-_require_scratch_reflink
 _supported_os Linux
 
 _require_xfs_io_command "reflink"
diff --git a/tests/xfs/803 b/tests/xfs/803
index 62a9246..1f8f580 100755
--- a/tests/xfs/803
+++ b/tests/xfs/803
@@ -47,7 +47,8 @@ _supported_fs xfs
 _supported_os Linux
 
 _require_scratch
-_require_scratch_reflink
+_require_xfs_io_command "reflink"
+
 test -n "${FORCE_FUZZ}" || _require_scratch_xfs_crc
 _require_attrs
 
-- 
1.9.1

