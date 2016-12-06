Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:41153 "EHLO mx2.suse.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750785AbcLFWg7 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 6 Dec 2016 17:36:59 -0500
From: NeilBrown <neilb@suse.com>
To: Steve Dickson <SteveD@redhat.com>,
        "J. Bruce Fields" <bfields@redhat.com>
Date: Wed, 07 Dec 2016 09:36:52 +1100
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH 03/15] Add /etc/nfs.conf support to rpc.nfsd
In-Reply-To: <8e72acac-42de-bf02-9069-60e7b6a12c04@RedHat.com>
References: <148065078775.28046.5506130555300891075.stgit@noble> <148065110833.28046.2561331715736018574.stgit@noble> <8e72acac-42de-bf02-9069-60e7b6a12c04@RedHat.com>
Message-ID: <87r35k4rcr.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
        micalg=pgp-sha256; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--=-=-=
Content-Type: text/plain

On Wed, Dec 07 2016, Steve Dickson wrote:

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
> Do we need both ver4 and ver4.0?

"vers4" allows you to enable or disable v4 has a whole.
The assumption is that if enabled, all minor versions that the kernel
supports will be enabled by default.
vers4.x allows individual minor versions to be disabled, so
 vers4=yes
 vers4.0=no
would disable v4.0, just like "-V4 -N4.0"

I do wonder if this is ever valid though.  Why do we allow minor
versions to be enabled/disabled?
Does it make any sense to enable a non-contiguous set of minor versions?
Should we just have a maximum NFSv4 minor version?

I was trying to duplicate the current functionality as closely as
convenient.  That might not be best in this case.

Thanks,
NeilBrown


>
> steved.
>> +.BR vers4.1 ,
>> +.BR vers4.2 ,
>> +.BR rdma .

--=-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEG8Yp69OQ2HB7X0l6Oeye3VZigbkFAlhHPYQACgkQOeye3VZi
gbkO1RAAwqfnuMKCYduCqGpGJ9i7vgovgLgw6WzJXurWSV3an4iDe/vzFbqF9YH3
OFrNcxDIaspYte2oXeHZPDO57wLSsSTB8RNmHdOzrqg6Ak8tpn7R6uPt9mGJdu78
JptL1eg/iDefEBwtwYSZDD9iX4Pn0KuO5EcHjBkJLiT+IE0e48U8EOGJZG83Setu
l3nxBV5nOWkkYYPIVASx8ZOVqUXGmy2MGIAMABXhtci9PlKYfVtRbB3ItLy7x1M2
YhlUgY8C8DtuHMSLxMr/E96BLgQ2rgwb7wjau6j7lifvK7ux76lqORqYu9M05oLg
ApK/c/+3WGeacsuOjHszrE5f4YZrzn8kI+6vSNo/G/x+N49nhbvwesvG0NDuaWSD
qnQ1efN0csNjSs+bepYDjiy2Bz1AOQ/MqhnY44LaV/WeYKnjZ9BI48CoOh6WVC/w
BKaVjSEy6Nsn158aZWbLEtA2DuBHNc3u92Cuob+o6Nvw29M5/VJLXdCXkUrAwQ/T
Hj7cHqtqhWHfxUPr06R/vG+oKbaRWBQ8Tc0itxCUAoHR2wxc6hvBNsblvF8x+xWC
beQ9bjzJJEQ5TQRvD0TEAmoWxgc2xO2W2BrEZjbOiPJ1tAOM3xlQl7La6r7HmIng
11rQmpfEAmwE/sTB8HheTUYpuMBdF+KnLZEj2rxMXhVJ7O1vm3w=
=+LoA
-----END PGP SIGNATURE-----
--=-=-=--
