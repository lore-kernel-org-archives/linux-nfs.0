From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 11/23] umount.nfs: Make do_nfs_mount use conventional
	EX_	style return codes
Date: Sat, 28 Jul 2007 17:50:04 -0400
Message-ID: <20070728215004.21871.3483.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: neilb@suse.de
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IEuAp-0007Xn-49
	for nfs@lists.sourceforge.net; Sat, 28 Jul 2007 14:50:07 -0700
Received: from flpi102.sbcis.sbc.com ([207.115.20.71] helo=flpi102.prodigy.net)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IEuAt-0003IJ-0V
	for nfs@lists.sourceforge.net; Sat, 28 Jul 2007 14:50:11 -0700
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

do_nfs_mount() should return EX_ style return codes and not 1 or 0 in order
to distinguish between usage errors and other problems (such as EX_FILEIO
or RPC errors).

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 utils/mount/nfsumount.c |   38 ++++++++++++++++++++++++++------------
 1 files changed, 26 insertions(+), 12 deletions(-)

diff --git a/utils/mount/nfsumount.c b/utils/mount/nfsumount.c
index a6fec31..4a41ff1 100644
--- a/utils/mount/nfsumount.c
+++ b/utils/mount/nfsumount.c
@@ -121,9 +121,6 @@ static int del_mtab(const char *spec, const char *node)
         return EX_FILEIO;
 }
 
-/*
- * Returns 1 if everything went well, else 0.
- */
 static int do_nfs_umount(const char *spec, char *opts)
 {
 	char *hostname;
@@ -133,10 +130,20 @@ static int do_nfs_umount(const char *spec, char *opts)
 	struct pmap *pmap = &mnt_server.pmap;
 	char *p;
 
-	if (spec == NULL || (p = strchr(spec,':')) == NULL)
-		goto out_bad;
-	hostname = xstrndup(spec, p-spec);
-	dirname = xstrdup(p+1);
+	if (spec == NULL) {
+		nfs_error(_("%s: No NFS export name was provided"),
+				progname);
+		return EX_USAGE;
+	}
+	
+	p = strchr(spec, ':');
+	if (p == NULL) {
+		nfs_error(_("%s: '%s' is not a legal NFS export name"),
+				progname, spec);
+		return EX_USAGE;
+	}
+	hostname = xstrndup(spec, p - spec);
+	dirname = xstrdup(p + 1);
 #ifdef NFS_MOUNT_DEBUG
 	printf(_("host: %s, directory: %s\n"), hostname, dirname);
 #endif
@@ -180,11 +187,18 @@ static int do_nfs_umount(const char *spec, char *opts)
 	if (opts && (hasmntopt(&mnt, "udp") || hasmntopt(&mnt, "proto=udp")))
 		pmap->pm_prot = IPPROTO_UDP;
 
-	if (!nfs_gethostbyname(hostname, &mnt_server.saddr))
-		goto out_bad;
-	return nfs_call_umount(&mnt_server, &dirname);
- out_bad:
-	nfs_error(_("%s: %s: not found or not mounted"), progname, spec);
+	if (!nfs_gethostbyname(hostname, &mnt_server.saddr)) {
+		nfs_error(_("%s: '%s' does not contain a recognized hostname"),
+				progname, spec);
+		return EX_USAGE;
+	}
+
+	if (!nfs_call_umount(&mnt_server, &dirname)) {
+		nfs_error(_("%s: Server failed to unmount '%s'"),
+				progname, spec);
+		return EX_USAGE;
+	}
+
 	return 0;
 }
 


-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >>  http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
