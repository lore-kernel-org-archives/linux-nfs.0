From: Dan Stromberg <strombrg@dcs.nac.uci.edu>
Subject: RE: Some code, and a question
Date: Wed, 07 Sep 2005 10:02:31 -0700
Message-ID: <1126112551.16701.19.camel@seki.nac.uci.edu>
References: <482A3FA0050D21419C269D13989C611308539F8B@lavender-fe.eng.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: nfs@lists.sourceforge.net, Greg Banks <gnb@sgi.com>,
	strombrg@dcs.nac.uci.edu
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1ED3KC-0006ov-8H
	for nfs@lists.sourceforge.net; Wed, 07 Sep 2005 10:03:04 -0700
Received: from dcs.nac.uci.edu ([128.200.34.32])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44)
	id 1ED3KB-0000P9-2J
	for nfs@lists.sourceforge.net; Wed, 07 Sep 2005 10:03:04 -0700
To: "Lever, Charles" <Charles.Lever@netapp.com>
In-Reply-To: <482A3FA0050D21419C269D13989C611308539F8B@lavender-fe.eng.netapp.com>
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

On Wed, 2005-09-07 at 08:34 -0700, Lever, Charles wrote:
> > On Wed, 2005-09-07 at 11:02 +1000, Greg Banks wrote: 
> > > On Tue, Sep 06, 2005 at 03:39:57PM -0700, Dan Stromberg wrote:
> > > > 
> > > > OK, I know NFS isn't usually thought of as the fastest 
> > protocol under
> > > > the sun,
> > > 
> > > Why would you think that?  NFSv3 can be very efficient at moving
> > > bits from point A to point B.
> > 
> > You mean aside from the troublesome back-and-forthing on a 
> > high latency network?
> 
> NFSv4 delegation will help there.

Cool.

> but on a data-intensive workload (ie mostly reads and writes and very
> few metadata operations) NFS can be quite as fast as the underlying
> network and the server's file system will allow.

Agreed, on huge files, NFS isn't that lackluster.

On a related note, I heard a rumor that there's going to be some sort of
proxy released by some vendor (the guy who described was under an NDA)
that should be able to greatly reduce back-and-forthing in NFS...  It
sounded very much like with NX does for X11 if you set it up with a
proxy.

Thanks!






-------------------------------------------------------
SF.Net email is Sponsored by the Better Software Conference & EXPO
September 19-22, 2005 * San Francisco, CA * Development Lifecycle Practices
Agile & Plan-Driven Development * Managing Projects & Teams * Testing & QA
Security * Process Improvement & Measurement * http://www.sqe.com/bsce5sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
