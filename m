Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cantor2.suse.de ([195.135.220.15]:58720 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750957Ab3FEBjp (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 4 Jun 2013 21:39:45 -0400
Date: Wed, 5 Jun 2013 11:39:32 +1000
From: NeilBrown <neilb@suse.de>
To: Chuck Lever <chuck.lever@oracle.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH] NFS: Fix keytabless mounts
Message-ID: <20130605113932.2999cf8f@notabene.brown>
In-Reply-To: <20130605004523.14256.24793.stgit@seurat.1015granger.net>
References: <20130605004523.14256.24793.stgit@seurat.1015granger.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=PGP-SHA1;
 boundary="Sig_/Fp9tH8yegbn7.6h/m0sYyKl"; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--Sig_/Fp9tH8yegbn7.6h/m0sYyKl
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

On Tue, 04 Jun 2013 20:56:31 -0400 Chuck Lever <chuck.lever@oracle.com> wro=
te:

> Commit 05f4c350 "NFS: Discover NFSv4 server trunking when mounting"
> Fri Sep 14 17:24:32 2012 introduced Uniform Client String support,
> which forces our NFS client to establish a client ID immediately
> during a mount operation rather than waiting until a user wants to
> open a file.
>=20
> Normally machine credentials (eg. from a keytab) are used to perform
> a mount operation that is protected by Kerberos.  Before 05f4c350,
> SETCLIENTID uses a machine credential, or falls back to a regular
> user's credential if no keytab is available.
>=20
> 05f4c350 seems to have broken the ability to mount with sec=3Dkrb5 on
> clients that don't have a keytab.  Performing SETCLIENTID early
> means there may be no user credential to fall back on, since during
> system initialization no regular user has kinit'd yet.
>=20
> Typically, root is required to kinit in this situation anyway to
> make a sec=3Dkrb5 mount work.  So, the kernel should try to use root's
> credential for lease management if there's no keytab.
>=20
> The new logic should cause the root credential to be tried only
> after both the machine cred and a user cred are found to be
> unavailable.
>=20
> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
> ---
>=20
> Hi Neil-
>=20
> Here's a wacky idea to continue our conversation.  Tested just
> enough to confirm it may do something useful.  Applies to 3.7.
> Something similar might work for 3.8 and 3.9.
>=20

Thanks Chuck!  Looks interesting.
I'll see if I can get it tested by someone who actually depends on this
working.  I'll let you know how it goes.

NeilBrown

--Sig_/Fp9tH8yegbn7.6h/m0sYyKl
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.19 (GNU/Linux)

iQIVAwUBUa6W1Dnsnt1WYoG5AQLCthAAso9PbEPjzkMG+tuW/ycuNAMrX+aURMrB
ryoTsFPnGens3SoQuX67njufy0H5LlMZeuBmf6565kHmCo1ABJxl7dCtyH9BUPws
nTYCvahdBbIWBnPwEXcvb1Uok2XB7t7KN5UAKmVobVKIQHk1gUH7zvWAcLh3UTF6
uuSyTKtyjs229YlvltOWf5CYZU7ezj8oatlisKi2cd+iq5YY1qi+wnZ+LpnGyjKC
NIzf9VohRHbq4rqHJ4lKVhDTywSzBH9TpIiSzBIpwa3+p1+wO5yt0WrD2XaGNFsB
oXMH1c/OHkEqPFo0RqlvgcvojlSiHmkSqE7SYMJxUXvkKA1LSZ445yaevSt5RapD
UdSHbpHpDoH53o6+IV6kWG7ONgbkLaD8+ad41ye+1JIbxzxG+2i4Ym8naUEEq3Ly
dkdfP9UARWo+AikSbHhSjN5is5nsx6pFgUkCzM6TXcvgloScby00mm7+bBiawzrC
TI5Xob2qo5h42Ckn7A6XuAbrchXaOk7FC5glNl2f2nhAUh6SdZHlnJAnZwjLlVl3
czRJxP6+e4ybQAI//HNsA5SZBTg4TcZciH30aSCeMqK490p/Zdpf3dv65xNftCva
e5cKP5DLcCq/DSPaYzqpyhGbUG0GWG389iSjOUBJi8WHrKFsRrYtyBY08liFgjr9
cjr1q0d3K3M=
=ttH7
-----END PGP SIGNATURE-----

--Sig_/Fp9tH8yegbn7.6h/m0sYyKl--
