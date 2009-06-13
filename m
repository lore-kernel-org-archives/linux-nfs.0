From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 8/8] NFS: Invalid mount option values should always fail,
	even with "sloppy"
Date: Sat, 13 Jun 2009 19:26:38 -0400
Message-ID: <20090613232638.3225.61460.stgit@isabey.1015granger.net>
References: <20090613232149.3225.92143.stgit@isabey.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: trond.myklebust@fys.uio.no
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet12.oracle.com ([148.87.113.124]:62130 "EHLO
	rgminet12.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756482AbZFMX0p (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 13 Jun 2009 19:26:45 -0400
In-Reply-To: <20090613232149.3225.92143.stgit-r85ClMMopbrwdl/1UfZZQIVfYA8g3rJ/@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Ian Kent reports:

"I've noticed a couple of other regressions with the options vers
and proto option of mount.nfs(8).

The commands:

mount -t nfs -o vers=<invalid version> <server>:/<path> /<mountpoint>
mount -t nfs -o proto=<invalid proto> <server>:/<path> /<mountpoint>

both immediately fail.

But if the "-s" option is also used they both succeed with the
mount falling back to defaults (by the look of it).

In the past these failed even when the sloppy option was given, as
I think they should. I believe the sloppy option is meant to allow
the mount command to still function for mount options (for example
in shared autofs maps) that exist on other Unix implementations but
aren't present in the Linux mount.nfs(8). So, an invalid value
specified for a known mount option is different to an unknown mount
option and should fail appropriately."

See RH bugzilla 486266.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/nfs/super.c |  157 ++++++++++++++++++++++----------------------------------
 1 files changed, 61 insertions(+), 96 deletions(-)

diff --git a/fs/nfs/super.c b/fs/nfs/super.c
index 8b3b494..ff18f7d 100644
--- a/fs/nfs/super.c
+++ b/fs/nfs/super.c
@@ -942,11 +942,6 @@ static int nfs_parse_security_flavors(char *value,
 	return 1;
 }
 
-static void nfs_parse_invalid_value(const char *option)
-{
-	dfprintk(MOUNT, "NFS:   bad value specified for %s option\n", option);
-}
-
 /*
  * Error-check and convert a string of mount options from user space into
  * a data structure.  The whole mount string is processed; bad options are
@@ -957,7 +952,7 @@ static int nfs_parse_mount_options(char *raw,
 				   struct nfs_parsed_mount_data *mnt)
 {
 	char *p, *string, *secdata;
-	int rc, sloppy = 0, errors = 0;
+	int rc, sloppy = 0, invalid_option = 0;
 
 	if (!raw) {
 		dfprintk(MOUNT, "NFS: mount options string was NULL.\n");
@@ -1091,113 +1086,82 @@ static int nfs_parse_mount_options(char *raw,
 		 */
 		case Opt_port:
 			if (match_int(args, &option) ||
-			    option < 0 || option > USHORT_MAX) {
-				errors++;
-				nfs_parse_invalid_value("port");
-			} else
-				mnt->nfs_server.port = option;
+			    option < 0 || option > USHORT_MAX)
+				goto out_invalid_value;
+			mnt->nfs_server.port = option;
 			break;
 		case Opt_rsize:
-			if (match_int(args, &option) || option < 0) {
-				errors++;
-				nfs_parse_invalid_value("rsize");
-			} else
-				mnt->rsize = option;
+			if (match_int(args, &option) || option < 0)
+				goto out_invalid_value;
+			mnt->rsize = option;
 			break;
 		case Opt_wsize:
-			if (match_int(args, &option) || option < 0) {
-				errors++;
-				nfs_parse_invalid_value("wsize");
-			} else
-				mnt->wsize = option;
+			if (match_int(args, &option) || option < 0)
+				goto out_invalid_value;
+			mnt->wsize = option;
 			break;
 		case Opt_bsize:
-			if (match_int(args, &option) || option < 0) {
-				errors++;
-				nfs_parse_invalid_value("bsize");
-			} else
-				mnt->bsize = option;
+			if (match_int(args, &option) || option < 0)
+				goto out_invalid_value;
+			mnt->bsize = option;
 			break;
 		case Opt_timeo:
-			if (match_int(args, &option) || option <= 0) {
-				errors++;
-				nfs_parse_invalid_value("timeo");
-			} else
-				mnt->timeo = option;
+			if (match_int(args, &option) || option <= 0)
+				goto out_invalid_value;
+			mnt->timeo = option;
 			break;
 		case Opt_retrans:
-			if (match_int(args, &option) || option <= 0) {
-				errors++;
-				nfs_parse_invalid_value("retrans");
-			} else
-				mnt->retrans = option;
+			if (match_int(args, &option) || option <= 0)
+				goto out_invalid_value;
+			mnt->retrans = option;
 			break;
 		case Opt_acregmin:
-			if (match_int(args, &option) || option < 0) {
-				errors++;
-				nfs_parse_invalid_value("acregmin");
-			} else
-				mnt->acregmin = option;
+			if (match_int(args, &option) || option < 0)
+				goto out_invalid_value;
+			mnt->acregmin = option;
 			break;
 		case Opt_acregmax:
-			if (match_int(args, &option) || option < 0) {
-				errors++;
-				nfs_parse_invalid_value("acregmax");
-			} else
-				mnt->acregmax = option;
+			if (match_int(args, &option) || option < 0)
+				goto out_invalid_value;
+			mnt->acregmax = option;
 			break;
 		case Opt_acdirmin:
-			if (match_int(args, &option) || option < 0) {
-				errors++;
-				nfs_parse_invalid_value("acdirmin");
-			} else
-				mnt->acdirmin = option;
+			if (match_int(args, &option) || option < 0)
+				goto out_invalid_value;
+			mnt->acdirmin = option;
 			break;
 		case Opt_acdirmax:
-			if (match_int(args, &option) || option < 0) {
-				errors++;
-				nfs_parse_invalid_value("acdirmax");
-			} else
-				mnt->acdirmax = option;
+			if (match_int(args, &option) || option < 0)
+				goto out_invalid_value;
+			mnt->acdirmax = option;
 			break;
 		case Opt_actimeo:
-			if (match_int(args, &option) || option < 0) {
-				errors++;
-				nfs_parse_invalid_value("actimeo");
-			} else
-				mnt->acregmin = mnt->acregmax =
-				mnt->acdirmin = mnt->acdirmax = option;
+			if (match_int(args, &option) || option < 0)
+				goto out_invalid_value;
+			mnt->acregmin = mnt->acregmax =
+			mnt->acdirmin = mnt->acdirmax = option;
 			break;
 		case Opt_namelen:
-			if (match_int(args, &option) || option < 0) {
-				errors++;
-				nfs_parse_invalid_value("namlen");
-			} else
-				mnt->namlen = option;
+			if (match_int(args, &option) || option < 0)
+				goto out_invalid_value;
+			mnt->namlen = option;
 			break;
 		case Opt_mountport:
 			if (match_int(args, &option) ||
-			    option < 0 || option > USHORT_MAX) {
-				errors++;
-				nfs_parse_invalid_value("mountport");
-			} else
-				mnt->mount_server.port = option;
+			    option < 0 || option > USHORT_MAX)
+				goto out_invalid_value;
+			mnt->mount_server.port = option;
 			break;
 		case Opt_mountvers:
 			if (match_int(args, &option) ||
 			    option < NFS_MNT_VERSION ||
-			    option > NFS_MNT3_VERSION) {
-				errors++;
-				nfs_parse_invalid_value("mountvers");
-			} else
-				mnt->mount_server.version = option;
+			    option > NFS_MNT3_VERSION)
+				goto out_invalid_value;
+			mnt->mount_server.version = option;
 			break;
 		case Opt_nfsvers:
