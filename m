Return-Path: linux-nfs-owner@vger.kernel.org
Received: from youngberry.canonical.com ([91.189.89.112]:36761 "EHLO
	youngberry.canonical.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933516Ab3CVPxo (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 22 Mar 2013 11:53:44 -0400
From: Dave Chiluk <chiluk@canonical.com>
To: Trond.Myklebust@netapp.com, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org
Subject: [PATCH] NFSv4: Fix the string length returned by the idmapper
Date: Fri, 22 Mar 2013 10:53:32 -0500
Message-Id: <1363967612-28488-1-git-send-email-chiluk@canonical.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Trond Myklebust <Trond.Myklebust@netapp.com>

Functions like nfs_map_uid_to_name() and nfs_map_gid_to_group() are
expected to return a string without any terminating NUL character.
Regression introduced by commit 57e62324e469e092ecc6c94a7a86fe4bd6ac5172
(NFS: Store the legacy idmapper result in the keyring).

This fixes inability to chown on chgrp files on AIX nfs shares.

Reported-by: Dave Chiluk <dave.chiluk@canonical.com>
Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: Bryan Schumaker <bjschuma@netapp.com>
Cc: stable@vger.kernel.org [>=3.4]
---
 fs/nfs/idmap.c |   14 +++++++++-----
 1 file changed, 9 insertions(+), 5 deletions(-)

diff --git a/fs/nfs/idmap.c b/fs/nfs/idmap.c
index dc0f98d..99e9ec6 100644
--- a/fs/nfs/idmap.c
+++ b/fs/nfs/idmap.c
@@ -726,9 +726,10 @@ out1:
 	return ret;
 }
 
-static int nfs_idmap_instantiate(struct key *key, struct key *authkey, char *data)
+static int nfs_idmap_instantiate(struct key *key, struct key *authkey,
+		char *data, size_t datalen)
 {
-	return key_instantiate_and_link(key, data, strlen(data) + 1,
+	return key_instantiate_and_link(key, data, datalen,
 					id_resolver_cache->thread_keyring,
 					authkey);
 }
@@ -738,6 +739,7 @@ static int nfs_idmap_read_and_verify_message(struct idmap_msg *im,
 		struct key *key, struct key *authkey)
 {
 	char id_str[NFS_UINT_MAXLEN];
+	size_t len;
 	int ret = -ENOKEY;
 
 	/* ret = -ENOKEY */
@@ -747,13 +749,15 @@ static int nfs_idmap_read_and_verify_message(struct idmap_msg *im,
 	case IDMAP_CONV_NAMETOID:
 		if (strcmp(upcall->im_name, im->im_name) != 0)
 			break;
-		sprintf(id_str, "%d", im->im_id);
-		ret = nfs_idmap_instantiate(key, authkey, id_str);
+		/* Note: here we store the NUL terminator too */
+		len = sprintf(id_str, "%d", im->im_id) + 1;
+		ret = nfs_idmap_instantiate(key, authkey, id_str, len);
 		break;
 	case IDMAP_CONV_IDTONAME:
 		if (upcall->im_id != im->im_id)
 			break;
-		ret = nfs_idmap_instantiate(key, authkey, im->im_name);
+		len = strlen(im->im_name);
+		ret = nfs_idmap_instantiate(key, authkey, im->im_name, len);
 		break;
 	default:
 		ret = -EINVAL;
-- 
1.7.9.5

