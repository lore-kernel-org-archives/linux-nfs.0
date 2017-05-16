Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:55126 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751567AbdEPMLp (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 16 May 2017 08:11:45 -0400
From: Eryu Guan <eguan@redhat.com>
To: fstests@vger.kernel.org
Cc: Eryu Guan <eguan@redhat.com>,
        "J . Bruce Fields" <bfields@redhat.com>,
        Weston Andros Adamson <dros@primarydata.com>,
        linux-nfs@vger.kernel.org
Subject: [RFC PATCH] nfs: test nfs4_getfacl near page size ACL from server
Date: Tue, 16 May 2017 20:09:09 +0800
Message-Id: <20170516120909.827-1-eguan@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Test nfs4_getfacl gets ACL list correctly from server when the ACL
length is close enough to the end of a page. On buggy NFS client
getxattr could return ERANGE. Upstream commit ed92d8c137b7 ("NFSv4:
fix getacl ERANGE for some ACL buffer sizes") fixed this bug in 4.11
kernel.

Note that this reproducer was originally written by J. Bruce Fields.

Cc: J. Bruce Fields <bfields@redhat.com>
Cc: Weston Andros Adamson <dros@primarydata.com>
Cc: linux-nfs@vger.kernel.org
Signed-off-by: Eryu Guan <eguan@redhat.com>
---

Hi all,

This is the first attempt to add NFS specific tests to fstests with the hope
that we'll have more NFS tests go to fstests and more people testing NFS by
running fstests, it would be great if fstests could be part of the Linux NFS
development workflow too.

fstests does find NFS bugs (some are regression bugs), I noticed at least three
regressions introduced in 4.12-rc1 release, one was reported to nfs list[1].
The other two regressions are:
a) generic/095 crashes NFS (not sure server or client yet, not reproduced
   manually yet)
b) copy_file_range(2) hang on NFSv4.2 mount, caught by just added
   copy_file_range tests.

I'm still working on bisecting them now, will report to NFS list once I get
something.

Thanks,
Eryu

[1] https://www.spinics.net/lists/linux-nfs/msg63767.html

 common/config      |  2 ++
 common/nfs         | 35 +++++++++++++++++++++++++
 common/rc          |  1 +
 tests/nfs/001      | 77 ++++++++++++++++++++++++++++++++++++++++++++++++++++++
 tests/nfs/001.out  |  2 ++
 tests/nfs/Makefile | 20 ++++++++++++++
 tests/nfs/group    |  6 +++++
 7 files changed, 143 insertions(+)
 create mode 100644 common/nfs
 create mode 100755 tests/nfs/001
 create mode 100644 tests/nfs/001.out
 create mode 100644 tests/nfs/Makefile
 create mode 100644 tests/nfs/group

diff --git a/common/config b/common/config
index 8211356..c3e9997 100644
--- a/common/config
+++ b/common/config
@@ -196,6 +196,8 @@ export XZ_PROG="`set_prog_path xz`"
 export FLOCK_PROG="`set_prog_path flock`"
 export LDD_PROG="`set_prog_path ldd`"
 export TIMEOUT_PROG="`set_prog_path timeout`"
+export NFS4_SETFACL_PROG="`set_prog_path nfs4_setfacl`"
+export NFS4_GETFACL_PROG="`set_prog_path nfs4_getfacl`"
 
 # use 'udevadm settle' or 'udevsettle' to wait for lv to be settled.
 # newer systems have udevadm command but older systems like RHEL5 don't.
diff --git a/common/nfs b/common/nfs
new file mode 100644
index 0000000..a03eaf4
--- /dev/null
+++ b/common/nfs
@@ -0,0 +1,35 @@
+#
+# NFS specific common functions.
+#
+
+# given an NFS export and a NFS version number, return 0 if
+# the mounted NFS is the given version. e.g.
+# _is_nfs_version $SCRATCH_DEV 4.2
+_is_nfs_version()
+{
+	local nfs_exp=$1
+	local nfs_ver=$2
+	_fs_options $1 | grep -q "vers=$2"
+}
+
+# require $TEST_DEV mounted as a given NFS version
+# e.g. _require_test_nfs_version 4.2
+_require_test_nfs_version()
+{
+	_require_test
+	if ! _is_nfs_version $TEST_DEV $1; then
+		_notrun "Test requires \$TEST_DEV mounted as NFSv$1"
+	fi
+}
+
+# require $SCRATCH_DEV mounted as a given NFS version
+# e.g. _require_scratch_nfs_version 4
+_require_scratch_nfs_version()
+{
+	_require_scratch
+	_scratch_mount
+	if ! _is_nfs_version $SCRATCH_DEV $1; then
+		_notrun "Test requires \$SCRATCH_DEV mounted as NFSv$1"
+	fi
+	_scratch_unmount
+}
diff --git a/common/rc b/common/rc
index aa35b5e..ca0a284 100644
--- a/common/rc
+++ b/common/rc
@@ -162,6 +162,7 @@ case "$FSTYP" in
 	 [ "$MKFS_F2FS_PROG" = "" ] && _fatal "mkfs.f2fs not found"
 	 ;;
     nfs)
