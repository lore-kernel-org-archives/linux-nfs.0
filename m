Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:40274 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751591AbcFOTC6 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 15 Jun 2016 15:02:58 -0400
From: Benjamin Coddington <bcodding@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>
Subject: [PATCH] NFS: Trim extra slash in v4 nfs_path
Date: Wed, 15 Jun 2016 15:02:55 -0400
Message-Id: <1cb38ee043176bca8ded7e18120776f8cf6a722d.1466017326.git.bcodding@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

A NFSv4 mount of a subdirectory will show an extra slash (as in
'server://path') in proc's mountinfo which will not match the device name
and path.  This can cause problems for programs searching for the mount.
Fix this by checking for a leading slash in the dentry path, if so trim
away any trailing slashes in the device name.

Signed-off-by: Benjamin Coddington <bcodding@redhat.com>
---
 fs/nfs/namespace.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/fs/nfs/namespace.c b/fs/nfs/namespace.c
index c8162c660c44..5551e8ef67fd 100644
--- a/fs/nfs/namespace.c
+++ b/fs/nfs/namespace.c
@@ -98,7 +98,7 @@ rename_retry:
 		return end;
 	}
 	namelen = strlen(base);
-	if (flags & NFS_PATH_CANONICAL) {
+	if (*end == '/') {
 		/* Strip off excess slashes in base string */
 		while (namelen > 0 && base[namelen - 1] == '/')
 			namelen--;
-- 
2.5.5

