Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:40375 "EHLO mx2.suse.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751308AbcLFWaN (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 6 Dec 2016 17:30:13 -0500
From: NeilBrown <neilb@suse.com>
To: Steve Dickson <SteveD@redhat.com>,
        "J. Bruce Fields" <bfields@redhat.com>
Date: Wed, 07 Dec 2016 09:30:05 +1100
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH 03/15] Add /etc/nfs.conf support to rpc.nfsd
In-Reply-To: <79c2889c-3a77-7fcb-37d0-8fd970b54be7@RedHat.com>
References: <148065078775.28046.5506130555300891075.stgit@noble> <148065110833.28046.2561331715736018574.stgit@noble> <79c2889c-3a77-7fcb-37d0-8fd970b54be7@RedHat.com>
Message-ID: <87twag4ro2.fsf@notabene.neil.brown.name>
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
>> I haven't added -H support, but everything else should be able to be
>> set through /etc/nfs.conf.
>>=20
>> Signed-off-by: NeilBrown <neilb@suse.com>
>> ---
>>  systemd/nfs.conf.man |   24 ++++++++++++++++++++++++
>>  utils/nfsd/nfsd.c    |   36 ++++++++++++++++++++++++++++++++++++
>>  utils/nfsd/nfsd.man  |   49 +++++++++++++++++++++++++++++++++++++++++++=
+++---
>>  3 files changed, 106 insertions(+), 3 deletions(-)
>>=20
>> diff --git a/systemd/nfs.conf.man b/systemd/nfs.conf.man
>> index 1f524d8fe74e..6ac6c65a81d9 100644
>> --- a/systemd/nfs.conf.man
>> +++ b/systemd/nfs.conf.man
>> @@ -76,8 +76,32 @@ file is the only way to configure this program.  See
>>  .BR nfsdcltrack (8)
>>  for details.
>>=20=20
>> +.TP
>> +.B nfsd
>> +Recognized values:
>> +.BR threads ,
>> +.BR grace-time ,
>> +.BR lease-time ,
>> +.BR udp ,
>> +.BR tcp ,
>> +.BR vers2 ,
>> +.BR vers3 ,
>> +.BR vers4 ,
>> +.BR vers4.0 ,
>> +.BR vers4.1 ,
>> +.BR vers4.2 ,
>> +.BR rdma .
> I'm curious as to what the criteria was as to
> which options were defined. I would think 'debug'
> and 'port' would have made the list.

port should have made the list, it just .... didn't.

debug was more of a deliberate omission, or at least a deferral.
I didn't include debug for any daemons. mountd, nfsd, nfsdcltrack all
allow the option.  statd blends it with no-syslog. sm-notify has "-d".
mountd's --debug is different to the other, and takes word, as does
"exportfs -d".  The word is passed to xlog_sconfig can can select from
general, call, auth, parse, all.

Assuming that we want to be able to enable debug in the config file
(wouldn't you just run that command manually when you want to enable
debugging?) it would be good to standardize somehow.

So I guess I was treating "debug" like "host" - do it later.
I have no excuse for "port" :-(

NeilBrown

--=-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEG8Yp69OQ2HB7X0l6Oeye3VZigbkFAlhHO+0ACgkQOeye3VZi
gbn55g/9F62nrxjG47WtfPA4HLLS/tEJcmUNz0W2X8MVJisw+JQfk1zJzhAG/Cus
DX0WySztk0uZJ94dr8G7ei4fusZwW/0t/xWS/oM3dsEDwH+dfa6cwZehlEirhJ+t
yZ+S5m+eF2AYMShYfxN6avfBWPTv4swG/nRwu3iynJOYgShyEMpTAum/zIiq0vGp
WGXWZpvk1B0uTK4l68As3YXpwreODJzKW4WqrTMTJxXAMlZdEg1/rP1VOF6hIyPc
tR0EkMIUg/h1ocyM3jYImLyS5i2sd/1/N/tb+4yaz24mFTOAd8T77TJHF5HlIi2Q
3iLxguXnq+CARLimqrM8Ylr7kat2ks1EtI4Gxs0rDeiVT5NTkqYqkOEclg/2D69S
gcyKPpUKRauA0sNBNss07KzfYJwfJEZkDhpkdDca+u/4MYRBLVcjlNUYtS9WDj9s
DCA8zhmwj4QgL4qfhAsa+q0Azv1MejSHNixHXFAr4gbq+eA5HuHZgW4CSGdNM+kH
NeY7rvU+COOMtPQEF5ReS/zPioUvHy9Apo3TF5HGpekf2+snv+eeX8KxzgHGUy5P
sf4LtB1LxOSpS54XlJI4lCYUey1NCGj9mrQZxnVCdcGudwNQw+uWeVkuDAKO2AX6
1+KS09vmwZV4ZkHeNr8JsvDVJGNmzqDYimd5NjxcLWCGbTMt1j8=
=5OMb
-----END PGP SIGNATURE-----
--=-=-=--
