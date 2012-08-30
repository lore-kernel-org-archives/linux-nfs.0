Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-pb0-f46.google.com ([209.85.160.46]:60811 "EHLO
	mail-pb0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751865Ab2H3UyF (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 30 Aug 2012 16:54:05 -0400
Received: by pbbrr13 with SMTP id rr13so3758610pbb.19
        for <linux-nfs@vger.kernel.org>; Thu, 30 Aug 2012 13:54:05 -0700 (PDT)
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH] NFS: Filter auth flavors returned by MNT3
To: linux-nfs@vger.kernel.org
Date: Thu, 30 Aug 2012 13:53:58 -0700
Message-ID: <20120830204930.3101.99200.stgit@seurat.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Use the new rpcauth_list_flavors() API introduced in commit 6a1a1e34
to prevent legacy NFS mounts from attempting to use security flavors
that the local RPC client does not support.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

I don't remember exactly what we wanted to do here.  Trond, do you
recall?

 fs/nfs/mount_clnt.c |   91 +++++++++++++++++++++++++++++++++++++++++++++++++++
 1 files changed, 91 insertions(+), 0 deletions(-)

diff --git a/fs/nfs/mount_clnt.c b/fs/nfs/mount_clnt.c
index 8e65c7f..3e39678 100644
--- a/fs/nfs/mount_clnt.c
+++ b/fs/nfs/mount_clnt.c
@@ -135,6 +135,88 @@ struct mnt_fhstatus {
 	struct nfs_fh *fh;
 };
 
+/*
+ * Predicate: return true if info->auth_flavs[] contains "flavor"
+ */
+static bool flavor_found(struct nfs_mount_request *info,
+			 rpc_authflavor_t flavor)
+{
+	unsigned int i, max = *info->auth_flav_len;
+
+	for (i = 0; i < max; i++) {
+		if (info->auth_flavs[i] == flavor) {
+			return true;
+		}
+	}
+	return false;
+}
+
+static int do_filter_flavors(rpc_authflavor_t *supported,
+			     unsigned int sup_size,
+			     struct nfs_mount_request *info)
+{
+	unsigned int i, j, max = *info->auth_flav_len;
+	rpc_authflavor_t *good;
+	int status;
+
+	good = kcalloc(max, sizeof(*good), GFP_KERNEL);
+	if (good == NULL) {
+		status = -ENOMEM;
+		goto out;
+	}
+
+	j = 0;
+	for (i = 0; i < sup_size; i++) {
+		if (flavor_found(info, supported[i])) {
+			good[j++] = supported[i];
+		}
+	}
+
+	if (j == 0) {
+		/* no supported flavors found */
+		status = -EACCES;
+		goto out;
+	}
+
+	for (i = 0; i < j; i++) {
+		info->auth_flavs[i] = good[i];
+	}
+	*info->auth_flav_len = j;
+	status = 0;
+
+out:
+	kfree(good);
+	return status;
+}
+
+/*
+ * Flavors not supported locally are removed from the flavor list
+ * returned from the server.  On success, update the server's
+ * flavor list and return zero.  Otherwise a negative errno
+ * is returned.
+ */
+static int nfs_filter_auth_flavors(struct nfs_mount_request *info)
+{
+	int status, sup_size = NFS_MAX_SECFLAVORS;
+	rpc_authflavor_t *supported;
+
+	supported = kcalloc(sup_size, sizeof(*supported), GFP_KERNEL);
+	if (supported == NULL) {
+		status = -ENOMEM;
+		goto out;
+	}
+
+	status = rpcauth_list_flavors(supported, sup_size);
+	if (status < 0)
+		goto out;
+
+	status = do_filter_flavors(supported, status, info);
+
+out:
+	kfree(supported);
+	return status;
+}
+
 /**
  * nfs_mount - Obtain an NFS file handle for the given host and path
  * @info: pointer to mount request arguments
@@ -189,6 +271,12 @@ int nfs_mount(struct nfs_mount_request *info)
 	if (result.errno != 0)
 		goto out_mnt_err;
 
+	if (info->version == NFS_MNT3_VERSION) {
+		status = nfs_filter_auth_flavors(info);
+		if (status < 0)
+			goto out_filter_err;
+	}
+
 	dprintk("NFS: MNT request succeeded\n");
 	status = 0;
 
@@ -208,6 +296,9 @@ out_mnt_err:
 	dprintk("NFS: MNT server returned result %d\n", result.errno);
 	status = result.errno;
 	goto out;
+out_filter_err:
+	dprintk("NFS: error %d filtering flavors\n", status);
+	goto out;
 }
 
 /**

