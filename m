From: "Chuck Lever" <chucklever@gmail.com>
Subject: Re: cel's patches for 2.6.18 kernels
Date: Thu, 21 Sep 2006 10:50:51 -0400
Message-ID: <76bd70e30609210750s5c8b943cg267513c64dc0433f@mail.gmail.com>
References: <76bd70e30609201128r9188a17i51b779c6e1b569fc@mail.gmail.com>
	<20060920202010.GA22954@infradead.org>
	<76bd70e30609201353l7d8c063fp94916c509b08b24e@mail.gmail.com>
	<1158787006.5639.19.camel@lade.trondhjem.org>
	<76bd70e30609201929s1e01b453ia694774d77f9474c@mail.gmail.com>
	<451284E4.4050806@RedHat.com>
	<1158846435.7626.7.camel@lade.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Linux NFS Mailing List <nfs@lists.sourceforge.net>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GQPtD-0004xi-1Q
	for nfs@lists.sourceforge.net; Thu, 21 Sep 2006 07:50:59 -0700
Received: from wx-out-0506.google.com ([66.249.82.228])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1GQPtB-00083N-Fd
	for nfs@lists.sourceforge.net; Thu, 21 Sep 2006 07:50:59 -0700
Received: by wx-out-0506.google.com with SMTP id r21so804955wxc
	for <nfs@lists.sourceforge.net>; Thu, 21 Sep 2006 07:50:52 -0700 (PDT)
To: "Trond Myklebust" <trond.myklebust@fys.uio.no>
In-Reply-To: <1158846435.7626.7.camel@lade.trondhjem.org>
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

On 9/21/06, Trond Myklebust <trond.myklebust@fys.uio.no> wrote:
> On Thu, 2006-09-21 at 08:26 -0400, Steve Dickson wrote:
> >
> > Chuck Lever wrote:
> > > No slot table means we can dynamically increase and decrease the
> > > number of concurrent RPC requests per transport -- which is a
> > > pre-requisite for scalability when all mounts to the same server use
> > > the same transport.  I don't relish the idea of a hundred mount points
> > > on a client that are only allowed to start 16 total requests at a
> > > time.
> > >
> > I think this is a very good thing... not having a hard code slot table
> > make things much more scalable... imho...
>
> I'd like to see _lots_ of testing in a low-memory environment before I'm
> ready to fully subscribe to that opinion.

The current behavior is that the VM dumps a boat load of writes on the
NFS client, and they all queue up on the RPC client's backlog queue.
In the new code, each request is allowed to proceed further to the
allocation of an RPC buffer before it is stopped.  The buffers come
out of a slab cache, so low-memory behavior should be fairly
reasonable.

The small slot table size already throttles write-intensive workloads
and anything that tries to drive concurrent I/O.  To add an additional
constraint that multiple mount point go through a small fixed size
slot table seems like poor design.

Perhaps we can add a per-mount point concurrency limit instead of a
per-transport limit?

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
