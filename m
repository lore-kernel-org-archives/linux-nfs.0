Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-la0-f45.google.com ([209.85.215.45]:62559 "EHLO
	mail-la0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755543AbaHFMBd (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 6 Aug 2014 08:01:33 -0400
From: Pavel Shilovsky <pshilovsky@samba.org>
To: Steve Dickson <SteveD@redhat.com>
Cc: linux-cifs@vger.kernel.org, linux-nfs@vger.kernel.org,
        Jeff Layton <jlayton@samba.org>
Subject: [PATCH 4/5] Add SMB/CIFS section in tests.init
Date: Wed,  6 Aug 2014 16:01:11 +0400
Message-Id: <1407326472-13853-5-git-send-email-pshilovsky@samba.org>
In-Reply-To: <1407326472-13853-1-git-send-email-pshilovsky@samba.org>
References: <1407326472-13853-1-git-send-email-pshilovsky@samba.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

---
 tests.init | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/tests.init b/tests.init
index 4d16e1b..4b574fc 100644
--- a/tests.init
+++ b/tests.init
@@ -33,6 +33,10 @@ MOUNTCMD='./domount -o $MNTOPTIONS $SERVER\:$SERVPATH $MNTPOINT'
 #	DG/UX
 #MOUNTCMD='./domount -t nfs -o $MNTOPTIONS $SERVER\:$SERVPATH $MNTPOINT'
 
+# Use this mount command if using:
+#	SMB/CIFS
+#MOUNTCMD='./domount -t cifs -o $MNTOPTIONS //$SERVER/$SERVPATH $MNTPOINT'
+
 UMOUNTCMD='./domount -u $MNTPOINT'
 
 # Use the next two lines if using:
-- 
1.8.1.2

