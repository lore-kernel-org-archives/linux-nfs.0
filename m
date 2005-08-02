From: Olaf Kirch <okir@suse.de>
Subject: Re: [PATCH] Fix nfsd rewrite performance
Date: Tue, 2 Aug 2005 11:49:50 +0200
Message-ID: <20050802094950.GB29054@suse.de>
References: <20050801113954.GA8698@suse.de> <20050801115319.GD6497@fieldses.org> <20050801115922.GE8698@suse.de> <20050801121053.GA8238@fieldses.org> <20050801121422.GH8698@suse.de> <20050801125832.GB8598@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DztPI-0001ID-D8
	for nfs@lists.sourceforge.net; Tue, 02 Aug 2005 02:49:56 -0700
Received: from cantor.suse.de ([195.135.220.2] helo=mx1.suse.de)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44)
	id 1DztPH-0000LZ-6j
	for nfs@lists.sourceforge.net; Tue, 02 Aug 2005 02:49:56 -0700
To: "J. Bruce Fields" <bfields@fieldses.org>
In-Reply-To: <20050801125832.GB8598@fieldses.org>
Sender: nfs-admin@lists.sourceforge.net
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

On Mon, Aug 01, 2005 at 08:58:32AM -0400, J. Bruce Fields wrote:
> There's a different problem, though, with the request deferral stuff.
> It waits for upcalls by aborting request processing, saving a copy of
> the raw request data, then processing it from scratch again when the
> upcall response comes.

I just looked at the code, and there are two types of deferrals.
One is for authentication stuff - this will actually use svc_defer and
svc_revisit, which goes back to look at the entire request.

The other type is what hte nfs4idmap stuff does, which uses its own
defer/revisit routines, which just make the nfsd thread wait.

So neither poses a problem to munging the iovec in nfsd_write: The
authentication stuff will happen when we parse the RPC header, which is
way before we decide to call nfsd_write.  The idmap stuff may be called
after processing a write call, but it will not go back to revisit the
entire request, it will just stall briefly while idmapd is doing its job.
Correct?

In general, I believe it does not make sense to call svc_defer once we've
started to process a request, because the request may not be idempotent.
It sounds like a reasonable assumption to me that deferring and revisiting
an entire requests is only done before we hit the RPC program handler.

Olaf
-- 
Olaf Kirch   |  --- o --- Nous sommes du soleil we love when we play
okir@suse.de |    / | \   sol.dhoop.naytheet.ah kin.ir.samse.qurax


-------------------------------------------------------
SF.Net email is sponsored by: Discover Easy Linux Migration Strategies
from IBM. Find simple to follow Roadmaps, straightforward articles,
informative Webcasts and more! Get everything you need to get up to
speed, fast. http://ads.osdn.com/?ad_id=7477&alloc_id=16492&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
