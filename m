From: "Lever, Charles" <Charles.Lever@netapp.com>
Subject: RE: NAS server avalanche overload
Date: Wed, 3 Mar 2004 18:07:14 -0800
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <482A3FA0050D21419C269D13989C61130435DCCE@lavender-fe.eng.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Cc: <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1AyiMP-000728-D9
	for nfs@lists.sourceforge.net; Wed, 03 Mar 2004 18:13:17 -0800
Received: from mx01.netapp.com ([198.95.226.53])
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.30)
	id 1AyiGm-00033d-TM
	for nfs@lists.sourceforge.net; Wed, 03 Mar 2004 18:07:28 -0800
To: "Greg Banks" <gnb@melbourne.sgi.com>,
        "Erik Walthinsen" <omega@pdxcolo.net>
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

> > > The noatime option has no effect over NFS.  Your [rw]sizes are
> > > really quite small, try 8K.  Also, try turning off noac.
> > The rwsizes were set based on a set of experiments with=20
> different sizes,
> > with 4k yielding by far the best bandwidth performance. =20
> The limiting
> > factor there is that the gig switch we have atm doesn't handle jumbo
> > frames.=20
>=20
> That really shouldn't make a difference; both 4K and 8K IOs will end
> up being split over multiple ethernet frames.

it does make a difference if you are using UDP and your network
suffers from bursty congestion or buffer overruns.

erik, you should look for network problems so you can boost your
transfer size without suffering a loss in performance.


-------------------------------------------------------
This SF.Net email is sponsored by: IBM Linux Tutorials
Free Linux tutorial presented by Daniel Robbins, President and CEO of
GenToo technologies. Learn everything from fundamentals to system
administration.http://ads.osdn.com/?ad_id=1470&alloc_id=3638&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
