Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:20390 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751051AbaAQEMF (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 16 Jan 2014 23:12:05 -0500
Received: from int-mx12.intmail.prod.int.phx2.redhat.com (int-mx12.intmail.prod.int.phx2.redhat.com [10.5.11.25])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id s0H4C57v025384
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <linux-nfs@vger.kernel.org>; Thu, 16 Jan 2014 23:12:05 -0500
From: Simo Sorce <simo@redhat.com>
To: jlayton@redhat.com
Cc: steved@redhat.com, linux-nfs@vger.kernel.org
Subject: [PATCH 2/2] Remove unused parameter
Date: Thu, 16 Jan 2014 23:11:59 -0500
Message-Id: <1389931919-4801-3-git-send-email-simo@redhat.com>
In-Reply-To: <1389931919-4801-2-git-send-email-simo@redhat.com>
References: <20140116204949.1bea663a@corrin.poochiereds.net>
 <1389931919-4801-1-git-send-email-simo@redhat.com>
 <1389931919-4801-2-git-send-email-simo@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The name variable is always set to NULL now in all callers, so just
sto passing it around needlessly.

Signed-off-by: Simo Sorce <simo@redhat.com>
---
 utils/gssd/krb5_util.c |    8 ++++----
 1 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/utils/gssd/krb5_util.c b/utils/gssd/krb5_util.c
index cb64a52f3c9c6e6fdb90e007172ecd43f8e2f458..8d4b0e3593a0bd25e00d41c7d0e29322f5f55d6e 100644
--- a/utils/gssd/krb5_util.c
+++ b/utils/gssd/krb5_util.c
@@ -1359,12 +1359,12 @@ gssd_k5_get_default_realm(char **def_realm)
 }
 
 static int
-gssd_acquire_krb5_cred(gss_name_t name, gss_cred_id_t *gss_cred)
+gssd_acquire_krb5_cred(gss_cred_id_t *gss_cred)
 {
 	OM_uint32 maj_stat, min_stat;
 	gss_OID_set_desc desired_mechs = { 1, &krb5oid };
 
-	maj_stat = gss_acquire_cred(&min_stat, name, GSS_C_INDEFINITE,
+	maj_stat = gss_acquire_cred(&min_stat, GSS_C_NO_NAME, GSS_C_INDEFINITE,
 				    &desired_mechs, GSS_C_INITIATE,
 				    gss_cred, NULL, NULL);
 
@@ -1384,7 +1384,7 @@ gssd_acquire_user_cred(uid_t uid, gss_cred_id_t *gss_cred)
 	OM_uint32 maj_stat, min_stat;
 	int ret;
 
-	ret = gssd_acquire_krb5_cred(GSS_C_NO_NAME, gss_cred);
+	ret = gssd_acquire_krb5_cred(gss_cred);
 
 	/* force validation of cred to check for expiry */
 	if (ret == 0) {
@@ -1423,7 +1423,7 @@ limit_krb5_enctypes(struct rpc_gss_sec *sec)
 	int err = -1;
 
 	if (sec->cred == GSS_C_NO_CREDENTIAL) {
-		err = gssd_acquire_krb5_cred(GSS_C_NO_NAME, &sec->cred);
+		err = gssd_acquire_krb5_cred(&sec->cred);
 		if (err)
 			return -1;
 	}
-- 
1.7.1

