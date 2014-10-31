Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:49646 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751211AbaJaREa (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 31 Oct 2014 13:04:30 -0400
From: Eryu Guan <eguan@redhat.com>
To: fstests@vger.kernel.org
Cc: linux-nfs@vger.kernel.org, Eryu Guan <eguan@redhat.com>
Subject: [PATCH v2 3/5] common: skip atime related tests on NFS
Date: Sat,  1 Nov 2014 01:03:58 +0800
Message-Id: <1414775040-4051-4-git-send-email-eguan@redhat.com>
In-Reply-To: <1414775040-4051-1-git-send-email-eguan@redhat.com>
References: <1414775040-4051-1-git-send-email-eguan@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

>From nfs(5) we can know that atime related mount options have no effect
on NFS mounts, so add _require_atime() helper to skip atime tests on NFS

Signed-off-by: Eryu Guan <eguan@redhat.com>
---
 common/rc         | 7 +++++++
 tests/generic/003 | 1 +
 tests/generic/192 | 1 +
 3 files changed, 9 insertions(+)

diff --git a/common/rc b/common/rc
index ca8c4a2..2d2b40f 100644
--- a/common/rc
+++ b/common/rc
@@ -2385,6 +2385,13 @@ _verify_reflink()
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
1.9.3

