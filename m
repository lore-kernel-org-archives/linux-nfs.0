Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx12.netapp.com ([216.240.18.77]:17900 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757039Ab3HMVsA (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 13 Aug 2013 17:48:00 -0400
From: <andros@netapp.com>
To: <trond.myklebust@netapp.com>
CC: <linux-nfs@vger.kernel.org>, Andy Adamson <andros@netapp.com>
Subject: [PATCH Version 5 1/3] NFSv4 Remove unused LIPKEY and SPKM enums
Date: Tue, 13 Aug 2013 17:47:47 -0400
Message-ID: <1376430469-3773-2-git-send-email-andros@netapp.com>
In-Reply-To: <1376430469-3773-1-git-send-email-andros@netapp.com>
References: <1376430469-3773-1-git-send-email-andros@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

SPKM and LIPKEY are not supported.

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 fs/nfs/super.c                  | 34 ----------------------------------
 include/linux/sunrpc/msg_prot.h |  6 ------
 2 files changed, 40 deletions(-)

diff --git a/fs/nfs/super.c b/fs/nfs/super.c
index d26bd63..f4d3768 100644
--- a/fs/nfs/super.c
+++ b/fs/nfs/super.c
@@ -209,8 +209,6 @@ static const match_table_t nfs_xprt_protocol_tokens = {
 enum {
 	Opt_sec_none, Opt_sec_sys,
 	Opt_sec_krb5, Opt_sec_krb5i, Opt_sec_krb5p,
-	Opt_sec_lkey, Opt_sec_lkeyi, Opt_sec_lkeyp,
-	Opt_sec_spkm, Opt_sec_spkmi, Opt_sec_spkmp,
 
 	Opt_sec_err
 };
@@ -224,14 +222,6 @@ static const match_table_t nfs_secflavor_tokens = {
 	{ Opt_sec_krb5i, "krb5i" },
 	{ Opt_sec_krb5p, "krb5p" },
 
-	{ Opt_sec_lkey, "lkey" },
-	{ Opt_sec_lkeyi, "lkeyi" },
-	{ Opt_sec_lkeyp, "lkeyp" },
-
-	{ Opt_sec_spkm, "spkm3" },
-	{ Opt_sec_spkmi, "spkm3i" },
-	{ Opt_sec_spkmp, "spkm3p" },
-
 	{ Opt_sec_err, NULL }
 };
 
@@ -502,12 +492,6 @@ static const char *nfs_pseudoflavour_to_name(rpc_authflavor_t flavour)
 		{ RPC_AUTH_GSS_KRB5, "krb5" },
 		{ RPC_AUTH_GSS_KRB5I, "krb5i" },
 		{ RPC_AUTH_GSS_KRB5P, "krb5p" },
-		{ RPC_AUTH_GSS_LKEY, "lkey" },
-		{ RPC_AUTH_GSS_LKEYI, "lkeyi" },
-		{ RPC_AUTH_GSS_LKEYP, "lkeyp" },
-		{ RPC_AUTH_GSS_SPKM, "spkm" },
-		{ RPC_AUTH_GSS_SPKMI, "spkmi" },
-		{ RPC_AUTH_GSS_SPKMP, "spkmp" },
 		{ UINT_MAX, "unknown" }
 	};
 	int i;
@@ -1044,24 +1028,6 @@ static int nfs_parse_security_flavors(char *value,
 	case Opt_sec_krb5p:
 		mnt->auth_flavors[0] = RPC_AUTH_GSS_KRB5P;
 		break;
-	case Opt_sec_lkey:
-		mnt->auth_flavors[0] = RPC_AUTH_GSS_LKEY;
-		break;
-	case Opt_sec_lkeyi:
-		mnt->auth_flavors[0] = RPC_AUTH_GSS_LKEYI;
-		break;
-	case Opt_sec_lkeyp:
-		mnt->auth_flavors[0] = RPC_AUTH_GSS_LKEYP;
-		break;
-	case Opt_sec_spkm:
-		mnt->auth_flavors[0] = RPC_AUTH_GSS_SPKM;
-		break;
-	case Opt_sec_spkmi:
-		mnt->auth_flavors[0] = RPC_AUTH_GSS_SPKMI;
-		break;
-	case Opt_sec_spkmp:
-		mnt->auth_flavors[0] = RPC_AUTH_GSS_SPKMP;
-		break;
 	default:
 		return 0;
 	}
diff --git a/include/linux/sunrpc/msg_prot.h b/include/linux/sunrpc/msg_prot.h
index aadc6a0..1666da0 100644
--- a/include/linux/sunrpc/msg_prot.h
+++ b/include/linux/sunrpc/msg_prot.h
@@ -29,12 +29,6 @@ enum rpc_auth_flavors {
 	RPC_AUTH_GSS_KRB5  = 390003,
 	RPC_AUTH_GSS_KRB5I = 390004,
 	RPC_AUTH_GSS_KRB5P = 390005,
-	RPC_AUTH_GSS_LKEY  = 390006,
-	RPC_AUTH_GSS_LKEYI = 390007,
-	RPC_AUTH_GSS_LKEYP = 390008,
-	RPC_AUTH_GSS_SPKM  = 390009,
-	RPC_AUTH_GSS_SPKMI = 390010,
-	RPC_AUTH_GSS_SPKMP = 390011,
 };
 
 /* Maximum size (in bytes) of an rpc credential or verifier */
-- 
1.8.3.1

