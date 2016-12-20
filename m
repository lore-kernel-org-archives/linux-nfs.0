Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:42500 "EHLO mx2.suse.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S932479AbcLTXWm (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 20 Dec 2016 18:22:42 -0500
From: NeilBrown <neilb@suse.com>
To: Steve Dickson <SteveD@redhat.com>,
        "J. Bruce Fields" <bfields@redhat.com>
Date: Wed, 21 Dec 2016 10:22:24 +1100
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH 03/15] Add /etc/nfs.conf support to rpc.nfsd
In-Reply-To: <87r35k4rcr.fsf@notabene.neil.brown.name>
References: <148065078775.28046.5506130555300891075.stgit@noble> <148065110833.28046.2561331715736018574.stgit@noble> <8e72acac-42de-bf02-9069-60e7b6a12c04@RedHat.com> <87r35k4rcr.fsf@notabene.neil.brown.name>
Message-ID: <87mvfqrxsf.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
        micalg=pgp-sha256; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--=-=-=
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Wed, Dec 07 2016, NeilBrown wrote:

> [ Unknown signature status ]
> On Wed, Dec 07 2016, Steve Dickson wrote:
>
>>> +.B nfsd
>>> +Recognized values:
>>> +.BR threads ,
>>> +.BR grace-time ,
>>> +.BR lease-time ,
>>> +.BR udp ,
>>> +.BR tcp ,
>>> +.BR vers2 ,
>>> +.BR vers3 ,
>>> +.BR vers4 ,
>>> +.BR vers4.0 ,
>> Do we need both ver4 and ver4.0?
>
> "vers4" allows you to enable or disable v4 has a whole.
> The assumption is that if enabled, all minor versions that the kernel
> supports will be enabled by default.
> vers4.x allows individual minor versions to be disabled, so
>  vers4=3Dyes
>  vers4.0=3Dno
> would disable v4.0, just like "-V4 -N4.0"

What I meant here, of course, is
   just like "-V4 -N4.0" *should*

not "just like what it *does*."

To my surprise, when you actually try "nfsd -N4.0",
it opens /proc/fs/nfsd/versions and writes "+4.32".

#define NFSCTL_VERISSET(_cltbits, _v) ((_cltbits) & (1 << ((_v) - 1)))=20

That "-1" makes it clear that version 4.0 isn't understood.

The kernel side seem to understand that '0' is an independent minor version:
static bool nfsd_supported_minorversions[NFSD_SUPPORTED_MINOR_VERSION + 1] =
=3D {
	[0] =3D 1,
	[1] =3D 1,
	[2] =3D 1,
};

but refuses to let it be disabled:
				if (num !=3D 4)
					return -EINVAL;
				minor =3D simple_strtoul(minorp+1, NULL, 0);
				if (minor =3D=3D 0)
					return -EINVAL;

so you can have 4.1 disabled while 4.0 and 4.2 are active, but you
cannot disable 4.0 as well.

Should that be fixed?  Do we care?

At least we should change
					int i =3D atoi(p+1);
					if (i > NFS4_MAXMINOR) {
						fprintf(stderr, "%s: unsupported minor version\n", optarg);
						exit(1);

in nfsd.c so the test is
  if (i < NFS4_MINMINOR || i > NFS4_MAXMINOR) {

I'll send a patch.

Thanks,
NeilBrown

--=-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEG8Yp69OQ2HB7X0l6Oeye3VZigbkFAlhZvTAACgkQOeye3VZi
gblZrxAAqlO7O4qsepMvny4uUM2a4s8N+GdRkCV0f6DJGygMQWWidsoUEzPc8w/N
OSwhuUX89GNBkl/eRCz540MOSay5uLLKA7CSU8iDdWXLdNF5RTrB2R2jst9jF6RG
H661VkdxGSYE9nKdP0vp57MExiQwPSQNWAl6+ba/BCrNPQJ1UCBoxh8IHfcAXhhW
6VHFxeFlp64j7foBEh9Tl9zWAXJ6mxRncCnA0D7oTgcQzM2xHU6cFIZERkwNcXIC
3n2OL89gJUEhkxb0mFE4OfTRjSGNsOErw2thiuUFOVAyeG4D2a9np15Rw8H3j4q0
yJF9yjEe/CV5rHlvQHAJmdaRlHLDAs4yLoYdUy3fkcl00kbMgv9CH1JcnS7UU5ga
gWVsuAH5RwetnMk1zYEZ7xG7qSDNfGHF0Y7lCeKzfkWPFkxU2VSns5xCBTh15nOa
uohUjIWICGH2eU7zd7aEuYMRvx1UOQlyPu0NGwl9aeuK455qz2N37PE9QnitKBZe
ReR8+tR8QKiO8N1809AEveJmPXHnhOdL0vxlE7GKWNKFDLU9P7lg0lV849CPfWqc
sNRyLoZKdGWf/HnC0BSB1J3GRAJsz+zN4a9e3m0DSvQ2bapuJoO5V7hnKAnRtgRX
TMYJ94H/7fZZ1aA3xHazWZw75ANOqwnDPC7qkkAuNXmYZNnV+ks=
=1CY9
-----END PGP SIGNATURE-----
--=-=-=--
