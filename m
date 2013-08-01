Return-Path: linux-nfs-owner@vger.kernel.org
Received: from che.mayfirst.org ([209.234.253.108]:50652 "EHLO
	che.mayfirst.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752286Ab3HAS4D (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 1 Aug 2013 14:56:03 -0400
Message-ID: <51FAAF3D.3010806@fifthhorseman.net>
Date: Thu, 01 Aug 2013 14:55:57 -0400
From: Daniel Kahn Gillmor <dkg@fifthhorseman.net>
MIME-Version: 1.0
To: Simo Sorce <simo@redhat.com>
CC: David Howells <dhowells@redhat.com>, keyrings@linux-nfs.org,
        "Eric W. Biederman" <ebiederm@xmission.com>,
        "Serge E. Hallyn" <serge.hallyn@ubuntu.com>, linux-nfs@vger.kernel.org,
        krbdev@mit.edu, linux-kernel@vger.kernel.org
Subject: Re: [PATCH 2/2] KEYS: Add per-user_namespace registers for persistent
 per-UID kerberos caches
References: <20130801173846.28023.19009.stgit@warthog.procyon.org.uk>  <20130801173902.28023.68819.stgit@warthog.procyon.org.uk>  <51FAA0CC.7010106@fifthhorseman.net> <1375381798.15733.207.camel@willson.li.ssimo.org>
In-Reply-To: <1375381798.15733.207.camel@willson.li.ssimo.org>
Content-Type: multipart/signed; micalg=pgp-sha512;
 protocol="application/pgp-signature";
 boundary="----enig2WHFTLRFBFVREFOWVNKHG"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
------enig2WHFTLRFBFVREFOWVNKHG
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

On 08/01/2013 02:29 PM, Simo Sorce wrote:

> It's called 'abstraction' :-)

Good, I like abstraction :)

>> It seems like a non-privileged user could use this to store arbitrary
>> data in this keyring as a way of hiding what would otherwise be
>> filesystem activity or using it for some sort of odd/sneaky IPC
>> mechanism.  Is this an intentional side effect?
>=20
> Just as a user can add data into a shm segment ?
> Is there any difference ?

I guess this raises the question from a different perspective: if the
kernel already supports arbitrary shm segments, filesystem locations,
etc, which can be used for storing/passing opaque bytestrings between
different parts of userspace, what advantages do we gain from having
this new specific mechanism in the kernel?  Why couldn't those parts of
userspace just rely on already-existing mechanisms instead of
introducing this new interface?

Again, i'm not trying to say it's a bad idea; there's probably a
big-picture piece of the puzzle that i don't see that makes this all
obvious.  i just want to understand what it is.  Thanks for your
explanations!

Regards,

	--dkg


------enig2WHFTLRFBFVREFOWVNKHG
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.14 (GNU/Linux)
Comment: Using GnuPG with Icedove - http://www.enigmail.net/

iQJ8BAEBCgBmBQJR+q89XxSAAAAAAC4AKGlzc3Vlci1mcHJAbm90YXRpb25zLm9w
ZW5wZ3AuZmlmdGhob3JzZW1hbi5uZXRFQjk2OTEyODdBN0FEREUzNzU3RDkxMUVB
NTI0MDFCMTFCRkRGQTVDAAoJEKUkAbEb/fpccfsP/1YMyvzpT0lg/Hjk7lcZQNNn
dlsMz+CjD/WMSFao4Y+lYjjXXb9YF0FQFyBrAFDS5RzEyDQzz2zuuEKxv6AM3omL
BHFXoPJGeJ5VlbpChJKB9vX7JK2wt8HglO6CdtkSBDqcgwJ/NuvH3SVujqlzuUGk
/y2pfS2EbgN5CHnpq/okoX4b80kfPmAo1NmCG6nxPSHhVTDE2aol67HyjmFENFeQ
v1nFj8NuIuY2uMO/d1wHTfdCxdKiFKLVjuaJyWTuDaMiDbnoGBAsx/99NuBA/6Z5
WkmkwKQT+fJrWbNFxHBsLuHyHiPL44RQ9HPKrOQ0rS/JVXX9VnHivN1IIplI7Qgd
YdtB+SQqA+MBjavF+whg458wmiFadGQpXgFQrBYK0fsXHiZartFrbAT5+lhnkXAE
+dibhXywP0B4cKsdKJDUcOijrTkgFAYkA39NdVFdVtcinjxmVBQBJgP2o2dtgWJZ
IXQFM1JTdziiyuvk6MzNQLAGUjl/zoj4zzQKvRxElQ8HXWK5Yfxn9Ayb4Aa9uDJj
8+/TuCNaD/0ABp7Noz+JPu2NTlF0aylHK03wjFf3JOD7zj4jY/Nt62u1EqPPmz6M
NvIeNSg40O7OR2XRUtRMKWMmDm7Zz0ytPto3/Vb5s73sSoXJCR1zEIfF6IaK9kHk
mg4QtsNWAh1CzXHap4T5
=qcNT
-----END PGP SIGNATURE-----

------enig2WHFTLRFBFVREFOWVNKHG--
