From: Joe Perches <joe@perches.com>
Subject: [PATCH] - [9/15] - remove defconfig ptr comparisons to 0 -
	fs/nfsd
Date: Tue, 13 Nov 2007 18:05:25 -0800
Message-ID: <1195005925.5163.95.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
	Neil Brown <neilb@suse.de>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	nfs@lists.sourceforge.net
To: linux-kernel <linux-kernel@vger.kernel.org>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Is7dP-0003vS-Ar
	for nfs@lists.sourceforge.net; Tue, 13 Nov 2007 18:05:43 -0800
Received: from dsl022.labridge.com ([206.117.136.22] helo=perches.com)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1Is7dT-0004FY-Tl
	for nfs@lists.sourceforge.net; Tue, 13 Nov 2007 18:05:49 -0800
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

Remove defconfig ptr comparison to 0

Remove sparse warning: Using plain integer as NULL pointer

Signed-off-by: Joe Perches <joe@perches.com>

---

diff --git a/fs/nfsd/vfs.c b/fs/nfsd/vfs.c
index d019918..07b38cf 100644
--- a/fs/nfsd/vfs.c
+++ b/fs/nfsd/vfs.c
@@ -987,7 +987,7 @@ nfsd_vfs_write(struct svc_rqst *rqstp, struct svc_fh *fhp, struct file *file,
 	 * flushing the data to disk is handled separately below.
 	 */
 
-	if (file->f_op->fsync == 0) {/* COMMIT3 cannot work */
+	if (!file->f_op->fsync) {/* COMMIT3 cannot work */
 	       stable = 2;
 	       *stablep = 2; /* FILE_SYNC */
 	}



-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >> http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
