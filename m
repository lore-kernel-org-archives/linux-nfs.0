From: "Lever, Charles" <Charles.Lever@netapp.com>
Subject: RE: Data coherency trouble with multiple clients, on2.6.14-rc5
Date: Wed, 26 Oct 2005 08:27:57 -0700
Message-ID: <044B81DE141D7443BCE91E8F44B3C1E288E5A5@exsvl02.hq.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Cc: <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1EUnCA-0001M2-LB
	for nfs@lists.sourceforge.net; Wed, 26 Oct 2005 08:28:06 -0700
Received: from mx1.netapp.com ([216.240.18.38])
	by mail.sourceforge.net with esmtp (Exim 4.44)
	id 1EUnCA-0005OL-7h
	for nfs@lists.sourceforge.net; Wed, 26 Oct 2005 08:28:06 -0700
To: "Trond Myklebust" <trond.myklebust@fys.uio.no>,
	"Charles Duffy" <ccd@mailcall.com.au>
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

> > The client mount options are: =
noac,nocto,sync,hard,intr,rw,nfsvers=3D3
> > The server exports flags are:=20
> (rw,no_root_squash,sync,no_wdelay,insecure)
> >=20
> > Various combinations of the above mount options make no difference.
> > I've also tried with a 2.6.14-rc5 server, and the problem persists.
>=20
> It sounds like you are really looking for the O_DIRECT (i.e. uncached)
> file I/O mode.

i agree that O_DIRECT is the right solution.  however, even with "noac"
i would expect mr. duffy's workload to behave correctly most of the
time.  sounds like he is able to make it fail very easily.


-------------------------------------------------------
This SF.Net email is sponsored by the JBoss Inc.
Get Certified Today * Register for a JBoss Training Course
Free Certification Exam for All Training Attendees Through End of 2005
Visit http://www.jboss.com/services/certification for more information
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
