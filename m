From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [PATCH] Make sure unlock is really an
	unlock	when	cancelling a lock
Date: Wed, 13 Jun 2007 16:37:31 -0400
Message-ID: <1181767051.6151.86.camel@heimdal.trondhjem.org>
References: <1181581269.8988.42.camel@dyn9047022153>
	<1181752511.6151.5.camel@heimdal.trondhjem.org>
	<1181765857.16851.16.camel@dyn9047022153>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: NFS List <nfs@lists.sourceforge.net>
To: Frank Filz <ffilzlnx@us.ibm.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HyZb0-0002cJ-U4
	for nfs@lists.sourceforge.net; Wed, 13 Jun 2007 13:37:38 -0700
Received: from pat.uio.no ([129.240.10.15]
	ident=[U2FsdGVkX1+AnkhWMUqyoLe2xXNN75iamVcj6v3SLtM=])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1HyZb2-0000B6-B4
	for nfs@lists.sourceforge.net; Wed, 13 Jun 2007 13:37:42 -0700
In-Reply-To: <1181765857.16851.16.camel@dyn9047022153>
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

On Wed, 2007-06-13 at 13:17 -0700, Frank Filz wrote:
> On Wed, 2007-06-13 at 12:35 -0400, Trond Myklebust wrote:
> > On Mon, 2007-06-11 at 10:01 -0700, Frank Filz wrote:
> > > I ran into a curious issue when a lock is being canceled. The
> > > cancellation results in a lock request to the vfs layer instead of an
> > > unlock request. This is particularly insidious when the process that
> > 
> > Any idea why the cancellation turns into a lock request? I really don't
> > want to apply a patch that just appears to paper over the problem.
> 
> Ok, the path is as follows:
> 
> first _nfs4_do_setlk():
> 
> static int _nfs4_do_setlk(struct nfs4_state *state, int cmd, struct file_lock *fl, int reclaim)
> ...
> 	ret = nfs4_wait_for_completion_rpc_task(task);
> 	if (ret == 0) {
> ...
> 	} else
> 		data->cancelled = 1;
> 
> then nfs4_lock_release():
> 
> static void nfs4_lock_release(void *calldata)
> ...
> 	if (data->cancelled != 0) {
> 		struct rpc_task *task;
> 		task = nfs4_do_unlck(&data->fl, data->ctx, data->lsp,
> 				data->arg.lock_seqid);
> 
> The problem is the same file_lock that was passed in to _nfs4_do_setlk()
> gets passed to nfs4_do_unlck() from nfs4_lock_release(). So the type is
> still F_RDLCK or FWRLCK, not F_UNLCK. At some point, when cancelling the
> lock, the type needs to be changed to F_UNLCK. It seemed easiest to do
> that in nfs4_do_unlck(), but it could be done in nfs4_lock_release().
> The concern I had with doing it there was if something still needed the
> original file_lock, though it turns out the original file_lock still
> needs to be modified by nfs4_do_unlck() because nfs4_do_unlck() uses the
> original file_lock to pass to the vfs layer, and a copy of the original
> file_lock for the RPC request.
> 
> Frank

I see. It would be great if you could summarise the above (or just
including the above text in full would be fine too) in the changelog
entry for the patch. (Sorry sometimes the one-liner patches are the
hardest to justify :-))

Cheers
  Trond


-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
