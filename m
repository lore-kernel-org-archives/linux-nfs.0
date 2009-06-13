From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 4/8] NFS: add new file handle decoders to in-kernel mountd
	client
Date: Sat, 13 Jun 2009 19:26:08 -0400
Message-ID: <20090613232608.3225.99155.stgit@isabey.1015granger.net>
References: <20090613232149.3225.92143.stgit@isabey.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: trond.myklebust@fys.uio.no
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from acsinet11.oracle.com ([141.146.126.233]:48408 "EHLO
	acsinet11.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753944AbZFMX0e (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 13 Jun 2009 19:26:34 -0400
In-Reply-To: <20090613232149.3225.92143.stgit-r85ClMMopbrwdl/1UfZZQIVfYA8g3rJ/@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Introduce xdr_stream-based XDR file handle decoders to the in-kernel
mountd client.  These are more careful than the existing decoder
functions about buffer overflows and data type and range checking.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/nfs/mount_clnt.c |   39 +++++++++++++++++++++++++++++++++++++++
 1 files changed, 39 insertions(+), 0 deletions(-)

diff --git a/fs/nfs/mount_clnt.c b/fs/nfs/mount_clnt.c
index 8429885..dd8c6f4 100644
--- a/fs/nfs/mount_clnt.c
+++ b/fs/nfs/mount_clnt.c
@@ -31,6 +31,8 @@
 #define encode_dirpath_sz	(1 + XDR_QUADLEN(MNTPATHLEN))
 #define MNT_status_sz		(1)
 #define MNT_fhs_status_sz	(1)
+#define MNT_fhandle_sz		XDR_QUADLEN(NFS2_FHSIZE)
+#define MNT_fhandle3_sz		(1 + XDR_QUADLEN(NFS3_FHSIZE))
 
 /*
  * XDR argument and result sizes
@@ -272,6 +274,20 @@ static int decode_status(struct xdr_stream *xdr, struct mountres *res)
 	return 0;
 }
 
+static int decode_fhandle(struct xdr_stream *xdr, struct mountres *res)
+{
+	struct nfs_fh *fh = res->fh;
+	__be32 *p;
+
+	p = xdr_inline_decode(xdr, NFS2_FHSIZE);
+	if (unlikely(p == NULL))
+		return -EIO;
+
+	fh->size = NFS2_FHSIZE;
+	memcpy(fh->data, p, NFS2_FHSIZE);
+	return 0;
+}
+
 static int decode_fhs_status(struct xdr_stream *xdr, struct mountres *res)
 {
 	unsigned int i;
@@ -295,6 +311,29 @@ static int decode_fhs_status(struct xdr_stream *xdr, struct mountres *res)
 	return 0;
 }
 
+static int decode_fhandle3(struct xdr_stream *xdr, struct mountres *res)
+{
+	struct nfs_fh *fh = res->fh;
+	u32 size;
+	__be32 *p;
+
+	p = xdr_inline_decode(xdr, sizeof(size));
+	if (unlikely(p == NULL))
+		return -EIO;
+
+	size = ntohl(*p++);
+	if (size > NFS3_FHSIZE || size == 0)
+		return -EIO;
+
+	p = xdr_inline_decode(xdr, size);
+	if (unlikely(p == NULL))
+		return -EIO;
+
+	fh->size = size;
+	memcpy(fh->data, p, size);
+	return 0;
+}
+
 static int xdr_decode_fhstatus3(struct rpc_rqst *req, __be32 *p,
 				struct mnt_fhstatus *res)
 {

