Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx3-rdu2.redhat.com ([66.187.233.73]:49666 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1752246AbeDDWIC (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 4 Apr 2018 18:08:02 -0400
Subject: [PATCH 11/12] fscache: Pass object size in rather than calling back
 for it
From: David Howells <dhowells@redhat.com>
To: torvalds@linux-foundation.org
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org,
        dhowells@redhat.com, linux-cachefs@redhat.com,
        linux-fsdevel@vger.kernel.org, linux-afs@lists.infradead.org
Date: Wed, 04 Apr 2018 23:07:59 +0100
Message-ID: <152287967976.14760.7288888207248267076.stgit@warthog.procyon.org.uk>
In-Reply-To: <152287959470.14760.10350886166577848180.stgit@warthog.procyon.org.uk>
References: <152287959470.14760.10350886166577848180.stgit@warthog.procyon.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Pass the object size in to fscache_acquire_cookie() and
fscache_write_page() rather than the netfs providing a callback by which it
can be received.  This makes it easier to update the size of the object
when a new page is written that extends the object.

The current object size is also passed by fscache to the check_aux
function, obviating the need to store it in the aux data.

Signed-off-by: David Howells <dhowells@redhat.com>
Acked-by: Anna Schumaker <anna.schumaker@netapp.com>
Tested-by: Steve Dickson <steved@redhat.com>
---

 Documentation/filesystems/caching/netfs-api.txt |   61 ++++++++++++-----------
 fs/9p/cache.c                                   |   27 ++++------
 fs/afs/cache.c                                  |   24 ++-------
 fs/afs/cell.c                                   |    2 -
 fs/afs/file.c                                   |    6 ++
 fs/afs/inode.c                                  |    2 -
 fs/afs/volume.c                                 |    2 -
 fs/cachefiles/interface.c                       |    5 +-
 fs/cachefiles/xattr.c                           |    6 ++
 fs/ceph/cache.c                                 |   26 +++-------
 fs/cifs/cache.c                                 |   15 ++----
 fs/cifs/fscache.c                               |   14 +++--
 fs/fscache/cookie.c                             |   18 +++----
 fs/fscache/fsdef.c                              |    6 ++
 fs/fscache/object.c                             |    5 +-
 fs/fscache/page.c                               |    5 ++
 fs/nfs/fscache-index.c                          |   19 +------
 fs/nfs/fscache.c                                |   14 ++---
 fs/nfs/fscache.h                                |    1 
 include/linux/fscache-cache.h                   |    3 +
 include/linux/fscache.h                         |   32 ++++++------
 21 files changed, 127 insertions(+), 166 deletions(-)

diff --git a/Documentation/filesystems/caching/netfs-api.txt b/Documentation/filesystems/caching/netfs-api.txt
index 332840ad4151..2a6f7399c1f3 100644
--- a/Documentation/filesystems/caching/netfs-api.txt
+++ b/Documentation/filesystems/caching/netfs-api.txt
@@ -129,12 +129,10 @@ To define an object, a structure of the following type should be filled out:
 			const void *parent_netfs_data,
 			const void *cookie_netfs_data);
 
-		void (*get_attr)(const void *cookie_netfs_data,
-				 uint64_t *size);
-
 		enum fscache_checkaux (*check_aux)(void *cookie_netfs_data,
 						   const void *data,
-						   uint16_t datalen);
+						   uint16_t datalen,
+						   loff_t object_size);
 
 		void (*get_context)(void *cookie_netfs_data, void *context);
 
@@ -179,16 +177,7 @@ This has the following fields:
      cache in the parent's list will be chosen, or failing that, the first
      cache in the master list.
 
- (4) A function to retrieve attribute data from the netfs [optional].
-
-     This function will be called with the netfs data that was passed to the
-     cookie acquisition function.  It should return the size of the file if
-     this is a data file.  The size may be used to govern how much cache must
-     be reserved for this file in the cache.
-
-     If the function is absent, a file size of 0 is assumed.
-
- (5) A function to check the auxiliary data [optional].
+ (4) A function to check the auxiliary data [optional].
 
      This function will be called to check that a match found in the cache for
      this object is valid.  For instance with AFS it could check the auxiliary
@@ -198,6 +187,9 @@ This has the following fields:
      If this function is absent, it will be assumed that matching objects in a
      cache are always valid.
 
+     The function is also passed the cache's idea of the object size and may
+     use this to manage coherency also.
+
      If present, the function should return one of the following values:
 
 	(*) FSCACHE_CHECKAUX_OKAY		- the entry is okay as is
@@ -207,7 +199,7 @@ This has the following fields:
      This function can also be used to extract data from the auxiliary data in
      the cache and copy it into the netfs's structures.
 
- (6) A pair of functions to manage contexts for the completion callback
+ (5) A pair of functions to manage contexts for the completion callback
      [optional].
 
      The cache read/write functions are passed a context which is then passed
@@ -221,7 +213,7 @@ This has the following fields:
      required for indices as indices may not contain data.  These functions may
      be called in interrupt context and so may not sleep.
 
- (7) A function to mark a page as retaining cache metadata [optional].
+ (6) A function to mark a page as retaining cache metadata [optional].
 
      This is called by the cache to indicate that it is retaining in-memory
      information for this page and that the netfs should uncache the page when
@@ -233,7 +225,7 @@ This has the following fields:
 
      This function is not required for indices as they're not permitted data.
 
- (8) A function to unmark all the pages retaining cache metadata [mandatory].
+ (7) A function to unmark all the pages retaining cache metadata [mandatory].
 
      This is called by FS-Cache to indicate that a backing store is being
      unbound from a cookie and that all the marks on the pages should be
@@ -310,6 +302,7 @@ the path to the file:
 			       const void *aux_data,
 			       size_t aux_data_len,
 			       void *netfs_data,
+			       loff_t object_size,
 			       bool enable);
 
 This function creates an index entry in the index represented by parent,
@@ -326,6 +319,10 @@ The netfs may pass an arbitrary value in netfs_data and this will be presented
 to it in the event of any calling back.  This may also be used in tracing or
 logging of messages.
 
+The cache tracks the size of the data attached to an object and this set to be
+object_size.  For indices, this should be 0.  This value will be passed to the
+->check_aux() callback.
+
 Note that this function never returns an error - all errors are handled
 internally.  It may, however, return NULL to indicate no cookie.  It is quite
 acceptable to pass this token back to this function as the parent to another
