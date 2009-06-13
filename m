From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 2/8] NFS: remove unused function in fs/nfs/mount_clnt.c
Date: Sat, 13 Jun 2009 19:25:54 -0400
Message-ID: <20090613232553.3225.20231.stgit@isabey.1015granger.net>
References: <20090613232149.3225.92143.stgit@isabey.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: trond.myklebust@fys.uio.no
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from acsinet11.oracle.com ([141.146.126.233]:48423 "EHLO
	acsinet11.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755266AbZFMX0g (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 13 Jun 2009 19:26:36 -0400
In-Reply-To: <20090613232149.3225.92143.stgit-r85ClMMopbrwdl/1UfZZQIVfYA8g3rJ/@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Clean up: remove xdr_encode_dirpath() now that it has been replaced.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/nfs/mount_clnt.c |    8 --------
 1 files changed, 0 insertions(+), 8 deletions(-)

diff --git a/fs/nfs/mount_clnt.c b/fs/nfs/mount_clnt.c
index 93361af..79b5954 100644
--- a/fs/nfs/mount_clnt.c
+++ b/fs/nfs/mount_clnt.c
@@ -141,14 +141,6 @@ out_mnt_err:
 /*
  * XDR encode/decode functions for MOUNT
  */
-static int xdr_encode_dirpath(struct rpc_rqst *req, __be32 *p,
-			      const char *path)
-{
-	p = xdr_encode_string(p, path);
-
-	req->rq_slen = xdr_adjust_iovec(req->rq_svec, p);
-	return 0;
-}
 
 static int encode_mntdirpath(struct xdr_stream *xdr, const char *pathname)
 {

