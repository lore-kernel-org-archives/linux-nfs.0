From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH 13/15] SUNRPC: RPC buffer size estimates are too
	large
Date: Wed, 24 Jan 2007 15:51:34 -0500
Message-ID: <20070124205134.GC6587@fieldses.org>
References: <20070124191704.31133.12713.stgit@localhost.localdomain>
	<20070124192020.31133.78494.stgit@localhost.localdomain>
	<20070124203739.GA6587@fieldses.org> <45B7C482.9090807@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net, trond.myklebust@fys.uio.no
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1H9p5k-00027F-1A
	for nfs@lists.sourceforge.net; Wed, 24 Jan 2007 12:51:36 -0800
Received: from mail.fieldses.org ([66.93.2.214] helo=fieldses.org)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1H9p5k-0002Ir-LI
	for nfs@lists.sourceforge.net; Wed, 24 Jan 2007 12:51:38 -0800
In-Reply-To: <45B7C482.9090807@oracle.com>
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

On Wed, Jan 24, 2007 at 03:41:38PM -0500, Chuck Lever wrote:
> J. Bruce Fields wrote:
> >On Wed, Jan 24, 2007 at 02:20:20PM -0500, Chuck Lever wrote:
> >>+ 	req->rq_callsize = RPC_CALLHDRSIZE + (slack << 1) + proc->p_arglen;
> >>+ 	req->rq_callsize <<= 2;
> >>+ 	req->rq_rcvsize = RPC_REPHDRSIZE + slack + proc->p_replen;
> >>+ 	req->rq_rcvsize <<= 2;
> >
> >What happened to rslack?  The callsize calculation should be using
> >cslack and the rcvsize calculation rslack, I think, right?
> 
> As far as I understood it, cslack is the size of the authentication 
> verifier for that flavor.  Shouldn't that be the same for calls and replies?

No--it can even vary from one call or reply to the next, and we can't
necessarily exactly predict the size of the reply verifier (though we
should be able to give a fairly tight upper bound).  Also the call has a
credential in addition to the verifier, and the credential size also
depends on the security flavor.

> >In the krb5p case there's an extra annoyance: rslack is used to decide
> >where to expect page data to start, so it can only take into account
> >extra space needed at the beginning.  But krb5p has to add padding, for
> >example, to the end of each request.
> 
> That padding has to follow XDR rules, though, correct?

This is padding at a different level--the plaintext usually has to be
padded to the nearest block size (at least 8 bytes) before encryption.

--b.

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys - and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
