Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qg0-f44.google.com ([209.85.192.44]:32882 "EHLO
	mail-qg0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933272AbaLMOLu (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 13 Dec 2014 09:11:50 -0500
Received: by mail-qg0-f44.google.com with SMTP id q107so4722221qgd.3
        for <linux-nfs@vger.kernel.org>; Sat, 13 Dec 2014 06:11:49 -0800 (PST)
From: Jeff Layton <jlayton@primarydata.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH 2/2] nfsd: fi_delegees doesn't need to be an atomic_t
Date: Sat, 13 Dec 2014 09:11:40 -0500
Message-Id: <1418479900-4757-3-git-send-email-jlayton@primarydata.com>
In-Reply-To: <1418479900-4757-1-git-send-email-jlayton@primarydata.com>
References: <1418479900-4757-1-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

fi_delegees is always handled under the fi_lock, so there's no need to
use an atomic_t for this field.

Signed-off-by: Jeff Layton <jlayton@primarydata.com>
---
 fs/nfsd/nfs4state.c | 8 ++++----
 fs/nfsd/state.h     | 2 +-
 2 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 86bc2882bffc..55e8afeff8db 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -688,7 +688,7 @@ static void nfs4_put_deleg_lease(struct nfs4_file *fp)
 	struct file *filp = NULL;
 
 	spin_lock(&fp->fi_lock);
-	if (fp->fi_deleg_file && atomic_dec_and_test(&fp->fi_delegees))
+	if (fp->fi_deleg_file && --fp->fi_delegees == 0)
 		swap(filp, fp->fi_deleg_file);
 	spin_unlock(&fp->fi_lock);
 
@@ -3856,12 +3856,12 @@ static int nfs4_setlease(struct nfs4_delegation *dp)
 	/* Race breaker */
 	if (fp->fi_deleg_file) {
 		status = 0;
-		atomic_inc(&fp->fi_delegees);
+		++fp->fi_delegees;
 		hash_delegation_locked(dp, fp);
 		goto out_unlock;
 	}
 	fp->fi_deleg_file = filp;
-	atomic_set(&fp->fi_delegees, 1);
+	fp->fi_delegees = 1;
 	hash_delegation_locked(dp, fp);
 	spin_unlock(&fp->fi_lock);
 	spin_unlock(&state_lock);
@@ -3902,7 +3902,7 @@ nfs4_set_delegation(struct nfs4_client *clp, struct svc_fh *fh,
 		status = -EAGAIN;
 		goto out_unlock;
 	}
-	atomic_inc(&fp->fi_delegees);
+	++fp->fi_delegees;
 	hash_delegation_locked(dp, fp);
 	status = 0;
 out_unlock:
diff --git a/fs/nfsd/state.h b/fs/nfsd/state.h
index 28264a72fa60..afadb7c2e357 100644
--- a/fs/nfsd/state.h
+++ b/fs/nfsd/state.h
@@ -489,7 +489,7 @@ struct nfs4_file {
 	atomic_t		fi_access[2];
 	u32			fi_share_deny;
 	struct file		*fi_deleg_file;
-	atomic_t		fi_delegees;
+	int			fi_delegees;
 	struct knfsd_fh		fi_fhandle;
 	bool			fi_had_conflict;
 };
-- 
2.1.0

