Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ie0-f170.google.com ([209.85.223.170]:44167 "EHLO
	mail-ie0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756418Ab3A3Xmo (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 30 Jan 2013 18:42:44 -0500
Received: by mail-ie0-f170.google.com with SMTP id c11so1859886ieb.29
        for <linux-nfs@vger.kernel.org>; Wed, 30 Jan 2013 15:42:43 -0800 (PST)
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH v2 5/9] SUNRPC: Load GSS kernel module by OID
To: linux-nfs@vger.kernel.org
Cc: Chuck Lever <chuck.lever@oracle.com>, David Howells <dhowells@redhat.com>
Date: Wed, 30 Jan 2013 18:42:42 -0500
Message-ID: <20130130234242.47786.73848.stgit@seurat.1015granger.net>
In-Reply-To: <20130130231546.47786.6016.stgit@seurat.1015granger.net>
References: <20130130231546.47786.6016.stgit@seurat.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The current GSS mech switch can find and load GSS pseudoflavor
modules by name ("krb5") or pseudoflavor number ("390003"), but
cannot find GSS modules by GSS tuple:

  [ "1.2.840.113554.1.2.2", GSS_C_QOP_DEFAULT, RPC_GSS_SVC_NONE ]

This is important when dealing with a SECINFO request.  A SECINFO
reply contains a list of flavors the server supports for the
requested export, but GSS flavors also have a GSS tuple that maps
to a pseudoflavor (like 390003 for krb5).

If the GSS module that supports the OID in the tuple is not loaded,
our client is not able to load that module dynamically to support
that pseudoflavor.

Add a way for the GSS mech switch to load GSS pseudoflavor support
by OID before searching for the pseudoflavor that matches the OID
and service.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
Cc: David Howells <dhowells@redhat.com>
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
index 61d36ce..b822ec5 100644
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
index b09f25b..8d03d32 100644
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
+	dprintk("RPC:       %s(%s)\n", __func__, buf);
+	request_module("rpc-auth-gss-%s", buf);
 
 	spin_lock(&registered_mechs_lock);
 	list_for_each_entry(pos, &registered_mechs, gm_list) {

