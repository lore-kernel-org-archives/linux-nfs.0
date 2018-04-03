Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx3-rdu2.redhat.com ([66.187.233.73]:58022 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751649AbeDCOxW (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 3 Apr 2018 10:53:22 -0400
Subject: [PATCH 1/3] fscache: Attach the index key and aux data to the cookie
From: David Howells <dhowells@redhat.com>
To: anna.schumaker@netapp.com, steved@redhat.com
Cc: linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org,
        linux-afs@lists.infradead.org
Date: Tue, 03 Apr 2018 15:53:18 +0100
Message-ID: <152276719852.15943.14721470190265271738.stgit@warthog.procyon.org.uk>
In-Reply-To: <152276719197.15943.8722265175158239235.stgit@warthog.procyon.org.uk>
References: <152276719197.15943.8722265175158239235.stgit@warthog.procyon.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Attach copies of the index key and auxiliary data to the fscache cookie so
that:

 (1) The callbacks to the netfs for this stuff can be eliminated.  This
     can simplify things in the cache as the information is still
     available, even after the cache has relinquished the cookie.

 (2) Simplifies the locking requirements of accessing the information as we
     don't have to worry about the netfs object going away on us.

 (3) The cache can do lazy updating of the coherency information on disk.
     As long as the cache is flushed before reboot/poweroff, there's no
     need to update the coherency info on disk every time it changes.

 (4) Cookies can be hashed or put in a tree as the index key is easily
     available.  This allows:

     (a) Checks for duplicate cookies can be made at the top fscache layer
     	 rather than down in the bowels of the cache backend.

     (b) Caching can be added to a netfs object that has a cookie if the
     	 cache is brought online after the netfs object is allocated.

A certain amount of space is made in the cookie for inline copies of the
data, but if it won't fit there, extra memory will be allocated for it.

The downside of this is that live cache operation requires more memory.

Signed-off-by: David Howells <dhowells@redhat.com>
---

 Documentation/filesystems/caching/netfs-api.txt |  106 ++++++++--------
 fs/9p/cache.c                                   |   73 +++--------
 fs/afs/cache.c                                  |  120 +-----------------
 fs/afs/cell.c                                   |    4 -
 fs/afs/inode.c                                  |   46 ++++++-
 fs/afs/internal.h                               |    7 +
 fs/afs/volume.c                                 |    4 -
 fs/cachefiles/interface.c                       |   38 ++++--
 fs/cachefiles/namei.c                           |   33 ++---
 fs/cachefiles/xattr.c                           |    2 
 fs/ceph/cache.c                                 |   93 ++++----------
 fs/cifs/cache.c                                 |  153 -----------------------
 fs/cifs/fscache.c                               |  122 ++++++++++++++++--
 fs/cifs/fscache.h                               |   13 ++
 fs/fscache/cache.c                              |    2 
 fs/fscache/cookie.c                             |   88 ++++++++++---
 fs/fscache/fsdef.c                              |   49 -------
 fs/fscache/internal.h                           |   21 +++
 fs/fscache/netfs.c                              |   17 ++-
 fs/fscache/object-list.c                        |   28 ++--
 fs/fscache/object.c                             |   22 +++
 fs/fscache/operation.c                          |    2 
 fs/nfs/fscache-index.c                          |  140 ---------------------
 fs/nfs/fscache.c                                |   83 ++++++++++++
 fs/nfs/fscache.h                                |   16 ++
 include/linux/fscache.h                         |  110 ++++++++++-------
 26 files changed, 606 insertions(+), 786 deletions(-)

diff --git a/Documentation/filesystems/caching/netfs-api.txt b/Documentation/filesystems/caching/netfs-api.txt
index 0eb31de3a2c1..332840ad4151 100644
--- a/Documentation/filesystems/caching/netfs-api.txt
+++ b/Documentation/filesystems/caching/netfs-api.txt
@@ -129,17 +129,9 @@ To define an object, a structure of the following type should be filled out:
 			const void *parent_netfs_data,
 			const void *cookie_netfs_data);
 
-		uint16_t (*get_key)(const void *cookie_netfs_data,
-				    void *buffer,
-				    uint16_t bufmax);
-
 		void (*get_attr)(const void *cookie_netfs_data,
 				 uint64_t *size);
 
-		uint16_t (*get_aux)(const void *cookie_netfs_data,
-				    void *buffer,
-				    uint16_t bufmax);
-
 		enum fscache_checkaux (*check_aux)(void *cookie_netfs_data,
 						   const void *data,
 						   uint16_t datalen);
@@ -187,14 +179,7 @@ This has the following fields:
      cache in the parent's list will be chosen, or failing that, the first
      cache in the master list.
 
- (4) A function to retrieve an object's key from the netfs [mandatory].
-
-     This function will be called with the netfs data that was passed to the
-     cookie acquisition function and the maximum length of key data that it may
-     provide.  It should write the required key data into the given buffer and
-     return the quantity it wrote.
-
- (5) A function to retrieve attribute data from the netfs [optional].
+ (4) A function to retrieve attribute data from the netfs [optional].
 
      This function will be called with the netfs data that was passed to the
      cookie acquisition function.  It should return the size of the file if
@@ -203,20 +188,7 @@ This has the following fields:
 
      If the function is absent, a file size of 0 is assumed.
 
- (6) A function to retrieve auxiliary data from the netfs [optional].
-
-     This function will be called with the netfs data that was passed to the
-     cookie acquisition function and the maximum length of auxiliary data that
-     it may provide.  It should write the auxiliary data into the given buffer
-     and return the quantity it wrote.
-
-     If this function is absent, the auxiliary data length will be set to 0.
-
-     The length of the auxiliary data buffer may be dependent on the key
-     length.  A netfs mustn't rely on being able to provide more than 400 bytes
-     for both.
-
- (7) A function to check the auxiliary data [optional].
+ (5) A function to check the auxiliary data [optional].
 
      This function will be called to check that a match found in the cache for
      this object is valid.  For instance with AFS it could check the auxiliary
@@ -235,7 +207,7 @@ This has the following fields:
      This function can also be used to extract data from the auxiliary data in
      the cache and copy it into the netfs's structures.
 
- (8) A pair of functions to manage contexts for the completion callback
+ (6) A pair of functions to manage contexts for the completion callback
      [optional].
 
      The cache read/write functions are passed a context which is then passed
@@ -249,7 +221,7 @@ This has the following fields:
      required for indices as indices may not contain data.  These functions may
      be called in interrupt context and so may not sleep.
 
- (9) A function to mark a page as retaining cache metadata [optional].
+ (7) A function to mark a page as retaining cache metadata [optional].
 
      This is called by the cache to indicate that it is retaining in-memory
      information for this page and that the netfs should uncache the page when
@@ -261,7 +233,7 @@ This has the following fields:
 
      This function is not required for indices as they're not permitted data.
 
-(10) A function to unmark all the pages retaining cache metadata [mandatory].
+ (8) A function to unmark all the pages retaining cache metadata [mandatory].
 
      This is called by FS-Cache to indicate that a backing store is being
      unbound from a cookie and that all the marks on the pages should be
@@ -333,12 +305,27 @@ the path to the file:
 	struct fscache_cookie *
 	fscache_acquire_cookie(struct fscache_cookie *parent,
 			       const struct fscache_object_def *def,
+			       const void *index_key,
+			       size_t index_key_len,
+			       const void *aux_data,
+			       size_t aux_data_len,
 			       void *netfs_data,
 			       bool enable);
 
 This function creates an index entry in the index represented by parent,
 filling in the index entry by calling the operations pointed to by def.
 
+A unique key that represents the object within the parent must be pointed to by
+index_key and is of length index_key_len.
+
+An optional blob of auxiliary data that is to be stored within the cache can be
+pointed to with aux_data and should be of length aux_data_len.  This would
+typically be used for storing coherency data.
+
+The netfs may pass an arbitrary value in netfs_data and this will be presented
+to it in the event of any calling back.  This may also be used in tracing or
+logging of messages.
+
 Note that this function never returns an error - all errors are handled
 internally.  It may, however, return NULL to indicate no cookie.  It is quite
 acceptable to pass this token back to this function as the parent to another
@@ -355,29 +342,23 @@ must be enabled to do anything with it.  A disabled cookie can be enabled by
 calling fscache_enable_cookie() (see below).
 
 For example, with AFS, a cell would be added to the primary index.  This index
-entry would have a dependent inode containing a volume location index for the
-volume mappings within this cell:
+entry would have a dependent inode containing volume mappings within this cell:
 
 	cell->cache =
 		fscache_acquire_cookie(afs_cache_netfs.primary_index,
 				       &afs_cell_cache_index_def,
+				       cell->name, strlen(cell->name),
+				       NULL, 0,
 				       cell, true);
 
-Then when a volume location was accessed, it would be entered into the cell's
-index and an inode would be allocated that acts as a volume type and hash chain
-combination:
-
-	vlocation->cache =
-		fscache_acquire_cookie(cell->cache,
-				       &afs_vlocation_cache_index_def,
-				       vlocation, true);
-
-And then a particular flavour of volume (R/O for example) could be added to
-that index, creating another index for vnodes (AFS inode equivalents):
+And then a particular volume could be added to that index by ID, creating
+another index for vnodes (AFS inode equivalents):
 
 	volume->cache =
-		fscache_acquire_cookie(vlocation->cache,
+		fscache_acquire_cookie(volume->cell->cache,
 				       &afs_volume_cache_index_def,
+				       &volume->vid, sizeof(volume->vid),
+				       NULL, 0,
 				       volume, true);
 
 
@@ -392,6 +373,8 @@ the object definition should be something other than index type.
 	vnode->cache =
 		fscache_acquire_cookie(volume->cache,
 				       &afs_vnode_cache_object_def,
+				       &key, sizeof(key),
+				       &aux, sizeof(aux),
 				       vnode, true);
 
 
@@ -408,6 +391,8 @@ it would be some other type of object such as a data file.
 	xattr->cache =
 		fscache_acquire_cookie(vnode->cache,
 				       &afs_xattr_cache_object_def,
+				       &xattr->name, strlen(xattr->name),
+				       NULL, 0,
 				       xattr, true);
 
 Miscellaneous objects might be used to store extended attributes or directory
@@ -717,21 +702,23 @@ INDEX AND DATA FILE CONSISTENCY
 To find out whether auxiliary data for an object is up to data within the
 cache, the following function can be called:
 
-	int fscache_check_consistency(struct fscache_cookie *cookie)
+	int fscache_check_consistency(struct fscache_cookie *cookie,
+				      const void *aux_data);
 
 This will call back to the netfs to check whether the auxiliary data associated
-with a cookie is correct.  It returns 0 if it is and -ESTALE if it isn't; it
-may also return -ENOMEM and -ERESTARTSYS.
+with a cookie is correct; if aux_data is non-NULL, it will update the auxiliary
+data buffer first.  It returns 0 if it is and -ESTALE if it isn't; it may also
+return -ENOMEM and -ERESTARTSYS.
 
 To request an update of the index data for an index or other object, the
 following function should be called:
 
-	void fscache_update_cookie(struct fscache_cookie *cookie);
+	void fscache_update_cookie(struct fscache_cookie *cookie,
+				   const void *aux_data);
 
-This function will refer back to the netfs_data pointer stored in the cookie by
-the acquisition function to obtain the data to write into each revised index
-entry.  The update method in the parent index definition will be called to
-transfer the data.
+This function will update the cookie's auxiliary data buffer from aux_data if
+that is non-NULL and then schedule this to be stored on disk.  The update
+method in the parent index definition will be called to transfer the data.
 
 Note that partial updates may happen automatically at other times, such as when
 data blocks are added to a data file object.
@@ -750,6 +737,7 @@ The initial enablement state is set by fscache_acquire_cookie(), but the cookie
 can be enabled or disabled later.  To disable a cookie, call:
     
 	void fscache_disable_cookie(struct fscache_cookie *cookie,
+				    const void *aux_data,
     				    bool invalidate);
     
 If the cookie is not already disabled, this locks the cookie against other
@@ -764,6 +752,7 @@ markings are cleared up.
 Cookies can be enabled or reenabled with:
     
     	void fscache_enable_cookie(struct fscache_cookie *cookie,
+				   const void *aux_data,
     				   bool (*can_enable)(void *data),
     				   void *data)
     
@@ -777,6 +766,9 @@ ruling as to whether or not enablement should actually be permitted to begin.
 All possible failures are handled internally.  The cookie will only be marked
 as enabled if provisional backing objects are allocated.
 
+In both cases, the cookie's auxiliary data buffer is updated from aux_data if
+that is non-NULL inside the enablement lock before proceeding.
+
 
 ===============================
 MISCELLANEOUS COOKIE OPERATIONS
@@ -823,6 +815,7 @@ COOKIE UNREGISTRATION
 To get rid of a cookie, this function should be called.
 
 	void fscache_relinquish_cookie(struct fscache_cookie *cookie,
+				       const void *aux_data,
 				       bool retire);
 
 If retire is non-zero, then the object will be marked for recycling, and all
@@ -833,6 +826,9 @@ If retire is zero, then the object may be available again when next the
 acquisition function is called.  Retirement here will overrule the pinning on a
 cookie.
 
+The cookie's auxiliary data will be updated from aux_data if that is non-NULL
+so that the cache can lazily update it on disk.
+
 One very important note - relinquish must NOT be called for a cookie unless all
 the cookies for "child" indices, objects and pages have been relinquished
 first.
diff --git a/fs/9p/cache.c b/fs/9p/cache.c
index 64c58eb26159..9d0030af5672 100644
--- a/fs/9p/cache.c
+++ b/fs/9p/cache.c
@@ -55,41 +55,26 @@ int v9fs_random_cachetag(struct v9fs_session_info *v9ses)
 	return scnprintf(v9ses->cachetag, CACHETAG_LEN, "%lu", jiffies);
 }
 
-static uint16_t v9fs_cache_session_get_key(const void *cookie_netfs_data,
-					   void *buffer, uint16_t bufmax)
-{
-	struct v9fs_session_info *v9ses;
-	uint16_t klen = 0;
-
-	v9ses = (struct v9fs_session_info *)cookie_netfs_data;
-	p9_debug(P9_DEBUG_FSC, "session %p buf %p size %u\n",
-		 v9ses, buffer, bufmax);
-
-	if (v9ses->cachetag)
-		klen = strlen(v9ses->cachetag);
-
-	if (klen > bufmax)
-		return 0;
-
-	memcpy(buffer, v9ses->cachetag, klen);
-	p9_debug(P9_DEBUG_FSC, "cache session tag %s\n", v9ses->cachetag);
-	return klen;
-}
-
 const struct fscache_cookie_def v9fs_cache_session_index_def = {
 	.name		= "9P.session",
 	.type		= FSCACHE_COOKIE_TYPE_INDEX,
-	.get_key	= v9fs_cache_session_get_key,
 };
 
 void v9fs_cache_session_get_cookie(struct v9fs_session_info *v9ses)
 {
 	/* If no cache session tag was specified, we generate a random one. */
-	if (!v9ses->cachetag)
-		v9fs_random_cachetag(v9ses);
+	if (!v9ses->cachetag) {
+		if (v9fs_random_cachetag(v9ses) < 0) {
+			v9ses->fscache = NULL;
+			return;
+		}
+	}
 
 	v9ses->fscache = fscache_acquire_cookie(v9fs_cache_netfs.primary_index,
 						&v9fs_cache_session_index_def,
+						v9ses->cachetag,
+						strlen(v9ses->cachetag),
+						NULL, 0,
 						v9ses, true);
 	p9_debug(P9_DEBUG_FSC, "session %p get cookie %p\n",
 		 v9ses, v9ses->fscache);
@@ -99,21 +84,10 @@ void v9fs_cache_session_put_cookie(struct v9fs_session_info *v9ses)
 {
 	p9_debug(P9_DEBUG_FSC, "session %p put cookie %p\n",
 		 v9ses, v9ses->fscache);
-	fscache_relinquish_cookie(v9ses->fscache, 0);
+	fscache_relinquish_cookie(v9ses->fscache, NULL, false);
 	v9ses->fscache = NULL;
 }
 
-
-static uint16_t v9fs_cache_inode_get_key(const void *cookie_netfs_data,
-					 void *buffer, uint16_t bufmax)
-{
-	const struct v9fs_inode *v9inode = cookie_netfs_data;
-	memcpy(buffer, &v9inode->qid.path, sizeof(v9inode->qid.path));
-	p9_debug(P9_DEBUG_FSC, "inode %p get key %llu\n",
-		 &v9inode->vfs_inode, v9inode->qid.path);
-	return sizeof(v9inode->qid.path);
-}
-
 static void v9fs_cache_inode_get_attr(const void *cookie_netfs_data,
 				      uint64_t *size)
 {
@@ -124,16 +98,6 @@ static void v9fs_cache_inode_get_attr(const void *cookie_netfs_data,
 		 &v9inode->vfs_inode, *size);
 }
 
-static uint16_t v9fs_cache_inode_get_aux(const void *cookie_netfs_data,
-					 void *buffer, uint16_t buflen)
-{
-	const struct v9fs_inode *v9inode = cookie_netfs_data;
-	memcpy(buffer, &v9inode->qid.version, sizeof(v9inode->qid.version));
-	p9_debug(P9_DEBUG_FSC, "inode %p get aux %u\n",
-		 &v9inode->vfs_inode, v9inode->qid.version);
-	return sizeof(v9inode->qid.version);
-}
-
 static enum
 fscache_checkaux v9fs_cache_inode_check_aux(void *cookie_netfs_data,
 					    const void *buffer,
@@ -154,9 +118,7 @@ fscache_checkaux v9fs_cache_inode_check_aux(void *cookie_netfs_data,
 const struct fscache_cookie_def v9fs_cache_inode_index_def = {
 	.name		= "9p.inode",
 	.type		= FSCACHE_COOKIE_TYPE_DATAFILE,
-	.get_key	= v9fs_cache_inode_get_key,
 	.get_attr	= v9fs_cache_inode_get_attr,
-	.get_aux	= v9fs_cache_inode_get_aux,
 	.check_aux	= v9fs_cache_inode_check_aux,
 };
 
@@ -175,6 +137,10 @@ void v9fs_cache_inode_get_cookie(struct inode *inode)
 	v9ses = v9fs_inode2v9ses(inode);
 	v9inode->fscache = fscache_acquire_cookie(v9ses->fscache,
 						  &v9fs_cache_inode_index_def,
+						  &v9inode->qid.path,
+						  sizeof(v9inode->qid.path),
+						  &v9inode->qid.version,
+						  sizeof(v9inode->qid.version),
 						  v9inode, true);
 
 	p9_debug(P9_DEBUG_FSC, "inode %p get cookie %p\n",
@@ -190,7 +156,8 @@ void v9fs_cache_inode_put_cookie(struct inode *inode)
 	p9_debug(P9_DEBUG_FSC, "inode %p put cookie %p\n",
 		 inode, v9inode->fscache);
 
-	fscache_relinquish_cookie(v9inode->fscache, 0);
+	fscache_relinquish_cookie(v9inode->fscache, &v9inode->qid.version,
+				  false);
 	v9inode->fscache = NULL;
 }
 
@@ -203,7 +170,7 @@ void v9fs_cache_inode_flush_cookie(struct inode *inode)
 	p9_debug(P9_DEBUG_FSC, "inode %p flush cookie %p\n",
 		 inode, v9inode->fscache);
 
-	fscache_relinquish_cookie(v9inode->fscache, 1);
+	fscache_relinquish_cookie(v9inode->fscache, NULL, true);
 	v9inode->fscache = NULL;
 }
 
@@ -236,11 +203,15 @@ void v9fs_cache_inode_reset_cookie(struct inode *inode)
 	old = v9inode->fscache;
 
 	mutex_lock(&v9inode->fscache_lock);
-	fscache_relinquish_cookie(v9inode->fscache, 1);
+	fscache_relinquish_cookie(v9inode->fscache, NULL, true);
 
 	v9ses = v9fs_inode2v9ses(inode);
 	v9inode->fscache = fscache_acquire_cookie(v9ses->fscache,
 						  &v9fs_cache_inode_index_def,
+						  &v9inode->qid.path,
+						  sizeof(v9inode->qid.path),
+						  &v9inode->qid.version,
+						  sizeof(v9inode->qid.version),
 						  v9inode, true);
 	p9_debug(P9_DEBUG_FSC, "inode %p revalidating cookie old %p new %p\n",
 		 inode, old, v9inode->fscache);
diff --git a/fs/afs/cache.c b/fs/afs/cache.c
index cd857db9b112..a16f1e024cf3 100644
--- a/fs/afs/cache.c
+++ b/fs/afs/cache.c
@@ -12,17 +12,8 @@
 #include <linux/sched.h>
 #include "internal.h"
 
-static uint16_t afs_cell_cache_get_key(const void *cookie_netfs_data,
-				       void *buffer, uint16_t buflen);
-static uint16_t afs_volume_cache_get_key(const void *cookie_netfs_data,
-					 void *buffer, uint16_t buflen);
-
-static uint16_t afs_vnode_cache_get_key(const void *cookie_netfs_data,
-					void *buffer, uint16_t buflen);
 static void afs_vnode_cache_get_attr(const void *cookie_netfs_data,
 				     uint64_t *size);
-static uint16_t afs_vnode_cache_get_aux(const void *cookie_netfs_data,
-					void *buffer, uint16_t buflen);
 static enum fscache_checkaux afs_vnode_cache_check_aux(void *cookie_netfs_data,
 						       const void *buffer,
 						       uint16_t buflen);
@@ -35,97 +26,20 @@ struct fscache_netfs afs_cache_netfs = {
 struct fscache_cookie_def afs_cell_cache_index_def = {
 	.name		= "AFS.cell",
 	.type		= FSCACHE_COOKIE_TYPE_INDEX,
-	.get_key	= afs_cell_cache_get_key,
 };
 
 struct fscache_cookie_def afs_volume_cache_index_def = {
 	.name		= "AFS.volume",
 	.type		= FSCACHE_COOKIE_TYPE_INDEX,
-	.get_key	= afs_volume_cache_get_key,
 };
 
 struct fscache_cookie_def afs_vnode_cache_index_def = {
-	.name			= "AFS.vnode",
-	.type			= FSCACHE_COOKIE_TYPE_DATAFILE,
-	.get_key		= afs_vnode_cache_get_key,
-	.get_attr		= afs_vnode_cache_get_attr,
-	.get_aux		= afs_vnode_cache_get_aux,
-	.check_aux		= afs_vnode_cache_check_aux,
+	.name		= "AFS.vnode",
+	.type		= FSCACHE_COOKIE_TYPE_DATAFILE,
+	.get_attr	= afs_vnode_cache_get_attr,
+	.check_aux	= afs_vnode_cache_check_aux,
 };
 
-/*
- * set the key for the index entry
- */
-static uint16_t afs_cell_cache_get_key(const void *cookie_netfs_data,
-				       void *buffer, uint16_t bufmax)
-{
-	const struct afs_cell *cell = cookie_netfs_data;
-	uint16_t klen;
-
-	_enter("%p,%p,%u", cell, buffer, bufmax);
-
-	klen = strlen(cell->name);
-	if (klen > bufmax)
-		return 0;
-
-	memcpy(buffer, cell->name, klen);
-	return klen;
-}
-
-/*****************************************************************************/
-/*
- * set the key for the volume index entry
- */
-static uint16_t afs_volume_cache_get_key(const void *cookie_netfs_data,
-					 void *buffer, uint16_t bufmax)
-{
-	const struct afs_volume *volume = cookie_netfs_data;
-	struct {
-		u64 volid;
-	} __packed key;
-
-	_enter("{%u},%p,%u", volume->type, buffer, bufmax);
-
-	if (bufmax < sizeof(key))
-		return 0;
-
-	key.volid = volume->vid;
-	memcpy(buffer, &key, sizeof(key));
-	return sizeof(key);
-}
-
-/*****************************************************************************/
-/*
- * set the key for the index entry
- */
-static uint16_t afs_vnode_cache_get_key(const void *cookie_netfs_data,
-					void *buffer, uint16_t bufmax)
-{
-	const struct afs_vnode *vnode = cookie_netfs_data;
-	struct {
-		u32 vnode_id;
-		u32 unique;
-		u32 vnode_id_ext[2];	/* Allow for a 96-bit key */
-	} __packed key;
-
-	_enter("{%x,%x,%llx},%p,%u",
-	       vnode->fid.vnode, vnode->fid.unique, vnode->status.data_version,
-	       buffer, bufmax);
-
-	/* Allow for a 96-bit key */
-	memset(&key, 0, sizeof(key));
-	key.vnode_id		= vnode->fid.vnode;
-	key.unique		= vnode->fid.unique;
-	key.vnode_id_ext[0]	= 0;
-	key.vnode_id_ext[1]	= 0;
-
-	if (sizeof(key) > bufmax)
-		return 0;
-
-	memcpy(buffer, &key, sizeof(key));
-	return sizeof(key);
-}
-
 /*
  * provide updated file attributes
  */
@@ -141,32 +55,6 @@ static void afs_vnode_cache_get_attr(const void *cookie_netfs_data,
 	*size = vnode->status.size;
 }
 
-struct afs_vnode_cache_aux {
-	u64 data_version;
-} __packed;
-
-/*
- * provide new auxiliary cache data
- */
-static uint16_t afs_vnode_cache_get_aux(const void *cookie_netfs_data,
-					void *buffer, uint16_t bufmax)
-{
-	const struct afs_vnode *vnode = cookie_netfs_data;
-	struct afs_vnode_cache_aux aux;
-
-	_enter("{%x,%x,%Lx},%p,%u",
-	       vnode->fid.vnode, vnode->fid.unique, vnode->status.data_version,
-	       buffer, bufmax);
-
-	aux.data_version = vnode->status.data_version;
-
-	if (bufmax < sizeof(aux))
-		return 0;
-
-	memcpy(buffer, &aux, sizeof(aux));
-	return sizeof(aux);
-}
-
 /*
  * check that the auxiliary data indicates that the entry is still valid
  */
diff --git a/fs/afs/cell.c b/fs/afs/cell.c
index 9bb921d120d0..9d3985fbf75e 100644
--- a/fs/afs/cell.c
+++ b/fs/afs/cell.c
@@ -522,6 +522,8 @@ static int afs_activate_cell(struct afs_net *net, struct afs_cell *cell)
 #ifdef CONFIG_AFS_FSCACHE
 	cell->cache = fscache_acquire_cookie(afs_cache_netfs.primary_index,
 					     &afs_cell_cache_index_def,
+					     cell->name, strlen(cell->name),
+					     NULL, 0,
 					     cell, true);
 #endif
 	ret = afs_proc_cell_setup(net, cell);
@@ -547,7 +549,7 @@ static void afs_deactivate_cell(struct afs_net *net, struct afs_cell *cell)
 	spin_unlock(&net->proc_cells_lock);
 
 #ifdef CONFIG_AFS_FSCACHE
-	fscache_relinquish_cookie(cell->cache, 0);
+	fscache_relinquish_cookie(cell->cache, NULL, false);
 	cell->cache = NULL;
 #endif
 
diff --git a/fs/afs/inode.c b/fs/afs/inode.c
index c942c79fc5f0..e499713efd2e 100644
--- a/fs/afs/inode.c
+++ b/fs/afs/inode.c
@@ -242,6 +242,33 @@ struct inode *afs_iget_pseudo_dir(struct super_block *sb, bool root)
 	return inode;
 }
 
+/*
+ * Get a cache cookie for an inode.
+ */
+static void afs_get_inode_cache(struct afs_vnode *vnode)
+{
+#ifdef CONFIG_AFS_FSCACHE
+	struct {
+		u32 vnode_id;
+		u32 unique;
+		u32 vnode_id_ext[2];	/* Allow for a 96-bit key */
+	} __packed key;
+	struct afs_vnode_cache_aux aux;
+
+	key.vnode_id		= vnode->fid.vnode;
+	key.unique		= vnode->fid.unique;
+	key.vnode_id_ext[0]	= 0;
+	key.vnode_id_ext[1]	= 0;
+	aux.data_version	= vnode->status.data_version;
+
+	vnode->cache = fscache_acquire_cookie(vnode->volume->cache,
+					      &afs_vnode_cache_index_def,
+					      &key, sizeof(key),
+					      &aux, sizeof(aux),
+					      vnode, true);
+#endif
+}
+
 /*
  * inode retrieval
  */
@@ -307,11 +334,7 @@ struct inode *afs_iget(struct super_block *sb, struct key *key,
 	/* set up caching before mapping the status, as map-status reads the
 	 * first page of symlinks to see if they're really mountpoints */
 	inode->i_size = vnode->status.size;
-#ifdef CONFIG_AFS_FSCACHE
-	vnode->cache = fscache_acquire_cookie(vnode->volume->cache,
-					      &afs_vnode_cache_index_def,
-					      vnode, true);
-#endif
+	afs_get_inode_cache(vnode);
 
 	ret = afs_inode_map_status(vnode, key);
 	if (ret < 0)
@@ -327,7 +350,7 @@ struct inode *afs_iget(struct super_block *sb, struct key *key,
 	/* failure */
 bad_inode:
 #ifdef CONFIG_AFS_FSCACHE
-	fscache_relinquish_cookie(vnode->cache, ret == -ENOENT);
+	fscache_relinquish_cookie(vnode->cache, NULL, ret == -ENOENT);
 	vnode->cache = NULL;
 #endif
 	iget_failed(inode);
@@ -511,9 +534,14 @@ void afs_evict_inode(struct inode *inode)
 	}
 
 #ifdef CONFIG_AFS_FSCACHE
-	fscache_relinquish_cookie(vnode->cache,
-				  test_bit(AFS_VNODE_DELETED, &vnode->flags));
-	vnode->cache = NULL;
+	{
+		struct afs_vnode_cache_aux aux;
+
+		aux.data_version = vnode->status.data_version;
+		fscache_relinquish_cookie(vnode->cache, &aux,
+					  test_bit(AFS_VNODE_DELETED, &vnode->flags));
+		vnode->cache = NULL;
+	}
 #endif
 
 	afs_put_permits(vnode->permit_cache);
diff --git a/fs/afs/internal.h b/fs/afs/internal.h
index 72217170b155..a6a1d75eee41 100644
--- a/fs/afs/internal.h
+++ b/fs/afs/internal.h
@@ -559,6 +559,13 @@ struct afs_fs_cursor {
 #define AFS_FS_CURSOR_NO_VSLEEP	0x0020		/* Set to prevent sleep on VBUSY, VOFFLINE, ... */
 };
 
+/*
+ * Cache auxiliary data.
+ */
+struct afs_vnode_cache_aux {
+	u64			data_version;
+} __packed;
+
 #include <trace/events/afs.h>
 
 /*****************************************************************************/
diff --git a/fs/afs/volume.c b/fs/afs/volume.c
index b517a588781f..345cb2d675d2 100644
--- a/fs/afs/volume.c
+++ b/fs/afs/volume.c
@@ -225,6 +225,8 @@ void afs_activate_volume(struct afs_volume *volume)
 #ifdef CONFIG_AFS_FSCACHE
 	volume->cache = fscache_acquire_cookie(volume->cell->cache,
 					       &afs_volume_cache_index_def,
+					       &volume->vid, sizeof(volume->vid),
+					       NULL, 0,
 					       volume, true);
 #endif
 
@@ -245,7 +247,7 @@ void afs_deactivate_volume(struct afs_volume *volume)
 	write_unlock(&volume->cell->proc_lock);
 
 #ifdef CONFIG_AFS_FSCACHE
-	fscache_relinquish_cookie(volume->cache,
+	fscache_relinquish_cookie(volume->cache, NULL,
 				  test_bit(AFS_VOLUME_DELETED, &volume->flags));
 	volume->cache = NULL;
 #endif
diff --git a/fs/cachefiles/interface.c b/fs/cachefiles/interface.c
index 405ebc3932c2..3264dcfdc92a 100644
--- a/fs/cachefiles/interface.c
+++ b/fs/cachefiles/interface.c
@@ -32,7 +32,7 @@ static struct fscache_object *cachefiles_alloc_object(
 	struct cachefiles_cache *cache;
 	struct cachefiles_xattr *auxdata;
 	unsigned keylen, auxlen;
-	void *buffer;
+	void *buffer, *p;
 	char *key;
 
 	cache = container_of(_cache, struct cachefiles_cache, cache);
@@ -65,8 +65,12 @@ static struct fscache_object *cachefiles_alloc_object(
 	if (!buffer)
 		goto nomem_buffer;
 
-	keylen = cookie->def->get_key(cookie->netfs_data, buffer + 2, 512);
-	ASSERTCMP(keylen, <, 512);
+	keylen = cookie->key_len;
+	if (keylen <= sizeof(cookie->inline_key))
+		p = cookie->inline_key;
+	else
+		p = cookie->key;
+	memcpy(buffer + 2, p, keylen);
 
 	*(uint16_t *)buffer = keylen;
 	((char *)buffer)[keylen + 2] = 0;
@@ -80,15 +84,17 @@ static struct fscache_object *cachefiles_alloc_object(
 
 	/* get hold of the auxiliary data and prepend the object type */
 	auxdata = buffer;
-	auxlen = 0;
-	if (cookie->def->get_aux) {
-		auxlen = cookie->def->get_aux(cookie->netfs_data,
-					      auxdata->data, 511);
-		ASSERTCMP(auxlen, <, 511);
+	auxlen = cookie->aux_len;
+	if (auxlen) {
+		if (auxlen <= sizeof(cookie->inline_aux))
+			p = cookie->inline_aux;
+		else
+			p = cookie->aux;
+		memcpy(auxdata->data, p, auxlen);
 	}
 
 	auxdata->len = auxlen + 1;
-	auxdata->type = cookie->def->type;
+	auxdata->type = cookie->type;
 
 	lookup_data->auxdata = auxdata;
 	lookup_data->key = key;
@@ -206,6 +212,7 @@ static void cachefiles_update_object(struct fscache_object *_object)
 	struct cachefiles_cache *cache;
 	struct fscache_cookie *cookie;
 	const struct cred *saved_cred;
+	const void *aux;
 	unsigned auxlen;
 
 	_enter("{OBJ%x}", _object->debug_id);
@@ -220,26 +227,29 @@ static void cachefiles_update_object(struct fscache_object *_object)
 	}
 
 	cookie = object->fscache.cookie;
+	auxlen = cookie->aux_len;
 
-	if (!cookie->def->get_aux) {
+	if (!auxlen) {
 		fscache_unuse_cookie(_object);
 		_leave(" [no aux]");
 		return;
 	}
 
-	auxdata = kmalloc(2 + 512 + 3, cachefiles_gfp);
+	auxdata = kmalloc(2 + auxlen + 3, cachefiles_gfp);
 	if (!auxdata) {
 		fscache_unuse_cookie(_object);
 		_leave(" [nomem]");
 		return;
 	}
 
-	auxlen = cookie->def->get_aux(cookie->netfs_data, auxdata->data, 511);
+	aux = (auxlen <= sizeof(cookie->inline_aux)) ?
+		cookie->inline_aux : cookie->aux;
+
+	memcpy(auxdata->data, aux, auxlen);
 	fscache_unuse_cookie(_object);
-	ASSERTCMP(auxlen, <, 511);
 
 	auxdata->len = auxlen + 1;
-	auxdata->type = cookie->def->type;
+	auxdata->type = cookie->type;
 
 	cachefiles_begin_secure(cache, &saved_cred);
 	cachefiles_update_object_xattr(object, auxdata);
diff --git a/fs/cachefiles/namei.c b/fs/cachefiles/namei.c
index 5fc214256316..0daa1e3fe0df 100644
--- a/fs/cachefiles/namei.c
+++ b/fs/cachefiles/namei.c
@@ -30,11 +30,11 @@
  */
 static noinline
 void __cachefiles_printk_object(struct cachefiles_object *object,
-				const char *prefix,
-				u8 *keybuf)
+				const char *prefix)
 {
 	struct fscache_cookie *cookie;
-	unsigned keylen, loop;
+	const u8 *k;
+	unsigned loop;
 
 	pr_err("%sobject: OBJ%x\n", prefix, object->fscache.debug_id);
 	pr_err("%sobjstate=%s fl=%lx wbusy=%x ev=%lx[%lx]\n",
@@ -56,23 +56,16 @@ void __cachefiles_printk_object(struct cachefiles_object *object,
 		       object->fscache.cookie->parent,
 		       object->fscache.cookie->netfs_data,
 		       object->fscache.cookie->flags);
-		if (keybuf && cookie->def)
-			keylen = cookie->def->get_key(cookie->netfs_data, keybuf,
-						      CACHEFILES_KEYBUF_SIZE);
-		else
-			keylen = 0;
+		pr_err("%skey=[%u] '", prefix, cookie->key_len);
+		k = (cookie->key_len <= sizeof(cookie->inline_key)) ?
+			cookie->inline_key : cookie->key;
+		for (loop = 0; loop < cookie->key_len; loop++)
+			pr_cont("%02x", k[loop]);
+		pr_cont("'\n");
 	} else {
 		pr_err("%scookie=NULL\n", prefix);
-		keylen = 0;
 	}
 	spin_unlock(&object->fscache.lock);
-
-	if (keylen) {
-		pr_err("%skey=[%u] '", prefix, keylen);
-		for (loop = 0; loop < keylen; loop++)
-			pr_cont("%02x", keybuf[loop]);
-		pr_cont("'\n");
-	}
 }
 
 /*
@@ -81,14 +74,10 @@ void __cachefiles_printk_object(struct cachefiles_object *object,
 static noinline void cachefiles_printk_object(struct cachefiles_object *object,
 					      struct cachefiles_object *xobject)
 {
-	u8 *keybuf;
-
-	keybuf = kmalloc(CACHEFILES_KEYBUF_SIZE, GFP_NOIO);
 	if (object)
-		__cachefiles_printk_object(object, "", keybuf);
+		__cachefiles_printk_object(object, "");
 	if (xobject)
-		__cachefiles_printk_object(xobject, "x", keybuf);
-	kfree(keybuf);
+		__cachefiles_printk_object(xobject, "x");
 }
 
 /*
diff --git a/fs/cachefiles/xattr.c b/fs/cachefiles/xattr.c
index d31c1a72d8a5..d84423c264af 100644
--- a/fs/cachefiles/xattr.c
+++ b/fs/cachefiles/xattr.c
@@ -113,6 +113,7 @@ int cachefiles_set_object_xattr(struct cachefiles_object *object,
 	/* attempt to install the cache metadata directly */
 	_debug("SET #%u", auxdata->len);
 
+	clear_bit(FSCACHE_COOKIE_AUX_UPDATED, &object->fscache.cookie->flags);
 	ret = vfs_setxattr(dentry, cachefiles_xattr_cache,
 			   &auxdata->type, auxdata->len,
 			   XATTR_CREATE);
@@ -141,6 +142,7 @@ int cachefiles_update_object_xattr(struct cachefiles_object *object,
 	/* attempt to install the cache metadata directly */
 	_debug("SET #%u", auxdata->len);
 
+	clear_bit(FSCACHE_COOKIE_AUX_UPDATED, &object->fscache.cookie->flags);
 	ret = vfs_setxattr(dentry, cachefiles_xattr_cache,
 			   &auxdata->type, auxdata->len,
 			   XATTR_REPLACE);
diff --git a/fs/ceph/cache.c b/fs/ceph/cache.c
index a3ab265d3215..fee869061f05 100644
--- a/fs/ceph/cache.c
+++ b/fs/ceph/cache.c
@@ -41,34 +41,15 @@ static LIST_HEAD(ceph_fscache_list);
 struct ceph_fscache_entry {
 	struct list_head list;
 	struct fscache_cookie *fscache;
-	struct ceph_fsid fsid;
 	size_t uniq_len;
+	/* The following members must be last */
+	struct ceph_fsid fsid;
 	char uniquifier[0];
 };
 
-static uint16_t ceph_fscache_session_get_key(const void *cookie_netfs_data,
-					     void *buffer, uint16_t maxbuf)
-{
-	const struct ceph_fs_client* fsc = cookie_netfs_data;
-	const char *fscache_uniq = fsc->mount_options->fscache_uniq;
-	uint16_t fsid_len, uniq_len;
-
-	fsid_len = sizeof(fsc->client->fsid);
-	uniq_len = fscache_uniq ? strlen(fscache_uniq) : 0;
-	if (fsid_len + uniq_len > maxbuf)
-		return 0;
-
-	memcpy(buffer, &fsc->client->fsid, fsid_len);
-	if (uniq_len)
-		memcpy(buffer + fsid_len, fscache_uniq, uniq_len);
-
-	return fsid_len + uniq_len;
-}
-
 static const struct fscache_cookie_def ceph_fscache_fsid_object_def = {
 	.name		= "CEPH.fsid",
 	.type		= FSCACHE_COOKIE_TYPE_INDEX,
-	.get_key	= ceph_fscache_session_get_key,
 };
 
 int ceph_fscache_register(void)
@@ -110,16 +91,19 @@ int ceph_fscache_register_fs(struct ceph_fs_client* fsc)
 		goto out_unlock;
 	}
 
+	memcpy(&ent->fsid, fsid, sizeof(*fsid));
+	if (uniq_len > 0) {
+		memcpy(&ent->uniquifier, fscache_uniq, uniq_len);
+		ent->uniq_len = uniq_len;
+	}
+
 	fsc->fscache = fscache_acquire_cookie(ceph_cache_netfs.primary_index,
 					      &ceph_fscache_fsid_object_def,
+					      &ent->fsid, sizeof(ent->fsid) + uniq_len,
+					      NULL, 0,
 					      fsc, true);
 
 	if (fsc->fscache) {
-		memcpy(&ent->fsid, fsid, sizeof(*fsid));
-		if (uniq_len > 0) {
-			memcpy(&ent->uniquifier, fscache_uniq, uniq_len);
-			ent->uniq_len = uniq_len;
-		}
 		ent->fscache = fsc->fscache;
 		list_add_tail(&ent->list, &ceph_fscache_list);
 	} else {
@@ -133,38 +117,6 @@ int ceph_fscache_register_fs(struct ceph_fs_client* fsc)
 	return err;
 }
 
-static uint16_t ceph_fscache_inode_get_key(const void *cookie_netfs_data,
-					   void *buffer, uint16_t maxbuf)
-{
-	const struct ceph_inode_info* ci = cookie_netfs_data;
-	uint16_t klen;
-
-	/* use ceph virtual inode (id + snapshot) */
-	klen = sizeof(ci->i_vino);
-	if (klen > maxbuf)
-		return 0;
-
-	memcpy(buffer, &ci->i_vino, klen);
-	return klen;
-}
-
-static uint16_t ceph_fscache_inode_get_aux(const void *cookie_netfs_data,
-					   void *buffer, uint16_t bufmax)
-{
-	struct ceph_aux_inode aux;
-	const struct ceph_inode_info* ci = cookie_netfs_data;
-	const struct inode* inode = &ci->vfs_inode;
-
-	memset(&aux, 0, sizeof(aux));
-	aux.version = ci->i_version;
-	aux.mtime = inode->i_mtime;
-	aux.size = i_size_read(inode);
-
-	memcpy(buffer, &aux, sizeof(aux));
-
-	return sizeof(aux);
-}
-
 static void ceph_fscache_inode_get_attr(const void *cookie_netfs_data,
 					uint64_t *size)
 {
@@ -197,9 +149,7 @@ static enum fscache_checkaux ceph_fscache_inode_check_aux(
 static const struct fscache_cookie_def ceph_fscache_inode_object_def = {
 	.name		= "CEPH.inode",
 	.type		= FSCACHE_COOKIE_TYPE_DATAFILE,
-	.get_key	= ceph_fscache_inode_get_key,
 	.get_attr	= ceph_fscache_inode_get_attr,
-	.get_aux	= ceph_fscache_inode_get_aux,
 	.check_aux	= ceph_fscache_inode_check_aux,
 };
 
@@ -207,6 +157,7 @@ void ceph_fscache_register_inode_cookie(struct inode *inode)
 {
 	struct ceph_inode_info *ci = ceph_inode(inode);
 	struct ceph_fs_client *fsc = ceph_inode_to_client(inode);
+	struct ceph_aux_inode aux;
 
 	/* No caching for filesystem */
 	if (!fsc->fscache)
@@ -218,9 +169,15 @@ void ceph_fscache_register_inode_cookie(struct inode *inode)
 
 	inode_lock_nested(inode, I_MUTEX_CHILD);
 	if (!ci->fscache) {
+		memset(&aux, 0, sizeof(aux));
+		aux.version = ci->i_version;
+		aux.mtime = inode->i_mtime;
+		aux.size = i_size_read(inode);
 		ci->fscache = fscache_acquire_cookie(fsc->fscache,
-					&ceph_fscache_inode_object_def,
-					ci, false);
+						     &ceph_fscache_inode_object_def,
+						     &ci->i_vino, sizeof(ci->i_vino),
+						     &aux, sizeof(aux),
+						     ci, false);
 	}
 	inode_unlock(inode);
 }
@@ -235,7 +192,7 @@ void ceph_fscache_unregister_inode_cookie(struct ceph_inode_info* ci)
 	ci->fscache = NULL;
 
 	fscache_uncache_all_inode_pages(cookie, &ci->vfs_inode);
-	fscache_relinquish_cookie(cookie, 0);
+	fscache_relinquish_cookie(cookie, &ci->i_vino, false);
 }
 
 static bool ceph_fscache_can_enable(void *data)
@@ -254,11 +211,11 @@ void ceph_fscache_file_set_cookie(struct inode *inode, struct file *filp)
 	if (inode_is_open_for_write(inode)) {
 		dout("fscache_file_set_cookie %p %p disabling cache\n",
 		     inode, filp);
-		fscache_disable_cookie(ci->fscache, false);
+		fscache_disable_cookie(ci->fscache, &ci->i_vino, false);
 		fscache_uncache_all_inode_pages(ci->fscache, inode);
 	} else {
-		fscache_enable_cookie(ci->fscache, ceph_fscache_can_enable,
-				inode);
+		fscache_enable_cookie(ci->fscache, &ci->i_vino,
+				      ceph_fscache_can_enable, inode);
 		if (fscache_cookie_enabled(ci->fscache)) {
 			dout("fscache_file_set_cookie %p %p enabling cache\n",
 			     inode, filp);
@@ -385,7 +342,7 @@ void ceph_fscache_unregister_fs(struct ceph_fs_client* fsc)
 		WARN_ON_ONCE(!found);
 		mutex_unlock(&ceph_fscache_lock);
 
-		__fscache_relinquish_cookie(fsc->fscache, 0);
+		__fscache_relinquish_cookie(fsc->fscache, NULL, false);
 	}
 	fsc->fscache = NULL;
 }
@@ -402,7 +359,7 @@ void ceph_fscache_revalidate_cookie(struct ceph_inode_info *ci)
 	 * truncate while the caller holds CEPH_CAP_FILE_RD */
 	mutex_lock(&ci->i_truncate_mutex);
 	if (!cache_valid(ci)) {
-		if (fscache_check_consistency(ci->fscache))
+		if (fscache_check_consistency(ci->fscache, &ci->i_vino))
 			fscache_invalidate(ci->fscache);
 		spin_lock(&ci->i_ceph_lock);
 		ci->i_fscache_gen = ci->i_rdcache_gen;
diff --git a/fs/cifs/cache.c b/fs/cifs/cache.c
index 2c14020e5e1d..b4fa270ef532 100644
--- a/fs/cifs/cache.c
+++ b/fs/cifs/cache.c
@@ -45,68 +45,12 @@ void cifs_fscache_unregister(void)
 	fscache_unregister_netfs(&cifs_fscache_netfs);
 }
 
-/*
- * Key layout of CIFS server cache index object
- */
-struct cifs_server_key {
-	uint16_t	family;		/* address family */
-	__be16		port;		/* IP port */
-	union {
-		struct in_addr	ipv4_addr;
-		struct in6_addr	ipv6_addr;
-	} addr[0];
-};
-
-/*
- * Server object keyed by {IPaddress,port,family} tuple
- */
-static uint16_t cifs_server_get_key(const void *cookie_netfs_data,
-				   void *buffer, uint16_t maxbuf)
-{
-	const struct TCP_Server_Info *server = cookie_netfs_data;
-	const struct sockaddr *sa = (struct sockaddr *) &server->dstaddr;
-	const struct sockaddr_in *addr = (struct sockaddr_in *) sa;
-	const struct sockaddr_in6 *addr6 = (struct sockaddr_in6 *) sa;
-	struct cifs_server_key *key = buffer;
-	uint16_t key_len = sizeof(struct cifs_server_key);
-
-	memset(key, 0, key_len);
-
-	/*
-	 * Should not be a problem as sin_family/sin6_family overlays
-	 * sa_family field
-	 */
-	switch (sa->sa_family) {
-	case AF_INET:
-		key->family = sa->sa_family;
-		key->port = addr->sin_port;
-		key->addr[0].ipv4_addr = addr->sin_addr;
-		key_len += sizeof(key->addr[0].ipv4_addr);
-		break;
-
-	case AF_INET6:
-		key->family = sa->sa_family;
-		key->port = addr6->sin6_port;
-		key->addr[0].ipv6_addr = addr6->sin6_addr;
-		key_len += sizeof(key->addr[0].ipv6_addr);
-		break;
-
-	default:
-		cifs_dbg(VFS, "Unknown network family '%d'\n", sa->sa_family);
-		key_len = 0;
-		break;
-	}
-
-	return key_len;
-}
-
 /*
  * Server object for FS-Cache
  */
 const struct fscache_cookie_def cifs_fscache_server_index_def = {
 	.name = "CIFS.server",
 	.type = FSCACHE_COOKIE_TYPE_INDEX,
-	.get_key = cifs_server_get_key,
 };
 
 /*
@@ -116,7 +60,7 @@ struct cifs_fscache_super_auxdata {
 	u64	resource_id;		/* unique server resource id */
 };
 
-static char *extract_sharename(const char *treename)
+char *extract_sharename(const char *treename)
 {
 	const char *src;
 	char *delim, *dst;
@@ -140,52 +84,6 @@ static char *extract_sharename(const char *treename)
 	return dst;
 }
 
-/*
- * Superblock object currently keyed by share name
- */
-static uint16_t cifs_super_get_key(const void *cookie_netfs_data, void *buffer,
-				   uint16_t maxbuf)
-{
-	const struct cifs_tcon *tcon = cookie_netfs_data;
-	char *sharename;
-	uint16_t len;
-
-	sharename = extract_sharename(tcon->treeName);
-	if (IS_ERR(sharename)) {
-		cifs_dbg(FYI, "%s: couldn't extract sharename\n", __func__);
-		sharename = NULL;
-		return 0;
-	}
-
-	len = strlen(sharename);
-	if (len > maxbuf)
-		return 0;
-
-	memcpy(buffer, sharename, len);
-
-	kfree(sharename);
-
-	return len;
-}
-
-static uint16_t
-cifs_fscache_super_get_aux(const void *cookie_netfs_data, void *buffer,
-			   uint16_t maxbuf)
-{
-	struct cifs_fscache_super_auxdata auxdata;
-	const struct cifs_tcon *tcon = cookie_netfs_data;
-
-	memset(&auxdata, 0, sizeof(auxdata));
-	auxdata.resource_id = tcon->resource_id;
-
-	if (maxbuf > sizeof(auxdata))
-		maxbuf = sizeof(auxdata);
-
-	memcpy(buffer, &auxdata, maxbuf);
-
-	return maxbuf;
-}
-
 static enum
 fscache_checkaux cifs_fscache_super_check_aux(void *cookie_netfs_data,
 					      const void *data,
@@ -212,36 +110,9 @@ fscache_checkaux cifs_fscache_super_check_aux(void *cookie_netfs_data,
 const struct fscache_cookie_def cifs_fscache_super_index_def = {
 	.name = "CIFS.super",
 	.type = FSCACHE_COOKIE_TYPE_INDEX,
-	.get_key = cifs_super_get_key,
-	.get_aux = cifs_fscache_super_get_aux,
 	.check_aux = cifs_fscache_super_check_aux,
 };
 
-/*
- * Auxiliary data attached to CIFS inode within the cache
- */
-struct cifs_fscache_inode_auxdata {
-	struct timespec	last_write_time;
-	struct timespec	last_change_time;
-	u64		eof;
-};
-
-static uint16_t cifs_fscache_inode_get_key(const void *cookie_netfs_data,
-					   void *buffer, uint16_t maxbuf)
-{
-	const struct cifsInodeInfo *cifsi = cookie_netfs_data;
-	uint16_t keylen;
-
-	/* use the UniqueId as the key */
-	keylen = sizeof(cifsi->uniqueid);
-	if (keylen > maxbuf)
-		keylen = 0;
-	else
-		memcpy(buffer, &cifsi->uniqueid, keylen);
-
-	return keylen;
-}
-
 static void
 cifs_fscache_inode_get_attr(const void *cookie_netfs_data, uint64_t *size)
 {
@@ -250,26 +121,6 @@ cifs_fscache_inode_get_attr(const void *cookie_netfs_data, uint64_t *size)
 	*size = cifsi->vfs_inode.i_size;
 }
 
-static uint16_t
-cifs_fscache_inode_get_aux(const void *cookie_netfs_data, void *buffer,
-			   uint16_t maxbuf)
-{
-	struct cifs_fscache_inode_auxdata auxdata;
-	const struct cifsInodeInfo *cifsi = cookie_netfs_data;
-
-	memset(&auxdata, 0, sizeof(auxdata));
-	auxdata.eof = cifsi->server_eof;
-	auxdata.last_write_time = cifsi->vfs_inode.i_mtime;
-	auxdata.last_change_time = cifsi->vfs_inode.i_ctime;
-
-	if (maxbuf > sizeof(auxdata))
-		maxbuf = sizeof(auxdata);
-
-	memcpy(buffer, &auxdata, maxbuf);
-
-	return maxbuf;
-}
-
 static enum
 fscache_checkaux cifs_fscache_inode_check_aux(void *cookie_netfs_data,
 					      const void *data,
@@ -295,8 +146,6 @@ fscache_checkaux cifs_fscache_inode_check_aux(void *cookie_netfs_data,
 const struct fscache_cookie_def cifs_fscache_inode_object_def = {
 	.name		= "CIFS.uniqueid",
 	.type		= FSCACHE_COOKIE_TYPE_DATAFILE,
-	.get_key	= cifs_fscache_inode_get_key,
 	.get_attr	= cifs_fscache_inode_get_attr,
-	.get_aux	= cifs_fscache_inode_get_aux,
 	.check_aux	= cifs_fscache_inode_check_aux,
 };
diff --git a/fs/cifs/fscache.c b/fs/cifs/fscache.c
index 8d4b7bc8ae91..83bcfeb6f8b4 100644
--- a/fs/cifs/fscache.c
+++ b/fs/cifs/fscache.c
@@ -23,11 +23,63 @@
 #include "cifs_debug.h"
 #include "cifs_fs_sb.h"
 
+/*
+ * Key layout of CIFS server cache index object
+ */
+struct cifs_server_key {
+	struct {
+		uint16_t	family;		/* address family */
+		__be16		port;		/* IP port */
+	} hdr;
+	union {
+		struct in_addr	ipv4_addr;
+		struct in6_addr	ipv6_addr;
+	};
+} __packed;
+
+/*
+ * Get a cookie for a server object keyed by {IPaddress,port,family} tuple
+ */
 void cifs_fscache_get_client_cookie(struct TCP_Server_Info *server)
 {
+	const struct sockaddr *sa = (struct sockaddr *) &server->dstaddr;
+	const struct sockaddr_in *addr = (struct sockaddr_in *) sa;
+	const struct sockaddr_in6 *addr6 = (struct sockaddr_in6 *) sa;
+	struct cifs_server_key key;
+	uint16_t key_len = sizeof(key.hdr);
+
+	memset(&key, 0, sizeof(key));
+
+	/*
+	 * Should not be a problem as sin_family/sin6_family overlays
+	 * sa_family field
+	 */
+	key.hdr.family = sa->sa_family;
+	switch (sa->sa_family) {
+	case AF_INET:
+		key.hdr.port = addr->sin_port;
+		key.ipv4_addr = addr->sin_addr;
+		key_len += sizeof(key.ipv4_addr);
+		break;
+
+	case AF_INET6:
+		key.hdr.port = addr6->sin6_port;
+		key.ipv6_addr = addr6->sin6_addr;
+		key_len += sizeof(key.ipv6_addr);
+		break;
+
+	default:
+		cifs_dbg(VFS, "Unknown network family '%d'\n", sa->sa_family);
+		server->fscache = NULL;
+		return;
+	}
+
 	server->fscache =
 		fscache_acquire_cookie(cifs_fscache_netfs.primary_index,
-				&cifs_fscache_server_index_def, server, true);
+				       &cifs_fscache_server_index_def,
+				       &key, key_len,
+				       NULL, 0,
+				       server, true);
 	cifs_dbg(FYI, "%s: (0x%p/0x%p)\n",
 		 __func__, server, server->fscache);
 }
@@ -36,17 +88,29 @@ void cifs_fscache_release_client_cookie(struct TCP_Server_Info *server)
 {
 	cifs_dbg(FYI, "%s: (0x%p/0x%p)\n",
 		 __func__, server, server->fscache);
-	fscache_relinquish_cookie(server->fscache, 0);
+	fscache_relinquish_cookie(server->fscache, NULL, false);
 	server->fscache = NULL;
 }
 
 void cifs_fscache_get_super_cookie(struct cifs_tcon *tcon)
 {
 	struct TCP_Server_Info *server = tcon->ses->server;
+	char *sharename;
+
+	sharename = extract_sharename(tcon->treeName);
+	if (IS_ERR(sharename)) {
+		cifs_dbg(FYI, "%s: couldn't extract sharename\n", __func__);
+		tcon->fscache = NULL;
+		return;
+	}
 
 	tcon->fscache =
 		fscache_acquire_cookie(server->fscache,
-				&cifs_fscache_super_index_def, tcon, true);
+				       &cifs_fscache_super_index_def,
+				       sharename, strlen(sharename),
+				       &tcon->resource_id, sizeof(tcon->resource_id),
+				       tcon, true);
+	kfree(sharename);
 	cifs_dbg(FYI, "%s: (0x%p/0x%p)\n",
 		 __func__, server->fscache, tcon->fscache);
 }
@@ -54,10 +118,28 @@ void cifs_fscache_get_super_cookie(struct cifs_tcon *tcon)
 void cifs_fscache_release_super_cookie(struct cifs_tcon *tcon)
 {
 	cifs_dbg(FYI, "%s: (0x%p)\n", __func__, tcon->fscache);
-	fscache_relinquish_cookie(tcon->fscache, 0);
+	fscache_relinquish_cookie(tcon->fscache, &tcon->resource_id, false);
 	tcon->fscache = NULL;
 }
 
+static void cifs_fscache_acquire_inode_cookie(struct cifsInodeInfo *cifsi,
+					      struct cifs_tcon *tcon)
+{
+	struct cifs_fscache_inode_auxdata auxdata;
+
+	memset(&auxdata, 0, sizeof(auxdata));
+	auxdata.eof = cifsi->server_eof;
+	auxdata.last_write_time = cifsi->vfs_inode.i_mtime;
+	auxdata.last_change_time = cifsi->vfs_inode.i_ctime;
+
+	cifsi->fscache =
+		fscache_acquire_cookie(tcon->fscache,
+				       &cifs_fscache_inode_object_def,
+				       &cifsi->uniqueid, sizeof(cifsi->uniqueid),
+				       &auxdata, sizeof(&auxdata),
+				       cifsi, true);
+}
+
 static void cifs_fscache_enable_inode_cookie(struct inode *inode)
 {
 	struct cifsInodeInfo *cifsi = CIFS_I(inode);
@@ -67,21 +149,28 @@ static void cifs_fscache_enable_inode_cookie(struct inode *inode)
 	if (cifsi->fscache)
 		return;
 
-	if (cifs_sb->mnt_cifs_flags & CIFS_MOUNT_FSCACHE) {
-		cifsi->fscache = fscache_acquire_cookie(tcon->fscache,
-				&cifs_fscache_inode_object_def, cifsi, true);
-		cifs_dbg(FYI, "%s: got FH cookie (0x%p/0x%p)\n",
-			 __func__, tcon->fscache, cifsi->fscache);
-	}
+	if (!(cifs_sb->mnt_cifs_flags & CIFS_MOUNT_FSCACHE))
+		return;
+
+	cifs_fscache_acquire_inode_cookie(cifsi, tcon);
+
+	cifs_dbg(FYI, "%s: got FH cookie (0x%p/0x%p)\n",
+		 __func__, tcon->fscache, cifsi->fscache);
 }
 
 void cifs_fscache_release_inode_cookie(struct inode *inode)
 {
+	struct cifs_fscache_inode_auxdata auxdata;
 	struct cifsInodeInfo *cifsi = CIFS_I(inode);
 
 	if (cifsi->fscache) {
+		memset(&auxdata, 0, sizeof(auxdata));
+		auxdata.eof = cifsi->server_eof;
+		auxdata.last_write_time = cifsi->vfs_inode.i_mtime;
+		auxdata.last_change_time = cifsi->vfs_inode.i_ctime;
+
 		cifs_dbg(FYI, "%s: (0x%p)\n", __func__, cifsi->fscache);
-		fscache_relinquish_cookie(cifsi->fscache, 0);
+		fscache_relinquish_cookie(cifsi->fscache, &auxdata, false);
 		cifsi->fscache = NULL;
 	}
 }
@@ -93,7 +182,7 @@ static void cifs_fscache_disable_inode_cookie(struct inode *inode)
 	if (cifsi->fscache) {
 		cifs_dbg(FYI, "%s: (0x%p)\n", __func__, cifsi->fscache);
 		fscache_uncache_all_inode_pages(cifsi->fscache, inode);
-		fscache_relinquish_cookie(cifsi->fscache, 1);
+		fscache_relinquish_cookie(cifsi->fscache, NULL, true);
 		cifsi->fscache = NULL;
 	}
 }
@@ -110,16 +199,14 @@ void cifs_fscache_reset_inode_cookie(struct inode *inode)
 {
 	struct cifsInodeInfo *cifsi = CIFS_I(inode);
 	struct cifs_sb_info *cifs_sb = CIFS_SB(inode->i_sb);
+	struct cifs_tcon *tcon = cifs_sb_master_tcon(cifs_sb);
 	struct fscache_cookie *old = cifsi->fscache;
 
 	if (cifsi->fscache) {
 		/* retire the current fscache cache and get a new one */
-		fscache_relinquish_cookie(cifsi->fscache, 1);
+		fscache_relinquish_cookie(cifsi->fscache, NULL, true);
 
-		cifsi->fscache = fscache_acquire_cookie(
-					cifs_sb_master_tcon(cifs_sb)->fscache,
-					&cifs_fscache_inode_object_def,
-					cifsi, true);
+		cifs_fscache_acquire_inode_cookie(cifsi, tcon);
 		cifs_dbg(FYI, "%s: new cookie 0x%p oldcookie 0x%p\n",
 			 __func__, cifsi->fscache, old);
 	}
@@ -239,4 +326,3 @@ void __cifs_fscache_invalidate_page(struct page *page, struct inode *inode)
 	fscache_wait_on_page_write(cookie, page);
 	fscache_uncache_page(cookie, page);
 }
-
diff --git a/fs/cifs/fscache.h b/fs/cifs/fscache.h
index 24794b6cd8ec..c7e3ac251e16 100644
--- a/fs/cifs/fscache.h
+++ b/fs/cifs/fscache.h
@@ -27,6 +27,18 @@
 
 #ifdef CONFIG_CIFS_FSCACHE
 
+/*
+ * Auxiliary data attached to CIFS inode within the cache
+ */
+struct cifs_fscache_inode_auxdata {
+	struct timespec	last_write_time;
+	struct timespec	last_change_time;
+	u64		eof;
+};
+
+/*
+ * cache.c
+ */
 extern struct fscache_netfs cifs_fscache_netfs;
 extern const struct fscache_cookie_def cifs_fscache_server_index_def;
 extern const struct fscache_cookie_def cifs_fscache_super_index_def;
@@ -34,6 +46,7 @@ extern const struct fscache_cookie_def cifs_fscache_inode_object_def;
 
 extern int cifs_fscache_register(void);
 extern void cifs_fscache_unregister(void);
+extern char *extract_sharename(const char *);
 
 /*
  * fscache.c
diff --git a/fs/fscache/cache.c b/fs/fscache/cache.c
index 56cce7fdd39e..c184c5a356ff 100644
--- a/fs/fscache/cache.c
+++ b/fs/fscache/cache.c
@@ -125,7 +125,7 @@ struct fscache_cache *fscache_select_cache_for_object(
 	}
 
 	/* the parent is unbacked */
-	if (cookie->def->type != FSCACHE_COOKIE_TYPE_INDEX) {
+	if (cookie->type != FSCACHE_COOKIE_TYPE_INDEX) {
 		/* cookie not an index and is unbacked */
 		spin_unlock(&cookie->lock);
 		_leave(" = NULL [cookie ub,ni]");
diff --git a/fs/fscache/cookie.c b/fs/fscache/cookie.c
index 6cf964a46961..598755802882 100644
--- a/fs/fscache/cookie.c
+++ b/fs/fscache/cookie.c
@@ -58,6 +58,8 @@ void fscache_cookie_init_once(void *_cookie)
 struct fscache_cookie *__fscache_acquire_cookie(
 	struct fscache_cookie *parent,
 	const struct fscache_cookie_def *def,
+	const void *index_key, size_t index_key_len,
+	const void *aux_data, size_t aux_data_len,
 	void *netfs_data,
 	bool enable)
 {
@@ -69,6 +71,13 @@ struct fscache_cookie *__fscache_acquire_cookie(
 	       parent ? (char *) parent->def->name : "<no-parent>",
 	       def->name, netfs_data, enable);
 
+	if (!index_key || !index_key_len || index_key_len > 255 || aux_data_len > 255)
+		return NULL;
+	if (!aux_data || !aux_data_len) {
+		aux_data = NULL;
+		aux_data_len = 0;
+	}
+
 	fscache_stat(&fscache_n_acquires);
 
 	/* if there's no parent cookie, then we don't create one here either */
@@ -79,11 +88,10 @@ struct fscache_cookie *__fscache_acquire_cookie(
 	}
 
 	/* validate the definition */
-	BUG_ON(!def->get_key);
 	BUG_ON(!def->name[0]);
 
 	BUG_ON(def->type == FSCACHE_COOKIE_TYPE_INDEX &&
-	       parent->def->type != FSCACHE_COOKIE_TYPE_INDEX);
+	       parent->type != FSCACHE_COOKIE_TYPE_INDEX);
 
 	/* allocate and initialise a cookie */
 	cookie = kmem_cache_alloc(fscache_cookie_jar, GFP_KERNEL);
@@ -93,6 +101,25 @@ struct fscache_cookie *__fscache_acquire_cookie(
 		return NULL;
 	}
 
+	cookie->key_len		= index_key_len;
+	cookie->aux_len		= aux_data_len;
+
+	if (cookie->key_len <= sizeof(cookie->inline_key)) {
+		memcpy(cookie->inline_key, index_key, cookie->key_len);
+	} else {
+		cookie->key = kmemdup(index_key, cookie->key_len, GFP_KERNEL);
+		if (!cookie->key)
+			goto nomem;
+	}
+
+	if (cookie->aux_len <= sizeof(cookie->inline_aux)) {
+		memcpy(cookie->inline_aux, aux_data, cookie->aux_len);
+	} else {
+		cookie->aux = kmemdup(aux_data, cookie->aux_len, GFP_KERNEL);
+		if (!cookie->aux)
+			goto nomem;
+	}
+
 	atomic_set(&cookie->usage, 1);
 	atomic_set(&cookie->n_children, 0);
 
@@ -108,12 +135,13 @@ struct fscache_cookie *__fscache_acquire_cookie(
 	cookie->parent		= parent;
 	cookie->netfs_data	= netfs_data;
 	cookie->flags		= (1 << FSCACHE_COOKIE_NO_DATA_YET);
-
+	cookie->type		= def->type;
+	
 	/* radix tree insertion won't use the preallocation pool unless it's
 	 * told it may not wait */
 	INIT_RADIX_TREE(&cookie->stores, GFP_NOFS & ~__GFP_DIRECT_RECLAIM);
 
-	switch (cookie->def->type) {
+	switch (cookie->type) {
 	case FSCACHE_COOKIE_TYPE_INDEX:
 		fscache_stat(&fscache_n_cookie_index);
 		break;
@@ -131,7 +159,7 @@ struct fscache_cookie *__fscache_acquire_cookie(
 		/* if the object is an index then we need do nothing more here
 		 * - we create indices on disk when we need them as an index
 		 * may exist in multiple caches */
-		if (cookie->def->type != FSCACHE_COOKIE_TYPE_INDEX) {
+		if (cookie->type != FSCACHE_COOKIE_TYPE_INDEX) {
 			if (fscache_acquire_non_index_cookie(cookie) == 0) {
 				set_bit(FSCACHE_COOKIE_ENABLED, &cookie->flags);
 			} else {
@@ -150,6 +178,14 @@ struct fscache_cookie *__fscache_acquire_cookie(
 	fscache_stat(&fscache_n_acquires_ok);
 	_leave(" = %p", cookie);
 	return cookie;
+
+nomem:
+	if (cookie->aux_len > sizeof(cookie->inline_aux))
+		kfree(cookie->aux);
+	if (cookie->key_len > sizeof(cookie->inline_key))
+		kfree(cookie->key);
+	kmem_cache_free(fscache_cookie_jar, cookie);
+	return NULL;
 }
 EXPORT_SYMBOL(__fscache_acquire_cookie);
 
@@ -157,6 +193,7 @@ EXPORT_SYMBOL(__fscache_acquire_cookie);
  * Enable a cookie to permit it to accept new operations.
  */
 void __fscache_enable_cookie(struct fscache_cookie *cookie,
+			     const void *aux_data,
 			     bool (*can_enable)(void *data),
 			     void *data)
 {
@@ -167,12 +204,14 @@ void __fscache_enable_cookie(struct fscache_cookie *cookie,
 	wait_on_bit_lock(&cookie->flags, FSCACHE_COOKIE_ENABLEMENT_LOCK,
 			 TASK_UNINTERRUPTIBLE);
 
+	fscache_update_aux(cookie, aux_data);
+
 	if (test_bit(FSCACHE_COOKIE_ENABLED, &cookie->flags))
 		goto out_unlock;
 
 	if (can_enable && !can_enable(data)) {
 		/* The netfs decided it didn't want to enable after all */
-	} else if (cookie->def->type != FSCACHE_COOKIE_TYPE_INDEX) {
+	} else if (cookie->type != FSCACHE_COOKIE_TYPE_INDEX) {
 		/* Wait for outstanding disablement to complete */
 		__fscache_wait_on_invalidate(cookie);
 
@@ -431,10 +470,7 @@ void __fscache_invalidate(struct fscache_cookie *cookie)
 	 * there, and if it's doing that, it may as well just retire the
 	 * cookie.
 	 */
-	ASSERTCMP(cookie->def->type, ==, FSCACHE_COOKIE_TYPE_DATAFILE);
-
-	/* We will be updating the cookie too. */
-	BUG_ON(!cookie->def->get_aux);
+	ASSERTCMP(cookie->type, ==, FSCACHE_COOKIE_TYPE_DATAFILE);
 
 	/* If there's an object, we tell the object state machine to handle the
 	 * invalidation on our behalf, otherwise there's nothing to do.
@@ -478,7 +514,7 @@ EXPORT_SYMBOL(__fscache_wait_on_invalidate);
 /*
  * update the index entries backing a cookie
  */
-void __fscache_update_cookie(struct fscache_cookie *cookie)
+void __fscache_update_cookie(struct fscache_cookie *cookie, const void *aux_data)
 {
 	struct fscache_object *object;
 
@@ -492,10 +528,10 @@ void __fscache_update_cookie(struct fscache_cookie *cookie)
 
 	_enter("{%s}", cookie->def->name);
 
-	BUG_ON(!cookie->def->get_aux);
-
 	spin_lock(&cookie->lock);
 
+	fscache_update_aux(cookie, aux_data);
+
 	if (fscache_cookie_enabled(cookie)) {
 		/* update the index entry on disk in each cache backing this
 		 * cookie.
@@ -514,7 +550,9 @@ EXPORT_SYMBOL(__fscache_update_cookie);
 /*
  * Disable a cookie to stop it from accepting new requests from the netfs.
  */
-void __fscache_disable_cookie(struct fscache_cookie *cookie, bool invalidate)
+void __fscache_disable_cookie(struct fscache_cookie *cookie,
+			      const void *aux_data,
+			      bool invalidate)
 {
 	struct fscache_object *object;
 	bool awaken = false;
@@ -533,6 +571,9 @@ void __fscache_disable_cookie(struct fscache_cookie *cookie, bool invalidate)
 
 	wait_on_bit_lock(&cookie->flags, FSCACHE_COOKIE_ENABLEMENT_LOCK,
 			 TASK_UNINTERRUPTIBLE);
+
+	fscache_update_aux(cookie, aux_data);
+
 	if (!test_and_clear_bit(FSCACHE_COOKIE_ENABLED, &cookie->flags))
 		goto out_unlock_enable;
 
@@ -569,7 +610,7 @@ void __fscache_disable_cookie(struct fscache_cookie *cookie, bool invalidate)
 				 TASK_UNINTERRUPTIBLE);
 
 	/* Make sure any pending writes are cancelled. */
-	if (cookie->def->type != FSCACHE_COOKIE_TYPE_INDEX)
+	if (cookie->type != FSCACHE_COOKIE_TYPE_INDEX)
 		fscache_invalidate_writes(cookie);
 
 	/* Reset the cookie state if it wasn't relinquished */
@@ -591,7 +632,9 @@ EXPORT_SYMBOL(__fscache_disable_cookie);
  * - all dependents of this cookie must have already been unregistered
  *   (indices/files/pages)
  */
-void __fscache_relinquish_cookie(struct fscache_cookie *cookie, bool retire)
+void __fscache_relinquish_cookie(struct fscache_cookie *cookie,
+				 const void *aux_data,
+				 bool retire)
 {
 	fscache_stat(&fscache_n_relinquishes);
 	if (retire)
@@ -613,7 +656,7 @@ void __fscache_relinquish_cookie(struct fscache_cookie *cookie, bool retire)
 	if (test_and_set_bit(FSCACHE_COOKIE_RELINQUISHED, &cookie->flags))
 		BUG();
 
-	__fscache_disable_cookie(cookie, retire);
+	__fscache_disable_cookie(cookie, aux_data, retire);
 
 	/* Clear pointers back to the netfs */
 	cookie->netfs_data	= NULL;
@@ -655,6 +698,10 @@ void fscache_cookie_put(struct fscache_cookie *cookie,
 
 		parent = cookie->parent;
 		BUG_ON(!hlist_empty(&cookie->backing_objects));
+		if (cookie->aux_len > sizeof(cookie->inline_aux))
+			kfree(cookie->aux);
+		if (cookie->key_len > sizeof(cookie->inline_key))
+			kfree(cookie->key);
 		kmem_cache_free(fscache_cookie_jar, cookie);
 
 		cookie = parent;
@@ -669,7 +716,8 @@ void fscache_cookie_put(struct fscache_cookie *cookie,
  *
  * NOTE: it only serves no-index type
  */
-int __fscache_check_consistency(struct fscache_cookie *cookie)
+int __fscache_check_consistency(struct fscache_cookie *cookie,
+				const void *aux_data)
 {
 	struct fscache_operation *op;
 	struct fscache_object *object;
@@ -678,7 +726,7 @@ int __fscache_check_consistency(struct fscache_cookie *cookie)
 
 	_enter("%p,", cookie);
 
-	ASSERTCMP(cookie->def->type, ==, FSCACHE_COOKIE_TYPE_DATAFILE);
+	ASSERTCMP(cookie->type, ==, FSCACHE_COOKIE_TYPE_DATAFILE);
 
 	if (fscache_wait_for_deferred_lookup(cookie) < 0)
 		return -ERESTARTSYS;
@@ -698,6 +746,8 @@ int __fscache_check_consistency(struct fscache_cookie *cookie)
 
 	spin_lock(&cookie->lock);
 
+	fscache_update_aux(cookie, aux_data);
+
 	if (!fscache_cookie_enabled(cookie) ||
 	    hlist_empty(&cookie->backing_objects))
 		goto inconsistent;
diff --git a/fs/fscache/fsdef.c b/fs/fscache/fsdef.c
index 5a117df2a9ef..1122e97d56e8 100644
--- a/fs/fscache/fsdef.c
+++ b/fs/fscache/fsdef.c
@@ -13,12 +13,6 @@
 #include <linux/module.h>
 #include "internal.h"
 
-static uint16_t fscache_fsdef_netfs_get_key(const void *cookie_netfs_data,
-					    void *buffer, uint16_t bufmax);
-
-static uint16_t fscache_fsdef_netfs_get_aux(const void *cookie_netfs_data,
-					    void *buffer, uint16_t bufmax);
-
 static
 enum fscache_checkaux fscache_fsdef_netfs_check_aux(void *cookie_netfs_data,
 						    const void *data,
@@ -60,6 +54,7 @@ struct fscache_cookie fscache_fsdef_index = {
 	.backing_objects = HLIST_HEAD_INIT,
 	.def		= &fscache_fsdef_index_def,
 	.flags		= 1 << FSCACHE_COOKIE_ENABLED,
+	.type		= FSCACHE_COOKIE_TYPE_INDEX,
 };
 EXPORT_SYMBOL(fscache_fsdef_index);
 
@@ -71,51 +66,9 @@ EXPORT_SYMBOL(fscache_fsdef_index);
 struct fscache_cookie_def fscache_fsdef_netfs_def = {
 	.name		= "FSDEF.netfs",
 	.type		= FSCACHE_COOKIE_TYPE_INDEX,
-	.get_key	= fscache_fsdef_netfs_get_key,
-	.get_aux	= fscache_fsdef_netfs_get_aux,
 	.check_aux	= fscache_fsdef_netfs_check_aux,
 };
 
-/*
- * get the key data for an FSDEF index record - this is the name of the netfs
- * for which this entry is created
- */
-static uint16_t fscache_fsdef_netfs_get_key(const void *cookie_netfs_data,
-					    void *buffer, uint16_t bufmax)
-{
-	const struct fscache_netfs *netfs = cookie_netfs_data;
-	unsigned klen;
-
-	_enter("{%s.%u},", netfs->name, netfs->version);
-
-	klen = strlen(netfs->name);
-	if (klen > bufmax)
-		return 0;
-
-	memcpy(buffer, netfs->name, klen);
-	return klen;
-}
-
-/*
- * get the auxiliary data for an FSDEF index record - this is the index
- * structure version number of the netfs for which this version is created
- */
-static uint16_t fscache_fsdef_netfs_get_aux(const void *cookie_netfs_data,
-					    void *buffer, uint16_t bufmax)
-{
-	const struct fscache_netfs *netfs = cookie_netfs_data;
-	unsigned dlen;
-
-	_enter("{%s.%u},", netfs->name, netfs->version);
-
-	dlen = sizeof(uint32_t);
-	if (dlen > bufmax)
-		return 0;
-
-	memcpy(buffer, &netfs->version, dlen);
-	return dlen;
-}
-
 /*
  * check that the index structure version number stored in the auxiliary data
  * matches the one the netfs gave us
diff --git a/fs/fscache/internal.h b/fs/fscache/internal.h
index c27e2db3004e..5f905a499306 100644
--- a/fs/fscache/internal.h
+++ b/fs/fscache/internal.h
@@ -342,6 +342,27 @@ void fscache_put_context(struct fscache_cookie *cookie, void *context)
 		cookie->def->put_context(cookie->netfs_data, context);
 }
 
+/*
+ * Update the auxiliary data on a cookie.
+ */
+static inline
+void fscache_update_aux(struct fscache_cookie *cookie, const void *aux_data)
+{
+	void *p;
+
+	if (!aux_data)
+		return;
+	if (cookie->aux_len <= sizeof(cookie->inline_aux))
+		p = cookie->inline_aux;
+	else
+		p = cookie->aux;
+
+	if (memcmp(p, aux_data, cookie->aux_len) != 0) {
+		memcpy(p, aux_data, cookie->aux_len);
+		set_bit(FSCACHE_COOKIE_AUX_UPDATED, &cookie->flags);
+	}
+}
+
 /*****************************************************************************/
 /*
  * debug tracing
diff --git a/fs/fscache/netfs.c b/fs/fscache/netfs.c
index c816600d1dde..a5998dfab7e7 100644
--- a/fs/fscache/netfs.c
+++ b/fs/fscache/netfs.c
@@ -37,6 +37,19 @@ int __fscache_register_netfs(struct fscache_netfs *netfs)
 		return -ENOMEM;
 	}
 
+	cookie->key_len = strlen(netfs->name);
+	if (cookie->key_len <= sizeof(cookie->inline_key)) {
+		memcpy(cookie->inline_key, netfs->name, strlen(netfs->name));
+	} else {
+		ret = -ENOMEM;
+		cookie->key = kmemdup(netfs->name, cookie->key_len, GFP_KERNEL);
+		if (!cookie->key)
+			goto nomem;
+	}
+
+	cookie->aux_len = sizeof(netfs->version);
+	memcpy(cookie->inline_aux, &netfs->version, cookie->aux_len);
+
 	/* initialise the primary index cookie */
 	atomic_set(&cookie->usage, 1);
 	atomic_set(&cookie->n_children, 0);
@@ -46,6 +59,7 @@ int __fscache_register_netfs(struct fscache_netfs *netfs)
 	cookie->parent		= &fscache_fsdef_index;
 	cookie->netfs_data	= netfs;
 	cookie->flags		= 1 << FSCACHE_COOKIE_ENABLED;
+	cookie->type		= FSCACHE_COOKIE_TYPE_INDEX;
 
 	spin_lock_init(&cookie->lock);
 	spin_lock_init(&cookie->stores_lock);
@@ -73,6 +87,7 @@ int __fscache_register_netfs(struct fscache_netfs *netfs)
 already_registered:
 	up_write(&fscache_addremove_sem);
 
+nomem:
 	if (ret < 0)
 		kmem_cache_free(fscache_cookie_jar, cookie);
 
@@ -92,7 +107,7 @@ void __fscache_unregister_netfs(struct fscache_netfs *netfs)
 	down_write(&fscache_addremove_sem);
 
 	list_del(&netfs->link);
-	fscache_relinquish_cookie(netfs->primary_index, 0);
+	fscache_relinquish_cookie(netfs->primary_index, NULL, false);
 
 	up_write(&fscache_addremove_sem);
 
diff --git a/fs/fscache/object-list.c b/fs/fscache/object-list.c
index 0438d4cd91ef..43e6e28c164f 100644
--- a/fs/fscache/object-list.c
+++ b/fs/fscache/object-list.c
@@ -36,8 +36,6 @@ struct fscache_objlist_data {
 #define FSCACHE_OBJLIST_CONFIG_NOEVENTS	0x00000800	/* show objects without no events */
 #define FSCACHE_OBJLIST_CONFIG_WORK	0x00001000	/* show objects with work */
 #define FSCACHE_OBJLIST_CONFIG_NOWORK	0x00002000	/* show objects without work */
-
-	u8		buf[512];	/* key and aux data buffer */
 };
 
 /*
@@ -170,7 +168,7 @@ static int fscache_objlist_show(struct seq_file *m, void *v)
 	struct fscache_cookie *cookie;
 	unsigned long config = data->config;
 	char _type[3], *type;
-	u8 *buf = data->buf, *p;
+	u8 *p;
 
 	if ((unsigned long) v == 1) {
 		seq_puts(m, "OBJECT   PARENT   STAT CHLDN OPS OOP IPR EX READS"
@@ -254,7 +252,7 @@ static int fscache_objlist_show(struct seq_file *m, void *v)
 	if (fscache_use_cookie(obj)) {
 		uint16_t keylen = 0, auxlen = 0;
 
-		switch (cookie->def->type) {
+		switch (cookie->type) {
 		case 0:
 			type = "IX";
 			break;
@@ -263,7 +261,7 @@ static int fscache_objlist_show(struct seq_file *m, void *v)
 			break;
 		default:
 			snprintf(_type, sizeof(_type), "%02u",
-				 cookie->def->type);
+				 cookie->type);
 			type = _type;
 			break;
 		}
@@ -274,30 +272,30 @@ static int fscache_objlist_show(struct seq_file *m, void *v)
 			   cookie->flags,
 			   cookie->netfs_data);
 
-		if (cookie->def->get_key &&
-		    config & FSCACHE_OBJLIST_CONFIG_KEY)
-			keylen = cookie->def->get_key(cookie->netfs_data,
-						      buf, 400);
+		if (config & FSCACHE_OBJLIST_CONFIG_KEY)
+			keylen = cookie->key_len;
 
-		if (cookie->def->get_aux &&
-		    config & FSCACHE_OBJLIST_CONFIG_AUX)
-			auxlen = cookie->def->get_aux(cookie->netfs_data,
-						      buf + keylen, 512 - keylen);
-		fscache_unuse_cookie(obj);
+		if (config & FSCACHE_OBJLIST_CONFIG_AUX)
+			auxlen = cookie->aux_len;
 
 		if (keylen > 0 || auxlen > 0) {
 			seq_puts(m, " ");
-			for (p = buf; keylen > 0; keylen--)
+			p = keylen <= sizeof(cookie->inline_key) ?
+				cookie->inline_key : cookie->key;
+			for (; keylen > 0; keylen--)
 				seq_printf(m, "%02x", *p++);
 			if (auxlen > 0) {
 				if (config & FSCACHE_OBJLIST_CONFIG_KEY)
 					seq_puts(m, ", ");
+				p = auxlen <= sizeof(cookie->inline_aux) ?
+					cookie->inline_aux : cookie->aux;
 				for (; auxlen > 0; auxlen--)
 					seq_printf(m, "%02x", *p++);
 			}
 		}
 
 		seq_puts(m, "\n");
+		fscache_unuse_cookie(obj);
 	} else {
 		seq_puts(m, "<no_netfs>\n");
 	}
diff --git a/fs/fscache/object.c b/fs/fscache/object.c
index 7c0ddb7ae29a..b213030c3265 100644
--- a/fs/fscache/object.c
+++ b/fs/fscache/object.c
@@ -144,6 +144,7 @@ static void fscache_put_object(struct fscache_object *,
 			       enum fscache_obj_ref_trace);
 static bool fscache_enqueue_dependents(struct fscache_object *, int);
 static void fscache_dequeue_object(struct fscache_object *);
+static void fscache_update_aux_data(struct fscache_object *);
 
 /*
  * we need to notify the parent when an op completes that we had outstanding
@@ -711,6 +712,11 @@ static const struct fscache_state *fscache_drop_object(struct fscache_object *ob
 	ASSERT(cookie != NULL);
 	ASSERT(!hlist_unhashed(&object->cookie_link));
 
+	if (test_bit(FSCACHE_COOKIE_AUX_UPDATED, &cookie->flags)) {
+		kdebug("final update");
+		fscache_update_aux_data(object);
+	}
+
 	/* Make sure the cookie no longer points here and that the netfs isn't
 	 * waiting for us.
 	 */
@@ -1036,6 +1042,17 @@ static const struct fscache_state *fscache_invalidate_object(struct fscache_obje
 	return s;
 }
 
+/*
+ * Update auxiliary data.
+ */
+static void fscache_update_aux_data(struct fscache_object *object)
+{
+	fscache_stat(&fscache_n_updates_run);
+	fscache_stat(&fscache_n_cop_update_object);
+	object->cache->ops->update_object(object);
+	fscache_stat_d(&fscache_n_cop_update_object);
+}
+
 /*
  * Asynchronously update an object.
  */
@@ -1044,10 +1061,7 @@ static const struct fscache_state *fscache_update_object(struct fscache_object *
 {
 	_enter("{OBJ%x},%d", object->debug_id, event);
 
-	fscache_stat(&fscache_n_updates_run);
-	fscache_stat(&fscache_n_cop_update_object);
-	object->cache->ops->update_object(object);
-	fscache_stat_d(&fscache_n_cop_update_object);
+	fscache_update_aux_data(object);
 
 	_leave("");
 	return transit_to(WAIT_FOR_CMD);
diff --git a/fs/fscache/operation.c b/fs/fscache/operation.c
index 7a071e1e952d..e30c5975ea58 100644
--- a/fs/fscache/operation.c
+++ b/fs/fscache/operation.c
@@ -506,7 +506,7 @@ void fscache_put_operation(struct fscache_operation *op)
 	if (!atomic_dec_and_test(&op->usage))
 		return;
 
-	trace_fscache_op(op->object->cookie, op, fscache_op_put);
+	trace_fscache_op(op->object ? op->object->cookie : NULL, op, fscache_op_put);
 
 	_debug("PUT OP");
 	ASSERTIFCMP(op->state != FSCACHE_OP_ST_INITIALISED &&
diff --git a/fs/nfs/fscache-index.c b/fs/nfs/fscache-index.c
index 0ee4b93d36ea..6fd3679b7137 100644
--- a/fs/nfs/fscache-index.c
+++ b/fs/nfs/fscache-index.c
@@ -49,59 +49,6 @@ void nfs_fscache_unregister(void)
 	fscache_unregister_netfs(&nfs_fscache_netfs);
 }
 
-/*
- * Layout of the key for an NFS server cache object.
- */
-struct nfs_server_key {
-	uint16_t	nfsversion;		/* NFS protocol version */
-	uint16_t	family;			/* address family */
-	uint16_t	port;			/* IP port */
-	union {
-		struct in_addr	ipv4_addr;	/* IPv4 address */
-		struct in6_addr ipv6_addr;	/* IPv6 address */
-	} addr[0];
-};
-
-/*
- * Generate a key to describe a server in the main NFS index
- * - We return the length of the key, or 0 if we can't generate one
- */
-static uint16_t nfs_server_get_key(const void *cookie_netfs_data,
-				   void *buffer, uint16_t bufmax)
-{
-	const struct nfs_client *clp = cookie_netfs_data;
-	const struct sockaddr_in6 *sin6 = (struct sockaddr_in6 *) &clp->cl_addr;
-	const struct sockaddr_in *sin = (struct sockaddr_in *) &clp->cl_addr;
-	struct nfs_server_key *key = buffer;
-	uint16_t len = sizeof(struct nfs_server_key);
-
-	memset(key, 0, len);
-	key->nfsversion = clp->rpc_ops->version;
-	key->family = clp->cl_addr.ss_family;
-
-	switch (clp->cl_addr.ss_family) {
-	case AF_INET:
-		key->port = sin->sin_port;
-		key->addr[0].ipv4_addr = sin->sin_addr;
-		len += sizeof(key->addr[0].ipv4_addr);
-		break;
-
-	case AF_INET6:
-		key->port = sin6->sin6_port;
-		key->addr[0].ipv6_addr = sin6->sin6_addr;
-		len += sizeof(key->addr[0].ipv6_addr);
-		break;
-
-	default:
-		printk(KERN_WARNING "NFS: Unknown network family '%d'\n",
-		       clp->cl_addr.ss_family);
-		len = 0;
-		break;
-	}
-
-	return len;
-}
-
 /*
  * Define the server object for FS-Cache.  This is used to describe a server
  * object to fscache_acquire_cookie().  It is keyed by the NFS protocol and
@@ -110,32 +57,8 @@ static uint16_t nfs_server_get_key(const void *cookie_netfs_data,
 const struct fscache_cookie_def nfs_fscache_server_index_def = {
 	.name		= "NFS.server",
 	.type 		= FSCACHE_COOKIE_TYPE_INDEX,
-	.get_key	= nfs_server_get_key,
 };
 
-/*
- * Generate a key to describe a superblock key in the main NFS index
- */
-static uint16_t nfs_super_get_key(const void *cookie_netfs_data,
-				  void *buffer, uint16_t bufmax)
-{
-	const struct nfs_fscache_key *key;
-	const struct nfs_server *nfss = cookie_netfs_data;
-	uint16_t len;
-
-	key = nfss->fscache_key;
-	len = sizeof(key->key) + key->key.uniq_len;
-	if (len > bufmax) {
-		len = 0;
-	} else {
-		memcpy(buffer, &key->key, sizeof(key->key));
-		memcpy(buffer + sizeof(key->key),
-		       key->key.uniquifier, key->key.uniq_len);
-	}
-
-	return len;
-}
-
 /*
  * Define the superblock object for FS-Cache.  This is used to describe a
  * superblock object to fscache_acquire_cookie().  It is keyed by all the NFS
@@ -144,40 +67,8 @@ static uint16_t nfs_super_get_key(const void *cookie_netfs_data,
 const struct fscache_cookie_def nfs_fscache_super_index_def = {
 	.name		= "NFS.super",
 	.type 		= FSCACHE_COOKIE_TYPE_INDEX,
-	.get_key	= nfs_super_get_key,
 };
 
-/*
- * Definition of the auxiliary data attached to NFS inode storage objects
- * within the cache.
- *
- * The contents of this struct are recorded in the on-disk local cache in the
- * auxiliary data attached to the data storage object backing an inode.  This
- * permits coherency to be managed when a new inode binds to an already extant
- * cache object.
- */
-struct nfs_fscache_inode_auxdata {
-	struct timespec	mtime;
-	struct timespec	ctime;
-	loff_t		size;
-	u64		change_attr;
-};
-
-/*
- * Generate a key to describe an NFS inode in an NFS server's index
- */
-static uint16_t nfs_fscache_inode_get_key(const void *cookie_netfs_data,
-					  void *buffer, uint16_t bufmax)
-{
-	const struct nfs_inode *nfsi = cookie_netfs_data;
-	uint16_t nsize;
-
-	/* use the inode's NFS filehandle as the key */
-	nsize = nfsi->fh.size;
-	memcpy(buffer, nfsi->fh.data, nsize);
-	return nsize;
-}
-
 /*
  * Get certain file attributes from the netfs data
  * - This function can be absent for an index
@@ -192,35 +83,6 @@ static void nfs_fscache_inode_get_attr(const void *cookie_netfs_data,
 	*size = nfsi->vfs_inode.i_size;
 }
 
-/*
- * Get the auxiliary data from netfs data
- * - This function can be absent if the index carries no state data
- * - Should store the auxiliary data in the buffer
- * - Should return the amount of amount stored
- * - Not permitted to return an error
- * - The netfs data from the cookie being used as the source is presented
- */
-static uint16_t nfs_fscache_inode_get_aux(const void *cookie_netfs_data,
-					  void *buffer, uint16_t bufmax)
-{
-	struct nfs_fscache_inode_auxdata auxdata;
-	const struct nfs_inode *nfsi = cookie_netfs_data;
-
-	memset(&auxdata, 0, sizeof(auxdata));
-	auxdata.size = nfsi->vfs_inode.i_size;
-	auxdata.mtime = nfsi->vfs_inode.i_mtime;
-	auxdata.ctime = nfsi->vfs_inode.i_ctime;
-
-	if (NFS_SERVER(&nfsi->vfs_inode)->nfs_client->rpc_ops->version == 4)
-		auxdata.change_attr = inode_peek_iversion_raw(&nfsi->vfs_inode);
-
-	if (bufmax > sizeof(auxdata))
-		bufmax = sizeof(auxdata);
-
-	memcpy(buffer, &auxdata, bufmax);
-	return bufmax;
-}
-
 /*
  * Consult the netfs about the state of an object
  * - This function can be absent if the index carries no state data
@@ -288,9 +150,7 @@ static void nfs_fh_put_context(void *cookie_netfs_data, void *context)
 const struct fscache_cookie_def nfs_fscache_inode_object_def = {
 	.name		= "NFS.fh",
 	.type		= FSCACHE_COOKIE_TYPE_DATAFILE,
-	.get_key	= nfs_fscache_inode_get_key,
 	.get_attr	= nfs_fscache_inode_get_attr,
-	.get_aux	= nfs_fscache_inode_get_aux,
 	.check_aux	= nfs_fscache_inode_check_aux,
 	.get_context	= nfs_fh_get_context,
 	.put_context	= nfs_fh_put_context,
diff --git a/fs/nfs/fscache.c b/fs/nfs/fscache.c
index d63bea8bbfbb..c45ba2691cee 100644
--- a/fs/nfs/fscache.c
+++ b/fs/nfs/fscache.c
@@ -18,6 +18,7 @@
 #include <linux/in6.h>
 #include <linux/seq_file.h>
 #include <linux/slab.h>
+#include <linux/iversion.h>
 
 #include "internal.h"
 #include "iostat.h"
@@ -28,6 +29,21 @@
 static struct rb_root nfs_fscache_keys = RB_ROOT;
 static DEFINE_SPINLOCK(nfs_fscache_keys_lock);
 
+/*
+ * Layout of the key for an NFS server cache object.
+ */
+struct nfs_server_key {
+	struct {
+		uint16_t	nfsversion;		/* NFS protocol version */
+		uint16_t	family;			/* address family */
+		__be16		port;			/* IP port */
+	} hdr;
+	union {
+		struct in_addr	ipv4_addr;	/* IPv4 address */
+		struct in6_addr ipv6_addr;	/* IPv6 address */
+	};
+} __packed;
+
 /*
  * Get the per-client index cookie for an NFS client if the appropriate mount
  * flag was set
@@ -36,9 +52,40 @@ static DEFINE_SPINLOCK(nfs_fscache_keys_lock);
  */
 void nfs_fscache_get_client_cookie(struct nfs_client *clp)
 {
+	const struct sockaddr_in6 *sin6 = (struct sockaddr_in6 *) &clp->cl_addr;
+	const struct sockaddr_in *sin = (struct sockaddr_in *) &clp->cl_addr;
+	struct nfs_server_key key;
+	uint16_t len = sizeof(key.hdr);
+
+	memset(&key, 0, sizeof(key));
+	key.hdr.nfsversion = clp->rpc_ops->version;
+	key.hdr.family = clp->cl_addr.ss_family;
+
+	switch (clp->cl_addr.ss_family) {
+	case AF_INET:
+		key.hdr.port = sin->sin_port;
+		key.ipv4_addr = sin->sin_addr;
+		len += sizeof(key.ipv4_addr);
+		break;
+
+	case AF_INET6:
+		key.hdr.port = sin6->sin6_port;
+		key.ipv6_addr = sin6->sin6_addr;
+		len += sizeof(key.ipv6_addr);
+		break;
+
+	default:
+		printk(KERN_WARNING "NFS: Unknown network family '%d'\n",
+		       clp->cl_addr.ss_family);
+		clp->fscache = NULL;
+		return;
+	}
+
 	/* create a cache index for looking up filehandles */
 	clp->fscache = fscache_acquire_cookie(nfs_fscache_netfs.primary_index,
 					      &nfs_fscache_server_index_def,
+					      &key, len,
+					      NULL, 0,
 					      clp, true);
 	dfprintk(FSCACHE, "NFS: get client cookie (0x%p/0x%p)\n",
 		 clp, clp->fscache);
@@ -52,7 +99,7 @@ void nfs_fscache_release_client_cookie(struct nfs_client *clp)
 	dfprintk(FSCACHE, "NFS: releasing client cookie (0x%p/0x%p)\n",
 		 clp, clp->fscache);
 
-	fscache_relinquish_cookie(clp->fscache, 0);
+	fscache_relinquish_cookie(clp->fscache, NULL, false);
 	clp->fscache = NULL;
 }
 
@@ -139,6 +186,8 @@ void nfs_fscache_get_super_cookie(struct super_block *sb, const char *uniq, int
 	/* create a cache index for looking up filehandles */
 	nfss->fscache = fscache_acquire_cookie(nfss->nfs_client->fscache,
 					       &nfs_fscache_super_index_def,
+					       key, sizeof(*key) + ulen,
+					       NULL, 0,
 					       nfss, true);
 	dfprintk(FSCACHE, "NFS: get superblock cookie (0x%p/0x%p)\n",
 		 nfss, nfss->fscache);
@@ -163,7 +212,7 @@ void nfs_fscache_release_super_cookie(struct super_block *sb)
 	dfprintk(FSCACHE, "NFS: releasing superblock cookie (0x%p/0x%p)\n",
 		 nfss, nfss->fscache);
 
-	fscache_relinquish_cookie(nfss->fscache, 0);
+	fscache_relinquish_cookie(nfss->fscache, NULL, false);
 	nfss->fscache = NULL;
 
 	if (nfss->fscache_key) {
@@ -180,13 +229,25 @@ void nfs_fscache_release_super_cookie(struct super_block *sb)
  */
 void nfs_fscache_init_inode(struct inode *inode)
 {
+	struct nfs_fscache_inode_auxdata auxdata;
 	struct nfs_inode *nfsi = NFS_I(inode);
 
 	nfsi->fscache = NULL;
 	if (!S_ISREG(inode->i_mode))
 		return;
+
+	memset(&auxdata, 0, sizeof(auxdata));
+	auxdata.size = nfsi->vfs_inode.i_size;
+	auxdata.mtime = nfsi->vfs_inode.i_mtime;
+	auxdata.ctime = nfsi->vfs_inode.i_ctime;
+
+	if (NFS_SERVER(&nfsi->vfs_inode)->nfs_client->rpc_ops->version == 4)
+		auxdata.change_attr = inode_peek_iversion_raw(&nfsi->vfs_inode);
+
 	nfsi->fscache = fscache_acquire_cookie(NFS_SB(inode->i_sb)->fscache,
 					       &nfs_fscache_inode_object_def,
+					       nfsi->fh.data, nfsi->fh.size,
+					       &auxdata, sizeof(auxdata),
 					       nfsi, false);
 }
 
@@ -195,12 +256,17 @@ void nfs_fscache_init_inode(struct inode *inode)
  */
 void nfs_fscache_clear_inode(struct inode *inode)
 {
+	struct nfs_fscache_inode_auxdata auxdata;
 	struct nfs_inode *nfsi = NFS_I(inode);
 	struct fscache_cookie *cookie = nfs_i_fscache(inode);
 
 	dfprintk(FSCACHE, "NFS: clear cookie (0x%p/0x%p)\n", nfsi, cookie);
 
-	fscache_relinquish_cookie(cookie, false);
+	memset(&auxdata, 0, sizeof(auxdata));
+	auxdata.size = nfsi->vfs_inode.i_size;
+	auxdata.mtime = nfsi->vfs_inode.i_mtime;
+	auxdata.ctime = nfsi->vfs_inode.i_ctime;
+	fscache_relinquish_cookie(cookie, &auxdata, false);
 	nfsi->fscache = NULL;
 }
 
@@ -232,20 +298,27 @@ static bool nfs_fscache_can_enable(void *data)
  */
 void nfs_fscache_open_file(struct inode *inode, struct file *filp)
 {
+	struct nfs_fscache_inode_auxdata auxdata;
 	struct nfs_inode *nfsi = NFS_I(inode);
 	struct fscache_cookie *cookie = nfs_i_fscache(inode);
 
 	if (!fscache_cookie_valid(cookie))
 		return;
 
+	memset(&auxdata, 0, sizeof(auxdata));
+	auxdata.size = nfsi->vfs_inode.i_size;
+	auxdata.mtime = nfsi->vfs_inode.i_mtime;
+	auxdata.ctime = nfsi->vfs_inode.i_ctime;
+
 	if (inode_is_open_for_write(inode)) {
 		dfprintk(FSCACHE, "NFS: nfsi 0x%p disabling cache\n", nfsi);
 		clear_bit(NFS_INO_FSCACHE, &nfsi->flags);
-		fscache_disable_cookie(cookie, true);
+		fscache_disable_cookie(cookie, &auxdata, true);
 		fscache_uncache_all_inode_pages(cookie, inode);
 	} else {
 		dfprintk(FSCACHE, "NFS: nfsi 0x%p enabling cache\n", nfsi);
-		fscache_enable_cookie(cookie, nfs_fscache_can_enable, inode);
+		fscache_enable_cookie(cookie, &auxdata,
+				      nfs_fscache_can_enable, inode);
 		if (fscache_cookie_enabled(cookie))
 			set_bit(NFS_INO_FSCACHE, &NFS_I(inode)->flags);
 	}
diff --git a/fs/nfs/fscache.h b/fs/nfs/fscache.h
index d7fe3e799f2f..96e989f579d1 100644
--- a/fs/nfs/fscache.h
+++ b/fs/nfs/fscache.h
@@ -56,6 +56,22 @@ struct nfs_fscache_key {
 	} key;
 };
 
+/*
+ * Definition of the auxiliary data attached to NFS inode storage objects
+ * within the cache.
+ *
+ * The contents of this struct are recorded in the on-disk local cache in the
+ * auxiliary data attached to the data storage object backing an inode.  This
+ * permits coherency to be managed when a new inode binds to an already extant
+ * cache object.
+ */
+struct nfs_fscache_inode_auxdata {
+	struct timespec	mtime;
+	struct timespec	ctime;
+	loff_t		size;
+	u64		change_attr;
+};
+
 /*
  * fscache-index.c
  */
diff --git a/include/linux/fscache.h b/include/linux/fscache.h
index fe0c349684fa..a2d3a2116248 100644
--- a/include/linux/fscache.h
+++ b/include/linux/fscache.h
@@ -83,17 +83,6 @@ struct fscache_cookie_def {
 		const void *parent_netfs_data,
 		const void *cookie_netfs_data);
 
-	/* get an index key
-	 * - should store the key data in the buffer
-	 * - should return the amount of data stored
-	 * - not permitted to return an error
-	 * - the netfs data from the cookie being used as the source is
-	 *   presented
-	 */
-	uint16_t (*get_key)(const void *cookie_netfs_data,
-			    void *buffer,
-			    uint16_t bufmax);
-
 	/* get certain file attributes from the netfs data
 	 * - this function can be absent for an index
 	 * - not permitted to return an error
@@ -102,18 +91,6 @@ struct fscache_cookie_def {
 	 */
 	void (*get_attr)(const void *cookie_netfs_data, uint64_t *size);
 
-	/* get the auxiliary data from netfs data
-	 * - this function can be absent if the index carries no state data
-	 * - should store the auxiliary data in the buffer
-	 * - should return the amount of amount stored
-	 * - not permitted to return an error
-	 * - the netfs data from the cookie being used as the source is
-	 *   presented
-	 */
-	uint16_t (*get_aux)(const void *cookie_netfs_data,
-			    void *buffer,
-			    uint16_t bufmax);
-
 	/* consult the netfs about the state of an object
 	 * - this function can be absent if the index carries no state data
 	 * - the netfs data from the cookie being used as the target is
@@ -186,6 +163,19 @@ struct fscache_cookie {
 #define FSCACHE_COOKIE_RELINQUISHED	4	/* T if cookie has been relinquished */
 #define FSCACHE_COOKIE_ENABLED		5	/* T if cookie is enabled */
 #define FSCACHE_COOKIE_ENABLEMENT_LOCK	6	/* T if cookie is being en/disabled */
+#define FSCACHE_COOKIE_AUX_UPDATED	7	/* T if the auxiliary data was updated */
+
+	u8				type;		/* Type of object */
+	u8				key_len;	/* Length of index key */
+	u8				aux_len;	/* Length of auxiliary data */
+	union {
+		void			*key;		/* Index key */
+		u8			inline_key[16];	/* - If the key is short enough */
+	};
+	union {
+		void			*aux;		/* Auxiliary data */
+		u8			inline_aux[8];	/* - If the aux data is short enough */
+	};
 };
 
 static inline bool fscache_cookie_enabled(struct fscache_cookie *cookie)
@@ -208,10 +198,12 @@ extern void __fscache_release_cache_tag(struct fscache_cache_tag *);
 extern struct fscache_cookie *__fscache_acquire_cookie(
 	struct fscache_cookie *,
 	const struct fscache_cookie_def *,
+	const void *, size_t,
+	const void *, size_t,
 	void *, bool);
-extern void __fscache_relinquish_cookie(struct fscache_cookie *, bool);
-extern int __fscache_check_consistency(struct fscache_cookie *);
-extern void __fscache_update_cookie(struct fscache_cookie *);
+extern void __fscache_relinquish_cookie(struct fscache_cookie *, const void *, bool);
+extern int __fscache_check_consistency(struct fscache_cookie *, const void *);
+extern void __fscache_update_cookie(struct fscache_cookie *, const void *);
 extern int __fscache_attr_changed(struct fscache_cookie *);
 extern void __fscache_invalidate(struct fscache_cookie *);
 extern void __fscache_wait_on_invalidate(struct fscache_cookie *);
@@ -238,8 +230,8 @@ extern void __fscache_uncache_all_inode_pages(struct fscache_cookie *,
 					      struct inode *);
 extern void __fscache_readpages_cancel(struct fscache_cookie *cookie,
 				       struct list_head *pages);
-extern void __fscache_disable_cookie(struct fscache_cookie *, bool);
-extern void __fscache_enable_cookie(struct fscache_cookie *,
+extern void __fscache_disable_cookie(struct fscache_cookie *, const void *, bool);
+extern void __fscache_enable_cookie(struct fscache_cookie *, const void *,
 				    bool (*)(void *), void *);
 
 /**
@@ -317,6 +309,10 @@ void fscache_release_cache_tag(struct fscache_cache_tag *tag)
  * fscache_acquire_cookie - Acquire a cookie to represent a cache object
  * @parent: The cookie that's to be the parent of this one
  * @def: A description of the cache object, including callback operations
+ * @index_key: The index key for this cookie
+ * @index_key_len: Size of the index key
+ * @aux_data: The auxiliary data for the cookie (may be NULL)
+ * @aux_data_len: Size of the auxiliary data buffer
  * @netfs_data: An arbitrary piece of data to be kept in the cookie to
  * represent the cache object to the netfs
  * @enable: Whether or not to enable a data cookie immediately
@@ -332,12 +328,18 @@ static inline
 struct fscache_cookie *fscache_acquire_cookie(
 	struct fscache_cookie *parent,
 	const struct fscache_cookie_def *def,
+	const void *index_key,
+	size_t index_key_len,
+	const void *aux_data,
+	size_t aux_data_len,
 	void *netfs_data,
 	bool enable)
 {
 	if (fscache_cookie_valid(parent) && fscache_cookie_enabled(parent))
-		return __fscache_acquire_cookie(parent, def, netfs_data,
-						enable);
+		return __fscache_acquire_cookie(parent, def,
+						index_key, index_key_len,
+						aux_data, aux_data_len,
+						netfs_data, enable);
 	else
 		return NULL;
 }
@@ -346,36 +348,44 @@ struct fscache_cookie *fscache_acquire_cookie(
  * fscache_relinquish_cookie - Return the cookie to the cache, maybe discarding
  * it
  * @cookie: The cookie being returned
+ * @aux_data: The updated auxiliary data for the cookie (may be NULL)
  * @retire: True if the cache object the cookie represents is to be discarded
  *
  * This function returns a cookie to the cache, forcibly discarding the
- * associated cache object if retire is set to true.
+ * associated cache object if retire is set to true.  The opportunity is
+ * provided to update the auxiliary data in the cache before the object is
+ * disconnected.
  *
  * See Documentation/filesystems/caching/netfs-api.txt for a complete
  * description.
  */
 static inline
-void fscache_relinquish_cookie(struct fscache_cookie *cookie, bool retire)
+void fscache_relinquish_cookie(struct fscache_cookie *cookie,
+			       const void *aux_data,
+			       bool retire)
 {
 	if (fscache_cookie_valid(cookie))
-		__fscache_relinquish_cookie(cookie, retire);
+		__fscache_relinquish_cookie(cookie, aux_data, retire);
 }
 
 /**
- * fscache_check_consistency - Request that if the cache is updated
+ * fscache_check_consistency - Request validation of a cache's auxiliary data
  * @cookie: The cookie representing the cache object
+ * @aux_data: The updated auxiliary data for the cookie (may be NULL)
  *
- * Request an consistency check from fscache, which passes the request
- * to the backing cache.
+ * Request an consistency check from fscache, which passes the request to the
+ * backing cache.  The auxiliary data on the cookie will be updated first if
+ * @aux_data is set.
  *
  * Returns 0 if consistent and -ESTALE if inconsistent.  May also
  * return -ENOMEM and -ERESTARTSYS.
  */
 static inline
-int fscache_check_consistency(struct fscache_cookie *cookie)
+int fscache_check_consistency(struct fscache_cookie *cookie,
+			      const void *aux_data)
 {
 	if (fscache_cookie_valid(cookie) && fscache_cookie_enabled(cookie))
-		return __fscache_check_consistency(cookie);
+		return __fscache_check_consistency(cookie, aux_data);
 	else
 		return 0;
 }
@@ -383,18 +393,20 @@ int fscache_check_consistency(struct fscache_cookie *cookie)
 /**
  * fscache_update_cookie - Request that a cache object be updated
  * @cookie: The cookie representing the cache object
+ * @aux_data: The updated auxiliary data for the cookie (may be NULL)
  *
  * Request an update of the index data for the cache object associated with the
- * cookie.
+ * cookie.  The auxiliary data on the cookie will be updated first if @aux_data
+ * is set.
  *
  * See Documentation/filesystems/caching/netfs-api.txt for a complete
  * description.
  */
 static inline
-void fscache_update_cookie(struct fscache_cookie *cookie)
+void fscache_update_cookie(struct fscache_cookie *cookie, const void *aux_data)
 {
 	if (fscache_cookie_valid(cookie) && fscache_cookie_enabled(cookie))
-		__fscache_update_cookie(cookie);
+		__fscache_update_cookie(cookie, aux_data);
 }
 
 /**
@@ -780,6 +792,7 @@ void fscache_uncache_all_inode_pages(struct fscache_cookie *cookie,
 /**
  * fscache_disable_cookie - Disable a cookie
  * @cookie: The cookie representing the cache object
+ * @aux_data: The updated auxiliary data for the cookie (may be NULL)
  * @invalidate: Invalidate the backing object
  *
  * Disable a cookie from accepting further alloc, read, write, invalidate,
@@ -790,34 +803,41 @@ void fscache_uncache_all_inode_pages(struct fscache_cookie *cookie,
  *
  * If @invalidate is set, then the backing object will be invalidated and
  * detached, otherwise it will just be detached.
+ *
+ * If @aux_data is set, then auxiliary data will be updated from that.
  */
 static inline
-void fscache_disable_cookie(struct fscache_cookie *cookie, bool invalidate)
+void fscache_disable_cookie(struct fscache_cookie *cookie,
+			    const void *aux_data,
+			    bool invalidate)
 {
 	if (fscache_cookie_valid(cookie) && fscache_cookie_enabled(cookie))
-		__fscache_disable_cookie(cookie, invalidate);
+		__fscache_disable_cookie(cookie, aux_data, invalidate);
 }
 
 /**
  * fscache_enable_cookie - Reenable a cookie
  * @cookie: The cookie representing the cache object
+ * @aux_data: The updated auxiliary data for the cookie (may be NULL)
  * @can_enable: A function to permit enablement once lock is held
  * @data: Data for can_enable()
  *
  * Reenable a previously disabled cookie, allowing it to accept further alloc,
  * read, write, invalidate, update or acquire operations.  An attempt will be
- * made to immediately reattach the cookie to a backing object.
+ * made to immediately reattach the cookie to a backing object.  If @aux_data
+ * is set, the auxiliary data attached to the cookie will be updated.
  *
  * The can_enable() function is called (if not NULL) once the enablement lock
  * is held to rule on whether enablement is still permitted to go ahead.
  */
 static inline
 void fscache_enable_cookie(struct fscache_cookie *cookie,
+			   const void *aux_data,
 			   bool (*can_enable)(void *data),
 			   void *data)
 {
 	if (fscache_cookie_valid(cookie) && !fscache_cookie_enabled(cookie))
-		__fscache_enable_cookie(cookie, can_enable, data);
+		__fscache_enable_cookie(cookie, aux_data, can_enable, data);
 }
 
 #endif /* _LINUX_FSCACHE_H */

