From: "Heflin, Roger A." <Roger.A.Heflin@conocophillips.com>
Subject: RE: Application locked when network crash
Date: Tue, 17 Jun 2003 10:26:21 -0500
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <31B1521BD986E84E9D43651F8DF99BDC0134B40B@POEXMB1.conoco.net>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="US-ASCII"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from mailman1.ppco.com ([138.32.33.10])
	by sc8-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 19SILs-0008H9-00
	for <nfs@lists.sourceforge.net>; Tue, 17 Jun 2003 08:26:28 -0700
To: "Jacky Lam" <faichai0@yahoo.com>, <nfs@lists.sourceforge.net>
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


Put intr on the nfs mount and then you can usually ctrl-c the
application, it generally will take a few seconds for the application
to respond to the ctrl-c, the other option is to use soft mounts,
but if your network is less than perfect or your server is overloaded
this will often cause lots of timeouts that will cause the application
to crash when there is no problem except the network being slow.
See "man nfs" and the nfs section of "man mount".

Generally this hanging is the desired behavior when the network
is expected to come back as this causes the least damage to=20
the users running on the machine as the job in question will
continue where it left off if the server has sync on the exports
of the given filesystem (see "man exports").

                              Roger

> -----Original Message-----
> From:	Jacky Lam [SMTP:faichai0@yahoo.com]
> Sent:	Tuesday, June 17, 2003 9:49 AM
> To:	nfs@lists.sourceforge.net
> Subject:	[NFS] Application locked when network crash
>=20
> Dear all,
>=20
>     I am not very familiar with nfs. Currently, I connect a client =
with an
> nfs server. When the client is reading/writing from/to the server, the
> network is crashed(I repeat the problem by removing the network =
cable).
> Then, the client is hanged. How can the client get out from the hang =
in
> customed timeout(or at least in short period of time)? Thanks very =
much.
>=20
>     (Please cc to my email because I haven't subscribed the list yet.
> Thanks)
>=20
> Yours,
> Jacky
>=20
>=20
>=20
> -------------------------------------------------------
> This SF.Net email is sponsored by: INetU
> Attention Web Developers & Consultants: Become An INetU Hosting =
Partner.
> Refer Dedicated Servers. We Manage Them. You Get 10% Monthly =
Commission!
> INetU Dedicated Managed Hosting http://www.inetu.net/partner/index.php
> _______________________________________________
> NFS maillist  -  NFS@lists.sourceforge.net
> https://lists.sourceforge.net/lists/listinfo/nfs


-------------------------------------------------------
This SF.Net email is sponsored by: INetU
Attention Web Developers & Consultants: Become An INetU Hosting Partner.
Refer Dedicated Servers. We Manage Them. You Get 10% Monthly Commission!
INetU Dedicated Managed Hosting http://www.inetu.net/partner/index.php
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
