Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:35117 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751055AbcG2FFI (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 29 Jul 2016 01:05:08 -0400
From: NeilBrown <neilb@suse.com>
To: Steve Dickson <SteveD@redhat.com>
Date: Fri, 29 Jul 2016 15:03:36 +1000
Subject: [PATCH 5/7] mount: fix memory leak in v4root_add_parents
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
        Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Message-ID: <146976861678.20186.788066493232715792.stgit@noble>
In-Reply-To: <146976807524.20186.8871903418718212567.stgit@noble>
References: <146976807524.20186.8871903418718212567.stgit@noble>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

If pseudofs_update failed, we weren't freeing 'path'.

Signed-off-by: NeilBrown <neilb@suse.com>
---
 utils/mountd/v4root.c |    6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/utils/mountd/v4root.c b/utils/mountd/v4root.c
index d52172592823..f978f4ceef01 100644
--- a/utils/mountd/v4root.c
+++ b/utils/mountd/v4root.c
@@ -152,6 +152,7 @@ static int v4root_add_parents(nfs_export *exp)
 	char *hostname = exp->m_export.e_hostname;
 	char *path;
 	char *ptr;
+	int ret = 0;
 
 	path = strdup(exp->m_export.e_path);
 	if (!path) {
@@ -160,19 +161,18 @@ static int v4root_add_parents(nfs_export *exp)
 		return -ENOMEM;
 	}
 	for (ptr = path; ptr; ptr = strchr(ptr, '/')) {
-		int ret;
 		char saved;
 
 		saved = *ptr;
 		*ptr = '\0';
 		ret = pseudofs_update(hostname, *path ? path : "/", exp);
 		if (ret)
-			return ret;
+			break;
 		*ptr = saved;
 		ptr++;
 	}
 	free(path);
-	return 0;
+	return ret;
 }
 
 /*


