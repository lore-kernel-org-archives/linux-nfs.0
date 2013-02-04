Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ia0-f171.google.com ([209.85.210.171]:59849 "EHLO
	mail-ia0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754838Ab3BDUUH (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 4 Feb 2013 15:20:07 -0500
Received: by mail-ia0-f171.google.com with SMTP id z13so8617972iaz.30
        for <linux-nfs@vger.kernel.org>; Mon, 04 Feb 2013 12:20:07 -0800 (PST)
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH v3 8/9] SUNRPC: Make gss_mech_get() static
To: trond.myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org
Date: Mon, 04 Feb 2013 15:20:06 -0500
Message-ID: <20130204202006.1518.45889.stgit@seurat.1015granger.net>
In-Reply-To: <20130204201458.1518.12931.stgit@seurat.1015granger.net>
References: <20130204201458.1518.12931.stgit@seurat.1015granger.net>
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
index dc1e51b..59cfcff 100644
--- a/include/linux/sunrpc/gss_api.h
+++ b/include/linux/sunrpc/gss_api.h
@@ -144,9 +144,6 @@ struct gss_api_mech *gss_mech_get_by_pseudoflavor(u32);
 /* Fill in an array with a list of supported pseudoflavors */
 int gss_mech_list_pseudoflavors(rpc_authflavor_t *, int);
 
-/* Just increments the mechanism's reference count and returns its input: */
-struct gss_api_mech * gss_mech_get(struct gss_api_mech *);
-
 /* For every successful gss_mech_get or gss_mech_get_by_* call there must be a
  * corresponding call to gss_mech_put. */
 void gss_mech_put(struct gss_api_mech *);
diff --git a/net/sunrpc/auth_gss/gss_mech_switch.c b/net/sunrpc/auth_gss/gss_mech_switch.c
index a8d6ee5..b9f4f7b 100644
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
 struct gss_api_mech *
 _gss_mech_get_by_name(const char *name)
 {

