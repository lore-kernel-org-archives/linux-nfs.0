Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qa0-f49.google.com ([209.85.216.49]:61580 "EHLO
	mail-qa0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753839AbaGULoR (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 21 Jul 2014 07:44:17 -0400
Received: by mail-qa0-f49.google.com with SMTP id dc16so5009579qab.36
        for <linux-nfs@vger.kernel.org>; Mon, 21 Jul 2014 04:44:16 -0700 (PDT)
From: Jeff Layton <jeff.layton@primarydata.com>
Date: Mon, 21 Jul 2014 07:44:12 -0400
To: NeilBrown <neilb@suse.de>
Cc: bfields@fieldses.org, hch@infradead.org, linux-nfs@vger.kernel.org
Subject: Re: [PATCH v4 10/10] nfsd: give block_delegation and
 delegation_blocked its own spinlock
Message-ID: <20140721074412.4d9be086@tlielax.poochiereds.net>
In-Reply-To: <20140721170254.0289ab9f@notabene.brown>
References: <1405696416-32585-1-git-send-email-jlayton@primarydata.com>
	<1405696416-32585-11-git-send-email-jlayton@primarydata.com>
	<20140721170254.0289ab9f@notabene.brown>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 boundary="Sig_/GGdF7HKbQP+VoiyDQnY/j9Y"; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--Sig_/GGdF7HKbQP+VoiyDQnY/j9Y
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

On Mon, 21 Jul 2014 17:02:54 +1000
NeilBrown <neilb@suse.de> wrote:

> On Fri, 18 Jul 2014 11:13:36 -0400 Jeff Layton <jlayton@primarydata.com>
> wrote:
>=20
> > The state lock can be fairly heavily contended, and there's no reason
> > that nfs4_file lookups and delegation_blocked should be mutually
> > exclusive.  Let's give the new block_delegation code its own spinlock.
> > It does mean that we'll need to take a different lock in the delegation
> > break code, but that's not generally as critical to performance.
> >=20
> > Cc: Neil Brown <neilb@suse.de>
> > Signed-off-by: Jeff Layton <jlayton@primarydata.com>
>=20
> Makes sense, thanks.
> However.....
>=20
>=20
> > ---
> >  fs/nfsd/nfs4state.c | 25 +++++++++++++------------
> >  1 file changed, 13 insertions(+), 12 deletions(-)
> >=20
> > diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
> > index a2c6c85adfc7..952def00363b 100644
> > --- a/fs/nfsd/nfs4state.c
> > +++ b/fs/nfsd/nfs4state.c
> > @@ -506,10 +506,11 @@ static struct nfs4_ol_stateid * nfs4_alloc_statei=
d(struct nfs4_client *clp)
> >   * Each filter is 256 bits.  We hash the filehandle to 32bit and use t=
he
> >   * low 3 bytes as hash-table indices.
> >   *
> > - * 'state_lock', which is always held when block_delegations() is call=
ed,
> > - * is used to manage concurrent access.  Testing does not need the lock
> > - * except when swapping the two filters.
> > + * 'blocked_delegations_lock', which is always held when block_delegat=
ions()
> > + * is called, is used to manage concurrent access.  Testing does not n=
eed the
> > + * lock except when swapping the two filters.
>=20
> ...this comment is wrong.  blocked_delegations_lock is *not* held when
> block_delegations() is call, it is taken when needed (almost) by
> block_delegations.
>=20

Thanks, fixed.

> >   */
> > +static DEFINE_SPINLOCK(blocked_delegations_lock);
> >  static struct bloom_pair {
> >  	int	entries, old_entries;
> >  	time_t	swap_time;
> > @@ -525,7 +526,7 @@ static int delegation_blocked(struct knfsd_fh *fh)
> >  	if (bd->entries =3D=3D 0)
> >  		return 0;
> >  	if (seconds_since_boot() - bd->swap_time > 30) {
> > -		spin_lock(&state_lock);
> > +		spin_lock(&blocked_delegations_lock);
> >  		if (seconds_since_boot() - bd->swap_time > 30) {
> >  			bd->entries -=3D bd->old_entries;
> >  			bd->old_entries =3D bd->entries;
> > @@ -534,7 +535,7 @@ static int delegation_blocked(struct knfsd_fh *fh)
> >  			bd->new =3D 1-bd->new;
> >  			bd->swap_time =3D seconds_since_boot();
> >  		}
> > -		spin_unlock(&state_lock);
> > +		spin_unlock(&blocked_delegations_lock);
> >  	}
> >  	hash =3D arch_fast_hash(&fh->fh_base, fh->fh_size, 0);
> >  	if (test_bit(hash&255, bd->set[0]) &&
> > @@ -555,16 +556,16 @@ static void block_delegations(struct knfsd_fh *fh)
> >  	u32 hash;
> >  	struct bloom_pair *bd =3D &blocked_delegations;
> > =20
> > -	lockdep_assert_held(&state_lock);
> > -
> >  	hash =3D arch_fast_hash(&fh->fh_base, fh->fh_size, 0);
> > =20
> >  	__set_bit(hash&255, bd->set[bd->new]);
> >  	__set_bit((hash>>8)&255, bd->set[bd->new]);
> >  	__set_bit((hash>>16)&255, bd->set[bd->new]);
> > +	spin_lock(&blocked_delegations_lock);
>=20
> __set_bit isn't atomic.  The spin_lock should be taken *before* these
> __set_bit() calls.
>=20
> Otherwise, looks fine.
>=20
> Thanks,
> NeilBrown
>=20
>=20

Ok. I guess the worry is that we could end up setting bits in the
middle of swapping the two fields? Makes sense -- fixed in my repo.
I'll send out the updated set later today (it also includes a few nits
that HCH pointed out last week).

As a side note...I wonder how much we'll get in the way of false
positives with this scheme?

Given that we'll always have (or will have had) a nfs4_file
corresponding to this inode, perhaps we'd be better off doing something
like storing (and maybe hashing on) the filehandle in the nfs4_file,
and just ensuring that we hold on to it for 30s or so after the last
put?

Not something I'm looking at doing today, but it might be worth
considering for a later delegations rework.

> >  	if (bd->entries =3D=3D 0)
> >  		bd->swap_time =3D seconds_since_boot();
> >  	bd->entries +=3D 1;
> > +	spin_unlock(&blocked_delegations_lock);
> >  }
> > =20
> >  static struct nfs4_delegation *
> > @@ -3097,16 +3098,16 @@ void nfsd4_prepare_cb_recall(struct nfs4_delega=
tion *dp)
> >  	struct nfs4_client *clp =3D dp->dl_stid.sc_client;
> >  	struct nfsd_net *nn =3D net_generic(clp->net, nfsd_net_id);
> > =20
> > -	/*
> > -	 * We can't do this in nfsd_break_deleg_cb because it is
> > -	 * already holding inode->i_lock
> > -	 */
> > -	spin_lock(&state_lock);
> >  	block_delegations(&dp->dl_fh);
> > +
> >  	/*
> > +	 * We can't do this in nfsd_break_deleg_cb because it is
> > +	 * already holding inode->i_lock.
> > +	 *
> >  	 * If the dl_time !=3D 0, then we know that it has already been
> >  	 * queued for a lease break. Don't queue it again.
> >  	 */
> > +	spin_lock(&state_lock);
> >  	if (dp->dl_time =3D=3D 0) {
> >  		dp->dl_time =3D get_seconds();
> >  		list_add_tail(&dp->dl_recall_lru, &nn->del_recall_lru);
>=20


--=20
Jeff Layton <jlayton@primarydata.com>

--Sig_/GGdF7HKbQP+VoiyDQnY/j9Y
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBAgAGBQJTzP0NAAoJEAAOaEEZVoIVMj4P/R5AGdhGuxJ5dX84hQnWw0ju
Sr2bWZJWup01tXwD0kuLV4j6duzsUqrr3I+HaNFjt/owA3UAxiCUNVjLFQ3MrEUx
uU86NgFgNkUdxmOf7QDWhIrWHL4bI6pCmO5GICGCaibwa+Rl4Qr4byd8MNxvNoOb
1xOYCzrQcZBdA4DU0DJiT7BZeYajzwkOzqVGZZD0h51FDScxuxJq2ljTGcLwtREf
796I4CgWeOHFLetLDb1sX9+h4XvJvxpj1CfQt3dk0WdEwl5BQPHQv8wvKj7RY4/c
5n9bdktA5frx9puNvVaKDSa2qkiViVEeUQIKskLD2xDvzZo/g55mzpaB0xnTubf0
4Xl2UMbCgWnr/hFFdh7RKVtZZLnMJOk2buY9+QIVvQcaczEm4UL4eMH/Y/VtP2E7
aYnamYYlTdbuDi5MC/TpmUI8U2Lo9bDU7K1ArhexaNAZZTwRfOEXXkSVbQdjvbYo
4PY6N6KDUB+YbrPIPSydjonVJIaYssL2U9y4MhK2C1tfyU+mqBByi3bpeEo80FUk
VFtMKiBADMMJaMGDLVFCCDEe3S7Y9IGOoC4qcZcKwRhZxgRWnfmkQnb9r6HYtZpi
+nHibqas8EIAAh50e8nonPfT/FKmBMMZpdJJZbg8urWl+N2uAnu0jiM0hGgz9TQN
vPyNTLyi8afDWYzdy9Ks
=jFC2
-----END PGP SIGNATURE-----

--Sig_/GGdF7HKbQP+VoiyDQnY/j9Y--
