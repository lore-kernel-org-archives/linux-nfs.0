From: Jason Uhlenkott <juhlenko@akamai.com>
Subject: [TRIVIAL] Clean up nfs_create_request comments
Date: Fri, 24 Nov 2006 23:26:26 -0800
Message-ID: <20061125072626.GA23875@48M1231.sanmateo.corp.akamai.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Gnrvo-0004Vb-Hn
	for nfs@lists.sourceforge.net; Fri, 24 Nov 2006 23:26:36 -0800
Received: from fw01.cmbrmaks.akamai.com ([80.67.64.10] helo=smtp2.akamai.com)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1Gnrvo-00068v-K4
	for nfs@lists.sourceforge.net; Fri, 24 Nov 2006 23:26:37 -0800
Received: from smtp2.akamai.com (vwall.kendall.corp.akamai.com [172.17.4.33])
	by smtp2.akamai.com (8.13.8/8.12.10) with ESMTP id kAP7QrRq018897
	for <nfs@lists.sourceforge.net>; Sat, 25 Nov 2006 02:26:53 -0500 (EST)
Received: from 48M1231.sanmateo.corp.akamai.com
	(48M1231.sanmateo.corp.akamai.com [172.23.9.157])
	by smtp2.akamai.com (8.13.8/8.12.10) with ESMTP id kAP7QqFq018894
	for <nfs@lists.sourceforge.net>; Sat, 25 Nov 2006 02:26:53 -0500 (EST)
Received: from juhlenko by 48M1231.sanmateo.corp.akamai.com with local (Exim
	4.50) id 1Gnrve-0007qb-O2
	for nfs@lists.sourceforge.net; Fri, 24 Nov 2006 23:26:26 -0800
To: nfs@lists.sourceforge.net
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

--- linux.orig/fs/nfs/pagelist.c	2006-11-24 23:03:00.350861445 -0800
+++ linux/fs/nfs/pagelist.c	2006-11-24 23:04:06.213414314 -0800
@@ -49,9 +49,7 @@
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
@@ -62,16 +60,12 @@
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
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys - and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
