From: =?iso-8859-1?Q?Brasseur_Val=E9ry?= <Valery.Brasseur@atosorigin.com>
Subject: RE: strange lock problem
Date: Fri, 20 Jun 2003 14:15:17 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <8147E1B07201DD41B6B9F0D31E07B38444913E@srv-grp-s07.dev.atos.fr>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Cc: nfs@lists.sourceforge.net, "'Lever, Charles'"
	 <Charles.Lever@netapp.com>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from hermes4.atos-group.com ([160.92.18.11])
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 19TKng-0002G6-00
	for <nfs@lists.sourceforge.net>; Fri, 20 Jun 2003 05:15:28 -0700
To: 'Trond Myklebust' <trond.myklebust@fys.uio.no>
Errors-To: nfs-admin@lists.sourceforge.net
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

> -----Original Message-----
> From: Trond Myklebust [mailto:trond.myklebust@fys.uio.no]
> Sent: Thursday, June 19, 2003 7:20 PM
> To: Brasseur Val=E9ry
> Cc: nfs@lists.sourceforge.net; 'Lever, Charles'
> Subject: Re: [NFS] strange lock problem
>=20
>=20
> >>>>> " " =3D=3D Brasseur Val=E9ry <Valery.Brasseur@atosorigin.com> =
writes:
>=20
>      > Having investigate more, I know see that sometimes 2 process
>      > are able to obtain the same file lock !
>=20
> If the rpc.statd monitoring is screwing with the filer (telling it
> that the client has rebooted and that it must release all locks), =
then
> this is indeed possible.
>=20
> Is some process on the client perhaps restarting rpc.statd?

no I have no process on the client which monitor/restart the rpc.statd =
!

how can track this ?

thanks=20
valery

>=20
> Cheers,
>   Trond
>=20


-------------------------------------------------------
This SF.Net email is sponsored by: INetU
Attention Web Developers & Consultants: Become An INetU Hosting Partner.
Refer Dedicated Servers. We Manage Them. You Get 10% Monthly Commission!
INetU Dedicated Managed Hosting http://www.inetu.net/partner/index.php
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
