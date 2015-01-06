Return-Path: linux-nfs-owner@vger.kernel.org
Received: from casper.infradead.org ([85.118.1.10]:55221 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755860AbbAFQ3j (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 6 Jan 2015 11:29:39 -0500
From: Christoph Hellwig <hch@lst.de>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Jeff Layton <jlayton@primarydata.com>, linux-nfs@vger.kernel.org,
        linux-fsdevel@vger.kernel.org, xfs@oss.sgi.com
Subject: [PATCH 06/18] nfsd: make lookup/alloc/unhash_stid available outside nfs4state.c
Date: Tue,  6 Jan 2015 17:28:29 +0100
Message-Id: <1420561721-9150-7-git-send-email-hch@lst.de>
In-Reply-To: <1420561721-9150-1-git-send-email-hch@lst.de>
References: <1420561721-9150-1-git-send-email-hch@lst.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 fs/nfsd/nfs4state.c | 8 ++++----
 fs/nfsd/state.h     | 6 ++++++
 2 files changed, 10 insertions(+), 4 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index aaa3f8e..e804e9b 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -486,7 +486,7 @@ static void nfs4_file_put_access(struct nfs4_file *fp, u32 access)
 		__nfs4_file_put_access(fp, O_RDONLY);
 }
 
-static struct nfs4_stid *nfs4_alloc_stid(struct nfs4_client *cl,
+struct nfs4_stid *nfs4_alloc_stid(struct nfs4_client *cl,
 					 struct kmem_cache *slab)
 {
 	struct nfs4_stid *stid;
@@ -690,7 +690,7 @@ static void nfs4_put_deleg_lease(struct nfs4_file *fp)
 	}
 }
 
-static void unhash_stid(struct nfs4_stid *s)
+void nfs4_unhash_stid(struct nfs4_stid *s)
 {
 	s->sc_type = 0;
 }
@@ -998,7 +998,7 @@ static void unhash_lock_stateid(struct nfs4_ol_stateid *stp)
 
 	list_del_init(&stp->st_locks);
 	unhash_ol_stateid(stp);
-	unhash_stid(&stp->st_stid);
+	nfs4_unhash_stid(&stp->st_stid);
 }
 
 static void release_lock_stateid(struct nfs4_ol_stateid *stp)
@@ -4437,7 +4437,7 @@ out_unlock:
 	return status;
 }
 
-static __be32
+__be32
 nfsd4_lookup_stateid(struct nfsd4_compound_state *cstate,
 		     stateid_t *stateid, unsigned char typemask,
 		     struct nfs4_stid **s, struct nfsd_net *nn)
diff --git a/fs/nfsd/state.h b/fs/nfsd/state.h
index dab6553..55a3ece 100644
--- a/fs/nfsd/state.h
+++ b/fs/nfsd/state.h
@@ -545,6 +545,12 @@ struct nfsd_net;
 extern __be32 nfs4_preprocess_stateid_op(struct net *net,
 		struct nfsd4_compound_state *cstate,
 		stateid_t *stateid, int flags, struct file **filp);
+__be32 nfsd4_lookup_stateid(struct nfsd4_compound_state *cstate,
+		     stateid_t *stateid, unsigned char typemask,
+		     struct nfs4_stid **s, struct nfsd_net *nn);
+struct nfs4_stid *nfs4_alloc_stid(struct nfs4_client *cl,
+		struct kmem_cache *slab);
+void nfs4_unhash_stid(struct nfs4_stid *s);
 void nfs4_put_stid(struct nfs4_stid *s);
 void nfs4_remove_reclaim_record(struct nfs4_client_reclaim *, struct nfsd_net *);
 extern void nfs4_release_reclaim(struct nfsd_net *);
-- 
1.9.1

