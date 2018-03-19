Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:41692 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1755760AbeCSOgq (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 19 Mar 2018 10:36:46 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org
Cc: "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 06/10] nfsd: make nfs4_get_existing_delegation less confusing
Date: Mon, 19 Mar 2018 10:36:30 -0400
Message-Id: <1521470194-24840-7-git-send-email-bfields@redhat.com>
In-Reply-To: <1521470194-24840-1-git-send-email-bfields@redhat.com>
References: <1521470194-24840-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: "J. Bruce Fields" <bfields@redhat.com>

This doesn't "get" anything.

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/nfsd/nfs4state.c | 23 +++++++++--------------
 1 file changed, 9 insertions(+), 14 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 3fc0682ca799..b49000797c6f 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -870,20 +870,16 @@ void nfs4_unhash_stid(struct nfs4_stid *s)
 }
 
 /**
- * nfs4_get_existing_delegation - Discover if this delegation already exists
+ * nfs4_delegation_exists - Discover if this delegation already exists
  * @clp:     a pointer to the nfs4_client we're granting a delegation to
  * @fp:      a pointer to the nfs4_file we're granting a delegation on
  *
  * Return:
- *      On success: NULL if an existing delegation was not found.
- *
- *      On error: -EAGAIN if one was previously granted to this nfs4_client
- *                 for this nfs4_file.
- *
+ *      On success: true iff an existing delegation is found
  */
 
-static int
-nfs4_get_existing_delegation(struct nfs4_client *clp, struct nfs4_file *fp)
+static bool
+nfs4_delegation_exists(struct nfs4_client *clp, struct nfs4_file *fp)
 {
 	struct nfs4_delegation *searchdp = NULL;
 	struct nfs4_client *searchclp = NULL;
@@ -916,15 +912,13 @@ nfs4_get_existing_delegation(struct nfs4_client *clp, struct nfs4_file *fp)
 static int
 hash_delegation_locked(struct nfs4_delegation *dp, struct nfs4_file *fp)
 {
-	int status;
 	struct nfs4_client *clp = dp->dl_stid.sc_client;
 
 	lockdep_assert_held(&state_lock);
 	lockdep_assert_held(&fp->fi_lock);
 
-	status = nfs4_get_existing_delegation(clp, fp);
-	if (status)
-		return status;
+	if (nfs4_delegation_exists(clp, fp))
+		return -EAGAIN;
 	++fp->fi_delegees;
 	refcount_inc(&dp->dl_stid.sc_count);
 	dp->dl_stid.sc_type = NFS4_DELEG_STID;
@@ -4343,7 +4337,7 @@ static struct nfs4_delegation *
 nfs4_set_delegation(struct nfs4_client *clp, struct svc_fh *fh,
 		    struct nfs4_file *fp, struct nfs4_clnt_odstate *odstate)
 {
-	int status;
+	int status = 0;
 	struct nfs4_delegation *dp;
 
 	if (fp->fi_had_conflict)
@@ -4351,7 +4345,8 @@ nfs4_set_delegation(struct nfs4_client *clp, struct svc_fh *fh,
 
 	spin_lock(&state_lock);
 	spin_lock(&fp->fi_lock);
-	status = nfs4_get_existing_delegation(clp, fp);
+	if (nfs4_delegation_exists(clp, fp))
+		status = -EAGAIN;
 	spin_unlock(&fp->fi_lock);
 	spin_unlock(&state_lock);
 
-- 
2.14.3

