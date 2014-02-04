Return-Path: linux-nfs-owner@vger.kernel.org
Received: from messinet.com ([50.196.241.75]:58235 "EHLO chicago.messinet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753502AbaBDSsy (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 4 Feb 2014 13:48:54 -0500
From: Anthony Messina <amessina@messinet.com>
To: Steve Dickson <SteveD@redhat.com>
Cc: NeilBrown <neilb@suse.de>, linux-nfs@vger.kernel.org
Subject: Re: [PATCH/RFC: nfs-utils] Common systemd unit files for nfs-utils.
Date: Tue, 04 Feb 2014 12:48:47 -0600
Message-ID: <39783294.8Mk3atqdZo@linux-ws1.messinet.com>
In-Reply-To: <52F130E2.6090308@RedHat.com>
References: <20140130172451.7a354ce4@notabene.brown> <20140204093452.7b6d7c7d@notabene.brown> <52F130E2.6090308@RedHat.com>
MIME-Version: 1.0
Content-Type: multipart/signed; boundary="nextPart2092683.BgoAEjVs84"; micalg="pgp-sha1"; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


--nextPart2092683.BgoAEjVs84
Content-Transfer-Encoding: quoted-printable
Content-Type: text/plain; charset="us-ascii"

On Tuesday, February 04, 2014 01:26:42 PM Steve Dickson wrote:
> > Also rpc.gssd will be run whenever nfs-server.target or nfs-client.=
target
> > is started.
>=20
> Why is rpc.gssd started when the nfs server is started? Possibly for =
secure=20
> loopback mounts??

Isn't this needed for KRB5/NFSv4.1 callbacks?  I seem to remember needi=
ng this=20
on the server as well as the client, lest I get the frequent "gss upcal=
l=20
timeout" issue.  At least on Fedora that's how it's been for me.

=2DA

=2D-=20
Anthony - http://messinet.com - http://messinet.com/~amessina/gallery
8F89 5E72 8DF0 BCF0 10BE 9967 92DC 35DC B001 4A4E

--nextPart2092683.BgoAEjVs84
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part.
Content-Transfer-Encoding: 7Bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.22 (GNU/Linux)

iEYEABECAAYFAlLxNhQACgkQktw13LABSk4hBgCeNn3MBQToJpNpkQc3KyDKG+7E
PqwAoJrbSOtrgj3VkF7kJC8RfxZbcniV
=8MMn
-----END PGP SIGNATURE-----

--nextPart2092683.BgoAEjVs84--

