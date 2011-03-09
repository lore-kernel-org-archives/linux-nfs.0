Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.parallels.com ([64.131.90.16]:57263 "EHLO mx2.parallels.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752050Ab1CIWCr (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 9 Mar 2011 17:02:47 -0500
Message-ID: <4D77F8FD.5060203@parallels.com>
Date: Wed, 9 Mar 2011 16:02:37 -0600
From: Rob Landley <rlandley@parallels.com>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: [PATCH] Cleanup: Factor out some cut-and-paste code.
Content-Type: text/plain; charset="ISO-8859-1"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

From: Rob Landley <rlandley@parallels.com>

Factor out some cut-and-paste code in options parsing.
Saves about 800 bytes on x86-64.

Signed-off-by: Rob Landley <rlandley@parallels.com>
---

  add/remove: 2/0 grow/shrink: 1/2 up/down: 115/-956 (-841)
  function                                     old     new   delta
  nfs_get_option_ul                              -      69     +69
  nfs_get_option_str                             -      45     +45
  nfs_kill_super                                33      34      +1
  nfs_alloc_parsed_mount_data                  107     106      -1
  nfs_parse_mount_options                     3608    2653    -955

 fs/nfs/super.c |  155 +++++++++++++----------------------------------
 1 file changed, 44 insertions(+), 111 deletions(-)

diff --git a/fs/nfs/super.c b/fs/nfs/super.c
index b68c860..d103034 100644
--- a/fs/nfs/super.c
+++ b/fs/nfs/super.c
@@ -979,6 +979,27 @@ static int nfs_parse_security_flavors(char *value,
 	return 1;
 }
 
+static int nfs_get_option_str(substring_t args[], char **option)
+{
+	kfree(*option);
+	*option = match_strdup(args);
+	return !option;
+}
+
+static int nfs_get_option_ul(substring_t args[], unsigned long *option)
+{
+	int rc;
+	char *string;
+
+	string = match_strdup(args);
+	if (string == NULL)
+		return -ENOMEM;
+	rc = strict_strtoul(string, 10, option);
+	kfree(string);
+
+	return rc;
+}
+
 /*
  * Error-check and convert a string of mount options from user space into
  * a data structure.  The whole mount string is processed; bad options are
@@ -1127,155 +1148,82 @@ static int nfs_parse_mount_options(char *raw,
 		 * options that take numeric values
 		 */
 		case Opt_port:
-			string = match_strdup(args);
-			if (string == NULL)
-				goto out_nomem;
-			rc = strict_strtoul(string, 10, &option);
-			kfree(string);
-			if (rc != 0 || option > USHRT_MAX)
+			if (nfs_get_option_ul(args, &option) ||
+			    option > USHRT_MAX)
 				goto out_invalid_value;
 			mnt->nfs_server.port = option;
 			break;
 		case Opt_rsize:
-			string = match_strdup(args);
-			if (string == NULL)
-				goto out_nomem;
-			rc = strict_strtoul(string, 10, &option);
-			kfree(string);
-			if (rc != 0)
+			if (nfs_get_option_ul(args, &option))
 				goto out_invalid_value;
 			mnt->rsize = option;
 			break;
 		case Opt_wsize:
-			string = match_strdup(args);
-			if (string == NULL)
-				goto out_nomem;
-			rc = strict_strtoul(string, 10, &option);
-			kfree(string);
-			if (rc != 0)
+			if (nfs_get_option_ul(args, &option))
 				goto out_invalid_value;
 			mnt->wsize = option;
 			break;
 		case Opt_bsize:
-			string = match_strdup(args);
-			if (string == NULL)
-				goto out_nomem;
-			rc = strict_strtoul(string, 10, &option);
-			kfree(string);
-			if (rc != 0)
+			if (nfs_get_option_ul(args, &option))
 				goto out_invalid_value;
 			mnt->bsize = option;
 			break;
 		case Opt_timeo:
-			string = match_strdup(args);
-			if (string == NULL)
-				goto out_nomem;
-			rc = strict_strtoul(string, 10, &option);
-			kfree(string);
-			if (rc != 0 || option == 0)
+			if (nfs_get_option_ul(args, &option) || option == 0)
 				goto out_invalid_value;
 			mnt->timeo = option;
 			break;
 		case Opt_retrans:
-			string = match_strdup(args);
-			if (string == NULL)
-				goto out_nomem;
-			rc = strict_strtoul(string, 10, &option);
-			kfree(string);
-			if (rc != 0 || option == 0)
+			if (nfs_get_option_ul(args, &option) || option == 0)
 				goto out_invalid_value;
 			mnt->retrans = option;
 			break;
 		case Opt_acregmin:
-			string = match_strdup(args);
-			if (string == NULL)
-				goto out_nomem;
-			rc = strict_strtoul(string, 10, &option);
-			kfree(string);
-			if (rc != 0)
+			if (nfs_get_option_ul(args, &option))
 				goto out_invalid_value;
 			mnt->acregmin = option;
 			break;
 		case Opt_acregmax:
-			string = match_strdup(args);
-			if (string == NULL)
-				goto out_nomem;
-			rc = strict_strtoul(string, 10, &option);
-			kfree(string);
-			if (rc != 0)
+			if (nfs_get_option_ul(args, &option))
 				goto out_invalid_value;
 			mnt->acregmax = option;
 			break;
 		case Opt_acdirmin:
-			string = match_strdup(args);
-			if (string == NULL)
-				goto out_nomem;
-			rc = strict_strtoul(string, 10, &option);
-			kfree(string);
-			if (rc != 0)
+			if (nfs_get_option_ul(args, &option))
 				goto out_invalid_value;
 			mnt->acdirmin = option;
 			break;
 		case Opt_acdirmax:
-			string = match_strdup(args);
-			if (string == NULL)
-				goto out_nomem;
-			rc = strict_strtoul(string, 10, &option);
-			kfree(string);
-			if (rc != 0)
+			if (nfs_get_option_ul(args, &option))
 				goto out_invalid_value;
 			mnt->acdirmax = option;
 			break;
 		case Opt_actimeo:
-			string = match_strdup(args);
-			if (string == NULL)
-				goto out_nomem;
-			rc = strict_strtoul(string, 10, &option);
-			kfree(string);
-			if (rc != 0)
+			if (nfs_get_option_ul(args, &option))
 				goto out_invalid_value;
 			mnt->acregmin = mnt->acregmax =
 			mnt->acdirmin = mnt->acdirmax = option;
 			break;
 		case Opt_namelen:
-			string = match_strdup(args);
-			if (string == NULL)
-				goto out_nomem;
-			rc = strict_strtoul(string, 10, &option);
-			kfree(string);
-			if (rc != 0)
+			if (nfs_get_option_ul(args, &option))
 				goto out_invalid_value;
 			mnt->namlen = option;
 			break;
 		case Opt_mountport:
-			string = match_strdup(args);
-			if (string == NULL)
-				goto out_nomem;
-			rc = strict_strtoul(string, 10, &option);
-			kfree(string);
-			if (rc != 0 || option > USHRT_MAX)
+			if (nfs_get_option_ul(args, &option) ||
+			    option > USHRT_MAX)
 				goto out_invalid_value;
 			mnt->mount_server.port = option;
 			break;
 		case Opt_mountvers:
-			string = match_strdup(args);
-			if (string == NULL)
-				goto out_nomem;
-			rc = strict_strtoul(string, 10, &option);
-			kfree(string);
-			if (rc != 0 ||
+			if (nfs_get_option_ul(args, &option) ||
 			    option < NFS_MNT_VERSION ||
 			    option > NFS_MNT3_VERSION)
 				goto out_invalid_value;
 			mnt->mount_server.version = option;
 			break;
 		case Opt_nfsvers:
-			string = match_strdup(args);
-			if (string == NULL)
-				goto out_nomem;
-			rc = strict_strtoul(string, 10, &option);
-			kfree(string);
-			if (rc != 0)
+			if (nfs_get_option_ul(args, &option))
 				goto out_invalid_value;
 			switch (option) {
 			case NFS2_VERSION:
@@ -1295,12 +1243,7 @@ static int nfs_parse_mount_options(char *raw,
 			}
 			break;
 		case Opt_minorversion:
-			string = match_strdup(args);
-			if (string == NULL)
-				goto out_nomem;
-			rc = strict_strtoul(string, 10, &option);
-			kfree(string);
-			if (rc != 0)
+			if (nfs_get_option_ul(args, &option))
 				goto out_invalid_value;
 			if (option > NFS4_MAX_MINOR_VERSION)
 				goto out_invalid_value;
@@ -1336,21 +1279,18 @@ static int nfs_parse_mount_options(char *raw,
 			case Opt_xprt_udp:
 				mnt->flags &= ~NFS_MOUNT_TCP;
 				mnt->nfs_server.protocol = XPRT_TRANSPORT_UDP;
-				kfree(string);
 				break;
 			case Opt_xprt_tcp6:
 				protofamily = AF_INET6;
 			case Opt_xprt_tcp:
 				mnt->flags |= NFS_MOUNT_TCP;
 				mnt->nfs_server.protocol = XPRT_TRANSPORT_TCP;
-				kfree(string);
 				break;
 			case Opt_xprt_rdma:
 				/* vector side protocols to TCP */
 				mnt->flags |= NFS_MOUNT_TCP;
 				mnt->nfs_server.protocol = XPRT_TRANSPORT_RDMA;
 				xprt_load_transport(string);
-				kfree(string);
 				break;
 			default:
 				dfprintk(MOUNT, "NFS:   unrecognized "
@@ -1358,6 +1298,7 @@ static int nfs_parse_mount_options(char *raw,
 				kfree(string);
 				return 0;
 			}
+			kfree(string);
 			break;
 		case Opt_mountproto:
 			string = match_strdup(args);
@@ -1400,18 +1341,13 @@ static int nfs_parse_mount_options(char *raw,
 				goto out_invalid_address;
 			break;
 		case Opt_clientaddr:
-			string = match_strdup(args);
-			if (string == NULL)
+			if (nfs_get_option_str(args, &mnt->client_address))
 				goto out_nomem;
-			kfree(mnt->client_address);
-			mnt->client_address = string;
 			break;
 		case Opt_mounthost:
-			string = match_strdup(args);
-			if (string == NULL)
+			if (nfs_get_option_str(args,
+					       &mnt->mount_server.hostname))
 				goto out_nomem;
-			kfree(mnt->mount_server.hostname);
-			mnt->mount_server.hostname = string;
 			break;
 		case Opt_mountaddr:
 			string = match_strdup(args);
@@ -1451,11 +1387,8 @@ static int nfs_parse_mount_options(char *raw,
 			};
 			break;
 		case Opt_fscache_uniq:
-			string = match_strdup(args);
-			if (string == NULL)
+			if (nfs_get_option_str(args, &mnt->fscache_uniq))
 				goto out_nomem;
-			kfree(mnt->fscache_uniq);
-			mnt->fscache_uniq = string;
 			mnt->options |= NFS_OPTION_FSCACHE;
 			break;
 		case Opt_local_lock:
