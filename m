From: "Lever, Charles" <Charles.Lever@netapp.com>
Subject: RE: [RFC] nfsstat v4 layout
Date: Wed, 16 Mar 2005 10:05:49 -0800
Message-ID: <482A3FA0050D21419C269D13989C611308539893@lavender-fe.eng.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Cc: <nfs@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DBcu8-0005N3-AP
	for nfs@lists.sourceforge.net; Wed, 16 Mar 2005 10:06:00 -0800
Received: from mx2.netapp.com ([216.240.18.37])
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.41)
	id 1DBcu3-0007yv-Lo
	for nfs@lists.sourceforge.net; Wed, 16 Mar 2005 10:06:00 -0800
To: "G. Allen Morris III" <gam3-nfs@gam3.net>
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

mr morris-

i think open_cnfrm or open_conf makes sense as open_confirm.  and so on
for the others:
open_dngrd; setclntid doesn't need to be spelled out, for instance.

also, i would love it if the count fields were wider (NFSv2 and v3 too).

> -----Original Message-----
> From: G. Allen Morris III [mailto:gam3-nfs@gam3.net]=20
> Sent: Wednesday, March 16, 2005 12:38 PM
> To: nfs@lists.sourceforge.net
> Subject: [NFS] [RFC] nfsstat v4 layout
>=20
>=20
>=20
> I made a patch to nfsstat to display v4 stats.
> I am having a problem with some of the names being so
> long setclientid_confirm for instance. =20
>=20
> Is the format below too confusing?  Anyone have a better idea?
>=20
> Client nfs v4:
> null        read        write       commit      open       =20
> *_confirm  =20
> 0       0%  0       0%  0       0%  0       0%  0       0%  0=20
>       0% =20
> *_noattr    *_downgrade close       setattr     fsinfo     =20
> renew      =20
> 0       0%  0       0%  0       0%  0       0%  0       0%  0=20
>       0% =20
> setclientid *_confirm   lock        lockt       locku      =20
> access     =20
> 0       0%  0       0%  0       0%  0       0%  0       0%  0=20
>       0% =20
> getattr     lookup      lookup_root remove      rename     =20
> link       =20
> 0       0%  0       0%  0       0%  0       0%  0       0%  0=20
>       0% =20
> symlink     create      pathconf    statfs      readlink   =20
> readdir    =20
> 0       0%  0       0%  0       0%  0       0%  0       0%  0=20
>       0% =20
> server_caps delegreturn=20
> 0       0%  0       0% =20
>=20
>=20
> Allen Morris <gam3@gam3.net>
>=20
>=20
> -------------------------------------------------------
> SF email is sponsored by - The IT Product Guide
> Read honest & candid reviews on hundreds of IT Products from=20
> real users.
> Discover which products truly live up to the hype. Start reading now.
> http://ads.osdn.com/?ad_id=3D6595&alloc_id=3D14396&op=3Dclick
> _______________________________________________
> NFS maillist  -  NFS@lists.sourceforge.net
> https://lists.sourceforge.net/lists/listinfo/nfs
>=20


-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now.
http://ads.osdn.com/?ad_id=6595&alloc_id=14396&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
