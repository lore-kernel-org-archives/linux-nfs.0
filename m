From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: cel's patches for 2.6.18 kernels
Date: Thu, 21 Sep 2006 13:33:03 -0400
Message-ID: <1158859983.5441.48.camel@lade.trondhjem.org>
References: <76bd70e30609201128r9188a17i51b779c6e1b569fc@mail.gmail.com>
	<20060920202010.GA22954@infradead.org>
	<76bd70e30609201353l7d8c063fp94916c509b08b24e@mail.gmail.com>
	<1158787006.5639.19.camel@lade.trondhjem.org>
	<76bd70e30609201929s1e01b453ia694774d77f9474c@mail.gmail.com>
	<451284E4.4050806@RedHat.com>
	<1158846435.7626.7.camel@lade.trondhjem.org>
	<76bd70e30609210750s5c8b943cg267513c64dc0433f@mail.gmail.com>
	<1158851176.5441.17.camel@lade.trondhjem.org>
	<76bd70e30609210851h71b48c28ka2b283bd5842afd5@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Linux NFS Mailing List <nfs@lists.sourceforge.net>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GQSQK-0005c3-Ie
	for nfs@lists.sourceforge.net; Thu, 21 Sep 2006 10:33:20 -0700
Received: from pat.uio.no ([129.240.10.4])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1GQSQK-0007gE-RV
	for nfs@lists.sourceforge.net; Thu, 21 Sep 2006 10:33:21 -0700
To: Chuck Lever <chucklever@gmail.com>
In-Reply-To: <76bd70e30609210851h71b48c28ka2b283bd5842afd5@mail.gmail.com>
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

On Thu, 2006-09-21 at 11:51 -0400, Chuck Lever wrote:
> I didn't say "immune".  Slabs improve low-memory behavior.  They limit
> the amount of internal memory fragmentation, and provide a clean and
> automatic API for reaping unused memory when the system has passed its
> low-memory threshold.

So does kmalloc, which is built on a set of slabs. The main difference
between the two is that slabs tend to be limited to one task at hand.

> Even when a mount point is totally idle and the connection has timed
> out, the slot table is still there.  It's a large piece of memory,
> usually a page or more.  With these patches, that memory usage is
> eliminated when a transport is idle, and can be reclaimed if needed.

We'd usually prefer that the VM reclaim dirty pages first.

> > > The small slot table size already throttles write-intensive workloads
> > > and anything that tries to drive concurrent I/O.  To add an additional
> > > constraint that multiple mount point go through a small fixed size
> > > slot table seems like poor design.
> >
> > Its main purpose is precisely that of _limiting_ the amount of RPC
> > buffer usage, and hence avoiding yet another potential source of memory
> > deadlocks.
> 
> [ I might point out that this is not documented anywhere.  But that's
> an aside. ]
> 
> We are getting ahead of ourselves.  The patches I wrote do not remove
> the limit, they merely change it from a hard architectural limit to a
> virtual limit.
> 
> BUT THE LIMIT STILL EXISTS, and defaults to 16 requests, just as before.

As I've said before, that is intentional.

> If the limit is exceeded, no RPC buffer is allocated, and tasks are
> queued on the backlog queue, just as before.  So the low-memory
> behavior characteristics of the patches should be exactly the same or
> somewhat better than before.

No. They will differ, because your RPC queue can now eat unlimited
amounts of memory.

> The point is to allow more flexibility.  You can now change the limit
> on the fly, while the transport is in use.  This change is a
> pre-requisite to allowing the client to tune itself as more mount
> points use a single transport.  Instead of a dumb fixed limit, we can
> now think about a flexible dynamic limit that can allow greater
> concurrency when resources are available.
> 
> I might also point out that the *real* limiter of memory usage is the
> kmalloc in rpc_malloc.  If it fails, call_allocate will delay and
> loop.  This has nothing to do with the slot table size, and suggests
> that the slot table size limit is totally arbitrary.

Correct. The real limiter is the kmalloc, and that is why we don't want
to allow arbitrary slot sizes. We do not want the RPC layer to eat
unlimited gobs of memory.

> > There is already a mechanism in place for allowing the user to fiddle
> > with the limits,
> 
> Why should any user care about setting this limit?  The client should
> be able to regulate itself to make optimal use of the available
> resources.  Hand-tuning this limit is simply a work around.

Remind me why _you_ lobbied for the ability to do this?




-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys -- and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
