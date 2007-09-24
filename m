From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 07/14] text-based mount.nfs: Use "child" instead of
	"bg" for	nfsmount_s
Date: Mon, 24 Sep 2007 11:28:59 -0400
Message-ID: <20070924152859.3804.4483.stgit@monet.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: neilb@suse.de
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IZpsK-0006pv-QT
	for nfs@lists.sourceforge.net; Mon, 24 Sep 2007 08:29:32 -0700
Received: from flpi101.sbcis.sbc.com ([207.115.20.70] helo=flpi101.prodigy.net)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IZpsN-0006Jr-KD
	for nfs@lists.sourceforge.net; Mon, 24 Sep 2007 08:29:37 -0700
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
index a04596d..f73521f 100644
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
