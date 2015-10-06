Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pa0-f42.google.com ([209.85.220.42]:34522 "EHLO
	mail-pa0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753100AbbJFU0S (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 6 Oct 2015 16:26:18 -0400
Received: by padhy16 with SMTP id hy16so79642719pad.1
        for <linux-nfs@vger.kernel.org>; Tue, 06 Oct 2015 13:26:17 -0700 (PDT)
Subject: Re: [PATCH v8 00/41] Richacls
Mime-Version: 1.0 (Mac OS X Mail 8.2 \(2104\))
Content-Type: multipart/signed; boundary="Apple-Mail=_2BC013DC-9D8C-45B8-8CC6-5E5219C7CBCA"; protocol="application/pgp-signature"; micalg=pgp-sha256
From: Andreas Dilger <adilger@dilger.ca>
In-Reply-To: <CAHc6FU5aZJDC3N1iGyVeHfbqMyquM93ONJvUR-t0a9+AjmtAXQ@mail.gmail.com>
Date: Tue, 6 Oct 2015 14:26:09 -0600
Cc: Christoph Hellwig <hch@infradead.org>,
        Austin S Hemmelgarn <ahferroin7@gmail.com>,
        Alexander Viro <viro@zeniv.linux.org.uk>,
        "Theodore Ts'o" <tytso@mit.edu>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        Jeff Layton <jlayton@poochiereds.net>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        linux-ext4 <linux-ext4@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>,
        linux-fsdevel <linux-fsdevel@vger.kernel.org>,
        linux-nfs@vger.kernel.org, Linux API <linux-api@vger.kernel.org>
Message-Id: <CF738526-0807-4CE5-A52B-413164D41AA9@dilger.ca>
References: <1443391772-10171-1-git-send-email-agruenba@redhat.com> <20151004062313.GA20212@infradead.org> <CAHc6FU53mXg1k0KCNkWEjxyuC8iAUgWh-A76qX=C3Yth+qEyuQ@mail.gmail.com> <5612C85C.2060407@gmail.com> <20151006094935.GA14144@infradead.org> <CAHc6FU5aZJDC3N1iGyVeHfbqMyquM93ONJvUR-t0a9+AjmtAXQ@mail.gmail.com>
To: Andreas Gruenbacher <agruenba@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


--Apple-Mail=_2BC013DC-9D8C-45B8-8CC6-5E5219C7CBCA
Content-Transfer-Encoding: quoted-printable
Content-Type: text/plain;
	charset=us-ascii

On Oct 6, 2015, at 7:12 AM, Andreas Gruenbacher <agruenba@redhat.com> =
wrote:
>=20
> On Tue, Oct 6, 2015 at 11:49 AM, Christoph Hellwig <hch@infradead.org> =
wrote:
>> On Mon, Oct 05, 2015 at 02:58:36PM -0400, Austin S Hemmelgarn wrote:
>>> I think the point is that a new VFS feature that is easy to =
integrate in
>>> multiple filesystems should have support for those filesystems.  A =
decade
>>> ago, just having ext* support would probably have been fine, but =
these days,
>>> XFS, BTRFS, and F2FS are used just as much (if not more) on =
production
>>> systems as ext4, and having support for them right from the start =
would
>>> significantly help with adoption of richacls.
>>=20
>> That's one reason.  The other is that actually wiring it up for more
>> than a single consumer shows its actually reasonable generic.
>=20
> The filesystem interface now is the same as for POSIX ACLs, used by a
> dozen or so filesystems already.
>=20
>> I don't want to end up with a situration like Posix ACLs again where
>> different file systems using different on disk formats again.
>=20
> Any file system could choose a different on-disk format than the one
> that ext4 currently uses, but I don't see a reason why any should.
> Apart from uid / gid mappings that is the same as the user-space xattr
> format. Network file systems like NFSv4 and CIFS with their predefined
> over-the-wire formats obviously are another story.

And any disk filesystems that have their own non-POSIX ACLs, such as =
HFS, NTFS, ZFS would presumably also need to map the in-kernel Richacl =
format to their on-disk format.

Cheers, Andreas






--Apple-Mail=_2BC013DC-9D8C-45B8-8CC6-5E5219C7CBCA
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
	filename=signature.asc
Content-Type: application/pgp-signature;
	name=signature.asc
Content-Description: Message signed with OpenPGP using GPGMail

-----BEGIN PGP SIGNATURE-----
Comment: GPGTools - http://gpgtools.org

iQIVAwUBVhQuY3Kl2rkXzB/gAQjy2BAAp5upU1xFGzGv3nOJ9JW0EHZff4l7ccFu
kwFjn/6rotF6OXO0YQQGXUgZp6SlKN1ytoxJBV4l3A1ukb2ufRld6iiOEOmibZuT
LGJuGAbQnT6KSL+IYtT9Jz/2cWw5fnHw8QKYtphzqrBbHJqqbcS0IMDw5WTfw0Y7
S9ayWZGNITtbjo49Kjmw90cwk/s7WUGr9r3zzgmp8rXzFRYoyF2WgopzK5Gwb+Ak
fB+JvHWq/9+PrKfY1Iyk+PhxuLL71r6z4yol9POUY+BFD2xGxiSKfHhIuSO6gnXT
k0CaZvVG2hrCLsRUTwd9MnyC7Zsb5wNMvLnJOq2NyajYBR60l62IZ4hImKPmg/ej
EZ1WyPObjhIjgdzI33zRHhpaZBvmFqL2vmv7N7EfhjLbePWeMrv3r4tQxN+syHRW
D5ghIj1nhYcEsesRbLvu7WxEO9AnSy7na9L+84T/1Bt6bmO0BPvwEeGSx2KzccE0
QpgaxRr9SG/CLiq8fO6Hb+5B+yfiUEHIT2zNDIrW33fSEvHbVA1nDbiDhXSLCLK+
NszXTjQ1i3nEINx+1tuT+62bhSgGRUfUwdoW4TSTkUR069N8JWiUOtQQaK7kIyuq
IrzYsB5OO2SWBYgsL50GhdjASDi2B6f9qBVLKWDLufPBtHtx+OllYtp4uZl0tcAI
KzKVmTgB4RU=
=CoPb
-----END PGP SIGNATURE-----

--Apple-Mail=_2BC013DC-9D8C-45B8-8CC6-5E5219C7CBCA--
