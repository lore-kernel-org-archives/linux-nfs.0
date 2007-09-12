From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 21/24] text-based mount.nfs: Plug "bg" processing
	into	nfsmount_s()
Date: Wed, 12 Sep 2007 12:16:19 -0400
Message-ID: <20070912161619.23491.90147.stgit@manray.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IVUt4-0004ax-Bw
	for nfs@lists.sourceforge.net; Wed, 12 Sep 2007 09:16:22 -0700
Received: from flpi101.sbcis.sbc.com ([207.115.20.70] helo=flpi101.prodigy.net)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IVUt6-0002vl-Vm
	for nfs@lists.sourceforge.net; Wed, 12 Sep 2007 09:16:27 -0700
Received: from manray.1015granger.net
	(adsl-76-241-169-38.dsl.sfldmi.sbcglobal.net [76.241.169.38])
	by flpi101.prodigy.net (8.13.8 out.dk.spool/8.13.8) with ESMTP id
	l8CGFT83030583
	for <nfs@lists.sourceforge.net>; Wed, 12 Sep 2007 09:15:29 -0700
Received: from manray.1015granger.net (manray.1015granger.net [127.0.0.1])
	by manray.1015granger.net (8.14.1/8.14.1) with ESMTP id l8CGGJjL023633
	for <nfs@lists.sourceforge.net>; Wed, 12 Sep 2007 12:16:19 -0400
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

We have all the pre-requisites now, so add "bg" mount processing to
nfsmount_s() to enable background mount processing for text-based NFSv2 and
NFSv3 mounts.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 utils/mount/stropts.c |   17 ++++++++++++-----
 1 files changed, 12 insertions(+), 5 deletions(-)

diff --git a/utils/mount/stropts.c b/utils/mount/stropts.c
index e5be243..d2d7e9f 100644
--- a/utils/mount/stropts.c
+++ b/utils/mount/stropts.c
@@ -554,8 +554,6 @@ static int nfsmount_child(const char *spec, const char *node,
  *		(possibly also a return argument)
  * @fake:	flag indicating whether to carry out the whole operation
  * @child:	one if this is a backgrounded mount
- *
- * XXX: need to handle bg, fg, and retry options.
  */
 int nfsmount_s(const char *spec, const char *node, int flags,
 		char **extra_opts, int fake, int child)
@@ -568,14 +566,13 @@ int nfsmount_s(const char *spec, const char *node, int flags,
 	if (!parse_devname(spec, &hostname))
 		return retval;
 	err = fill_ipv4_sockaddr(hostname, &saddr);
-	free(hostname);
 	if (!err)
-		return retval;
+		goto fail;
 
 	options = po_split(*extra_opts);
 	if (!options) {
 		nfs_error(_("%s: internal option parsing error"), progname);
-		return retval;
+		goto fail;
 	}
 
 	if (!append_addr_option(&saddr, options, child))
@@ -587,9 +584,19 @@ int nfsmount_s(const char *spec, const char *node, int flags,
 	if (po_rightmost(options, "bg", "fg") > -1)
 		retval =  nfsmount_fg(spec, node, flags, options,
 							fake, extra_opts);
+	else {
+		if (!child)
+			retval = nfsmount_parent(spec, node, hostname, flags,
+						 options, fake, extra_opts);
+		else
+			retval = nfsmount_child(spec, node, hostname, flags,
+						options, fake, extra_opts);
+	}
 
 out:
 	po_destroy(options);
+fail:
+	free(hostname);
 	return retval;
 }
 


-------------------------------------------------------------------------
This SF.net email is sponsored by: Microsoft
Defy all challenges. Microsoft(R) Visual Studio 2005.
http://clk.atdmt.com/MRT/go/vse0120000070mrt/direct/01/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
