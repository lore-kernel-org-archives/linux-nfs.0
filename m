Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-yk0-f172.google.com ([209.85.160.172]:33920 "EHLO
	mail-yk0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965269AbbHKROH (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 11 Aug 2015 13:14:07 -0400
Received: by ykdt205 with SMTP id t205so92069487ykd.1
        for <linux-nfs@vger.kernel.org>; Tue, 11 Aug 2015 10:14:05 -0700 (PDT)
From: Jeff Layton <jlayton@poochiereds.net>
To: trond.myklebust@primarydata.com
Cc: Anna.Schumaker@netapp.com, linux-nfs@vger.kernel.org
Subject: [PATCH] nfs: allow nfs4_label_free to ignore a PTR_ERR value
Date: Tue, 11 Aug 2015 13:13:59 -0400
Message-Id: <1439313239-30593-1-git-send-email-jeff.layton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

nfs4_label_alloc is a little odd in that a NULL return means "label is
not needed" and a PTR_ERR return means an actual error. In at least one
place however (nfs_lookup_revalidate) we can end up passing an error
value to nfs4_label_free, which will likely lead to an oops.

We could fix that one caller, but I think just allowing the free to
accept and ignore PTR_ERR values is probably appropriate given how the
allocation works.

Signed-off-by: Jeff Layton <jeff.layton@primarydata.com>
---
 fs/nfs/internal.h | 10 +++++-----
 1 file changed, 5 insertions(+), 5 deletions(-)

diff --git a/fs/nfs/internal.h b/fs/nfs/internal.h
index 9b372b845f6a..44bc298f6216 100644
--- a/fs/nfs/internal.h
+++ b/fs/nfs/internal.h
@@ -312,13 +312,13 @@ nfs4_label_copy(struct nfs4_label *dst, struct nfs4_label *src)
 
 	return dst;
 }
+
 static inline void nfs4_label_free(struct nfs4_label *label)
 {
-	if (label) {
-		kfree(label->label);
-		kfree(label);
-	}
-	return;
+	if (IS_ERR_OR_NULL(label))
+		return;
+	kfree(label->label);
+	kfree(label);
 }
 
 static inline void nfs_zap_label_cache_locked(struct nfs_inode *nfsi)
-- 
2.4.3

