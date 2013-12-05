Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-pb0-f47.google.com ([209.85.160.47]:47012 "EHLO
	mail-pb0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754023Ab3LEDH0 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 4 Dec 2013 22:07:26 -0500
Received: by mail-pb0-f47.google.com with SMTP id um1so24834997pbc.20
        for <linux-nfs@vger.kernel.org>; Wed, 04 Dec 2013 19:07:25 -0800 (PST)
Message-ID: <529FEDE8.50207@gmail.com>
Date: Thu, 05 Dec 2013 11:07:20 +0800
From: Kinglong Mee <kinglongmee@gmail.com>
MIME-Version: 1.0
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: linux-nfs@vger.kernel.org
Subject: [PATCH] nfsd: get rid of unused function definition
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


Signed-off-by: Kinglong Mee <kinglongmee@gmail.com>
---
 fs/nfsd/vfs.h | 2 --
 1 file changed, 2 deletions(-)

diff --git a/fs/nfsd/vfs.h b/fs/nfsd/vfs.h
index a4be2e3..fd8c0cc 100644
--- a/fs/nfsd/vfs.h
+++ b/fs/nfsd/vfs.h
@@ -89,8 +89,6 @@ __be32		nfsd_link(struct svc_rqst *, struct svc_fh *,
 __be32		nfsd_rename(struct svc_rqst *,
 				struct svc_fh *, char *, int,
 				struct svc_fh *, char *, int);
-__be32		nfsd_remove(struct svc_rqst *,
-				struct svc_fh *, char *, int);
 __be32		nfsd_unlink(struct svc_rqst *, struct svc_fh *, int type,
 				char *name, int len);
 __be32		nfsd_readdir(struct svc_rqst *, struct svc_fh *,
-- 
1.8.4.2
