From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 04/23] umount.nfs: some umount.nfs error return codes
	are	confusing
Date: Sat, 28 Jul 2007 17:49:28 -0400
Message-ID: <20070728214928.21871.38390.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: neilb@suse.de
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IEuAF-0007PR-8z
	for nfs@lists.sourceforge.net; Sat, 28 Jul 2007 14:49:31 -0700
Received: from flpi102.sbcis.sbc.com ([207.115.20.71] helo=flpi102.prodigy.net)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IEuAJ-00032e-6N
	for nfs@lists.sourceforge.net; Sat, 28 Jul 2007 14:49:35 -0700
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

umount.nfs should return the standard EX_ mount return codes.  At some
point in the past, it was returning 0 for failure and 1 for success, and
some of these have been changed and some haven't.  See if we can rectify
this.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 utils/mount/nfsumount.c |   10 +++++-----
 1 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/utils/mount/nfsumount.c b/utils/mount/nfsumount.c
index dbfb85b..55e1c28 100644
--- a/utils/mount/nfsumount.c
+++ b/utils/mount/nfsumount.c
@@ -281,17 +281,17 @@ int nfsumount(int argc, char *argv[])
 		case 'h':
 		default:
 			umount_usage();
-			return 0;
+			return EX_USAGE;
 		}
 	}
 	if (optind != argc) {
 		umount_usage();
-		return 0;
+		return EX_USAGE;
 	}
 	
 	if (spec == NULL || (*spec != '/' && strchr(spec,':') == NULL)) {
-		printf(_("umount: %s: not found\n"), spec);
-		return 0;
+		nfs_error(_("%s: %s: not found\n"), progname, spec);
+		return EX_USAGE;
 	}
 
 	if (*spec == '/')
@@ -319,7 +319,7 @@ int nfsumount(int argc, char *argv[])
 		only_root:
 			nfs_error(_("%s: You are not permitted to unmount %s"),
 					progname, spec);
-			return 0;
+			return EX_USAGE;
 		}
 		if (hasmntopt(&mc->m, "users") == NULL) {
 			char *opt = hasmntopt(&mc->m, "user");


-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >>  http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
