From: Greg Banks <gnb@sgi.com>
Subject: Re: ETIMEDOUT in nfsd?
Date: Fri, 6 Aug 2004 10:50:50 +1000
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20040806005050.GX5581@sgi.com>
References: <20040803081503.GM5581@sgi.com> <20040803191610.GC7781@fieldses.org> <20040804073500.GP5581@sgi.com> <20040804141346.GA19282@fieldses.org> <20040805022608.GR5581@sgi.com> <20040805142159.GB25948@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linux NFS Mailing List <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1Bst4F-0001v5-My
	for nfs@lists.sourceforge.net; Thu, 05 Aug 2004 17:58:43 -0700
Received: from omx2-ext.sgi.com ([192.48.171.19] helo=omx2.sgi.com)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.34)
	id 1Bst4F-0007MH-8u
	for nfs@lists.sourceforge.net; Thu, 05 Aug 2004 17:58:43 -0700
To: "J. Bruce Fields" <bfields@fieldses.org>
In-Reply-To: <20040805142159.GB25948@fieldses.org>
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

On Thu, Aug 05, 2004 at 10:21:59AM -0400, J. Bruce Fields wrote:
> On Thu, Aug 05, 2004 at 12:26:08PM +1000, Greg Banks wrote:
> > On Wed, Aug 04, 2004 at 10:13:46AM -0400, J. Bruce Fields wrote:
> > > This is only right if upcalls are done before you've done anything
> > > non-idempotent, which makes it hard to handle NFSv4 compounds
> > > correctly.
> > 
> > Ouch, this is not a good assumption, especially considering servers
> > rebooting and cache timeouts.
> 
> I don't see the problem you're referring to.  I don't believe that in
> either case these internal replays add any problems that we don't
> already have, but perhaps I'm missing something.

Perhaps I misunderstood your sentence...did you instead mean the
assumption is that nothing non-idempotent happens *between* when the
cache is missed and an upcall enqueued, and when the upcall completes?
I was thinking something different...

Perhaps that still sound like a problem.  For example, imagine a test
where two clients both try to create a file (typical file locking
strategy e.g. for mail clients) and one of them sends creds which
miss the cache and need an upcall and the other's creds hit the
cache.  Does that cache-missing client always lose the race
gracefully?  Does something unpleasant happen with the file?

> > > > Why not send EJUKEBOX to the client, and let it manage retry using a
> > > > retry strategy designed for a slow server instead of the one designed
> > > > for lossy networks?
> > > 
> > > That might mean returning EJUKEBOX on a lot of common operations (e.g.
> > > on the first rpc request from a new client), when the server usually
> > > could have replied very quickly.
> > 
> > Potentially.  But, in your experience do idmapper upcalls proceed quickly?
> 
> It's a good question; it would be interesting to measure them sometime
> with a variety of different configurations (local /etc/passwd, ldap,
> etc.), but we haven't gotten around to that yet.

You might want to look into what happens when the userspace daemon
does a query to an LDAP server which is very slow, e.g. multiple
seconds delay.  There was some unpleasantness in situations like
this when upcalls to rpc.mountd which involved mountd doing reverse
DNS lookups, were added to IRIX a few releases ago.  One of the results
was that mountd needed to become multithreaded.  The lesson from
that was to assume that upcalls are going to take more time than
you want them to, and have a sensible strategy with timeouts and
parallelism.

Greg.
-- 
Greg Banks, R&D Software Engineer, SGI Australian Software Group.
I don't speak for SGI.


-------------------------------------------------------
This SF.Net email is sponsored by OSTG. Have you noticed the changes on
Linux.com, ITManagersJournal and NewsForge in the past few weeks? Now,
one more big change to announce. We are now OSTG- Open Source Technology
Group. Come see the changes on the new OSTG site. www.ostg.com
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
