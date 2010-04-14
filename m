From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 10/22] gss_krb5: Add upcall info indicating supported kerberos enctypes
Date: Wed, 14 Apr 2010 13:36:46 -0400
Message-ID: <1271266618-26016-11-git-send-email-Trond.Myklebust@netapp.com>
References: <1271266618-26016-1-git-send-email-Trond.Myklebust@netapp.com>
 <1271266618-26016-2-git-send-email-Trond.Myklebust@netapp.com>
 <1271266618-26016-3-git-send-email-Trond.Myklebust@netapp.com>
 <1271266618-26016-4-git-send-email-Trond.Myklebust@netapp.com>
 <1271266618-26016-5-git-send-email-Trond.Myklebust@netapp.com>
 <1271266618-26016-6-git-send-email-Trond.Myklebust@netapp.com>
 <1271266618-26016-7-git-send-email-Trond.Myklebust@netapp.com>
 <1271266618-26016-8-git-send-email-Trond.Myklebust@netapp.com>
 <1271266618-26016-9-git-send-email-Trond.Myklebust@netapp.com>
 <1271266618-26016-10-git-send-email-Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:48907 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756557Ab0DNRhU (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 14 Apr 2010 13:37:20 -0400
Received: from localhost.localdomain (pd07336a.hq.netapp.com [10.58.61.110] (may be forged))
	by smtp1.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id o3EHawK6021574
	for <linux-nfs@vger.kernel.org>; Wed, 14 Apr 2010 10:37:04 -0700 (PDT)
In-Reply-To: <1271266618-26016-10-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The text based upcall now indicates which Kerberos encryption types are
supported by the kernel rpcsecgss code.  This is used by gssd to
determine which encryption types it should attempt to negotiate
when creating a context with a server.

The server principal's database and keytab encryption types are
what limits what it should negotiate.  Therefore, its keytab
should be created with only the enctypes listed by this file.

Currently we support des-cbc-crc, des-cbc-md4 and des-cbc-md5

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 include/linux/sunrpc/gss_api.h      |    2 ++
 net/sunrpc/auth_gss/auth_gss.c      |    8 +++++++-
 net/sunrpc/auth_gss/gss_krb5_mech.c |    1 +
 3 files changed, 10 insertions(+), 1 deletions(-)

diff --git a/include/linux/sunrpc/gss_api.h b/include/linux/sunrpc/gss_api.h
index 03f3333..b22d7f1 100644
--- a/include/linux/sunrpc/gss_api.h
+++ b/include/linux/sunrpc/gss_api.h
@@ -80,6 +80,8 @@ struct gss_api_mech {
 	/* pseudoflavors supported by this mechanism: */
 	int			gm_pf_num;
 	struct pf_desc *	gm_pfs;
+	/* Should the following be a callback operation instead? */
+	const char		*gm_upcall_enctypes;
 };
 
 /* and must provide the following operations: */
diff --git a/net/sunrpc/auth_gss/auth_gss.c b/net/sunrpc/auth_gss/auth_gss.c
index d64a58b..6654c85 100644
--- a/net/sunrpc/auth_gss/auth_gss.c
+++ b/net/sunrpc/auth_gss/auth_gss.c
@@ -377,11 +377,12 @@ static void gss_encode_v0_msg(struct gss_upcall_msg *gss_msg)
 static void gss_encode_v1_msg(struct gss_upcall_msg *gss_msg,
 				struct rpc_clnt *clnt, int machine_cred)
 {
+	struct gss_api_mech *mech = gss_msg->auth->mech;
 	char *p = gss_msg->databuf;
 	int len = 0;
 
 	gss_msg->msg.len = sprintf(gss_msg->databuf, "mech=%s uid=%d ",
-				   gss_msg->auth->mech->gm_name,
+				   mech->gm_name,
 				   gss_msg->uid);
 	p += gss_msg->msg.len;
 	if (clnt->cl_principal) {
@@ -398,6 +399,11 @@ static void gss_encode_v1_msg(struct gss_upcall_msg *gss_msg,
 		p += len;
 		gss_msg->msg.len += len;
 	}
+	if (mech->gm_upcall_enctypes) {
+		len = sprintf(p, mech->gm_upcall_enctypes);
+		p += len;
+		gss_msg->msg.len += len;
+	}
 	len = sprintf(p, "\n");
 	gss_msg->msg.len += len;
 
diff --git a/net/sunrpc/auth_gss/gss_krb5_mech.c b/net/sunrpc/auth_gss/gss_krb5_mech.c
index 8b612e7..d96d824 100644
--- a/net/sunrpc/auth_gss/gss_krb5_mech.c
+++ b/net/sunrpc/auth_gss/gss_krb5_mech.c
@@ -552,6 +552,7 @@ static struct gss_api_mech gss_kerberos_mech = {
 	.gm_ops		= &gss_kerberos_ops,
 	.gm_pf_num	= ARRAY_SIZE(gss_kerberos_pfs),
 	.gm_pfs		= gss_kerberos_pfs,
+	.gm_upcall_enctypes = "enctypes=1,2,3 ",
 };
 
 static int __init init_kerberos_module(void)
-- 
1.6.6.1

