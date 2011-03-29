Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from orca.ele.uri.edu ([131.128.51.63]:48902 "EHLO orca.ele.uri.edu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754516Ab1C2Us1 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 29 Mar 2011 16:48:27 -0400
From: "Will Simoneau" <simoneau@ele.uri.edu>
Date: Tue, 29 Mar 2011 16:24:08 -0400
To: Chuck Lever <chuck.lever@oracle.com>
Cc: Belisko Marek <marek.belisko@gmail.com>, Trond.Myklebust@netapp.com,
        broonie@opensource.wolfsonmicro.com, bdowning@lavos.net,
        linux-nfs@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>
Subject: Re: [bisect] kernel 2.6.38 regression with root nfs mounting
Message-ID: <20110329202408.GM1966@ele.uri.edu>
References: <AANLkTimjmdi8sFTTjSPerOVgHQ+pjjwwMvCUX3AJ16At@mail.gmail.com>
 <43F07477-9075-444D-9BBB-368650538EA8@oracle.com>
 <AANLkTinHUQkBvcvh9APVutOqcKOug6CA066kS_O4p4Tq@mail.gmail.com>
 <DC2B75F8-382A-4AFB-9286-4A55EAF7609A@oracle.com>
 <AANLkTikWyUbtHbbnSh8NBeP3mT4jDOu5Pbtfw=TwKrwE@mail.gmail.com>
 <977C528D-4540-4EB2-92F9-6DAF357D8C81@oracle.com>
 <AANLkTik0UgB+k2i=E5t9XcF50SoSr_iXaFYrhctDx0FJ@mail.gmail.com>
 <8F19F0FE-0800-4C45-B857-1C682CF6A30D@oracle.com>
 <AANLkTin4-+Mc7d0a-XnZvPKL-C_Cf+Kmnm1Bmh1XZZu4@mail.gmail.com>
 <4AD2FFC1-E777-4C29-8718-4E1717EFCD86@oracle.com>
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="BnCwdHgQ2ZomtW9r"
In-Reply-To: <4AD2FFC1-E777-4C29-8718-4E1717EFCD86@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

--BnCwdHgQ2ZomtW9r
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On 09:26 Fri 25 Mar     , Chuck Lever wrote:
>=20
> According to the trace, the mount succeeds, and NFS requests are working.=
  However, the server's replies to READ requests are not being seen by the =
client.  Something on the client host or in the network is dropping them.  =
I see successful 16KB reads, but 32KB reads do not work.  Check your client=
 for packet filtering (either intentional filtering, or accidental filterin=
g due to configuration issues).
>=20
> I'll revisit the mount option defaults for NFSROOT again.

I have encountered the same problem as Belisko, using an FPGA board I am
working on (CPU is a mipsel r4k clone). 2.6.38-rc8 nfsroot works fine,
2.6.38 hangs while starting init. I can see read replies going out from
the NFS server but the client does not seem to receive them.

Interestingly, we are both using DM9000 network chips. I wonder if there
is a UDP-related problem on the DM9000. I will play with my
configuration a little more (in particular testing proto=3Dtcp and revert
of 53d4737580535e073963b91ce87d4216e434fab5) but my guess is the DM9000
driver/chip is to blame. The DM9000A on my board has 16K of on-chip SRAM
used for its RX/TX buffers which may be playing a part in the problem.

--BnCwdHgQ2ZomtW9r
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.16 (GNU/Linux)

iEYEARECAAYFAk2SP+gACgkQLYBaX8VDLLUC4ACdGU1KyfOH4zbNEhWGPaTqz6Mx
Az4AoKoUbHa/C9U6gUdxJpX1jUAJNUY9
=2Biu
-----END PGP SIGNATURE-----

--BnCwdHgQ2ZomtW9r--
