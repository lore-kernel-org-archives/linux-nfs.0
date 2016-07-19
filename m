Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:58297 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752398AbcGSXB5 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 19 Jul 2016 19:01:57 -0400
From: NeilBrown <neilb@suse.com>
To: Steve Dickson <SteveD@redhat.com>
Date: Wed, 20 Jul 2016 09:01:50 +1000
Cc: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 7/8] mount: don't treat temporary name resolution failure as permanent.
In-Reply-To: <20160714022643.5874.27102.stgit@noble>
References: <20160714021310.5874.22953.stgit@noble> <20160714022643.5874.27102.stgit@noble>
Message-ID: <8737n59qqp.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
	micalg=pgp-sha256; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--=-=-=
Content-Type: text/plain

On Thu, Jul 14 2016, NeilBrown wrote:

> If getaddrinfo() returns EAI_AGAIN, we shouldn't just give up, but
> should continue normal retries as the nameserver may be unavailable
> for the same reason as the NFS server.
>
> So move the getaddrinfo() call from nfs_validate_options() into
> nfs_try_mounts() which is always called soon after, except in the
> 'remount' case when we don't want it anyway.
>
> If EAI_AGAIN is returned, set errno to EAGAIN and allow this to be a
> temporary failure.  Otherwise report error and set errno to EALREADY
> so no further message is given.
>
> Signed-off-by: NeilBrown <neilb@suse.com>


> +
> +		if (!nfs_append_addr_option(mi->address->ai_addr,
> +					    mi->address->ai_addrlen, mi->options))
> +			return 0;
> +		mi->address = address;

This patch is badly buggy.  I'm de-referencing mi->address before
assigning it.  How did that ever pass quality control I ask myself.
(fortunately SUSE does better QA than I do).

I'll submit a revised version ... maybe put all the patches affecting
the mountpoint export option at the end of the list.

NeilBrown

--=-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBCAAGBQJXjrFeAAoJEDnsnt1WYoG5RuEP/19XY8oLYukeAtnAcnWjsfjN
DtEwLCrhwyECDt5y4AgVz4Y9m3S29pYRNMrCgvYpAC6vXWfSoqy8nUjpem0x/cEH
PeqH+oGH3+7jiEm9TPyXtKBo3bXuq32HmTF1Sg47QVubhBBLK90WxHVr7IZaCICs
/dQ2KIBVmv9gT8NH7KONM/LEVrqpLfgU8BuRXa7sZjEd2Rq0rVCUGAZlf91NlJju
a6vqcpuK7DCwOCUf8VYX7EwQskIoHOKVNnFKQJa7Xv6K/klKHmtcCtBrRpCjir84
ExO5kUtmI2XRnp7M8Xsajj0xKdRdVAna5DVs92OMkKXlgJdZLBbtGiPHbTVem7am
i6EMU9NYkh0CZjqy4bqhM7gKvIBjmO3NBFHfJy6Vp2o0xKJFWCWBj8u6uejLg9dZ
kFHWfkfK8nCKiHSUVuq9wKXwgKpbMDkyIjo5tEAe36AwJrAYfV6tXgSfRSoX1RQP
1+pB/PEPyL64U9kf3M+RZ8oStpUZPwimEMHhW/p8vSXgbT35EY8uafOR7APJ+dnH
2hWlwAwtWeJEO9odObkkTHM6TA1KW3fx4U3YDyQN9gxodLSO5Pl9XRvf+RoEkD9R
taJI4rngXc2D2lLFWxQLzLhMd7xkIba1CY4Occ5qPUVybZ7Ohulk1Au4HoWF2eiE
LlPFG9Jew6eW/426kBiN
=/X0u
-----END PGP SIGNATURE-----
--=-=-=--
