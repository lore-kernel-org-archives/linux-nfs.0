Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pa0-f52.google.com ([209.85.220.52]:36607 "EHLO
	mail-pa0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752895AbbKZWKX (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 26 Nov 2015 17:10:23 -0500
Received: by pacdm15 with SMTP id dm15so95362525pac.3
        for <linux-nfs@vger.kernel.org>; Thu, 26 Nov 2015 14:10:23 -0800 (PST)
Subject: Re: [PATCH 02/12] statx: Provide IOC flags for Windows fs attributes
Mime-Version: 1.0 (Mac OS X Mail 8.2 \(2104\))
Content-Type: multipart/signed; boundary="Apple-Mail=_11804957-1D5E-42D1-9FC2-1FF410D3FF51"; protocol="application/pgp-signature"; micalg=pgp-sha256
From: Andreas Dilger <adilger@dilger.ca>
In-Reply-To: <7976.1448552129@warthog.procyon.org.uk>
Date: Thu, 26 Nov 2015 15:10:16 -0700
Cc: "Theodore Ts'o" <tytso@mit.edu>, arnd@arndb.de, linux-afs@vger.kernel.org,
        linux-nfs@vger.kernel.org, linux-cifs@vger.kernel.org,
        samba-technical@lists.samba.org, linux-kernel@vger.kernel.org,
        linux-fsdevel@vger.kernel.org, linux-ext4@vger.kernel.org
Message-Id: <591F46C1-DBA1-434A-9BD1-1D45DD94611B@dilger.ca>
References: <20151124195256.GB3482@thunk.org> <20151120145422.18930.72662.stgit@warthog.procyon.org.uk> <20151120145447.18930.5308.stgit@warthog.procyon.org.uk> <7976.1448552129@warthog.procyon.org.uk>
To: David Howells <dhowells@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


--Apple-Mail=_11804957-1D5E-42D1-9FC2-1FF410D3FF51
Content-Transfer-Encoding: quoted-printable
Content-Type: text/plain;
	charset=us-ascii

On Nov 26, 2015, at 8:35 AM, David Howells <dhowells@redhat.com> wrote:
>=20
> Theodore Ts'o <tytso@mit.edu> wrote:
>=20
>> As a result, I would suggest that we not try to use the
>> FS_IOC_[GS]ETFLAGS number scheme for any new interface, so we're at
>> least not making a bad situation worse.
>>=20
>> The only reason why some other file systems have chosen to use
>> FS_IOC_[GS]ETFLAGS, instead of defining their own ioctl, is so they
>> can use lsattr/chattr from e2fsprogs instead of creating their own
>> utility.  But for statx, there isn't a good reason use the same flags
>> number space.  At the very least, can we use a new flags field for =
the
>> Windows file attributes?  It's not like lsattr/chattr has the ability
>> to set those flags today anyway.  So we might as well use a new flags
>> field and a new flags numberspace for them.
>=20
> Hmmm...  I was trying to make it so that these bits would be saved to =
disk as
> part of the IOC flags so that Samba could make use of them.  I guess =
they'll
> have to be stored in an xattr instead.

The flags can be part of the same flags word in the statx() API, and how =
they
are stored on disk is a filesystem implementation detail.  In some =
cases, not
all of the flags can be stored on disk (e.g. FAT or whatever) and an =
error
will be returned.  In other cases they can be stored efficiently as bits =
in
the inode, and other filesystems may chose to store them as internal =
xattrs.
That shouldn't be the concern of the statx() syscall.

Cheers, Andreas






--Apple-Mail=_11804957-1D5E-42D1-9FC2-1FF410D3FF51
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
	filename=signature.asc
Content-Type: application/pgp-signature;
	name=signature.asc
Content-Description: Message signed with OpenPGP using GPGMail

-----BEGIN PGP SIGNATURE-----
Comment: GPGTools - http://gpgtools.org

iQIVAwUBVleDSHKl2rkXzB/gAQjCNA//Zcdl0r/qkNmEYtHIORP91tJ5V7sEOdlA
89Gj88sPqOMw6KZ3N+yFfe+JXsnJd8lCKcXEJTIwL3bwSGQ07s77x6d78QF9YVwB
kvXaY/AwfUHJJjANP6LsIWXlsgIh0t6p4DdXiJinFxEsMeijTbrgsDRhBaQYNRmA
fWlAcEuYcrHjc6oBbdvx0qW4zKuFqtyovP3sj3hH01ltgbipRwrkzK9z7aBfl9kg
DHqzkopRCwRM6FQVENqHJtyalUiJqo92YjrkTkzN5s7SOpd2fehgW8x7Aw1w9xT/
SgYJKj/Ni/bYQu2tJvYmzfs8oh7DMAklMFedR1c2vkK5RBnTnVBdOJ6nr8QH/rVP
8LX9JzXGfgvPG1mKNd+cSn3OmdbCIeyQFYAWQJrHBibjAHpWuzq4IAxfybYvYGO3
cgL3ie9wFQ0yGwsQqOy1XL56ZnfG4CO9y6hMVxIdggi+N/aEbKEL4q7NWNL/FYOG
77kFAdXnTKAHbr27TCdjtjAY26H868XCeRp3Yo+QzHDjsT8+dCOpSUwPPuwuBf+f
aADRTSNgY+spoAUGEBY0r1q6ADfivqmZIQLZoyKDH1N28SINhVuIWOki9TqqkVOA
MpCFHm1uIFP0PHKqT/aMzdy9PCAPMzwMqcJwFgRvcMf0pMzVORbbBum0TCDCG7Sd
BY4Qo+Yr3lI=
=lTnh
-----END PGP SIGNATURE-----

--Apple-Mail=_11804957-1D5E-42D1-9FC2-1FF410D3FF51--
