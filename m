Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:48128 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754638AbcHBSi5 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 2 Aug 2016 14:38:57 -0400
From: Jeff Layton <jlayton@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: bfields@fieldses.org
Subject: [RFC PATCH 4/4] nfsd: set the MAY_NOTIFY_LOCK flag in OPEN replies
Date: Tue,  2 Aug 2016 14:15:31 -0400
Message-Id: <1470161731-11301-5-git-send-email-jlayton@redhat.com>
In-Reply-To: <1470161731-11301-1-git-send-email-jlayton@redhat.com>
References: <1470161731-11301-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

If we are using v4.1+, then we can send notification when contended
locks become free. Inform the client of that fact.

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 fs/nfsd/nfs4state.c       | 6 ++++--
 include/uapi/linux/nfs4.h | 5 +++--
 2 files changed, 7 insertions(+), 4 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 6a81e6b86438..3cfb4c326060 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -4493,9 +4493,11 @@ out:
 	* To finish the open response, we just need to set the rflags.
 	*/
 	open->op_rflags = NFS4_OPEN_RESULT_LOCKTYPE_POSIX;
-	if (!(open->op_openowner->oo_flags & NFS4_OO_CONFIRMED) &&
-	    !nfsd4_has_session(&resp->cstate))
+	if (nfsd4_has_session(&resp->cstate))
+		open->op_rflags |= NFS4_OPEN_RESULT_MAY_NOTIFY_LOCK;
+	else if (!(open->op_openowner->oo_flags & NFS4_OO_CONFIRMED))
 		open->op_rflags |= NFS4_OPEN_RESULT_CONFIRM;
+
 	if (dp)
 		nfs4_put_stid(&dp->dl_stid);
 	if (stp)
diff --git a/include/uapi/linux/nfs4.h b/include/uapi/linux/nfs4.h
index 2b871e0858d9..4ae62796bfde 100644
--- a/include/uapi/linux/nfs4.h
+++ b/include/uapi/linux/nfs4.h
@@ -39,8 +39,9 @@
 #define NFS4_FH_VOL_MIGRATION		0x0004
 #define NFS4_FH_VOL_RENAME		0x0008
 
-#define NFS4_OPEN_RESULT_CONFIRM 0x0002
-#define NFS4_OPEN_RESULT_LOCKTYPE_POSIX 0x0004
+#define NFS4_OPEN_RESULT_CONFIRM		0x0002
+#define NFS4_OPEN_RESULT_LOCKTYPE_POSIX		0x0004
+#define NFS4_OPEN_RESULT_MAY_NOTIFY_LOCK	0x0020
 
 #define NFS4_SHARE_ACCESS_MASK	0x000F
 #define NFS4_SHARE_ACCESS_READ	0x0001
-- 
2.7.4

