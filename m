From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 12/27] NFS: Use size_t for storing buffer lengths
Date: Fri, 26 Oct 2007 13:31:42 -0400
Message-ID: <20071026173142.31475.50315.stgit@manray.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: trond.myklebust@fys.uio.no
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IlT2G-0007EC-U1
	for nfs@lists.sourceforge.net; Fri, 26 Oct 2007 10:31:53 -0700
Received: from flpi185.sbcis.sbc.com ([207.115.20.187]
	helo=flpi185.prodigy.net)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IlT2M-0008NX-BW
	for nfs@lists.sourceforge.net; Fri, 26 Oct 2007 10:31:58 -0700
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

Prevent buffer length underflow by using a size_t to store and pass
buffer lengths.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/nfs/idmap.c |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/fs/nfs/idmap.c b/fs/nfs/idmap.c
index 6ecc9c3..917a370 100644
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
 
@@ -192,7 +192,7 @@ idmap_lookup_id(struct idmap_hashtable *h, __u32 id)
  * pretty trivial.
  */
 static inline struct idmap_hashent *
-idmap_alloc_name(struct idmap_hashtable *h, char *name, unsigned len)
+idmap_alloc_name(struct idmap_hashtable *h, char *name, size_t len)
 {
 	return idmap_name_hash(h, name, len);
 }
@@ -383,7 +383,7 @@ idmap_pipe_downcall(struct file *filp, const char __user *src, size_t mlen)
 	struct idmap_msg im_in, *im = &idmap->idmap_im;
 	struct idmap_hashtable *h;
 	struct idmap_hashent *he = NULL;
-	int namelen_in;
+	size_t namelen_in;
 	int ret;
 
 	if (mlen != sizeof(im_in))


-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >> http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
