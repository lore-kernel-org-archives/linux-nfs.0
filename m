From: "Chuck Lever" <chucklever@gmail.com>
Subject: Re: cel's patches for 2.6.18 kernels
Date: Wed, 20 Sep 2006 16:53:06 -0400
Message-ID: <76bd70e30609201353l7d8c063fp94916c509b08b24e@mail.gmail.com>
References: <76bd70e30609201128r9188a17i51b779c6e1b569fc@mail.gmail.com>
	<20060920202010.GA22954@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Linux NFS Mailing List <nfs@lists.sourceforge.net>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GQ94A-00052J-2c
	for nfs@lists.sourceforge.net; Wed, 20 Sep 2006 13:53:10 -0700
Received: from wx-out-0506.google.com ([66.249.82.226])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1GQ94A-0007wL-Or
	for nfs@lists.sourceforge.net; Wed, 20 Sep 2006 13:53:11 -0700
Received: by wx-out-0506.google.com with SMTP id r21so464104wxc
	for <nfs@lists.sourceforge.net>; Wed, 20 Sep 2006 13:53:07 -0700 (PDT)
To: "Christoph Hellwig" <hch@infradead.org>
In-Reply-To: <20060920202010.GA22954@infradead.org>
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

On 9/20/06, Christoph Hellwig <hch@infradead.org> wrote:
> On Wed, Sep 20, 2006 at 02:28:10PM -0400, Chuck Lever wrote:
> > This e-mail announces the release of cel's patch set for Linux 2.6.18
> > kernels.  The patchset contains several important features, including:
> >
> > 1.  The finishing patches for the RPC client transport switch
> >
> > 2.  Support for rpcbind protocol versions 2 and 3
> >
> > 3.  Some support for IPv6 in the RPC and NFS clients
> >
> > 4.  Elimination of the BKL in the RPC and NFS clients
> >
> > 5.  Elimination of the RPC slot table
>
> What's the merge plan for those patches?  The transport switch and ipv6
> code is eagerly anticipated by many people.

About two thirds of the RPC transport switch is already in.
Twenty-ish more patches are going in 2.6.19.  There remain roughly 30
more patches that I need to walk through with Trond, and we can
probably get those into 2.6.20.  I wouldn't mind moving them up, but
that's up to Trond.

The IPv6 stuff is still being finished.  Olaf may be able to help with
the NLM parts; Bull is still working through the NFS server parts; I'm
trying to act as integrator.  I would like to line up some testers.  I
think those may be as far out as three or four releases, but progress
is occurring -- note there are a lot more IPv6 patches in this
patchset than there were in 2.6.17's.

Elimination of the BKL is complete except for a few unimportant spots.
 All it needs is thorough testing on a multi-way ppc64 system to
reveal niggling problems.

The RPC slot table patches are completely rewritten in this release.
That will probably need some testing and review.

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
