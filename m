Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-yx0-f174.google.com ([209.85.213.174]:59181 "EHLO
	mail-yx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932350Ab2GKUbK (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 11 Jul 2012 16:31:10 -0400
Received: by yenl2 with SMTP id l2so1691195yen.19
        for <linux-nfs@vger.kernel.org>; Wed, 11 Jul 2012 13:31:10 -0700 (PDT)
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 10/15] SUNRPC: Add rpcauth_list_flavors()
To: trond.myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org
Date: Wed, 11 Jul 2012 16:31:08 -0400
Message-ID: <20120711203107.3767.51920.stgit@degas.1015granger.net>
In-Reply-To: <20120711201718.3767.66867.stgit@degas.1015granger.net>
References: <20120711201718.3767.66867.stgit@degas.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The gss_mech_list_pseudoflavors() function provides a list of
currently registered GSS pseudoflavors.  This list does not include
any non-GSS flavors that have been registered with the RPC client.
nfs4_find_root_sec() currently adds these extra flavors by hand.

Instead, nfs4_find_root_sec() should be looking at the set of flavors
that have been explicitly registered via rpcauth_register().  And,
other areas of code will soon need the same kind of list that
contains all flavors the kernel currently knows about (see below).

Rather than cloning the open-coded logic in nfs4_find_root_sec() to
those new places, introduce a generic RPC function that generates a
full list of registered auth flavors and pseudoflavors.

A new rpc_authops method is added that lists a flavor's
pseudoflavors, if it has any.  I encountered an interesting module
loader loop when I tried to get the RPC client to invoke
gss_mech_list_pseudoflavors() by name.

This patch is a pre-requisite for server trunking discovery, and a
pre-requisite for fixing up the in-kernel mount client to do better
automatic security flavor selection.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/nfs/nfs4proc.c                     |   11 ++++---
 include/linux/sunrpc/auth.h           |    2 +
 include/linux/sunrpc/gss_api.h        |    3 +-
 net/sunrpc/auth.c                     |   54 +++++++++++++++++++++++++++++++++
 net/sunrpc/auth_gss/auth_gss.c        |    1 +
 net/sunrpc/auth_gss/gss_mech_switch.c |   18 +++++++++--
 6 files changed, 80 insertions(+), 9 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 43c678b..75bff3f 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -43,7 +43,6 @@
 #include <linux/printk.h>
 #include <linux/slab.h>
 #include <linux/sunrpc/clnt.h>
-#include <linux/sunrpc/gss_api.h>
 #include <linux/nfs.h>
 #include <linux/nfs4.h>
 #include <linux/nfs_fs.h>
@@ -2417,11 +2416,15 @@ static int nfs4_find_root_sec(struct nfs_server *server, struct nfs_fh *fhandle,
 	int i, len, status = 0;
 	rpc_authflavor_t flav_array[NFS_MAX_SECFLAVORS];
 
-	len = gss_mech_list_pseudoflavors(&flav_array[0]);
-	flav_array[len] = RPC_AUTH_NULL;
-	len += 1;
+	len = rpcauth_list_flavors(flav_array, ARRAY_SIZE(flav_array));
+	BUG_ON(len < 0);
 
 	for (i = 0; i < len; i++) {
+		/* AUTH_UNIX is the default flavor if none was specified,
+		 * thus has already been tried. */
+		if (flav_array[i] == RPC_AUTH_UNIX)
+			continue;
+
 		status = nfs4_lookup_root_sec(server, fhandle, info, flav_array[i]);
 		if (status == -NFS4ERR_WRONGSEC || status == -EACCES)
 			continue;
diff --git a/include/linux/sunrpc/auth.h b/include/linux/sunrpc/auth.h
index 492a36d..f25ba92 100644
--- a/include/linux/sunrpc/auth.h
+++ b/include/linux/sunrpc/auth.h
@@ -101,6 +101,7 @@ struct rpc_authops {
 	struct rpc_cred *	(*crcreate)(struct rpc_auth*, struct auth_cred *, int);
 	int			(*pipes_create)(struct rpc_auth *);
 	void			(*pipes_destroy)(struct rpc_auth *);
+	int			(*list_pseudoflavors)(rpc_authflavor_t *, int);
 };
 
 struct rpc_credops {
@@ -135,6 +136,7 @@ int			rpcauth_register(const struct rpc_authops *);
 int			rpcauth_unregister(const struct rpc_authops *);
 struct rpc_auth *	rpcauth_create(rpc_authflavor_t, struct rpc_clnt *);
 void			rpcauth_release(struct rpc_auth *);
+int			rpcauth_list_flavors(rpc_authflavor_t *, int);
 struct rpc_cred *	rpcauth_lookup_credcache(struct rpc_auth *, struct auth_cred *, int);
 void			rpcauth_init_cred(struct rpc_cred *, const struct auth_cred *, struct rpc_auth *, const struct rpc_credops *);
 struct rpc_cred *	rpcauth_lookupcred(struct rpc_auth *, int);
diff --git a/include/linux/sunrpc/gss_api.h b/include/linux/sunrpc/gss_api.h
index 332da61..a19e254 100644
--- a/include/linux/sunrpc/gss_api.h
+++ b/include/linux/sunrpc/gss_api.h
@@ -14,6 +14,7 @@
 
 #ifdef __KERNEL__
 #include <linux/sunrpc/xdr.h>
+#include <linux/sunrpc/msg_prot.h>
 #include <linux/uio.h>
 
 /* The mechanism-independent gss-api context: */
@@ -127,7 +128,7 @@ struct gss_api_mech *gss_mech_get_by_name(const char *);
 struct gss_api_mech *gss_mech_get_by_pseudoflavor(u32);
 
 /* Fill in an array with a list of supported pseudoflavors */
-int gss_mech_list_pseudoflavors(u32 *);
+int gss_mech_list_pseudoflavors(rpc_authflavor_t *, int);
 
 /* Just increments the mechanism's reference count and returns its input: */
 struct gss_api_mech * gss_mech_get(struct gss_api_mech *);
diff --git a/net/sunrpc/auth.c b/net/sunrpc/auth.c
index 727e506..b5c067b 100644
--- a/net/sunrpc/auth.c
+++ b/net/sunrpc/auth.c
@@ -13,6 +13,7 @@
 #include <linux/errno.h>
 #include <linux/hash.h>
 #include <linux/sunrpc/clnt.h>
+#include <linux/sunrpc/gss_api.h>
 #include <linux/spinlock.h>
 
 #ifdef RPC_DEBUG
@@ -122,6 +123,59 @@ rpcauth_unregister(const struct rpc_authops *ops)
 }
 EXPORT_SYMBOL_GPL(rpcauth_unregister);
 
+/**
+ * rpcauth_list_flavors - discover registered flavors and pseudoflavors
+ * @array: array to fill in
+ * @size: size of "array"
+ *
+ * Returns the number of array items filled in, or a negative errno.
+ *
+ * The returned array is not sorted by any policy.  Callers should not
+ * rely on the order of the items in the returned array.
+ */
+int
+rpcauth_list_flavors(rpc_authflavor_t *array, int size)
+{
+	rpc_authflavor_t flavor;
+	int result = 0;
+
+	spin_lock(&rpc_authflavor_lock);
+	for (flavor = 0; flavor < RPC_AUTH_MAXFLAVOR; flavor++) {
+		const struct rpc_authops *ops = auth_flavors[flavor];
+		rpc_authflavor_t pseudos[4];
+		int i, len;
+
+		if (result >= size) {
+			result = -ENOMEM;
+			break;
+		}
+
+		if (ops == NULL)
+			continue;
+		if (ops->list_pseudoflavors == NULL) {
+			array[result++] = ops->au_flavor;
+			continue;
+		}
+		len = ops->list_pseudoflavors(pseudos, ARRAY_SIZE(pseudos));
+		if (len < 0) {
+			result = len;
+			break;
+		}
+		for (i = 0; i < len; i++) {
+			if (result >= size) {
+				result = -ENOMEM;
+				break;
+			}
+			array[result++] = pseudos[i];
+		}
+	}
+	spin_unlock(&rpc_authflavor_lock);
+
+	dprintk("RPC:       %s returns %d\n", __func__, result);
+	return result;
+}
+EXPORT_SYMBOL_GPL(rpcauth_list_flavors);
+
 struct rpc_auth *
 rpcauth_create(rpc_authflavor_t pseudoflavor, struct rpc_clnt *clnt)
 {
diff --git a/net/sunrpc/auth_gss/auth_gss.c b/net/sunrpc/auth_gss/auth_gss.c
index d3ad81f..34c5220 100644
--- a/net/sunrpc/auth_gss/auth_gss.c
+++ b/net/sunrpc/auth_gss/auth_gss.c
@@ -1619,6 +1619,7 @@ static const struct rpc_authops authgss_ops = {
 	.crcreate	= gss_create_cred,
 	.pipes_create	= gss_pipes_dentries_create,
 	.pipes_destroy	= gss_pipes_dentries_destroy,
+	.list_pseudoflavors = gss_mech_list_pseudoflavors,
 };
 
 static const struct rpc_credops gss_credops = {
diff --git a/net/sunrpc/auth_gss/gss_mech_switch.c b/net/sunrpc/auth_gss/gss_mech_switch.c
index 782bfe1..6ac5dfc 100644
--- a/net/sunrpc/auth_gss/gss_mech_switch.c
+++ b/net/sunrpc/auth_gss/gss_mech_switch.c
@@ -239,14 +239,26 @@ gss_mech_get_by_pseudoflavor(u32 pseudoflavor)
 
 EXPORT_SYMBOL_GPL(gss_mech_get_by_pseudoflavor);
 
-int gss_mech_list_pseudoflavors(rpc_authflavor_t *array_ptr)
+/**
+ * gss_mech_list_pseudoflavors - Discover registered GSS pseudoflavors
+ * @array: array to fill in
+ * @size: size of "array"
+ *
+ * Returns the number of array items filled in, or a negative errno.
+ *
+ * The returned array is not sorted by any policy.  Callers should not
+ * rely on the order of the items in the returned array.
+ */
+int gss_mech_list_pseudoflavors(rpc_authflavor_t *array_ptr, int size)
 {
 	struct gss_api_mech *pos = NULL;
 	int j, i = 0;
 
 	spin_lock(&registered_mechs_lock);
 	list_for_each_entry(pos, &registered_mechs, gm_list) {
-		for (j=0; j < pos->gm_pf_num; j++) {
+		for (j = 0; j < pos->gm_pf_num; j++) {
+			if (i >= size)
+				return -ENOMEM;
 			array_ptr[i++] = pos->gm_pfs[j].pseudoflavor;
 		}
 	}
@@ -254,8 +266,6 @@ int gss_mech_list_pseudoflavors(rpc_authflavor_t *array_ptr)
 	return i;
 }
 
-EXPORT_SYMBOL_GPL(gss_mech_list_pseudoflavors);
-
 u32
 gss_svc_to_pseudoflavor(struct gss_api_mech *gm, u32 service)
 {

