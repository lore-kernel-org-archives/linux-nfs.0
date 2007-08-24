From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 1/9] mount.nfs: Fix nfs4mount_s prototype.
Date: Fri, 24 Aug 2007 13:11:11 -0400
Message-ID: <20070824171111.10418.69889.stgit@monet.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: neilb@suse.de
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IOcgx-0003vb-4j
	for nfs@lists.sourceforge.net; Fri, 24 Aug 2007 10:11:27 -0700
Received: from flpi101.sbcis.sbc.com ([207.115.20.70] helo=flpi101.prodigy.net)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IOch1-0001oE-DK
	for nfs@lists.sourceforge.net; Fri, 24 Aug 2007 10:11:31 -0700
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

The definition of nfs4mount_s in utils/mount/stropts.c doesn't match the
prototype declared in utils/mount/stropts.h.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 utils/mount/stropts.c |    5 +++--
 1 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/utils/mount/stropts.c b/utils/mount/stropts.c
index 95392a1..ca79ce0 100644
--- a/utils/mount/stropts.c
+++ b/utils/mount/stropts.c
@@ -37,6 +37,7 @@
 #include "nls.h"
 #include "nfs_mount.h"
 #include "mount_constants.h"
+#include "stropts.h"
 #include "error.h"
 #include "network.h"
 
@@ -286,13 +287,13 @@ fail:
  * @extra_opts:	pointer to C string containing fs-specific mount options
  *		(possibly also a return argument)
  * @fake:	flag indicating whether to carry out the whole operation
- * @bg:		one if this is a backgrounded mount attempt
+ * @child:	one if this is a backgrounded mount
  *
  * XXX: need to handle bg, fg, and retry options.
  *
  */
 int nfs4mount_s(const char *spec, const char *node, int flags,
-		char **extra_opts, int fake)
+		char **extra_opts, int fake, int child)
 {
 	int retval = EX_FAIL;
 


-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >>  http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
