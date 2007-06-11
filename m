From: Frank Filz <ffilzlnx@us.ibm.com>
Subject: [PATCH] Make sure unlock is really an unlock when cancelling
	a lock
Date: Mon, 11 Jun 2007 10:01:09 -0700
Message-ID: <1181581269.8988.42.camel@dyn9047022153>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: NFS List <nfs@lists.sourceforge.net>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Hxn9q-0004A4-T8
	for nfs@lists.sourceforge.net; Mon, 11 Jun 2007 09:54:23 -0700
Received: from e1.ny.us.ibm.com ([32.97.182.141])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1Hxn9r-00036c-OU
	for nfs@lists.sourceforge.net; Mon, 11 Jun 2007 09:54:26 -0700
Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e1.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id l5BGs7qO012691
	for <nfs@lists.sourceforge.net>; Mon, 11 Jun 2007 12:54:07 -0400
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v8.3) with ESMTP id
	l5BGs746528292
	for <nfs@lists.sourceforge.net>; Mon, 11 Jun 2007 12:54:07 -0400
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id
	l5BGs7Yq021859
	for <nfs@lists.sourceforge.net>; Mon, 11 Jun 2007 12:54:07 -0400
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

I ran into a curious issue when a lock is being canceled. The
cancellation results in a lock request to the vfs layer instead of an
unlock request. This is particularly insidious when the process that
owns the lock is exiting. In that case, sometimes the erroneous lock is
applied AFTER the process has entered zombie state, preventing the lock
from ever being released. Eventually other processes block on the lock
causing a slow degredation of the system. In the 2.6.16 kernel this was
investigated on, the problem is compounded by the fact that the cl_sem
is held while blocking on the vfs lock, which results in most processes
accessing the nfs file system in question hanging.

It seems like the simplest solution is to force all situations where
nfs4_do_unlck() is being used to result in an unlock, so with that in
mind, I made the following change:

Signed-off-by: Frank Filz <ffilzlnx@us.ibm.com>

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 648e0ac..6751a8c 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -3152,6 +3152,11 @@ static struct rpc_task *nfs4_do_unlck(struct file_lock *fl,
 {
 	struct nfs4_unlockdata *data;
 
+	/* Ensure this is an unlock - when canceling a lock, the
+	 * canceled lock is passed in, and it won't be an unlock.
+	 */
+	fl->fl_type = F_UNLCK;
+
 	data = nfs4_alloc_unlockdata(fl, ctx, lsp, seqid);
 	if (data == NULL) {
 		nfs_free_seqid(seqid);



-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
