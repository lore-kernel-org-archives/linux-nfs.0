Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ia0-f174.google.com ([209.85.210.174]:47734 "EHLO
	mail-ia0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751439Ab3CPTz3 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 16 Mar 2013 15:55:29 -0400
Received: by mail-ia0-f174.google.com with SMTP id b35so132021iac.19
        for <linux-nfs@vger.kernel.org>; Sat, 16 Mar 2013 12:55:29 -0700 (PDT)
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH v1 09/15] SUNRPC: Remove EXPORT_SYMBOL_GPL() from GSS mech
 switch
To: trond.myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org, Chuck Lever <chuck.lever@oracle.com>
Date: Sat, 16 Mar 2013 15:55:27 -0400
Message-ID: <20130316195527.27329.8603.stgit@seurat.1015granger.net>
In-Reply-To: <20130316195044.27329.11666.stgit@seurat.1015granger.net>
References: <20130316195044.27329.11666.stgit@seurat.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Clean up: Reduce the symbol table footprint for auth_rpcgss.ko by
removing exported symbols for functions that are no longer used
outside of auth_rpcgss.ko.

The remaining two EXPORTs in gss_mech_switch.c get documenting
comments.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 net/sunrpc/auth_gss/gss_mech_switch.c |   26 +++++++++++++-------------
 1 files changed, 13 insertions(+), 13 deletions(-)

diff --git a/net/sunrpc/auth_gss/gss_mech_switch.c b/net/sunrpc/auth_gss/gss_mech_switch.c
index 8941652..79881d6 100644
--- a/net/sunrpc/auth_gss/gss_mech_switch.c
+++ b/net/sunrpc/auth_gss/gss_mech_switch.c
@@ -103,8 +103,13 @@ out:
 	return status;
 }
 
-int
-gss_mech_register(struct gss_api_mech *gm)
+/**
+ * gss_mech_register - register a GSS mechanism
+ * @gm: GSS mechanism handle
+ *
+ * Returns zero if successful, or a negative errno.
+ */
+int gss_mech_register(struct gss_api_mech *gm)
 {
 	int status;
 
@@ -117,11 +122,14 @@ gss_mech_register(struct gss_api_mech *gm)
 	dprintk("RPC:       registered gss mechanism %s\n", gm->gm_name);
 	return 0;
 }
-
 EXPORT_SYMBOL_GPL(gss_mech_register);
 
-void
-gss_mech_unregister(struct gss_api_mech *gm)
+/**
+ * gss_mech_unregister - release a GSS mechanism
+ * @gm: GSS mechanism handle
+ *
+ */
+void gss_mech_unregister(struct gss_api_mech *gm)
 {
 	spin_lock(&registered_mechs_lock);
 	list_del(&gm->gm_list);
@@ -129,7 +137,6 @@ gss_mech_unregister(struct gss_api_mech *gm)
 	dprintk("RPC:       unregistered gss mechanism %s\n", gm->gm_name);
 	gss_mech_free(gm);
 }
-
 EXPORT_SYMBOL_GPL(gss_mech_unregister);
 
 static struct gss_api_mech *gss_mech_get(struct gss_api_mech *gm)
@@ -167,7 +174,6 @@ struct gss_api_mech * gss_mech_get_by_name(const char *name)
 	}
 	return gm;
 }
-EXPORT_SYMBOL_GPL(gss_mech_get_by_name);
 
 static struct gss_api_mech *gss_mech_get_by_OID(struct rpcsec_gss_oid *obj)
 {
@@ -355,8 +361,6 @@ gss_pseudoflavor_to_service(struct gss_api_mech *gm, u32 pseudoflavor)
 	return 0;
 }
 
-EXPORT_SYMBOL_GPL(gss_pseudoflavor_to_service);
-
 char *
 gss_service_to_auth_domain_name(struct gss_api_mech *gm, u32 service)
 {
@@ -369,8 +373,6 @@ gss_service_to_auth_domain_name(struct gss_api_mech *gm, u32 service)
 	return NULL;
 }
 
-EXPORT_SYMBOL_GPL(gss_service_to_auth_domain_name);
-
 void
 gss_mech_put(struct gss_api_mech * gm)
 {
@@ -378,8 +380,6 @@ gss_mech_put(struct gss_api_mech * gm)
 		module_put(gm->gm_owner);
 }
 
-EXPORT_SYMBOL_GPL(gss_mech_put);
-
 /* The mech could probably be determined from the token instead, but it's just
  * as easy for now to pass it in. */
 int

