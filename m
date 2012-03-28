Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mailhub.sw.ru ([195.214.232.25]:33391 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753507Ab2C1PJI (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 28 Mar 2012 11:09:08 -0400
Subject: [PATCH 1/8] nfsd: use passed cache_detail pointer expkey_parse()
To: bfields@fieldses.org
From: Stanislav Kinsbursky <skinsbursky@parallels.com>
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org, devel@openvz.org
Date: Wed, 28 Mar 2012 19:09:01 +0400
Message-ID: <20120328150901.2646.43715.stgit@localhost6.localdomain6>
In-Reply-To: <20120328150152.2646.33607.stgit@localhost6.localdomain6>
References: <20120328150152.2646.33607.stgit@localhost6.localdomain6>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Using of hard-coded svc_expkey_cache pointer in expkey_parse() looks redundant.
Moreover, global cache will be replaced with per-net instance soon.

Signed-off-by: Stanislav Kinsbursky <skinsbursky@parallels.com>

Signed-off-by: Stanislav Kinsbursky <skinsbursky@parallels.com>

---
 fs/nfsd/export.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/fs/nfsd/export.c b/fs/nfsd/export.c
index 8e9689a..71c5ce3 100644
--- a/fs/nfsd/export.c
+++ b/fs/nfsd/export.c
@@ -163,7 +163,7 @@ static int expkey_parse(struct cache_detail *cd, char *mesg, int mlen)
 	cache_flush();
  out:
 	if (ek)
-		cache_put(&ek->h, &svc_expkey_cache);
+		cache_put(&ek->h, cd);
 	if (dom)
 		auth_domain_put(dom);
 	kfree(buf);

