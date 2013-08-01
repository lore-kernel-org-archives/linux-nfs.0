Return-Path: linux-nfs-owner@vger.kernel.org
Received: from che.mayfirst.org ([209.234.253.108]:50628 "EHLO
	che.mayfirst.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756334Ab3HASBW (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 1 Aug 2013 14:01:22 -0400
Message-ID: <51FAA0CC.7010106@fifthhorseman.net>
Date: Thu, 01 Aug 2013 13:54:20 -0400
From: Daniel Kahn Gillmor <dkg@fifthhorseman.net>
MIME-Version: 1.0
To: David Howells <dhowells@redhat.com>
CC: keyrings@linux-nfs.org, linux-nfs@vger.kernel.org, krbdev@mit.edu,
        "Serge E. Hallyn" <serge.hallyn@ubuntu.com>,
        linux-kernel@vger.kernel.org, simo@redhat.com,
        "Eric W. Biederman" <ebiederm@xmission.com>
Subject: Re: [PATCH 2/2] KEYS: Add per-user_namespace registers for persistent
 per-UID kerberos caches
References: <20130801173846.28023.19009.stgit@warthog.procyon.org.uk> <20130801173902.28023.68819.stgit@warthog.procyon.org.uk>
In-Reply-To: <20130801173902.28023.68819.stgit@warthog.procyon.org.uk>
Content-Type: multipart/signed; micalg=pgp-sha512;
 protocol="application/pgp-signature";
 boundary="----enig2HPEGVJSWILCKRSSWXCEJ"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
------enig2HPEGVJSWILCKRSSWXCEJ
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

On 08/01/2013 01:39 PM, David Howells wrote:
> The uid is -1 or the user's own UID for the user's own cache or the uid=
 of some
> other user's cache (requires CAP_SETUID).  This permits rpc.gssd or wha=
tever to
> mess with the cache.

Is the goal here eventually to be able to avoid the upcall to rpc.gssd
entirely?  It seems a little bit roundabout to have the kernel call up
into userspace for the credentials, only to talk to a process which then
calls back into the kernel for something that the kernel has already
well-defined internally.

It seems like a non-privileged user could use this to store arbitrary
data in this keyring as a way of hiding what would otherwise be
filesystem activity or using it for some sort of odd/sneaky IPC
mechanism.  Is this an intentional side effect?

Sorry if these are obvious questions.  feel free to point me to
already-documented answers if they exist.

Thanks for all your work on this!

Regards,

	--dkg


------enig2HPEGVJSWILCKRSSWXCEJ
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.14 (GNU/Linux)
Comment: Using GnuPG with Icedove - http://www.enigmail.net/

iQJ8BAEBCgBmBQJR+qDMXxSAAAAAAC4AKGlzc3Vlci1mcHJAbm90YXRpb25zLm9w
ZW5wZ3AuZmlmdGhob3JzZW1hbi5uZXRFQjk2OTEyODdBN0FEREUzNzU3RDkxMUVB
NTI0MDFCMTFCRkRGQTVDAAoJEKUkAbEb/fpciGkP/1UCt9/H0KQVVaeSjm9rl4EJ
hmpUVJWHm8yPleOoKZxhuMmZMGhzxhDCt2q1itj9iBdBFCxdKVn3I6XZAEQoRDnW
l4Ys6hZ9RvZnfNd5c7W5Nhi8kRxDWAaa7pcuVYsCfWW5T+Z2hROVBqnW6IeewYn8
BAe7ajZfWB7mR4IZX12fxhX2yUa0pFlMEqDxmA+h67TmgQuF2nudYpMGpzNZYXxH
s5QJohgfPpldZuFBgjpEQCWtWIxdCrmv8UoljuLekUT4rwevIE/T9pJBWSExFimI
ehnmYlF6SUU0pzoAjtIFv+XO1y+5Yeizstqlu5gu0LqjjQEaZ1+aknb5YVpVb0Xh
/tA5EMnToH486CC09ZOEywN3jTjrX9xwddVijqyFSCp3+EPprVjv+A88WsLXrjE2
25xXDQ5MOdaR2n9Tth06BZiZM+7xmiNVmsCwWeB40AH+UvcZR/y0JMLn/Bq8QEKV
CroZBiCfHqF7/+cHlDwdK7JtSySe2pv8m6KQs13PTbX610gR3d+oSh7YINKKceGc
k9DJvMo7d6gQrChR0i3RQKDnYEDD7g86zGM4QuwQzSSc6eZ+DDBpYR2XmTY19YgB
7538qD/EbF1D6s0wTE+b1KfTrulv8/2Fp3sflVDY9753BZCK8uDmPJlgZU1XanMv
3oQTGIvPL+sotqlhj1S0
=TWzs
-----END PGP SIGNATURE-----

------enig2HPEGVJSWILCKRSSWXCEJ--
