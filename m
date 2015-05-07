Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp.gentoo.org ([140.211.166.183]:60201 "EHLO smtp.gentoo.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753231AbbEGHTM (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 7 May 2015 03:19:12 -0400
From: Mike Frysinger <vapier@gentoo.org>
To: libtirpc-devel@lists.sourceforge.net
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH libtirpc] fix build w/gssapi disabled
Date: Thu,  7 May 2015 03:19:09 -0400
Message-Id: <1430983149-22199-1-git-send-email-vapier@gentoo.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Starting with commit d5259e751111cb108c784b044296185f543fc0be (Add header
definitions for rpc_gss_*() APIs), the gss headers were pulled in all the
time leading to build failures like so:
  CC       libtirpc_la-bindresvport.lo
In file included from ../tirpc/rpc/svc_auth.h:44:0,
                 from ../tirpc/rpc/rpc.h:68,
                 from bindresvport.c:46:
../tirpc/rpc/rpcsec_gss.h:38:27: fatal error: gssapi/gssapi.h: No such file or directory

Signed-off-by: Mike Frysinger <vapier@gentoo.org>
---
 tirpc/rpc/svc_auth.h | 6 ++++++
 1 file changed, 6 insertions(+)

diff --git a/tirpc/rpc/svc_auth.h b/tirpc/rpc/svc_auth.h
index 44b38bf..998b13a 100644
--- a/tirpc/rpc/svc_auth.h
+++ b/tirpc/rpc/svc_auth.h
@@ -41,6 +41,8 @@
 #ifndef _RPC_SVC_AUTH_H
 #define _RPC_SVC_AUTH_H
 
+#ifdef HAVE_RPCSEC_GSS
+
 #include <rpc/rpcsec_gss.h>
 
 typedef struct {
@@ -51,6 +53,8 @@ typedef struct {
 	u_int			seq_num;
 } svc_rpc_gss_parms_t;
 
+#endif
+
 /*
  * Interface to server-side authentication flavors.
  */
@@ -63,8 +67,10 @@ typedef struct SVCAUTH {
 		int     (*svc_ah_destroy)(struct SVCAUTH *);
 		} *svc_ah_ops;
 	caddr_t svc_ah_private;
+#ifdef HAVE_RPCSEC_GSS
 	svc_rpc_gss_parms_t svc_gss_params;
 	rpc_gss_rawcred_t raw_cred;
+#endif
 } SVCAUTH;
 
 #define SVCAUTH_WRAP(auth, xdrs, xfunc, xwhere) \
-- 
2.4.0