-			if (match_int(args, &option)) {
-				errors++;
-				nfs_parse_invalid_value("nfsvers");
-				break;
-			}
+			if (match_int(args, &option))
+				goto out_invalid_value;
 			switch (option) {
 			case NFS2_VERSION:
 				mnt->flags &= ~NFS_MOUNT_VER3;
@@ -1206,8 +1170,7 @@ static int nfs_parse_mount_options(char *raw,
 				mnt->flags |= NFS_MOUNT_VER3;
 				break;
 			default:
-				errors++;
-				nfs_parse_invalid_value("nfsvers");
+				goto out_invalid_value;
 			}
 			break;
 
@@ -1221,9 +1184,9 @@ static int nfs_parse_mount_options(char *raw,
 			rc = nfs_parse_security_flavors(string, mnt);
 			kfree(string);
 			if (!rc) {
-				errors++;
 				dfprintk(MOUNT, "NFS:   unrecognized "
 						"security flavor\n");
+				return 0;
 			}
 			break;
 		case Opt_proto:
@@ -1237,23 +1200,25 @@ static int nfs_parse_mount_options(char *raw,
 			case Opt_xprt_udp:
 				mnt->flags &= ~NFS_MOUNT_TCP;
 				mnt->nfs_server.protocol = XPRT_TRANSPORT_UDP;
+				kfree(string);
 				break;
 			case Opt_xprt_tcp:
 				mnt->flags |= NFS_MOUNT_TCP;
 				mnt->nfs_server.protocol = XPRT_TRANSPORT_TCP;
+				kfree(string);
 				break;
 			case Opt_xprt_rdma:
 				/* vector side protocols to TCP */
 				mnt->flags |= NFS_MOUNT_TCP;
 				mnt->nfs_server.protocol = XPRT_TRANSPORT_RDMA;
 				xprt_load_transport(string);
+				kfree(string);
 				break;
 			default:
-				errors++;
 				dfprintk(MOUNT, "NFS:   unrecognized "
 						"transport protocol\n");
+				return 0;
 			}
-			kfree(string);
 			break;
 		case Opt_mountproto:
 			string = match_strdup(args);
@@ -1272,9 +1237,9 @@ static int nfs_parse_mount_options(char *raw,
 				break;
 			case Opt_xprt_rdma: /* not used for side protocols */
 			default:
-				errors++;
 				dfprintk(MOUNT, "NFS:   unrecognized "
 						"transport protocol\n");
+				return 0;
 			}
 			break;
 		case Opt_addr:
@@ -1330,9 +1295,9 @@ static int nfs_parse_mount_options(char *raw,
 					mnt->flags |= NFS_MOUNT_LOOKUP_CACHE_NONEG|NFS_MOUNT_LOOKUP_CACHE_NONE;
 					break;
 				default:
-					errors++;
 					dfprintk(MOUNT, "NFS:   invalid "
 							"lookupcache argument\n");
+					return 0;
 			};
 			break;
 
@@ -1350,20 +1315,20 @@ static int nfs_parse_mount_options(char *raw,
 			break;
 
 		default:
-			errors++;
+			invalid_option = 1;
 			dfprintk(MOUNT, "NFS:   unrecognized mount option "
 					"'%s'\n", p);
 		}
 	}
 
-	if (errors > 0) {
-		dfprintk(MOUNT, "NFS: parsing encountered %d error%s\n",
-				errors, (errors == 1 ? "" : "s"));
-		if (!sloppy)
-			return 0;
-	}
+	if (!sloppy && invalid_option)
+		return 0;
+
 	return 1;
 
+out_invalid_value:
+	printk(KERN_INFO "NFS: bad mount option value specified: %s \n", p);
+	return 0;
 out_nomem:
 	printk(KERN_INFO "NFS: not enough memory to parse option\n");
 	return 0;

