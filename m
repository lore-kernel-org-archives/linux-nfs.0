From: "Lever, Charles" <Charles.Lever@netapp.com>
Subject: RE: possible client stale filehandle bug?
Date: Wed, 16 Feb 2005 13:18:41 -0800
Message-ID: <482A3FA0050D21419C269D13989C61130853976D@lavender-fe.eng.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Cc: "Garrick Staples" <garrick@usc.edu>, <nfs@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1D1WZL-0003ey-Vk
	for nfs@lists.sourceforge.net; Wed, 16 Feb 2005 13:18:47 -0800
Received: from mx1.netapp.com ([216.240.18.38])
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.41)
	id 1D1WZL-0004jl-Ke
	for nfs@lists.sourceforge.net; Wed, 16 Feb 2005 13:18:47 -0800
To: "Neil Horman" <nhorman@redhat.com>
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

hi neil-

> >>It seems that the Solaris clients never report any such=20
> errors, only the Linux
> >>clients.  However, watching 'snoop' on the Solaris NFS=20
> server, I see that it IS
> >>returning stale file handles to both OSes, but Solaris=20
> clients seem to retry
> >>the request several times; and the Linux clients=20
> immediately pass the error up
> >>to the application.
> >>
> >>Is there some condition that the 2.4 kernel is handling incorrectly?
> >=20
> >=20
> > I do not believe that Solaris redrives ESTALE on read, but=20
> they may do
> > it on open(). Linux does not redrive either case. See the many
> > discussions in the NFS list archives for why.
> >=20
>=20
> Solaris does in fact retry on operations on ESTALE errors,=20
> definately on=20
> open, and I think on read/readdir/stat/etc. as well.  We had some=20
> discussion about tht here recently.

as far as i know Solaris doesn't redrive on read or write, but only
during pathname resolution.  redriving a read or write will only work in
the case where the server has taken the export offline temporarily; if
the file handle really is bad, then redriving a read or write is
probably safe, but won't accomplish anything.

i have a patch that adds support for pathname resolution retry to 2.6
(now in Trond's NFS_ALL for 2.6.11-rc4) and a pair of patches that
implement this for RHEL 3.0 that i've sent to steve and al viro for
review.


-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now.
http://ads.osdn.com/?ad_id=6595&alloc_id=14396&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
