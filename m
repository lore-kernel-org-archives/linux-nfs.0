Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from cantor.suse.de ([195.135.220.2]:42186 "EHLO mx1.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752375Ab0HLG4H (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 12 Aug 2010 02:56:07 -0400
From: NeilBrown <neilb@suse.de>
To: "J. Bruce Fields" <bfields@fieldses.org>
Date: Thu, 12 Aug 2010 16:55:22 +1000
Subject: [PATCH 1/2] sunrpc: extract some common sunrpc_cache code from nfsd
Cc: linux-nfs@vger.kernel.org
Message-ID: <20100812065522.3408.34827.stgit@localhost.localdomain>
In-Reply-To: <20100812064957.3408.44224.stgit@localhost.localdomain>
References: <20100812064957.3408.44224.stgit@localhost.localdomain>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

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
index c2a4f71..e56827b 100644
--- a/fs/nfsd/export.c
+++ b/fs/nfsd/export.c
@@ -935,10 +935,9 @@ static void exp_fsid_unhash(struct svc_export *exp)
 
 	ek = exp_get_fsid_key(exp->ex_client, exp->ex_fsid);
 	if (!IS_ERR(ek)) {
-		ek->h.expiry_time = get_seconds()-1;
+		sunrpc_invalidate(&ek->h, &svc_expkey_cache);
 		cache_put(&ek->h, &svc_expkey_cache);
 	}
-	svc_expkey_cache.nextcheck = get_seconds();
 }
 
 static int exp_fsid_hash(svc_client *clp, struct svc_export *exp)
@@ -973,10 +972,9 @@ static void exp_unhash(struct svc_export *exp)
 
 	ek = exp_get_key(exp->ex_client, inode->i_sb->s_dev, inode->i_ino);
 	if (!IS_ERR(ek)) {
-		ek->h.expiry_time = get_seconds()-1;
+		sunrpc_invalidate(&ek->h, &svc_expkey_cache);
 		cache_put(&ek->h, &svc_expkey_cache);
 	}
-	svc_expkey_cache.nextcheck = get_seconds();
 }
 	
 /*
@@ -1097,8 +1095,7 @@ out:
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
index 7bf3e84..0e1febf 100644
--- a/include/linux/sunrpc/cache.h
+++ b/include/linux/sunrpc/cache.h
@@ -228,4 +228,10 @@ static inline time_t get_expiry(char **bpp)
 	return rv;
 }
 
+static inline void sunrpc_invalidate(struct cache_head *h,
+				     struct cache_detail *detail)
+{
+	h->expiry_time = get_seconds() - 1;
+	detail->nextcheck = get_seconds();
+}
 #endif /*  _LINUX_SUNRPC_CACHE_H_ */


