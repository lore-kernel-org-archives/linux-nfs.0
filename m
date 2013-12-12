Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mout.gmx.net ([212.227.15.15]:59460 "EHLO mout.gmx.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750840Ab3LLSJB (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 12 Dec 2013 13:09:01 -0500
Received: from n22.fritz.box ([85.177.144.142]) by mail.gmx.com (mrgmx103)
 with ESMTPSA (Nemesis) id 0MUpI8-1W397f2UCi-00YBdC for
 <linux-nfs@vger.kernel.org>; Thu, 12 Dec 2013 19:08:59 +0100
From: =?UTF-8?q?Toralf=20F=C3=B6rster?= <toralf.foerster@gmx.de>
To: linux-nfs@vger.kernel.org
Cc: toralf.foerster@gmx.de
Subject: [PATCH] point to the right include file in a comment (left over from a9004abc3)
Date: Thu, 12 Dec 2013 19:09:00 +0100
Message-Id: <1386871740-7253-1-git-send-email-toralf.foerster@gmx.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Toralf Förster <toralf.foerster@gmx.de>
---
 fs/nfs/nfs4state.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/nfs4state.c b/fs/nfs/nfs4state.c
index 059c01b..e5be725 100644
--- a/fs/nfs/nfs4state.c
+++ b/fs/nfs/nfs4state.c
@@ -1071,7 +1071,7 @@ void nfs_free_seqid(struct nfs_seqid *seqid)
 /*
  * Increment the seqid if the OPEN/OPEN_DOWNGRADE/CLOSE succeeded, or
  * failed with a seqid incrementing error -
- * see comments nfs_fs.h:seqid_mutating_error()
+ * see comments nfs4.h:seqid_mutating_error()
  */
 static void nfs_increment_seqid(int status, struct nfs_seqid *seqid)
 {
@@ -1116,7 +1116,7 @@ void nfs_increment_open_seqid(int status, struct nfs_seqid *seqid)
 /*
  * Increment the seqid if the LOCK/LOCKU succeeded, or
  * failed with a seqid incrementing error -
- * see comments nfs_fs.h:seqid_mutating_error()
+ * see comments nfs4.h:seqid_mutating_error()
  */
 void nfs_increment_lock_seqid(int status, struct nfs_seqid *seqid)
 {
-- 
1.8.3.2

