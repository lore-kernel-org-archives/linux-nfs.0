Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:25339 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751467Ab0EQQAs (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 17 May 2010 12:00:48 -0400
Message-ID: <4BF16825.2060805@openvz.org>
Date: Mon, 17 May 2010 20:00:37 +0400
From: Pavel Emelyanov <xemul@openvz.org>
To: "J. Bruce Fields" <bfields@citi.umich.edu>
CC: linux-nfs@vger.kernel.org, NeilBrown <neilb@suse.de>
Subject: [PATCH] nfsd: Fix uninitialized ptr access in find_file()
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

The alloc_init_file() first adds a file to the hash and then
initializes its fi_inode, fi_id and fi_had_conflict.

The uninitialized fi_inode can thus be erroneously checked by
the find_file(), so move the hash insertion lower.

I didn't find whether the same can be true for two other fields, 
but the common sense tells me it's better to initialize an object 
before putting it into a global hash table :)

Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

---

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 84b0fe9..296eded 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -1757,12 +1757,12 @@ alloc_init_file(struct inode *ino)
 		INIT_LIST_HEAD(&fp->fi_hash);
 		INIT_LIST_HEAD(&fp->fi_stateids);
 		INIT_LIST_HEAD(&fp->fi_delegations);
-		spin_lock(&recall_lock);
-		list_add(&fp->fi_hash, &file_hashtbl[hashval]);
-		spin_unlock(&recall_lock);
 		fp->fi_inode = igrab(ino);
 		fp->fi_id = current_fileid++;
 		fp->fi_had_conflict = false;
+		spin_lock(&recall_lock);
+		list_add(&fp->fi_hash, &file_hashtbl[hashval]);
+		spin_unlock(&recall_lock);
 		return fp;
 	}
 	return NULL;
