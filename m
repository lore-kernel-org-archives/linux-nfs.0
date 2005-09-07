From: "Lever, Charles" <Charles.Lever@netapp.com>
Subject: RE: Some code, and a question
Date: Wed, 7 Sep 2005 08:34:15 -0700
Message-ID: <482A3FA0050D21419C269D13989C611308539F8B@lavender-fe.eng.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Cc: <nfs@lists.sourceforge.net>, "Greg Banks" <gnb@sgi.com>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1ED1wS-0003A7-8t
	for nfs@lists.sourceforge.net; Wed, 07 Sep 2005 08:34:28 -0700
Received: from mx2.netapp.com ([216.240.18.37])
	by mail.sourceforge.net with esmtp (Exim 4.44)
	id 1ED1wQ-0006Fj-53
	for nfs@lists.sourceforge.net; Wed, 07 Sep 2005 08:34:28 -0700
To: "Dan Stromberg" <strombrg@dcs.nac.uci.edu>
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

> On Wed, 2005-09-07 at 11:02 +1000, Greg Banks wrote:=20
> > On Tue, Sep 06, 2005 at 03:39:57PM -0700, Dan Stromberg wrote:
> > >=20
> > > OK, I know NFS isn't usually thought of as the fastest=20
> protocol under
> > > the sun,
> >=20
> > Why would you think that?  NFSv3 can be very efficient at moving
> > bits from point A to point B.
>=20
> You mean aside from the troublesome back-and-forthing on a=20
> high latency network?

NFSv4 delegation will help there.

but on a data-intensive workload (ie mostly reads and writes and very
few metadata operations) NFS can be quite as fast as the underlying
network and the server's file system will allow.


-------------------------------------------------------
SF.Net email is Sponsored by the Better Software Conference & EXPO
September 19-22, 2005 * San Francisco, CA * Development Lifecycle Practices
Agile & Plan-Driven Development * Managing Projects & Teams * Testing & QA
Security * Process Improvement & Measurement * http://www.sqe.com/bsce5sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
