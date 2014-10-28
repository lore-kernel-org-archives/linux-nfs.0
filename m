Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:35061 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752399AbaJ1NQ5 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 28 Oct 2014 09:16:57 -0400
From: Eryu Guan <eguan@redhat.com>
To: fstests@vger.kernel.org
Cc: linux-nfs@vger.kernel.org, Eryu Guan <eguan@redhat.com>
Subject: [PATCH 3/4] common: skip atime related tests on NFS
Date: Tue, 28 Oct 2014 21:16:10 +0800
Message-Id: <1414502171-10319-4-git-send-email-eguan@redhat.com>
In-Reply-To: <1414502171-10319-1-git-send-email-eguan@redhat.com>
References: <1414502171-10319-1-git-send-email-eguan@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

>From nfs(5) we can know that atime related mount options have no effect
on NFS mounts, so add _require_atime() helper to skip atime tests on NFS

Also change the way how _require_relatime() mount $SCRATCH_DEV, use
_scratch_mount helper so it's mounted with selinux context, to avoid
"same superblock, different selinux context" failure.

Signed-off-by: Eryu Guan <eguan@redhat.com>
---
 common/rc         | 9 ++++++++-
 tests/generic/003 | 1 +
 tests/generic/192 | 1 +
 3 files changed, 10 insertions(+), 1 deletion(-)

diff --git a/common/rc b/common/rc
index 42f00cb..b50577f 100644
--- a/common/rc
+++ b/common/rc
@@ -2379,10 +2379,17 @@ _verify_reflink()
                || echo "$1 and $2 are not reflinks: different extents"
 }
 
+_require_atime()
+{
+	if [ "$FSTYP" == "nfs" ]; then
+		_notrun "atime related mount options have no effect on NFS"
+	fi
+}
+
 _require_relatime()
 {
         _scratch_mkfs > /dev/null 2>&1
-        _mount -t $FSTYP -o relatime $SCRATCH_DEV $SCRATCH_MNT || \
+        _scratch_mount -o relatime || \
                 _notrun "relatime not supported by the current kernel"
 	_scratch_unmount
 }
diff --git a/tests/generic/003 b/tests/generic/003
index 83d6f90..7ffd09a 100755
--- a/tests/generic/003
+++ b/tests/generic/003
@@ -47,6 +47,7 @@ _cleanup()
 _supported_fs generic
 _supported_os Linux
 _require_scratch
+_require_atime
 _require_relatime
 
 rm -f $seqres.full
diff --git a/tests/generic/192 b/tests/generic/192
index b2da358..5b6cfbc 100755
--- a/tests/generic/192
+++ b/tests/generic/192
@@ -54,6 +54,7 @@ is_noatime_set() {
 _supported_fs generic
 _supported_os Linux
 _require_test
+_require_atime
 #delay=150
 #delay=75
 #delay=60
-- 
1.8.3.1

