Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from adsl-76-241-169-38.dsl.sfldmi.sbcglobal.net ([76.241.169.38]:50550
	"EHLO matisse.1015granger.net" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1753372AbZHDN7L (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 4 Aug 2009 09:59:11 -0400
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 4/4] NFS: Use the authentication flavor list returned by mountd
To: trond.myklebust@fys.uio.no
Cc: linux-nfs@vger.kernel.org
Date: Tue, 04 Aug 2009 09:59:09 -0400
Message-ID: <20090804135909.2287.66026.stgit@matisse.1015granger.net>
In-Reply-To: <20090804135425.2287.3313.stgit@matisse.1015granger.net>
References: <20090804135425.2287.3313.stgit@matisse.1015granger.net>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Commit a14017db added support in the kernel's NFS mount client to
decode the authentication flavor list returned by mountd.

The NFS client can now use this list to determine whether the
authentication flavor requested by the user is actually supported
by the server.

Note we don't actually negotiate the security flavor if none was
specified by the user.  Instead, we try to use AUTH_SYS, and fail if
the server does not support it.  This prevents us from negotiating
an inappropriate security flavor (some servers list AUTH_NULL first).

If the server does not support AUTH_SYS, the user must provide an
appropriate security flavor by specifying the "sec=" mount option.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/nfs/super.c |   58 +++++++++++++++++++++++++++++++++++++++++++++++++-------
 1 files changed, 51 insertions(+), 7 deletions(-)

diff --git a/fs/nfs/super.c b/fs/nfs/super.c
index a33e608..8526008 100644
--- a/fs/nfs/super.c
+++ b/fs/nfs/super.c
@@ -1437,13 +1437,50 @@ out_security_failure:
 }
 
 /*
+ * Match the requested auth flavors with the list returned by
+ * the server.  Returns zero and sets the mount's authentication
+ * flavor on success; returns -EACCES if server does not support
+ * the requested flavor.
+ */
+static int nfs_walk_authlist(struct nfs_parsed_mount_data *args,
+			     struct nfs_mount_request *request)
+{
+	unsigned int i, j, server_authlist_len = *(request->auth_flav_len);
+
+	/*
+	 * We avoid sophisticated negotiating here, as there are
+	 * plenty of cases where we can get it wrong, providing
+	 * either too little or too much security.
+	 *
+	 * RFC 2623, section 2.7 suggests we SHOULD prefer the
+	 * flavor listed first.  However, some servers list
+	 * AUTH_NULL first.  Our caller plants AUTH_SYS, the
+	 * preferred default, in args->auth_flavors[0] if user
+	 * didn't specify sec= mount option.
+	 */
+	for (i = 0; i < args->auth_flavor_len; i++)
+		for (j = 0; j < server_authlist_len; j++)
+			if (args->auth_flavors[i] == request->auth_flavs[j]) {
+				dfprintk(MOUNT, "NFS: using auth flavor %d\n",
+					request->auth_flavs[j]);
+				args->auth_flavors[0] = request->auth_flavs[j];
+				return 0;
+			}
+
+	dfprintk(MOUNT, "NFS: server does not support requested auth flavor\n");
+	nfs_umount(request);
+	return -EACCES;
+}
+
+/*
  * Use the remote server's MOUNT service to request the NFS file handle
  * corresponding to the provided path.
  */
 static int nfs_try_mount(struct nfs_parsed_mount_data *args,
 			 struct nfs_fh *root_fh)
 {
-	unsigned int auth_flavor_len = 0;
+	rpc_authflavor_t server_authlist[NFS_MAX_SECFLAVORS];
+	unsigned int server_authlist_len = ARRAY_SIZE(server_authlist);
 	struct nfs_mount_request request = {
 		.sap		= (struct sockaddr *)
 						&args->mount_server.address,
@@ -1451,7 +1488,8 @@ static int nfs_try_mount(struct nfs_parsed_mount_data *args,
 		.protocol	= args->mount_server.protocol,
 		.fh		= root_fh,
 		.noresvport	= args->flags & NFS_MOUNT_NORESVPORT,
-		.auth_flav_len	= &auth_flavor_len,
+		.auth_flav_len	= &server_authlist_len,
+		.auth_flavs	= server_authlist,
 	};
 	int status;
 
@@ -1488,12 +1526,18 @@ static int nfs_try_mount(struct nfs_parsed_mount_data *args,
 	 * to a file handle.
 	 */
 	status = nfs_mount(&request);
-	if (status == 0)
-		return 0;
+	if (status != 0) {
+		dfprintk(MOUNT, "NFS: unable to mount server %s, error %d\n",
+				request.hostname, status);
+		return status;
+	}
 
-	dfprintk(MOUNT, "NFS: unable to mount server %s, error %d\n",
-			request.hostname, status);
-	return status;
+	/*
+	 * MNTv1 (NFSv2) does not support auth flavor negotiation.
+	 */
+	if (args->mount_server.version != NFS_MNT3_VERSION)
+		return 0;
+	return nfs_walk_authlist(args, &request);
 }
 
 static int nfs_parse_simple_hostname(const char *dev_name,