@@ -349,7 +346,7 @@ entry would have a dependent inode containing volume mappings within this cell:
 				       &afs_cell_cache_index_def,
 				       cell->name, strlen(cell->name),
 				       NULL, 0,
-				       cell, true);
+				       cell, 0, true);
 
 And then a particular volume could be added to that index by ID, creating
 another index for vnodes (AFS inode equivalents):
@@ -359,7 +356,7 @@ another index for vnodes (AFS inode equivalents):
 				       &afs_volume_cache_index_def,
 				       &volume->vid, sizeof(volume->vid),
 				       NULL, 0,
-				       volume, true);
+				       volume, 0, true);
 
 
 ======================
@@ -375,7 +372,7 @@ the object definition should be something other than index type.
 				       &afs_vnode_cache_object_def,
 				       &key, sizeof(key),
 				       &aux, sizeof(aux),
-				       vnode, true);
+				       vnode, vnode->status.size, true);
 
 
 =================================
@@ -393,7 +390,7 @@ it would be some other type of object such as a data file.
 				       &afs_xattr_cache_object_def,
 				       &xattr->name, strlen(xattr->name),
 				       NULL, 0,
-				       xattr, true);
+				       xattr, strlen(xattr->val), true);
 
 Miscellaneous objects might be used to store extended attributes or directory
 entries for example.
@@ -410,8 +407,7 @@ cache to adjust its metadata for data tracking appropriately:
 	int fscache_attr_changed(struct fscache_cookie *cookie);
 
 The cache will return -ENOBUFS if there is no backing cache or if there is no
-space to allocate any extra metadata required in the cache.  The attributes
-will be accessed with the get_attr() cookie definition operation.
+space to allocate any extra metadata required in the cache.
 
 Note that attempts to read or write data pages in the cache over this size may
 be rebuffed with -ENOBUFS.
@@ -536,12 +532,13 @@ written back to the cache:
 
 	int fscache_write_page(struct fscache_cookie *cookie,
 			       struct page *page,
+			       loff_t object_size,
 			       gfp_t gfp);
 
 The cookie argument must specify a data file cookie, the page specified should
 contain the data to be written (and is also used to specify the page number),
-and the gfp argument is used to control how any memory allocations made are
-satisfied.
+object_size is the revised size of the object and the gfp argument is used to
+control how any memory allocations made are satisfied.
 
 The page must have first been read or allocated successfully and must not have
 been uncached before writing is performed.
@@ -735,11 +732,11 @@ still possible to uncache pages and relinquish the cookie.
 
 The initial enablement state is set by fscache_acquire_cookie(), but the cookie
 can be enabled or disabled later.  To disable a cookie, call:
-    
+
 	void fscache_disable_cookie(struct fscache_cookie *cookie,
 				    const void *aux_data,
     				    bool invalidate);
-    
+
 If the cookie is not already disabled, this locks the cookie against other
 enable and disable ops, marks the cookie as being disabled, discards or
 invalidates any backing objects and waits for cessation of activity on any
@@ -748,14 +745,15 @@ associated object before unlocking the cookie.
 All possible failures are handled internally.  The caller should consider
 calling fscache_uncache_all_inode_pages() afterwards to make sure all page
 markings are cleared up.
-    
+
 Cookies can be enabled or reenabled with:
-    
+
     	void fscache_enable_cookie(struct fscache_cookie *cookie,
 				   const void *aux_data,
+				   loff_t object_size,
     				   bool (*can_enable)(void *data),
     				   void *data)
-    
+
 If the cookie is not already enabled, this locks the cookie against other
 enable and disable ops, invokes can_enable() and, if the cookie is not an index
 cookie, will begin the procedure of acquiring backing objects.
@@ -766,6 +764,9 @@ ruling as to whether or not enablement should actually be permitted to begin.
 All possible failures are handled internally.  The cookie will only be marked
 as enabled if provisional backing objects are allocated.
 
+The object's data size is updated from object_size and is passed to the
+->check_aux() function.
+
 In both cases, the cookie's auxiliary data buffer is updated from aux_data if
 that is non-NULL inside the enablement lock before proceeding.
 
diff --git a/fs/9p/cache.c b/fs/9p/cache.c
index 9d0030af5672..9eb34701a566 100644
--- a/fs/9p/cache.c
+++ b/fs/9p/cache.c
@@ -75,7 +75,7 @@ void v9fs_cache_session_get_cookie(struct v9fs_session_info *v9ses)
 						v9ses->cachetag,
 						strlen(v9ses->cachetag),
 						NULL, 0,
-						v9ses, true);
+						v9ses, 0, true);
 	p9_debug(P9_DEBUG_FSC, "session %p get cookie %p\n",
 		 v9ses, v9ses->fscache);
 }
@@ -88,20 +88,11 @@ void v9fs_cache_session_put_cookie(struct v9fs_session_info *v9ses)
 	v9ses->fscache = NULL;
 }
 
-static void v9fs_cache_inode_get_attr(const void *cookie_netfs_data,
-				      uint64_t *size)
-{
-	const struct v9fs_inode *v9inode = cookie_netfs_data;
-	*size = i_size_read(&v9inode->vfs_inode);
-
-	p9_debug(P9_DEBUG_FSC, "inode %p get attr %llu\n",
-		 &v9inode->vfs_inode, *size);
-}
-
 static enum
 fscache_checkaux v9fs_cache_inode_check_aux(void *cookie_netfs_data,
 					    const void *buffer,
-					    uint16_t buflen)
+					    uint16_t buflen,
+					    loff_t object_size)
 {
 	const struct v9fs_inode *v9inode = cookie_netfs_data;
 
@@ -118,7 +109,6 @@ fscache_checkaux v9fs_cache_inode_check_aux(void *cookie_netfs_data,
 const struct fscache_cookie_def v9fs_cache_inode_index_def = {
 	.name		= "9p.inode",
 	.type		= FSCACHE_COOKIE_TYPE_DATAFILE,
-	.get_attr	= v9fs_cache_inode_get_attr,
 	.check_aux	= v9fs_cache_inode_check_aux,
 };
 
@@ -141,7 +131,9 @@ void v9fs_cache_inode_get_cookie(struct inode *inode)
 						  sizeof(v9inode->qid.path),
 						  &v9inode->qid.version,
 						  sizeof(v9inode->qid.version),
-						  v9inode, true);
+						  v9inode,
+						  i_size_read(&v9inode->vfs_inode),
+						  true);
 
 	p9_debug(P9_DEBUG_FSC, "inode %p get cookie %p\n",
 		 inode, v9inode->fscache);
