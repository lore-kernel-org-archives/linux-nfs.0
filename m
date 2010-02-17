From: NeilBrown <neilb@suse.de>
Subject: [PATCH 1/2] sunrpc: extract some common sunrpc_cache code from nfsd
Date: Wed, 17 Feb 2010 17:47:30 +1100
Message-ID: <20100217064730.13656.36217.stgit@notabene.brown>
References: <20100217064330.13656.61404.stgit@notabene.brown>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: "J. Bruce Fields" <bfields@fieldses.org>,
	Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from cantor.suse.de ([195.135.220.2]:49829 "EHLO mx1.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752353Ab0BQGsq (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 17 Feb 2010 01:48:46 -0500
In-Reply-To: <20100217064330.13656.61404.stgit-wvvUuzkyo1EYVZTmpyfIwg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Rather can duplicating this idiom twice, put it in an inline function.
This reduces the usage of 'expiry_time' out side the sunrpc/cache.c
code and thus the impact of a change that is about to be made to that
field.

Signed-off-by: NeilBrown <neilb@suse.de>
---
 fs/nfsd/export.c             |    9 +++------
 include/linux/sunrpc/cache.h |    6 ++++++
 2 files changed, 9 insertions(+), 6 deletions(-)

diff --git a/fs/nfsd/export.c b/fs/nfsd/export.c
index a0c4016..d548da4 100644
--- a/fs/nfsd/export.c
+++ b/fs/nfsd/export.c
@@ -928,10 +928,9 @@ static void exp_fsid_unhash(struct svc_export *exp)
 
 	ek = exp_get_fsid_key(exp->ex_client, exp->ex_fsid);
 	if (!IS_ERR(ek)) {
-		ek->h.expiry_time = get_seconds()-1;
+		sunrpc_invalidate(&ek->h, &svc_expkey_cache);
 		cache_put(&ek->h, &svc_expkey_cache);
 	}
-	svc_expkey_cache.nextcheck = get_seconds();
 }
 
 static int exp_fsid_hash(svc_client *clp, struct svc_export *exp)
@@ -966,10 +965,9 @@ static void exp_unhash(struct svc_export *exp)
 
 	ek = exp_get_key(exp->ex_client, inode->i_sb->s_dev, inode->i_ino);
 	if (!IS_ERR(ek)) {
-		ek->h.expiry_time = get_seconds()-1;
+		sunrpc_invalidate(&ek->h, &svc_expkey_cache);
 		cache_put(&ek->h, &svc_expkey_cache);
 	}
-	svc_expkey_cache.nextcheck = get_seconds();
 }
 	
 /*
@@ -1090,8 +1088,7 @@ out:
 static void
 exp_do_unexport(svc_export *unexp)
 {
-	unexp->h.expiry_time = get_seconds()-1;
-	svc_export_cache.nextcheck = get_seconds();
+	sunrpc_invalidate(&unexp->h, &svc_export_cache);
 	exp_unhash(unexp);
 	exp_fsid_unhash(unexp);
 }
diff --git a/include/linux/sunrpc/cache.h b/include/linux/sunrpc/cache.h
index 6f52b4d..e41ee6d 100644
--- a/include/linux/sunrpc/cache.h
+++ b/include/linux/sunrpc/cache.h
@@ -227,4 +227,10 @@ static inline time_t get_expiry(char **bpp)
 	return rv;
 }
 
+static inline void sunrpc_invalidate(struct cache_head *h,
+				     struct cache_detail *detail)
+{
+	h->expiry_time = get_seconds() - 1;
+	detail->nextcheck = get_seconds();
+}
 #endif /*  _LINUX_SUNRPC_CACHE_H_ */


