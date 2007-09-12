From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 16/24] text-based mount.nfs: Implement falling back to
	NFSv2	and UDP
Date: Wed, 12 Sep 2007 12:15:53 -0400
Message-ID: <20070912161553.23491.53440.stgit@manray.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IVUsc-0004So-4P
	for nfs@lists.sourceforge.net; Wed, 12 Sep 2007 09:15:54 -0700
Received: from flpi101.sbcis.sbc.com ([207.115.20.70] helo=flpi101.prodigy.net)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IVUsf-0000pV-Se
	for nfs@lists.sourceforge.net; Wed, 12 Sep 2007 09:15:58 -0700
Received: from manray.1015granger.net
	(adsl-76-241-169-38.dsl.sfldmi.sbcglobal.net [76.241.169.38])
	by flpi101.prodigy.net (8.13.8 out.dk.spool/8.13.8) with ESMTP id
	l8CGF3wt029268
	for <nfs@lists.sourceforge.net>; Wed, 12 Sep 2007 09:15:03 -0700
Received: from manray.1015granger.net (manray.1015granger.net [127.0.0.1])
	by manray.1015granger.net (8.14.1/8.14.1) with ESMTP id l8CGFr7h023603
	for <nfs@lists.sourceforge.net>; Wed, 12 Sep 2007 12:15:53 -0400
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

An additional kernel patch is required to cause the kernel to return
EOPNOTSUPP when an rpcbind fails during a NULL request.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 utils/mount/stropts.c |   40 +++++++++++++++++++++++++++++++++++-----
 1 files changed, 35 insertions(+), 5 deletions(-)

diff --git a/utils/mount/stropts.c b/utils/mount/stropts.c
index f6d11e9..d4777df 100644
--- a/utils/mount/stropts.c
+++ b/utils/mount/stropts.c
@@ -344,7 +344,10 @@ static int rewrite_mount_opts(struct mount_options *options)
 }
 
 /*
- * Attempt an NFS mount via a mount(2) system call.
+ * Attempt an NFS mount via a mount(2) system call.  If the kernel
+ * claims the requested service isn't supported on the server, probe
+ * the server to see what's supported, rewrite the mount options,
+ * and retry the request.
  *
  * Returns 1 if successful.  Otherwise, returns zero.
  * "errno" is set to reflect the individual error.
@@ -355,10 +358,8 @@ static int try_nfsmount(const char *spec, const char *node,
 {
 	free(*extra_opts);
 	*extra_opts = po_join(options);
-	if (!*extra_opts) {
-		nfs_error(_("%s: internal option parsing error"), progname);
-		return 0;
-	}
+	if (!*extra_opts)
+		goto parse_err;
 
 	if (verbose)
 		printf(_("%s: text-based options: '%s'\n"),
@@ -371,8 +372,37 @@ static int try_nfsmount(const char *spec, const char *node,
 				flags & ~(MS_USER|MS_USERS), *extra_opts))
 		return 1;
 
+	/*
+	 * Kernel returns EOPNOTSUPP if the RPC bind failed,
+	 * and EPROTONOSUPPORT if the version isn't supported.
+	 */
+	if (errno != EOPNOTSUPP && errno != EPROTONOSUPPORT) {
+		mount_error(spec, node, errno);
+		return 0;
+	}
+
+	if (!rewrite_mount_opts(options))
+		goto parse_err;
+	free(*extra_opts);
+	*extra_opts = po_join(options);
+	if (!*extra_opts)
+		goto parse_err;
+
+	if (verbose)
+		printf(_("%s: text-based options (retry): '%s'\n"),
+			progname, *extra_opts);
+
+	if (!mount(spec, node, "nfs",
+				flags & ~(MS_USER|MS_USERS), *extra_opts))
+		return 1;
+
 	mount_error(spec, node, errno);
 	return 0;
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
