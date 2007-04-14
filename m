From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: NFS: Fix two bugs in the O_DIRECT write code
Date: Sat, 14 Apr 2007 19:11:52 -0400
Message-ID: <1176592312.6089.29.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: "Mr. Charles Edward Lever" <Chuck.Lever@oracle.com>,
	nfs@lists.sourceforge.net, linux-kernel@vger.kernel.org
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HcrPZ-0001ye-4V
	for nfs@lists.sourceforge.net; Sat, 14 Apr 2007 16:12:05 -0700
Received: from mx2.netapp.com ([216.240.18.37])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HcrPa-0001il-TF
	for nfs@lists.sourceforge.net; Sat, 14 Apr 2007 16:12:07 -0700
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

Do not flag an error if the COMMIT call fails and we decide to resend the
writes. Let the resend flag the error if it fails.

If a write has failed, then nfs_direct_write_result should not attempt to
send a commit. It should just exit asap and return the error to the user.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: Chuck Lever <chuck.lever@oracle.com>
---

 fs/nfs/direct.c |   11 +++++++----
 1 files changed, 7 insertions(+), 4 deletions(-)

diff --git a/fs/nfs/direct.c b/fs/nfs/direct.c
index b1c98ea..2877744 100644
--- a/fs/nfs/direct.c
+++ b/fs/nfs/direct.c
@@ -432,10 +432,10 @@ static void nfs_direct_commit_result(struct rpc_task *task, void *calldata)
 	if (NFS_PROTO(data->inode)->commit_done(task, data) != 0)
 		return;
 	if (unlikely(task->tk_status < 0)) {
-		dreq->error = task->tk_status;
+		dprintk("NFS: %5u commit failed with error %d.\n",
+				task->tk_pid, task->tk_status);
 		dreq->flags = NFS_ODIRECT_RESCHED_WRITES;
-	}
-	if (memcmp(&dreq->verf, &data->verf, sizeof(data->verf))) {
+	} else if (memcmp(&dreq->verf, &data->verf, sizeof(data->verf))) {
 		dprintk("NFS: %5u commit verify failed\n", task->tk_pid);
 		dreq->flags = NFS_ODIRECT_RESCHED_WRITES;
 	}
@@ -531,9 +531,12 @@ static void nfs_direct_write_result(struct rpc_task *task, void *calldata)
 
 	spin_lock(&dreq->lock);
 
+	if (unlikely(dreq->error != 0))
+		goto out_unlock;
 	if (unlikely(status < 0)) {
+		/* An error has occured, so we should not commit */
+		dreq->flags = 0;
 		dreq->error = status;
-		goto out_unlock;
 	}
 
 	dreq->count += data->res.count;

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
