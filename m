From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 4/4] NFS: text-based mounts should support multiple security
	flavors
Date: Fri, 21 Mar 2008 17:50:57 -0400
Message-ID: <20080321215057.13546.38940.stgit@ingres.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: trond.myklebust@netapp.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from flpi102.sbcis.sbc.com ([207.115.20.71]:13037 "EHLO
	flpi102.prodigy.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753311AbYCUVvK (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 21 Mar 2008 17:51:10 -0400
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

 fs/nfs/internal.h |    4 +
 fs/nfs/super.c    |  149 +++++++++++++++++++++++++++++++----------------------
 2 files changed, 90 insertions(+), 63 deletions(-)

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
index 0869cf2..e99e808 100644
--- a/fs/nfs/super.c
+++ b/fs/nfs/super.c
@@ -742,81 +742,106 @@ static void nfs_parse_server_address(char *value,
 
 /*
  * Parse the value of the 'sec=' option.
- *
- * The flavor_len setting is for v4 mounts.
  */
-static int nfs_parse_security_flavors(char *string,
+static int nfs_parse_security_flavors(char *value,
 				      struct nfs_parsed_mount_data *mnt)
 {
-	int token;
-	substring_t args[MAX_OPT_ARGS];
+	int result = 1;
+	char *p, *string;
 
-	if (string == NULL)
-		goto out_nomem;
+	mnt->auth_flavor_len = 0;
 
-	dfprintk(MOUNT, "NFS: parsing sec=%s option\n", string);
+	dfprintk(MOUNT, "NFS: parsing sec=%s option\n", value);
 
-	token = match_token(string, nfs_secflavor_tokens, args);
-	kfree(string);
+	while ((p = strsep(&value, ":")) != NULL) {
+		substring_t args[MAX_OPT_ARGS];
+		int token;
 
-	switch (token) {
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
-		goto out_unrec_sec;
+		if (!*p)
+			continue;
+
+		if (mnt->auth_flavor_len >= MAX_SECURITY_FLAVORS)
+			goto out_inval_auth;
+
+		string = match_strdup(args);
+		if (string == NULL)
+			goto out_nomem;
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
+			goto out_unrec_sec;
+		}
+
+		mnt->auth_flavor_len++;
 	}
 
-	return 1;
+out:
+	kfree(value);
+	return result;
 
 out_nomem:
-	printk(KERN_INFO "NFS: not enough memory to parse sec= option\n");
-	return 0;
+	printk(KERN_INFO
+		"NFS: not enough memory to parse sec= option\n");
+	result = 0;
+	goto out;
 
 out_unrec_sec:
-	printk(KERN_INFO "NFS: unrecognized security flavor\n");
-	return 0;
+	printk(KERN_INFO
+		"NFS: sec= option specifies an unrecognized security flavor\n");
+	result = 0;
+	goto out;
+
+out_inval_auth:
+	printk(KERN_INFO
+		"NFS: sec= option specifies too many security flavors\n");
+	result = 0;
+	goto out;
 }
 
 /*

