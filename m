From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 4/4] mount.nfs: Combine two verbose messages into one
Date: Tue, 21 Aug 2007 12:19:18 -0400
Message-ID: <20070821161918.4373.84933.stgit@monet.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: neilb@suse.de
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1INWS8-0003VO-6E
	for nfs@lists.sourceforge.net; Tue, 21 Aug 2007 09:19:36 -0700
Received: from flpvm23.prodigy.net ([207.115.20.53])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1INWSC-0007nT-Az
	for nfs@lists.sourceforge.net; Tue, 21 Aug 2007 09:19:40 -0700
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

A little less noise.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 utils/mount/stropts.c |   12 ++----------
 1 files changed, 2 insertions(+), 10 deletions(-)

diff --git a/utils/mount/stropts.c b/utils/mount/stropts.c
index c114200..95392a1 100644
--- a/utils/mount/stropts.c
+++ b/utils/mount/stropts.c
@@ -254,17 +254,13 @@ int nfsmount_s(const char *spec, const char *node, int flags,
 {
 	int retval = EX_FAIL;
 
-	if (verbose)
-		printf(_("%s: using C string mount system call interface\n"),
-			progname);
-
 	extract_interesting_options(*extra_opts);
 
 	if (!addr_opt && !append_addr_opt(spec, extra_opts))
 		goto fail;
 
 	if (verbose)
-		printf(_("%s: option string is '%s'\n"),
+		printf(_("%s: text-based options: '%s'\n"),
 			progname, *extra_opts);
 
 	if (!fake) {
@@ -300,10 +296,6 @@ int nfs4mount_s(const char *spec, const char *node, int flags,
 {
 	int retval = EX_FAIL;
 
-	if (verbose)
-		printf(_("%s: using C string mount system call interface\n"),
-			progname);
-
 	extract_interesting_options(*extra_opts);
 
 	if (!addr_opt && !append_addr_opt(spec, extra_opts))
@@ -313,7 +305,7 @@ int nfs4mount_s(const char *spec, const char *node, int flags,
 		goto fail;
 
 	if (verbose)
-		printf(_("%s: option string is '%s'\n"),
+		printf(_("%s: text-based options: '%s'\n"),
 			progname, *extra_opts);
 
 	if (!fake) {


-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >>  http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
