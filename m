Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-vb0-f46.google.com ([209.85.212.46]:43164 "EHLO
	mail-vb0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755681Ab2KIUGz (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 9 Nov 2012 15:06:55 -0500
Received: by mail-vb0-f46.google.com with SMTP id ff1so4276477vbb.19
        for <linux-nfs@vger.kernel.org>; Fri, 09 Nov 2012 12:06:54 -0800 (PST)
From: Jeff Layton <jlayton@redhat.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH RFC 2/7] nfsd: have nfsd4_find_reclaim_client take a char * argument
Date: Fri,  9 Nov 2012 15:06:39 -0500
Message-Id: <1352491604-21605-3-git-send-email-jlayton@redhat.com>
In-Reply-To: <1352491604-21605-1-git-send-email-jlayton@redhat.com>
References: <1352491604-21605-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Currently, it takes a client pointer, but later we're going to need to
search for these records without knowing whether a matching client even
exists.

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 fs/nfsd/nfs4recover.c |  2 +-
 fs/nfsd/nfs4state.c   | 11 ++++-------
 fs/nfsd/state.h       |  2 +-
 3 files changed, 6 insertions(+), 9 deletions(-)

diff --git a/fs/nfsd/nfs4recover.c b/fs/nfsd/nfs4recover.c
index 10b7f47..df582fa 100644
--- a/fs/nfsd/nfs4recover.c
+++ b/fs/nfsd/nfs4recover.c
@@ -485,7 +485,7 @@ nfsd4_check_legacy_client(struct nfs4_client *clp)
 		return 0;
 
 	/* look for it in the reclaim hashtable otherwise */
-	if (nfsd4_find_reclaim_client(clp)) {
+	if (nfsd4_find_reclaim_client(clp->cl_recdir)) {
 		set_bit(NFSD4_CLIENT_STABLE, &clp->cl_flags);
 		return 0;
 	}
diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index f15a2a0..d12f10e 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -4518,19 +4518,16 @@ nfs4_release_reclaim(void)
 /*
  * called from OPEN, CLAIM_PREVIOUS with a new clientid. */
 struct nfs4_client_reclaim *
-nfsd4_find_reclaim_client(struct nfs4_client *clp)
+nfsd4_find_reclaim_client(const char *recdir)
 {
 	unsigned int strhashval;
 	struct nfs4_client_reclaim *crp = NULL;
 
-	dprintk("NFSD: nfs4_find_reclaim_client for %.*s with recdir %s\n",
-		            clp->cl_name.len, clp->cl_name.data,
-			    clp->cl_recdir);
+	dprintk("NFSD: nfs4_find_reclaim_client for recdir %s\n", recdir);
 
-	/* find clp->cl_name in reclaim_str_hashtbl */
-	strhashval = clientstr_hashval(clp->cl_recdir);
+	strhashval = clientstr_hashval(recdir);
 	list_for_each_entry(crp, &reclaim_str_hashtbl[strhashval], cr_strhash) {
-		if (same_name(crp->cr_recdir, clp->cl_recdir)) {
+		if (same_name(crp->cr_recdir, recdir)) {
 			return crp;
 		}
 	}
diff --git a/fs/nfsd/state.h b/fs/nfsd/state.h
index bd734f0..ec01d45 100644
--- a/fs/nfsd/state.h
+++ b/fs/nfsd/state.h
@@ -454,7 +454,7 @@ extern void nfs4_lock_state(void);
 extern void nfs4_unlock_state(void);
 extern int nfs4_in_grace(void);
 extern void nfs4_release_reclaim(void);
-extern struct nfs4_client_reclaim *nfsd4_find_reclaim_client(struct nfs4_client *crp);
+extern struct nfs4_client_reclaim *nfsd4_find_reclaim_client(const char *recdir);
 extern __be32 nfs4_check_open_reclaim(clientid_t *clid, bool sessions);
 extern void nfs4_free_openowner(struct nfs4_openowner *);
 extern void nfs4_free_lockowner(struct nfs4_lockowner *);
-- 
1.7.11.7

