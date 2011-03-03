Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from citi.umich.edu ([141.212.112.111]:55878 "EHLO citi.umich.edu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754413Ab1CCA7P (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 2 Mar 2011 19:59:15 -0500
From: Kevin Coffman <kwc@citi.umich.edu>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: <linux-nfs@vger.kernel.org>, Kevin Coffman <kwc@citi.umich.edu>
Subject: [PATCH 1/2] gss:krb5 only include enctype numbers in gm_upcall_enctypes
Date: Wed,  2 Mar 2011 19:51:41 -0500
Message-Id: <1299113502-17179-2-git-send-email-kwc@citi.umich.edu>
In-Reply-To: <1299113502-17179-1-git-send-email-kwc@citi.umich.edu>
References: <1299113502-17179-1-git-send-email-kwc@citi.umich.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

Make the value in gm_upcall_enctypes just the enctype values.
This allows the values to be used more easily elsewhere.

Signed-off-by: Kevin Coffman <kwc@citi.umich.edu>
---
 net/sunrpc/auth_gss/auth_gss.c      |    2 +-
 net/sunrpc/auth_gss/gss_krb5_mech.c |    2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/sunrpc/auth_gss/auth_gss.c b/net/sunrpc/auth_gss/auth_gss.c
index 45dbf15..f3914d0 100644
--- a/net/sunrpc/auth_gss/auth_gss.c
+++ b/net/sunrpc/auth_gss/auth_gss.c
@@ -417,7 +417,7 @@ static void gss_encode_v1_msg(struct gss_upcall_msg *gss_msg,
 		gss_msg->msg.len += len;
 	}
 	if (mech->gm_upcall_enctypes) {
-		len = sprintf(p, mech->gm_upcall_enctypes);
+		len = sprintf(p, "enctypes=%s ", mech->gm_upcall_enctypes);
 		p += len;
 		gss_msg->msg.len += len;
 	}
diff --git a/net/sunrpc/auth_gss/gss_krb5_mech.c b/net/sunrpc/auth_gss/gss_krb5_mech.c
index f375dec..9022f0a 100644
--- a/net/sunrpc/auth_gss/gss_krb5_mech.c
+++ b/net/sunrpc/auth_gss/gss_krb5_mech.c
@@ -750,7 +750,7 @@ static struct gss_api_mech gss_kerberos_mech = {
 	.gm_ops		= &gss_kerberos_ops,
 	.gm_pf_num	= ARRAY_SIZE(gss_kerberos_pfs),
 	.gm_pfs		= gss_kerberos_pfs,
-	.gm_upcall_enctypes = "enctypes=18,17,16,23,3,1,2 ",
+	.gm_upcall_enctypes = "18,17,16,23,3,1,2",
 };
 
 static int __init init_kerberos_module(void)
-- 
1.7.3.4

