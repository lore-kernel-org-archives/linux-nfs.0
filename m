From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 03/24] mount.nfs: Don't leak mount_opts
Date: Wed, 12 Sep 2007 12:14:45 -0400
Message-ID: <20070912161445.23491.7851.stgit@manray.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IVUs0-0004P9-Lv
	for nfs@lists.sourceforge.net; Wed, 12 Sep 2007 09:15:16 -0700
Received: from flpi101.sbcis.sbc.com ([207.115.20.70] helo=flpi101.prodigy.net)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IVUs2-0002Aa-SH
	for nfs@lists.sourceforge.net; Wed, 12 Sep 2007 09:15:21 -0700
Received: from manray.1015granger.net
	(adsl-76-241-169-38.dsl.sfldmi.sbcglobal.net [76.241.169.38])
	by flpi101.prodigy.net (8.13.8 out.dk.spool/8.13.8) with ESMTP id
	l8CGDteu026207
	for <nfs@lists.sourceforge.net>; Wed, 12 Sep 2007 09:13:55 -0700
Received: from manray.1015granger.net (manray.1015granger.net [127.0.0.1])
	by manray.1015granger.net (8.14.1/8.14.1) with ESMTP id l8CGEjK2023525
	for <nfs@lists.sourceforge.net>; Wed, 12 Sep 2007 12:14:45 -0400
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

Properly release mount_opts before exiting.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 utils/mount/mount.c |   19 +++++++++++++------
 1 files changed, 13 insertions(+), 6 deletions(-)

diff --git a/utils/mount/mount.c b/utils/mount/mount.c
index 2c1899a..8c2e91d 100644
--- a/utils/mount/mount.c
+++ b/utils/mount/mount.c
@@ -470,19 +470,19 @@ int main(int argc, char *argv[])
 				nfs_error(_("%s: Passing mount options via a"
 					" string is unsupported by this"
 					" kernel\n"), progname);
-				exit(EX_USAGE);
+				goto out_usage;
 			}
 			if (uid != 0) {
 				nfs_error(_("%s: -i option is restricted to 'root'\n"),
 					progname);
-				exit(EX_USAGE);
+				goto out_usage;
 			}
 			++string;
 			break;
 		case 'h':
 		default:
 			mount_usage();
-			exit(EX_USAGE);
+			goto out_usage;
 		}
 	}
 
@@ -491,7 +491,7 @@ int main(int argc, char *argv[])
 	 */
 	if (optind != argc - 2) {
 		mount_usage();
-		exit(EX_USAGE);
+		goto out_usage;
 	}
 
 	if (strcmp(progname, "mount.nfs4") == 0)
@@ -510,7 +510,7 @@ int main(int argc, char *argv[])
 		    strcmp(mc->m.mnt_type, fs_type) != 0) {
 			nfs_error(_("%s: permission denied: no match for %s "
 				"found in /etc/fstab"), progname, mount_point);
-			exit(EX_USAGE);
+			goto out_usage;
 		}
 
 		/*
@@ -525,7 +525,7 @@ int main(int argc, char *argv[])
 	mount_point = canonicalize(mount_point);
 	if (!mount_point) {
 		nfs_error(_("%s: no mount point provided"), progname);
-		exit(EX_USAGE);
+		goto out_usage;
 	}
 	if (mount_point[0] != '/') {
 		nfs_error(_("%s: unrecognized mount point %s"),
@@ -575,8 +575,15 @@ int main(int argc, char *argv[])
 	}
 
 out:
+	if (mount_opts)
+		free(mount_opts);
 	if (extra_opts)
 		free(extra_opts);
 	free(mount_point);
 	exit(mnt_err);
+
+out_usage:
+	if (mount_opts)
+		free(mount_opts);
+	exit(EX_USAGE);
 }


-------------------------------------------------------------------------
This SF.net email is sponsored by: Microsoft
Defy all challenges. Microsoft(R) Visual Studio 2005.
http://clk.atdmt.com/MRT/go/vse0120000070mrt/direct/01/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
