Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cantor2.suse.de ([195.135.220.15]:40524 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752992AbaGQBuf (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 16 Jul 2014 21:50:35 -0400
Date: Thu, 17 Jul 2014 11:50:24 +1000
From: NeilBrown <neilb@suse.de>
To: Jeff Layton <jeff.layton@primarydata.com>
Cc: Trond Myklebust <trond.myklebust@primarydata.com>,
        Alexander Viro <viro@zeniv.linux.org.uk>,
        NFS <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] NFS: nfs4_lookup_revalidate need to report STALE
 inodes.
Message-ID: <20140717115024.1eb7433d@notabene.brown>
In-Reply-To: <20140714194738.5aafaf25@tlielax.poochiereds.net>
References: <20140714151405.2fa06dd7@notabene.brown>
	<20140714081455.69f55224@tlielax.poochiereds.net>
	<20140714223513.47807c98@notabene.brown>
	<20140714090028.6f04fd2c@tlielax.poochiereds.net>
	<20140715085727.6fa12272@notabene.brown>
	<20140714194738.5aafaf25@tlielax.poochiereds.net>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 boundary="Sig_/ExOI2en4TzbXIMEBfGqC0m9"; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--Sig_/ExOI2en4TzbXIMEBfGqC0m9
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

On Mon, 14 Jul 2014 19:47:38 -0400 Jeff Layton <jeff.layton@primarydata.com>
wrote:

> On Tue, 15 Jul 2014 08:57:27 +1000
> NeilBrown <neilb@suse.de> wrote:
>=20
> > On Mon, 14 Jul 2014 09:00:28 -0400 Jeff Layton <jeff.layton@primarydata=
.com>
> > wrote:
> >=20
> > > On Mon, 14 Jul 2014 22:35:13 +1000
> > > NeilBrown <neilb@suse.de> wrote:
> > >=20
> > > > On Mon, 14 Jul 2014 08:14:55 -0400 Jeff Layton <jeff.layton@primary=
data.com>
> > > > wrote:
> > > >=20
> > > > > On Mon, 14 Jul 2014 15:14:05 +1000
> > > > > NeilBrown <neilb@suse.de> wrote:
> > > > >=20
> > > > > >=20
> > > > > > If an 'open' of a file in an NFSv4 filesystem finds that the de=
ntry is
> > > > > > in cache, but the inode is stale (on the server), the dentry wi=
ll not
> > > > > > be re-validated immediately and may cause ESTALE to be returned=
 to
> > > > > > user-space.
> > > > > >=20
> > > > > > For a non-create 'open', do_last() calls lookup_fast() and on s=
uccess
> > > > > > will eventually call may_open() which calls into nfs_permission=
().
> > > > > > If nfs_permission() makes the ACCESS call to the server it will=
 get
> > > > > > NFS4ERR_STALE, resulting in ESTALE from may_open() and thence f=
rom
> > > > > > do_last().
> > > > > > The retry-on-ESTALE in filename_lookup() will repeat exactly th=
e same
> > > > > > process because nothing in this path will invalidate the dentry=
 due to
> > > > > > the inode being stale, so the ESTALE will be returned.
> > > > > >=20
> > > > > > lookup_fast() calls ->d_revalidate(), but for an OPEN on an NFS=
v4
> > > > > > filesystem, that will succeed for regular files:
> > > > > > 	/* Let f_op->open() actually open (and revalidate) the file */
> > > > > >=20
> > > > > > Unfortunately in the case of a STALE inode, f_op->open() never =
gets
> > > > > > called.  If we teach nfs4_lookup_revalidate() to report a failu=
re on
> > > > > > NFS_STALE() inodes, then the dentry will be invalidated and a f=
ull
> > > > > > lookup will be attempted.  The ESTALE errors go away.
> > > > > >=20
> > > > > >=20
> > > > > > While I think this fix is correct, I'm not convinced that it is
> > > > > > sufficient, particularly if lookupcache=3Dnone.
> > > > > > The current code will fail an "open" is nfs_permission() fails,
> > > > > > without having performed a LOOKUP. i.e. it will use the cache.
> > > > > > nfs_lookup_revalidate will force a lookup before the permission=
 check
> > > > > > if NFS_MOUNT_LOOKUP_CACHE_NONE, but nfs4_lookup_revalidate will=
 not.
> > > > > >=20
> > > > >=20
> > > > > This patch should make the code fall through to nfs_lookup_revali=
date,
> > > > > which would then force the lookup, right?
> > > >=20
> > > > Yes ... though maybe that's not what I really want to do.  I really=
 wanted to
> > > > just return '0', though I would need to check that is right in all =
cases.
> > > >=20
> > > > >=20
> > > > > Also, I'm a little unclear...
> > > > >=20
> > > > > Why would may_open fail with ESTALE after the v4 OPEN succeeds? T=
he
> > > > > OPEN should be returning a filehandle and attributes for the inode
> > > > > actually opened. It seems like we ought to be doing any permission
> > > > > checks vs. that inode, not anything we had in cache. Presumably t=
he
> > > > > server is then holding it open so it shouldn't be stale.
> > > >=20
> > > > may_open is called *before* and v4 OPEN.
> > > >=20
> > > > In do_last, if the inode is already in cache, then
> > > >   lookup_fast is called, which calls d_revalidate
> > > >   then may_open (calls ->permission)
> > > >   then finish_open which calls f_op->open
> > > >=20
> > > > Yes, we should be doing permission checking against whatever 'open'=
 finds.
> > > > But the VFS is structured to the the permission check after d_reval=
idate and
> > > > before ->open.  So maybe d_revalidate needs to do the NFS open??
> > > >=20
> > >=20
> > > Ok, I see. Ugh, having the revalidate do the open sounds...messy.
> >=20
> > Having the VFS call into the file system in dribs and drabs, rather tha=
n just
> > asking the filesystem to "open" and  letting it call back to VFS librar=
ies
> > for name lookup etc it what is really messy (IMO).
> >=20
> > So yes - definite mess.  Not entirely sure where the mess is.
> >=20
>=20
> Yeah, that might have been cleaner overall. I'm not sure how we can get
> there from where the code is today though...
>=20
> > >=20
> > > A simpler fix might be to fix it so that an -ESTALE return from
> > > may_open triggers a retry. Something like this maybe (probably
> > > whitespace damaged, so just for discussion purposes):
> >=20
> > Nice idea but doesn't work.
> > We get back to retry_lookup and call lookup_open().
> > lookup_dcache calls d_revalidate which reports that everything is fine,=
 so it
> > tells lookup_open which jumps to out_no_open and does nothing useful.
> > So we end up in may_open() again which returns ESTALE again but now we'=
ve
> > used up all our extra lives...
> >=20
>=20
> Ahh right, so you'd probably need to pair that with the patch you
> already have. Regardless, it seems like getting back an ESTALE from
> may_open should trigger a retry rather than just erroring out.
>=20
> >=20
> > One thing I noticed while exploring this is that do_last calls "may_ope=
n"
> > *before* finish_open() while atomic_open() calls "may_open" *after*
> > finish_open() (which it calls by virtual of the fact that all ->atomic_=
open
> > methods call finish_open()).
> >=20
> > I was very tempted to just move the 'may_open' call in 'do_last' to aft=
er the
> > 'finish_open' call.  That fixed the problem, but I'm not sure it is "ri=
ght".
> >=20
> > I think the real core messiness here is that permission checking should=
 be
> > neither before nor after finish_open, but should be an integral part of
> > finish_open with the filesystem doing the permission check in f_op->ope=
n().
> >=20
> > I'm currently thinking this is the best patch for now:
> >=20
> > diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
> > index 4f7414afca27..5c40cfd3ae29 100644
> > --- a/fs/nfs/dir.c
> > +++ b/fs/nfs/dir.c
> > @@ -1563,9 +1563,10 @@ static int nfs4_lookup_revalidate(struct dentry =
*dentry, unsigned int flags)
> >  	/* We cannot do exclusive creation on a positive dentry */
> >  	if (flags & LOOKUP_EXCL)
> >  		goto no_open_dput;
> > =20
> > -	/* Let f_op->open() actually open (and revalidate) the file */
> > -	ret =3D 1;
> > +	if (!NFS_STALE(inode))
> > +		/* Let f_op->open() actually open (and revalidate) the file */
> > +		ret =3D 1;
> > =20
> >  out:
> >  	dput(parent);
> >=20
> >=20
> > Thanks,
> > NeilBrown
> >=20
>=20
> That looks fine too, but I think you probably will also want to pair it
> with making may_open retry the open on an ESTALE return.
>=20
> The problem with the above check alone is that it's only going to fire
> if you previously found the inode to be stale. It may be stale on the
> server, but the client doesn't realize it yet, or could go stale after
> this check and before the ACCESS call. In that case, you'll still end
> up getting back an ESTALE once you hit may_open (unless I'm missing
> something) and that won't trigger a reattempt either.

I must admit to being a bit confused by your position here.

You are the one who introduced the high-level retry-on-ESTALE functionality
into namei.c.  So you presumably know that an ESTALE will already be
retried.  Yet you are suggesting to that we add another retry here??

The way I understanding it, ESTALE should only be retried if it was a cached
inode that was found to be STALE.  When that happens, the dentry needs to be
invalidated and then the whole path retried again from the top with
LOOKUP_REVAL.  This time we won't trust anything that is cached so any ESTA=
LE
we find is a real ESTALE that must be returned to the caller.

=46rom this perspective, the problem is either something is seeing a STALE
inode in the first pass and not invalidating the dentry, or that something =
is
not revalidating the dentry on the second pass despite LOOKUP_REVAL being s=
et.
I'm assuming that nfs4_look_revalidate should be invalidating the dentry on
the first pass (by returning 0).  Other fixes might be possible, but further
retries should be pointless - we already have the required retry in place
thanks to you!

Thanks,
NeilBrown

--Sig_/ExOI2en4TzbXIMEBfGqC0m9
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.22 (GNU/Linux)

iQIVAwUBU8cr4Dnsnt1WYoG5AQJ/HhAApkRijY/ySgEdhucNQCQbSGy+5vBxDpyR
zNy2ntgDPU59ikHnaFfOvrXFIaopzuL4CLA4B8aENttoEE9ujguzSfDr7dcQJXvU
4TmBYbkG/Q0IMnu8tZA9hBE0ypgBZKIb3cX40ZX/Gi5JQ2lZiRQCIbgEPIdW4PGo
mGKBp2ugJIe2nJO/7uFQbJ19HR2yye5U/BIWP50RA+J+ZBkuOVb8zfhs3d62XF3d
cni4TDUnulBjxP7EVrkx5nGh300tKx0YfvLsdnH+oKgztjEoC6alZZLPGCG5MaDA
Q9D8wzMeVN0/MoVaEwcMM5/rr4JcqRTCJM7jVGZPrr4Gw7mVWMGh3lmaH9tZHdTW
pqH94eDwFr6kclXgJVlqsUMrwWTPNEjmwcC1oLH1NCp4UQ3lGYD2BmADPaUUrn/+
thKwloRDQ2i8lAaOhSCeIsDYoHzXKgpHweyiKAUEnZ1N7VW/BsKOv5OQfkcX3H04
GXr0A2tq4amWfQm9i4gy98Cn7meyB1u8WqnNayzX3z8GAffqguqZKKgwkwEInocS
cku6afIc/LVB3pD5xQgaT9FxjynekHruvT7Zr1stweeTnvmhGA37iA2vIgaj1wa4
1SHSFnzlGriwDZzwTIMli8jQ3v6/Xgs5d5BAEtVfnvFFJw32bZjwv9jzUwqlyHwx
IDM8OryliJQ=
=6Y/I
-----END PGP SIGNATURE-----

--Sig_/ExOI2en4TzbXIMEBfGqC0m9--
