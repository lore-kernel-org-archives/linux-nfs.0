Return-Path: linux-nfs-owner@vger.kernel.org
Received: from auth-4.ukservers.net ([217.10.138.158]:34831 "EHLO
	auth-4.ukservers.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754507AbaJGPUG (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 7 Oct 2014 11:20:06 -0400
From: Carl Hetherington <cth@carlh.net>
To: linux-nfs@vger.kernel.org
Cc: dhowells@redhat.com, keyrings@linux-nfs.org,
        Carl Hetherington <cth@carlh.net>
Date: Tue,  7 Oct 2014 16:19:44 +0100
Message-Id: <1412695184-20773-3-git-send-email-cth@carlh.net>
In-Reply-To: <1412695184-20773-1-git-send-email-cth@carlh.net>
References: <1412695184-20773-1-git-send-email-cth@carlh.net>
Subject: [PATCH 2/2] nfs: don't return expired keys from nfs_idmap_request_key()
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Call request_valid_key_with_auxdata() from nfs_idmap_request_key()
so that the keys code asks userspace for an updated key if one
has expired.  Without this, nfs_idmap_request_key() can return an
expired key which causes incorrect uid/gid mappings.

Signed-off-by: Carl Hetherington <cth@carlh.net>
---
 fs/nfs/idmap.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/idmap.c b/fs/nfs/idmap.c
index 567983d..744e40f 100644
--- a/fs/nfs/idmap.c
+++ b/fs/nfs/idmap.c
@@ -278,8 +278,8 @@ static struct key *nfs_idmap_request_key(const char *name, size_t namelen,
 	rkey = request_key(&key_type_id_resolver, desc, "");
 	if (IS_ERR(rkey)) {
 		mutex_lock(&idmap->idmap_mutex);
-		rkey = request_key_with_auxdata(&key_type_id_resolver_legacy,
-						desc, "", 0, idmap);
+		rkey = request_valid_key_with_auxdata(&key_type_id_resolver_legacy,
+						      desc, "", 0, idmap);
 		mutex_unlock(&idmap->idmap_mutex);
 	}
 
-- 
1.9.1