@@ -212,7 +204,9 @@ void v9fs_cache_inode_reset_cookie(struct inode *inode)
 						  sizeof(v9inode->qid.path),
 						  &v9inode->qid.version,
 						  sizeof(v9inode->qid.version),
-						  v9inode, true);
+						  v9inode,
+						  i_size_read(&v9inode->vfs_inode),
+						  true);
 	p9_debug(P9_DEBUG_FSC, "inode %p revalidating cookie old %p new %p\n",
 		 inode, old, v9inode->fscache);
 
@@ -338,7 +332,8 @@ void __v9fs_readpage_to_fscache(struct inode *inode, struct page *page)
 	const struct v9fs_inode *v9inode = V9FS_I(inode);
 
 	p9_debug(P9_DEBUG_FSC, "inode %p page %p\n", inode, page);
-	ret = fscache_write_page(v9inode->fscache, page, GFP_KERNEL);
+	ret = fscache_write_page(v9inode->fscache, page,
+				 i_size_read(&v9inode->vfs_inode), GFP_KERNEL);
 	p9_debug(P9_DEBUG_FSC, "ret =  %d\n", ret);
 	if (ret != 0)
 		v9fs_uncache_page(inode, page);
diff --git a/fs/afs/cache.c b/fs/afs/cache.c
index a16f1e024cf3..b1c31ec4523a 100644
--- a/fs/afs/cache.c
+++ b/fs/afs/cache.c
@@ -12,11 +12,10 @@
 #include <linux/sched.h>
 #include "internal.h"
 
-static void afs_vnode_cache_get_attr(const void *cookie_netfs_data,
-				     uint64_t *size);
 static enum fscache_checkaux afs_vnode_cache_check_aux(void *cookie_netfs_data,
 						       const void *buffer,
-						       uint16_t buflen);
+						       uint16_t buflen,
+						       loff_t object_size);
 
 struct fscache_netfs afs_cache_netfs = {
 	.name			= "afs",
@@ -36,31 +35,16 @@ struct fscache_cookie_def afs_volume_cache_index_def = {
 struct fscache_cookie_def afs_vnode_cache_index_def = {
 	.name		= "AFS.vnode",
 	.type		= FSCACHE_COOKIE_TYPE_DATAFILE,
-	.get_attr	= afs_vnode_cache_get_attr,
 	.check_aux	= afs_vnode_cache_check_aux,
 };
 
-/*
- * provide updated file attributes
- */
-static void afs_vnode_cache_get_attr(const void *cookie_netfs_data,
-				     uint64_t *size)
-{
-	const struct afs_vnode *vnode = cookie_netfs_data;
-
-	_enter("{%x,%x,%llx},",
-	       vnode->fid.vnode, vnode->fid.unique,
-	       vnode->status.data_version);
-
-	*size = vnode->status.size;
-}
-
 /*
  * check that the auxiliary data indicates that the entry is still valid
  */
 static enum fscache_checkaux afs_vnode_cache_check_aux(void *cookie_netfs_data,
 						       const void *buffer,
-						       uint16_t buflen)
+						       uint16_t buflen,
+						       loff_t object_size)
 {
 	struct afs_vnode *vnode = cookie_netfs_data;
 	struct afs_vnode_cache_aux aux;
diff --git a/fs/afs/cell.c b/fs/afs/cell.c
index 0747460221cb..4235a05afc76 100644
--- a/fs/afs/cell.c
+++ b/fs/afs/cell.c
@@ -524,7 +524,7 @@ static int afs_activate_cell(struct afs_net *net, struct afs_cell *cell)
 					     &afs_cell_cache_index_def,
 					     cell->name, strlen(cell->name),
 					     NULL, 0,
-					     cell, true);
+					     cell, 0, true);
 #endif
 	ret = afs_proc_cell_setup(net, cell);
 	if (ret < 0)
diff --git a/fs/afs/file.c b/fs/afs/file.c
index a39192ced99e..79e665a35fea 100644
--- a/fs/afs/file.c
+++ b/fs/afs/file.c
@@ -339,7 +339,8 @@ int afs_page_filler(void *data, struct page *page)
 		/* send the page to the cache */
 #ifdef CONFIG_AFS_FSCACHE
 		if (PageFsCache(page) &&
-		    fscache_write_page(vnode->cache, page, GFP_KERNEL) != 0) {
+		    fscache_write_page(vnode->cache, page, vnode->status.size,
+				       GFP_KERNEL) != 0) {
 			fscache_uncache_page(vnode->cache, page);
 			BUG_ON(PageFsCache(page));
 		}
@@ -403,7 +404,8 @@ static void afs_readpages_page_done(struct afs_call *call, struct afs_read *req)
 	/* send the page to the cache */
 #ifdef CONFIG_AFS_FSCACHE
 	if (PageFsCache(page) &&
-	    fscache_write_page(vnode->cache, page, GFP_KERNEL) != 0) {
+	    fscache_write_page(vnode->cache, page, vnode->status.size,
+			       GFP_KERNEL) != 0) {
 		fscache_uncache_page(vnode->cache, page);
 		BUG_ON(PageFsCache(page));
 	}
diff --git a/fs/afs/inode.c b/fs/afs/inode.c
index e499713efd2e..65c5b1edd338 100644
--- a/fs/afs/inode.c
+++ b/fs/afs/inode.c
@@ -265,7 +265,7 @@ static void afs_get_inode_cache(struct afs_vnode *vnode)
 					      &afs_vnode_cache_index_def,
 					      &key, sizeof(key),
 					      &aux, sizeof(aux),
-					      vnode, true);
+					      vnode, vnode->status.size, true);
 #endif
 }
 
diff --git a/fs/afs/volume.c b/fs/afs/volume.c
index 345cb2d675d2..3037bd01f617 100644
--- a/fs/afs/volume.c
+++ b/fs/afs/volume.c
@@ -227,7 +227,7 @@ void afs_activate_volume(struct afs_volume *volume)
 					       &afs_volume_cache_index_def,
 					       &volume->vid, sizeof(volume->vid),
 					       NULL, 0,
-					       volume, true);
+					       volume, 0, true);
 #endif
 
 	write_lock(&volume->cell->proc_lock);
