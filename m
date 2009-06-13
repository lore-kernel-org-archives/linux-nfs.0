From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 5/8] NFS: add XDR decoder for mountd version 3 auth-flavor
	lists
Date: Sat, 13 Jun 2009 19:26:16 -0400
Message-ID: <20090613232615.3225.79468.stgit@isabey.1015granger.net>
References: <20090613232149.3225.92143.stgit@isabey.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: trond.myklebust@fys.uio.no
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from acsinet11.oracle.com ([141.146.126.233]:48426 "EHLO
	acsinet11.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755445AbZFMX0h (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 13 Jun 2009 19:26:37 -0400
In-Reply-To: <20090613232149.3225.92143.stgit-r85ClMMopbrwdl/1UfZZQIVfYA8g3rJ/@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Introduce an xdr_stream-based XDR decoder that can unpack the auth-
flavor list returned in a MNT3 reply.

The nfs_mount() function's caller allocates an array, and passes the
size and a pointer to it.  The decoder decodes all the flavors it can
into the array, and returns the number of decoded flavors.

If the caller is not interested in the auth flavors, it can pass a
value of zero as the size of the pre-allocated array.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/nfs/internal.h   |    6 ++++++
 fs/nfs/mount_clnt.c |   37 +++++++++++++++++++++++++++++++++++++
 2 files changed, 43 insertions(+), 0 deletions(-)

diff --git a/fs/nfs/internal.h b/fs/nfs/internal.h
index 1173099..b13b456 100644
--- a/fs/nfs/internal.h
+++ b/fs/nfs/internal.h
@@ -30,6 +30,12 @@ struct nfs_clone_mount {
 };
 
 /*
+ * Note: RFC 1813 doesn't limit the number of auth flavors that
+ * a server can return, so make something up.
+ */
+#define NFS_MAX_SECFLAVORS	(12)
+
+/*
  * In-kernel mount arguments
  */
 struct nfs_parsed_mount_data {
diff --git a/fs/nfs/mount_clnt.c b/fs/nfs/mount_clnt.c
index dd8c6f4..ed0a27e 100644
--- a/fs/nfs/mount_clnt.c
+++ b/fs/nfs/mount_clnt.c
@@ -33,6 +33,7 @@
 #define MNT_fhs_status_sz	(1)
 #define MNT_fhandle_sz		XDR_QUADLEN(NFS2_FHSIZE)
 #define MNT_fhandle3_sz		(1 + XDR_QUADLEN(NFS3_FHSIZE))
+#define MNT_authflav3_sz	(1 + NFS_MAX_SECFLAVORS)
 
 /*
  * XDR argument and result sizes
@@ -122,6 +123,8 @@ static struct {
 struct mountres {
 	int errno;
 	struct nfs_fh *fh;
+	unsigned int *auth_count;
+	rpc_authflavor_t *auth_flavors;
 };
 
 struct mnt_fhstatus {
@@ -334,6 +337,40 @@ static int decode_fhandle3(struct xdr_stream *xdr, struct mountres *res)
 	return 0;
 }
 
+static int decode_auth_flavors(struct xdr_stream *xdr, struct mountres *res)
+{
+	rpc_authflavor_t *flavors = res->auth_flavors;
+	unsigned int *count = res->auth_count;
+	u32 entries, i;
+	__be32 *p;
+
+	if (*count == 0)
+		return 0;
+
+	p = xdr_inline_decode(xdr, sizeof(entries));
+	if (unlikely(p == NULL))
+		return -EIO;
+	entries = ntohl(*p);
+	dprintk("NFS: received %u auth flavors\n", entries);
+	if (entries > NFS_MAX_SECFLAVORS)
+		entries = NFS_MAX_SECFLAVORS;
+
+	p = xdr_inline_decode(xdr, sizeof(u32) * entries);
+	if (unlikely(p == NULL))
+		return -EIO;
+
+	if (entries > *count)
+		entries = *count;
+
+	for (i = 0; i < entries; i++) {
+		flavors[i] = ntohl(*p++);
+		dprintk("NFS:\tflavor %u: %d\n", i, flavors[i]);
+	}
+	*count = i;
+
+	return 0;
+}
+
 static int xdr_decode_fhstatus3(struct rpc_rqst *req, __be32 *p,
 				struct mnt_fhstatus *res)
 {

