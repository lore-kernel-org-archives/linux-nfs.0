From: "Chuck Lever" <chucklever@gmail.com>
Subject: Re: cel's patches for 2.6.18 kernels
Date: Wed, 20 Sep 2006 22:29:17 -0400
Message-ID: <76bd70e30609201929s1e01b453ia694774d77f9474c@mail.gmail.com>
References: <76bd70e30609201128r9188a17i51b779c6e1b569fc@mail.gmail.com>
	<20060920202010.GA22954@infradead.org>
	<76bd70e30609201353l7d8c063fp94916c509b08b24e@mail.gmail.com>
	<1158787006.5639.19.camel@lade.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Christoph Hellwig <hch@infradead.org>,
	Linux NFS Mailing List <nfs@lists.sourceforge.net>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GQEJQ-0008A8-Nc
	for nfs@lists.sourceforge.net; Wed, 20 Sep 2006 19:29:17 -0700
Received: from wx-out-0506.google.com ([66.249.82.233])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1GQEJR-0001aB-C2
	for nfs@lists.sourceforge.net; Wed, 20 Sep 2006 19:29:17 -0700
Received: by wx-out-0506.google.com with SMTP id r21so577859wxc
	for <nfs@lists.sourceforge.net>; Wed, 20 Sep 2006 19:29:17 -0700 (PDT)
To: "Trond Myklebust" <trond.myklebust@fys.uio.no>
In-Reply-To: <1158787006.5639.19.camel@lade.trondhjem.org>
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

On 9/20/06, Trond Myklebust <trond.myklebust@fys.uio.no> wrote:
> On Wed, 2006-09-20 at 16:53 -0400, Chuck Lever wrote:
> > On 9/20/06, Christoph Hellwig <hch@infradead.org> wrote:
> > > What's the merge plan for those patches?  The transport switch and ipv6
> > > code is eagerly anticipated by many people.
> >
> > About two thirds of the RPC transport switch is already in.
> > Twenty-ish more patches are going in 2.6.19.  There remain roughly 30
> > more patches that I need to walk through with Trond, and we can
> > probably get those into 2.6.20.  I wouldn't mind moving them up, but
> > that's up to Trond.
> >
> > The IPv6 stuff is still being finished.  Olaf may be able to help with
> > the NLM parts; Bull is still working through the NFS server parts; I'm
> > trying to act as integrator.  I would like to line up some testers.  I
> > think those may be as far out as three or four releases, but progress
> > is occurring -- note there are a lot more IPv6 patches in this
> > patchset than there were in 2.6.17's.
>
> What are the prospects for the server side?

About half of that work was already done to support NFSv4 callbacks,
and so it is contained in my patch set already.  The NFS
server-specific patches are still in Aurelien's hands, so I don't
know.  NLM hasn't been touched yet, but Olaf has been thinking about
it.

> > The RPC slot table patches are completely rewritten in this release.
> > That will probably need some testing and review.
>
> Could you remind me again why we are so keen to get rid of the RPC slot
> table?

I implemented from scratch using your suggestions.  Basically the
rpc_rqst is carved out of the RPC buffer instead of out of a large
tied down piece of storage.

No slot table means we can dynamically increase and decrease the
number of concurrent RPC requests per transport -- which is a
pre-requisite for scalability when all mounts to the same server use
the same transport.  I don't relish the idea of a hundred mount points
on a client that are only allowed to start 16 total requests at a
time.

-- 
"We who cut mere stones must always be envisioning cathedrals"
   -- Quarry worker's creed

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys -- and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
