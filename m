Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx3-rdu2.redhat.com ([66.187.233.73]:54632 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1752262AbeDDWG6 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 4 Apr 2018 18:06:58 -0400
Subject: [PATCH 02/12] afs: Use the vnode ID uniquifier in the cache key not
 the aux data
From: David Howells <dhowells@redhat.com>
To: torvalds@linux-foundation.org
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org,
        dhowells@redhat.com, linux-cachefs@redhat.com,
        linux-fsdevel@vger.kernel.org, linux-afs@lists.infradead.org
Date: Wed, 04 Apr 2018 23:06:53 +0100
Message-ID: <152287961391.14760.9907355495632109276.stgit@warthog.procyon.org.uk>
In-Reply-To: <152287959470.14760.10350886166577848180.stgit@warthog.procyon.org.uk>
References: <152287959470.14760.10350886166577848180.stgit@warthog.procyon.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

AFS vnodes (files) are referenced by a triplet of { volume ID, vnode ID,
uniquifier }.  Currently, kafs is only using the vnode ID as the file key
in the volume fscache index and checking the uniquifier on cookie
acquisition against the contents of the auxiliary data stored in the cache.

Unfortunately, this is subject to a race in which an FS.RemoveFile or
FS.RemoveDir op is issued against the server but the local afs inode isn't
torn down and disposed off before another thread issues something like
FS.CreateFile.  The latter then gets given the vnode ID that just got
removed, but with a new uniquifier and a cookie collision occurs in the
cache because the cookie is only keyed on the vnode ID whereas the inode is
keyed on the vnode ID plus the uniquifier.

Fix this by keying the cookie on the uniquifier in addition to the vnode ID
and dropping the uniquifier from the auxiliary data supplied.

Signed-off-by: David Howells <dhowells@redhat.com>
---

 fs/afs/cache.c |   22 ++++++++--------------
 1 file changed, 8 insertions(+), 14 deletions(-)

diff --git a/fs/afs/cache.c b/fs/afs/cache.c
index f62ff71d28c9..cd857db9b112 100644
--- a/fs/afs/cache.c
+++ b/fs/afs/cache.c
@@ -29,7 +29,7 @@ static enum fscache_checkaux afs_vnode_cache_check_aux(void *cookie_netfs_data,
 
 struct fscache_netfs afs_cache_netfs = {
 	.name			= "afs",
-	.version		= 1,
+	.version		= 2,
 };
 
 struct fscache_cookie_def afs_cell_cache_index_def = {
@@ -103,7 +103,9 @@ static uint16_t afs_vnode_cache_get_key(const void *cookie_netfs_data,
 {
 	const struct afs_vnode *vnode = cookie_netfs_data;
 	struct {
-		u32 vnode_id[3];
+		u32 vnode_id;
+		u32 unique;
+		u32 vnode_id_ext[2];	/* Allow for a 96-bit key */
 	} __packed key;
 
 	_enter("{%x,%x,%llx},%p,%u",
@@ -112,9 +114,10 @@ static uint16_t afs_vnode_cache_get_key(const void *cookie_netfs_data,
 
 	/* Allow for a 96-bit key */
 	memset(&key, 0, sizeof(key));
-	key.vnode_id[0] = vnode->fid.vnode;
-	key.vnode_id[1] = 0;
-	key.vnode_id[2] = 0;
+	key.vnode_id		= vnode->fid.vnode;
+	key.unique		= vnode->fid.unique;
+	key.vnode_id_ext[0]	= 0;
+	key.vnode_id_ext[1]	= 0;
 
 	if (sizeof(key) > bufmax)
 		return 0;
@@ -140,7 +143,6 @@ static void afs_vnode_cache_get_attr(const void *cookie_netfs_data,
 
 struct afs_vnode_cache_aux {
 	u64 data_version;
-	u32 fid_unique;
 } __packed;
 
 /*
@@ -156,9 +158,7 @@ static uint16_t afs_vnode_cache_get_aux(const void *cookie_netfs_data,
 	       vnode->fid.vnode, vnode->fid.unique, vnode->status.data_version,
 	       buffer, bufmax);
 
-	memset(&aux, 0, sizeof(aux));
 	aux.data_version = vnode->status.data_version;
-	aux.fid_unique = vnode->fid.unique;
 
 	if (bufmax < sizeof(aux))
 		return 0;
@@ -189,12 +189,6 @@ static enum fscache_checkaux afs_vnode_cache_check_aux(void *cookie_netfs_data,
 		return FSCACHE_CHECKAUX_OBSOLETE;
 	}
 
-	if (vnode->fid.unique != aux.fid_unique) {
-		_leave(" = OBSOLETE [uniq %x != %x]",
-		       aux.fid_unique, vnode->fid.unique);
-		return FSCACHE_CHECKAUX_OBSOLETE;
-	}
-
 	if (vnode->status.data_version != aux.data_version) {
 		_leave(" = OBSOLETE [vers %llx != %llx]",
 		       aux.data_version, vnode->status.data_version);

