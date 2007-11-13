From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 13/25] NFS: Distinguish IPv6 addresses in
	__nfs_find_client
Date: Tue, 13 Nov 2007 13:32:09 -0500
Message-ID: <20071113183209.5087.28230.stgit@manray.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: netdev@vger.kernel.org
To: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Is0YU-0000UQ-F9
	for nfs@lists.sourceforge.net; Tue, 13 Nov 2007 10:32:11 -0800
Received: from flpi101.sbcis.sbc.com ([207.115.20.70] helo=flpi101.prodigy.net)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1Is0YZ-0008H8-NE
	for nfs@lists.sourceforge.net; Tue, 13 Nov 2007 10:32:16 -0800
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

Add support for the AF_INET6 family of IP addresses in __nfs_find_client.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
Cc: Aurelien Charbon <aurelien.charbon@ext.bull.net>
---

 fs/nfs/client.c |   34 +++++++++++++++++++++++++++-------
 1 files changed, 27 insertions(+), 7 deletions(-)

diff --git a/fs/nfs/client.c b/fs/nfs/client.c
index 8eff0b2..67a5a53 100644
--- a/fs/nfs/client.c
+++ b/fs/nfs/client.c
@@ -34,6 +34,8 @@
 #include <linux/nfs_idmap.h>
 #include <linux/vfs.h>
 #include <linux/inet.h>
+#include <linux/in6.h>
+#include <net/ipv6.h>
 #include <linux/nfs_xdr.h>
 
 #include <asm/system.h>
@@ -213,11 +215,10 @@ static struct nfs_client *__nfs_find_client(const struct sockaddr *addr,
 					    unsigned int nfsversion,
 					    int match_port)
 {
-	struct sockaddr_in *ap = (struct sockaddr_in *)addr;
 	struct nfs_client *clp;
 
 	list_for_each_entry(clp, &nfs_client_list, cl_share_link) {
-		struct sockaddr_in *clap = (struct sockaddr_in *)&clp->cl_addr;
+		struct sockaddr *clap = (struct sockaddr *)&clp->cl_addr;
 
 		/* Don't match clients that failed to initialise properly */
 		if (clp->cl_cons_state < 0)
@@ -227,14 +228,33 @@ static struct nfs_client *__nfs_find_client(const struct sockaddr *addr,
 		if (clp->rpc_ops->version != nfsversion)
 			continue;
 
-		if (((struct sockaddr *)clap)->sa_family != addr->sa_family)
+		if (clap->sa_family != addr->sa_family)
 			continue;
 
-		if (clap->sin_addr.s_addr != ap->sin_addr.s_addr)
+		switch (addr->sa_family) {
+		case AF_INET: {
+			struct sockaddr_in *sap = (struct sockaddr_in *)clap;
+			struct sockaddr_in *ap = (struct sockaddr_in *)addr;
+			if (sap->sin_addr.s_addr != ap->sin_addr.s_addr)
+				continue;
+			if (!match_port || sap->sin_port == ap->sin_port)
+				goto found;
 			continue;
-
-		if (!match_port || clap->sin_port == ap->sin_port)
-			goto found;
+			}
+		case AF_INET6: {
+			struct sockaddr_in6 *sap = (struct sockaddr_in6 *)clap;
+			struct sockaddr_in6 *ap = (struct sockaddr_in6 *)addr;
+			if (!ipv6_addr_equal(&sap->sin6_addr, &ap->sin6_addr))
+				continue;
+			if (!match_port || sap->sin6_port == ap->sin6_port)
+				goto found;
+			continue;
+			}
+		default:
+			printk(KERN_ERR "%s: address family not supported\n",
+				__FUNCTION__);
+			return NULL;
+		}
 	}
 
 	return NULL;


-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >> http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
