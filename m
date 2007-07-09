From: Frank Filz <ffilzlnx@us.ibm.com>
Subject: [RESUBMIT][PATCH] Make sure unlock is really an unlock
	when	cancelling a lock
Date: Mon, 09 Jul 2007 15:32:29 -0700
Message-ID: <1184020349.16851.40.camel@dyn9047022153>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Trond Myklebust <trond.myklebust@fys.uio.no>
To: NFS List <nfs@lists.sourceforge.net>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1I81i6-0006jM-DQ
	for nfs@lists.sourceforge.net; Mon, 09 Jul 2007 15:28:05 -0700
Received: from e6.ny.us.ibm.com ([32.97.182.146])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1I81i9-0005rV-E8
	for nfs@lists.sourceforge.net; Mon, 09 Jul 2007 15:28:05 -0700
Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e6.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id l69MTAFP027807
	for <nfs@lists.sourceforge.net>; Mon, 9 Jul 2007 18:29:10 -0400
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v8.3) with ESMTP id
	l69MRw1c370870
	for <nfs@lists.sourceforge.net>; Mon, 9 Jul 2007 18:27:58 -0400
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id
	l69MRwtu000869
	for <nfs@lists.sourceforge.net>; Mon, 9 Jul 2007 18:27:58 -0400
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

Not sure if this got lost in the noise:

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

In more detail, here is how the situation occurs:

first _nfs4_do_setlk():

static int _nfs4_do_setlk(struct nfs4_state *state, int cmd, struct file_lock *fl, int reclaim)
...
        ret = nfs4_wait_for_completion_rpc_task(task);
        if (ret == 0) {
...
        } else
                data->cancelled = 1;

then nfs4_lock_release():

static void nfs4_lock_release(void *calldata)
...
        if (data->cancelled != 0) {
                struct rpc_task *task;
                task = nfs4_do_unlck(&data->fl, data->ctx, data->lsp,
                                data->arg.lock_seqid);

The problem is the same file_lock that was passed in to _nfs4_do_setlk()
gets passed to nfs4_do_unlck() from nfs4_lock_release(). So the type is
still F_RDLCK or FWRLCK, not F_UNLCK. At some point, when cancelling the
lock, the type needs to be changed to F_UNLCK. It seemed easiest to do
that in nfs4_do_unlck(), but it could be done in nfs4_lock_release().
The concern I had with doing it there was if something still needed the
original file_lock, though it turns out the original file_lock still
needs to be modified by nfs4_do_unlck() because nfs4_do_unlck() uses the
original file_lock to pass to the vfs layer, and a copy of the original
file_lock for the RPC request.

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
