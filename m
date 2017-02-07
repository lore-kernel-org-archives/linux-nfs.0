Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:32854 "EHLO mx2.suse.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751906AbdBGXfL (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 7 Feb 2017 18:35:11 -0500
From: NeilBrown <neilb@suse.com>
To: Kinglong Mee <kinglongmee@gmail.com>,
        "J. Bruce Fields" <bfields@fieldses.org>, linux-nfs@vger.kernel.org
Date: Wed, 08 Feb 2017 10:16:36 +1100
Cc: Trond Myklebust <trond.myklebust@primarydata.com>,
        Kinglong Mee <kinglongmee@gmail.com>
Subject: Re: [PATCH 1/2] SUNRPC/Cache: Always treat the invalid cache as unexpired
In-Reply-To: <e8f37174-0afd-7213-547a-269fc81c01dc@gmail.com>
References: <e8f37174-0afd-7213-547a-269fc81c01dc@gmail.com>
Message-ID: <87y3xhvbfv.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
        micalg=pgp-sha256; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--=-=-=
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Mon, Feb 06 2017, Kinglong Mee wrote:

> When the first time pynfs runs after rpc/nfsd startup, always get the war=
ning,
>
> "Got error: Connection closed"
>
> I found the problem is caused by,
> 1. A new startup of nfsd, rpc.mountd, etc,
> 2. A rpc request from client (pynfs test, or normal mounting),
> 3. An ip_map cache is created but invalid, so upcall to rpc.mountd,
> 4. rpc.mountd process the ip_map upcall, before write the valid data to n=
fsd,
>    do auth_reload(), and check_useipaddr(),
> 5. For the first time, old_use_ipaddr =3D -1, it causes rpc.mountd do wri=
te_flush    that doing cache_clean,
> 6. The ip_map cache will be treat as expired and clean,
> 7. When rpc.mountd write the valid data to nfsd, a new ip_map is created
>    and updated, the cache_check of old ip_map(doing the upcall) will
>    return -ETIMEDOUT.
> 8. RPC layer return SVC_CLOSE and close the xprt after commit 4d712ef1db05
>    "svcauth_gss: Close connection when dropping an incoming message"
>
> NeilBrown suggest in another email,
>
> "If CACHE_VALID is not set, then there is no data in the cache item,
>  so there is nothing to expire. So it would be nice if cache items that
>  don't have CACHE_VALID are never treated as expired."
>
> v2, change the checking of CACHE_PENDING to CACHE_VALID
>
> Signed-off-by: Kinglong Mee <kinglongmee@gmail.com>
> ---
>  include/linux/sunrpc/cache.h | 5 ++++-
>  1 file changed, 4 insertions(+), 1 deletion(-)
>
> diff --git a/include/linux/sunrpc/cache.h b/include/linux/sunrpc/cache.h
> index 62a60ee..782024e 100644
> --- a/include/linux/sunrpc/cache.h
> +++ b/include/linux/sunrpc/cache.h
> @@ -204,8 +204,11 @@ static inline void cache_put(struct cache_head *h, s=
truct cache_detail *cd)
>  	kref_put(&h->ref, cd->cache_put);
>  }
>=20=20
> -static inline int cache_is_expired(struct cache_detail *detail, struct c=
ache_head *h)
> +static inline bool cache_is_expired(struct cache_detail *detail, struct =
cache_head *h)
>  {
> +	if (!test_bit(CACHE_VALID, &h->flags))
> +		return false;
> +
>  	return  (h->expiry_time < seconds_since_boot()) ||
>  		(detail->flush_time >=3D h->last_refresh);
>  }
> --=20
> 2.9.3

Thanks for this.
I think it would be best if this patch were applied *after* the change
to cache_purge(), to avoid possible issues if a git-bisect lands between
these two.
Apart from that:\
 Reviewed-by: NeilBrown <neilb@suse.com>

Thanks,
NeilBrown

--=-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEG8Yp69OQ2HB7X0l6Oeye3VZigbkFAliaVVQACgkQOeye3VZi
gbkyGQ/+L5d+UucqAo9DLKTxrmQ2nd1OhIEaeJKxYsPuBKYSxoal/Ool0mlK2Ix2
JPZcK/XK8nW26+OTBYPO/pypIcxC6KAerhhhwVkBO6hsdd4T+epwm21mpve0Gt5G
HPcAR8lh9BYN9AVoFOcPOHfwO1P5aW4J6lbZIRgd3ctdOMckfOFEesK6mzAzPRJ3
sxF1XxWg/WPCW1cHXxqm/SJLH2gljSTmOUJwuHuzyTcHnrowuhYFknFYRFGj540I
ORJr+yeVBQ/yWlKgjiYeKNaiPI4zYWC3OYaNWJqdkdvuKzs5zr7HOd9ocIZXUbqg
iq+L0gLF3PVrObAMr7JDiEW6ttTzubGAJzzqqv9CNO1ZPP2MNb5TRM2+ZpehX2cI
pvZ36R7PuYOwf9+vxJ7Q4CODLlh7OHQCdcsFxVOrJ9l5daLBEddYqGrxs7zZ4lJS
q54956nIdXWdevfzM2YfWJR+i6o18rswC7jaKumZp0EGKSAJOnlK7v3Nihm2NPCW
b0R71zz51Emj2cMpYxWhJofkH6MWw69WzGMUDg/QCMAg/eq7g8pn5RxwYUWV4VYo
y4COsUeF5SfTHqHqtk9Nt2hR7vSeadDZh9xLdvxD1OB3SZJd8LQlJ7AmQS8M4IoX
VlUI1mktAcPvleQhZrZzmLCIqpujKLsjlP4qqGi8bUyhZo+PVdo=
=emvU
-----END PGP SIGNATURE-----
--=-=-=--
