Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pa0-f53.google.com ([209.85.220.53]:35390 "EHLO
	mail-pa0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753314AbbKZWG1 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 26 Nov 2015 17:06:27 -0500
Received: by pacej9 with SMTP id ej9so95214346pac.2
        for <linux-nfs@vger.kernel.org>; Thu, 26 Nov 2015 14:06:27 -0800 (PST)
Subject: Re: [RFC][PATCH 00/12] Enhanced file stat system call
Mime-Version: 1.0 (Mac OS X Mail 8.2 \(2104\))
Content-Type: multipart/signed; boundary="Apple-Mail=_0D35D9D1-1072-40EB-A0C2-891C4163E436"; protocol="application/pgp-signature"; micalg=pgp-sha256
From: Andreas Dilger <adilger@dilger.ca>
In-Reply-To: <7342.1448551183@warthog.procyon.org.uk>
Date: Thu, 26 Nov 2015 15:06:19 -0700
Cc: Christoph Hellwig <hch@infradead.org>, arnd@arndb.de,
        linux-afs@vger.kernel.org, linux-nfs@vger.kernel.org,
        linux-cifs@vger.kernel.org, samba-technical@lists.samba.org,
        linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        linux-ext4@vger.kernel.org
Message-Id: <46109C88-01C8-40A1-B44B-B76BF8C119C7@dilger.ca>
References: <20151124081149.GA8840@infradead.org> <20151120145422.18930.72662.stgit@warthog.procyon.org.uk> <7342.1448551183@warthog.procyon.org.uk>
To: David Howells <dhowells@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


--Apple-Mail=_0D35D9D1-1072-40EB-A0C2-891C4163E436
Content-Transfer-Encoding: quoted-printable
Content-Type: text/plain;
	charset=us-ascii

On Nov 26, 2015, at 8:19 AM, David Howells <dhowells@redhat.com> wrote:
>=20
> Christoph Hellwig <hch@infradead.org> wrote:
>=20
>> from a quick look the statx bits looks fine in general.  I think Ted
>> last time had a problem with the IOC flag allocation, so you might
>> want to ping him.
>=20
> Yeah - he commented on that.
>=20
>> But fsinfo with the multiplexer and the void pointer is just =
horrible.
>> What were you thinking there?
>=20
> I think the fsinfo data struct probably wants splitting up.

Could we separate the statx() and fsinfo() submissions so that this =
doesn't
block statx() landing indefinitely?  I think people are generally in =
support
of statx() as it is today, and it's been _sooo_ long in coming that I'd =
hate
to see it delayed further.  The statx() syscall definitely has value =
without
fsinfo() to improve the life of network filesystems.

Cheers, Andreas

>  Now this could be
> done in a number of ways, including:
>=20
> (1) By adding multiple syscalls (statfsx, fsinfo, netfsinfo, ...) but =
each
>     one needs a bit in the kernel to handle the basics (path/fd =
lookup,
>     security check, buffer allocation and freeing, ...) which could =
all be in
>     common - hence the mux method.
>=20
> (2) Adding an argument to the fsinfo syscall since it has at least one
>     syscall argument spare.
>=20
> (3) Offloading some of the bits to standardised xattr calls.  The =
large
>     string fields (domain name, volume name, ...) would seem to be =
obvious
>     candidates for this.
>=20
> Given that the core VFS gets to manage the contents of the buffer, it
> shouldn't be as controversial as pioctl().
>=20
> David
> --
> To unsubscribe from this list: send the line "unsubscribe linux-ext4" =
in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html


Cheers, Andreas






--Apple-Mail=_0D35D9D1-1072-40EB-A0C2-891C4163E436
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
	filename=signature.asc
Content-Type: application/pgp-signature;
	name=signature.asc
Content-Description: Message signed with OpenPGP using GPGMail

-----BEGIN PGP SIGNATURE-----
Comment: GPGTools - http://gpgtools.org

iQIVAwUBVleCXXKl2rkXzB/gAQjJbA//cBhy5Ew7OJ1xn4MLdvpzbE8AKUbG7RmY
fopEv+iiYM4GhHSAApH+/G++Q4DVhXc6EgCpdkMJmoPavNTgr5LSMNyzd7HUhFPh
iaGsgB90GagjLazR8B5X8ESQfxxgJrV8ytugrz/OC08Myz/0DW5qrd1E3/Q6oYok
iX2WctbZJN6OfrBGbxLVqz0iGmyTu9ky5Zgwt1FTVHKlgf4aUf7I8TKMPV6WxsGh
Z18ZJZ0V7a30ANILncW5PdU+hB09KLhxyIaauCsLeqJhc/ncWBL9ZB73+TlNGyr1
i9BELLXdMSvNPPpY0PzV1cuBRuErcTIEiBSgElLz3KZUuQZ0YReowCN9juqNUUTG
CdDq/TkCob3tMKxerb359GHpr+Uuk/cRMZf2d/SYHHv+TQh6WeaUS61wXq96lf8x
rrHReu+hTuWgtFQj07Onzs8SPYYd7KlgteCtzPNdV214glFOayVAGpizYIhxF0sY
cTaoT/MDThrXHy7NwOAE3Aun39D9uqEeVn0RKmNiCenfpIy6W4D8GZLIG9rre2YQ
44UElWKofhz9Z+rD2TYyG0GzIYaxhiG0cdBqMiidkplyoWBfpr188hwcd/U/Na9r
3hmqc87SPplcTxIUnpFVvnTc8oIt9eeI/cCdCM7jncw9LdjyWlPAPjCUa4/hmXUY
AtST8EW4QZU=
=Z4o0
-----END PGP SIGNATURE-----

--Apple-Mail=_0D35D9D1-1072-40EB-A0C2-891C4163E436--
