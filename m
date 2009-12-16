From: Benny Halevy <bhalevy@panasas.com>
Subject: [RFC 03/11] nfsd: introduce get_nfs4_client
Date: Wed, 16 Dec 2009 19:40:59 +0200
Message-ID: <1260985259-21446-1-git-send-email-bhalevy@panasas.com>
References: <4B291B4C.3060603@panasas.com>
Cc: linux-nfs@vger.kernel.org, pnfs@linux-nfs.org,
	Benny Halevy <bhalevy@panasas.com>
To: " J. Bruce Fields" <bfields@citi.umich.edu>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:23083 "EHLO
	daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S932275AbZLPRlE (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 16 Dec 2009 12:41:04 -0500
In-Reply-To: <4B291B4C.3060603@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

define a public interface for increment the nfs4_client reference count.

Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfsd/nfs4callback.c |    2 +-
 fs/nfsd/nfs4state.c    |    6 ++++++
 fs/nfsd/state.h        |    1 +
 3 files changed, 8 insertions(+), 1 deletions(-)

diff --git a/fs/nfsd/nfs4callback.c b/fs/nfsd/nfs4callback.c
index c6eed2a..2b4d27b 100644
--- a/fs/nfsd/nfs4callback.c
+++ b/fs/nfsd/nfs4callback.c
@@ -567,7 +567,7 @@ nfsd4_probe_callback(struct nfs4_client *clp)
 	}
 
 	/* the task holds a reference to the nfs4_client struct */
-	atomic_inc(&clp->cl_count);
+	get_nfs4_client(clp);
 
 	do_probe_callback(clp);
 }
diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index dd76682..c456551 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -708,6 +708,12 @@ free_client(struct nfs4_client *clp)
 }
 
 void
+get_nfs4_client(struct nfs4_client *clp)
+{
+	atomic_inc(&clp->cl_count);
+}
+
+void
 put_nfs4_client(struct nfs4_client *clp)
 {
 	if (atomic_dec_and_test(&clp->cl_count))
diff --git a/fs/nfsd/state.h b/fs/nfsd/state.h
index 7e67eca..21109d4 100644
--- a/fs/nfsd/state.h
+++ b/fs/nfsd/state.h
@@ -385,6 +385,7 @@ extern void nfs4_lock_state(void);
 extern void nfs4_unlock_state(void);
 extern int nfs4_in_grace(void);
 extern __be32 nfs4_check_open_reclaim(clientid_t *clid);
+extern void get_nfs4_client(struct nfs4_client *);
 extern void put_nfs4_client(struct nfs4_client *clp);
 extern void nfs4_free_stateowner(struct kref *kref);
 extern int set_callback_cred(void);
-- 
1.6.5.1

