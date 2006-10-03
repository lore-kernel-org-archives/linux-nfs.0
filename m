From: Greg Banks <gnb@sgi.com>
Subject: Re: [PATCH 008 of 11] knfsd: Prepare knfsd for support of
	rsize/wsize of up to 1MB, over TCP.
Date: Tue, 3 Oct 2006 11:59:20 +1000
Message-ID: <20061003015920.GJ28796@sgi.com>
References: <20060824162917.3600.patches@notabene> <1060824063711.5008@suse.de>
	<20060925154316.GA17465@fieldses.org>
	<17697.48800.933642.581926@cse.unsw.edu.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
	nfs@lists.sourceforge.net, linux-kernel@vger.kernel.org
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GUZZG-0003K0-QZ
	for nfs@lists.sourceforge.net; Mon, 02 Oct 2006 18:59:35 -0700
Received: from omx2-ext.sgi.com ([192.48.171.19] helo=omx2.sgi.com)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1GUZZG-0002SA-HW
	for nfs@lists.sourceforge.net; Mon, 02 Oct 2006 18:59:35 -0700
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
> On Monday September 25, bfields@fieldses.org wrote:
> > 
> > We're reporting svc_max_payload(rqstp) as the server's maximum
> > read/write block size:
> 
> Yes.  So I'm going to change the number returned by
> svc_max_payload(rqstp) to mean the maximum read/write block size.
> i.e. when a service is created, the number passed isn't the maximum
> packet size, but is the maximum payload size.

I'm confused.  Last time I looked at the code that was
exactly what the semantics were?

> The assumption is that all of the request that is not payload will fit
> into one page, and all of the reply that is not payload will also fit
> into one page (though a different page).

This is a pretty good assumption for v3.

> It means that RPC services that have lots of non-payload data combined
> with payload data won't work, but making sunrpc code completely
> general when there are only two users is just too painful.
> 
> The only real problem is that NFSv4 can have arbitrarily large
> non-payload data, and arbitrarily many payloads.  But I guess any
> client that trying to send two full-sized payloads in the one request
> is asking for trouble (I don't suppose the RPC spells this out at
> all?).

Bruce and I briefly discussed this when I dropped into CITI the other
week.  The conclusion was that this is a non-issue in the short term
because all the clients do a single READ or WRITE per call.  In the
long term I hope to rewrite some parts of that code to do away with
one of the memcpy()s in the WRITE path, and handling multiple WRITEs
for v4 would be a natural extension of that.

Greg.
-- 
Greg Banks, R&D Software Engineer, SGI Australian Software Group.
I don't speak for SGI.

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys -- and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
