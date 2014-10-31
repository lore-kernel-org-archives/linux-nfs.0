Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:53560 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751798AbaJaREY (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 31 Oct 2014 13:04:24 -0400
From: Eryu Guan <eguan@redhat.com>
To: fstests@vger.kernel.org
Cc: linux-nfs@vger.kernel.org, Eryu Guan <eguan@redhat.com>
Subject: [PATCH v2 1/5] common: re-enable tests that require scratch dev on NFS
Date: Sat,  1 Nov 2014 01:03:56 +0800
Message-Id: <1414775040-4051-2-git-send-email-eguan@redhat.com>
In-Reply-To: <1414775040-4051-1-git-send-email-eguan@redhat.com>
References: <1414775040-4051-1-git-send-email-eguan@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This commit disables tests requires scratch dev running on NFS

c041421 xfstests: stop special casing nfs and udf

Now re-enable them to get a larger test coverage on NFS.

Signed-off-by: Eryu Guan <eguan@redhat.com>
---
 common/rc | 22 +++++++++++++++++++---
 1 file changed, 19 insertions(+), 3 deletions(-)

diff --git a/common/rc b/common/rc
index 747cf72..ae03712 100644
--- a/common/rc
+++ b/common/rc
@@ -551,6 +551,14 @@ _mkfs_dev()
     rm -f $tmp_dir.mkfserr $tmp_dir.mkfsstd
 }
 
+# remove all files in $SCRATCH_MNT, useful when testing on NFS/CIFS
+_scratch_cleanup_files()
+{
+	_scratch_mount
+	rm -rf $SCRATCH_MNT/*
+	_scratch_unmount
+}
+
 _scratch_mkfs()
 {
     case $FSTYP in
@@ -558,7 +566,9 @@ _scratch_mkfs()
         _scratch_mkfs_xfs $*
 	;;
     nfs*)
-	# do nothing for nfs
+	# unable to re-create NFS, just remove all files in $SCRATCH_MNT to
+	# avoid EEXIST caused by the leftover files created in previous runs
+        _scratch_cleanup_files
 	;;
     cifs)
 	# do nothing for cifs
@@ -1032,8 +1042,14 @@ _require_scratch_nocheck()
 {
     case "$FSTYP" in
 	nfs*)
-                 _notrun "requires a scratch device"
-		 ;;
+		echo $SCRATCH_DEV | grep -q ":/" > /dev/null 2>&1
+		if [ -z "$SCRATCH_DEV" -o "$?" != "0" ]; then
+			_notrun "this test requires a valid \$SCRATCH_DEV"
+		fi
+		if [ ! -d "$SCRATCH_MNT" ]; then
+			_notrun "this test requires a valid \$SCRATCH_MNT"
+		fi
+		;;
 	cifs)
 		_notrun "requires a scratch device"
 		;;
-- 
1.9.3

