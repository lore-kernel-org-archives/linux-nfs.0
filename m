From: "Lever, Charles" <Charles.Lever@netapp.com>
Subject: RE: debugging failed lock recovery
Date: Fri, 28 Jan 2005 09:36:35 -0800
Message-ID: <482A3FA0050D21419C269D13989C6113085396A0@lavender-fe.eng.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Cc: <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1CubVl-0007Ba-UN
	for nfs@lists.sourceforge.net; Fri, 28 Jan 2005 11:10:29 -0800
Received: from mx2.netapp.com ([216.240.18.37])
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.41)
	id 1CubVc-0007P8-H6
	for nfs@lists.sourceforge.net; Fri, 28 Jan 2005 11:10:29 -0800
To: "Ara.T.Howard" <Ara.T.Howard@noaa.gov>
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

hardwiring the results of gethostbyname on the client and server by
seeding entries in /etc/hosts might be a start.

i believe there is also an option on statd to always use a particular
nodename (-n ?).

> -----Original Message-----
> From: Ara.T.Howard [mailto:Ara.T.Howard@noaa.gov]=20
> Sent: Friday, January 28, 2005 12:27 PM
> To: Lever, Charles
> Cc: nfs@lists.sourceforge.net
> Subject: RE: [NFS] debugging failed lock recovery
>=20
>=20
> On Fri, 28 Jan 2005, Lever, Charles wrote:
>=20
> > ara-
> >
> > the client must have a fully qualified nodename (uname -n)=20
> which matches
> > the result of a DNS lookup, in order for lock recovery to work.
> >
> > the nodename is set in /etc/sysconfig/networking on red hat systems.
>=20
> charles-
>=20
> thanks for the lead!
>=20
> yes.  they all have that and they are in dns.  however, our=20
> nfs runs on the
> 'backdoor': each client/server has two cards, one mated to
>=20
>    client.domain
>=20
> and one to
>=20
>    client.b.domain
>=20
> both are in dns.
>=20
> *however* the output of uname -n is (of course) the=20
> frontdoor.  so it seems we
> have a mismatch.  so uname -n *might* match the result of a dns lookup
> depending on which interface is looked up and, i'm guessing,=20
> this will be the
> backdoor interface and therefore fail.
>=20
> anyone have ideas on what to do about this?  can nfs be run=20
> on a multihomed
> server on an interface NOT named the same as 'uname -n'??
>=20
> kind regards.
>=20
> -a
> --=20
> =
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
> | EMAIL   :: Ara [dot] T [dot] Howard [at] noaa [dot] gov
> | PHONE   :: 303.497.6469
> | When you do something, you should burn yourself completely,=20
> like a good
> | bonfire, leaving no trace of yourself.  --Shunryu Suzuki
> =
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
>=20


-------------------------------------------------------
This SF.Net email is sponsored by: IntelliVIEW -- Interactive Reporting
Tool for open source databases. Create drag-&-drop reports. Save time
by over 75%! Publish reports on the web. Export to DOC, XLS, RTF, etc.
Download a FREE copy at http://www.intelliview.com/go/osdn_nl
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
