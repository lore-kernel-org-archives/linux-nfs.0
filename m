Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-vb0-f46.google.com ([209.85.212.46]:59742 "EHLO
	mail-vb0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752395Ab2KLUBQ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 12 Nov 2012 15:01:16 -0500
Received: by mail-vb0-f46.google.com with SMTP id ff1so6652181vbb.19
        for <linux-nfs@vger.kernel.org>; Mon, 12 Nov 2012 12:01:16 -0800 (PST)
From: Jeff Layton <jlayton@redhat.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH 07/11] nfsd: make nfs4_client_to_reclaim return a pointer to the reclaim record
Date: Mon, 12 Nov 2012 15:00:54 -0500
Message-Id: <1352750458-16857-8-git-send-email-jlayton@redhat.com>
In-Reply-To: <1352750458-16857-1-git-send-email-jlayton@redhat.com>
References: <1352750458-16857-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Later callers will need to make changes to the record.

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 fs/nfsd/nfs4state.c | 20 ++++++++++----------
 fs/nfsd/state.h     |  2 +-
 2 files changed, 11 insertions(+), 11 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 24dcda2..1c6f82e 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -4498,22 +4498,22 @@ nfs4_has_reclaimed_state(const char *name)
 /*
  * failure => all reset bets are off, nfserr_no_grace...
  */
-int
+struct nfs4_client_reclaim *
 nfs4_client_to_reclaim(const char *name)
 {
 	unsigned int strhashval;
-	struct nfs4_client_reclaim *crp = NULL;
+	struct nfs4_client_reclaim *crp;
 
 	dprintk("NFSD nfs4_client_to_reclaim NAME: %.*s\n", HEXDIR_LEN, name);
 	crp = alloc_reclaim();
-	if (!crp)
-		return 0;
-	strhashval = clientstr_hashval(name);
-	INIT_LIST_HEAD(&crp->cr_strhash);
-	list_add(&crp->cr_strhash, &reclaim_str_hashtbl[strhashval]);
-	memcpy(crp->cr_recdir, name, HEXDIR_LEN);
-	reclaim_str_hashtbl_size++;
-	return 1;
+	if (crp) {
+		strhashval = clientstr_hashval(name);
+		INIT_LIST_HEAD(&crp->cr_strhash);
+		list_add(&crp->cr_strhash, &reclaim_str_hashtbl[strhashval]);
+		memcpy(crp->cr_recdir, name, HEXDIR_LEN);
+		reclaim_str_hashtbl_size++;
+	}
+	return crp;
 }
 
 void
diff --git a/fs/nfsd/state.h b/fs/nfsd/state.h
index 3528616..3f8b26b 100644
--- a/fs/nfsd/state.h
+++ b/fs/nfsd/state.h
@@ -482,7 +482,7 @@ extern void nfsd4_destroy_callback_queue(void);
 extern void nfsd4_shutdown_callback(struct nfs4_client *);
 extern void nfs4_put_delegation(struct nfs4_delegation *dp);
 extern __be32 nfs4_make_rec_clidname(char *clidname, struct xdr_netobj *clname);
-extern int nfs4_client_to_reclaim(const char *name);
+extern struct nfs4_client_reclaim *nfs4_client_to_reclaim(const char *name);
 extern int nfs4_has_reclaimed_state(const char *name);
 extern void release_session_client(struct nfsd4_session *);
 extern void nfsd4_purge_closed_stateid(struct nfs4_stateowner *);
-- 
1.7.11.7

