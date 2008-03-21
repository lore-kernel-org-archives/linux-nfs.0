From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 1/4] NFS: Refactor logic for parsing NFS security flavor mount
	options
Date: Fri, 21 Mar 2008 17:50:35 -0400
Message-ID: <20080321215035.13546.12708.stgit@ingres.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: trond.myklebust@netapp.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from flpi102.sbcis.sbc.com ([207.115.20.71]:12785 "EHLO
	flpi102.prodigy.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755003AbYCUVuw (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 21 Mar 2008 17:50:52 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Clean up:  Before introducing support for parsing multiple security
flavors, refactor the NFS mount option parsing function to extract the
security flavor parsing logic into a separate function.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/nfs/super.c |  169 +++++++++++++++++++++++++++++++-------------------------
 1 files changed, 95 insertions(+), 74 deletions(-)

diff --git a/fs/nfs/super.c b/fs/nfs/super.c
index c99ca1f..fad43d1 100644
--- a/fs/nfs/super.c
+++ b/fs/nfs/super.c
@@ -741,6 +741,98 @@ static void nfs_parse_server_address(char *value,
 }
 
 /*
+ * Parse the value of the 'sec=' option.
+ *
+ * The flags setting is for v2/v3.  The flavor_len
+ * setting is for v4.  v2/v3 also need to know the
+ * difference between NULL and UNIX.
+ */
+static int nfs_parse_security_flavors(char *string,
+				      struct nfs_parsed_mount_data *mnt)
+{
+	int token;
+	substring_t args[MAX_OPT_ARGS];
+
+	if (string == NULL)
+		goto out_nomem;
+
+	dfprintk(MOUNT, "NFS: parsing sec=%s option\n", string);
+
+	token = match_token(string, nfs_secflavor_tokens, args);
+	kfree(string);
+
+	switch (token) {
+	case Opt_sec_none:
+		mnt->flags &= ~NFS_MOUNT_SECFLAVOUR;
+		mnt->auth_flavor_len = 0;
+		mnt->auth_flavors[0] = RPC_AUTH_NULL;
+		break;
+	case Opt_sec_sys:
+		mnt->flags &= ~NFS_MOUNT_SECFLAVOUR;
+		mnt->auth_flavor_len = 0;
+		mnt->auth_flavors[0] = RPC_AUTH_UNIX;
+		break;
+	case Opt_sec_krb5:
+		mnt->flags |= NFS_MOUNT_SECFLAVOUR;
+		mnt->auth_flavor_len = 1;
+		mnt->auth_flavors[0] = RPC_AUTH_GSS_KRB5;
+		break;
+	case Opt_sec_krb5i:
+		mnt->flags |= NFS_MOUNT_SECFLAVOUR;
+		mnt->auth_flavor_len = 1;
+		mnt->auth_flavors[0] = RPC_AUTH_GSS_KRB5I;
+		break;
+	case Opt_sec_krb5p:
+		mnt->flags |= NFS_MOUNT_SECFLAVOUR;
+		mnt->auth_flavor_len = 1;
+		mnt->auth_flavors[0] = RPC_AUTH_GSS_KRB5P;
+		break;
+	case Opt_sec_lkey:
+		mnt->flags |= NFS_MOUNT_SECFLAVOUR;
+		mnt->auth_flavor_len = 1;
+		mnt->auth_flavors[0] = RPC_AUTH_GSS_LKEY;
+		break;
+	case Opt_sec_lkeyi:
+		mnt->flags |= NFS_MOUNT_SECFLAVOUR;
+		mnt->auth_flavor_len = 1;
+		mnt->auth_flavors[0] = RPC_AUTH_GSS_LKEYI;
+		break;
+	case Opt_sec_lkeyp:
+		mnt->flags |= NFS_MOUNT_SECFLAVOUR;
+		mnt->auth_flavor_len = 1;
+		mnt->auth_flavors[0] = RPC_AUTH_GSS_LKEYP;
+		break;
+	case Opt_sec_spkm:
+		mnt->flags |= NFS_MOUNT_SECFLAVOUR;
+		mnt->auth_flavor_len = 1;
+		mnt->auth_flavors[0] = RPC_AUTH_GSS_SPKM;
+		break;
+	case Opt_sec_spkmi:
+		mnt->flags |= NFS_MOUNT_SECFLAVOUR;
+		mnt->auth_flavor_len = 1;
+		mnt->auth_flavors[0] = RPC_AUTH_GSS_SPKMI;
+		break;
+	case Opt_sec_spkmp:
+		mnt->flags |= NFS_MOUNT_SECFLAVOUR;
+		mnt->auth_flavor_len = 1;
+		mnt->auth_flavors[0] = RPC_AUTH_GSS_SPKMP;
+		break;
+	default:
+		goto out_unrec_sec;
+	}
+
+	return 1;
+
+out_nomem:
+	printk(KERN_INFO "NFS: not enough memory to parse sec= option\n");
+	return 0;
+
+out_unrec_sec:
+	printk(KERN_INFO "NFS: unrecognized security flavor\n");
+	return 0;
+}
+
+/*
  * Error-check and convert a string of mount options from user space into
  * a data structure
  */
@@ -947,76 +1039,9 @@ static int nfs_parse_mount_options(char *raw,
 			break;
 
 		case Opt_sec:
-			string = match_strdup(args);
-			if (string == NULL)
-				goto out_nomem;
-			token = match_token(string, nfs_secflavor_tokens, args);
-			kfree(string);
-
-			/*
-			 * The flags setting is for v2/v3.  The flavor_len
-			 * setting is for v4.  v2/v3 also need to know the
-			 * difference between NULL and UNIX.
-			 */
-			switch (token) {
-			case Opt_sec_none:
-				mnt->flags &= ~NFS_MOUNT_SECFLAVOUR;
-				mnt->auth_flavor_len = 0;
-				mnt->auth_flavors[0] = RPC_AUTH_NULL;
-				break;
-			case Opt_sec_sys:
-				mnt->flags &= ~NFS_MOUNT_SECFLAVOUR;
-				mnt->auth_flavor_len = 0;
-				mnt->auth_flavors[0] = RPC_AUTH_UNIX;
-				break;
-			case Opt_sec_krb5:
-				mnt->flags |= NFS_MOUNT_SECFLAVOUR;
-				mnt->auth_flavor_len = 1;
-				mnt->auth_flavors[0] = RPC_AUTH_GSS_KRB5;
-				break;
-			case Opt_sec_krb5i:
-				mnt->flags |= NFS_MOUNT_SECFLAVOUR;
-				mnt->auth_flavor_len = 1;
-				mnt->auth_flavors[0] = RPC_AUTH_GSS_KRB5I;
-				break;
-			case Opt_sec_krb5p:
-				mnt->flags |= NFS_MOUNT_SECFLAVOUR;
-				mnt->auth_flavor_len = 1;
-				mnt->auth_flavors[0] = RPC_AUTH_GSS_KRB5P;
-				break;
-			case Opt_sec_lkey:
-				mnt->flags |= NFS_MOUNT_SECFLAVOUR;
-				mnt->auth_flavor_len = 1;
-				mnt->auth_flavors[0] = RPC_AUTH_GSS_LKEY;
-				break;
-			case Opt_sec_lkeyi:
-				mnt->flags |= NFS_MOUNT_SECFLAVOUR;
-				mnt->auth_flavor_len = 1;
-				mnt->auth_flavors[0] = RPC_AUTH_GSS_LKEYI;
-				break;
-			case Opt_sec_lkeyp:
-				mnt->flags |= NFS_MOUNT_SECFLAVOUR;
-				mnt->auth_flavor_len = 1;
-				mnt->auth_flavors[0] = RPC_AUTH_GSS_LKEYP;
-				break;
-			case Opt_sec_spkm:
-				mnt->flags |= NFS_MOUNT_SECFLAVOUR;
-				mnt->auth_flavor_len = 1;
-				mnt->auth_flavors[0] = RPC_AUTH_GSS_SPKM;
-				break;
-			case Opt_sec_spkmi:
-				mnt->flags |= NFS_MOUNT_SECFLAVOUR;
-				mnt->auth_flavor_len = 1;
-				mnt->auth_flavors[0] = RPC_AUTH_GSS_SPKMI;
-				break;
-			case Opt_sec_spkmp:
-				mnt->flags |= NFS_MOUNT_SECFLAVOUR;
-				mnt->auth_flavor_len = 1;
-				mnt->auth_flavors[0] = RPC_AUTH_GSS_SPKMP;
-				break;
-			default:
-				goto out_unrec_sec;
-			}
+			if (!nfs_parse_security_flavors(match_strdup(args),
+							mnt))
+				return 0;
 			break;
 		case Opt_proto:
 			string = match_strdup(args);
@@ -1132,10 +1157,6 @@ out_unrec_xprt:
 	printk(KERN_INFO "NFS: unrecognized transport protocol\n");
 	return 0;
 
-out_unrec_sec:
-	printk(KERN_INFO "NFS: unrecognized security flavor\n");
-	return 0;
-
 out_unknown:
 	printk(KERN_INFO "NFS: unknown mount option: %s\n", p);
 	return 0;

