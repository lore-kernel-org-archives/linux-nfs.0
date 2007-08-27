From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: [PATCH 03/15] nfsd: fix horrible indentation in nfsd_setattr
Date: Mon, 27 Aug 2007 16:22:44 -0400
Message-ID: <1188246177833-git-send-email-bfields@fieldses.org>
References: <11882461763072-git-send-email-bfields@fieldses.org>
	<1188246176681-git-send-email-bfields@fieldses.org>
	<1188246176897-git-send-email-bfields@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Neil Brown <neilb@suse.de>,
	Christoph Hellwig <hch@infradead.org>, nfs@lists.sourceforge.net,
	Christoph Hellwig <hch@lst.de>
To: linux-kernel@vger.kernel.org
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IPl72-0004k0-MQ
	for nfs@lists.sourceforge.net; Mon, 27 Aug 2007 13:23:04 -0700
Received: from mail.fieldses.org ([66.93.2.214] helo=fieldses.org)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1IPl76-0003Pp-Id
	for nfs@lists.sourceforge.net; Mon, 27 Aug 2007 13:23:09 -0700
In-Reply-To: <1188246176897-git-send-email-bfields@fieldses.org>
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

From: Christoph Hellwig <hch@infradead.org>

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 fs/nfsd/vfs.c |   43 ++++++++++++++++++++++++++-----------------
 1 files changed, 26 insertions(+), 17 deletions(-)

diff --git a/fs/nfsd/vfs.c b/fs/nfsd/vfs.c
index a0c2b25..11ae949 100644
--- a/fs/nfsd/vfs.c
+++ b/fs/nfsd/vfs.c
@@ -294,7 +294,8 @@ nfsd_setattr(struct svc_rqst *rqstp, struct svc_fh *fhp, struct iattr *iap,
 	if (!iap->ia_valid)
 		goto out;
 
-	/* NFSv2 does not differentiate between "set-[ac]time-to-now"
+	/*
+	 * NFSv2 does not differentiate between "set-[ac]time-to-now"
 	 * which only requires access, and "set-[ac]time-to-X" which
 	 * requires ownership.
 	 * So if it looks like it might be "set both to the same time which
@@ -307,25 +308,33 @@ nfsd_setattr(struct svc_rqst *rqstp, struct svc_fh *fhp, struct iattr *iap,
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
+		/*
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
+			/*
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
 			err = nfsd_permission(rqstp, fhp->fh_export, dentry, MAY_TRUNC|MAY_OWNER_OVERRIDE);
-- 
1.5.3.rc5.19.g0734d


-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >>  http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
