From: Dan Stromberg <strombrg@dcs.nac.uci.edu>
Subject: max filesystem size - nfs imposed limit?
Date: Wed, 19 May 2004 16:44:11 -0700
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <1085010251.22480.52.camel@sabaki.dcs.uci.edu>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-QFxG6GSaRjtV5csrPA1V"
Cc: strombrg@dcs.nac.uci.edu
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1BQarj-0004QN-7v
	for nfs@lists.sourceforge.net; Wed, 19 May 2004 16:52:51 -0700
Received: from sabaki.nac.uci.edu ([128.200.34.80] helo=sabaki.dcs.uci.edu)
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.30)
	id 1BQarj-0001gU-01
	for nfs@lists.sourceforge.net; Wed, 19 May 2004 16:52:51 -0700
To: nfs@lists.sourceforge.net
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


--=-QFxG6GSaRjtV5csrPA1V
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable


We need to set up a multiterrabyte filesystem (probably 30T), and NFS
export it.

Does linux nfs impose a maximum filesystem size?  Or is that strictly a
matter of the filesystem type being exported (ext3, xfs, lustre, gfs,
whatever)?  Does it matter if you're using nfs v2/v3/v4?  Does the
kernel version matter?  How about 32 bit vs 64 bit platforms (especially
interested in whether an opteron or linux ppc would help)?

Is linux NFS on 64 bit platforms stable?

Sorry if these questions have been asked before.  I didn't have much
luck locating answers (which might make a nice entry in a FAQ :), which
I'd be willing to take a stab at composing the entry for) by googling
and searching the list archives.

--=20
Dan Stromberg DCS/NACS/UCI <strombrg@dcs.nac.uci.edu>


--=-QFxG6GSaRjtV5csrPA1V
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.0.7 (GNU/Linux)

iD8DBQBAq/FKo0feVm00f/8RAqntAJ4iVohw/8PHESZjwKapJbaHt73NsgCfWjQp
9RkFcVBVMNYm6FC/ld/83GM=
=9oZ4
-----END PGP SIGNATURE-----

--=-QFxG6GSaRjtV5csrPA1V--


-------------------------------------------------------
This SF.Net email is sponsored by: Oracle 10g
Get certified on the hottest thing ever to hit the market... Oracle 10g. 
Take an Oracle 10g class now, and we'll give you the exam FREE.
http://ads.osdn.com/?ad_id=3149&alloc_id=8166&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
