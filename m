Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mailhub.sw.ru ([195.214.232.25]:38038 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753507Ab2C1PJ3 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 28 Mar 2012 11:09:29 -0400
Subject: [PATCH 4/8] nfsd: use exp_put() for svc_export_cache put
To: bfields@fieldses.org
From: Stanislav Kinsbursky <skinsbursky@parallels.com>
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org, devel@openvz.org
Date: Wed, 28 Mar 2012 19:09:22 +0400
Message-ID: <20120328150921.2646.46229.stgit@localhost6.localdomain6>
In-Reply-To: <20120328150152.2646.33607.stgit@localhost6.localdomain6>
References: <20120328150152.2646.33607.stgit@localhost6.localdomain6>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This patch replaces cache_put() call for svc_export_cache by exp_put() call.

Signed-off-by: Stanislav Kinsbursky <skinsbursky@parallels.com>

Signed-off-by: Stanislav Kinsbursky <skinsbursky@parallels.com>

---
 fs/nfsd/export.c |    2 +-
 fs/nfsd/nfsfh.c  |    2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/fs/nfsd/export.c b/fs/nfsd/export.c
index 99ea4c0..c20a405 100644
--- a/fs/nfsd/export.c
+++ b/fs/nfsd/export.c
@@ -1205,7 +1205,7 @@ static int e_show(struct seq_file *m, void *p)
 	cache_get(&exp->h);
 	if (cache_check(&svc_export_cache, &exp->h, NULL))
 		return 0;
-	cache_put(&exp->h, &svc_export_cache);
+	exp_put(exp);
 	return svc_export_show(m, &svc_export_cache, cp);
 }
 
diff --git a/fs/nfsd/nfsfh.c b/fs/nfsd/nfsfh.c
index 68454e7..cc79300 100644
--- a/fs/nfsd/nfsfh.c
+++ b/fs/nfsd/nfsfh.c
@@ -636,7 +636,7 @@ fh_put(struct svc_fh *fhp)
 #endif
 	}
 	if (exp) {
-		cache_put(&exp->h, &svc_export_cache);
+		exp_put(exp);
 		fhp->fh_export = NULL;
 	}
 	return;

