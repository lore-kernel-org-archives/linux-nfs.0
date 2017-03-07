Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:56554 "EHLO mx2.suse.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751088AbdCGUKj (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 7 Mar 2017 15:10:39 -0500
From: NeilBrown <neilb@suse.com>
To: Trond Myklebust <trondmy@primarydata.com>,
        "jlayton\@poochiereds.net" <jlayton@poochiereds.net>,
        "linux-nfs\@vger.kernel.org" <linux-nfs@vger.kernel.org>
Date: Wed, 08 Mar 2017 07:09:26 +1100
Cc: "hch\@infradead.org" <hch@infradead.org>
Subject: Re: Confused by pnfs LAYOUTRETURN - seeking clarity.
In-Reply-To: <1488847700.2913.1.camel@primarydata.com>
References: <87shmvnzh7.fsf@notabene.neil.brown.name> <1488569105.2997.1.camel@poochiereds.net> <87r32bjbzq.fsf@notabene.neil.brown.name> <1488847700.2913.1.camel@primarydata.com>
Message-ID: <87wpc0j1c9.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
        micalg=pgp-sha256; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--=-=-=
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable

On Tue, Mar 07 2017, Trond Myklebust wrote:

> Hi Neil,
>
> On Mon, 2017-03-06 at 14:54 +1100, NeilBrown wrote:
...
>>=20
>> So the Netapp filer is clearly doing the wrong thing, as we doesn't
>> send
>> CB_LAYOUTRECALL.=C2=A0=C2=A0But I'm far from convinced that Linux is doi=
ng the
>> right thing by replying NFS4ERR_NOMATCHING_LAYOUT.
>>=20
>> However, I'm not going to try to "fix" anything here.=C2=A0=C2=A0Hopeful=
ly we
>> can
>> manage to stumble forward.
>>=20
>
> Please see RFC5661, Section 12.5.5.1 https://tools.ietf.org/html/rfc566
> 1#section-12.5.5.1
>
> That section has a full documentation of what the server should
> interpret NFS4ERR_NOMATCHING_LAYOUT to mean, and should explain why the
> Linux client behaviour is quite correct w.r.t. the spec.
> There are a couple of errata to consider too, but they mainly try to
> nail down the expected behaviour for a couple of corner cases.

Thanks for that.  The last too sentences to suggest that
NFS4ERR_NOMATCHING_LAYOUT isn't really an error, and the whole
discusses how the server and client can reasonably have different
understandings of the current set of layouts.

Thanks,
NeilBrown

--=-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEG8Yp69OQ2HB7X0l6Oeye3VZigbkFAli/E3YACgkQOeye3VZi
gbnJEw//Th43YtnehGQXkkfHJLJWkbPkdtw4AuADDagkarEf30Y9aGruexl+9Pk9
yGeQRyhFH3wRALMzba9NKeXN5neC1KT5L0XKuvkn9DZ1OrzzxGwpIXnTU/nped8m
4pzllh8KiFDqa0/TojhpCo9oHXMaqIBKWRAVxRpxvat+isMINVQYpy4Y0/EMHjKl
i4gP4hxkwFwwgipDLiWLuqgXSkGYXyyLuQhoZTFKx79mm5kavPuDAedWvCVWBiQT
PX+hrlHyy/6I+BFTw5O1TH+7Fu0T41BWTskfGcuwzIchEKYMQJDf3wtNk1BYyFgE
/lYX9cAM7Ks5J5YfHkCMWIfcfPTsl+m6ZVWiZx29RQBDSXKQlr4uZ9Ikd8tS2mtY
cHy9yPL0Q2EjMul7pqsPbHbnSCXtunL/WwMHBpHBUUUmal+T1eTMkRswM5uQUMxj
HReMERcovdDru8i+hE5K+q7FoRvRnWEtcGsjQSVqJLxt/jRI6dbv3paMokSvneeu
v2kIwPoyhTNG4LMVooVLEFuoWfRrEHSM6N0xu/8pa+5z6//mqThug7NuctebnAx/
f0RwrzZnxYo4xusSnG8Qv1VcGsLXbKbwwKWPqzlIXHizE6O3AI9rqmbNowGmrR1l
Xun2iAWPMjJcxRNe74GpKPl7c5v2lLFxZbJlr7VFf+OEZmZ+0T0=
=xI8o
-----END PGP SIGNATURE-----
--=-=-=--
