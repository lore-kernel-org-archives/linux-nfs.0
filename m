From: "Lever, Charles" <Charles.Lever@netapp.com>
Subject: RE: rpc.statd -n
Date: Wed, 2 Feb 2005 11:41:15 -0800
Message-ID: <482A3FA0050D21419C269D13989C611307CF4BCB@lavender-fe.eng.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Cc: <nfs@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1CwQNO-0005E9-TF
	for nfs@lists.sourceforge.net; Wed, 02 Feb 2005 11:41:22 -0800
Received: from mx2.netapp.com ([216.240.18.37])
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.41)
	id 1CwQNN-0004lZ-2z
	for nfs@lists.sourceforge.net; Wed, 02 Feb 2005 11:41:22 -0800
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

hi ara-

statd is a user-level thing.  it has nothing to do with mount or the
mount options.

everything should work properly with multi-homed clients as long as each
client consistently uses the same unique hostname for both lockd and
statd requests, as far as i can tell.

> -----Original Message-----
> From: Ara.T.Howard [mailto:Ara.T.Howard@noaa.gov]=20
> Sent: Wednesday, February 02, 2005 1:42 PM
> To: nfs@lists.sourceforge.net
> Subject: [NFS] rpc.statd -n
>=20
>=20
>=20
> i have a question regarding rpc.statd and it's reporting of=20
> hostname.  in the
> case of a multi-homed client, say one running nfs on the
>=20
>    client.b.domain
>=20
> interface.  rpc.statd must be forced to report itself as=20
> 'client.b.domain'
> lest lockd recovery fail when it reports client.domain.  this=20
> is all well and
> good - but what if you have nfs running on more than one=20
> interface, like the
> case of home dirs on front-door and file-server on back-door?=20
>  now what can
> you do?  if you specify the hostname for rpc.statd you'll=20
> break lock recovery
> on one or the other filesystem right?
>=20
> i'm thinking that rpc.statd needs to be able to report as a=20
> user specified
> name for each mounted filesystem - eg. a mount option.  if=20
> this were done
> fstab could look something like
>=20
>    moby.b:/raid/array0/part1/export on /dmsp/moby-0-1 type=20
> nfs=20
> (rw,bg,hard,intr,rsize=3D8192,wsize=3D8192,addr=3D10.1.186.54,hostna
> me=3Dclient.b.domain)
>    moby:/raid/array0/part2/export on /home type nfs=20
> (rw,bg,hard,intr,rsize=3D8192,wsize=3D8192,addr=3D10.1.186.54,hostna
> me=3Dclient.domain)
>=20
> of course, there is already the 'mounthost' option - if all mounted
> filesystems specified this as `uname -n` whould this make=20
> lock recovery work
> for all interfaces?
>=20
> obviously i know very little about this but am wondering what=20
> the best way to
> make lock recovery work for mutil-homed clients mounting=20
> filesystems on > 1
> interface.
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
>=20
> -------------------------------------------------------
> This SF.Net email is sponsored by: IntelliVIEW -- Interactive=20
> Reporting
> Tool for open source databases. Create drag-&-drop reports. Save time
> by over 75%! Publish reports on the web. Export to DOC, XLS, RTF, etc.
> Download a FREE copy at http://www.intelliview.com/go/osdn_nl
> _______________________________________________
> NFS maillist  -  NFS@lists.sourceforge.net
> https://lists.sourceforge.net/lists/listinfo/nfs
>=20


-------------------------------------------------------
This SF.Net email is sponsored by: IntelliVIEW -- Interactive Reporting
Tool for open source databases. Create drag-&-drop reports. Save time
by over 75%! Publish reports on the web. Export to DOC, XLS, RTF, etc.
Download a FREE copy at http://www.intelliview.com/go/osdn_nl
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
