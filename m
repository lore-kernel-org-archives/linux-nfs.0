Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cantor2.suse.de ([195.135.220.15]:56633 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753265Ab2JCDq2 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 2 Oct 2012 23:46:28 -0400
Date: Wed, 3 Oct 2012 13:46:29 +1000
From: NeilBrown <neilb@suse.de>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: NFS <linux-nfs@vger.kernel.org>
Subject: Re: Inconsistency when mounting a directory that 'world' cannot
 access.
Message-ID: <20121003134629.72557522@notabene.brown>
In-Reply-To: <20121002143334.GA1435@fieldses.org>
References: <20120918112329.7d88ed9e@notabene.brown>
	<20121001154309.GD18400@fieldses.org>
	<20121002123810.15bd1ee2@notabene.brown>
	<20121002143334.GA1435@fieldses.org>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=PGP-SHA1;
 boundary="Sig_/=lV.DAzHlMz_pAAl+iUoMcU"; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--Sig_/=lV.DAzHlMz_pAAl+iUoMcU
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

On Tue, 2 Oct 2012 10:33:34 -0400 "J. Bruce Fields" <bfields@fieldses.org>
wrote:

> I guess you're right.  So it starts to sound more like: "you have a
> confusing setup.  Your export configuration says one thing, and your
> filesystem permissions say another.  Under NFSv3 the confusion didn't
> matter, but now it does--time to fix it."
>=20

That's the best I could come to - I'm glad to have it confirmed.  Thanks!

It is unfortunate that Linux NFS uses an anon credential to mount when krb5
is in use, and uses 'root' when auth_sys is used (which might be anon if
"root_squash" is active, but might not).
I wonder if it would work to use auth_none for the mount-time lookup, just
for consistency..

Is the following appropriate?  Is there somewhere better to put this caveat?

Thanks,
NeilBrown


diff --git a/utils/exportfs/exports.man b/utils/exportfs/exports.man
index bc1de73..91e4b9c 100644
--- a/utils/exportfs/exports.man
+++ b/utils/exportfs/exports.man
@@ -126,6 +126,10 @@ will be enforced only for access using flavors listed =
in the immediately
 preceding sec=3D option.  The only options that are permitted to vary in
 this way are ro, rw, no_root_squash, root_squash, and all_squash.
 .PP
+When RPCSEC_GSS is used with NFSv4, a client will only be able to mount a
+directory if that directory and all its ancestors give eXecute access
+to "world".
+.PP
 .SS General Options
 .BR exportfs
 understands the following export options:

--Sig_/=lV.DAzHlMz_pAAl+iUoMcU
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.18 (GNU/Linux)

iQIVAwUBUGu1FTnsnt1WYoG5AQLzLw//aJlbMWx/fsOZxO5hlAxIneo0GigmoRo6
wQgBLKC4c41yB9wvsSzAv6nZkkgpwrUDhwtJXM7kto2Wbc/R+6qjAVx3FrM/kXUH
HS1tzjTQBFpqGk/EmSYHpAMPQ86WuMKM0OwVPX/yjyEvjeFLE71ZBYutNrCMY/Qx
D8mvRmaww3VTjl5rHLwsfhphKupCSkx0UHPNXTUJ9FaRJcRttwdi+VOF1YhLHPZa
bKSv5yLGTf3M7NlXj4T4k53rxg1Qv5khMHKGlRdllJV4TDfj09W89UcsgvP9PGNs
oeSyGepe1nEzc4uR6Al8Yph/cPKuBg0HDLBTSF8vHDEBHHfT+tzROWt92rrhOpl3
80kPdoXSeIL/NlBS/17cjetI3JYNwHnIm/BIHCaVErFVZfis+zTkAwoli59KmyT9
cKbqVTQ3Bk0EDbbvGx54WssjmnjiVuOOxkbrBp0FfXnpAYc82X/JHEvTrm24u0DL
nw/ffkzN7OG83bN6vk0DhEBp/Rvn+v6pQt2Pq80xAO2NOLc9znRhRRmkqBRsMh97
P7A8P+oD0RO8t/ugLuAw/cdPTw4QUrqesZ4yZbuvtJu+HSWiArt9BnC9YS+0y7/m
PUrS+6MJBmULV0o9JhGLspHaOZukTZypdzbutgVeA9jjXp+3T/PGnAvY2U5lQsDj
djtey0OjkPA=
=B7do
-----END PGP SIGNATURE-----

--Sig_/=lV.DAzHlMz_pAAl+iUoMcU--
