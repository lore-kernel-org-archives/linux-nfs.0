From: Greg Banks <gnb@sgi.com>
Subject: Re: ETIMEDOUT in nfsd?
Date: Wed, 4 Aug 2004 17:35:00 +1000
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20040804073500.GP5581@sgi.com>
References: <20040803081503.GM5581@sgi.com> <20040803191610.GC7781@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linux NFS Mailing List <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1BsGKX-0002A2-CR
	for nfs@lists.sourceforge.net; Wed, 04 Aug 2004 00:36:57 -0700
Received: from externalmx-1.sourceforge.net ([12.152.184.25])
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.34)
	id 1BsGKV-0000rb-Jw
	for nfs@lists.sourceforge.net; Wed, 04 Aug 2004 00:36:57 -0700
Received: from [192.48.171.19] (helo=omx2.sgi.com)
	by externalmx-1.sourceforge.net with esmtp (Exim 4.41)
	id 1BsGKT-0000xP-0S
	for nfs@lists.sourceforge.net; Wed, 04 Aug 2004 00:36:53 -0700
To: "J. Bruce Fields" <bfields@fieldses.org>
In-Reply-To: <20040803191610.GC7781@fieldses.org>
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

On Tue, Aug 03, 2004 at 03:16:10PM -0400, J. Bruce Fields wrote:
> On Tue, Aug 03, 2004 at 06:15:03PM +1000, Greg Banks wrote:
> > So I was somewhat surprised to see that in 2.6, the mapping from
> > Linux errno to NFS error in fs/nfsd/nfsproc.c:nfserrno() maps
> > -EAGAIN to nfserr_dropit, causing nfsd_dispatch to just drop the
> > call and not reply.  Furthermore I need to return the network
> > error -ETIMEDOUT to get NFSERR_JUKEBOX.  I don't get it...can
> > someone explain both of these?
> 
> The server does upcalls to userspace daemons (usually to mountd to get
> export options or IP address->client name mappings) by doing a lookup in
> a cache, and returning -EAGAIN if an upcall is required.

With, if I understand your document correctly, the side effect of
queuing an upcall which can be expected to fill the cache at some
later date depending on the action of the userspace daemon (and
its LDAP or NIS lookups or whatever).

> The request is
> then dropped, a copy of the request is made (see svcsock.c:svc_defer())
> and reprocessed at a later time (see svcsock.c:svc_revisit()).

Let me see if I understand this...the *NFS* request is silently dropped,
and the *sunrpc cache* request is remembered on the server machine and
sent upstairs later, presumably as the userspace daemon replies to
earlier upcalls.  The NFS client gets nothing...no reply and no
indication that it should retry the original NFS request.

So you're implicitly relying on the normal clientside timeout and
retry mechanism to get the NFS request resubmitted?  Why not send
EJUKEBOX to the client, and let it manage retry using a retry strategy
designed for a slow server instead of the one designed for lossy
networks?  Otherwise the exponential backoff could hurt the client's
latency more than it deserves.


Anyway, the problem I have is the use of EAGAIN.  The normal semantics
of EAGAIN are that the receiver should cause a retry of whatever it was
doing.  So if (say) nfsd_write() returned -EAGAIN it would make
sense to translate that into NFSERR_JUKEBOX which is designed to have
the same effect at the client.

This is what happens on an Altix with DMF installed: the DMF hooks
in the filesystem return EAGAIN when they need to pull a file in
from tape, and that percolates naturally through several layers to
be translated to NFSERR_JUKEBOX to the client.

http://www.sgi.com/products/storage/tech/dmf.html

That DMF code returns EAGAIN because it's been given O_NONBLOCK,
and that's the semantics of O_NONBLOCK: return EAGAIN if you can't
succeed without blocking.  This happens in code that's common to the
IRIX and Linux implementations of DMF.  In other words, there's a
whole body of history for using EAGAIN this way.

Instead you're using EAGAIN in another part of the code to indicate
that a cache entry has expired or is missing and that an upcall is
in progress and might succeed later, which then drives a completely
different retry strategy (with the client being kept in the dark).

We need to figure out how to resolve these two competing usages of
EAGAIN.

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
