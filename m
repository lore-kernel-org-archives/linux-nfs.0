From: Bernd Schubert <bernd-schubert@web.de>
Subject: Re: Poor NFS performance, kernel 2.6.6.
Date: Thu, 27 May 2004 20:07:04 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <200405272007.10918.bernd-schubert@web.de>
References: <Pine.LNX.4.58.0405271331430.7539@penti.sit.fi>
Mime-Version: 1.0
Content-Type: multipart/signed;
  protocol="application/pgp-signature";
  micalg=pgp-sha1;
  boundary="Boundary-02=_O5itA4MhZGHJAUo";
  charset="iso-8859-1"
Cc: Harald Hannelius <harald+nfs@arcada.fi>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1BTPHi-0005I5-UY
	for nfs@lists.sourceforge.net; Thu, 27 May 2004 11:07:18 -0700
Received: from smtp06.web.de ([217.72.192.224])
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:DES-CBC3-SHA:168)
	(Exim 4.30)
	id 1BTPHg-0002AZ-MV
	for nfs@lists.sourceforge.net; Thu, 27 May 2004 11:07:16 -0700
To: nfs@lists.sourceforge.net
In-Reply-To: <Pine.LNX.4.58.0405271331430.7539@penti.sit.fi>
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


--Boundary-02=_O5itA4MhZGHJAUo
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

Hello,

>
> Distribution slackware-9.1 on both computers.
>
> /etc/exports;
>
>    /home   193.167.32.175(ro,no_root_squash,async)
>
> /etc/fstab;
>
>   193.167.32.187:/home    /home   nfs     \
>  defaults,noauto,rsize=3D32768,wsize=3D32768,nfsvers=3D3 0 0
>

if you read the list archive, you will see that Trond always suggests to us=
e=20
tcp in situations like this. Some weeks ago there was a discussion on LKML=
=20
about 2.6., udp and nfs, the final statement was, that one always should us=
e=20
tcp with 2.6. kernel versions (I still don't understand why, but my knowled=
ge=20
about network protocol design and kernel internal networking is probably to=
o=20
much limited to understand the reason ;) ).

Hope it helps,
	Bernd=20

--Boundary-02=_O5itA4MhZGHJAUo
Content-Type: application/pgp-signature
Content-Description: signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.4 (GNU/Linux)

iD8DBQBAti5OC8BUnAF+ydYRAin3AKCNjGwW2yKqyJBuGcEqA++G0DiL3gCgmPwV
bgR3kb5iUHAHeWygZhrUiW4=
=c0R/
-----END PGP SIGNATURE-----

--Boundary-02=_O5itA4MhZGHJAUo--


-------------------------------------------------------
This SF.Net email is sponsored by: Oracle 10g
Get certified on the hottest thing ever to hit the market... Oracle 10g. 
Take an Oracle 10g class now, and we'll give you the exam FREE.
http://ads.osdn.com/?ad_id=3149&alloc_id=8166&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
