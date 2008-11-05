From: "Brian J. Murrell" <brian-SquOHqY54CVWr29BmMi2cA@public.gmane.org>
Subject: Re: gssapi and nfs4
Date: Wed, 05 Nov 2008 14:51:56 -0500
Message-ID: <1225914716.3785.54.camel@pc.interlinx.bc.ca>
References: <1225813410.2247.279.camel@brian-laptop>
	 <89c397150811041000l93b9831w1e8dce2175c6d51f@mail.gmail.com>
	 <1225824797.2247.345.camel@brian-laptop>
	 <20081104224817.GB16121@fieldses.org>
	 <1225862729.13506.8.camel@pc.interlinx.bc.ca>
	 <20081105190235.GA969@fieldses.org>
	 <1225912734.3785.40.camel@pc.interlinx.bc.ca>
	 <89c397150811051140p2f6e1cb1x1960570d19ac5d6d@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha1"; protocol="application/pgp-signature"; boundary="=-MYbrFq3uINqGMYN60P8t"
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from server.klug.on.ca ([205.189.48.131]:3104 "EHLO
	server.klug.on.ca" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752674AbYKETwA (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 5 Nov 2008 14:52:00 -0500
Received: from linux.interlinx.bc.ca (d193-213-184.home3.cgocable.net [67.193.213.184])
	(using TLSv1 with cipher DHE-RSA-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by server.klug.on.ca (Postfix) with ESMTP id 090792807
	for <linux-nfs@vger.kernel.org>; Wed,  5 Nov 2008 14:51:58 -0500 (EST)
Received: from [10.75.22.1] (pc.ilinx [10.75.22.1])
	by linux.interlinx.bc.ca (Postfix) with ESMTP id AB367800A
	for <linux-nfs@vger.kernel.org>; Wed,  5 Nov 2008 14:51:57 -0500 (EST)
In-Reply-To: <89c397150811051140p2f6e1cb1x1960570d19ac5d6d-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


--=-MYbrFq3uINqGMYN60P8t
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Wed, 2008-11-05 at 14:40 -0500, William A. (Andy) Adamson wrote:
>=20
> A better way to limit access is to use ACL's on the directory,

Yes, indeed.  I have been holding off as long as I can on using ACLs
given the lack of integration into the GUI (i.e. gnome) environment thus
far.  For example, so far as I know, nautilus does not have any ACL
inspection/modification in it yet.  Maybe that's not such a big deal.
Just another layer I guess.

> which
> actually make a difference when running kerberos. :)

Yeah.

FWIU, ACLs would solve the other of the 2 problems that I went to nfs4
with gssapi for anyway and that's being able to more easily allow others
access to files.  Unix groups work fine for this as long as you can
control the umask/permission bits a particular application sets on the
files it creates.

While I can create inheritance rules for ownerships in the SYS security
model I can't create (inheritable) umask/permissions rules and have to
rely on either the users' global umask or the application giving, say,
group write permissions to a file.  Setting the users' global umask for
that is of course unacceptable and that only leaves attacking the
problem on an application-by-application basis.  Yuck.

b.


--=-MYbrFq3uINqGMYN60P8t
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.9 (GNU/Linux)

iEYEABECAAYFAkkR+VwACgkQl3EQlGLyuXAXwQCggq/Gca0rerVIKXtzz2i3jte4
65sAn2VVYWkErTyXTUhbiemZZ3ANz6Cj
=wbUs
-----END PGP SIGNATURE-----

--=-MYbrFq3uINqGMYN60P8t--

