From: Steve Dickson <SteveD@redhat.com>
Subject: Re: cel's patches for 2.6.18 kernels
Date: Thu, 21 Sep 2006 08:26:12 -0400
Message-ID: <451284E4.4050806@RedHat.com>
References: <76bd70e30609201128r9188a17i51b779c6e1b569fc@mail.gmail.com>	<20060920202010.GA22954@infradead.org>	<76bd70e30609201353l7d8c063fp94916c509b08b24e@mail.gmail.com>	<1158787006.5639.19.camel@lade.trondhjem.org>
	<76bd70e30609201929s1e01b453ia694774d77f9474c@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Christoph Hellwig <hch@infradead.org>,
	Linux NFS Mailing List <nfs@lists.sourceforge.net>,
	Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GQNdN-0000EZ-4l
	for nfs@lists.sourceforge.net; Thu, 21 Sep 2006 05:26:29 -0700
Received: from mx1.redhat.com ([66.187.233.31])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1GQNdL-0007E6-H1
	for nfs@lists.sourceforge.net; Thu, 21 Sep 2006 05:26:30 -0700
To: Chuck Lever <chucklever@gmail.com>
In-Reply-To: <76bd70e30609201929s1e01b453ia694774d77f9474c@mail.gmail.com>
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



Chuck Lever wrote:
> No slot table means we can dynamically increase and decrease the
> number of concurrent RPC requests per transport -- which is a
> pre-requisite for scalability when all mounts to the same server use
> the same transport.  I don't relish the idea of a hundred mount points
> on a client that are only allowed to start 16 total requests at a
> time.
> 
I think this is a very good thing... not having a hard code slot table
make things much more scalable... imho...

steved.


-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys -- and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
