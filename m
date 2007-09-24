From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 02/14] mount.nfs: add EX_SUCCESS exit code
Date: Mon, 24 Sep 2007 11:28:33 -0400
Message-ID: <20070924152833.3804.38316.stgit@monet.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: neilb@suse.de
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IZq3b-0007yQ-0d
	for nfs@lists.sourceforge.net; Mon, 24 Sep 2007 08:41:11 -0700
Received: from flpi101.sbcis.sbc.com ([207.115.20.70] helo=flpi101.prodigy.net)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IZpro-0004kX-Si
	for nfs@lists.sourceforge.net; Mon, 24 Sep 2007 08:29:01 -0700
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

We've had some recent trouble, especially in the umount code, that appears
to be due to functions returning a 1 or a 0 return code when they should be
returning a mount exit code (such as EX_FAIL) or a 0.

To help clearly distinguish these two classes of functions, define an
EX_SUCCESS exit code, which is equal to zero.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 support/include/xcommon.h |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/support/include/xcommon.h b/support/include/xcommon.h
index 9e23d12..d1a4b18 100644
--- a/support/include/xcommon.h
+++ b/support/include/xcommon.h
@@ -36,6 +36,7 @@ extern void die(int err, const char *fmt, ...);
 extern void (*at_die)(void);
 
 /* exit status - bits below are ORed */
+#define EX_SUCCESS	0	/* no failure occurred */
 #define EX_USAGE	1	/* incorrect invocation or permission */
 #define EX_SYSERR	2	/* out of memory, cannot fork, ... */
 #define EX_SOFTWARE	4	/* internal mount bug or wrong version */


-------------------------------------------------------------------------
This SF.net email is sponsored by: Microsoft
Defy all challenges. Microsoft(R) Visual Studio 2005.
http://clk.atdmt.com/MRT/go/vse0120000070mrt/direct/01/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
