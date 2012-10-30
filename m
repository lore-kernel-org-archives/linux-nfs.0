Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cantor2.suse.de ([195.135.220.15]:44916 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S934293Ab2J3UaG (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 30 Oct 2012 16:30:06 -0400
Date: Wed, 31 Oct 2012 07:30:27 +1100
From: NeilBrown <neilb@suse.de>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: "J. Bruce Fields" <bfields@redhat.com>, linux-nfs@vger.kernel.org,
        linux-fsdevel@vger.kernel.org, Peter Staubach <pstaubach@exagrid.com>
Subject: Re: [PATCH 0/2] fix nfsd stable write implementation
Message-ID: <20121031073027.254242ed@notabene.brown>
In-Reply-To: <20121030140725.GC24618@fieldses.org>
References: <1351285617-20450-1-git-send-email-bfields@redhat.com>
	<20121030102833.306e833a@notabene.brown>
	<20121030140725.GC24618@fieldses.org>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=PGP-SHA1;
 boundary="Sig_/DINZOuuoxml_cjyAbEiayS7"; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--Sig_/DINZOuuoxml_cjyAbEiayS7
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

On Tue, 30 Oct 2012 10:07:25 -0400 "J. Bruce Fields" <bfields@fieldses.org>
wrote:

> On Tue, Oct 30, 2012 at 10:28:33AM +1100, NeilBrown wrote:
> > On Fri, 26 Oct 2012 17:06:55 -0400 "J. Bruce Fields" <bfields@redhat.co=
m>
> > wrote:
> >=20
> > > From: "J. Bruce Fields" <bfields@redhat.com>
> > >=20
> > > Peter pointed out to me that the nfs server is implementing stable
> > > writes by setting the O_SYNC flag.  I can't see why we couldn't write
> > > and then sync instead, but I don't know this stuff as well as I shoul=
d;
> > > does the following look reasonable to people?
> >=20
> > Bruce changed the code to implement stable writes by calling
> > vfs_fsync_range().  I can't see why we couldn't use O_SYNC instead.
> >=20
> > It seems like you are making a change just for the sake of making a cha=
nge.
> > Is there some reason that you think a separate 'sync' is more efficient=
 than
> > using O_SYNC ?
>=20
> Oh, sorry, see the changelog on the second patch: the problem is that
> the struct file can be shared across multiple writes in the NFSv4 case,
> so a single stable write could make all subsequent writes synchronous.
>=20
> (And some day people would like filehandle caching for v2/v3, in which
> case we'll run into the same problem.)

Ahh, I missed that.
Makes sense then, thanks.

>=20
> > As a general principle, I think it is best to give the file system as m=
uch
> > information as possible to that it can make whatever optimisation decis=
ions
> > that it wants to.
> >=20
> > Setting O_SYNC gives the filesystem more information than not, because =
it
> > allows it to change the behaviour of the 'write' request... though I do=
n't
> > know if any filesystem actually uses the information.
>=20
> I'm not sure how to figure out if that's a real problem or not.

Search all filesystems for special handling of O_SYNC or O_DSYNC?

I strongly suspect that it is not a real problem.

Thanks,
NeilBrown


--Sig_/DINZOuuoxml_cjyAbEiayS7
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.18 (GNU/Linux)

iQIVAwUBUJA44znsnt1WYoG5AQI3GBAAksMaCz5I0ZNbum2pr3IGKnubc6Q1mpyv
xCExIw2UJUNswe0dU65KwDOkFK8f6Idt15NBt6wSWN9PWBOHuwGhiZNJiMf4GXLE
/J8VKkNUB5A6/1ZJGbC/gIs+AvH0n8u+95DvwEKGAVmjGOTePJiMruZsdyKS6FV4
dfBAMBvWck966aXnCKL7UjLEawgphWymoisfufgknGC/2PfYDUUdHUT0ewe5pa3F
u2ozJE4wV4LF8BoLd3ZsyyOhO5mUsBLXD+N1ypanSb9/hXd3tIU7naH1Y5crPqdJ
9yp5yh4sF8IoPtg3k6P2dNmgfxeAqdiYnsHEBUpP45LYU445ZXTeyTUh+4/r34WA
3j6e/VyXC5+lIhOk0f8GzQxfkJseblrphv6lV6MdKeogaO2hU6kwvCJpgKobDTSq
oilr0Hq1SfxjAHyFv/IFlfsqex5aSBkr58pIAwsgVJFuhAKS4iwbcuBN4da/ps3u
zPZHQWg+Afc9p7bOsW8/FpR5pIZSZ05AoSP73mVpahF1jvW7Q2K+hj7Y1cj3Ijgu
wqH76i3k5JNchmIlCEcKomWP6PLVfR1QwEEK5Uukzm+jk4UFxt4bazBmD8Zc2P6D
UihAvrEC9vCEgOy0I9zxxpotAKvFQ+x6wM5m8gn8021Tdyx+EEgQ9DQVPFEH1WoX
25plKD0qtNY=
=sTnW
-----END PGP SIGNATURE-----

--Sig_/DINZOuuoxml_cjyAbEiayS7--
