Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:3847 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751988Ab1AFV6u (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 6 Jan 2011 16:58:50 -0500
Message-ID: <4D263B19.7070003@netapp.com>
Date: Thu, 06 Jan 2011 16:58:49 -0500
From: Bryan Schumaker <bjschuma@netapp.com>
To: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "Myklebust, Trond" <Trond.Myklebust@netapp.com>
Subject: [PATCH v3 5/5] NFS: Determine initial mount security
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0


When sec=<something> is not presented as a mount option,
we should attempt to determine what security flavor the
server is using.

Signed-off-by: Bryan Schumaker <bjschuma@netapp.com>
---
 fs/nfs/nfs4proc.c                     |   33 +++++++++++++++++++++++++++++++--
 include/linux/sunrpc/gss_api.h        |    3 +++
 net/sunrpc/auth_gss/gss_mech_switch.c |   16 ++++++++++++++++
 3 files changed, 50 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 82d50c4..82c6162 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -41,6 +41,7 @@
 #include <linux/string.h>
 #include <linux/slab.h>
 #include <linux/sunrpc/clnt.h>
+#include <linux/sunrpc/gss_api.h>
 #include <linux/nfs.h>
 #include <linux/nfs4.h>
 #include <linux/nfs_fs.h>
@@ -2171,15 +2172,43 @@ static int nfs4_lookup_root(struct nfs_server *server, struct nfs_fh *fhandle,
 	return err;
 }
 
+static int nfs4_lookup_root_sec(struct nfs_server *server, struct nfs_fh *fhandle,
+				struct nfs_fsinfo *info, rpc_authflavor_t flavor)
+{
+	struct rpc_auth *auth;
+	int ret;
+
+	auth = rpcauth_create(flavor, server->client);
+	if (!auth) {
+		ret = -EIO;
+		goto out;
+	}
+	ret = nfs4_lookup_root(server, fhandle, info);
+	if (ret < 0)
+		ret = -EAGAIN;
+out:
+	return ret;
+}
+
 /*
  * get the file handle for the "/" directory on the server
  */
 static int nfs4_proc_get_root(struct nfs_server *server, struct nfs_fh *fhandle,
 			      struct nfs_fsinfo *info)
 {
-	int status;
+	int i, len, status = 0;
+	rpc_authflavor_t flav_array[NFS_MAX_SECFLAVORS + 2];
 
-	status = nfs4_lookup_root(server, fhandle, info);
+	flav_array[0] = RPC_AUTH_UNIX;
+	len = gss_mech_list_pseudoflavors(&flav_array[1]);
+	flav_array[1+len] = RPC_AUTH_NULL;
+	len += 2;
+
+	for (i = 0; i < len; i++) {
+		status = nfs4_lookup_root_sec(server, fhandle, info, flav_array[i]);
+		if (status == 0)
+			break;
+	}
 	if (status == 0)
 		status = nfs4_server_capabilities(server, fhandle);
 	if (status == 0)
diff --git a/include/linux/sunrpc/gss_api.h b/include/linux/sunrpc/gss_api.h
index 5d8048b..332da61 100644
--- a/include/linux/sunrpc/gss_api.h
+++ b/include/linux/sunrpc/gss_api.h
@@ -126,6 +126,9 @@ struct gss_api_mech *gss_mech_get_by_name(const char *);
 /* Similar, but get by pseudoflavor. */
 struct gss_api_mech *gss_mech_get_by_pseudoflavor(u32);
 
+/* Fill in an array with a list of supported pseudoflavors */
+int gss_mech_list_pseudoflavors(u32 *);
+
 /* Just increments the mechanism's reference count and returns its input: */
 struct gss_api_mech * gss_mech_get(struct gss_api_mech *);
 
diff --git a/net/sunrpc/auth_gss/gss_mech_switch.c b/net/sunrpc/auth_gss/gss_mech_switch.c
index 6c844b0..e3c36a2 100644
--- a/net/sunrpc/auth_gss/gss_mech_switch.c
+++ b/net/sunrpc/auth_gss/gss_mech_switch.c
@@ -215,6 +215,22 @@ gss_mech_get_by_pseudoflavor(u32 pseudoflavor)
 
 EXPORT_SYMBOL_GPL(gss_mech_get_by_pseudoflavor);
 
+int gss_mech_list_pseudoflavors(rpc_authflavor_t *array_ptr)
+{
+	struct gss_api_mech *pos = NULL;
+	int i = 0;
+
+	spin_lock(&registered_mechs_lock);
+	list_for_each_entry(pos, &registered_mechs, gm_list) {
+		array_ptr[i] = pos->gm_pfs->pseudoflavor;
+		i++;
+	}
+	spin_unlock(&registered_mechs_lock);
+	return i;
+}
+
+EXPORT_SYMBOL_GPL(gss_mech_list_pseudoflavors);
+
 u32
 gss_svc_to_pseudoflavor(struct gss_api_mech *gm, u32 service)
 {
-- 
1.7.3.4

