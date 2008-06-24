From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH] NFS: Allow either strict or sloppy mount option parsing
Date: Tue, 24 Jun 2008 19:28:02 -0400
Message-ID: <20080624232714.3175.64924.stgit@ellison.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: trond.myklebust@netapp.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from agminet01.oracle.com ([141.146.126.228]:53766 "EHLO
	agminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754658AbYFXX3K (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 24 Jun 2008 19:29:10 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The kernel's NFS client mount option parser currently doesn't allow
unrecognized or incorrect mount options.  This prevents misspellings or
incorrectly specified mount options from possibly causing silent data
corruption.

However, NFS mount options are not standardized, so different operating
systems can use differently spelled mount options to support similar
features, or can support mount options which no other operating system
supports.

"Sloppy" mount option parsing, which allows the parser to ignore any
option it doesn't recognize, is needed to support automounters that often
use maps that are shared between heterogenous operating systems.

The legacy mount command ignores the validity of the values of mount
options entirely, except for the "sec=" and "proto=" options.  If an
incorrect value is specified, the out-of-range value is passed to the
kernel; if a value is specified that contains non-numeric characters,
it appears as though the legacy mount command sets that option to zero
(probably incorrect behavior in general).

In any case, this sets a precedent which we will partially follow for
the kernel mount option parser:

	+ if "sloppy" is not set, the parser will be strict about both
	  unrecognized options (same as legacy) and invalid option
	  values (stricter than legacy)

	+ if "sloppy" is set, the parser will ignore unrecognized
	  options and invalid option values (same as legacy)

An "invalid" option value in this case means that either the type
(integer, short, or string) or sign (for integer values) of the specified
value is incorrect.

This patch does two things: it changes the NFS client's mount option
parsing loop so that it parses the whole string instead of failing at
the first unrecognized option or invalid option value.  An unrecognized
option or an invalid option value cause the option to be skipped.

Then, the patch adds a "sloppy" mount option that allows the parsing
to succeed anyway if there were any problems during parsing.  When
parsing a set of options is complete, if there are errors and "sloppy"
was specified, return success anyway.  Otherwise, only return success
if there are no errors.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

Note: this patch may depend on the clean-up patches in the "multiple security
flavor" series I just sent out, but I'm pretty sure it doesn't depend on the
final patch in that series.

 fs/nfs/super.c |  203 +++++++++++++++++++++++++++++++++++---------------------
 1 files changed, 128 insertions(+), 75 deletions(-)


diff --git a/fs/nfs/super.c b/fs/nfs/super.c
index 22bdc50..ba1a7c5 100644
--- a/fs/nfs/super.c
+++ b/fs/nfs/super.c
@@ -92,8 +92,8 @@ enum {
 	Opt_sec, Opt_proto, Opt_mountproto, Opt_mounthost,
 	Opt_addr, Opt_mountaddr, Opt_clientaddr,
 
-	/* Mount options that are ignored */
-	Opt_userspace, Opt_deprecated,
+	/* Special mount options */
+	Opt_userspace, Opt_deprecated, Opt_sloppy,
 
 	Opt_err
 };
@@ -103,6 +103,8 @@ static match_table_t nfs_mount_option_tokens = {
 	{ Opt_userspace, "fg" },
 	{ Opt_userspace, "retry=%s" },
 
+	{ Opt_sloppy, "sloppy" },
+
 	{ Opt_soft, "soft" },
 	{ Opt_hard, "hard" },
 	{ Opt_deprecated, "intr" },
@@ -941,15 +943,22 @@ static int nfs_parse_security_flavors(char *value,
 	return 1;
 }
 
+static void nfs_parse_invalid_value(const char *option)
+{
+	dfprintk(MOUNT, "NFS:   bad value specified for %s option\n", option);
+}
+
 /*
  * Error-check and convert a string of mount options from user space into
- * a data structure
+ * a data structure.  The whole mount string is processed; bad options are
+ * skipped as they are encountered.  If there were no errors, return 1;
+ * otherwise return 0 (zero).
  */
 static int nfs_parse_mount_options(char *raw,
 				   struct nfs_parsed_mount_data *mnt)
 {
 	char *p, *string, *secdata;
-	int rc;
+	int rc, sloppy = 0, errors = 0;
 
 	if (!raw) {
 		dfprintk(MOUNT, "NFS: mount options string was NULL.\n");
@@ -982,6 +991,10 @@ static int nfs_parse_mount_options(char *raw,
 
 		token = match_token(p, nfs_mount_option_tokens, args);
 		switch (token) {
+
+		/*
+		 * boolean options:  foo/nofoo
+		 */
 		case Opt_soft:
 			mnt->flags |= NFS_MOUNT_SOFT;
 			break;
@@ -1049,103 +1062,145 @@ static int nfs_parse_mount_options(char *raw,
 			mnt->flags |= NFS_MOUNT_UNSHARED;
 			break;
 
+		/*
+		 * options that take numeric values
+		 */
 		case Opt_port:
-			if (match_int(args, &option))
-				return 0;
-			if (option < 0 || option > 65535)
-				return 0;
-			mnt->nfs_server.port = option;
+			if (match_int(args, &option) ||
+			    option < 0 || option > USHORT_MAX) {
+				errors++;
+				nfs_parse_invalid_value("port");
+			} else
+				mnt->nfs_server.port = option;
 			break;
 		case Opt_rsize:
-			if (match_int(args, &mnt->rsize))
-				return 0;
+			if (match_int(args, &option) || option < 0) {
+				errors++;
+				nfs_parse_invalid_value("rsize");
+			} else
+				mnt->rsize = option;
 			break;
 		case Opt_wsize:
-			if (match_int(args, &mnt->wsize))
-				return 0;
+			if (match_int(args, &option) || option < 0) {
+				errors++;
+				nfs_parse_invalid_value("wsize");
+			} else
+				mnt->wsize = option;
 			break;
 		case Opt_bsize:
-			if (match_int(args, &option))
-				return 0;
-			if (option < 0)
-				return 0;
-			mnt->bsize = option;
+			if (match_int(args, &option) || option < 0) {
+				errors++;
+				nfs_parse_invalid_value("bsize");
+			} else
+				mnt->bsize = option;
 			break;
 		case Opt_timeo:
-			if (match_int(args, &mnt->timeo))
-				return 0;
+			if (match_int(args, &option) || option <= 0) {
+				errors++;
+				nfs_parse_invalid_value("timeo");
+			} else
+				mnt->timeo = option;
 			break;
 		case Opt_retrans:
-			if (match_int(args, &mnt->retrans))
-				return 0;
+			if (match_int(args, &option) || option <= 0) {
+				errors++;
+				nfs_parse_invalid_value("retrans");
+			} else
+				mnt->retrans = option;
 			break;
 		case Opt_acregmin:
-			if (match_int(args, &mnt->acregmin))
-				return 0;
+			if (match_int(args, &option) || option < 0) {
+				errors++;
+				nfs_parse_invalid_value("acregmin");
+			} else
+				mnt->acregmin = option;
 			break;
 		case Opt_acregmax:
-			if (match_int(args, &mnt->acregmax))
-				return 0;
+			if (match_int(args, &option) || option < 0) {
+				errors++;
+				nfs_parse_invalid_value("acregmax");
+			} else
+				mnt->acregmax = option;
 			break;
 		case Opt_acdirmin:
-			if (match_int(args, &mnt->acdirmin))
-				return 0;
+			if (match_int(args, &option) || option < 0) {
+				errors++;
+				nfs_parse_invalid_value("acdirmin");
+			} else
+				mnt->acdirmin = option;
 			break;
 		case Opt_acdirmax:
-			if (match_int(args, &mnt->acdirmax))
-				return 0;
+			if (match_int(args, &option) || option < 0) {
+				errors++;
+				nfs_parse_invalid_value("acdirmax");
+			} else
+				mnt->acdirmax = option;
 			break;
 		case Opt_actimeo:
-			if (match_int(args, &option))
-				return 0;
-			if (option < 0)
-				return 0;
-			mnt->acregmin =
-			mnt->acregmax =
-			mnt->acdirmin =
-			mnt->acdirmax = option;
+			if (match_int(args, &option) || option < 0) {
+				errors++;
+				nfs_parse_invalid_value("actimeo");
+			} else
+				mnt->acregmin = mnt->acregmax =
+				mnt->acdirmin = mnt->acdirmax = option;
 			break;
 		case Opt_namelen:
-			if (match_int(args, &mnt->namlen))
-				return 0;
+			if (match_int(args, &option) || option < 0) {
+				errors++;
+				nfs_parse_invalid_value("namlen");
+			} else
+				mnt->namlen = option;
 			break;
 		case Opt_mountport:
-			if (match_int(args, &option))
-				return 0;
-			if (option < 0 || option > 65535)
-				return 0;
-			mnt->mount_server.port = option;
+			if (match_int(args, &option) ||
+			    option < 0 || option > USHORT_MAX) {
+				errors++;
+				nfs_parse_invalid_value("mountport");
+			} else
+				mnt->mount_server.port = option;
 			break;
 		case Opt_mountvers:
-			if (match_int(args, &option))
-				return 0;
-			if (option < 0)
-				return 0;
-			mnt->mount_server.version = option;
+			if (match_int(args, &option) ||
+			    option < NFS_MNT_VERSION ||
+			    option > NFS_MNT3_VERSION) {
+				errors++;
+				nfs_parse_invalid_value("mountvers");
+			} else
+				mnt->mount_server.version = option;
 			break;
 		case Opt_nfsvers:
-			if (match_int(args, &option))
-				return 0;
+			if (match_int(args, &option)) {
+				errors++;
+				nfs_parse_invalid_value("nfsvers");
+				break;
+			}
 			switch (option) {
-			case 2:
+			case NFS2_VERSION:
 				mnt->flags &= ~NFS_MOUNT_VER3;
 				break;
-			case 3:
+			case NFS3_VERSION:
 				mnt->flags |= NFS_MOUNT_VER3;
 				break;
 			default:
-				goto out_unrec_vers;
+				errors++;
+				nfs_parse_invalid_value("nfsvers");
 			}
 			break;
 
+		/*
+		 * options that take text values
+		 */
 		case Opt_sec:
 			string = match_strdup(args);
 			if (string == NULL)
 				goto out_nomem;
 			rc = nfs_parse_security_flavors(string, mnt);
 			kfree(string);
-			if (!rc)
-				goto out_unrec_sec;
+			if (!rc) {
+				errors++;
+				dfprintk(MOUNT, "NFS:   unrecognized "
+						"security flavor\n");
+			}
 			break;
 		case Opt_proto:
 			string = match_strdup(args);
@@ -1170,7 +1225,9 @@ static int nfs_parse_mount_options(char *raw,
 				mnt->nfs_server.protocol = XPRT_TRANSPORT_RDMA;
 				break;
 			default:
-				goto out_unrec_xprt;
+				errors++;
+				dfprintk(MOUNT, "NFS:   unrecognized "
+						"transport protocol\n");
 			}
 			break;
 		case Opt_mountproto:
@@ -1190,7 +1247,9 @@ static int nfs_parse_mount_options(char *raw,
 				break;
 			case Opt_xprt_rdma: /* not used for side protocols */
 			default:
-				goto out_unrec_xprt;
+				errors++;
+				dfprintk(MOUNT, "NFS:   unrecognized "
+						"transport protocol\n");
 			}
 			break;
 		case Opt_addr:
@@ -1228,6 +1287,13 @@ static int nfs_parse_mount_options(char *raw,
 			kfree(string);
 			break;
 
+		/*
+		 * Special options
+		 */
+		case Opt_sloppy:
+			sloppy = 1;
+			dfprintk(MOUNT, "NFS:   relaxing parsing rules\n");
+			break;
 		case Opt_userspace:
 		case Opt_deprecated:
 			dfprintk(MOUNT, "NFS:   ignoring mount option "
@@ -1235,7 +1301,9 @@ static int nfs_parse_mount_options(char *raw,
 			break;
 
 		default:
-			goto out_unknown;
+			errors++;
+			dfprintk(MOUNT, "NFS:   unrecognized mount option "
+					"'%s'\n", p);
 		}
 	}
 
@@ -1248,21 +1316,6 @@ out_security_failure:
 	free_secdata(secdata);
 	printk(KERN_INFO "NFS: security options invalid: %d\n", rc);
 	return 0;
-out_unrec_vers:
-	printk(KERN_INFO "NFS: unrecognized NFS version number\n");
-	return 0;
-
-out_unrec_xprt:
-	printk(KERN_INFO "NFS: unrecognized transport protocol\n");
-	return 0;
-
-out_unrec_sec:
-	printk(KERN_INFO "NFS: unrecognized security flavor\n");
-	return 0;
-
-out_unknown:
-	printk(KERN_INFO "NFS: unknown mount option: %s\n", p);
-	return 0;
 }
 
 /*

