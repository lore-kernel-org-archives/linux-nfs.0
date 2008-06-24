From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 4/4] NFS: text-based mounts should support multiple security
	flavors
Date: Tue, 24 Jun 2008 16:34:02 -0400
Message-ID: <20080624203401.3366.83944.stgit@ellison.1015granger.net>
References: <20080624202913.3366.44867.stgit@ellison.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: trond.myklebust@netapp.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rgminet01.oracle.com ([148.87.113.118]:45116 "EHLO
	rgminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753627AbYFXUfs (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 24 Jun 2008 16:35:48 -0400
In-Reply-To: <20080624202913.3366.44867.stgit-ewv44WTpT0t9HhUboXbp9zCvJB+x5qRC@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Add support to the in-kernel NFS mount option parser for handling multiple
security flavors.

This does not implement support for multiple security flavors in the
underlying NFS or mountd clients.  When that support is added, simply crank
up the value of the MAX_SECURITY_FLAVORS macro, and that will enable the
mount option parser to grok colons and multiple security flavors.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/nfs/internal.h |    4 +-
 fs/nfs/super.c    |  126 ++++++++++++++++++++++++++++++++---------------------
 2 files changed, 79 insertions(+), 51 deletions(-)


diff --git a/fs/nfs/internal.h b/fs/nfs/internal.h
index 04ae867..6672c3a 100644
--- a/fs/nfs/internal.h
+++ b/fs/nfs/internal.h
@@ -27,6 +27,8 @@ struct nfs_clone_mount {
 	rpc_authflavor_t authflavor;
 };
 
+#define MAX_SECURITY_FLAVORS	(1)
+
 /*
  * In-kernel mount arguments
  */
@@ -39,7 +41,7 @@ struct nfs_parsed_mount_data {
 	int			namlen;
 	unsigned int		bsize;
 	unsigned int		auth_flavor_len;
-	rpc_authflavor_t	auth_flavors[1];
+	rpc_authflavor_t	auth_flavors[MAX_SECURITY_FLAVORS];
 	char			*client_address;
 
 	struct {
diff --git a/fs/nfs/super.c b/fs/nfs/super.c
index fa94851..22bdc50 100644
--- a/fs/nfs/super.c
+++ b/fs/nfs/super.c
@@ -853,63 +853,89 @@ static void nfs_set_transport_defaults(struct nfs_parsed_mount_data *mnt)
 
 /*
  * Parse the value of the 'sec=' option.
- *
- * The flavor_len setting is for v4 mounts.
  */
 static int nfs_parse_security_flavors(char *value,
 				      struct nfs_parsed_mount_data *mnt)
 {
-	substring_t args[MAX_OPT_ARGS];
+	char *p, *string;
+
+	mnt->auth_flavor_len = 0;
 
 	dfprintk(MOUNT, "NFS: parsing sec=%s option\n", value);
 
-	switch (match_token(value, nfs_secflavor_tokens, args)) {
-	case Opt_sec_none:
-		mnt->auth_flavor_len = 0;
-		mnt->auth_flavors[0] = RPC_AUTH_NULL;
-		break;
-	case Opt_sec_sys:
-		mnt->auth_flavor_len = 0;
-		mnt->auth_flavors[0] = RPC_AUTH_UNIX;
-		break;
-	case Opt_sec_krb5:
-		mnt->auth_flavor_len = 1;
-		mnt->auth_flavors[0] = RPC_AUTH_GSS_KRB5;
-		break;
-	case Opt_sec_krb5i:
-		mnt->auth_flavor_len = 1;
-		mnt->auth_flavors[0] = RPC_AUTH_GSS_KRB5I;
-		break;
-	case Opt_sec_krb5p:
-		mnt->auth_flavor_len = 1;
-		mnt->auth_flavors[0] = RPC_AUTH_GSS_KRB5P;
-		break;
-	case Opt_sec_lkey:
-		mnt->auth_flavor_len = 1;
-		mnt->auth_flavors[0] = RPC_AUTH_GSS_LKEY;
-		break;
-	case Opt_sec_lkeyi:
-		mnt->auth_flavor_len = 1;
-		mnt->auth_flavors[0] = RPC_AUTH_GSS_LKEYI;
-		break;
-	case Opt_sec_lkeyp:
-		mnt->auth_flavor_len = 1;
-		mnt->auth_flavors[0] = RPC_AUTH_GSS_LKEYP;
-		break;
-	case Opt_sec_spkm:
-		mnt->auth_flavor_len = 1;
-		mnt->auth_flavors[0] = RPC_AUTH_GSS_SPKM;
-		break;
-	case Opt_sec_spkmi:
-		mnt->auth_flavor_len = 1;
-		mnt->auth_flavors[0] = RPC_AUTH_GSS_SPKMI;
-		break;
-	case Opt_sec_spkmp:
-		mnt->auth_flavor_len = 1;
-		mnt->auth_flavors[0] = RPC_AUTH_GSS_SPKMP;
-		break;
-	default:
-		return 0;
+	while ((p = strsep(&value, ":")) != NULL) {
+		substring_t args[MAX_OPT_ARGS];
+		int token;
+
+		if (!*p)
+			continue;
+
+		if (mnt->auth_flavor_len >= MAX_SECURITY_FLAVORS) {
+			dfprintk(MOUNT, "NFS: sec= option specifies "
+					"too many security flavors\n");
+			return 0;
+		}
+
+		string = match_strdup(args);
+		if (string == NULL) {
+			dfprintk(MOUNT, "NFS: not enough memory "
+					"to parse sec= option\n");
+			return 0;
+		}
+
+		token = match_token(string, nfs_secflavor_tokens, args);
+		kfree(string);
+
+		switch (token) {
+		case Opt_sec_none:
+			mnt->auth_flavors[mnt->auth_flavor_len] =
+							RPC_AUTH_NULL;
+			break;
+		case Opt_sec_sys:
+			mnt->auth_flavors[mnt->auth_flavor_len] =
+							RPC_AUTH_UNIX;
+			break;
+		case Opt_sec_krb5:
+			mnt->auth_flavors[mnt->auth_flavor_len] =
+							RPC_AUTH_GSS_KRB5;
+			break;
+		case Opt_sec_krb5i:
+			mnt->auth_flavors[mnt->auth_flavor_len] =
+							RPC_AUTH_GSS_KRB5I;
+			break;
+		case Opt_sec_krb5p:
+			mnt->auth_flavors[mnt->auth_flavor_len] =
+							RPC_AUTH_GSS_KRB5P;
+			break;
+		case Opt_sec_lkey:
+			mnt->auth_flavors[mnt->auth_flavor_len] =
+							RPC_AUTH_GSS_LKEY;
+			break;
+		case Opt_sec_lkeyi:
+			mnt->auth_flavors[mnt->auth_flavor_len] =
+							RPC_AUTH_GSS_LKEYI;
+			break;
+		case Opt_sec_lkeyp:
+			mnt->auth_flavors[mnt->auth_flavor_len] =
+							RPC_AUTH_GSS_LKEYP;
+			break;
+		case Opt_sec_spkm:
+			mnt->auth_flavors[mnt->auth_flavor_len] =
+							RPC_AUTH_GSS_SPKM;
+			break;
+		case Opt_sec_spkmi:
+			mnt->auth_flavors[mnt->auth_flavor_len] =
+							RPC_AUTH_GSS_SPKMI;
+			break;
+		case Opt_sec_spkmp:
+			mnt->auth_flavors[mnt->auth_flavor_len] =
+							RPC_AUTH_GSS_SPKMP;
+			break;
+		default:
+			return 0;
+		}
+
+		mnt->auth_flavor_len++;
 	}
 
 	return 1;

