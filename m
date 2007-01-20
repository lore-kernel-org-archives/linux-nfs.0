From: Christoph Hellwig <hch@infradead.org>
Subject: Re: Eliminating the BKL from the NFS and RPC clients
Date: Sat, 20 Jan 2007 09:33:14 +0000
Message-ID: <20070120093314.GA29643@infradead.org>
References: <45B00585.10001@oracle.com> <20070119012349.GA25491@infradead.org>
	<1169184980.6158.19.camel@lade.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Christoph Hellwig <hch@infradead.org>, nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1H8CbW-00024R-8U
	for nfs@lists.sourceforge.net; Sat, 20 Jan 2007 01:33:42 -0800
Received: from pentafluge.infradead.org ([213.146.154.40])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1H8CbW-0007kx-RK
	for nfs@lists.sourceforge.net; Sat, 20 Jan 2007 01:33:44 -0800
To: Trond Myklebust <trond.myklebust@fys.uio.no>
In-Reply-To: <1169184980.6158.19.camel@lade.trondhjem.org>
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

On Fri, Jan 19, 2007 at 12:36:20AM -0500, Trond Myklebust wrote:
> No. Attributes may change at any moment on the server. That is _very_
> different to the case where the user or the client changes the
> attributes via setattr. For one thing, we don't have to notify the
> server. Secondly, we do want to be able to update those attributes from
> asynchronous contexts (for instance when a WRITE request returns with
> updated).
> The client should in any case _never_ be overriding the server
> attributes. The only exception to that rule is if we have cached writes
> which change the file size. We do try to detect that...

Sorry, my previous mail wasn't clear enough on how I want setattr
used here.  I think it's right to make all these attribute updates through
->setattr so filesystem can deal with them explicitly.  Of course we'd
still need to treat explicit updates different from implicit one,
probably by adding in ATTR_IMPLIZIT for the later.

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys - and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
