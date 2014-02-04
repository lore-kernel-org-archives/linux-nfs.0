Return-Path: linux-nfs-owner@vger.kernel.org
Received: from messinet.com ([50.196.241.75]:59017 "EHLO chicago.messinet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750937AbaBDMss (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 4 Feb 2014 07:48:48 -0500
Received: from localhost (localhost [127.0.0.1])
	by chicago.messinet.com (Postfix) with ESMTP id D847B67B41DD
	for <linux-nfs@vger.kernel.org>; Tue,  4 Feb 2014 06:42:17 -0600 (CST)
Received: from chicago.messinet.com ([127.0.0.1])
	by localhost (chicago.messinet.com [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id gKW-jCL5fk4u for <linux-nfs@vger.kernel.org>;
	Tue,  4 Feb 2014 06:42:17 -0600 (CST)
Received: from linux-ws1.messinet.com (unknown [IPv6:2001:470:c1dc:7779:d6be:d9ff:fe8d:7c1e])
	(using TLSv1 with cipher ECDHE-RSA-AES256-SHA (256/256 bits))
	(Client did not present a certificate)
	by chicago.messinet.com (Postfix) with ESMTPSA id 2BC8267B3F1C
	for <linux-nfs@vger.kernel.org>; Tue,  4 Feb 2014 06:42:17 -0600 (CST)
From: Anthony Messina <amessina@messinet.com>
To: linux-nfs@vger.kernel.org
Subject: Re: [PATCH/RFC: nfs-utils] Common systemd unit files for nfs-utils.
Date: Tue, 04 Feb 2014 06:42:12 -0600
Message-ID: <1757036.O2OPYTypu1@linux-ws1.messinet.com>
In-Reply-To: <52F003A1.3060908@RedHat.com>
References: <20140130172451.7a354ce4@notabene.brown> <52F003A1.3060908@RedHat.com>
MIME-Version: 1.0
Content-Type: multipart/signed; boundary="nextPart8554557.hMBlofD5jx"; micalg="pgp-sha1"; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


--nextPart8554557.hMBlofD5jx
Content-Transfer-Encoding: quoted-printable
Content-Type: text/plain; charset="us-ascii"

On Monday, February 03, 2014 04:01:21 PM Steve Dickson wrote:
> This changes the current API... Today to enable/start this service=20=

> today one does:
>=20
>   systemctl enable nfs-server
>   systemctl start nfs-server
>=20
> which would change to:
>=20
>   systemctl enable nfs-server.target
>   systemctl start nfs-server
>=20
> with the same daemons being started.
> This changed will cause existing scripts to fail...=20
> I guess I don't see the point of having a .target file.=20
>=20
> How is rpc.svcgssd enabled? Since the .service file does
> not have a [Install] section the systemctl enable rpc.svcgssd
> fails.
>=20
> Also how does gss-proxy come to play in all this? Maybe we=20
> just use  gss-proxy by default and retire rpc.svcgssd.

Usually just a quite listener (end-user & small-time sysadmin) on this =
ML...

+1 for gss-proxy by default (for Fedora anyway).  I've been using it=20=

throughout F19 extensively in the KRB5/NFSv4.1 environment with great s=
uccess. =20
I have nfs-secure-server.service "masked" via systemd to prevent it fro=
m being=20
started.

There seems to be only one strange issue I've come across with gss-prox=
y vs.=20
rpc.svcgssd: https://fedorahosted.org/gss-proxy/ticket/98.  This is wit=
h=20
regard to how access for the "nfsnobody" user is handled.  The ticket a=
ttempts=20
to show that with rpc.svcgssd, a host with host credentials and a user =
without=20
credentials can still access NFS shares with 0755 directories and 0644 =
files=20
(via the host credentials and mapped to the nfsnobody user).  With gss-=
proxy,=20
I had to create user credentials for kojibuilder@REALM because the acce=
ss=20
wasn't allowed via the nfsnobody path.  I'm not sure if this is resolve=
d, or=20
by design, etc.  But it is the only issue I've seen with gss-proxy vs.=20=

rpc.svcgssd.

Thanks.  -A

=2D-=20
Anthony - http://messinet.com - http://messinet.com/~amessina/gallery
8F89 5E72 8DF0 BCF0 10BE 9967 92DC 35DC B001 4A4E

--nextPart8554557.hMBlofD5jx
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part.
Content-Transfer-Encoding: 7Bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.22 (GNU/Linux)

iEYEABECAAYFAlLw4CgACgkQktw13LABSk7G1gCaA9/F9QR5AkglntbbNmjSqwyX
SZgAoKdgUoqN+ebBn+ky5Ul6IKhOyQ3i
=gauy
-----END PGP SIGNATURE-----

--nextPart8554557.hMBlofD5jx--

