Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:34104 "EHLO mx2.suse.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751336AbdBHAGL (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 7 Feb 2017 19:06:11 -0500
From: NeilBrown <neilb@suse.com>
To: Kinglong Mee <kinglongmee@gmail.com>,
        "J. Bruce Fields" <bfields@fieldses.org>, linux-nfs@vger.kernel.org
Date: Wed, 08 Feb 2017 11:04:49 +1100
Cc: Trond Myklebust <trond.myklebust@primarydata.com>,
        Kinglong Mee <kinglongmee@gmail.com>
Subject: Re: [PATCH 2/2] SUNRPC: Drop all entries from cache_detail when cache_purge()
In-Reply-To: <400d714e-3e4c-74b0-6734-96dbf491b9d9@gmail.com>
References: <400d714e-3e4c-74b0-6734-96dbf491b9d9@gmail.com>
Message-ID: <87vaslv97i.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
        micalg=pgp-sha256; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--=-=-=
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Mon, Feb 06 2017, Kinglong Mee wrote:

> User always free the cache_detail after sunrpc_destroy_cache_detail(),
> so, it must cleanup up entries that left in the cache_detail,
> otherwise, NULL reference may be caused when using the left entries.
>
> Also, NeriBrown suggests "write a stand-alone cache_purge()."
>
> v2, a stand-alone cache_purge(), not only for sunrpc_destroy_cache_detail
>
> Signed-off-by: Kinglong Mee <kinglongmee@gmail.com>
> ---
>  net/sunrpc/cache.c | 39 ++++++++++++++++++++++++---------------
>  1 file changed, 24 insertions(+), 15 deletions(-)
>
> diff --git a/net/sunrpc/cache.c b/net/sunrpc/cache.c
> index 8147e8d..bd6ee79 100644
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
> @@ -497,13 +489,30 @@ EXPORT_SYMBOL_GPL(cache_flush);
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
> +			cache_fresh_unlocked(ch, detail);
> +			cache_put(ch, detail);

I'm a little bothered by calling cache_fresh_unlocked() while holding
=2D>hash_lock.  No other code does that.
You could probably argue that we don't need ->hash_lock at all here
because by the time we call cache_purge(), there cannot safely be any
other users.  Should we just drop the write_lock() call?

NeilBrown


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

iQIzBAEBCAAdFiEEG8Yp69OQ2HB7X0l6Oeye3VZigbkFAliaYKEACgkQOeye3VZi
gbnRsA/9FzdPZfwidcjbrnzgdOXuUI+XGbasNiI8TSrM29+Z81xS/yH3W0p/FSv9
utCD2LvrB5kbsOWe1Hltc9plbA26Ktogv2hBe5QizPU/DCZgjvA9gnu5oOZsyly0
Noe+wo/dzV2iGEVnFxW8CiB3Q/ETmpHlCw7FdwsMA4by5ub3F4BHpXUWY9xbaTc2
SKJlEC4XYw1FPB8kfxA2M+6BwaXa+QM87eaBKsIi697Pcb9P8gdKGAsq7wdw7WLB
Sjk/mbMnxChPyu+qVT/ZBLJ2HnivdaCgJfd2CNt/2fp8djhHHn1ZLW54ZlZ1Pf6x
1X8N+PAUF4+DDSBKvAFrTDU4d8nJLMvzeVsfA0nLQm6A9qZrpozfzYK9f9lBk/GD
/Si6Jm38CxVei31XT9ZTiEfXixSsvhkoEfz84MQv9sNX/8hBLYp7eMwzaPjrr/U0
GlsHc6ngdjjQ1+UfwwiM+3WCsiS0StvvnmxoW02gyOPc2zsg/7LMP1h3P2PSw+av
OAqQPw56cVM63DHgp6SzV822+d/s32jVoB4DFJKDGAYchv0vVyJBdEz9W9aZ1sa/
iAsZ3eJMuvWRb3YcD0MJgxeLuyzfYe77PnYIi42MvdbZR1dTcWnCnSkr/XB+2i9V
58OjtLJ5TFndl2k4SavfGu17ShGmEz9fxNWkqelynkqgFwRamfM=
=UN3l
-----END PGP SIGNATURE-----
--=-=-=--
