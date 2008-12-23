From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 04/69] SUNRPC: rpcsec_gss modules should not be used by
 out-of-tree code
Date: Tue, 23 Dec 2008 18:02:06 -0500
Message-ID: <20081223230205.13743.2424.stgit@heimdal.trondhjem.org>
References: <20081223230158.13743.53992.stgit@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:45954 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752217AbYLWXXk (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 23 Dec 2008 18:23:40 -0500
Received: from svlrsexc2-prd.hq.netapp.com ([10.57.115.31])
	by smtp1.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id mBNNNa7K021304
	for <linux-nfs@vger.kernel.org>; Tue, 23 Dec 2008 15:23:38 -0800 (PST)
In-Reply-To: <20081223230158.13743.53992.stgit-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---

 net/sunrpc/auth_gss/gss_generic_token.c |    6 +++---
 net/sunrpc/auth_gss/gss_mech_switch.c   |   18 +++++++++---------
 net/sunrpc/auth_gss/svcauth_gss.c       |    4 ++--
 3 files changed, 14 insertions(+), 14 deletions(-)


diff --git a/net/sunrpc/auth_gss/gss_generic_token.c b/net/sunrpc/auth_gss/gss_generic_token.c
index d83b881..c0ba39c 100644
--- a/net/sunrpc/auth_gss/gss_generic_token.c
+++ b/net/sunrpc/auth_gss/gss_generic_token.c
@@ -152,7 +152,7 @@ g_token_size(struct xdr_netobj *mech, unsigned int body_size)
 	return(1 + der_length_size(body_size) + body_size);
 }
 
-EXPORT_SYMBOL(g_token_size);
+EXPORT_SYMBOL_GPL(g_token_size);
 
 /* fills in a buffer with the token header.  The buffer is assumed to
    be the right size.  buf is advanced past the token header */
@@ -167,7 +167,7 @@ g_make_token_header(struct xdr_netobj *mech, int body_size, unsigned char **buf)
 	TWRITE_STR(*buf, mech->data, ((int) mech->len));
 }
 
-EXPORT_SYMBOL(g_make_token_header);
+EXPORT_SYMBOL_GPL(g_make_token_header);
 
 /*
  * Given a buffer containing a token, reads and verifies the token,
@@ -231,5 +231,5 @@ g_verify_token_header(struct xdr_netobj *mech, int *body_size,
 	return(ret);
 }
 
-EXPORT_SYMBOL(g_verify_token_header);
+EXPORT_SYMBOL_GPL(g_verify_token_header);
 
diff --git a/net/sunrpc/auth_gss/gss_mech_switch.c b/net/sunrpc/auth_gss/gss_mech_switch.c
index bce9d52..6efbb0c 100644
--- a/net/sunrpc/auth_gss/gss_mech_switch.c
+++ b/net/sunrpc/auth_gss/gss_mech_switch.c
@@ -117,7 +117,7 @@ gss_mech_register(struct gss_api_mech *gm)
 	return 0;
 }
 
-EXPORT_SYMBOL(gss_mech_register);
+EXPORT_SYMBOL_GPL(gss_mech_register);
 
 void
 gss_mech_unregister(struct gss_api_mech *gm)
@@ -129,7 +129,7 @@ gss_mech_unregister(struct gss_api_mech *gm)
 	gss_mech_free(gm);
 }
 
-EXPORT_SYMBOL(gss_mech_unregister);
+EXPORT_SYMBOL_GPL(gss_mech_unregister);
 
 struct gss_api_mech *
 gss_mech_get(struct gss_api_mech *gm)
@@ -138,7 +138,7 @@ gss_mech_get(struct gss_api_mech *gm)
 	return gm;
 }
 
-EXPORT_SYMBOL(gss_mech_get);
+EXPORT_SYMBOL_GPL(gss_mech_get);
 
 struct gss_api_mech *
 gss_mech_get_by_name(const char *name)
@@ -158,7 +158,7 @@ gss_mech_get_by_name(const char *name)
 
 }
 
-EXPORT_SYMBOL(gss_mech_get_by_name);
+EXPORT_SYMBOL_GPL(gss_mech_get_by_name);
 
 static inline int
 mech_supports_pseudoflavor(struct gss_api_mech *gm, u32 pseudoflavor)
@@ -191,7 +191,7 @@ gss_mech_get_by_pseudoflavor(u32 pseudoflavor)
 	return gm;
 }
 
-EXPORT_SYMBOL(gss_mech_get_by_pseudoflavor);
+EXPORT_SYMBOL_GPL(gss_mech_get_by_pseudoflavor);
 
 u32
 gss_svc_to_pseudoflavor(struct gss_api_mech *gm, u32 service)
@@ -205,7 +205,7 @@ gss_svc_to_pseudoflavor(struct gss_api_mech *gm, u32 service)
 	}
 	return RPC_AUTH_MAXFLAVOR; /* illegal value */
 }
-EXPORT_SYMBOL(gss_svc_to_pseudoflavor);
+EXPORT_SYMBOL_GPL(gss_svc_to_pseudoflavor);
 
 u32
 gss_pseudoflavor_to_service(struct gss_api_mech *gm, u32 pseudoflavor)
@@ -219,7 +219,7 @@ gss_pseudoflavor_to_service(struct gss_api_mech *gm, u32 pseudoflavor)
 	return 0;
 }
 
-EXPORT_SYMBOL(gss_pseudoflavor_to_service);
+EXPORT_SYMBOL_GPL(gss_pseudoflavor_to_service);
 
 char *
 gss_service_to_auth_domain_name(struct gss_api_mech *gm, u32 service)
@@ -233,7 +233,7 @@ gss_service_to_auth_domain_name(struct gss_api_mech *gm, u32 service)
 	return NULL;
 }
 
-EXPORT_SYMBOL(gss_service_to_auth_domain_name);
+EXPORT_SYMBOL_GPL(gss_service_to_auth_domain_name);
 
 void
 gss_mech_put(struct gss_api_mech * gm)
@@ -242,7 +242,7 @@ gss_mech_put(struct gss_api_mech * gm)
 		module_put(gm->gm_owner);
 }
 
-EXPORT_SYMBOL(gss_mech_put);
+EXPORT_SYMBOL_GPL(gss_mech_put);
 
 /* The mech could probably be determined from the token instead, but it's just
  * as easy for now to pass it in. */
diff --git a/net/sunrpc/auth_gss/svcauth_gss.c b/net/sunrpc/auth_gss/svcauth_gss.c
index 81ae3d6..12803da 100644
--- a/net/sunrpc/auth_gss/svcauth_gss.c
+++ b/net/sunrpc/auth_gss/svcauth_gss.c
@@ -746,7 +746,7 @@ u32 svcauth_gss_flavor(struct auth_domain *dom)
 	return gd->pseudoflavor;
 }
 
-EXPORT_SYMBOL(svcauth_gss_flavor);
+EXPORT_SYMBOL_GPL(svcauth_gss_flavor);
 
 int
 svcauth_gss_register_pseudoflavor(u32 pseudoflavor, char * name)
@@ -780,7 +780,7 @@ out:
 	return stat;
 }
 
-EXPORT_SYMBOL(svcauth_gss_register_pseudoflavor);
+EXPORT_SYMBOL_GPL(svcauth_gss_register_pseudoflavor);
 
 static inline int
 read_u32_from_xdr_buf(struct xdr_buf *buf, int base, u32 *obj)

