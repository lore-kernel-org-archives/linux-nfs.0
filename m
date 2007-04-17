From: Mike Frysinger <vapier@gentoo.org>
Subject: Re: Does mountd/statd really need to listen on a privileged
	port??
Date: Tue, 17 Apr 2007 07:12:06 -0400
Message-ID: <200704170712.06635.vapier@gentoo.org>
References: <17950.44333.118970.276558@notabene.brown>
	<17950.57188.878877.547112@notabene.brown>
	<200704171214.35952.olaf.kirch@oracle.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============1840317850=="
Cc: Neil Brown <neilb@suse.de>, nfs@lists.sourceforge.net
To: Olaf Kirch <olaf.kirch@oracle.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HdlbJ-0003ua-Qr
	for nfs@lists.sourceforge.net; Tue, 17 Apr 2007 04:11:59 -0700
Received: from smtp.gentoo.org ([140.211.166.183])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HdlbL-0000cw-5r
	for nfs@lists.sourceforge.net; Tue, 17 Apr 2007 04:12:00 -0700
In-Reply-To: <200704171214.35952.olaf.kirch@oracle.com>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

--===============1840317850==
Content-Type: multipart/signed; boundary="nextPart7053691.Py68u0Fvs5";
	protocol="application/pgp-signature"; micalg=pgp-sha1
Content-Transfer-Encoding: 7bit

--nextPart7053691.Py68u0Fvs5
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

On Tuesday 17 April 2007, Olaf Kirch wrote:
> On Friday 13 April 2007 03:39, Neil Brown wrote:
> > > if that's true, then we could at least rewrite the socket code to bind
> > > to ports that do not appear in /etc/services (via getservbyport()) ...
> > > that'd allow admins to easily prevent things like mountd/statd from
> > > hijacking reserved ports ...
> >
> > I had thought of that too.  I'll probably implement it.  Your code (in
> > subsequent email) is a little more complicated than needed.  Just
> > repeatedly call bindresvport, closing if you don't like it.  The port
> > number tried increments each time.
>
> The glibc shipped with Suse has a file called /etc/bindresvport.blacklist
> that you can add ports to. I thought something similar had found its
> way upstream by now, but unfortunately I can't find it.

i thought Drepper already weighed in on this issue with a response similar=
=20
to "not a chance in hell" :)
=2Dmike

--nextPart7053691.Py68u0Fvs5
Content-Type: application/pgp-signature; name=signature.asc 
Content-Description: This is a digitally signed message part.

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.3 (GNU/Linux)

iQIVAwUARiSrhkFjO5/oN/WBAQIn1hAA0GAmzNp/01NmufnbLqog3Lox/3Rn2i5o
Eh0imMMbKpp2BtYYLwNRBn8kgW6Wdt9K5LkImSS4BXMzqbLS7YLtL9/M0Y1Cmzo7
5bDFqoS83i99jByAX9KawFjapEsaBoS92+m2u0n6SW3NTGdNZVINguQK+PoaugxI
JK8PbTDQQmraT1q1r39pOEmdBGbaK6eG/pcTKN18RoCYbycekKNPXETYyZWKbCRq
BxkhppROL0hkUtuuRIKGt5weZ6oAn8KBp7MO64F0Y5AJvLWjSp6Zqn1ckQE19ASu
Deu+mmsP3TDQVYlD2JVdrAZQrsp8fA/jZy2z6sc8pwYm8VRYYHBZxGAgcdanzQyf
TZ0lTlf6QGu0H4CssNWHq9VetyBb2FmQM//KeRVFaw7IyR3YaEC0zlsFeMAaCl8H
o3oDVtM9oOqKU1xIn9ka85wze12mBxOb+34Z4zRe0buuYLnkY6qetdde611FHjJT
fkfkDZ2TecVvmy8PeyqurMcAYgutksxughikCHZN8L7ckQocB9T7UOy/xW1bAIDf
QWVn6Xc68lHZd8watrhBVDWedPC5JPtbIlVZJXNA8GAF34RM67fQo6Rp9lfIJftl
cEYwxTtL37+U4VW6+59RxRwmQPy2ETVK5VxyhQYUBbHlypMAG5t1qgStHDgPeKjL
uzwuU05P7I0=
=FG/L
-----END PGP SIGNATURE-----

--nextPart7053691.Py68u0Fvs5--


--===============1840317850==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
--===============1840317850==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

--===============1840317850==--
