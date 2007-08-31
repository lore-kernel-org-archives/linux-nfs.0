From: "Brian J. Murrell" <brian@interlinx.bc.ca>
Subject: Re: slowness due to splitting into
	pages	in	nfs3svc_decode_writeargs()
Date: Fri, 31 Aug 2007 14:52:15 -0400
Message-ID: <1188586335.26165.104.camel@pc.ilinx>
References: <200708312003.30446.bernd-schubert@gmx.de>
	<20070831184515.GC11165@fieldses.org>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============1951418929=="
To: nfs <nfs@lists.sourceforge.net>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IRBbN-0004m8-Cx
	for nfs@lists.sourceforge.net; Fri, 31 Aug 2007 11:52:17 -0700
Received: from server.klug.on.ca ([205.189.48.131])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1IRBbQ-0000TX-OI
	for nfs@lists.sourceforge.net; Fri, 31 Aug 2007 11:52:22 -0700
Received: from linux.interlinx.bc.ca (d38-139-100.home1.cgocable.net
	[72.38.139.100])
	(using TLSv1 with cipher DHE-RSA-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by server.klug.on.ca (Postfix) with ESMTP id B2B212803
	for <nfs@lists.sourceforge.net>; Fri, 31 Aug 2007 14:52:17 -0400 (EDT)
Received: from [10.75.22.1] (pc.ilinx [10.75.22.1])
	(using TLSv1 with cipher DHE-RSA-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by linux.interlinx.bc.ca (Postfix) with ESMTP id A000710FC78
	for <nfs@lists.sourceforge.net>; Fri, 31 Aug 2007 14:52:15 -0400 (EDT)
In-Reply-To: <20070831184515.GC11165@fieldses.org>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net


--===============1951418929==
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature";
	boundary="=-Jye8i+3MnNBnUEIg3Z69"


--=-Jye8i+3MnNBnUEIg3Z69
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Fri, 2007-08-31 at 14:45 -0400, J. Bruce Fields wrote:
>=20
> Hm.  Any chance this is the same problem?:
>=20
> 	http://marc.info/?l=3Dlinux-nfs&m=3D112289652218095&w=3D2

Did this ever land anywhere?

b.

--=20
A day in the yard with my son is just like a day at work.  He goes
hunting around for stuff and brings it back to me and says: "Hey Dad,
look what I found.  The money is for me and the screw is for you."

--=-Jye8i+3MnNBnUEIg3Z69
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.6 (GNU/Linux)

iD8DBQBG2GNel3EQlGLyuXARAl+MAJ9c1UOVmFcktvWS98JiGNkV0m+zqQCfZQiL
caI0LraSYLgnmyKt5X8woKw=
=WzZw
-----END PGP SIGNATURE-----

--=-Jye8i+3MnNBnUEIg3Z69--



--===============1951418929==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >>  http://get.splunk.com/
--===============1951418929==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

--===============1951418929==--