diff --git a/fs/cachefiles/interface.c b/fs/cachefiles/interface.c
index 3264dcfdc92a..222bc5d8b62c 100644
--- a/fs/cachefiles/interface.c
+++ b/fs/cachefiles/interface.c
@@ -441,7 +441,7 @@ static int cachefiles_attr_changed(struct fscache_object *_object)
 	loff_t oi_size;
 	int ret;
 
-	_object->cookie->def->get_attr(_object->cookie->netfs_data, &ni_size);
+	ni_size = _object->store_limit_l;
 
 	_enter("{OBJ%x},[%llu]",
 	       _object->debug_id, (unsigned long long) ni_size);
@@ -513,8 +513,7 @@ static void cachefiles_invalidate_object(struct fscache_operation *op)
 	cache = container_of(object->fscache.cache,
 			     struct cachefiles_cache, cache);
 
-	op->object->cookie->def->get_attr(op->object->cookie->netfs_data,
-					  &ni_size);
+	ni_size = op->object->store_limit_l;
 
 	_enter("{OBJ%x},[%llu]",
 	       op->object->debug_id, (unsigned long long)ni_size);
diff --git a/fs/cachefiles/xattr.c b/fs/cachefiles/xattr.c
index d84423c264af..0a29a00aed2e 100644
--- a/fs/cachefiles/xattr.c
+++ b/fs/cachefiles/xattr.c
@@ -182,7 +182,8 @@ int cachefiles_check_auxdata(struct cachefiles_object *object)
 		goto error;
 
 	xlen--;
-	validity = fscache_check_aux(&object->fscache, &auxbuf->data, xlen);
+	validity = fscache_check_aux(&object->fscache, &auxbuf->data, xlen,
+				     i_size_read(d_backing_inode(dentry)));
 	if (validity != FSCACHE_CHECKAUX_OKAY)
 		goto error;
 
@@ -251,7 +252,8 @@ int cachefiles_check_object_xattr(struct cachefiles_object *object,
 		       object->fscache.cookie->def->name, dlen);
 
 		result = fscache_check_aux(&object->fscache,
-					   &auxbuf->data, dlen);
+					   &auxbuf->data, dlen,
+					   i_size_read(d_backing_inode(dentry)));
 
 		switch (result) {
 			/* entry okay as is */
diff --git a/fs/ceph/cache.c b/fs/ceph/cache.c
index fee869061f05..33a211b364ed 100644
--- a/fs/ceph/cache.c
+++ b/fs/ceph/cache.c
@@ -27,7 +27,6 @@
 struct ceph_aux_inode {
 	u64 		version;
 	struct timespec	mtime;
-	loff_t          size;
 };
 
 struct fscache_netfs ceph_cache_netfs = {
@@ -101,7 +100,7 @@ int ceph_fscache_register_fs(struct ceph_fs_client* fsc)
 					      &ceph_fscache_fsid_object_def,
 					      &ent->fsid, sizeof(ent->fsid) + uniq_len,
 					      NULL, 0,
-					      fsc, true);
+					      fsc, 0, true);
 
 	if (fsc->fscache) {
 		ent->fscache = fsc->fscache;
@@ -117,27 +116,21 @@ int ceph_fscache_register_fs(struct ceph_fs_client* fsc)
 	return err;
 }
 
-static void ceph_fscache_inode_get_attr(const void *cookie_netfs_data,
-					uint64_t *size)
-{
-	const struct ceph_inode_info* ci = cookie_netfs_data;
-	*size = i_size_read(&ci->vfs_inode);
-}
-
 static enum fscache_checkaux ceph_fscache_inode_check_aux(
-	void *cookie_netfs_data, const void *data, uint16_t dlen)
+	void *cookie_netfs_data, const void *data, uint16_t dlen,
+	loff_t object_size)
 {
 	struct ceph_aux_inode aux;
 	struct ceph_inode_info* ci = cookie_netfs_data;
 	struct inode* inode = &ci->vfs_inode;
 
-	if (dlen != sizeof(aux))
+	if (dlen != sizeof(aux) ||
+	    i_size_read(inode) != object_size)
 		return FSCACHE_CHECKAUX_OBSOLETE;
 
 	memset(&aux, 0, sizeof(aux));
 	aux.version = ci->i_version;
 	aux.mtime = inode->i_mtime;
-	aux.size = i_size_read(inode);
 
 	if (memcmp(data, &aux, sizeof(aux)) != 0)
 		return FSCACHE_CHECKAUX_OBSOLETE;
@@ -149,7 +142,6 @@ static enum fscache_checkaux ceph_fscache_inode_check_aux(
 static const struct fscache_cookie_def ceph_fscache_inode_object_def = {
 	.name		= "CEPH.inode",
 	.type		= FSCACHE_COOKIE_TYPE_DATAFILE,
-	.get_attr	= ceph_fscache_inode_get_attr,
 	.check_aux	= ceph_fscache_inode_check_aux,
 };
 
@@ -172,12 +164,11 @@ void ceph_fscache_register_inode_cookie(struct inode *inode)
 		memset(&aux, 0, sizeof(aux));
 		aux.version = ci->i_version;
 		aux.mtime = inode->i_mtime;
-		aux.size = i_size_read(inode);
 		ci->fscache = fscache_acquire_cookie(fsc->fscache,
 						     &ceph_fscache_inode_object_def,
 						     &ci->i_vino, sizeof(ci->i_vino),
 						     &aux, sizeof(aux),
-						     ci, false);
+						     ci, i_size_read(inode), false);
 	}
 	inode_unlock(inode);
 }
