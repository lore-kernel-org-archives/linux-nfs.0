Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp.gentoo.org ([140.211.166.183]:59624 "EHLO smtp.gentoo.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757721AbcCUTZF (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 21 Mar 2016 15:25:05 -0400
Subject: Re: Making an interface for alternative data streams
To: Christoph Hellwig <hch@infradead.org>
References: <56F03945.40208@gentoo.org> <20160321181825.GB10892@infradead.org>
 <56F0429D.7070708@gentoo.org>
Cc: linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org
From: Richard Yao <ryao@gentoo.org>
Message-ID: <56F048CB.9040303@gentoo.org>
Date: Mon, 21 Mar 2016 15:17:31 -0400
MIME-Version: 1.0
In-Reply-To: <56F0429D.7070708@gentoo.org>
Content-Type: multipart/signed; micalg=pgp-sha256;
 protocol="application/pgp-signature";
 boundary="spNlGAOgqupSr5T42nTeN98WRQ0xluW2d"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--spNlGAOgqupSr5T42nTeN98WRQ0xluW2d
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: quoted-printable

On 03/21/2016 02:51 PM, Richard Yao wrote:
> On 03/21/2016 02:18 PM, Christoph Hellwig wrote:
>> On Mon, Mar 21, 2016 at 02:11:17PM -0400, Richard Yao wrote:
>>> I am thinking of implementing Solaris-style alternative data streams =
in
>>> the ZFSOnLinux driver via an ioctl and writing a compatibility shim s=
o
>>> that software written to use O_XATTR can be trivially adapted to use =
the
>>> interface.
>>
>> Even if alternate data streams weren't braindead to start with we are
>> not going to support your vioation of our copyrights Richard.  Please =
go
>> away from our mailing lists.
>=20
> I have not violated your copyrights. So far, both the SFC and SFLC are
> in agreement on that.
>=20

On second thought, this deserves a more detailed response. While I have
spoken to both the SFLC and SFC in the past month, I have spoken to
others in the past. They include an attorney at the DoJ, the FSFE at
LinuxCon Europe 2014 and the Linux Foundation's general consul at
Linuxcon Europe 2014. Not once has any of these organizations ever
accused me of violating Linux copyrights.

All of my work (sans one userland thing I did to help the elderly while
I was at SUNYSB) is under open source licenses. I even have some patches
in the mainline tree. I have done the best that I can to respect the
license of every project to which I have contributed and until today,
there has never been a single claim that I personally violated them,
even in matters of disagreement on things like distribution of binary LKM=
s.

I understand that the SFC is representing you against VMWare. I have
been in touch with them. They have told me that they do not believe that
I have violated your copyright. If your attorneys have changed their
minds, please let me know so that I can forward your complaint to my
lawyers. Otherwise, please refrain from making such remarks.

That said, while my mainline contributions have been small because much
of my work being both out-of-tree and subject to the limitations of
older kernels, I intend to contribute more in the future and I have no
intention of going away.


--spNlGAOgqupSr5T42nTeN98WRQ0xluW2d
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBCAAGBQJW8EjPAAoJECDuEZm+6ExkvCcP/iaTWG0v9naJ9WKPEL9B0bo2
DXnX4y1FW+GwojYr1V/NmzqFk8xFcVmjCJhiv9qAOEa/j6wuRYKvx7NCPZ1BOH1U
1TOQX50uVPxgTUi30Fi6sTHTTFDYtWvvx2Tf7wBvcHUT93R3HUZjqVKkHkUzVDSu
l2sthBPyfMOG0EvRG+SCUG9z6ueA3FMyXdVYmSFBvyXt6aEsGvMx7Cxa2XTOqBtE
Uffv+FxQ2qXFHa9W5MYANCdYRx/zvrp3tsbTH+HcQy7yb60UHlamf58HMAPa8u0o
Y7YuTr4DZ9Ink8C++2L7wgbxlktGJwTYNu/ZfoHS4MdIihlgYeCubtnxWWRTzbAg
eyrNFvVgViXavCRELuVWzqaJHfdemFCTvVk1n3UqmThE6B8WYXqkyKZEiWh3VsHk
7TbsnakvpoU7lQDrb94t3y6l8yc216vsBjGty123PI0wEcqiXxKPz+PaGsWhmuWr
zaDVHXKjUIq/uLWzykkM++YDRoScjF95WBsseCqOqRUum7lkKRShOPFEBbenABI+
P5dpjLwu3ArICAy8ApXbXMCaXDhOaqzoODp885PPAfgVjfe+ImDf0Tkm0EYPm/8v
NsYxPfKp18jPqRVvsAvR5dfU951RBXbIYY1t0DH56srptkQUFC3FS7OEEulVLJcK
panc9S8N4x1SiN+yfjh7
=RY6/
-----END PGP SIGNATURE-----

--spNlGAOgqupSr5T42nTeN98WRQ0xluW2d--
