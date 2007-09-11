From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 01/19] text-based mount.nfs: Use "child" instead of
	"bg" for	nfsmount_s
Date: Mon, 10 Sep 2007 20:58:29 -0400
Message-ID: <20070911005828.24927.70152.stgit@monet.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IUu5O-0002vv-1o
	for nfs@lists.sourceforge.net; Mon, 10 Sep 2007 17:58:38 -0700
Received: from flpi102.sbcis.sbc.com ([207.115.20.71] helo=flpi102.prodigy.net)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IUu5R-00012w-OM
	for nfs@lists.sourceforge.net; Mon, 10 Sep 2007 17:58:42 -0700
Received: from monet.1015granger.net
	(adsl-76-241-169-38.dsl.sfldmi.sbcglobal.net [76.241.169.38])
	by flpi102.prodigy.net (8.13.8 out.dk.spool/8.13.8) with ESMTP id
	l8B0wIDE027410
	for <nfs@lists.sourceforge.net>; Mon, 10 Sep 2007 17:58:18 -0700
Received: from monet.1015granger.net (monet.1015granger.net [127.0.0.1])
	by monet.1015granger.net (8.14.1/8.14.1) with ESMTP id l8B0wT02024990
	for <nfs@lists.sourceforge.net>; Mon, 10 Sep 2007 20:58:29 -0400
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

Match a recent change to nfs4mount_s -- eventually it will become clear why
these were renamed.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 utils/mount/stropts.c |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/utils/mount/stropts.c b/utils/mount/stropts.c
index 236a3b4..018c6e7 100644
--- a/utils/mount/stropts.c
+++ b/utils/mount/stropts.c
@@ -243,12 +243,12 @@ static int append_clientaddr_opt(struct sockaddr_in *saddr, char **extra_opts)
  * @extra_opts:	pointer to C string containing fs-specific mount options
  *		(possibly also a return argument)
  * @fake:	flag indicating whether to carry out the whole operation
- * @bg:		one if this is a backgrounded mount attempt
+ * @child:	one if this is a backgrounded mount
  *
  * XXX: need to handle bg, fg, and retry options.
  */
 int nfsmount_s(const char *spec, const char *node, int flags,
-		char **extra_opts, int fake, int bg)
+		char **extra_opts, int fake, int child)
 {
 	struct sockaddr_in saddr;
 	char *hostname;
@@ -263,7 +263,7 @@ int nfsmount_s(const char *spec, const char *node, int flags,
 
 	extract_interesting_options(*extra_opts);
 
-	if (!bg && addr_opt) {
+	if (!child && addr_opt) {
 		nfs_error(_("%s: Illegal option: 'addr='"), progname);
 		return EX_FAIL;
 	}


-------------------------------------------------------------------------
This SF.net email is sponsored by: Microsoft
Defy all challenges. Microsoft(R) Visual Studio 2005.
http://clk.atdmt.com/MRT/go/vse0120000070mrt/direct/01/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
