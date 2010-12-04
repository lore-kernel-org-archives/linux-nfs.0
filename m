Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:63817 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755121Ab0LDXgc (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 4 Dec 2010 18:36:32 -0500
Received: by bwz15 with SMTP id 15so9493378bwz.19
        for <linux-nfs@vger.kernel.org>; Sat, 04 Dec 2010 15:36:31 -0800 (PST)
Date: Sun, 5 Dec 2010 00:36:28 +0100
From: rauch.holger@googlemail.com
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: Holger Rauch <rauch.holger@googlemail.com>, linux-nfs@vger.kernel.org
Subject: Re: NFSv4: rpc.svcgssd claims that no machine credentials exist
Message-ID: <20101204233627.GD5862@gmail.com>
References: <20101202020509.GA6526@gmail.com>
 <1291257241.6609.104.camel@heimdal.trondhjem.org>
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="H8ygTp4AXg6deix2"
In-Reply-To: <1291257241.6609.104.camel@heimdal.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

--H8ygTp4AXg6deix2
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi Trond,

thanks for your reply. Please see my answer(s) below.

On Wed, 01 Dec 2010, Trond Myklebust wrote:

> [...]=20
> ::1	my.host.name
>=20
> would completely screw up MIT kerberos's (and hence rpc.svcgssd's)
> ability to figure out the correct fdqn for my server.

Ok, but I have IPv6 disabled and thus also no such line in my /etc/hosts
file since I removed it manually.

> [...]
> Unfortunately, NetworkManager loves to add 'my.host.name' to any
> existing '::1' line. The only solution I've found so far is to disable
> NetworkManager on my server.

I use Debian which doesn't use NetworkManager.

>=20
> The other interesting rpcsec bug I found recently had to do with
> selinux: apparently MIT kerberos also likes to create a
> [...]

selinux is disabled as well.

> [...]

FYI, I also ran strace on the mentioned invocation of rpc.svcgssd but I
couldn't figure out the principal name rpc.svcgssd is really looking for.
How can I figure this out? Do I need some to enable debug logging in my
/etc/krb5.conf file? Judging from your explanation, this seems to be
an MIT Kerberos<->host name resolution issue, rather than an NFSv4
rpc.svcgssd issue. Would you suggest I also send this to the MIT Kerberos
mailing list?

Thanks in advance & kind regards,

   Holger

--H8ygTp4AXg6deix2
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)

iEYEARECAAYFAkz60HsACgkQbiVtWpZdKQILowCeNMm9zJPlwBuKf8ZGhPfZkY2n
Pf0AoIuR03KPJLr0chQWb+ILn5UP6Vv8
=WBvI
-----END PGP SIGNATURE-----

--H8ygTp4AXg6deix2--
