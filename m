From: Christoph Hellwig <hch@infradead.org>
Subject: [PATCH] nfsd: fix horrible indentation in nfsd_setattr
Date: Wed, 7 Mar 2007 15:26:25 +0000
Message-ID: <20070307152625.GA29633@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HOy2B-0007jn-Sk
	for nfs@lists.sourceforge.net; Wed, 07 Mar 2007 07:26:32 -0800
Received: from pentafluge.infradead.org ([213.146.154.40])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HOy2C-00046t-IF
	for nfs@lists.sourceforge.net; Wed, 07 Mar 2007 07:26:34 -0800
Received: from hch by pentafluge.infradead.org with local (Exim 4.63 #1 (Red
	Hat Linux)) id 1HOy25-0007iW-AR
	for nfs@lists.sourceforge.net; Wed, 07 Mar 2007 15:26:25 +0000
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


Signed-off-by: Christoph Hellwig <hch@lst.de>

Index: linux-2.6/fs/nfsd/vfs.c
===================================================================
--- linux-2.6.orig/fs/nfsd/vfs.c	2007-03-06 17:43:28.000000000 +0100
+++ linux-2.6/fs/nfsd/vfs.c	2007-03-06 17:45:48.000000000 +0100
@@ -277,7 +277,8 @@
 	if (!iap->ia_valid)
 		goto out;
 
-	/* NFSv2 does not differentiate between "set-[ac]time-to-now"
+	/*
+	 * NFSv2 does not differentiate between "set-[ac]time-to-now"
 	 * which only requires access, and "set-[ac]time-to-X" which
 	 * requires ownership.
 	 * So if it looks like it might be "set both to the same time which
@@ -290,25 +291,33 @@
 	 */
 #define BOTH_TIME_SET (ATTR_ATIME_SET | ATTR_MTIME_SET)
 #define	MAX_TOUCH_TIME_ERROR (30*60)
-	if ((iap->ia_valid & BOTH_TIME_SET) == BOTH_TIME_SET
-	    && iap->ia_mtime.tv_sec == iap->ia_atime.tv_sec
-	    ) {
-	    /* Looks probable.  Now just make sure time is in the right ballpark.
-	     * Solaris, at least, doesn't seem to care what the time request is.
-	     * We require it be within 30 minutes of now.
-	     */
-	    time_t delta = iap->ia_atime.tv_sec - get_seconds();
-	    if (delta<0) delta = -delta;
-	    if (delta < MAX_TOUCH_TIME_ERROR &&
-		inode_change_ok(inode, iap) != 0) {
-		/* turn off ATTR_[AM]TIME_SET but leave ATTR_[AM]TIME
-		 * this will cause notify_change to set these times to "now"
+	if ((iap->ia_valid & BOTH_TIME_SET) == BOTH_TIME_SET &&
+	    iap->ia_mtime.tv_sec == iap->ia_atime.tv_sec) {
+	    	/*
+		 * Looks probable.
+		 *
+		 * Now just make sure time is in the right ballpark.
+		 * Solaris, at least, doesn't seem to care what the time
+		 * request is.  We require it be within 30 minutes of now.
 		 */
-		iap->ia_valid &= ~BOTH_TIME_SET;
-	    }
+		time_t delta = iap->ia_atime.tv_sec - get_seconds();
+		if (delta < 0)
+			delta = -delta;
+		if (delta < MAX_TOUCH_TIME_ERROR &&
+		    inode_change_ok(inode, iap) != 0) {
+		    	/*
+			 * Turn off ATTR_[AM]TIME_SET but leave ATTR_[AM]TIME.
+			 * This will cause notify_change to set these times
+			 * to "now"
+			 */
+			iap->ia_valid &= ~BOTH_TIME_SET;
+		}
 	}
 	    
-	/* The size case is special. It changes the file as well as the attributes.  */
+	/*
+	 * The size case is special.
+	 * It changes the file as well as the attributes.
+	 */
 	if (iap->ia_valid & ATTR_SIZE) {
 		if (iap->ia_size < inode->i_size) {
 			err = nfsd_permission(fhp->fh_export, dentry, MAY_TRUNC|MAY_OWNER_OVERRIDE);

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys-and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
