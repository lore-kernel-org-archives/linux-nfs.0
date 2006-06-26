From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 2/2] NFS: missing
	set_page_writeback()/end_page_writeback() in nfs_cancel_requests
Date: Mon, 26 Jun 2006 19:32:07 -0400
Message-ID: <20060626233206.6228.95805.stgit@lade.trondhjem.org>
References: <20060626233204.6228.86324.stgit@lade.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: linux-fsdevel@vger.kernel.org, nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Fv0Yp-00026C-NR
	for nfs@lists.sourceforge.net; Mon, 26 Jun 2006 16:32:07 -0700
Received: from dh134.citi.umich.edu ([141.211.133.134] helo=lade.trondhjem.org)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1Fv0Yp-0004qo-Jf
	for nfs@lists.sourceforge.net; Mon, 26 Jun 2006 16:32:08 -0700
To: linux-kernel@vger.kernel.org
In-Reply-To: <20060626233204.6228.86324.stgit@lade.trondhjem.org>
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

From: Trond Myklebust <Trond.Myklebust@netapp.com>

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---

 fs/nfs/write.c |   22 +++++++++++++++++++---
 1 files changed, 19 insertions(+), 3 deletions(-)

diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index d054f12..fe3eb36 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -579,7 +579,23 @@ static int nfs_wait_on_requests(struct i
 	return ret;
 }
 
-static void nfs_cancel_requests(struct list_head *head)
+static void nfs_cancel_dirty_list(struct list_head *head)
+{
+	struct nfs_page *req;
+	while(!list_empty(head)) {
+		req = nfs_list_entry(head->next);
+		nfs_list_remove_request(req);
+		/* Hack, cough, splutter!
+		 * Wretched borken mm requires us to do this...
+		 */
+		set_page_writeback(req->wb_page);
+		end_page_writeback(req->wb_page);
+		nfs_inode_remove_request(req);
+		nfs_clear_page_writeback(req);
+	}
+}
+
+static void nfs_cancel_commit_list(struct list_head *head)
 {
 	struct nfs_page *req;
 	while(!list_empty(head)) {
@@ -1503,7 +1519,7 @@ int nfs_sync_inode_wait(struct inode *in
 		if (pages != 0) {
 			spin_unlock(&nfsi->req_lock);
 			if (how & FLUSH_INVALIDATE)
-				nfs_cancel_requests(&head);
+				nfs_cancel_dirty_list(&head);
 			else
 				ret = nfs_flush_list(inode, &head, pages, how);
 			spin_lock(&nfsi->req_lock);
@@ -1516,7 +1532,7 @@ int nfs_sync_inode_wait(struct inode *in
 			break;
 		if (how & FLUSH_INVALIDATE) {
 			spin_unlock(&nfsi->req_lock);
-			nfs_cancel_requests(&head);
+			nfs_cancel_commit_list(&head);
 			spin_lock(&nfsi->req_lock);
 			continue;
 		}

Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
