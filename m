From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: ETIMEDOUT in nfsd?
Date: Tue, 3 Aug 2004 15:16:10 -0400
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20040803191610.GC7781@fieldses.org>
References: <20040803081503.GM5581@sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Neil Brown <neilb@cse.unsw.edu.au>,
	Linux NFS Mailing List <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1Bs4lr-00071I-62
	for nfs@lists.sourceforge.net; Tue, 03 Aug 2004 12:16:23 -0700
Received: from dsl093-002-214.det1.dsl.speakeasy.net ([66.93.2.214] helo=pickle.fieldses.org)
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:RC4-SHA:128)
	(Exim 4.34)
	id 1Bs4lq-0006Di-LP
	for nfs@lists.sourceforge.net; Tue, 03 Aug 2004 12:16:23 -0700
To: Greg Banks <gnb@sgi.com>
In-Reply-To: <20040803081503.GM5581@sgi.com>
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

On Tue, Aug 03, 2004 at 06:15:03PM +1000, Greg Banks wrote:
> So I was somewhat surprised to see that in 2.6, the mapping from
> Linux errno to NFS error in fs/nfsd/nfsproc.c:nfserrno() maps
> -EAGAIN to nfserr_dropit, causing nfsd_dispatch to just drop the
> call and not reply.  Furthermore I need to return the network
> error -ETIMEDOUT to get NFSERR_JUKEBOX.  I don't get it...can
> someone explain both of these?

The server does upcalls to userspace daemons (usually to mountd to get
export options or IP address->client name mappings) by doing a lookup in
a cache, and returning -EAGAIN if an upcall is required.  The request is
then dropped, a copy of the request is made (see svcsock.c:svc_defer())
and reprocessed at a later time (see svcsock.c:svc_revisit()).

I have some rough notes on all this at

http://www.fieldses.org/~bfields/kernel/svc_caches/sunrpc_svc_cache.txt

and Neil has some documentation in Documentation/sunrpc-cache.txt.

--Bruce Fields


-------------------------------------------------------
This SF.Net email is sponsored by OSTG. Have you noticed the changes on
Linux.com, ITManagersJournal and NewsForge in the past few weeks? Now,
one more big change to announce. We are now OSTG- Open Source Technology
Group. Come see the changes on the new OSTG site. www.ostg.com
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
