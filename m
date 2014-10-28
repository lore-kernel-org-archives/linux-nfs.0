Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:45791 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752143AbaJ1NQy (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 28 Oct 2014 09:16:54 -0400
From: Eryu Guan <eguan@redhat.com>
To: fstests@vger.kernel.org
Cc: linux-nfs@vger.kernel.org, Eryu Guan <eguan@redhat.com>
Subject: [PATCH 1/4] common: re-enable tests that require scratch dev on NFS
Date: Tue, 28 Oct 2014 21:16:08 +0800
Message-Id: <1414502171-10319-2-git-send-email-eguan@redhat.com>
In-Reply-To: <1414502171-10319-1-git-send-email-eguan@redhat.com>
References: <1414502171-10319-1-git-send-email-eguan@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This commit disables tests requires scratch dev running on NFS

c041421 xfstests: stop special casing nfs and udf

Now re-enable them to get a larger test coverage on NFS.

Signed-off-by: Eryu Guan <eguan@redhat.com>
---
 common/rc | 16 +++++++++++++---
 1 file changed, 13 insertions(+), 3 deletions(-)

diff --git a/common/rc b/common/rc
index 747cf72..8738da7 100644
--- a/common/rc
+++ b/common/rc
@@ -558,7 +558,11 @@ _scratch_mkfs()
         _scratch_mkfs_xfs $*
 	;;
     nfs*)
-	# do nothing for nfs
+	# unable to re-create NFS, just remove all files in $SCRATCH_MNT to
+	# avoid EEXIST caused by the leftover files created in previous runs
+	_scratch_mount
+	rm -rf $SCRATCH_MNT/*
+	_scratch_unmount
 	;;
     cifs)
 	# do nothing for cifs
@@ -1032,8 +1036,14 @@ _require_scratch_nocheck()
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
1.8.3.1

