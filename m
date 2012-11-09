Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-vc0-f174.google.com ([209.85.220.174]:61101 "EHLO
	mail-vc0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755681Ab2KIUGx (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 9 Nov 2012 15:06:53 -0500
Received: by mail-vc0-f174.google.com with SMTP id fk26so4183151vcb.19
        for <linux-nfs@vger.kernel.org>; Fri, 09 Nov 2012 12:06:52 -0800 (PST)
From: Jeff Layton <jlayton@redhat.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH RFC 1/7] nfsd: remove unused argument to nfs4_has_reclaimed_state
Date: Fri,  9 Nov 2012 15:06:38 -0500
Message-Id: <1352491604-21605-2-git-send-email-jlayton@redhat.com>
In-Reply-To: <1352491604-21605-1-git-send-email-jlayton@redhat.com>
References: <1352491604-21605-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 fs/nfsd/nfs4recover.c | 2 +-
 fs/nfsd/nfs4state.c   | 2 +-
 fs/nfsd/state.h       | 2 +-
 3 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/fs/nfsd/nfs4recover.c b/fs/nfsd/nfs4recover.c
index 0a9ac9d..10b7f47 100644
--- a/fs/nfsd/nfs4recover.c
+++ b/fs/nfsd/nfs4recover.c
@@ -319,7 +319,7 @@ purge_old(struct dentry *parent, struct dentry *child)
 {
 	int status;
 
-	if (nfs4_has_reclaimed_state(child->d_name.name, false))
+	if (nfs4_has_reclaimed_state(child->d_name.name))
 		return 0;
 
 	status = vfs_rmdir(parent->d_inode, child);
diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index fba2996..f15a2a0 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -4465,7 +4465,7 @@ alloc_reclaim(void)
 }
 
 int
-nfs4_has_reclaimed_state(const char *name, bool use_exchange_id)
+nfs4_has_reclaimed_state(const char *name)
 {
 	unsigned int strhashval = clientstr_hashval(name);
 	struct nfs4_client *clp;
diff --git a/fs/nfsd/state.h b/fs/nfsd/state.h
index e036894..bd734f0 100644
--- a/fs/nfsd/state.h
+++ b/fs/nfsd/state.h
@@ -470,7 +470,7 @@ extern void nfsd4_shutdown_callback(struct nfs4_client *);
 extern void nfs4_put_delegation(struct nfs4_delegation *dp);
 extern __be32 nfs4_make_rec_clidname(char *clidname, struct xdr_netobj *clname);
 extern int nfs4_client_to_reclaim(const char *name);
-extern int nfs4_has_reclaimed_state(const char *name, bool use_exchange_id);
+extern int nfs4_has_reclaimed_state(const char *name);
 extern void release_session_client(struct nfsd4_session *);
 extern void nfsd4_purge_closed_stateid(struct nfs4_stateowner *);
 
-- 
1.7.11.7

