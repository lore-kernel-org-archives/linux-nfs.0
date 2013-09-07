Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx12.netapp.com ([216.240.18.77]:48967 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750758Ab3IGXSS (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sat, 7 Sep 2013 19:18:18 -0400
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: <linux-nfs@vger.kernel.org>
Subject: [PATCH 2/6] NFS: Clean up nfs_parse_security_flavors()
Date: Sat, 7 Sep 2013 19:18:09 -0400
Message-ID: <1378595893-60395-3-git-send-email-Trond.Myklebust@netapp.com>
In-Reply-To: <1378595893-60395-2-git-send-email-Trond.Myklebust@netapp.com>
References: <1378595893-60395-1-git-send-email-Trond.Myklebust@netapp.com>
 <1378595893-60395-2-git-send-email-Trond.Myklebust@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 fs/nfs/super.c | 25 +++++++++++++------------
 1 file changed, 13 insertions(+), 12 deletions(-)

diff --git a/fs/nfs/super.c b/fs/nfs/super.c
index 5d16ee3..b2dd6da 100644
--- a/fs/nfs/super.c
+++ b/fs/nfs/super.c
@@ -1032,49 +1032,50 @@ static int nfs_parse_security_flavors(char *value,
 				      struct nfs_parsed_mount_data *mnt)
 {
 	substring_t args[MAX_OPT_ARGS];
+	rpc_authflavor_t pseudoflavor;
 
 	dfprintk(MOUNT, "NFS: parsing sec=%s option\n", value);
 
 	switch (match_token(value, nfs_secflavor_tokens, args)) {
 	case Opt_sec_none:
-		mnt->auth_flavors[0] = RPC_AUTH_NULL;
+		pseudoflavor = RPC_AUTH_NULL;
 		break;
 	case Opt_sec_sys:
-		mnt->auth_flavors[0] = RPC_AUTH_UNIX;
+		pseudoflavor = RPC_AUTH_UNIX;
 		break;
 	case Opt_sec_krb5:
-		mnt->auth_flavors[0] = RPC_AUTH_GSS_KRB5;
+		pseudoflavor = RPC_AUTH_GSS_KRB5;
 		break;
 	case Opt_sec_krb5i:
-		mnt->auth_flavors[0] = RPC_AUTH_GSS_KRB5I;
+		pseudoflavor = RPC_AUTH_GSS_KRB5I;
 		break;
 	case Opt_sec_krb5p:
-		mnt->auth_flavors[0] = RPC_AUTH_GSS_KRB5P;
+		pseudoflavor = RPC_AUTH_GSS_KRB5P;
 		break;
 	case Opt_sec_lkey:
-		mnt->auth_flavors[0] = RPC_AUTH_GSS_LKEY;
+		pseudoflavor = RPC_AUTH_GSS_LKEY;
 		break;
 	case Opt_sec_lkeyi:
-		mnt->auth_flavors[0] = RPC_AUTH_GSS_LKEYI;
+		pseudoflavor = RPC_AUTH_GSS_LKEYI;
 		break;
 	case Opt_sec_lkeyp:
-		mnt->auth_flavors[0] = RPC_AUTH_GSS_LKEYP;
+		pseudoflavor = RPC_AUTH_GSS_LKEYP;
 		break;
 	case Opt_sec_spkm:
-		mnt->auth_flavors[0] = RPC_AUTH_GSS_SPKM;
+		pseudoflavor = RPC_AUTH_GSS_SPKM;
 		break;
 	case Opt_sec_spkmi:
-		mnt->auth_flavors[0] = RPC_AUTH_GSS_SPKMI;
+		pseudoflavor = RPC_AUTH_GSS_SPKMI;
 		break;
 	case Opt_sec_spkmp:
-		mnt->auth_flavors[0] = RPC_AUTH_GSS_SPKMP;
+		pseudoflavor = RPC_AUTH_GSS_SPKMP;
 		break;
 	default:
 		return 0;
 	}
 
 	mnt->flags |= NFS_MOUNT_SECFLAVOUR;
-	mnt->auth_flavor_len = 1;
+	nfs_set_auth_parsed_mount_data(mnt, pseudoflavor);
 	return 1;
 }
 
-- 
1.8.3.1

