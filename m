Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cantor2.suse.de ([195.135.220.15]:42936 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753191AbaGUHDD (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 21 Jul 2014 03:03:03 -0400
Date: Mon, 21 Jul 2014 17:02:54 +1000
From: NeilBrown <neilb@suse.de>
To: Jeff Layton <jlayton@primarydata.com>
Cc: bfields@fieldses.org, hch@infradead.org, linux-nfs@vger.kernel.org
Subject: Re: [PATCH v4 10/10] nfsd: give block_delegation and
 delegation_blocked its own spinlock
Message-ID: <20140721170254.0289ab9f@notabene.brown>
In-Reply-To: <1405696416-32585-11-git-send-email-jlayton@primarydata.com>
References: <1405696416-32585-1-git-send-email-jlayton@primarydata.com>
	<1405696416-32585-11-git-send-email-jlayton@primarydata.com>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 boundary="Sig_/Mz55+nM.Xw.SWHfGyEXDBy7"; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--Sig_/Mz55+nM.Xw.SWHfGyEXDBy7
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

On Fri, 18 Jul 2014 11:13:36 -0400 Jeff Layton <jlayton@primarydata.com>
wrote:

> The state lock can be fairly heavily contended, and there's no reason
> that nfs4_file lookups and delegation_blocked should be mutually
> exclusive.  Let's give the new block_delegation code its own spinlock.
> It does mean that we'll need to take a different lock in the delegation
> break code, but that's not generally as critical to performance.
>=20
> Cc: Neil Brown <neilb@suse.de>
> Signed-off-by: Jeff Layton <jlayton@primarydata.com>

Makes sense, thanks.
However.....


> ---
>  fs/nfsd/nfs4state.c | 25 +++++++++++++------------
>  1 file changed, 13 insertions(+), 12 deletions(-)
>=20
> diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
> index a2c6c85adfc7..952def00363b 100644
> --- a/fs/nfsd/nfs4state.c
> +++ b/fs/nfsd/nfs4state.c
> @@ -506,10 +506,11 @@ static struct nfs4_ol_stateid * nfs4_alloc_stateid(=
struct nfs4_client *clp)
>   * Each filter is 256 bits.  We hash the filehandle to 32bit and use the
>   * low 3 bytes as hash-table indices.
>   *
> - * 'state_lock', which is always held when block_delegations() is called,
> - * is used to manage concurrent access.  Testing does not need the lock
> - * except when swapping the two filters.
> + * 'blocked_delegations_lock', which is always held when block_delegatio=
ns()
> + * is called, is used to manage concurrent access.  Testing does not nee=
d the
> + * lock except when swapping the two filters.

...this comment is wrong.  blocked_delegations_lock is *not* held when
block_delegations() is call, it is taken when needed (almost) by
block_delegations.

>   */
> +static DEFINE_SPINLOCK(blocked_delegations_lock);
>  static struct bloom_pair {
>  	int	entries, old_entries;
>  	time_t	swap_time;
> @@ -525,7 +526,7 @@ static int delegation_blocked(struct knfsd_fh *fh)
>  	if (bd->entries =3D=3D 0)
>  		return 0;
>  	if (seconds_since_boot() - bd->swap_time > 30) {
> -		spin_lock(&state_lock);
> +		spin_lock(&blocked_delegations_lock);
>  		if (seconds_since_boot() - bd->swap_time > 30) {
>  			bd->entries -=3D bd->old_entries;
>  			bd->old_entries =3D bd->entries;
> @@ -534,7 +535,7 @@ static int delegation_blocked(struct knfsd_fh *fh)
>  			bd->new =3D 1-bd->new;
>  			bd->swap_time =3D seconds_since_boot();
>  		}
> -		spin_unlock(&state_lock);
> +		spin_unlock(&blocked_delegations_lock);
>  	}
>  	hash =3D arch_fast_hash(&fh->fh_base, fh->fh_size, 0);
>  	if (test_bit(hash&255, bd->set[0]) &&
> @@ -555,16 +556,16 @@ static void block_delegations(struct knfsd_fh *fh)
>  	u32 hash;
>  	struct bloom_pair *bd =3D &blocked_delegations;
> =20
> -	lockdep_assert_held(&state_lock);
> -
>  	hash =3D arch_fast_hash(&fh->fh_base, fh->fh_size, 0);
> =20
>  	__set_bit(hash&255, bd->set[bd->new]);
>  	__set_bit((hash>>8)&255, bd->set[bd->new]);
>  	__set_bit((hash>>16)&255, bd->set[bd->new]);
> +	spin_lock(&blocked_delegations_lock);

__set_bit isn't atomic.  The spin_lock should be taken *before* these
__set_bit() calls.

Otherwise, looks fine.

Thanks,
NeilBrown


>  	if (bd->entries =3D=3D 0)
>  		bd->swap_time =3D seconds_since_boot();
>  	bd->entries +=3D 1;
> +	spin_unlock(&blocked_delegations_lock);
>  }
> =20
>  static struct nfs4_delegation *
> @@ -3097,16 +3098,16 @@ void nfsd4_prepare_cb_recall(struct nfs4_delegati=
on *dp)
>  	struct nfs4_client *clp =3D dp->dl_stid.sc_client;
>  	struct nfsd_net *nn =3D net_generic(clp->net, nfsd_net_id);
> =20
> -	/*
> -	 * We can't do this in nfsd_break_deleg_cb because it is
> -	 * already holding inode->i_lock
> -	 */
> -	spin_lock(&state_lock);
>  	block_delegations(&dp->dl_fh);
> +
>  	/*
> +	 * We can't do this in nfsd_break_deleg_cb because it is
> +	 * already holding inode->i_lock.
> +	 *
>  	 * If the dl_time !=3D 0, then we know that it has already been
>  	 * queued for a lease break. Don't queue it again.
>  	 */
> +	spin_lock(&state_lock);
>  	if (dp->dl_time =3D=3D 0) {
>  		dp->dl_time =3D get_seconds();
>  		list_add_tail(&dp->dl_recall_lru, &nn->del_recall_lru);


--Sig_/Mz55+nM.Xw.SWHfGyEXDBy7
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.22 (GNU/Linux)

iQIVAwUBU8y7Hjnsnt1WYoG5AQJ7jg/+Ir38rKg3POj0+yQc/Xk+ct6lu1AqEcfZ
O4DgpH/cT8+bF7FDUm7rjBb2P790iN2zZKQtfY2rP250LOye5ou1hSMyAvwnbX2y
ylg1v39zgqlegyxP2bLe8cmjSooActxQ7P8ZLoTVmn31xeo6teK73USAD8DTBJLX
hFHLID6jQd/jP3HY8lXdhDNlLl4I4+bCtFKlQ9NAGYMNCTWumCrDHiFqKaS0yKdt
1Z0JlGgowqfTCzjhaAdr4BhIwADfav1uOr1ZU0zhd6uyZ/Xgv3+IDhyAN5ImRrd3
X7UBwlwVhGWTtCBsETNnk6Nb5E8HllXFNkovhLAsXCWWyRY2deLu01FeSVaqMZT0
CmQfg179rd8cZEdyLDUrbW0sVjN5NwXgUaLjZHplZp8ynwMw/mKR+3vikNrR9shf
AeFKm3RwTV6TSoeA2wUj1C67r7pgbCGsvwKxjiwJAKKzQR/aHu18YR8mD7bvhnu0
olR9MM6K/Qa5HOEKBpExAqxM/Kyfzl3HkyyFLOH1yBaSnGQwwsySYOlJDm2ClbkJ
x/R5xQGIHvzIOf1oAI/Y6ddaSH99DrMhiD2Jk8igwUhtUPAuLoxhhf4EScjwmJyg
FfW4jbiD5Rm9ZN0TA/QvSIuDIIZF9KwPV7jZMfX31Ps8zevtCY8prSfU823Vd621
w1HJeYmeo6Q=
=LyYa
-----END PGP SIGNATURE-----

--Sig_/Mz55+nM.Xw.SWHfGyEXDBy7--
