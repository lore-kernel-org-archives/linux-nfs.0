Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:38757 "EHLO mx2.suse.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751094AbdBHCds (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 7 Feb 2017 21:33:48 -0500
From: NeilBrown <neilb@suse.com>
To: Kinglong Mee <kinglongmee@gmail.com>,
        "J. Bruce Fields" <bfields@fieldses.org>, linux-nfs@vger.kernel.org
Date: Wed, 08 Feb 2017 13:19:04 +1100
Cc: Trond Myklebust <trond.myklebust@primarydata.com>,
        Kinglong Mee <kinglongmee@gmail.com>
Subject: Re: [PATCH 1/2 v3] SUNRPC: Drop all entries from cache_detail when cache_purge()
In-Reply-To: <99f0c881-f7bc-e548-8694-c68f11afde68@gmail.com>
References: <99f0c881-f7bc-e548-8694-c68f11afde68@gmail.com>
Message-ID: <87mvdxv2zr.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
        micalg=pgp-sha256; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--=-=-=
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Wed, Feb 08 2017, Kinglong Mee wrote:

> User always free the cache_detail after sunrpc_destroy_cache_detail(),
> so, it must cleanup up entries that left in the cache_detail,
> otherwise, NULL reference may be caused when using the left entries.
>
> Also, NeriBrown suggests "write a stand-alone cache_purge()."
>
> v3, move the cache_fresh_unlocked() out of write lock,
> v2, a stand-alone cache_purge(), not only for sunrpc_destroy_cache_detail
>
> Signed-off-by: Kinglong Mee <kinglongmee@gmail.com>

Looks good to me.

Reviewed-by: NeilBrown <neilb@suse.com>

Thanks,
NeilBrown

> ---
>  net/sunrpc/cache.c | 41 ++++++++++++++++++++++++++---------------
>  1 file changed, 26 insertions(+), 15 deletions(-)
>
> diff --git a/net/sunrpc/cache.c b/net/sunrpc/cache.c
> index 8147e8d..f0a7390 100644
> --- a/net/sunrpc/cache.c
> +++ b/net/sunrpc/cache.c
> @@ -362,11 +362,6 @@ void sunrpc_destroy_cache_detail(struct cache_detail=
 *cd)
>  	cache_purge(cd);
>  	spin_lock(&cache_list_lock);
>  	write_lock(&cd->hash_lock);
> -	if (cd->entries) {
> -		write_unlock(&cd->hash_lock);
> -		spin_unlock(&cache_list_lock);
> -		goto out;
> -	}
>  	if (current_detail =3D=3D cd)
>  		current_detail =3D NULL;
>  	list_del_init(&cd->others);
> @@ -376,9 +371,6 @@ void sunrpc_destroy_cache_detail(struct cache_detail =
*cd)
>  		/* module must be being unloaded so its safe to kill the worker */
>  		cancel_delayed_work_sync(&cache_cleaner);
>  	}
> -	return;
> -out:
> -	printk(KERN_ERR "RPC: failed to unregister %s cache\n", cd->name);
>  }
>  EXPORT_SYMBOL_GPL(sunrpc_destroy_cache_detail);
>=20=20
> @@ -497,13 +489,32 @@ EXPORT_SYMBOL_GPL(cache_flush);
>=20=20
>  void cache_purge(struct cache_detail *detail)
>  {
> -	time_t now =3D seconds_since_boot();
> -	if (detail->flush_time >=3D now)
> -		now =3D detail->flush_time + 1;
> -	/* 'now' is the maximum value any 'last_refresh' can have */
> -	detail->flush_time =3D now;
> -	detail->nextcheck =3D seconds_since_boot();
> -	cache_flush();
> +	struct cache_head *ch =3D NULL;
> +	struct hlist_head *head =3D NULL;
> +	struct hlist_node *tmp =3D NULL;
> +	int i =3D 0;
> +
> +	write_lock(&detail->hash_lock);
> +	if (!detail->entries) {
> +		write_unlock(&detail->hash_lock);
> +		return;
> +	}
> +
> +	dprintk("RPC: %d entries in %s cache\n", detail->entries, detail->name);
> +	for (i =3D 0; i < detail->hash_size; i++) {
> +		head =3D &detail->hash_table[i];
> +		hlist_for_each_entry_safe(ch, tmp, head, cache_list) {
> +			hlist_del_init(&ch->cache_list);
> +			detail->entries--;
> +
> +			set_bit(CACHE_CLEANED, &ch->flags);
> +			write_unlock(&detail->hash_lock);
> +			cache_fresh_unlocked(ch, detail);
> +			cache_put(ch, detail);
> +			write_lock(&detail->hash_lock);
> +		}
> +	}
> +	write_unlock(&detail->hash_lock);
>  }
>  EXPORT_SYMBOL_GPL(cache_purge);
>=20=20
> --=20
> 2.9.3
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

--=-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEG8Yp69OQ2HB7X0l6Oeye3VZigbkFAliagBgACgkQOeye3VZi
gbnh1A//bfFcO0yWZsQMC+pmsgYONacPBk1/0P+MXTW0wd1TB0T9zVYdniL8N3rC
BB5IPkWK7+t4FATIaQkBduRrlrDq63DXlrwCW2zxgz6vw6FAP3rRN95ZtIwA3nAC
DE1CgZOZrMy1ZQd7A8ZSP9D+cH+C11NNqj+I6YP5ojBju0Gk41tOXpYCegfcaV7d
CcZIfiiLNgCrgNAFBJTJGKHPWoJ3526xgmW/Z4zZuCfrECZYFDTBYA+Y6ERjyNNU
RUbv+eekXfJh7EctGyrKKpRd55cPTjtz/AvoVxlgPW4GWSkx09phALOpU9DWVY/G
NVln2xvflYxL3S7szouI5HxPoyNlpt7UoSmmiDykBq3N89LQ77DP+GE9r1O/y4uo
u4VwVzv3f9AQPmvXf0dYNyQI15PNG0L75dtjjeeyqUHaNfv0Z92jlfbxXmXRS0xC
8SBl1Gl5O3DF9G6GxYMXOMoxH49mKmPdr595f0Y+TG1ayyLbtuaWXxlHVHbiSR4i
NgkGx20NoNt2zF1FSuqAOT1GI+PsWx3DT4JRtyDGYRu0JeIAci3pFVhUNk9FO71Z
jD7aKD7bNAylRhwsZUWuqpBV46p2KywO3lbLnSi9B6aDusCEmXvD1WZc6VxI8hL+
8EF1zE8lZhi4UWXVrjSfU8MV+yK/2oCl/TGhYOykcAuvNoR9oWY=
=9Gub
-----END PGP SIGNATURE-----
--=-=-=--
