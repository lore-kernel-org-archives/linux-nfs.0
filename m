From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 088/112] NFS: Use size_t for storing name lengths
Date: Fri, 25 Jan 2008 11:37:55 -0500
Message-ID: <20080125163755.31887.70798.stgit@c-69-242-210-120.hsd1.mi.comcast.net>
References: <20080125163723.31887.68074.stgit@c-69-242-210-120.hsd1.mi.comcast.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:46194 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757069AbYAYRB7 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 25 Jan 2008 12:01:59 -0500
Received: from svlexrs01.hq.netapp.com (svlexrs01.corp.netapp.com [10.57.156.158])
	by smtp1.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id m0PH0WPV020490
	for <linux-nfs@vger.kernel.org>; Fri, 25 Jan 2008 09:01:44 -0800 (PST)
In-Reply-To: <20080125163723.31887.68074.stgit-KPEdlmqt5P7XOazzY/2fV4TcuzvYVacciM950cveMlzk1uMJSBkQmQ@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Chuck Lever <chuck.lever@oracle.com>

Clean up: always use the same type when handling buffer lengths.  As a
bonus, this prevents a mixed sign comparison in idmap_lookup_name.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
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
