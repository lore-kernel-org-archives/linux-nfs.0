Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ie0-f175.google.com ([209.85.223.175]:49383 "EHLO
	mail-ie0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751439Ab3CPTzU (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 16 Mar 2013 15:55:20 -0400
Received: by mail-ie0-f175.google.com with SMTP id c12so5572541ieb.20
        for <linux-nfs@vger.kernel.org>; Sat, 16 Mar 2013 12:55:20 -0700 (PDT)
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH v1 08/15] SUNRPC: Make gss_mech_get() static
To: trond.myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org, Chuck Lever <chuck.lever@oracle.com>
Date: Sat, 16 Mar 2013 15:55:19 -0400
Message-ID: <20130316195518.27329.80288.stgit@seurat.1015granger.net>
In-Reply-To: <20130316195044.27329.11666.stgit@seurat.1015granger.net>
References: <20130316195044.27329.11666.stgit@seurat.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

gss_mech_get() is no longer used outside of gss_mech_switch.c.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 include/linux/sunrpc/gss_api.h        |    3 ---
 net/sunrpc/auth_gss/gss_mech_switch.c |    5 +----
 2 files changed, 1 insertions(+), 7 deletions(-)

diff --git a/include/linux/sunrpc/gss_api.h b/include/linux/sunrpc/gss_api.h
index fca2338..f32b7a4 100644
--- a/include/linux/sunrpc/gss_api.h
+++ b/include/linux/sunrpc/gss_api.h
@@ -145,9 +145,6 @@ struct gss_api_mech *gss_mech_get_by_pseudoflavor(u32);
 /* Fill in an array with a list of supported pseudoflavors */
 int gss_mech_list_pseudoflavors(rpc_authflavor_t *, int);
 
-/* Just increments the mechanism's reference count and returns its input: */
-struct gss_api_mech * gss_mech_get(struct gss_api_mech *);
-
 /* For every successful gss_mech_get or gss_mech_get_by_* call there must be a
  * corresponding call to gss_mech_put. */
 void gss_mech_put(struct gss_api_mech *);
diff --git a/net/sunrpc/auth_gss/gss_mech_switch.c b/net/sunrpc/auth_gss/gss_mech_switch.c
index deaa7ae..8941652 100644
--- a/net/sunrpc/auth_gss/gss_mech_switch.c
+++ b/net/sunrpc/auth_gss/gss_mech_switch.c
@@ -132,15 +132,12 @@ gss_mech_unregister(struct gss_api_mech *gm)
 
 EXPORT_SYMBOL_GPL(gss_mech_unregister);
 
-struct gss_api_mech *
-gss_mech_get(struct gss_api_mech *gm)
+static struct gss_api_mech *gss_mech_get(struct gss_api_mech *gm)
 {
 	__module_get(gm->gm_owner);
 	return gm;
 }
 
-EXPORT_SYMBOL_GPL(gss_mech_get);
-
 static struct gss_api_mech *
 _gss_mech_get_by_name(const char *name)
 {

