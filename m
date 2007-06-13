From: Frank Filz <ffilzlnx@us.ibm.com>
Subject: Re: [PATCH] Make sure unlock is really an
	unlock	when	cancelling a lock
Date: Wed, 13 Jun 2007 13:17:37 -0700
Message-ID: <1181765857.16851.16.camel@dyn9047022153>
References: <1181581269.8988.42.camel@dyn9047022153>
	<1181752511.6151.5.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: NFS List <nfs@lists.sourceforge.net>
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HyZAj-0008LW-JY
	for nfs@lists.sourceforge.net; Wed, 13 Jun 2007 13:10:29 -0700
Received: from e3.ny.us.ibm.com ([32.97.182.143])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1HyZAl-0000Ph-Ca
	for nfs@lists.sourceforge.net; Wed, 13 Jun 2007 13:10:32 -0700
Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e3.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id l5DJ7O4L007798
	for <nfs@lists.sourceforge.net>; Wed, 13 Jun 2007 15:07:25 -0400
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v8.3) with ESMTP id
	l5DKAD1S510618
	for <nfs@lists.sourceforge.net>; Wed, 13 Jun 2007 16:10:13 -0400
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id
	l5DKACSG003789
	for <nfs@lists.sourceforge.net>; Wed, 13 Jun 2007 16:10:12 -0400
In-Reply-To: <1181752511.6151.5.camel@heimdal.trondhjem.org>
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

On Wed, 2007-06-13 at 12:35 -0400, Trond Myklebust wrote:
> On Mon, 2007-06-11 at 10:01 -0700, Frank Filz wrote:
> > I ran into a curious issue when a lock is being canceled. The
> > cancellation results in a lock request to the vfs layer instead of an
> > unlock request. This is particularly insidious when the process that
> 
> Any idea why the cancellation turns into a lock request? I really don't
> want to apply a patch that just appears to paper over the problem.

Ok, the path is as follows:

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

Frank




-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
