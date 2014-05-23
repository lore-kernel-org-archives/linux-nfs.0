Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qg0-f45.google.com ([209.85.192.45]:64060 "EHLO
	mail-qg0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751404AbaEWL6O (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 23 May 2014 07:58:14 -0400
Received: by mail-qg0-f45.google.com with SMTP id z60so7633784qgd.4
        for <linux-nfs@vger.kernel.org>; Fri, 23 May 2014 04:58:14 -0700 (PDT)
Message-ID: <537F37BD.9070005@gmail.com>
Date: Fri, 23 May 2014 19:57:49 +0800
From: Kinglong Mee <kinglongmee@gmail.com>
MIME-Version: 1.0
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: Linux NFS Mailing List <linux-nfs@vger.kernel.org>, kinglongmee@gmail.com
Subject: [PATCH 1/4] NFS4: Avoid NULL reference or double free in nfsd4_fslocs_free()
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

If fsloc_parse() failed at kzalloc(), fs/nfsd/export.c
 411
 412         fsloc->locations = kzalloc(fsloc->locations_count
 413                         * sizeof(struct nfsd4_fs_location), GFP_KERNEL);
 414         if (!fsloc->locations)
 415                 return -ENOMEM;

svc_export_parse() will call nfsd4_fslocs_free() with fsloc->locations = NULL,
so that, "kfree(fsloc->locations[i].path);" will cause a crash.

If fsloc_parse() failed after that, fsloc_parse() will call nfsd4_fslocs_free(),
and svc_export_parse() will call it again, so that, a double free is caused.

This patch checks the fsloc->locations, and set to NULL after it be freed.

Signed-off-by: Kinglong Mee <kinglongmee@gmail.com>
---
 fs/nfsd/export.c | 12 +++++++++---
 1 file changed, 9 insertions(+), 3 deletions(-)

diff --git a/fs/nfsd/export.c b/fs/nfsd/export.c
index 8513c59..9a41d3d 100644
--- a/fs/nfsd/export.c
+++ b/fs/nfsd/export.c
@@ -295,13 +295,19 @@ svc_expkey_update(struct cache_detail *cd, struct svc_expkey *new,
 
 static void nfsd4_fslocs_free(struct nfsd4_fs_locations *fsloc)
 {
+	struct nfsd4_fs_location *locations = fsloc->locations;
 	int i;
 
+	if (!locations)
+		return;
+
 	for (i = 0; i < fsloc->locations_count; i++) {
-		kfree(fsloc->locations[i].path);
-		kfree(fsloc->locations[i].hosts);
+		kfree(locations[i].path);
+		kfree(locations[i].hosts);
 	}
-	kfree(fsloc->locations);
+
+	kfree(locations);
+	fsloc->locations = NULL;
 }
 
 static void svc_export_put(struct kref *ref)
-- 
1.9.0

