Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-vc0-f174.google.com ([209.85.220.174]:61101 "EHLO
	mail-vc0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755712Ab2KIUG5 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 9 Nov 2012 15:06:57 -0500
Received: by mail-vc0-f174.google.com with SMTP id fk26so4183151vcb.19
        for <linux-nfs@vger.kernel.org>; Fri, 09 Nov 2012 12:06:56 -0800 (PST)
From: Jeff Layton <jlayton@redhat.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH RFC 3/7] nfsd: break out reclaim record removal into separate function
Date: Fri,  9 Nov 2012 15:06:40 -0500
Message-Id: <1352491604-21605-4-git-send-email-jlayton@redhat.com>
In-Reply-To: <1352491604-21605-1-git-send-email-jlayton@redhat.com>
References: <1352491604-21605-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

We'll need to be able to call this from nfs4recover.c eventually.

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 fs/nfsd/nfs4state.c | 12 +++++++++---
 fs/nfsd/state.h     |  1 +
 2 files changed, 10 insertions(+), 3 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index d12f10e..28664de 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -4498,6 +4498,14 @@ nfs4_client_to_reclaim(const char *name)
 }
 
 void
+nfs4_remove_reclaim_record(struct nfs4_client_reclaim *crp)
+{
+	list_del(&crp->cr_strhash);
+	kfree(crp);
+	reclaim_str_hashtbl_size--;
+}
+
+void
 nfs4_release_reclaim(void)
 {
 	struct nfs4_client_reclaim *crp = NULL;
@@ -4507,9 +4515,7 @@ nfs4_release_reclaim(void)
 		while (!list_empty(&reclaim_str_hashtbl[i])) {
 			crp = list_entry(reclaim_str_hashtbl[i].next,
 			                struct nfs4_client_reclaim, cr_strhash);
-			list_del(&crp->cr_strhash);
-			kfree(crp);
-			reclaim_str_hashtbl_size--;
+			nfs4_remove_reclaim_record(crp);
 		}
 	}
 	BUG_ON(reclaim_str_hashtbl_size);
diff --git a/fs/nfsd/state.h b/fs/nfsd/state.h
index ec01d45..8983169 100644
--- a/fs/nfsd/state.h
+++ b/fs/nfsd/state.h
@@ -453,6 +453,7 @@ extern __be32 nfs4_preprocess_stateid_op(struct net *net,
 extern void nfs4_lock_state(void);
 extern void nfs4_unlock_state(void);
 extern int nfs4_in_grace(void);
+void nfs4_remove_reclaim_record(struct nfs4_client_reclaim *);
 extern void nfs4_release_reclaim(void);
 extern struct nfs4_client_reclaim *nfsd4_find_reclaim_client(const char *recdir);
 extern __be32 nfs4_check_open_reclaim(clientid_t *clid, bool sessions);
-- 
1.7.11.7

