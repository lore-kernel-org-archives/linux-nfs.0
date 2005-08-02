From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH] Fix nfsd rewrite performance
Date: Tue, 2 Aug 2005 08:07:21 -0400
Message-ID: <20050802120721.GA5228@fieldses.org>
References: <20050801113954.GA8698@suse.de> <20050801115319.GD6497@fieldses.org> <20050801115922.GE8698@suse.de> <20050801121053.GA8238@fieldses.org> <20050801121422.GH8698@suse.de> <20050801125832.GB8598@fieldses.org> <20050802094950.GB29054@suse.de> <20050802100222.GA1940@fieldses.org> <20050802104904.GC29054@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DzvYa-00067j-Q0
	for nfs@lists.sourceforge.net; Tue, 02 Aug 2005 05:07:40 -0700
Received: from dsl093-002-214.det1.dsl.speakeasy.net ([66.93.2.214] helo=pickle.fieldses.org)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44)
	id 1DzvYa-0006Vd-FT
	for nfs@lists.sourceforge.net; Tue, 02 Aug 2005 05:07:40 -0700
To: Olaf Kirch <okir@suse.de>
In-Reply-To: <20050802104904.GC29054@suse.de>
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

On Tue, Aug 02, 2005 at 12:49:04PM +0200, Olaf Kirch wrote:
> On Tue, Aug 02, 2005 at 06:02:22AM -0400, J. Bruce Fields wrote:
> > Yeah.  So the simplest solution might be to make the other upcalls use
> > the same sort of deferral as the idmap upcalls, at least in the v4 case.
> > In the v3 case fh_verify always happens early enough not to be a
> > problem, I believe.
> > 
> > Though I still think it's unfortunate even for v3 that it will try to
> > copy (and allocate space for) the entire write request in the case of an
> > authentication- or export- related upcall.
> 
> I just looked at svc_defer in 2.6.12 and it seems it cannot handle
> more than one page of data anyway, and ditches anything else.

Oops, you're right.  Forcing the client to time out and retry there is
kind of unfortunate too, though.  A half hour of activity (to expire
entries from the export cache) followed by a write could trigger this.

--b.


-------------------------------------------------------
SF.Net email is sponsored by: Discover Easy Linux Migration Strategies
from IBM. Find simple to follow Roadmaps, straightforward articles,
informative Webcasts and more! Get everything you need to get up to
speed, fast. http://ads.osdn.com/?ad_id=7477&alloc_id=16492&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
