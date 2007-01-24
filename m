From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH 13/15] SUNRPC: RPC buffer size estimates are too
	large
Date: Wed, 24 Jan 2007 16:25:01 -0500
Message-ID: <20070124212501.GG6587@fieldses.org>
References: <20070124191704.31133.12713.stgit@localhost.localdomain>
	<20070124192020.31133.78494.stgit@localhost.localdomain>
	<20070124203739.GA6587@fieldses.org> <45B7C482.9090807@oracle.com>
	<20070124205134.GC6587@fieldses.org> <45B7CB0A.5040505@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net, trond.myklebust@fys.uio.no
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1H9pc9-0005Pt-P7
	for nfs@lists.sourceforge.net; Wed, 24 Jan 2007 13:25:05 -0800
Received: from mail.fieldses.org ([66.93.2.214] helo=fieldses.org)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1H9pcA-0007Ge-D3
	for nfs@lists.sourceforge.net; Wed, 24 Jan 2007 13:25:07 -0800
In-Reply-To: <45B7CB0A.5040505@oracle.com>
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

On Wed, Jan 24, 2007 at 04:09:30PM -0500, Chuck Lever wrote:
> These values are just for estimating the largest size the buffers will 
> need to be for this call and reply.  Alignment issues need to be handled 
>  somewhere else.

OK, I'm an idiot--so cslack is just for calculating the maximum size,
rslack is for placing the data correctly.  So now I understand what
you're doing, and don't see any more problem with it.

> >This is padding at a different level--the plaintext usually has to be
> >padded to the nearest block size (at least 8 bytes) before encryption.
> 
> That doesn't sound like XDR at all.  I don't see how RPC buffer 
> allocation could be concerned about this...

The encrypted data is encapsulated in xdr and the RPC buffers need to be
large enough to hold them.

But all we need to do is make gss's au_cslack value big enough for the
worst case and we're fine, OK.

--b.

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys - and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
