From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 3/8] text-based mount.nfs: Use new parser to handle
	'addr='	and 'clientaddr='
Date: Fri, 28 Sep 2007 16:36:40 -0400
Message-ID: <20070928203640.12851.56915.stgit@monet.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: neilb@suse.de
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IbMZg-0006UY-Tf
	for nfs@lists.sourceforge.net; Fri, 28 Sep 2007 13:36:37 -0700
Received: from flpi102.sbcis.sbc.com ([207.115.20.71] helo=flpi102.prodigy.net)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IbMZl-000776-Re
	for nfs@lists.sourceforge.net; Fri, 28 Sep 2007 13:36:42 -0700
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

Introduce, but don't yet use, functions that will eventually replace
append_addr_opt() and append_clientaddr_opt().

Note the behavioral change in append_addr_opt() -- it simply removes
any previous 'addr=' rather than throwing an error.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 utils/mount/stropts.c |   55 +++++++++++++++++++++++++++++++++++++++++++++++++
 1 files changed, 55 insertions(+), 0 deletions(-)

diff --git a/utils/mount/stropts.c b/utils/mount/stropts.c
index f73521f..b2e8d2f 100644
--- a/utils/mount/stropts.c
+++ b/utils/mount/stropts.c
@@ -40,6 +40,7 @@
 #include "stropts.h"
 #include "error.h"
 #include "network.h"
+#include "parse_opt.h"
 
 #ifdef HAVE_RPCSVC_NFS_PROT_H
 #include <rpcsvc/nfs_prot.h>
@@ -235,6 +236,60 @@ static int append_clientaddr_opt(struct sockaddr_in *saddr, char **extra_opts)
 }
 
 /*
+ * Append the 'addr=' option to the options string to pass a resolved
+ * server address to the kernel.  After a successful mount, this address
+ * is also added to /etc/mtab for use when unmounting.
+ *
+ * If 'addr=' is already present, we strip it out.  This prevents users
+ * from setting a bogus 'addr=' option themselves, and also allows bg
+ * retries to recompute the server's address, in case it has changed.
+ *
+ * Returns 1 if 'addr=' option appended successfully;
+ * otherwise zero.
+ */
+static int append_addr_option(struct sockaddr_in *saddr,
+			   struct mount_options *options)
+{
+	char new_option[24];
+
+	po_remove_all(options, "addr");
+
+	snprintf(new_option, sizeof(new_option) - 1,
+			"addr=%s", inet_ntoa(saddr->sin_addr));
+
+	if (po_append(options, new_option) == PO_SUCCEEDED)
+		return 1;
+	return 0;
+}
+
+/*
+ * Called to discover our address and append an appropriate 'clientaddr='
+ * option to the options string.
+ *
+ * Returns 1 if 'clientaddr=' option created successfully or if
+ * 'clientaddr=' option is already present; otherwise zero.
+ */
+static int append_clientaddr_option(struct sockaddr_in *saddr,
+				    struct mount_options *options)
+{
+	struct sockaddr_in my_addr;
+	char new_option[32];
+
+	if (po_contains(options, "clientaddr") == PO_SUCCEEDED)
+		return 1;
+
+	if (!get_client_address(saddr, &my_addr))
+		return 0;
+
+	snprintf(new_option, sizeof(new_option) - 1,
+			"clientaddr=%s", inet_ntoa(my_addr.sin_addr));
+
+	if (po_append(options, new_option) == PO_SUCCEEDED)
+		return 1;
+	return 0;
+}
+
+/*
  * nfsmount_s - Mount an NFSv2 or v3 file system using C string options
  *
  * @spec:	C string hostname:path specifying remoteshare to mount


-------------------------------------------------------------------------
This SF.net email is sponsored by: Microsoft
Defy all challenges. Microsoft(R) Visual Studio 2005.
http://clk.atdmt.com/MRT/go/vse0120000070mrt/direct/01/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
