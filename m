Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:50936 "EHLO mx1.suse.de"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1750992AbdE3IzX (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 30 May 2017 04:55:23 -0400
From: NeilBrown <neilb@suse.com>
To: Michael Biebl <mbiebl@gmail.com>
Date: Tue, 30 May 2017 18:55:15 +1000
Cc: Steve Dickson <SteveD@redhat.com>, linux-nfs@vger.kernel.org,
        systemd-devel@freedesktop.org
Subject: Re: [systemd-devel] [PATCH] nfs.man: document incompatibility between "bg" option and systemd.
In-Reply-To: <CAGWsdOh5Sy-=8uv1aLUsCs+Co_QHgrkbUOJ0fXkb=Xskcez6JQ@mail.gmail.com>
References: <87lgpkgwrw.fsf@notabene.neil.brown.name> <20170529133814.GC17967@gardel-login> <87tw43fgrf.fsf@notabene.neil.brown.name> <CAGWsdOh5Sy-=8uv1aLUsCs+Co_QHgrkbUOJ0fXkb=Xskcez6JQ@mail.gmail.com>
Message-ID: <87inkig1vw.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
        micalg=pgp-sha256; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--=-=-=
Content-Type: text/plain

On Tue, May 30 2017, Michael Biebl wrote:

> 2017-05-30 0:19 GMT+02:00 NeilBrown <neilb@suse.com>:
>
>> +.B bg
>> +option is not supported, and may be stripped from the option list.
>
> Either systemd is updated to actually strip the bg option or not. The
> documentation should reflect that.
> I don't think we should be vague about this, as it would only be confusing.

It depends on which version of systemd is in use.
Even if/when systemd is updated to strip the 'bg', it would not
be correct to say "and will be stripped..." as that isn't true for all
versions.
We could spell it out "and may be stripped from the option list,
depending on which version of systemd is installed", but I'm not sure
that really helps...
 "... and some versions of systemd will strip 'bg' from the option list"
 ??

Thanks,
NeilBrown

--=-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEG8Yp69OQ2HB7X0l6Oeye3VZigbkFAlktM3QACgkQOeye3VZi
gblvAw//esaBgGe/jsT+/gyvSifPBYvuiwwI8bKM29VmRL5x84WUL2RqMkZQJf9s
MZ8MkOfw4ZT8zfCFB7R8vSP0qWBU3cbU8Q/7VKbVWlqZb87ej3wiJHB2eBMO+c9t
AbwNilt/QLDRHPGKQg6kVoOqrmT5PwWiL+O/nUfkCqrm1/r5olnX/EXhTuf65A+l
jCx3QSbu9birr32/weDCdJQOsYUWZOkNkOk+/88ByKkS1pAPh2nB+WWkttfjTtej
l6SyUR+ptWAu86HPvjSexmOLdpItxy0+nWScqzjTc3itSc2Ts+WdPRhJjYuVdYMJ
EO4vAWH5jRPGnRul6DwLWLEiZT3Z8f47LwlFf1jEZtWbXfhB/h+tlRTuuV3jTEpf
27SprqYEBs5hDCtPXpx5iU90TVVvey8wG/fS+NcwXS5K1XS/G1xEhG3P6z4LcxRQ
4JKvj7rOuX71NFrKYT7sAgyWmWHTONa3nbYtEzWGyIYS/tDnRjyrG6qjkM/jd9TW
b297D8mkK2Z4+CzX8R3zV2LErfBTLJhymBfYwhLuIljaSAyhNtTxDVKqqXa9n7D5
EHB8CvcdSnPvcy07p6yvit/qhmaEKn3T8SeNKYiDdtZM1HW/g2ugIHMDWPojLGNO
OVmdA/SzMP6otZCk8bMFWf/ts4NNnkqbogHqjnCr0Nyo2dbpcjQ=
=IRH3
-----END PGP SIGNATURE-----
--=-=-=--
