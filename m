From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 4/8] NFS: Use size_t for storing name lengths
Date: Thu, 20 Dec 2007 14:54:49 -0500
Message-ID: <20071220195449.3280.3402.stgit@manray.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: trond.myklebust@fys.uio.no
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from flpi101.sbcis.sbc.com ([207.115.20.70]:46017 "EHLO
	flpi101.prodigy.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753553AbXLTTzB (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 20 Dec 2007 14:55:01 -0500
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Clean up: always use the same type when handling buffer lengths.  As a
bonus, this prevents a mixed sign comparison in idmap_lookup_name.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/nfs/idmap.c |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/fs/nfs/idmap.c b/fs/nfs/idmap.c
index d93e071..8ae5dba 100644
--- a/fs/nfs/idmap.c
+++ b/fs/nfs/idmap.c
@@ -74,7 +74,7 @@ module_param_call(idmap_cache_timeout, param_set_idmap_timeout, param_get_int,
 struct idmap_hashent {
 	unsigned long		ih_expires;
 	__u32			ih_id;
-	int			ih_namelen;
+	size_t			ih_namelen;
 	char			ih_name[IDMAP_NAMESZ];
 };
 
@@ -193,7 +193,7 @@ idmap_lookup_id(struct idmap_hashtable *h, __u32 id)
  * pretty trivial.
  */
 static inline struct idmap_hashent *
-idmap_alloc_name(struct idmap_hashtable *h, char *name, unsigned len)
+idmap_alloc_name(struct idmap_hashtable *h, char *name, size_t len)
 {
 	return idmap_name_hash(h, name, len);
 }
@@ -381,7 +381,7 @@ idmap_pipe_downcall(struct file *filp, const char __user *src, size_t mlen)
 	struct idmap_msg im_in, *im = &idmap->idmap_im;
 	struct idmap_hashtable *h;
 	struct idmap_hashent *he = NULL;
-	int namelen_in;
+	size_t namelen_in;
 	int ret;
 
 	if (mlen != sizeof(im_in))

