Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qc0-f175.google.com ([209.85.216.175]:32872 "EHLO
	mail-qc0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750734AbaIJL7r (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 10 Sep 2014 07:59:47 -0400
Received: by mail-qc0-f175.google.com with SMTP id c9so19117532qcz.34
        for <linux-nfs@vger.kernel.org>; Wed, 10 Sep 2014 04:59:46 -0700 (PDT)
From: Jeff Layton <jeff.layton@primarydata.com>
Date: Wed, 10 Sep 2014 07:59:43 -0400
To: NeilBrown <neilb@suse.de>
Cc: Christoph Hellwig <hch@infradead.org>, linux-nfs@vger.kernel.org
Subject: Re: kernel BUG in fs/dcache.c running nfs
Message-ID: <20140910075943.327db1b0@tlielax.poochiereds.net>
In-Reply-To: <20140910135739.2b897d94@notabene.brown>
References: <20140908144525.GB19811@infradead.org>
	<20140909105918.59477ee3@tlielax.poochiereds.net>
	<20140909154211.GA6614@infradead.org>
	<20140909121244.610f297d@tlielax.poochiereds.net>
	<20140909121546.3981121b@tlielax.poochiereds.net>
	<20140909135006.2b956f47@tlielax.poochiereds.net>
	<20140910135739.2b897d94@notabene.brown>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 boundary="Sig_/2Klg8=Ca0nV3a=7V3lW9+/d"; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--Sig_/2Klg8=Ca0nV3a=7V3lW9+/d
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

On Wed, 10 Sep 2014 13:57:39 +1000
NeilBrown <neilb@suse.de> wrote:

> On Tue, 9 Sep 2014 13:50:06 -0400 Jeff Layton <jeff.layton@primarydata.co=
m>
> wrote:
>=20
> > On Tue, 9 Sep 2014 12:15:46 -0400
> > Jeff Layton <jeff.layton@primarydata.com> wrote:
> >=20
> > > On Tue, 9 Sep 2014 12:12:44 -0400
> > > Jeff Layton <jlayton@primarydata.com> wrote:
> > >=20
> > > > On Tue, 9 Sep 2014 08:42:11 -0700
> > > > Christoph Hellwig <hch@infradead.org> wrote:
> > > >=20
> > > > > On Tue, Sep 09, 2014 at 10:59:18AM -0400, Jeff Layton wrote:
> > > > > > > [ 5497.405585]  [<ffffffff8135d0c1>] nfs4_do_open.constprop.8=
4+0x681/0x960
> > > > > > > [ 5497.405585]  [<ffffffff8135d459>] nfs4_atomic_open+0x9/0x20
> > > > > > > [ 5497.405585]  [<ffffffff8136cc3d>] nfs4_file_open+0xcd/0x1b0
> > > > > > > [ 5497.405585]  [<ffffffff811b8092>] do_dentry_open.isra.13+0=
x1f2/0x320
> > > > > > > [ 5497.405585]  [<ffffffff811b82ad>] finish_open+0x1d/0x30
> > > > > > > [ 5497.405585]  [<ffffffff811c98e9>] path_openat+0xb9/0x670
> > > > > > > [ 5497.405585]  [<ffffffff811ca26e>] do_filp_open+0x3e/0xa0
> > > > > > > [ 5497.405585]  [<ffffffff811b95cc>] do_sys_open+0x13c/0x230
> > > > > > > [ 5497.405585]  [<ffffffff811b96dd>] SyS_open+0x1d/0x20
> > > > > > > [ 5497.405585]  [<ffffffff81d9f5a9>] system_call_fastpath+0x1=
6/0x1b
> > > > > > >=20
> > > > > >=20
> > > > > > Odd...
> > > > > >=20
> > > > > > It looks like you hit the BUG() in d_instantiate.
> > > > > >=20
> > > > > > I don't see any calls to d_instantiate in the current nfs_code =
(aside
> > > > > > from the one in nfs_lookup, and I don't think that's getting ca=
lled
> > > > > > here). d_instantiate is called by d_add though, and that gets c=
alled
> > > > > > from nfs_atomic_open. Is that what happened here?
> > > > > >=20
> > > > > > Maybe you can use gdb to figure out what line of code
> > > > > > "nfs4_do_open.constprop.84+0x681" actually is?
> > > > >=20
> > > > > My gdb can't cope with these constprop expressions unfortunately.
> > > > >=20
> > > > > But when you remove the questionable symbols as I've done above i=
t's
> > > > > pretty clear that this must be the
> > > > >=20
> > > > > nfs4_atomic_open
> > > > >  -> nfs4_do_open
> > > > >    -> _nfs4_do_open
> > > > >      -> _nfs4_open_and_get_state
> > > > >        -> d_add
> > > > >          -> d_instantiate
> > > > >=20
> > > > > call chain. There is heavy inlining going on inside nfs4file.c, a=
nd
> > > > > d_add now is a simple inline around d_instantiate and d_rehash.
> > > >=20
> > > > Ok. So I'm guessing that means that the current scheme of doing a
> > > > d_drop/d_add is not valid. d_drop doesn't remove the dentry from the
> > > > i_alias list.
> > > >=20
> > > > It looks like the first call there should just be doing a d_delete
> > > > instead, since it's trying to turn the thing into a negative dentry.
> > >=20
> > > (cc'ing Neil B.)
> > >=20
> > > ...and I'd hazard a guess that 4fa2c54b5198d might be the culprit. You
> > > might want to try backing that out and see if it's still reproducible.
> > >=20
> > > Neil, any thoughts?
> > >=20
> >=20
> > In fact, maybe this patch would make sense?
> >=20
> > ------------------[snip]-------------------
> >=20
> > [PATCH] nfs: d_drop/d_add of positive dentry may be harmful
> >=20
> > Christoph reported the following oops, when running xfstests:
> >=20
> > generic/089 199s ...
> > [ 5497.402293] ------------[ cut here ]------------
> > [ 5497.403150] kernel BUG at ../fs/dcache.c:1620!
> > [ 5497.403974] invalid opcode: 0000 [#1] SMP
> > [ 5497.404826] Modules linked in:
> > [ 5497.405280] CPU: 1 PID: 14691 Comm: t_mtab Not tainted 3.17.0-rc3+ #=
264
> > [ 5497.405585] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2007
> > [ 5497.405585] task: ffff88007ac801d0 ti: ffff8800670a4000 task.ti: fff=
f8800670a4000
> > [ 5497.405585] RIP: 0010:[<ffffffff811d1345>]  [<ffffffff811d1345>] d_i=
nstantiate+0x75/0x80
> > [ 5497.405585] RSP: 0018:ffff8800670a7a68  EFLAGS: 00010286
> > [ 5497.405585] RAX: 0000000000000001 RBX: ffff880066c399d8 RCX: ffff880=
07ac80990
> > [ 5497.405585] RDX: 0000000000000000 RSI: 0000000000000000 RDI: ffff880=
066c399d8
> > [ 5497.405585] RBP: ffff8800670a7a88 R08: 0000000000000001 R09: 0000000=
000000000
> > [ 5497.405585] R10: ffff880072f45000 R11: 000000000003fdf0 R12: ffff880=
066c399d8
> > [ 5497.405585] R13: ffff88007a684800 R14: ffff88007acbc280 R15: ffff880=
0670de000
> > [ 5497.405585] FS:  00007f6db6aae700(0000) GS:ffff88007fc80000(0000) kn=
lGS:0000000000000000
> > [ 5497.405585] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
> > [ 5497.405585] CR2: 00007f6db5f56800 CR3: 000000007ac9e000 CR4: 0000000=
0000006e0
> > [ 5497.405585] Stack:
> > [ 5497.405585]  ffff8800670a7a88 ffff880066c399d8 ffff88007a684800 ffff=
88007a684800
> > [ 5497.405585]  ffff8800670a7b68 ffffffff8135d0c1 ffffffff00000004 ffff=
8800000000d0
> > [ 5497.405585]  ffff88007d400180 0000000000000246 ffff8800fffffffe ffff=
880072f45000
> > [ 5497.405585] Call Trace:
> > [ 5497.405585]  [<ffffffff8135d0c1>] nfs4_do_open.constprop.84+0x681/0x=
960
> > [ 5497.405585]  [<ffffffff8135d459>] nfs4_atomic_open+0x9/0x20
> > [ 5497.405585]  [<ffffffff8136cc3d>] nfs4_file_open+0xcd/0x1b0
> > [ 5497.405585]  [<ffffffff81d9ee56>] ? _raw_spin_unlock+0x26/0x30
> > [ 5497.405585]  [<ffffffff8176b73d>] ? lockref_get+0x1d/0x30
> > [ 5497.405585]  [<ffffffff8136cb70>] ? nfs4_file_fsync+0xb0/0xb0
> > [ 5497.405585]  [<ffffffff811b8092>] do_dentry_open.isra.13+0x1f2/0x320
> > [ 5497.405585]  [<ffffffff81336f52>] ? nfs_permission+0x62/0x1d0
> > [ 5497.405585]  [<ffffffff811b82ad>] finish_open+0x1d/0x30
> > [ 5497.405585]  [<ffffffff811c91be>] do_last.isra.63+0x62e/0xca0
> > [ 5497.405585]  [<ffffffff811c5703>] ? inode_permission+0x13/0x50
> > [ 5497.405585]  [<ffffffff811c5bde>] ? link_path_walk+0x23e/0x850
> > [ 5497.405585]  [<ffffffff811c98e9>] path_openat+0xb9/0x670
> > [ 5497.405585]  [<ffffffff811b366b>] ? poison_obj+0x2b/0x40
> > [ 5497.405585]  [<ffffffff811ca26e>] do_filp_open+0x3e/0xa0
> > [ 5497.405585]  [<ffffffff811d7da1>] ? __alloc_fd+0xd1/0x120
> > [ 5497.405585]  [<ffffffff811b95cc>] do_sys_open+0x13c/0x230
> > [ 5497.405585]  [<ffffffff810f5bbd>] ? trace_hardirqs_on_caller+0x10d/0=
x1d0
> > [ 5497.405585]  [<ffffffff811b96dd>] SyS_open+0x1d/0x20
> > [ 5497.405585]  [<ffffffff81d9f5a9>] system_call_fastpath+0x16/0x1b
> >=20
> > The BUG() is due to the fact that the d_alias hlist is not empty when
> > we called into d_instantiate. This is likely due to a situation where
> > we did a successful open and instantiated the dentry and then later
> > failed and ended up retrying. At that point, we try the open again and
> > get back -ENOENT, and try to d_drop/d_add it.
> >=20
> > The problem is that d_drop'ing a positive dentry is not sufficient to
> > "clear" it for adding it back into the cache. That just makes it unfind=
able
> > in the hash tables, but doesn't unhitch it from the inode.
> >=20
> > Switch to using the helper we already have for turning positive dentries
> > into negative ones.
> >=20
> > Cc: Neil Brown <neilb@suse.de>
> > Reported-by: Christoph Hellwig <hch@infradead.org>
> > Signed-off-by: Jeff Layton <jlayton@primarydata.com>
> > ---
> >  fs/nfs/dir.c      | 3 ++-
> >  fs/nfs/internal.h | 1 +
> >  fs/nfs/nfs4proc.c | 3 +--
> >  3 files changed, 4 insertions(+), 3 deletions(-)
> >=20
> > diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
> > index 36d921f0c602..3938dba859c5 100644
> > --- a/fs/nfs/dir.c
> > +++ b/fs/nfs/dir.c
> > @@ -1754,11 +1754,12 @@ out_err:
> >  }
> >  EXPORT_SYMBOL_GPL(nfs_mkdir);
> > =20
> > -static void nfs_dentry_handle_enoent(struct dentry *dentry)
> > +void nfs_dentry_handle_enoent(struct dentry *dentry)
> >  {
> >  	if (dentry->d_inode !=3D NULL && !d_unhashed(dentry))
> >  		d_delete(dentry);
> >  }
> > +EXPORT_SYMBOL_GPL(nfs_dentry_handle_enoent);
> > =20
> >  int nfs_rmdir(struct inode *dir, struct dentry *dentry)
> >  {
> > diff --git a/fs/nfs/internal.h b/fs/nfs/internal.h
> > index 9056622d2230..8d85a57ae499 100644
> > --- a/fs/nfs/internal.h
> > +++ b/fs/nfs/internal.h
> > @@ -326,6 +326,7 @@ extern unsigned long nfs_access_cache_scan(struct s=
hrinker *shrink,
> >  struct dentry *nfs_lookup(struct inode *, struct dentry *, unsigned in=
t);
> >  int nfs_create(struct inode *, struct dentry *, umode_t, bool);
> >  int nfs_mkdir(struct inode *, struct dentry *, umode_t);
> > +void nfs_dentry_handle_enoent(struct dentry *);
> >  int nfs_rmdir(struct inode *, struct dentry *);
> >  int nfs_unlink(struct inode *, struct dentry *);
> >  int nfs_symlink(struct inode *, struct dentry *, const char *);
> > diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
> > index 7dd8aca31c29..84ee3fb9e410 100644
> > --- a/fs/nfs/nfs4proc.c
> > +++ b/fs/nfs/nfs4proc.c
> > @@ -2226,8 +2226,7 @@ static int _nfs4_open_and_get_state(struct nfs4_o=
pendata *opendata,
> >  	ret =3D _nfs4_proc_open(opendata);
> >  	if (ret !=3D 0) {
> >  		if (ret =3D=3D -ENOENT) {
> > -			d_drop(opendata->dentry);
> > -			d_add(opendata->dentry, NULL);
> > +			nfs_dentry_handle_enoent(opendata->dentry);
> >  			nfs_set_verifier(opendata->dentry,
> >  					 nfs_save_change_attribute(opendata->dir->d_inode));
> >  		}
>=20
>=20
> The d_drop();d_add(); pattern is used a number of times in NFS, but what I
> didn't notice before is that it is only used if ->d_inode is NULL.
>=20
> We *could* simply change the condition to
>    if (ret =3D=3D -ENOENT && opendata->dentry->d_inode =3D=3D NULL) {
>=20
> Calling nfs_dentry_handle_enoent() is possibly a good idea, but we do wan=
t to
> still call d_add().  The whole point of the patch which introduce that co=
de
> was to ensure that negative entries were cached.
> nfs_dentry_handle_enoent()  is always enough to prepare for d_add(), so we
> cannot just replace d_drop with that.
>=20
> Maybe:
>=20
>   if (ret =3D=3D -ENOENT) {
> 	struct dentry *de =3D opendata->dentry;
> 	d_drop(de->d_inode);
>         if (de->d_inode =3D=3D NULL)
> 		d_add(de, NULL);
>         nfs_set_verifier(de, .....);
>   }
>=20

Yeah using nfs_dentry_handle_enoent won't hash a brand new negative
dentry. The above code though won't convert an existing positive dentry
into a negative one. I guess though that's a rare enough situation that
it's not worth optimizing for?

--=20
Jeff Layton <jlayton@primarydata.com>

--Sig_/2Klg8=Ca0nV3a=7V3lW9+/d
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBAgAGBQJUED0wAAoJEAAOaEEZVoIVE+YQAMsPsvgu3FB5u7j9/KB3rlqE
GIWMdQQgPB6KbG3CQN+dQHUpMO1LsHqz2VfsbU5sM0jWzLNAkIR7DK6IwH7+9NiC
mICMd6ii12RCKQGnFgPPZNQfW7cNQTgpI56auELiwtam7ZLa4zf27GYbhz6lLlEM
yhEn5K3tyo3V4zFUGk52xM02s6txS0uf9W03f5esa++fjISL/2pL+NoDYmrOMPlw
m61SpKYdNDLJqMx1wi89TMTaQ+CHQgdmALMyjQvUfH+iww58Ts4THkGFYueAquPP
g/AJxE+zw7rc2p3ImvmHWfIIU2dQ/TizX5MSb+gOqCgKj4bbcTHWQ9L57ll9tlRK
hEg+5QNFslMW1VFUHTk+eVnJdIxals9ouJBQgwMpjmyp3bU26cWjrP+uSGachYwL
S3XHQk5aCRqeJVx4Niyiz2nU54qrefQbTpN1GAbi7VO/gcO7QDxNlDumMD5DZtyv
mZUZsO9+is4azksUk8dRLOvUmZ3V7tlIyWJmpUbbKihd9CFEa2gHqFEdG7s4JUuG
qEiThy/Gwazxg9hHULZ7S0EUAWHtubWWYICbwt4wzJuQ8t0kmOlrfvm0I7+PZhXV
0PHGbkenSdu4LYeYMju6UymITbmijo9K1IU2X38zA738qI8e+/o6HtTgbGKn7Eee
SDalKTd7x922FxX1f6fo
=DaK0
-----END PGP SIGNATURE-----

--Sig_/2Klg8=Ca0nV3a=7V3lW9+/d--
