From: Jason Uhlenkott <juhlenko@akamai.com>
Subject: [PATCH] Clean up nfs_create_request comments
Date: Thu, 26 Apr 2007 17:25:51 -0700
Message-ID: <20070427002551.GD23354@48M1231.sanmateo.corp.akamai.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: trond.myklebust@fys.uio.no
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HhEHe-0000ux-Lj
	for nfs@lists.sourceforge.net; Thu, 26 Apr 2007 17:25:58 -0700
Received: from fw01.cmbrmaks.akamai.com ([80.67.64.10] helo=smtp2.akamai.com)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HhEHg-0006pY-UM
	for nfs@lists.sourceforge.net; Thu, 26 Apr 2007 17:26:01 -0700
Received: from smtp1.akamai.com (vwall.kendall.corp.akamai.com [172.17.4.33])
	by smtp2.akamai.com (8.13.8/8.12.10) with ESMTP id l3R0PvdL015031
	for <nfs@lists.sourceforge.net>; Thu, 26 Apr 2007 20:25:58 -0400 (EDT)
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

Remove some stale comments about hard limits which went away in 2.5.

Signed-off-by: Jason Uhlenkott <juhlenko@akamai.com>
---

--- linux-2.6.orig/fs/nfs/pagelist.c	2007-01-02 17:32:53.000000000 -0800
+++ linux-2.6/fs/nfs/pagelist.c	2007-04-26 17:21:22.008631692 -0700
@@ -50,9 +50,7 @@
  * @count: number of bytes to read/write
  *
  * The page must be locked by the caller. This makes sure we never
- * create two different requests for the same page, and avoids
- * a possible deadlock when we reach the hard limit on the number
- * of dirty pages.
+ * create two different requests for the same page.
  * User should ensure it is safe to sleep in this function.
  */
 struct nfs_page *
@@ -63,16 +61,12 @@
 	struct nfs_server *server = NFS_SERVER(inode);
 	struct nfs_page		*req;
 
-	/* Deal with hard limits.  */
 	for (;;) {
 		/* try to allocate the request struct */
 		req = nfs_page_alloc();
 		if (req != NULL)
 			break;
 
-		/* Try to free up at least one request in order to stay
-		 * below the hard limit
-		 */
 		if (signalled() && (server->flags & NFS_MOUNT_INTR))
 			return ERR_PTR(-ERESTARTSYS);
 		yield();

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
