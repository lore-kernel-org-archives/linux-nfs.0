Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mailhub.sw.ru ([195.214.232.25]:40762 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753507Ab2C1PJV (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 28 Mar 2012 11:09:21 -0400
Subject: [PATCH 3/8] nfsd: use cache detail pointer from svc_export structure
 on cache put
To: bfields@fieldses.org
From: Stanislav Kinsbursky <skinsbursky@parallels.com>
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org, devel@openvz.org
Date: Wed, 28 Mar 2012 19:09:15 +0400
Message-ID: <20120328150915.2646.47817.stgit@localhost6.localdomain6>
In-Reply-To: <20120328150152.2646.33607.stgit@localhost6.localdomain6>
References: <20120328150152.2646.33607.stgit@localhost6.localdomain6>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hard-coded pointer is redundant now and can be replaced.

Signed-off-by: Stanislav Kinsbursky <skinsbursky@parallels.com>

Signed-off-by: Stanislav Kinsbursky <skinsbursky@parallels.com>

---
 include/linux/nfsd/export.h |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/include/linux/nfsd/export.h b/include/linux/nfsd/export.h
index 6445529..485c2af 100644
--- a/include/linux/nfsd/export.h
+++ b/include/linux/nfsd/export.h
@@ -147,7 +147,7 @@ extern struct cache_detail svc_export_cache;
 
 static inline void exp_put(struct svc_export *exp)
 {
-	cache_put(&exp->h, &svc_export_cache);
+	cache_put(&exp->h, exp->cd);
 }
 
 static inline void exp_get(struct svc_export *exp)