@@ -214,7 +205,7 @@ void ceph_fscache_file_set_cookie(struct inode *inode, struct file *filp)
 		fscache_disable_cookie(ci->fscache, &ci->i_vino, false);
 		fscache_uncache_all_inode_pages(ci->fscache, inode);
 	} else {
-		fscache_enable_cookie(ci->fscache, &ci->i_vino,
+		fscache_enable_cookie(ci->fscache, &ci->i_vino, i_size_read(inode),
 				      ceph_fscache_can_enable, inode);
 		if (fscache_cookie_enabled(ci->fscache)) {
 			dout("fscache_file_set_cookie %p %p enabling cache\n",
@@ -308,7 +299,8 @@ void ceph_readpage_to_fscache(struct inode *inode, struct page *page)
 	if (!cache_valid(ci))
 		return;
 
-	ret = fscache_write_page(ci->fscache, page, GFP_KERNEL);
+	ret = fscache_write_page(ci->fscache, page, i_size_read(inode),
+				 GFP_KERNEL);
 	if (ret)
 		 fscache_uncache_page(ci->fscache, page);
 }
diff --git a/fs/cifs/cache.c b/fs/cifs/cache.c
index b4fa270ef532..edf5f40898bf 100644
--- a/fs/cifs/cache.c
+++ b/fs/cifs/cache.c
@@ -87,7 +87,8 @@ char *extract_sharename(const char *treename)
 static enum
 fscache_checkaux cifs_fscache_super_check_aux(void *cookie_netfs_data,
 					      const void *data,
-					      uint16_t datalen)
+					      uint16_t datalen,
+					      loff_t object_size)
 {
 	struct cifs_fscache_super_auxdata auxdata;
 	const struct cifs_tcon *tcon = cookie_netfs_data;
@@ -113,18 +114,11 @@ const struct fscache_cookie_def cifs_fscache_super_index_def = {
 	.check_aux = cifs_fscache_super_check_aux,
 };
 
-static void
-cifs_fscache_inode_get_attr(const void *cookie_netfs_data, uint64_t *size)
-{
-	const struct cifsInodeInfo *cifsi = cookie_netfs_data;
-
-	*size = cifsi->vfs_inode.i_size;
-}
-
 static enum
 fscache_checkaux cifs_fscache_inode_check_aux(void *cookie_netfs_data,
 					      const void *data,
-					      uint16_t datalen)
+					      uint16_t datalen,
+					      loff_t object_size)
 {
 	struct cifs_fscache_inode_auxdata auxdata;
 	struct cifsInodeInfo *cifsi = cookie_netfs_data;
@@ -146,6 +140,5 @@ fscache_checkaux cifs_fscache_inode_check_aux(void *cookie_netfs_data,
 const struct fscache_cookie_def cifs_fscache_inode_object_def = {
 	.name		= "CIFS.uniqueid",
 	.type		= FSCACHE_COOKIE_TYPE_DATAFILE,
-	.get_attr	= cifs_fscache_inode_get_attr,
 	.check_aux	= cifs_fscache_inode_check_aux,
 };
diff --git a/fs/cifs/fscache.c b/fs/cifs/fscache.c
index b89b59b01759..25d3f66b2d50 100644
--- a/fs/cifs/fscache.c
+++ b/fs/cifs/fscache.c
@@ -79,7 +79,7 @@ void cifs_fscache_get_client_cookie(struct TCP_Server_Info *server)
 				       &cifs_fscache_server_index_def,
 				       &key, key_len,
 				       NULL, 0,
-				       server, true);
+				       server, 0, true);
 	cifs_dbg(FYI, "%s: (0x%p/0x%p)\n",
 		 __func__, server, server->fscache);
 }
@@ -109,7 +109,7 @@ void cifs_fscache_get_super_cookie(struct cifs_tcon *tcon)
 				       &cifs_fscache_super_index_def,
 				       sharename, strlen(sharename),
 				       &tcon->resource_id, sizeof(tcon->resource_id),
-				       tcon, true);
+				       tcon, 0, true);
 	kfree(sharename);
 	cifs_dbg(FYI, "%s: (0x%p/0x%p)\n",
 		 __func__, server->fscache, tcon->fscache);
@@ -137,7 +137,7 @@ static void cifs_fscache_acquire_inode_cookie(struct cifsInodeInfo *cifsi,
 				       &cifs_fscache_inode_object_def,
 				       &cifsi->uniqueid, sizeof(cifsi->uniqueid),
 				       &auxdata, sizeof(auxdata),
-				       cifsi, true);
+				       cifsi, cifsi->vfs_inode.i_size, true);
 }
 
 static void cifs_fscache_enable_inode_cookie(struct inode *inode)
@@ -301,13 +301,15 @@ int __cifs_readpages_from_fscache(struct inode *inode,
 
 void __cifs_readpage_to_fscache(struct inode *inode, struct page *page)
 {
+	struct cifsInodeInfo *cifsi = CIFS_I(inode);
 	int ret;
 
 	cifs_dbg(FYI, "%s: (fsc: %p, p: %p, i: %p)\n",
-		 __func__, CIFS_I(inode)->fscache, page, inode);
-	ret = fscache_write_page(CIFS_I(inode)->fscache, page, GFP_KERNEL);
+		 __func__, cifsi->fscache, page, inode);
+	ret = fscache_write_page(cifsi->fscache, page,
+				 cifsi->vfs_inode.i_size, GFP_KERNEL);
 	if (ret != 0)
-		fscache_uncache_page(CIFS_I(inode)->fscache, page);
+		fscache_uncache_page(cifsi->fscache, page);
 }
 
 void __cifs_fscache_readpages_cancel(struct inode *inode, struct list_head *pages)
diff --git a/fs/fscache/cookie.c b/fs/fscache/cookie.c
index 4d6210082a60..8ca9a932d225 100644
--- a/fs/fscache/cookie.c
+++ b/fs/fscache/cookie.c
@@ -21,7 +21,8 @@ struct kmem_cache *fscache_cookie_jar;
 
 static atomic_t fscache_object_debug_id = ATOMIC_INIT(0);
 
