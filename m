From: Neil Brown <neilb@cse.unsw.edu.au>
Subject: Re: [PATCH][RFC] Multiple UDP sockets for knfsd
Date: Sun, 16 May 2004 08:24:31 +1000
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <16550.39071.745015.438121@cse.unsw.edu.au>
References: <40A42DB8.7B9C8152@melbourne.sgi.com>
	<1084566110.4237.66.camel@lade.trondhjem.org>
	<20040515063854.GB14983@sgi.com>
	<1084641723.3490.13.camel@lade.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Greg Banks <gnb@sgi.com>,
    Linux NFS Mailing List <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1BP7aY-0000KQ-ED
	for nfs@lists.sourceforge.net; Sat, 15 May 2004 15:25:02 -0700
Received: from note.orchestra.cse.unsw.edu.au ([129.94.242.24] ident=root)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.30)
	id 1BP7aX-0001aU-WE
	for nfs@lists.sourceforge.net; Sat, 15 May 2004 15:25:02 -0700
Received: From
	notabene.cse.unsw.edu.au ([129.94.241.7] == ppp2-007.ppp2.cse.unsw.EDU.AU) (auth-user neilb)
	(for <trond.myklebust@fys.uio.no>) (for <gnb@sgi.com>)
	(for <nfs@lists.sourceforge.net>) By note With Smtp ;
	Sun, 16 May 2004 08:24:47 +1000
To: Trond Myklebust <trond.myklebust@fys.uio.no>
In-Reply-To: message from Trond Myklebust on Saturday May 15
Errors-To: nfs-admin@lists.sourceforge.net
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

On Saturday May 15, trond.myklebust@fys.uio.no wrote:
> On Sat, 2004-05-15 at 02:38, Greg Banks wrote:
> > On Fri, May 14, 2004 at 04:21:50PM -0400, Trond Myklebust wrote:
> > > 
> > > I'm confused here. Are you actually implying that socket contention is
> > > responsible for a full *40%* decrease in throughput?
> > 
> > At that level of throughput, yes.
> 
> So what exactly *is* this bottleneck? As far as we're concerned, a
> socket is basically just a buffer and a couple of locks.
> 

It is almost certainly svsk->sk_sem.  We hold this while calling
sock->ops->sendpage  on each individual page of the reply - we don't
want them mixed up with some other reply.

Remember that the test here involves lots of large READ requests.
Each will have a few pages (this is an ia64 with large pages, so there
will probably be only one or two pages or page-fragments of data) what
will need to be fragmented into multiple UDP packets.

NeilBrown


-------------------------------------------------------
This SF.Net email is sponsored by: SourceForge.net Broadband
Sign-up now for SourceForge Broadband and get the fastest
6.0/768 connection for only $19.95/mo for the first 3 months!
http://ads.osdn.com/?ad_id=2562&alloc_id=6184&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
