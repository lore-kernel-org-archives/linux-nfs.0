Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f193.google.com ([209.85.223.193]:36035 "EHLO
	mail-io0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932174AbcGFWav (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 6 Jul 2016 18:30:51 -0400
Received: by mail-io0-f193.google.com with SMTP id l202so634304ioe.3
        for <linux-nfs@vger.kernel.org>; Wed, 06 Jul 2016 15:30:50 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH v4 14/28] NFS: Fix O_DIRECT verifier problems
Date: Wed,  6 Jul 2016 18:29:51 -0400
Message-Id: <1467844205-76852-15-git-send-email-trond.myklebust@primarydata.com>
In-Reply-To: <1467844205-76852-14-git-send-email-trond.myklebust@primarydata.com>
References: <1467844205-76852-1-git-send-email-trond.myklebust@primarydata.com>
 <1467844205-76852-2-git-send-email-trond.myklebust@primarydata.com>
 <1467844205-76852-3-git-send-email-trond.myklebust@primarydata.com>
 <1467844205-76852-4-git-send-email-trond.myklebust@primarydata.com>
 <1467844205-76852-5-git-send-email-trond.myklebust@primarydata.com>
 <1467844205-76852-6-git-send-email-trond.myklebust@primarydata.com>
 <1467844205-76852-7-git-send-email-trond.myklebust@primarydata.com>
 <1467844205-76852-8-git-send-email-trond.myklebust@primarydata.com>
 <1467844205-76852-9-git-send-email-trond.myklebust@primarydata.com>
 <1467844205-76852-10-git-send-email-trond.myklebust@primarydata.com>
 <1467844205-76852-11-git-send-email-trond.myklebust@primarydata.com>
 <1467844205-76852-12-git-send-email-trond.myklebust@primarydata.com>
 <1467844205-76852-13-git-send-email-trond.myklebust@primarydata.com>
 <1467844205-76852-14-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

We should not be interested in looking at the value of the stable field,
since that could take any value.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/direct.c   | 10 ++++++++--
 fs/nfs/internal.h |  7 +++++++
 fs/nfs/write.c    |  2 +-
 3 files changed, 16 insertions(+), 3 deletions(-)

diff --git a/fs/nfs/direct.c b/fs/nfs/direct.c
index 979b3c4dee6a..d6d43b5eafb3 100644
--- a/fs/nfs/direct.c
+++ b/fs/nfs/direct.c
@@ -196,6 +196,12 @@ static void nfs_direct_set_hdr_verf(struct nfs_direct_req *dreq,
 	WARN_ON_ONCE(verfp->committed < 0);
 }
 
+static int nfs_direct_cmp_verf(const struct nfs_writeverf *v1,
+		const struct nfs_writeverf *v2)
+{
+	return nfs_write_verifier_cmp(&v1->verifier, &v2->verifier);
+}
+
 /*
  * nfs_direct_cmp_hdr_verf - compare verifier for pgio header
  * @dreq - direct request possibly spanning multiple servers
@@ -215,7 +221,7 @@ static int nfs_direct_set_or_cmp_hdr_verf(struct nfs_direct_req *dreq,
 		nfs_direct_set_hdr_verf(dreq, hdr);
 		return 0;
 	}
-	return memcmp(verfp, &hdr->verf, sizeof(struct nfs_writeverf));
+	return nfs_direct_cmp_verf(verfp, &hdr->verf);
 }
 
 /*
@@ -238,7 +244,7 @@ static int nfs_direct_cmp_commit_data_verf(struct nfs_direct_req *dreq,
 	if (verfp->committed < 0)
 		return 1;
 
-	return memcmp(verfp, &data->verf, sizeof(struct nfs_writeverf));
+	return nfs_direct_cmp_verf(verfp, &data->verf);
 }
 
 /**
diff --git a/fs/nfs/internal.h b/fs/nfs/internal.h
index 5154fa65a2f2..150a8eb0f323 100644
--- a/fs/nfs/internal.h
+++ b/fs/nfs/internal.h
@@ -506,6 +506,13 @@ extern int nfs_migrate_page(struct address_space *,
 #define nfs_migrate_page NULL
 #endif
 
+static inline int
+nfs_write_verifier_cmp(const struct nfs_write_verifier *v1,
+		const struct nfs_write_verifier *v2)
+{
+	return memcmp(v1->data, v2->data, sizeof(v1->data));
+}
+
 /* unlink.c */
 extern struct rpc_task *
 nfs_async_rename(struct inode *old_dir, struct inode *new_dir,
diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index b13d48881d3a..3087fb6f1983 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -1789,7 +1789,7 @@ static void nfs_commit_release_pages(struct nfs_commit_data *data)
 
 		/* Okay, COMMIT succeeded, apparently. Check the verifier
 		 * returned by the server against all stored verfs. */
-		if (!memcmp(&req->wb_verf, &data->verf.verifier, sizeof(req->wb_verf))) {
+		if (!nfs_write_verifier_cmp(&req->wb_verf, &data->verf.verifier)) {
 			/* We have a match */
 			nfs_inode_remove_request(req);
 			dprintk(" OK\n");
-- 
2.7.4

