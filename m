Return-Path: linux-nfs-owner@vger.kernel.org
Received: from ppsw-52.csi.cam.ac.uk ([131.111.8.152]:37374 "EHLO
	ppsw-52.csi.cam.ac.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752483AbbBYOTw (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 25 Feb 2015 09:19:52 -0500
Received: from grapevine.cl.cam.ac.uk ([128.232.65.18]:47488)
	by ppsw-52.csi.cam.ac.uk (smtp.hermes.cam.ac.uk [131.111.8.159]:465)
	with esmtpsa (PLAIN:drt24) (TLSv1.2:DHE-RSA-AES128-SHA:128)
	id 1YQcVO-00076U-D2 (Exim 4.82_3-c0e5623) for linux-nfs@vger.kernel.org
	(return-path <drt24@cam.ac.uk>); Wed, 25 Feb 2015 14:00:02 +0000
Message-ID: <54EDD559.4090804@cam.ac.uk>
Date: Wed, 25 Feb 2015 13:59:53 +0000
From: Daniel Thomas <drt24@cam.ac.uk>
Reply-To: drt24@cam.ac.uk
MIME-Version: 1.0
To: linux-nfs@vger.kernel.org
Subject: NFS4 client port for file delegations
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="EOgX6A030hVQX8H9WvAPM7hLimbxPjpgu"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--EOgX6A030hVQX8H9WvAPM7hLimbxPjpgu
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable

We have a Linux NFS server (using ZFS) which supports NFS4. It uses
fixed ports for everything and those ports are allowed through the
firewall. We have a number of Linux clients which use this and other NFS
servers, they have a DROP ALL for all all packets arriving on
non-whitelisted ports.

I think that file delegations might not be working due to callbacks not
succeeding because the client port specified in SETCLIENTID by the
client is blocked by the firewall.

I have a couple of questions:

How do I check whether file delegations are working properly? Munin
graphs indicate 0 calls for some of the names which sound like they are
to do with delegations such as delagreturn or delagpurge but is there
some way of checking conclusively?

How do I specify what client port to provide in SETCLIENTID, there
should be some mount option? I can't find it. Or if it is a well defined
number, what is it?

Any pointers to answers?

Thank you,

Daniel


--EOgX6A030hVQX8H9WvAPM7hLimbxPjpgu
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBAgAGBQJU7dVhAAoJEFUUNdXXSTPZLgwP/1Sq4AqRv1Clpm9y5AVDz8ul
P2Q1W3ssE7T6Db6frl50yt16NPfzJ9UxO8s7G8sU3MEOR3InLRUqzjE9hHqtwkzT
UiP3ukFdQi5fjeJs7C2aVLdIDXx1DC0WvFdeWLKeagqlnNhGPcM1pCYIb6yy1bUd
VYW5O6UHiy8Zolwd1Y8QFeSM+tcnqvUi1Thqm94l2+7S50Fx4wyv3FnVvOdtg4/X
SKYDnt4g6+3WakEeOm2g6JVspE/MjY5YL+4UPaKX/YWebJOYWc1OujRoB9hHFjF/
V9exuTxfPCjh3G2q2/yG+Iz+eu1W5DVQZsMxWnE17i7Z/MZGLCN1IYRW3Z4KsQ2L
z47Fv/r/11gZtAlQuYAj+D/zzGEUblhXoAvZEc4BPZ21vmSQq/HbtkwyLq7zSB/w
pmHHMXxBFOb5WjhtneWUloRpFbbzWmSHuRmzI9WwWKaimjplo2CLhV3FZpJkv7Xo
lB3tfum7NY8lt7GDGyCXtxiUcUoknn6YXqgQgn0gtfeiqEdAH5U7UBG5JTK3ZbkC
+D288hUq6DvEU3uFNl0vT+UDUr7IoaR81e30eCcB1g1bpqZFXpSx8UTax3OtHNtq
ZEY/hoImc+vZz5bL9jYh8yS/lwIN3K2bwJhV39KHJuHYbEIANVgTxjDdeexq7fD9
GJ9gHNg7n908ojcbqKSb
=tP8/
-----END PGP SIGNATURE-----

--EOgX6A030hVQX8H9WvAPM7hLimbxPjpgu--