+	 . ./common/nfs
 	 ;;
     cifs)
 	 ;;
diff --git a/tests/nfs/001 b/tests/nfs/001
new file mode 100755
index 0000000..764cde3
--- /dev/null
+++ b/tests/nfs/001
@@ -0,0 +1,77 @@
+#! /bin/bash
+# FS QA Test 001
+#
+# Test nfs4_getfacl gets ACL list correctly from server when the ACL length is
+# close enough to the end of a page. On buggy NFS client getxattr could return
+# ERANGE. Upstream commit ed92d8c137b7 ("NFSv4: fix getacl ERANGE for some ACL
+# buffer sizes") fixed this bug.
+#
+#-----------------------------------------------------------------------
+# Copyright (c) 2017 Red Hat Inc., All Rights Reserved.
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
+status=1	# failure is the default!
+trap "_cleanup; exit \$status" 0 1 2 3 15
+
+_cleanup()
+{
+	cd /
+	rm -f $tmp.* $acltest.*
+}
+
+# get standard environment, filters and checks
+. ./common/rc
+. ./common/filter
+
+# remove previous $seqres.full before test
+rm -f $seqres.full
+
+# real QA test starts here
+_supported_fs nfs
+_supported_os Linux
+_require_test_nfs_version 4
+_require_command $NFS4_SETFACL_PROG "nfs4_setfacl"
+_require_command $NFS4_GETFACL_PROG "nfs4_getfacl"
+
+acltest=$TEST_DIR/acltest.$seq
+rm -f $acltest.*
+touch $acltest.file $acltest.list
+
+# Setup a carefully made ACE list to make attr buffer length is close enough to
+# PAGE_SIZE (size is 4088 in this case, and this only works for 4k page size)
+# that leaves too little room for adding extra attr bitmap in this page
+echo "A::OWNER@:RW" >$acltest.list
+for ((i=9802; i < 10002; i++)); do echo "A::$i:RW" >>$acltest.list; done
+echo "A::GROUP@:RW" >>$acltest.list
+echo "A::EVERYONE@:RW" >>$acltest.list
+
+# Save ACL to testfile
+$NFS4_SETFACL_PROG -S $acltest.list $acltest.file
+
+# Dump ACL, expect correct number of ACE entries
+$NFS4_GETFACL_PROG $acltest.file >>$seqres.full 2>&1
+$NFS4_GETFACL_PROG $acltest.file | wc -l
+
+# success, all done
+status=0
+exit
diff --git a/tests/nfs/001.out b/tests/nfs/001.out
new file mode 100644
index 0000000..741ade0
--- /dev/null
+++ b/tests/nfs/001.out
@@ -0,0 +1,2 @@
+QA output created by 001
+203
diff --git a/tests/nfs/Makefile b/tests/nfs/Makefile
new file mode 100644
index 0000000..754f2b2
--- /dev/null
+++ b/tests/nfs/Makefile
@@ -0,0 +1,20 @@
+#
+# Copyright (c) 2017 Red Hat, Inc.  All Rights Reserved.
+#
+
+TOPDIR = ../..
+include $(TOPDIR)/include/builddefs
+
+NFS_DIR = nfs
+TARGET_DIR = $(PKG_LIB_DIR)/$(TESTS_DIR)/$(NFS_DIR)
+
+include $(BUILDRULES)
+
+install:
+	$(INSTALL) -m 755 -d $(TARGET_DIR)
+	$(INSTALL) -m 755 $(TESTS) $(TARGET_DIR)
+	$(INSTALL) -m 644 group $(TARGET_DIR)
+	$(INSTALL) -m 644 $(OUTFILES) $(TARGET_DIR)
+
+# Nothing.
+install-dev install-lib:
diff --git a/tests/nfs/group b/tests/nfs/group
new file mode 100644
index 0000000..2619eae
--- /dev/null
+++ b/tests/nfs/group
@@ -0,0 +1,6 @@
+# QA groups control file
+# Defines test groups and nominal group owners
+# - do not start group names with a digit
+# - comment line before each group is "new" description
+#
+001 auto quick nfs4_acl acl
-- 
2.9.3