-static int fscache_acquire_non_index_cookie(struct fscache_cookie *cookie);
+static int fscache_acquire_non_index_cookie(struct fscache_cookie *cookie,
+					    loff_t object_size);
 static int fscache_alloc_object(struct fscache_cache *cache,
 				struct fscache_cookie *cookie);
 static int fscache_attach_object(struct fscache_cookie *cookie,
@@ -61,6 +62,7 @@ struct fscache_cookie *__fscache_acquire_cookie(
 	const void *index_key, size_t index_key_len,
 	const void *aux_data, size_t aux_data_len,
 	void *netfs_data,
+	loff_t object_size,
 	bool enable)
 {
 	struct fscache_cookie *cookie;
@@ -160,7 +162,7 @@ struct fscache_cookie *__fscache_acquire_cookie(
 		 * - we create indices on disk when we need them as an index
 		 * may exist in multiple caches */
 		if (cookie->type != FSCACHE_COOKIE_TYPE_INDEX) {
-			if (fscache_acquire_non_index_cookie(cookie) == 0) {
+			if (fscache_acquire_non_index_cookie(cookie, object_size) == 0) {
 				set_bit(FSCACHE_COOKIE_ENABLED, &cookie->flags);
 			} else {
 				atomic_dec(&parent->n_children);
@@ -194,6 +196,7 @@ EXPORT_SYMBOL(__fscache_acquire_cookie);
  */
 void __fscache_enable_cookie(struct fscache_cookie *cookie,
 			     const void *aux_data,
+			     loff_t object_size,
 			     bool (*can_enable)(void *data),
 			     void *data)
 {
@@ -215,7 +218,7 @@ void __fscache_enable_cookie(struct fscache_cookie *cookie,
 		/* Wait for outstanding disablement to complete */
 		__fscache_wait_on_invalidate(cookie);
 
-		if (fscache_acquire_non_index_cookie(cookie) == 0)
+		if (fscache_acquire_non_index_cookie(cookie, object_size) == 0)
 			set_bit(FSCACHE_COOKIE_ENABLED, &cookie->flags);
 	} else {
 		set_bit(FSCACHE_COOKIE_ENABLED, &cookie->flags);
@@ -232,11 +235,11 @@ EXPORT_SYMBOL(__fscache_enable_cookie);
  * - this must make sure the index chain is instantiated and instantiate the
  *   object representation too
  */
-static int fscache_acquire_non_index_cookie(struct fscache_cookie *cookie)
+static int fscache_acquire_non_index_cookie(struct fscache_cookie *cookie,
+					    loff_t object_size)
 {
 	struct fscache_object *object;
 	struct fscache_cache *cache;
-	uint64_t i_size;
 	int ret;
 
 	_enter("");
@@ -275,9 +278,6 @@ static int fscache_acquire_non_index_cookie(struct fscache_cookie *cookie)
 		return ret;
 	}
 
-	/* pass on how big the object we're caching is supposed to be */
-	cookie->def->get_attr(cookie->netfs_data, &i_size);
-
 	spin_lock(&cookie->lock);
 	if (hlist_empty(&cookie->backing_objects)) {
 		spin_unlock(&cookie->lock);
@@ -287,7 +287,7 @@ static int fscache_acquire_non_index_cookie(struct fscache_cookie *cookie)
 	object = hlist_entry(cookie->backing_objects.first,
 			     struct fscache_object, cookie_link);
 
-	fscache_set_store_limit(object, i_size);
+	fscache_set_store_limit(object, object_size);
 
 	/* initiate the process of looking up all the objects in the chain
 	 * (done by fscache_initialise_object()) */
diff --git a/fs/fscache/fsdef.c b/fs/fscache/fsdef.c
index 1122e97d56e8..aa46e48d8c75 100644
--- a/fs/fscache/fsdef.c
+++ b/fs/fscache/fsdef.c
@@ -16,7 +16,8 @@
 static
 enum fscache_checkaux fscache_fsdef_netfs_check_aux(void *cookie_netfs_data,
 						    const void *data,
-						    uint16_t datalen);
+						    uint16_t datalen,
+						    loff_t object_size);
 
 /*
  * The root index is owned by FS-Cache itself.
@@ -76,7 +77,8 @@ struct fscache_cookie_def fscache_fsdef_netfs_def = {
 static enum fscache_checkaux fscache_fsdef_netfs_check_aux(
 	void *cookie_netfs_data,
 	const void *data,
-	uint16_t datalen)
+	uint16_t datalen,
+	loff_t object_size)
 {
 	struct fscache_netfs *netfs = cookie_netfs_data;
 	uint32_t version;
diff --git a/fs/fscache/object.c b/fs/fscache/object.c
index b213030c3265..371dd1008510 100644
--- a/fs/fscache/object.c
+++ b/fs/fscache/object.c
@@ -922,7 +922,8 @@ static void fscache_dequeue_object(struct fscache_object *object)
  * and creation).
  */
 enum fscache_checkaux fscache_check_aux(struct fscache_object *object,
-					const void *data, uint16_t datalen)
+					const void *data, uint16_t datalen,
+					loff_t object_size)
 {
 	enum fscache_checkaux result;
 
@@ -932,7 +933,7 @@ enum fscache_checkaux fscache_check_aux(struct fscache_object *object,
 	}
 
 	result = object->cookie->def->check_aux(object->cookie->netfs_data,
-						data, datalen);
+						data, datalen, object_size);
 	switch (result) {
 		/* entry okay as is */
 	case FSCACHE_CHECKAUX_OKAY:
diff --git a/fs/fscache/page.c b/fs/fscache/page.c
index 810b33aced1c..111349f67d98 100644
--- a/fs/fscache/page.c
+++ b/fs/fscache/page.c
@@ -963,6 +963,7 @@ void fscache_invalidate_writes(struct fscache_cookie *cookie)
  */
 int __fscache_write_page(struct fscache_cookie *cookie,
 			 struct page *page,
+			 loff_t object_size,
 			 gfp_t gfp)
 {
 	struct fscache_storage *op;
@@ -1014,6 +1015,10 @@ int __fscache_write_page(struct fscache_cookie *cookie,
 	/* add the page to the pending-storage radix tree on the backing
 	 * object */
 	spin_lock(&object->lock);
+
+	if (object->store_limit_l != object_size)
+		fscache_set_store_limit(object, object_size);
+
 	spin_lock(&cookie->stores_lock);
 
 	_debug("store limit %llx", (unsigned long long) object->store_limit);
diff --git a/fs/nfs/fscache-index.c b/fs/nfs/fscache-index.c
index 6fd3679b7137..1c5d8d31fc0a 100644
--- a/fs/nfs/fscache-index.c
+++ b/fs/nfs/fscache-index.c
@@ -69,20 +69,6 @@ const struct fscache_cookie_def nfs_fscache_super_index_def = {
 	.type 		= FSCACHE_COOKIE_TYPE_INDEX,
 };
 
-/*
- * Get certain file attributes from the netfs data
- * - This function can be absent for an index
- * - Not permitted to return an error
- * - The netfs data from the cookie being used as the source is presented
- */
-static void nfs_fscache_inode_get_attr(const void *cookie_netfs_data,
-				       uint64_t *size)
-{
-	const struct nfs_inode *nfsi = cookie_netfs_data;
-
-	*size = nfsi->vfs_inode.i_size;
-}
-
 /*
  * Consult the netfs about the state of an object
  * - This function can be absent if the index carries no state data
@@ -92,7 +78,8 @@ static void nfs_fscache_inode_get_attr(const void *cookie_netfs_data,
 static
 enum fscache_checkaux nfs_fscache_inode_check_aux(void *cookie_netfs_data,
 						  const void *data,
-						  uint16_t datalen)
+						  uint16_t datalen,
+						  loff_t object_size)
 {
 	struct nfs_fscache_inode_auxdata auxdata;
 	struct nfs_inode *nfsi = cookie_netfs_data;
@@ -101,7 +88,6 @@ enum fscache_checkaux nfs_fscache_inode_check_aux(void *cookie_netfs_data,
 		return FSCACHE_CHECKAUX_OBSOLETE;
 
 	memset(&auxdata, 0, sizeof(auxdata));
-	auxdata.size = nfsi->vfs_inode.i_size;
 	auxdata.mtime = nfsi->vfs_inode.i_mtime;
 	auxdata.ctime = nfsi->vfs_inode.i_ctime;
 
@@ -150,7 +136,6 @@ static void nfs_fh_put_context(void *cookie_netfs_data, void *context)
 const struct fscache_cookie_def nfs_fscache_inode_object_def = {
 	.name		= "NFS.fh",
 	.type		= FSCACHE_COOKIE_TYPE_DATAFILE,
-	.get_attr	= nfs_fscache_inode_get_attr,
 	.check_aux	= nfs_fscache_inode_check_aux,
 	.get_context	= nfs_fh_get_context,
 	.put_context	= nfs_fh_put_context,
diff --git a/fs/nfs/fscache.c b/fs/nfs/fscache.c
index c45ba2691cee..b55fc7920c3b 100644
--- a/fs/nfs/fscache.c
+++ b/fs/nfs/fscache.c
@@ -86,7 +86,7 @@ void nfs_fscache_get_client_cookie(struct nfs_client *clp)
 					      &nfs_fscache_server_index_def,
 					      &key, len,
 					      NULL, 0,
-					      clp, true);
+					      clp, 0, true);
 	dfprintk(FSCACHE, "NFS: get client cookie (0x%p/0x%p)\n",
 		 clp, clp->fscache);
 }
@@ -188,7 +188,7 @@ void nfs_fscache_get_super_cookie(struct super_block *sb, const char *uniq, int
 					       &nfs_fscache_super_index_def,
 					       key, sizeof(*key) + ulen,
 					       NULL, 0,
-					       nfss, true);
+					       nfss, 0, true);
 	dfprintk(FSCACHE, "NFS: get superblock cookie (0x%p/0x%p)\n",
 		 nfss, nfss->fscache);
 	return;
@@ -237,7 +237,6 @@ void nfs_fscache_init_inode(struct inode *inode)
 		return;
 
 	memset(&auxdata, 0, sizeof(auxdata));
-	auxdata.size = nfsi->vfs_inode.i_size;
 	auxdata.mtime = nfsi->vfs_inode.i_mtime;
 	auxdata.ctime = nfsi->vfs_inode.i_ctime;
 
@@ -248,7 +247,7 @@ void nfs_fscache_init_inode(struct inode *inode)
 					       &nfs_fscache_inode_object_def,
 					       nfsi->fh.data, nfsi->fh.size,
 					       &auxdata, sizeof(auxdata),
-					       nfsi, false);
+					       nfsi, nfsi->vfs_inode.i_size, false);
 }
 
 /*
@@ -263,7 +262,6 @@ void nfs_fscache_clear_inode(struct inode *inode)
 	dfprintk(FSCACHE, "NFS: clear cookie (0x%p/0x%p)\n", nfsi, cookie);
 
 	memset(&auxdata, 0, sizeof(auxdata));
-	auxdata.size = nfsi->vfs_inode.i_size;
 	auxdata.mtime = nfsi->vfs_inode.i_mtime;
 	auxdata.ctime = nfsi->vfs_inode.i_ctime;
 	fscache_relinquish_cookie(cookie, &auxdata, false);
@@ -306,7 +304,6 @@ void nfs_fscache_open_file(struct inode *inode, struct file *filp)
 		return;
 
 	memset(&auxdata, 0, sizeof(auxdata));
-	auxdata.size = nfsi->vfs_inode.i_size;
 	auxdata.mtime = nfsi->vfs_inode.i_mtime;
 	auxdata.ctime = nfsi->vfs_inode.i_ctime;
 
@@ -317,7 +314,7 @@ void nfs_fscache_open_file(struct inode *inode, struct file *filp)
 		fscache_uncache_all_inode_pages(cookie, inode);
 	} else {
 		dfprintk(FSCACHE, "NFS: nfsi 0x%p enabling cache\n", nfsi);
-		fscache_enable_cookie(cookie, &auxdata,
+		fscache_enable_cookie(cookie, &auxdata, nfsi->vfs_inode.i_size,
 				      nfs_fscache_can_enable, inode);
 		if (fscache_cookie_enabled(cookie))
 			set_bit(NFS_INO_FSCACHE, &NFS_I(inode)->flags);
@@ -495,7 +492,8 @@ void __nfs_readpage_to_fscache(struct inode *inode, struct page *page, int sync)
 		 "NFS: readpage_to_fscache(fsc:%p/p:%p(i:%lx f:%lx)/%d)\n",
 		 nfs_i_fscache(inode), page, page->index, page->flags, sync);
 
-	ret = fscache_write_page(nfs_i_fscache(inode), page, GFP_KERNEL);
+	ret = fscache_write_page(nfs_i_fscache(inode), page,
+				 inode->i_size, GFP_KERNEL);
 	dfprintk(FSCACHE,
 		 "NFS:     readpage_to_fscache: p:%p(i:%lu f:%lx) ret %d\n",
 		 page, page->index, page->flags, ret);
diff --git a/fs/nfs/fscache.h b/fs/nfs/fscache.h
index 96e989f579d1..161ba2edb9d0 100644
--- a/fs/nfs/fscache.h
+++ b/fs/nfs/fscache.h
@@ -68,7 +68,6 @@ struct nfs_fscache_key {
 struct nfs_fscache_inode_auxdata {
 	struct timespec	mtime;
 	struct timespec	ctime;
-	loff_t		size;
 	u64		change_attr;
 };
 
diff --git a/include/linux/fscache-cache.h b/include/linux/fscache-cache.h
index 3e764fd38d9f..34cf0fdd7dc7 100644
--- a/include/linux/fscache-cache.h
+++ b/include/linux/fscache-cache.h
@@ -553,7 +553,8 @@ extern bool fscache_object_sleep_till_congested(signed long *timeoutp);
 
 extern enum fscache_checkaux fscache_check_aux(struct fscache_object *object,
 					       const void *data,
-					       uint16_t datalen);
+					       uint16_t datalen,
+					       loff_t object_size);
 
 extern void fscache_object_retrying_stale(struct fscache_object *object);
 
diff --git a/include/linux/fscache.h b/include/linux/fscache.h
index a2d3a2116248..eb38f39cf832 100644
--- a/include/linux/fscache.h
+++ b/include/linux/fscache.h
@@ -83,22 +83,15 @@ struct fscache_cookie_def {
 		const void *parent_netfs_data,
 		const void *cookie_netfs_data);
 
-	/* get certain file attributes from the netfs data
-	 * - this function can be absent for an index
-	 * - not permitted to return an error
-	 * - the netfs data from the cookie being used as the source is
-	 *   presented
-	 */
-	void (*get_attr)(const void *cookie_netfs_data, uint64_t *size);
-
 	/* consult the netfs about the state of an object
 	 * - this function can be absent if the index carries no state data
 	 * - the netfs data from the cookie being used as the target is
-	 *   presented, as is the auxiliary data
+	 *   presented, as is the auxiliary data and the object size
 	 */
 	enum fscache_checkaux (*check_aux)(void *cookie_netfs_data,
 					   const void *data,
-					   uint16_t datalen);
+					   uint16_t datalen,
+					   loff_t object_size);
 
 	/* get an extra reference on a read context
 	 * - this function can be absent if the completion function doesn't
@@ -200,7 +193,7 @@ extern struct fscache_cookie *__fscache_acquire_cookie(
 	const struct fscache_cookie_def *,
 	const void *, size_t,
 	const void *, size_t,
-	void *, bool);
+	void *, loff_t, bool);
 extern void __fscache_relinquish_cookie(struct fscache_cookie *, const void *, bool);
 extern int __fscache_check_consistency(struct fscache_cookie *, const void *);
 extern void __fscache_update_cookie(struct fscache_cookie *, const void *);
@@ -220,7 +213,7 @@ extern int __fscache_read_or_alloc_pages(struct fscache_cookie *,
 					 void *,
 					 gfp_t);
 extern int __fscache_alloc_page(struct fscache_cookie *, struct page *, gfp_t);
-extern int __fscache_write_page(struct fscache_cookie *, struct page *, gfp_t);
+extern int __fscache_write_page(struct fscache_cookie *, struct page *, loff_t, gfp_t);
 extern void __fscache_uncache_page(struct fscache_cookie *, struct page *);
 extern bool __fscache_check_page_write(struct fscache_cookie *, struct page *);
 extern void __fscache_wait_on_page_write(struct fscache_cookie *, struct page *);
@@ -231,7 +224,7 @@ extern void __fscache_uncache_all_inode_pages(struct fscache_cookie *,
 extern void __fscache_readpages_cancel(struct fscache_cookie *cookie,
 				       struct list_head *pages);
 extern void __fscache_disable_cookie(struct fscache_cookie *, const void *, bool);
-extern void __fscache_enable_cookie(struct fscache_cookie *, const void *,
+extern void __fscache_enable_cookie(struct fscache_cookie *, const void *, loff_t,
 				    bool (*)(void *), void *);
 
 /**
@@ -315,6 +308,7 @@ void fscache_release_cache_tag(struct fscache_cache_tag *tag)
  * @aux_data_len: Size of the auxiliary data buffer
  * @netfs_data: An arbitrary piece of data to be kept in the cookie to
  * represent the cache object to the netfs
+ * @object_size: The initial size of object
  * @enable: Whether or not to enable a data cookie immediately
  *
  * This function is used to inform FS-Cache about part of an index hierarchy
@@ -333,13 +327,14 @@ struct fscache_cookie *fscache_acquire_cookie(
 	const void *aux_data,
 	size_t aux_data_len,
 	void *netfs_data,
+	loff_t object_size,
 	bool enable)
 {
 	if (fscache_cookie_valid(parent) && fscache_cookie_enabled(parent))
 		return __fscache_acquire_cookie(parent, def,
 						index_key, index_key_len,
 						aux_data, aux_data_len,
-						netfs_data, enable);
+						netfs_data, object_size, enable);
 	else
 		return NULL;
 }
@@ -660,6 +655,7 @@ void fscache_readpages_cancel(struct fscache_cookie *cookie,
  * fscache_write_page - Request storage of a page in the cache
  * @cookie: The cookie representing the cache object
  * @page: The netfs page to store
+ * @object_size: Updated size of object
  * @gfp: The conditions under which memory allocation should be made
  *
  * Request the contents of the netfs page be written into the cache.  This
@@ -677,10 +673,11 @@ void fscache_readpages_cancel(struct fscache_cookie *cookie,
 static inline
 int fscache_write_page(struct fscache_cookie *cookie,
 		       struct page *page,
+		       loff_t object_size,
 		       gfp_t gfp)
 {
 	if (fscache_cookie_valid(cookie) && fscache_cookie_enabled(cookie))
-		return __fscache_write_page(cookie, page, gfp);
+		return __fscache_write_page(cookie, page, object_size, gfp);
 	else
 		return -ENOBUFS;
 }
@@ -819,6 +816,7 @@ void fscache_disable_cookie(struct fscache_cookie *cookie,
  * fscache_enable_cookie - Reenable a cookie
  * @cookie: The cookie representing the cache object
  * @aux_data: The updated auxiliary data for the cookie (may be NULL)
+ * @object_size: Current size of object
  * @can_enable: A function to permit enablement once lock is held
  * @data: Data for can_enable()
  *
@@ -833,11 +831,13 @@ void fscache_disable_cookie(struct fscache_cookie *cookie,
 static inline
 void fscache_enable_cookie(struct fscache_cookie *cookie,
 			   const void *aux_data,
+			   loff_t object_size,
 			   bool (*can_enable)(void *data),
 			   void *data)
 {
 	if (fscache_cookie_valid(cookie) && !fscache_cookie_enabled(cookie))
-		__fscache_enable_cookie(cookie, aux_data, can_enable, data);
+		__fscache_enable_cookie(cookie, aux_data, object_size,
+					can_enable, data);
 }
 
 #endif /* _LINUX_FSCACHE_H */

