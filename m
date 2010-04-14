From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 22/22] gss_krb5: Advertise rc4-hmac enctype support in the rpcsec_gss/krb5 upcall
Date: Wed, 14 Apr 2010 13:36:58 -0400
Message-ID: <1271266618-26016-23-git-send-email-Trond.Myklebust@netapp.com>
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
 <1271266618-26016-11-git-send-email-Trond.Myklebust@netapp.com>
 <1271266618-26016-12-git-send-email-Trond.Myklebust@netapp.com>
 <1271266618-26016-13-git-send-email-Trond.Myklebust@netapp.com>
 <1271266618-26016-14-git-send-email-Trond.Myklebust@netapp.com>
 <1271266618-26016-15-git-send-email-Trond.Myklebust@netapp.com>
 <1271266618-26016-16-git-send-email-Trond.Myklebust@netapp.com>
 <1271266618-26016-17-git-send-email-Trond.Myklebust@netapp.com>
 <1271266618-26016-18-git-send-email-Trond.Myklebust@netapp.com>
 <1271266618-26016-19-git-send-email-Trond.Myklebust@netapp.com>
 <1271266618-26016-20-git-send-email-Trond.Myklebust@netapp.com>
 <1271266618-26016-21-git-send-email-Trond.Myklebust@netapp.com>
 <1271266618-26016-22-git-send-email-Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:28110 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756580Ab0DNRhW (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 14 Apr 2010 13:37:22 -0400
Received: from localhost.localdomain (pd07336a.hq.netapp.com [10.58.61.110] (may be forged))
	by smtp1.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id o3EHawKI021574
	for <linux-nfs@vger.kernel.org>; Wed, 14 Apr 2010 10:37:11 -0700 (PDT)
In-Reply-To: <1271266618-26016-22-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Update the upcall info indicating which Kerberos enctypes
the kernel supports

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 net/sunrpc/auth_gss/gss_krb5_mech.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/sunrpc/auth_gss/gss_krb5_mech.c b/net/sunrpc/auth_gss/gss_krb5_mech.c
index 4187c6e..13bd8e8 100644
--- a/net/sunrpc/auth_gss/gss_krb5_mech.c
+++ b/net/sunrpc/auth_gss/gss_krb5_mech.c
@@ -742,7 +742,7 @@ static struct gss_api_mech gss_kerberos_mech = {
 	.gm_ops		= &gss_kerberos_ops,
 	.gm_pf_num	= ARRAY_SIZE(gss_kerberos_pfs),
 	.gm_pfs		= gss_kerberos_pfs,
-	.gm_upcall_enctypes = "enctypes=1,2,3,16,17,18 ",
+	.gm_upcall_enctypes = "enctypes=1,2,3,16,17,18,23 ",
 };
 
 static int __init init_kerberos_module(void)
-- 
1.6.6.1

