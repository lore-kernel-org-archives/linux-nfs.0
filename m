From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [PATCH 12/14] SUNRPC: RPC buffer size estimates are
	too	large
Date: Fri, 19 Jan 2007 18:12:31 -0500
Message-ID: <1169248351.6262.55.camel@lade.trondhjem.org>
References: <20070118232356.23310.6705.stgit@localhost.localdomain>
	<20070118233052.23310.25010.stgit@localhost.localdomain>
	<1169246214.6262.36.camel@lade.trondhjem.org>
	<45B14A46.4020508@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1H82ui-0006TN-Ts
	for nfs@lists.sourceforge.net; Fri, 19 Jan 2007 15:12:52 -0800
Received: from pat.uio.no ([129.240.10.15]
	ident=[U2FsdGVkX1/Z/ba4EelME7kEndoQYopnrzrw7SdJI5A=])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1H82uj-0004Kg-66
	for nfs@lists.sourceforge.net; Fri, 19 Jan 2007 15:12:54 -0800
To: chuck.lever@oracle.com
In-Reply-To: <45B14A46.4020508@oracle.com>
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

On Fri, 2007-01-19 at 17:46 -0500, Chuck Lever wrote:
> Trond Myklebust wrote:
> > On Thu, 2007-01-18 at 18:30 -0500, Chuck Lever wrote:
> >> The RPC buffer size estimation logic in net/sunrpc/clnt.c always
> >> significantly overestimates the requirements for the buffer size.
> >> A little instrumentation demonstrated that in fact rpc_malloc was never
> >> allocating the buffer from the mempool, but almost always called kmalloc.
> >>
> >> To compute the size of the RPC buffer more precisely, split p_bufsiz into
> >> two fields; one for the argument size, and one for the result size.  The
> >> goal is to keep the size requirement for RPC buffers at or below 2KiB.
> >>
> >> So now we will compute the sum of the exact call and reply header sizes,
> >> and split the RPC buffer precisely between the two.  That should keep all
> >> RPCs within the 2KiB buffer mempool limit.
> > 
> > How about adding a temporary BUG_ON() into call_allocate to ensure
> > task->tk_msg.rpc_proc->p_arglen is always non-zero. We also want to
> > check for non-zero values of task->tk_msg.rpc_proc->p_replen when
> > task->tk_msg.rpc_proc->p_decode is non-null.
> 
> Hmmm.  A sanity check is reasonable, but do we really want a runtime 
> check for values that are fixed at compile time?  I'm also not in love 
> with BUG_ON() -- maybe something like aborting the task and printing a 
> console warning would be less disruptive.

How is that less disruptive? A bug by any other name....

The point is just to make sure that all existing structures have been
converted and that we haven't missed anything. Feel free to queue up a
patch for the release after this patch has been merged in order to
remove it.

> > Finally, what is the purpose of req->rq_callsize and req->rq_rcvsize?
> > They don't appear to be used anywhere.
> 
> In my code, they are used in call_encode and xprt_release in addition to 
> call_allocate.  They basically replace rq_bufsize.

In that case, why not just add them in the patch that contains the code
that uses them?

Cheers,
  Trond


-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys - and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
