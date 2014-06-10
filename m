Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-pb0-f44.google.com ([209.85.160.44]:45001 "EHLO
	mail-pb0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752142AbaFJOFN (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 10 Jun 2014 10:05:13 -0400
Received: by mail-pb0-f44.google.com with SMTP id rq2so6312580pbb.3
        for <linux-nfs@vger.kernel.org>; Tue, 10 Jun 2014 07:05:12 -0700 (PDT)
Message-ID: <5397107B.7050607@gmail.com>
Date: Tue, 10 Jun 2014 22:04:43 +0800
From: Kinglong Mee <kinglongmee@gmail.com>
MIME-Version: 1.0
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: Linux NFS Mailing List <linux-nfs@vger.kernel.org>, kinglongmee@gmail.com
Subject: [PATCH] NFSD: Using path_get when assigning path for export
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Kinglong Mee <kinglongmee@gmail.com>
---
 fs/nfsd/export.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/fs/nfsd/export.c b/fs/nfsd/export.c
index 13b85f9..ef2d9d6 100644
--- a/fs/nfsd/export.c
+++ b/fs/nfsd/export.c
@@ -698,8 +698,8 @@ static void svc_export_init(struct cache_head *cnew, struct cache_head *citem)
 
 	kref_get(&item->ex_client->ref);
 	new->ex_client = item->ex_client;
-	new->ex_path.dentry = dget(item->ex_path.dentry);
-	new->ex_path.mnt = mntget(item->ex_path.mnt);
+	new->ex_path = item->ex_path;
+	path_get(&item->ex_path);
 	new->ex_fslocs.locations = NULL;
 	new->ex_fslocs.locations_count = 0;
 	new->ex_fslocs.migrated = 0;
-- 
1.9.3

