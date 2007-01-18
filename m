From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH 12/14] SUNRPC: RPC buffer size estimates are too
	large
Date: Thu, 18 Jan 2007 18:49:56 -0500
Message-ID: <20070118234956.GC14242@fieldses.org>
References: <20070118232356.23310.6705.stgit@localhost.localdomain>
	<20070118233052.23310.25010.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: trond.myklybust@fys.uio.no, nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1H7h1V-00052G-Vb
	for nfs@lists.sourceforge.net; Thu, 18 Jan 2007 15:50:26 -0800
Received: from mail.fieldses.org ([66.93.2.214] helo=fieldses.org)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1H7h1B-0008Rs-1c
	for nfs@lists.sourceforge.net; Thu, 18 Jan 2007 15:50:06 -0800
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

On Thu, Jan 18, 2007 at 06:30:53PM -0500, Chuck Lever wrote:
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
> 
> And, we can finally be rid of RPC_SLACK_SPACE!

I'm a little worried about krb5, and especially the integrity and
privacy code--I don't think this accounts for the space they need.

I'm not sure how best to estimate their requirements....

--b.

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys - and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
