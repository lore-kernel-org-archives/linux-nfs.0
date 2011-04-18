Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:33111 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751290Ab1DRUwm (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 18 Apr 2011 16:52:42 -0400
From: bjschuma@netapp.com
To: Trond.Myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org, Bryan Schumaker <bjschuma@netapp.com>
Subject: [PATCH v2 1/2] Handle NFS4ERR_WRONGSEC outside of nfs4_handle_exception()
Date: Mon, 18 Apr 2011 16:52:25 -0400
Message-Id: <1303159945-13020-1-git-send-email-bjschuma@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

From: Bryan Schumaker <bjschuma@netapp.com>

I only want to try other secflavors during an initial mount if
NFS4ERR_WRONGSEC is returned.  nfs4_handle_exception() could
potentially map other errors to EPERM, so we should handle this
error specially for correctness.

Signed-off-by: Bryan Schumaker <bjschuma@netapp.com>
---
 fs/nfs/nfs4proc.c |   28 +++++++++++++++++++++++-----
 1 files changed, 23 insertions(+), 5 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index b8e1ac6..8169f48 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -2186,9 +2186,14 @@ static int nfs4_lookup_root(struct nfs_server *server, struct nfs_fh *fhandle,
 	struct nfs4_exception exception = { };
 	int err;
 	do {
-		err = nfs4_handle_exception(server,
-				_nfs4_lookup_root(server, fhandle, info),
-				&exception);
+		err = _nfs4_lookup_root(server, fhandle, info);
+		switch (err) {
+		case 0:
+		case -NFS4ERR_WRONGSEC:
+			break;
+		default:
+			err = nfs4_handle_exception(server, err, &exception);
+		}
 	} while (exception.retry);
 	return err;
 }
@@ -2221,10 +2226,19 @@ static int nfs4_find_root_sec(struct nfs_server *server, struct nfs_fh *fhandle,
 
 	for (i = 0; i < len; i++) {
 		status = nfs4_lookup_root_sec(server, fhandle, info, flav_array[i]);
-		if (status == -EPERM || status == -EACCES)
+		if (status == -NFS4ERR_WRONGSEC || status == -EACCES)
 			continue;
 		break;
 	}
+	/*
+	 * -EACCESS could mean that the user doesn't have correct permissions
+	 * to access the mount.  It could also mean that we tried to mount
+	 * with a gss auth flavor, but rpc.gssd isn't running.  Either way,
+	 * existing mount programs don't handle -EACCES very well so it should
+	 * be mapped to -EPERM instead.
+	 */
+	if (status == -EACCES)
+		status = -EPERM;
 	return status;
 }
 
@@ -2235,7 +2249,11 @@ static int nfs4_proc_get_root(struct nfs_server *server, struct nfs_fh *fhandle,
 			      struct nfs_fsinfo *info)
 {
 	int status = nfs4_lookup_root(server, fhandle, info);
-	if ((status == -EPERM) && !(server->flags & NFS_MOUNT_SECFLAVOUR))
+	if ((status == -NFS4ERR_WRONGSEC) && !(server->flags & NFS_MOUNT_SECFLAVOUR))
+		/*
+		 * A status of -NFS4ERR_WRONGSEC will be mapped to -EPERM
+		 * by nfs4_map_errors() as this function exits.
+		 */
 		status = nfs4_find_root_sec(server, fhandle, info);
 	if (status == 0)
 		status = nfs4_server_capabilities(server, fhandle);
-- 
1.7.4.4

