From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH 12/14] SUNRPC: RPC buffer size estimates are too
	large
Date: Thu, 18 Jan 2007 19:00:52 -0500
Message-ID: <20070119000052.GD14242@fieldses.org>
References: <20070118232356.23310.6705.stgit@localhost.localdomain>
	<20070118233052.23310.25010.stgit@localhost.localdomain>
	<20070118234956.GC14242@fieldses.org> <45B008C8.6080601@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: trond.myklybust@fys.uio.no, nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1H7hBg-0006Ak-Er
	for nfs@lists.sourceforge.net; Thu, 18 Jan 2007 16:00:56 -0800
Received: from mail.fieldses.org ([66.93.2.214] helo=fieldses.org)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1H7hBh-0003bk-1c
	for nfs@lists.sourceforge.net; Thu, 18 Jan 2007 16:00:58 -0800
To: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <45B008C8.6080601@oracle.com>
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

On Thu, Jan 18, 2007 at 06:54:48PM -0500, Chuck Lever wrote:
> J. Bruce Fields wrote:
> >I'm a little worried about krb5, and especially the integrity and
> >privacy code--I don't think this accounts for the space they need.
> >
> >I'm not sure how best to estimate their requirements....
> 
> If the RPC header field size definitions are correct, the verifiers are 
> defined as 400 bytes (100 quads).  There should be room enough for the 
> largest verifiers.

OK, so your code always assumes the worst case for the verifier?

The problem is that integrity protection also adds another 8 bytes
(length and sequence number) to the body of each rpc, and privacy in
addition adds some variable amount of mechanism-specific encryption
overhead (a few tens of bytes for krb5, I think).

But if you're always allowing 400 bytes for the verifier then in
practice we're not going to have any problems with the current
mechanisms.

--b.

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys - and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
