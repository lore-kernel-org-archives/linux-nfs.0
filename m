Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:55714 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S965082AbcIPU2c (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 16 Sep 2016 16:28:32 -0400
From: Jeff Layton <jlayton@redhat.com>
To: bfields@fieldses.org
Cc: trond.myklebust@primarydata.com, anna.schumaker@netapp.com,
        linux-nfs@vger.kernel.org
Subject: [PATCH v3 5/5] nfsd: set the MAY_NOTIFY_LOCK flag in OPEN replies
Date: Fri, 16 Sep 2016 16:28:27 -0400
Message-Id: <1474057707-31286-6-git-send-email-jlayton@redhat.com>
In-Reply-To: <1474057707-31286-1-git-send-email-jlayton@redhat.com>
References: <1474057707-31286-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

If we are using v4.1+, then we can send notification when contended
locks become free. Inform the client of that fact.

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 fs/nfsd/nfs4state.c | 6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

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
-- 
2.7.4

