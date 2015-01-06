Return-Path: linux-nfs-owner@vger.kernel.org
Received: from casper.infradead.org ([85.118.1.10]:55225 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755861AbbAFQ3k (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 6 Jan 2015 11:29:40 -0500
From: Christoph Hellwig <hch@lst.de>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Jeff Layton <jlayton@primarydata.com>, linux-nfs@vger.kernel.org,
        linux-fsdevel@vger.kernel.org, xfs@oss.sgi.com
Subject: [PATCH 07/18] nfsd: make find/get/put file available outside nfs4state.c
Date: Tue,  6 Jan 2015 17:28:30 +0100
Message-Id: <1420561721-9150-8-git-send-email-hch@lst.de>
In-Reply-To: <1420561721-9150-1-git-send-email-hch@lst.de>
References: <1420561721-9150-1-git-send-email-hch@lst.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 fs/nfsd/nfs4state.c | 10 ++--------
 fs/nfsd/state.h     |  7 +++++++
 2 files changed, 9 insertions(+), 8 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index e804e9b..b2054d4 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -282,7 +282,7 @@ static void nfsd4_free_file_rcu(struct rcu_head *rcu)
 	kmem_cache_free(file_slab, fp);
 }
 
-static inline void
+void
 put_nfs4_file(struct nfs4_file *fi)
 {
 	might_lock(&state_lock);
@@ -295,12 +295,6 @@ put_nfs4_file(struct nfs4_file *fi)
 	}
 }
 
-static inline void
-get_nfs4_file(struct nfs4_file *fi)
-{
-	atomic_inc(&fi->fi_ref);
-}
-
 static struct file *
 __nfs4_get_fd(struct nfs4_file *f, int oflag)
 {
@@ -3300,7 +3294,7 @@ find_file_locked(struct knfsd_fh *fh, unsigned int hashval)
 	return NULL;
 }
 
-static struct nfs4_file *
+struct nfs4_file *
 find_file(struct knfsd_fh *fh)
 {
 	struct nfs4_file *fp;
diff --git a/fs/nfsd/state.h b/fs/nfsd/state.h
index 55a3ece..8bc961e 100644
--- a/fs/nfsd/state.h
+++ b/fs/nfsd/state.h
@@ -573,6 +573,13 @@ extern struct nfs4_client_reclaim *nfs4_client_to_reclaim(const char *name,
 							struct nfsd_net *nn);
 extern bool nfs4_has_reclaimed_state(const char *name, struct nfsd_net *nn);
 
+struct nfs4_file *find_file(struct knfsd_fh *fh);
+void put_nfs4_file(struct nfs4_file *fi);
+static inline void get_nfs4_file(struct nfs4_file *fi)
+{
+	atomic_inc(&fi->fi_ref);
+}
+
 /* grace period management */
 void nfsd4_end_grace(struct nfsd_net *nn);
 
-- 
1.9.1

