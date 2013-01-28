Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ia0-f182.google.com ([209.85.210.182]:56688 "EHLO
	mail-ia0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753531Ab3A1Ub7 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 28 Jan 2013 15:31:59 -0500
Received: by mail-ia0-f182.google.com with SMTP id w33so4857673iag.27
        for <linux-nfs@vger.kernel.org>; Mon, 28 Jan 2013 12:31:58 -0800 (PST)
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 1 4/5] SUNRPC: Find kernel module by OID
To: linux-nfs@vger.kernel.org
Cc: Chuck Lever <chuck.lever@oracle.com>
Date: Mon, 28 Jan 2013 15:31:57 -0500
Message-ID: <20130128203157.2523.17121.stgit@seurat.1015granger.net>
In-Reply-To: <20130128195843.2523.34798.stgit@seurat.1015granger.net>
References: <20130128195843.2523.34798.stgit@seurat.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The current GSS mech switch can find and load GSS pseudoflavor
modules by name or pseudoflavor number, but cannot find them by OID.

This is important when dealing with a SECINFO request, especially
early in the boot process.  A SECINFO reply has a list of flavors
the server can support, but they are listed by OID.  Our client
currently can choose only flavors that are already loaded.  We want
to be able to choose flavors where the module is available but not
yet loaded.

Add a way for the GSS mech switch to load GSS pseudoflavor support
by OID.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 net/sunrpc/Kconfig                    |    1 +
 net/sunrpc/auth_gss/gss_krb5_mech.c   |    1 +
 net/sunrpc/auth_gss/gss_mech_switch.c |    7 +++++++
 3 files changed, 9 insertions(+), 0 deletions(-)

diff --git a/net/sunrpc/Kconfig b/net/sunrpc/Kconfig
index 03d03e3..f97f555 100644
--- a/net/sunrpc/Kconfig
+++ b/net/sunrpc/Kconfig
@@ -3,6 +3,7 @@ config SUNRPC
 
 config SUNRPC_GSS
 	tristate
+	select OID_REGISTRY
 
 config SUNRPC_BACKCHANNEL
 	bool
diff --git a/net/sunrpc/auth_gss/gss_krb5_mech.c b/net/sunrpc/auth_gss/gss_krb5_mech.c
index d3611f1..8b1005d 100644
--- a/net/sunrpc/auth_gss/gss_krb5_mech.c
+++ b/net/sunrpc/auth_gss/gss_krb5_mech.c
@@ -750,6 +750,7 @@ MODULE_ALIAS("rpc-auth-gss-krb5p");
 MODULE_ALIAS("rpc-auth-gss-390003");
 MODULE_ALIAS("rpc-auth-gss-390004");
 MODULE_ALIAS("rpc-auth-gss-390005");
+MODULE_ALIAS("rpc-auth-gss-1.2.840.113554.1.2.2");
 
 static struct gss_api_mech gss_kerberos_mech = {
 	.gm_name	= "krb5",
diff --git a/net/sunrpc/auth_gss/gss_mech_switch.c b/net/sunrpc/auth_gss/gss_mech_switch.c
index 883b5b8..64dbf07a 100644
--- a/net/sunrpc/auth_gss/gss_mech_switch.c
+++ b/net/sunrpc/auth_gss/gss_mech_switch.c
@@ -36,6 +36,7 @@
 #include <linux/types.h>
 #include <linux/slab.h>
 #include <linux/module.h>
+#include <linux/oid_registry.h>
 #include <linux/sunrpc/msg_prot.h>
 #include <linux/sunrpc/gss_asn1.h>
 #include <linux/sunrpc/auth_gss.h>
@@ -174,6 +175,12 @@ EXPORT_SYMBOL_GPL(gss_mech_get_by_name);
 static struct gss_api_mech *gss_mech_get_by_OID(struct rpcsec_gss_oid *obj)
 {
 	struct gss_api_mech	*pos, *gm = NULL;
+	char buf[32];
+
+	if (sprint_oid(obj->data, obj->len, buf, sizeof(buf)) < 0)
+		return NULL;
+	dprintk("RPC:       %s: oid: %s\n", __func__, buf);
+	request_module("rpc-auth-gss-%s", buf);
 
 	spin_lock(&registered_mechs_lock);
 	list_for_each_entry(pos, &registered_mechs, gm_list) {

