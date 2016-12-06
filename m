Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:43271 "EHLO mx2.suse.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751233AbcLFWvb (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 6 Dec 2016 17:51:31 -0500
From: NeilBrown <neilb@suse.com>
To: Steve Dickson <SteveD@redhat.com>,
        "J. Bruce Fields" <bfields@redhat.com>
Date: Wed, 07 Dec 2016 09:51:23 +1100
Cc: linux-nfs@vger.kernel.org
Subject: Re: [RFC PATCH 00/15] Enhance /etc/nfs.conf usage and remove nfs-config.service
In-Reply-To: <ab0ce4e9-fd03-7cee-5ce2-5317c522db8f@RedHat.com>
References: <148065078775.28046.5506130555300891075.stgit@noble> <ab0ce4e9-fd03-7cee-5ce2-5317c522db8f@RedHat.com>
Message-ID: <87inqw4qok.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
        micalg=pgp-sha256; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--=-=-=
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Wed, Dec 07 2016, Steve Dickson wrote:

> On 12/01/2016 10:58 PM, NeilBrown wrote:
>> This is an RFC series.  A little voice at the back of my head keeps
>> telling me that I'm over-engineering, but there isn't really that much
>> new code, and I think the result has a lot to recommend it.
>>=20
>> But please tell me if I'm wrong.
>>=20
>> - Various daemons (not all) are enhance to accept configuration
>>   information from /etc/nfs.conf
>> - the conffile reader is enhanced to support include files, and
>>   particularly to be able to include /etc/sysconf/X or /etc/defaults/X
>>   files usefully
>> - nfs-config.service is removed, because it isn't really needed with
>>   the above.
>> - documentation for all the above is provided, including a new
>>   nfs.systemd man page which gives the bigger picture.
>>=20
> Here is the nfs.conf I will be using to do my testing...=20
> I'm just wondering if this is something we should put in the git tree?=20
>
> #
> # This is a general conifguration for the=20
> # NFS daemons and tools
> #
> #[nfsdcltrack]
> # storagedir=3D/var/lib/nfs/nfsdcltrack
> #
> #[nfsd]
> # threads=3D8
> # grace-time=3D90
> # lease-time=3D90
> # udp=3Dy
> # tcp=3Dy
> # vers2=3Dn
> # vers3=3Dy
> # vers4=3Dy
> # vers4.0=3Dy
> # vers4.1=3Dy
> # vers4.2=3Dy
> # rdma=3Dn
> #=20
> #[mountd]
> # manage_gids=3Dn
> # descriptors=3D0
> # port=3D42258
> # threads=3D1
> # reverse-lookup=3Dn
> # state-directory-path=3D/var/lib/nfs
> # ha-callout=3DNULL

NULL??  That looks like it is meant to mean something.
Ditto for the "port=3D0" below.

You seem to be listing the default here, in which case I would just have

  ha-callout=3D

Otherwise, this is probably a good idea.  People seem to prefer to fill
in templates, rather than read documentation :-(

Thanks,
NeilBrown


> #
> #[statd]
> # port=3D0
> # outgoing-port=3D0
> # name=3DNULL
> # state-directory-path=3D/var/lib/nfs/statd

This is normally "/var/lib/nfs" - no "/statd".

> # ha-callout=3DNULL
> #
> #[lockd]
> # port=3D0
> # udp-port=3D0
> #
> #[sm-notify]
> # retry-time=3D900
> # outgoing-port=3DNULL
> # outgoing-addr=3DNULL
> #

--=-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEG8Yp69OQ2HB7X0l6Oeye3VZigbkFAlhHQOsACgkQOeye3VZi
gblM8w//Qowfq2mxNMeZggqJQsIx+gCcIKNN5rcNtPVFW/BGL1D0GCBssjN1z2cn
Vtit3Bus8Ot+NPgvfvaVaLgZz7n5vY3Fc65Rdx//hA5pgSHo50KefhRO5PNCi1Bg
MJihPW8Gflan0H+4e+eIk0tWQRmZN25B4JdXU0wJ0wKTu98aYi0hGYoAr9Zdaavf
DjWS0EBHkv6UAk/vocrAZpIiH4k05fffSkj/dJmx0bezxgTB+/XXagokaUIZ3qgG
7Idx5K6lEf4kpPLdhR58bjGv96QwRIwP9FpgDtDA9RKx8kZnWKY8MvVo08iMdZ+Y
z12DD56jVJDlGQICazjObjAVXcIsbAn5Y5KGf/bZ+Cnbea9STc8x3S78EDCjXPAq
/GOl0sAW7lMSnGYjsISxQq9Lsdek0xZoEgPOPqwOMjdiZBy8RCMTbRibh2XLv+nk
w8FfOPAk0HbIGinoJyF77Yn9jNG128tp4omDsm90C2FtMV9dGL1gOwJ7uqeGhm1C
XpMLoJEZQTqaGr2aKkI1JvlO5Y+kq4MnvQr1cg8GxzN0Ddg7+kkS2EEG/sAUyisY
Jkfh2ZVB0E9dqa/JphduTRE9fnouY6AehTD9e5G6Bn6vq0VdccOjYF4pdnAFCavB
fBOhyWA/WmEQwJfRrUZQ/6S8n1cY4KDRkiPE7H3FKNXoFJrKtVM=
=U5wJ
-----END PGP SIGNATURE-----
--=-=-=--
