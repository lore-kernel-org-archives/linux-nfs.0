From: =?iso-8859-1?Q?Brasseur_Val=E9ry?= <Valery.Brasseur@atosorigin.com>
Subject: Re: strange lock problem
Date: Thu, 19 Jun 2003 18:16:25 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <8147E1B07201DD41B6B9F0D31E07B38444913A@srv-grp-s07.dev.atos.fr>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Cc: "'Lever, Charles'" <Charles.Lever@netapp.com>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from hermes4.atos-group.com ([160.92.18.11])
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 19T25T-0006UW-00
	for <nfs@lists.sourceforge.net>; Thu, 19 Jun 2003 09:16:35 -0700
To: nfs@lists.sourceforge.net
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

Having investigate more, I know see that sometimes 2 process are able =
to
obtain the same file lock !

in this case the 2 processes have 10 minutes interval of start ! and =
the
last one is the one in the filer lock table !! not the first !!!

any ideas ?

> -----Original Message-----
> From: Brasseur Val=E9ry=20
> Sent: Wednesday, June 18, 2003 3:13 PM
> To: nfs@lists.sourceforge.net
> Subject: [NFS] strange lock problem
>=20
>=20
> I am running Linux client (2.4.20 + NFS-ALL) mounting NetApp filer
> (DataOnTap 6.4).
>=20
> sometime I see lock which are not associated whit a process !
>=20
> ie:  on the filer i do a lock_dump -h : get list of lock
>=20
> on the client, I match the pid's form the list if my running=20
> pid's... and
> some are not found, even in the /proc/locks !!!
>=20
>=20
> if I clear the locks on the filer (by a sm_mon -l) they are=20
> all claimed !
>=20
>=20
> but after some time (a couple of hours !) a new sm_mon -l=20
> clear these locks
> !!!!
>=20
>=20
> did someone have ideas ?
>=20
> thanks=20
>=20
>=20
> -------------------------------------------------------
> This SF.Net email is sponsored by: INetU
> Attention Web Developers & Consultants: Become An INetU=20
> Hosting Partner.
> Refer Dedicated Servers. We Manage Them. You Get 10% Monthly=20
> Commission!
> INetU Dedicated Managed Hosting =
http://www.inetu.net/partner/index.php
> _______________________________________________
> NFS maillist  -  NFS@lists.sourceforge.net
> https://lists.sourceforge.net/lists/listinfo/nfs
>=20


-------------------------------------------------------
This SF.Net email is sponsored by: INetU
Attention Web Developers & Consultants: Become An INetU Hosting Partner.
Refer Dedicated Servers. We Manage Them. You Get 10% Monthly Commission!
INetU Dedicated Managed Hosting http://www.inetu.net/partner/index.php
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
