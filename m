Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:56408 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753565AbcIFPEx (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 6 Sep 2016 11:04:53 -0400
From: Jeff Layton <jlayton@redhat.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH v2 4/4] nfsd: set the MAY_NOTIFY_LOCK flag in OPEN replies
Date: Tue,  6 Sep 2016 11:04:50 -0400
Message-Id: <1473174290-29612-5-git-send-email-jlayton@redhat.com>
In-Reply-To: <1473174290-29612-1-git-send-email-jlayton@redhat.com>
References: <1473174290-29612-1-git-send-email-jlayton@redhat.com>
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
index 6c74d9a45163..4062f4fbfc6d 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -4490,9 +4490,11 @@ out:
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

