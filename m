From: Bernd Schubert <bernd-schubert@web.de>
Subject: Re: nfsprog support
Date: Mon, 3 May 2004 01:27:15 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <200405030127.24709.bernd-schubert@web.de>
References: <200404151750.53209.bernd-schubert@web.de> <200404152331.47440.bernd-schubert@web.de> <1082065434.7141.48.camel@lade.trondhjem.org>
Mime-Version: 1.0
Content-Type: multipart/signed;
  protocol="application/pgp-signature";
  micalg=pgp-sha1;
  boundary="Boundary-02=_cPYlA9qKaqrtBoh";
  charset="iso-8859-1"
Cc: Trond Myklebust <trond.myklebust@fys.uio.no>,
 Olaf Kirch <okir@suse.de>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1BKQMw-0003ij-Gk
	for nfs@lists.sourceforge.net; Sun, 02 May 2004 16:27:34 -0700
Received: from smtp06.web.de ([217.72.192.224] helo=smtp.web.de)
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:DES-CBC3-SHA:168)
	(Exim 4.30)
	id 1BKQMw-0003pl-2h
	for nfs@lists.sourceforge.net; Sun, 02 May 2004 16:27:34 -0700
To: nfs@lists.sourceforge.net
In-Reply-To: <1082065434.7141.48.camel@lade.trondhjem.org>
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


--Boundary-02=_cPYlA9qKaqrtBoh
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

Hi Trond,

sorry for the late response, but as usual I was busy with my main work.

>
> What you are describing sounds like a bug in "mount". In the case where
> the user specifies both "port" and "nfsvers", there is no need
> whatsoever to consult the portmapper.
>
> I just do not see this as a kernel bug, or as any form of justification
> for adding support for the nfsprog hack.
>

It seems I was chasing a phantom *hrmmph*.=20
After you told me, it might be a bug in "mount", I immedeately checked the=
=20
util-linux mount source and didn't find anything wrong.=20
Today I tried again finding the source of the problem, but now I don't see =
a=20
problem at all. Mounting on different ports just works fine, even with the=
=20
same nfsversion.
I really have no idea why it didn't work all the time, but now suddenly wor=
ks.

Sorry for wasting your time,
	Bernd


--Boundary-02=_cPYlA9qKaqrtBoh
Content-Type: application/pgp-signature
Content-Description: signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.4 (GNU/Linux)

iD8DBQBAlYPcC8BUnAF+ydYRAkckAJoD49757NeTyJOia8elgcKjgB2uFwCgjcA4
35s2W7nXModEmbtXkpWqzM0=
=hnV7
-----END PGP SIGNATURE-----

--Boundary-02=_cPYlA9qKaqrtBoh--


-------------------------------------------------------
This SF.Net email is sponsored by: Oracle 10g
Get certified on the hottest thing ever to hit the market... Oracle 10g. 
Take an Oracle 10g class now, and we'll give you the exam FREE.
http://ads.osdn.com/?ad_id=3149&alloc_id=8166&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
