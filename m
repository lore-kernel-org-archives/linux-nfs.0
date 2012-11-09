Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-vc0-f174.google.com ([209.85.220.174]:61101 "EHLO
	mail-vc0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755367Ab2KIUG6 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 9 Nov 2012 15:06:58 -0500
Received: by mail-vc0-f174.google.com with SMTP id fk26so4183151vcb.19
        for <linux-nfs@vger.kernel.org>; Fri, 09 Nov 2012 12:06:58 -0800 (PST)
From: Jeff Layton <jlayton@redhat.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH RFC 4/7] nfsd: make nfs4_client_to_reclaim return a pointer to the reclaim record
Date: Fri,  9 Nov 2012 15:06:41 -0500
Message-Id: <1352491604-21605-5-git-send-email-jlayton@redhat.com>
In-Reply-To: <1352491604-21605-1-git-send-email-jlayton@redhat.com>
References: <1352491604-21605-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Later callers will need to make changes to the record.

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 fs/nfsd/nfs4state.c | 8 ++++----
 fs/nfsd/state.h     | 2 +-
 2 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 28664de..23947b3 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -4479,22 +4479,22 @@ nfs4_has_reclaimed_state(const char *name)
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
 	if (!crp)
-		return 0;
+		return crp;
 	strhashval = clientstr_hashval(name);
 	INIT_LIST_HEAD(&crp->cr_strhash);
 	list_add(&crp->cr_strhash, &reclaim_str_hashtbl[strhashval]);
 	memcpy(crp->cr_recdir, name, HEXDIR_LEN);
 	reclaim_str_hashtbl_size++;
-	return 1;
+	return crp;
 }
 
 void
diff --git a/fs/nfsd/state.h b/fs/nfsd/state.h
index 8983169..7b9e656 100644
--- a/fs/nfsd/state.h
+++ b/fs/nfsd/state.h
@@ -470,7 +470,7 @@ extern void nfsd4_destroy_callback_queue(void);
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

