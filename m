Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qg0-f46.google.com ([209.85.192.46]:58534 "EHLO
	mail-qg0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755530AbaIZP4w (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 26 Sep 2014 11:56:52 -0400
Received: by mail-qg0-f46.google.com with SMTP id q108so9216837qgd.5
        for <linux-nfs@vger.kernel.org>; Fri, 26 Sep 2014 08:56:51 -0700 (PDT)
Date: Fri, 26 Sep 2014 11:56:46 -0400
From: Jeff Layton <jlayton@poochiereds.net>
To: Joschi Brauchle <joschi.brauchle@tum.de>
Cc: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "Fehenberger, Tobias" <tobias.fehenberger@tum.de>,
        "Stinner, Markus" <markus.stinner@tum.de>
Subject: Re: Need help debugging NFSv3+KRB5+PAT (Port Address Translation)
 problem
Message-ID: <20140926115646.684c8e3c@tlielax.poochiereds.net>
In-Reply-To: <542586EB.2040101@tum.de>
References: <542586EB.2040101@tum.de>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 boundary="Sig_/wHuU/+H8noPGJn1Y=zOo0CK"; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--Sig_/wHuU/+H8noPGJn1Y=zOo0CK
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

On Fri, 26 Sep 2014 17:31:55 +0200
Joschi Brauchle <joschi.brauchle@tum.de> wrote:

> Hello everyone,
>=20
> I need some help debugging a NFSv3 + KRB5 + PAT (Port Address=20
> Translation) problem.
>=20
> We have two hosts behind a firewall and an NFSv3 server outside=20
> requiring KRB5 authentication.
>=20
> 1) Client_NAT is using NAT (network address translation),
> 2) Client_PAT is using PAT (port address translation)
> to reach the NFSv3 server through the firewall.
>=20
> Both clients are configured identically in terms of Kerberos and so on.
>=20
> Mounting an NFSv3 share now fails on Client_PAT with the message:
> RPC: server SERVERNAME requires stronger authentication.
> On Client_NAT, mounting succeeds.
>=20
> We strongly suspect the port address translation to be the reason for=20
> the failure, but would need help confirming this and advice on how to=20
> fix it.
>=20
> Please find here the RPC debug logs from
> Client_NAT: http://pastebin.com/9RANqVgY
> Client_PAT: http://pastebin.com/TiscNVqW
> Here is a DIFF between the two: http://pastebin.com/wCg7WyYd
>=20
> I'm grateful for any help on this problem!
>=20
> Best regards,
> Joschi Brauchle

I'm not terribly familiar with the PAT vs. NAT distinction, but many
NFS servers require you to use privileged ports to connect to them. Is
your PAT client having its privileged port converted to a
non-privileged one?

If so (and if the server is Linux-based) then you can try to get around
that by exporting with the "insecure" export option.

--=20
Jeff Layton <jlayton@poochiereds.net>

--Sig_/wHuU/+H8noPGJn1Y=zOo0CK
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBAgAGBQJUJYy+AAoJEAAOaEEZVoIVe5AP/3OK1VStKZABF/kzbRNmrEG8
x3zdXQTiSzXdAOEce2aNvtSX4lu9HgkmRhULjfLEznoBoakpu63RLp4DrOluEbis
LLIjPz96Txo86AxEef5gaQpFSvY/mslyWuSVrwbUA2VDDkIXcuIqXjvfH92rkKX3
RZitcVjJVE9Tdb7agbwUwTAK9IkwExGz9nXn485icyBSzfw+xPYvc8KWs3PoXxA+
tFSnD5hqHZk0H7ZhBKGfsUG0xo92icLmVKD8e2ftqpV9VGIOc+bStVqGYO9aRNe9
jCodwM8boAHoIndlUVV92Gl0BskUWAtBI1zScyDaF0Zd2JjG/Z6U+w3tDf0NjQ1H
DCNFEnf/GujZ4GqeE6GknvfQ0b0CxmOLqBxUNwOr0ADjmZ9t/h+KBXzIXIzzrUW6
QCTTVdQ0p6ZoTSaQg06PfTLz8l0Ni0hmlPYmwN/5v1UKfXh6FlN01WUxCukliFcN
e1YVwMcU09Nrp5q3MRDN/eycExgn9HmKItRoyOTWc9sZQMtp4L2nkWJ4kz+6ehfP
gZVBax8FquLDj84AwXNhVzAr6csH8Ip0op7f+u+6r/LNWvy93zTz25/3Uee0aVL3
O8rNZ0nUSAJwhJI9NnzEIkJgWSq8qD7tbtRe3IicaE3G0VEqkD06jZwbhNALucUb
jApeTw03xe8n36n+bQjl
=ZA3L
-----END PGP SIGNATURE-----

--Sig_/wHuU/+H8noPGJn1Y=zOo0CK--
