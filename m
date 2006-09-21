From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: cel's patches for 2.6.18 kernels
Date: Thu, 21 Sep 2006 09:47:15 -0400
Message-ID: <1158846435.7626.7.camel@lade.trondhjem.org>
References: <76bd70e30609201128r9188a17i51b779c6e1b569fc@mail.gmail.com>
	<20060920202010.GA22954@infradead.org>
	<76bd70e30609201353l7d8c063fp94916c509b08b24e@mail.gmail.com>
	<1158787006.5639.19.camel@lade.trondhjem.org>
	<76bd70e30609201929s1e01b453ia694774d77f9474c@mail.gmail.com>
	<451284E4.4050806@RedHat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Christoph Hellwig <hch@infradead.org>,
	Linux NFS Mailing List <nfs@lists.sourceforge.net>,
	Chuck Lever <chucklever@gmail.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GQOu4-0007Ty-I3
	for nfs@lists.sourceforge.net; Thu, 21 Sep 2006 06:47:48 -0700
Received: from pat.uio.no ([129.240.10.4])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1GQOu2-00027F-SR
	for nfs@lists.sourceforge.net; Thu, 21 Sep 2006 06:47:49 -0700
To: Steve Dickson <SteveD@redhat.com>
In-Reply-To: <451284E4.4050806@RedHat.com>
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

On Thu, 2006-09-21 at 08:26 -0400, Steve Dickson wrote:
> 
> Chuck Lever wrote:
> > No slot table means we can dynamically increase and decrease the
> > number of concurrent RPC requests per transport -- which is a
> > pre-requisite for scalability when all mounts to the same server use
> > the same transport.  I don't relish the idea of a hundred mount points
> > on a client that are only allowed to start 16 total requests at a
> > time.
> > 
> I think this is a very good thing... not having a hard code slot table
> make things much more scalable... imho...

I'd like to see _lots_ of testing in a low-memory environment before I'm
ready to fully subscribe to that opinion.

Cheers,
  Trond


-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys -- and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
