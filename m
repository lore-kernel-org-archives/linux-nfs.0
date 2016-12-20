Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:46630 "EHLO mx2.suse.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754785AbcLTEEC (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 19 Dec 2016 23:04:02 -0500
From: NeilBrown <neilb@suse.com>
To: andros@netapp.com, bfields@fieldses.org
Date: Tue, 20 Dec 2016 15:03:54 +1100
Cc: neilb@suse.de, linux-nfs@vger.kernel.org,
        Andy Adamson <andros@netapp.com>
Subject: Re: [PATCH Version 3] SVCAUTH update the rsc cache on RPC_GSS_PROC_DESTROY
In-Reply-To: <1482192030-19219-2-git-send-email-andros@netapp.com>
References: <1482192030-19219-1-git-send-email-andros@netapp.com> <1482192030-19219-2-git-send-email-andros@netapp.com>
Message-ID: <87a8brtff9.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
        micalg=pgp-sha256; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--=-=-=
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Tue, Dec 20 2016, andros@netapp.com wrote:

> From: Andy Adamson <andros@netapp.com>
>
> The rsc cache code operates in a read_lock/write_lock environment.
> Changes to a cache entry should use the provided rsc_update
> routine which takes the write_lock.
>
> The current code sets the expiry_time and the CACHE_NEGATIVE flag
> without taking the write_lock as it does not call rsc_update.
> Without this patch, while cache_clean sees the entries to be
> removed, it does not remove the rsc_entries. This is because
> rsc_update sets other fields in the entry to properly trigger
> cache_clean.
>
> Cache_clean takes the write_lock to remove expired or invalid
> entries from the cache_list and calls cache_put on the entry.
>
> Looking at sunrpc_cache_update, what we want is to invalidate the
> cache entry, so that it is direclty replaced which means that
> update_rsc is called. We pass in a new zero'ed rsc cache entry
> to rsc_update with an expiry_time set to 0 along with the
> invalidatedcache entry to be destroyed.
>
> The cache_put at the end of svcauth_gss_accept processing drops
> the reference count to 1 which allows the cache_put called by
> cache_clean to result in a call to rsc_put and rsc_free
> to reap the entry after it has been removed from the cache_list
> under the write_lock.
>
> Signed-off-by: Andy Adamson <andros@netapp.com>
> ---
>  net/sunrpc/auth_gss/svcauth_gss.c | 18 +++++++++++++++---
>  1 file changed, 15 insertions(+), 3 deletions(-)
>
> diff --git a/net/sunrpc/auth_gss/svcauth_gss.c b/net/sunrpc/auth_gss/svca=
uth_gss.c
> index 45662d7..b8093da 100644
> --- a/net/sunrpc/auth_gss/svcauth_gss.c
> +++ b/net/sunrpc/auth_gss/svcauth_gss.c
> @@ -1409,7 +1409,9 @@ static void destroy_use_gss_proxy_proc_entry(struct=
 net *net) {}
>  	u32		crlen;
>  	struct gss_svc_data *svcdata =3D rqstp->rq_auth_data;
>  	struct rpc_gss_wire_cred *gc;
> -	struct rsc	*rsci =3D NULL;
> +	struct rsc	*rsci =3D NULL, new =3D {
> +		.mechctx =3D 0,
> +	};
>  	__be32		*rpcstart;
>  	__be32		*reject_stat =3D resv->iov_base + resv->iov_len;
>  	int		ret;
> @@ -1489,10 +1491,20 @@ static void destroy_use_gss_proxy_proc_entry(stru=
ct net *net) {}
>  	case RPC_GSS_PROC_DESTROY:
>  		if (gss_write_verf(rqstp, rsci->mechctx, gc->gc_seq))
>  			goto auth_err;
> -		rsci->h.expiry_time =3D get_seconds();
> -		set_bit(CACHE_NEGATIVE, &rsci->h.flags);
> +
> +		/** Invalidate the cache entry so sunrpc_update_cache
> +		 * direclty updates rsci. new->h.expiry_time is zero,
> +		 * so rsci->h.expiry_time will be set to zero and=20
> +		 * cache_clean will properly remove rsci.
> +		 */
> +		clear_bit(CACHE_VALID, &rsci->h.flags);

I think this is poor form.  It might work in this particular case, but
in general, clearing CACHE_VALID is the wrong thing to do.

What is the goal here?  Do we want to make sure future lookups for this
entry find a negative entry, or would we be happy for them to fail?

If they should find a negative entry, then just do the update without
messing with the CACHE_VALID flag.  It will require an allocation, but
that shouldn't be a big cost.

If you are happy for them to find nothing, the we should write a
sunrpc_cache_unhash() or similar which unlinks an entry from the cache
and decrements its refcount.

NeilBrown


> +		rsci =3D rsc_update(sn->rsc_cache, &new, rsci);
> +		if (!rsci)
> +			goto drop;
> +
>  		if (resv->iov_len + 4 > PAGE_SIZE)
>  			goto drop;
> +
>  		svc_putnl(resv, RPC_SUCCESS);
>  		goto complete;
>  	case RPC_GSS_PROC_DATA:
> --=20
> 1.8.3.1

--=-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEG8Yp69OQ2HB7X0l6Oeye3VZigbkFAlhYraoACgkQOeye3VZi
gbla1Q//Xq7pWarjt6rUa3Y6pe7u8BKmZFRV8iArjffqV+xr3zq2u45P/Ok4BJaY
UiUOyg+1fEjHBII8jSy2zvHRD+lPnyTpQa0eVPpfYrtbnqXG/pCwrp2a0FsYPGba
6MzTG2QePbHn+3lL7F+4CTL1j+2KDlVe3DQMiGJkTb484/jTxh9Ay8+9ntNgz7zV
F6y7oL7S+ujzsm3Ts98A/mWhmo5fb++IKb4/RYZTBd+mM48IMxug8VuteJAXGxZ+
L1AyRO0Ui1ozSbi8lZBZ+iz2C0B2QQtMeUwp1eNUJxZCu+83NvkLwZaH+Wpgbb1v
PQ8l8rzFg5AkUwqJ/weMK5vjZ8DQaA6QF78kVo+sWUWXcL+UN9DC5oDo2E08OoEo
J/Y5ylQ1jV9FgWYRLgIz/oyaNX264oHZ0I+2Q1gv18NgeWAOdKEMp8ieAw2quRqN
V0+Vkl1spoC1EeE1eGy2HEqkiTnLSZVwWZrBjnk2zjkF8Dr39VVlC0Ih7DiA+xV6
mybyqlvEb0KkLTdvldIgEvEuna+4spxLBFbm3ZVtyxlH0m2zdfE2+siAoDs+7k44
v1J1uNCWL0myZVWJz0rAKdHgQsQ85Ai8aadeJOZV6BoEtL5BuzkpvZdpbKsZzInY
2JsbpEOartpG+A2W7hZBDczX4w2pCGqCHzstMktOFkQVrR1T39Q=
=9Jqj
-----END PGP SIGNATURE-----
--=-=-=--
