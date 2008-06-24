From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 1/4] NFS: Refactor logic for parsing NFS security flavor mount
	options
Date: Tue, 24 Jun 2008 16:33:38 -0400
Message-ID: <20080624203337.3366.97689.stgit@ellison.1015granger.net>
References: <20080624202913.3366.44867.stgit@ellison.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: trond.myklebust@netapp.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rgminet01.oracle.com ([148.87.113.118]:45113 "EHLO
	rgminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753557AbYFXUfs (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 24 Jun 2008 16:35:48 -0400
In-Reply-To: <20080624202913.3366.44867.stgit-ewv44WTpT0t9HhUboXbp9zCvJB+x5qRC@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Clean up: Refactor the NFS mount option parsing function to extract the
security flavor parsing logic into a separate function.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/nfs/super.c |  143 +++++++++++++++++++++++++++++++-------------------------
 1 files changed, 78 insertions(+), 65 deletions(-)


diff --git a/fs/nfs/super.c b/fs/nfs/super.c
index 1736268..712b85f 100644
--- a/fs/nfs/super.c
+++ b/fs/nfs/super.c
@@ -852,6 +852,82 @@ static void nfs_set_transport_defaults(struct nfs_parsed_mount_data *mnt)
 }
 
 /*
+ * Parse the value of the 'sec=' option.
+ *
+ * The flags setting is for v2/v3.  The flavor_len setting is for v4.
+ * v2/v3 also need to know the difference between NULL and UNIX.
+ */
+static int nfs_parse_security_flavors(char *value,
+				      struct nfs_parsed_mount_data *mnt)
+{
+	substring_t args[MAX_OPT_ARGS];
+
+	dfprintk(MOUNT, "NFS: parsing sec=%s option\n", value);
+
+	switch (match_token(value, nfs_secflavor_tokens, args)) {
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
+		return 0;
+	}
+
+	return 1;
+}
+
+/*
  * Error-check and convert a string of mount options from user space into
  * a data structure
  */
@@ -1052,73 +1128,10 @@ static int nfs_parse_mount_options(char *raw,
 			string = match_strdup(args);
 			if (string == NULL)
 				goto out_nomem;
-			token = match_token(string, nfs_secflavor_tokens, args);
+			rc = nfs_parse_security_flavors(string, mnt);
 			kfree(string);
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
+			if (!rc)
 				goto out_unrec_sec;
-			}
 			break;
 		case Opt_proto:
 			string = match_strdup(args);

