Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qc0-f172.google.com ([209.85.216.172]:63917 "EHLO
	mail-qc0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756881AbaGQLWv (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 17 Jul 2014 07:22:51 -0400
Received: by mail-qc0-f172.google.com with SMTP id l6so1905858qcy.17
        for <linux-nfs@vger.kernel.org>; Thu, 17 Jul 2014 04:22:50 -0700 (PDT)
From: Jeff Layton <jeff.layton@primarydata.com>
Date: Thu, 17 Jul 2014 07:22:41 -0400
To: NeilBrown <neilb@suse.de>
Cc: Jeff Layton <jeff.layton@primarydata.com>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        Alexander Viro <viro@zeniv.linux.org.uk>,
        NFS <linux-nfs@vger.kernel.org>, Miklos Szeredi <miklos@szeredi.hu>,
        linux-fsdevel@vger.kernel.org
Subject: Re: [PATCH] NFS: nfs4_lookup_revalidate need to report STALE
 inodes.
Message-ID: <20140717072241.2c1549a3@tlielax.poochiereds.net>
In-Reply-To: <20140717115024.1eb7433d@notabene.brown>
References: <20140714151405.2fa06dd7@notabene.brown>
	<20140714081455.69f55224@tlielax.poochiereds.net>
	<20140714223513.47807c98@notabene.brown>
	<20140714090028.6f04fd2c@tlielax.poochiereds.net>
	<20140715085727.6fa12272@notabene.brown>
	<20140714194738.5aafaf25@tlielax.poochiereds.net>
	<20140717115024.1eb7433d@notabene.brown>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 boundary="Sig_/grrsYp9I2F0C2oKrgza.0z_"; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--Sig_/grrsYp9I2F0C2oKrgza.0z_
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

On Thu, 17 Jul 2014 11:50:24 +1000
NeilBrown <neilb@suse.de> wrote:

> On Mon, 14 Jul 2014 19:47:38 -0400 Jeff Layton <jeff.layton@primarydata.c=
om>
> wrote:
>=20
> > On Tue, 15 Jul 2014 08:57:27 +1000
> > NeilBrown <neilb@suse.de> wrote:
> >=20
> > > On Mon, 14 Jul 2014 09:00:28 -0400 Jeff Layton <jeff.layton@primaryda=
ta.com>
> > > wrote:
> > >=20
> > > > On Mon, 14 Jul 2014 22:35:13 +1000
> > > > NeilBrown <neilb@suse.de> wrote:
> > > >=20
> > > > > On Mon, 14 Jul 2014 08:14:55 -0400 Jeff Layton <jeff.layton@prima=
rydata.com>
> > > > > wrote:
> > > > >=20
> > > > > > On Mon, 14 Jul 2014 15:14:05 +1000
> > > > > > NeilBrown <neilb@suse.de> wrote:
> > > > > >=20
> > > > > > >=20
> > > > > > > If an 'open' of a file in an NFSv4 filesystem finds that the =
dentry is
> > > > > > > in cache, but the inode is stale (on the server), the dentry =
will not
> > > > > > > be re-validated immediately and may cause ESTALE to be return=
ed to
> > > > > > > user-space.
> > > > > > >=20
> > > > > > > For a non-create 'open', do_last() calls lookup_fast() and on=
 success
> > > > > > > will eventually call may_open() which calls into nfs_permissi=
on().
> > > > > > > If nfs_permission() makes the ACCESS call to the server it wi=
ll get
> > > > > > > NFS4ERR_STALE, resulting in ESTALE from may_open() and thence=
 from
> > > > > > > do_last().
> > > > > > > The retry-on-ESTALE in filename_lookup() will repeat exactly =
the same
> > > > > > > process because nothing in this path will invalidate the dent=
ry due to
> > > > > > > the inode being stale, so the ESTALE will be returned.
> > > > > > >=20
> > > > > > > lookup_fast() calls ->d_revalidate(), but for an OPEN on an N=
FSv4
> > > > > > > filesystem, that will succeed for regular files:
> > > > > > > 	/* Let f_op->open() actually open (and revalidate) the file =
*/
> > > > > > >=20
> > > > > > > Unfortunately in the case of a STALE inode, f_op->open() neve=
r gets
> > > > > > > called.  If we teach nfs4_lookup_revalidate() to report a fai=
lure on
> > > > > > > NFS_STALE() inodes, then the dentry will be invalidated and a=
 full
> > > > > > > lookup will be attempted.  The ESTALE errors go away.
> > > > > > >=20
> > > > > > >=20
> > > > > > > While I think this fix is correct, I'm not convinced that it =
is
> > > > > > > sufficient, particularly if lookupcache=3Dnone.
> > > > > > > The current code will fail an "open" is nfs_permission() fail=
s,
> > > > > > > without having performed a LOOKUP. i.e. it will use the cache.
> > > > > > > nfs_lookup_revalidate will force a lookup before the permissi=
on check
> > > > > > > if NFS_MOUNT_LOOKUP_CACHE_NONE, but nfs4_lookup_revalidate wi=
ll not.
> > > > > > >=20
> > > > > >=20
> > > > > > This patch should make the code fall through to nfs_lookup_reva=
lidate,
> > > > > > which would then force the lookup, right?
> > > > >=20
> > > > > Yes ... though maybe that's not what I really want to do.  I real=
ly wanted to
> > > > > just return '0', though I would need to check that is right in al=
l cases.
> > > > >=20
> > > > > >=20
> > > > > > Also, I'm a little unclear...
> > > > > >=20
> > > > > > Why would may_open fail with ESTALE after the v4 OPEN succeeds?=
 The
> > > > > > OPEN should be returning a filehandle and attributes for the in=
ode
> > > > > > actually opened. It seems like we ought to be doing any permiss=
ion
> > > > > > checks vs. that inode, not anything we had in cache. Presumably=
 the
> > > > > > server is then holding it open so it shouldn't be stale.
> > > > >=20
> > > > > may_open is called *before* and v4 OPEN.
> > > > >=20
> > > > > In do_last, if the inode is already in cache, then
> > > > >   lookup_fast is called, which calls d_revalidate
> > > > >   then may_open (calls ->permission)
> > > > >   then finish_open which calls f_op->open
> > > > >=20
> > > > > Yes, we should be doing permission checking against whatever 'ope=
n' finds.
> > > > > But the VFS is structured to the the permission check after d_rev=
alidate and
> > > > > before ->open.  So maybe d_revalidate needs to do the NFS open??
> > > > >=20
> > > >=20
> > > > Ok, I see. Ugh, having the revalidate do the open sounds...messy.
> > >=20
> > > Having the VFS call into the file system in dribs and drabs, rather t=
han just
> > > asking the filesystem to "open" and  letting it call back to VFS libr=
aries
> > > for name lookup etc it what is really messy (IMO).
> > >=20
> > > So yes - definite mess.  Not entirely sure where the mess is.
> > >=20
> >=20
> > Yeah, that might have been cleaner overall. I'm not sure how we can get
> > there from where the code is today though...
> >=20
> > > >=20
> > > > A simpler fix might be to fix it so that an -ESTALE return from
> > > > may_open triggers a retry. Something like this maybe (probably
> > > > whitespace damaged, so just for discussion purposes):
> > >=20
> > > Nice idea but doesn't work.
> > > We get back to retry_lookup and call lookup_open().
> > > lookup_dcache calls d_revalidate which reports that everything is fin=
e, so it
> > > tells lookup_open which jumps to out_no_open and does nothing useful.
> > > So we end up in may_open() again which returns ESTALE again but now w=
e've
> > > used up all our extra lives...
> > >=20
> >=20
> > Ahh right, so you'd probably need to pair that with the patch you
> > already have. Regardless, it seems like getting back an ESTALE from
> > may_open should trigger a retry rather than just erroring out.
> >=20
> > >=20
> > > One thing I noticed while exploring this is that do_last calls "may_o=
pen"
> > > *before* finish_open() while atomic_open() calls "may_open" *after*
> > > finish_open() (which it calls by virtual of the fact that all ->atomi=
c_open
> > > methods call finish_open()).
> > >=20
> > > I was very tempted to just move the 'may_open' call in 'do_last' to a=
fter the
> > > 'finish_open' call.  That fixed the problem, but I'm not sure it is "=
right".
> > >=20
> > > I think the real core messiness here is that permission checking shou=
ld be
> > > neither before nor after finish_open, but should be an integral part =
of
> > > finish_open with the filesystem doing the permission check in f_op->o=
pen().
> > >=20
> > > I'm currently thinking this is the best patch for now:
> > >=20
> > > diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
> > > index 4f7414afca27..5c40cfd3ae29 100644
> > > --- a/fs/nfs/dir.c
> > > +++ b/fs/nfs/dir.c
> > > @@ -1563,9 +1563,10 @@ static int nfs4_lookup_revalidate(struct dentr=
y *dentry, unsigned int flags)
> > >  	/* We cannot do exclusive creation on a positive dentry */
> > >  	if (flags & LOOKUP_EXCL)
> > >  		goto no_open_dput;
> > > =20
> > > -	/* Let f_op->open() actually open (and revalidate) the file */
> > > -	ret =3D 1;
> > > +	if (!NFS_STALE(inode))
> > > +		/* Let f_op->open() actually open (and revalidate) the file */
> > > +		ret =3D 1;
> > > =20
> > >  out:
> > >  	dput(parent);
> > >=20
> > >=20
> > > Thanks,
> > > NeilBrown
> > >=20
> >=20
> > That looks fine too, but I think you probably will also want to pair it
> > with making may_open retry the open on an ESTALE return.
> >=20
> > The problem with the above check alone is that it's only going to fire
> > if you previously found the inode to be stale. It may be stale on the
> > server, but the client doesn't realize it yet, or could go stale after
> > this check and before the ACCESS call. In that case, you'll still end
> > up getting back an ESTALE once you hit may_open (unless I'm missing
> > something) and that won't trigger a reattempt either.
>=20
> I must admit to being a bit confused by your position here.
>=20
> You are the one who introduced the high-level retry-on-ESTALE functionali=
ty
> into namei.c.  So you presumably know that an ESTALE will already be
> retried.  Yet you are suggesting to that we add another retry here??
>=20
> The way I understanding it, ESTALE should only be retried if it was a cac=
hed
> inode that was found to be STALE.  When that happens, the dentry needs to=
 be
> invalidated and then the whole path retried again from the top with
> LOOKUP_REVAL.  This time we won't trust anything that is cached so any ES=
TALE
> we find is a real ESTALE that must be returned to the caller.
>=20
> From this perspective, the problem is either something is seeing a STALE
> inode in the first pass and not invalidating the dentry, or that somethin=
g is
> not revalidating the dentry on the second pass despite LOOKUP_REVAL being=
 set.
> I'm assuming that nfs4_look_revalidate should be invalidating the dentry =
on
> the first pass (by returning 0).  Other fixes might be possible, but furt=
her
> retries should be pointless - we already have the required retry in place
> thanks to you!
>=20
> Thanks,
> NeilBrown

(cc'ing Miklos)

<facepalm>
You're totally correct. I had forgotten that we do retries on ESTALE at
a higher level. I got confused by the EOPENSTALE handling there after
finish_open.
</facepalm>

So, on your patch:

Acked-by: Jeff Layton <jlayton@primarydata.com>

That said, it does sort of bring up an unrelated question:

What's so special about an EOPENSTALE return from finish_open that we
need to handle retries in do_last? It seems like we could get rid of the
stale_open label and just let do_filp_open handle it like we would
an ESTALE return from any other spot in the function.

Just for giggles, here's an RFC patch. It builds but I haven't tested
it. It might also be possible to do some cleanup around saved_parent
with this.

Thoughts?

-------------------------[snip]-------------------

[PATCH] vfs: don't handle EOPENSTALE retries in do_last

We already handle ESTALE retries at higher levels. Retrying the lookup
and open in do_last is somewhat redundant. Remove the logic that
for that from do_last and just let the upper layers handle it.

Cc: Miklos Szeredi <miklos@szeredi.hu>
Signed-off-by: Jeff Layton <jlayton@primarydata.com>
---
 fs/namei.c | 26 +-------------------------
 1 file changed, 1 insertion(+), 25 deletions(-)

diff --git a/fs/namei.c b/fs/namei.c
index 985c6f368485..34c6d008d0e5 100644
--- a/fs/namei.c
+++ b/fs/namei.c
@@ -2882,7 +2882,6 @@ static int do_last(struct nameidata *nd, struct path =
*path,
 	struct inode *inode;
 	bool symlink_ok =3D false;
 	struct path save_parent =3D { .dentry =3D NULL, .mnt =3D NULL };
-	bool retried =3D false;
 	int error;
=20
 	nd->flags &=3D ~LOOKUP_PARENT;
@@ -2927,7 +2926,6 @@ static int do_last(struct nameidata *nd, struct path =
*path,
 			goto out;
 	}
=20
-retry_lookup:
 	if (op->open_flag & (O_CREAT | O_TRUNC | O_WRONLY | O_RDWR)) {
 		error =3D mnt_want_write(nd->path.mnt);
 		if (!error)
@@ -3017,7 +3015,6 @@ finish_lookup:
 		save_parent.dentry =3D nd->path.dentry;
 		save_parent.mnt =3D mntget(path->mnt);
 		nd->path.dentry =3D path->dentry;
-
 	}
 	nd->inode =3D inode;
 	/* Why this, you ask?  _Now_ we might have grown LOOKUP_JUMPED... */
@@ -3049,11 +3046,8 @@ finish_open_created:
 		goto out;
 	file->f_path.mnt =3D nd->path.mnt;
 	error =3D finish_open(file, nd->path.dentry, NULL, opened);
-	if (error) {
-		if (error =3D=3D -EOPENSTALE)
-			goto stale_open;
+	if (error)
 		goto out;
-	}
 opened:
 	error =3D open_check_o_direct(file);
 	if (error)
@@ -3080,24 +3074,6 @@ exit_dput:
 exit_fput:
 	fput(file);
 	goto out;
-
-stale_open:
-	/* If no saved parent or already retried then can't retry */
-	if (!save_parent.dentry || retried)
-		goto out;
-
-	BUG_ON(save_parent.dentry !=3D dir);
-	path_put(&nd->path);
-	nd->path =3D save_parent;
-	nd->inode =3D dir->d_inode;
-	save_parent.mnt =3D NULL;
-	save_parent.dentry =3D NULL;
-	if (got_write) {
-		mnt_drop_write(nd->path.mnt);
-		got_write =3D false;
-	}
-	retried =3D true;
-	goto retry_lookup;
 }
=20
 static int do_tmpfile(int dfd, struct filename *pathname,
--=20
1.9.3




--Sig_/grrsYp9I2F0C2oKrgza.0z_
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBAgAGBQJTx7IIAAoJEAAOaEEZVoIV5YkP/1TSacerXHuWiDer6fcPSOsK
LTFeTj1czuGwqdVxZfhSQ49QXVY84YfVT4tMYYGL/w7nTV27tQmE91lyybxF6C46
cGnitGlQ/rJpbWYQobu13JTmMur58gpcxg/9UTzh3rfz+oGo2ECP9ns4i9ZYVcvu
LwaPApVCTlSeXnBD23S5910BJX2B9ffvTDpKxcCq1ObyLrDI1FvqtcIZ1MjHIXlK
by/VEhVwD3NLpxoq4D+4SCVDfdvyhAzRsEk8Ssxy0TrkJWd3sZ4Yd+hkjkZPRB4J
Wg33Mkt7iGd0MIHq6eWnBLoQLjcg8NEtLoF+gOB46J0NJW5NwvvLNXy+cAI/AIbJ
rMgCS2slCMOq0x+iFG9NcMaPbOAEGenL6fhgiiJGLlkRUCXg6vg+xMn4iwG8PlFq
701YHsesnooWMcLju14wOaPG3eo8+XUKBJ419lmgHKyoz/O0ljJdObO6fm0kyWfq
BwVE8q0NukM9UtTkl46luS5owq/akD5U9mnNq2MYHct6kiKXUUvCuWkT3KmZShYi
3i/dEAMK2Pl1WVLnIa8D45024kr6OwEZWh2kSD6NbQk16DL52whpPEEgM43sVaOl
m4KIvKq2dRUeD94DqMgHcTPWics5IFy0fMn6akZLVjsNjSTwTuql76DGpMRjmCFa
zughj9UBTUymxjMl99Ve
=9HQi
-----END PGP SIGNATURE-----

--Sig_/grrsYp9I2F0C2oKrgza.0z_--
