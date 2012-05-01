Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:60145 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757929Ab2EAPpy (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 1 May 2012 11:45:54 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 2/6] nfsd4: fix missing "static"
Date: Tue,  1 May 2012 11:45:45 -0400
Message-Id: <1335887149-30420-3-git-send-email-bfields@redhat.com>
In-Reply-To: <1335887149-30420-1-git-send-email-bfields@redhat.com>
References: <1335887149-30420-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: "J. Bruce Fields" <bfields@redhat.com>

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/nfsd/export.c      |    2 +-
 fs/nfsd/nfs4recover.c |    2 +-
 fs/nfsd/nfs4state.c   |    2 +-
 fs/nfsd/nfs4xdr.c     |    2 +-
 4 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/fs/nfsd/export.c b/fs/nfsd/export.c
index dcb52b8..ec16364 100644
--- a/fs/nfsd/export.c
+++ b/fs/nfsd/export.c
@@ -706,7 +706,7 @@ static struct cache_head *svc_export_alloc(void)
 		return NULL;
 }
 
-struct cache_detail svc_export_cache_template = {
+static struct cache_detail svc_export_cache_template = {
 	.owner		= THIS_MODULE,
 	.hash_size	= EXPORT_HASHMAX,
 	.name		= "nfsd.export",
diff --git a/fs/nfsd/nfs4recover.c b/fs/nfsd/nfs4recover.c
index 4767429..2b8e9a9 100644
--- a/fs/nfsd/nfs4recover.c
+++ b/fs/nfsd/nfs4recover.c
@@ -1029,7 +1029,7 @@ rpc_pipefs_event(struct notifier_block *nb, unsigned long event, void *ptr)
 	return ret;
 }
 
-struct notifier_block nfsd4_cld_block = {
+static struct notifier_block nfsd4_cld_block = {
 	.notifier_call = rpc_pipefs_event,
 };
 
diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 307dd9c..7fe95ec 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -4052,7 +4052,7 @@ static void get_lock_access(struct nfs4_ol_stateid *lock_stp, u32 access)
 	__set_bit(access, &lock_stp->st_access_bmap);
 }
 
-__be32 lookup_or_create_lock_state(struct nfsd4_compound_state *cstate, struct nfs4_ol_stateid *ost, struct nfsd4_lock *lock, struct nfs4_ol_stateid **lst, bool *new)
+static __be32 lookup_or_create_lock_state(struct nfsd4_compound_state *cstate, struct nfs4_ol_stateid *ost, struct nfsd4_lock *lock, struct nfs4_ol_stateid **lst, bool *new)
 {
 	struct nfs4_file *fi = ost->st_file;
 	struct nfs4_openowner *oo = openowner(ost->st_stateowner);
diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
index bcd8904..59c5184 100644
--- a/fs/nfsd/nfs4xdr.c
+++ b/fs/nfsd/nfs4xdr.c
@@ -3399,7 +3399,7 @@ nfsd4_encode_sequence(struct nfsd4_compoundres *resp, int nfserr,
 	return 0;
 }
 
-__be32
+static __be32
 nfsd4_encode_test_stateid(struct nfsd4_compoundres *resp, int nfserr,
 			  struct nfsd4_test_stateid *test_stateid)
 {
-- 
1.7.9.5

