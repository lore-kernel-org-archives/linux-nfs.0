Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cantor2.suse.de ([195.135.220.15]:48274 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753045Ab3CMFzs (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 13 Mar 2013 01:55:48 -0400
Date: Wed, 13 Mar 2013 16:55:26 +1100
From: NeilBrown <neilb@suse.de>
To: Bodo Stroesser <bstroesser@ts.fujitsu.com>
Cc: bfields@fieldses.org, linux-nfs@vger.kernel.org
Subject: Re: sunrpc/cache.c: races while updating cache entries
Message-ID: <20130313165526.0756d38e@notabene.brown>
In-Reply-To: <61eb00$3gpm51@dgate20u.abg.fsc.net>
References: <61eb00$3gpm51@dgate20u.abg.fsc.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=PGP-SHA1;
 boundary="Sig_/BNdcefoIkDd.FHCvf8Sx+O."; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--Sig_/BNdcefoIkDd.FHCvf8Sx+O.
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

On 11 Mar 2013 17:13:41 +0100 Bodo Stroesser <bstroesser@ts.fujitsu.com>
wrote:

> Hi,
>=20
> AFAICS, there is one more race in RPC cache.
>=20
> The problem showed up for the "auth.unix.ip" cache, that
> has a reader.
>=20
> If a server thread tries to find a cache entry, it first
> does a lookup (or calls ip_map_cached_get() in this specific
> case). Then, it calls cache_check() for this entry.
>=20
> If the reader updates the cache entry just between the
> thread's lookup and cache_check() execution, cache_check()
> will do an upcall for this cache entry. This is, because
> sunrpc_cache_update() calls cache_fresh_locked(old, 0),
> which sets expiry_time to 0.
>=20
> Unfortunately, the reply to the upcall will not dequeue
> the queued cache_request, as the reply will be assigned to
> the cache entry newly created by the above cache update.
>=20
> The result is a growing queue of orphaned cache_request
> structures --> memory leak.
>=20
> I found this on a SLES11 SP1 with a backport of the latest
> patches that fix the other RPC races. On this old kernel,
> the problem also leads to svc_drop() being called for the
> affected RPC request (after svc_defer()).
>=20
> Best Regards
> Bodo

I don't think this is a real problem.
The periodic call to "cache_clean" should find these orphaned requests and
purge them.  So you could get a short term memory leak, but it should
correct itself.
Do you agree?

Thanks,
NeilBrown

--Sig_/BNdcefoIkDd.FHCvf8Sx+O.
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.19 (GNU/Linux)

iQIVAwUBUUAUzjnsnt1WYoG5AQIQDRAAiGGLzd0zN+ZINbDlyCTUCqDfA/Zx+OIk
x2AZ2OxjwqG4/9J+B5gKbBA4K/7WYcxmOJP06ZTDy8p3Rjjp0uc9mP90Vutl16ah
K6vhRyCH/uBFhrw0OUd9TuxR6G7SytzeSMslT5p1WOCiIN8EEUSSrVvfgI+qUa8N
1KClxQA0pr1zsqfADe/8VUOJj6Vh+zHMd2eJttMCTskYv1JtPKUS16lymLIcHl0e
WwdkD9HcEAyD1E4KCtKAdhhGL1im5Pi9DQn2hJdtgK1bFFTh0sWvLk6o4bMmHIBt
aYAGkbWFTfXyr4WrwqBwHGpAo6e0JpipCE+6OG4xl5a5aa1qppgmPgcVmfAsu8hX
zd9Im/QlC6OH56IoNoAgQ1ZdKx2pCSh7/QHaZykrmSJ5Jo8IdD9BjLFUZBtgDvZE
9aHTXKZlW6mz/2SfV4tEXcXh4/HCBluzxVNt3KA+omjjlG2j+9YR7oRVw7cQhKEV
FTcJ2CIzhyHRhUD5U5veCXGXxGaWkeKr3gAFzjFWpWx6/F2IDDnxPw4Aer0ZjmQv
tn+xrJ/mImkn8GQI20YahWqOPkjwrp8mbj3gDxO8POxyzGcvWnSjggVg2rjzkzTT
2imaR8t+cRw8moICPoH3Wu/8fRhsLuyPL2R2n/v5x6Z3AgxJrExgRRuQoHmhS+SU
37qUB2ybYVc=
=j+f8
-----END PGP SIGNATURE-----

--Sig_/BNdcefoIkDd.FHCvf8Sx+O.--
