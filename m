From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [PATCH 12/14] SUNRPC: RPC buffer size estimates are
	too	large
Date: Fri, 19 Jan 2007 17:36:54 -0500
Message-ID: <1169246214.6262.36.camel@lade.trondhjem.org>
References: <20070118232356.23310.6705.stgit@localhost.localdomain>
	<20070118233052.23310.25010.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1H82MD-0002zj-SA
	for nfs@lists.sourceforge.net; Fri, 19 Jan 2007 14:37:14 -0800
Received: from pat.uio.no ([129.240.10.15]
	ident=[U2FsdGVkX1/2tZHj2dBkp4u7fd+yrrvQ3bg3nJ3o7is=])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1H82ME-0008Gd-2a
	for nfs@lists.sourceforge.net; Fri, 19 Jan 2007 14:37:14 -0800
To: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <20070118233052.23310.25010.stgit@localhost.localdomain>
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

On Thu, 2007-01-18 at 18:30 -0500, Chuck Lever wrote:
> The RPC buffer size estimation logic in net/sunrpc/clnt.c always
> significantly overestimates the requirements for the buffer size.
> A little instrumentation demonstrated that in fact rpc_malloc was never
> allocating the buffer from the mempool, but almost always called kmalloc.
> 
> To compute the size of the RPC buffer more precisely, split p_bufsiz into
> two fields; one for the argument size, and one for the result size.  The
> goal is to keep the size requirement for RPC buffers at or below 2KiB.
> 
> So now we will compute the sum of the exact call and reply header sizes,
> and split the RPC buffer precisely between the two.  That should keep all
> RPCs within the 2KiB buffer mempool limit.

How about adding a temporary BUG_ON() into call_allocate to ensure
task->tk_msg.rpc_proc->p_arglen is always non-zero. We also want to
check for non-zero values of task->tk_msg.rpc_proc->p_replen when
task->tk_msg.rpc_proc->p_decode is non-null.

Finally, what is the purpose of req->rq_callsize and req->rq_rcvsize?
They don't appear to be used anywhere.




-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys - and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
