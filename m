From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH 008 of 11] knfsd: Prepare knfsd for support
	of	rsize/wsize of up to 1MB, over TCP.
Date: Mon, 2 Oct 2006 22:13:04 -0400
Message-ID: <20061003021304.GB12867@fieldses.org>
References: <20060824162917.3600.patches@notabene> <1060824063711.5008@suse.de>
	<20060925154316.GA17465@fieldses.org>
	<17697.48800.933642.581926@cse.unsw.edu.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net, linux-kernel@vger.kernel.org,
	Greg Banks <gnb@melbourne.sgi.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GUZmM-0004Qw-T7
	for nfs@lists.sourceforge.net; Mon, 02 Oct 2006 19:13:07 -0700
Received: from mail.fieldses.org ([66.93.2.214] helo=pickle.fieldses.org)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1GUZmM-0005Cb-E5
	for nfs@lists.sourceforge.net; Mon, 02 Oct 2006 19:13:07 -0700
To: Neil Brown <neilb@suse.de>
In-Reply-To: <17697.48800.933642.581926@cse.unsw.edu.au>
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

On Tue, Oct 03, 2006 at 11:36:32AM +1000, Neil Brown wrote:
> The only real problem is that NFSv4 can have arbitrarily large
> non-payload data, and arbitrarily many payloads.  But I guess any
> client that trying to send two full-sized payloads in the one request
> is asking for trouble (I don't suppose the RPC spells this out at
> all?).

The RFC?  Well, it does have a "RESOURCE" error that the server can
return for overly complicated compounds.  It doesn't give much guidance
on when exactly that could happen, but if there's ever a clear case for
returning NFS4ERR_RESOURCE, I think it must be the case of a client
trying to circumvent the maximum read/write size by using multiple read
or write operations in a single compound.

(We have some other odd restrictions on the sorts of compounds we can
accept, which I'd like to relax.  But that's a problem for another day.)

> And the fact that the code change to effect this is so tiny seems to
> imply that most of the code was already assuming that sv_bufsz was
> really the payload size rather than the packet size.

There's also the check at the end of svc_tcp_recvfrom():

	if (svsk->sk_reclen > serv->sv_bufsz) {
		printk(KERN_NOTICE "RPC: bad TCP reclen 0x%08lx (large)\n",
		       (unsigned long) svsk->sk_reclen);
		goto err_delete;
	}

--b.

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys -- and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
