From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 13/19] mount.nfs: Implement falling back to NFSv2 and
	UDP
Date: Mon, 10 Sep 2007 20:59:32 -0400
Message-ID: <20070911005932.24927.57093.stgit@monet.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IUu6D-000332-3T
	for nfs@lists.sourceforge.net; Mon, 10 Sep 2007 17:59:29 -0700
Received: from flpi102.sbcis.sbc.com ([207.115.20.71] helo=flpi102.prodigy.net)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IUu6H-0001NQ-Pg
	for nfs@lists.sourceforge.net; Mon, 10 Sep 2007 17:59:34 -0700
Received: from monet.1015granger.net
	(adsl-76-241-169-38.dsl.sfldmi.sbcglobal.net [76.241.169.38])
	by flpi102.prodigy.net (8.13.8 out.dk.spool/8.13.8) with ESMTP id
	l8B0xMLx028720
	for <nfs@lists.sourceforge.net>; Mon, 10 Sep 2007 17:59:22 -0700
Received: from monet.1015granger.net (monet.1015granger.net [127.0.0.1])
	by monet.1015granger.net (8.14.1/8.14.1) with ESMTP id l8B0xWWI025062
	for <nfs@lists.sourceforge.net>; Mon, 10 Sep 2007 20:59:32 -0400
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

If the initial user-specified options fail (with EOPNOTSUPP) then the
server has rejected the requested NFS version or transport protocol.

In that case, probe the server, and construct a fresh set of mount options
that ask for the specific mountd and NFS version and transport protocol
that the server supports.  Rewrite the mount options based on the results
of the probe, then try the request again.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 utils/mount/stropts.c |   32 +++++++++++++++++++++++++-------
 1 files changed, 25 insertions(+), 7 deletions(-)

diff --git a/utils/mount/stropts.c b/utils/mount/stropts.c
index deaf9e1..99d48cf 100644
--- a/utils/mount/stropts.c
+++ b/utils/mount/stropts.c
@@ -353,16 +353,15 @@ static int rewrite_mount_opts(struct mount_options *options)
  * Attempt an NFS mount via a mount(2) system call.
  *
  * Returns 1 if successful.  Otherwise, returns zero.
+ * "errno" is set to reflect the individual error.
  */
 static int try_nfsmount(const char *spec, const char *node,
 			int flags, struct mount_options *options,
 			int fake, char **extra_opts)
 {
 	*extra_opts = po_join(options);
-	if (!*extra_opts) {
-		nfs_error(_("%s: internal option parsing error"), progname);
-		return 0;
-	}
+	if (!*extra_opts)
+		goto parse_err;
 
 	if (verbose)
 		printf(_("%s: text-based options: '%s'\n"),
@@ -371,13 +370,32 @@ static int try_nfsmount(const char *spec, const char *node,
 	if (fake)
 		return 1;
 
-	if (mount(spec, node, "nfs",
-				flags & ~(MS_USER|MS_USERS), *extra_opts)) {
+	if (!mount(spec, node, "nfs",
+				flags & ~(MS_USER|MS_USERS), *extra_opts))
+		return 1;
+
+	if (errno != EOPNOTSUPP) {
 		mount_error(spec, node, errno);
 		return 0;
 	}
 
-	return 1;
+	if (!rewrite_mount_opts(options))
+		goto parse_err;
+	*extra_opts = po_join(options);
+	if (!*extra_opts)
+		goto parse_err;
+
+	if (!mount(spec, node, "nfs",
+				flags & ~(MS_USER|MS_USERS), *extra_opts))
+		return 1;
+
+	mount_error(spec, node, errno);
+	return 0;
+
+parse_err:
+	nfs_error(_("%s: internal option parsing error"), progname);
+	errno = EINVAL;
+	return 0;
 }
 
 /*


-------------------------------------------------------------------------
This SF.net email is sponsored by: Microsoft
Defy all challenges. Microsoft(R) Visual Studio 2005.
http://clk.atdmt.com/MRT/go/vse0120000070mrt/direct/01/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
