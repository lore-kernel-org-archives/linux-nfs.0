Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:57119 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752148AbbEEW0h (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 5 May 2015 18:26:37 -0400
Date: Wed, 6 May 2015 08:26:28 +1000
From: NeilBrown <neilb@suse.de>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Kinglong Mee <kinglongmee@gmail.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH RFC] NFSD: fix cannot umounting mount points under
 pseudo root
Message-ID: <20150506082628.0dd049c7@notabene.brown>
In-Reply-To: <20150505155203.GD27106@fieldses.org>
References: <20150424130045.6bbdb2f9@notabene.brown>
	<553E2784.6020906@gmail.com>
	<20150429125728.69ddfc6c@notabene.brown>
	<20150429191934.GA23980@fieldses.org>
	<20150430075225.21a71056@notabene.brown>
	<20150430213602.GB9509@fieldses.org>
	<20150501115326.51f5613a@notabene.brown>
	<20150504220130.GB16827@fieldses.org>
	<5548CBA3.9080608@gmail.com>
	<20150505141801.GB27106@fieldses.org>
	<20150505155203.GD27106@fieldses.org>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 boundary="Sig_/rk7h_1DfSy6=F_FS6p.r/=o"; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--Sig_/rk7h_1DfSy6=F_FS6p.r/=o
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

On Tue, 5 May 2015 11:52:03 -0400 "J. Bruce Fields" <bfields@fieldses.org>
wrote:

> On Tue, May 05, 2015 at 10:18:01AM -0400, J. Bruce Fields wrote:
> > On Tue, May 05, 2015 at 09:54:43PM +0800, Kinglong Mee wrote:
> > > On 5/5/2015 6:01 AM, J. Bruce Fields wrote:
> > > > + * Unlike lookup_one_len, it should be called without the parent
> > > > + * i_mutex held, and will take the i_mutex itself if necessary.
> > > > + */
> > > > +struct dentry *lookup_one_len_unlocked(const char *name,
> > > > +				       struct dentry *base, int len)
> > > > +{
> > > > +	struct qstr this;
> > > > +	unsigned int c;
> > > > +	int err;
> > > > +	struct dentry *ret;
> > > > +
> > > > +	WARN_ON_ONCE(!mutex_is_locked(&base->d_inode->i_mutex));
> > >=20
> > > Remove this line.
> >=20
> > Whoops, thanks.
> >=20
> > > > diff --git a/fs/nfsd/vfs.c b/fs/nfsd/vfs.c
> > > > index a30e79900086..cc7995762190 100644
> > > > --- a/fs/nfsd/vfs.c
> > > > +++ b/fs/nfsd/vfs.c
> > > > @@ -217,6 +217,13 @@ nfsd_lookup_dentry(struct svc_rqst *rqstp, str=
uct svc_fh *fhp,
> > > >  		host_err =3D PTR_ERR(dentry);
> > > >  		if (IS_ERR(dentry))
> > > >  			goto out_nfserr;
> > > > +		if (!S_ISREG(d_inode(dentry)->i_mode)) {
> > >=20
> > > Got a crash here tested by pynfs,
> >=20
> > OK, I guess I just forgot to take into account negative dentries.
> > Testing that now with (!(d_inode(dentry) && S_ISREG(..))).
>=20
> And I also forgot nfs3xdr.c.
>=20
> --b.
>=20
> commit 6c942d342f9f
> Author: NeilBrown <neilb@suse.de>
> Date:   Fri May 1 11:53:26 2015 +1000
>=20
>     nfsd: don't hold i_mutex over userspace upcalls
>    =20
>     We need information about exports when crossing mountpoints during
>     lookup or NFSv4 readdir.  If we don't already have that information
>     cached, we may have to ask (and wait for) rpc.mountd.
>    =20
>     In both cases we currently hold the i_mutex on the parent of the
>     directory we're asking rpc.mountd about.  We've seen situations where
>     rpc.mountd performs some operation on that directory that tries to ta=
ke
>     the i_mutex again, resulting in deadlock.
>    =20
>     With some care, we may be able to avoid that in rpc.mountd.  But it
>     seems better just to avoid holding a mutex while waiting on userspace.
>    =20
>     It appears that lookup_one_len is pretty much the only operation that
>     needs the i_mutex.  So we could just drop the i_mutex elsewhere and do
>     something like
>    =20
>     	mutex_lock()
>     	lookup_one_len()
>     	mutex_unlock()
>    =20
>     In many cases though the lookup would have been cached and not requir=
ed
>     the i_mutex, so it's more efficient to create a lookup_one_len() vari=
ant
>     that only takes the i_mutex when necessary.
>    =20
>     Signed-off-by: J. Bruce Fields <bfields@redhat.com>
>=20
> diff --git a/fs/namei.c b/fs/namei.c
> index 4a8d998b7274..0f554bf41dea 100644
> --- a/fs/namei.c
> +++ b/fs/namei.c
> @@ -2139,6 +2139,8 @@ static struct dentry *lookup_hash(struct nameidata =
*nd)
>   *
>   * Note that this routine is purely a helper for filesystem usage and sh=
ould
>   * not be called by generic code.
> + *
> + * Must be called with the parented i_mutex held.

"parented"?

    * base->i_mutex must be held by caller.

??


>   */
>  struct dentry *lookup_one_len(const char *name, struct dentry *base, int=
 len)
>  {
> @@ -2182,6 +2184,66 @@ struct dentry *lookup_one_len(const char *name, st=
ruct dentry *base, int len)
>  }
>  EXPORT_SYMBOL(lookup_one_len);
> =20
> +/**
> + * lookup_one_len - filesystem helper to lookup single pathname component
      lookup_one_len_unlocked - ..



> + * @name:	pathname component to lookup
> + * @base:	base directory to lookup from
> + * @len:	maximum length @len should be interpreted to
> + *
> + * Note that this routine is purely a helper for filesystem usage and sh=
ould
> + * not be called by generic code.
> + *
> + * Unlike lookup_one_len, it should be called without the parent
> + * i_mutex held, and will take the i_mutex itself if necessary.
> + */
> +struct dentry *lookup_one_len_unlocked(const char *name,
> +				       struct dentry *base, int len)
> +{
> +	struct qstr this;
> +	unsigned int c;
> +	int err;
> +	struct dentry *ret;
> +
> +	this.name =3D name;
> +	this.len =3D len;
> +	this.hash =3D full_name_hash(name, len);
> +	if (!len)
> +		return ERR_PTR(-EACCES);
> +
> +	if (unlikely(name[0] =3D=3D '.')) {
> +		if (len < 2 || (len =3D=3D 2 && name[1] =3D=3D '.'))
> +			return ERR_PTR(-EACCES);
> +	}
> +
> +	while (len--) {
> +		c =3D *(const unsigned char *)name++;
> +		if (c =3D=3D '/' || c =3D=3D '\0')
> +			return ERR_PTR(-EACCES);
> +	}
> +	/*
> +	 * See if the low-level filesystem might want
> +	 * to use its own hash..
> +	 */
> +	if (base->d_flags & DCACHE_OP_HASH) {
> +		int err =3D base->d_op->d_hash(base, &this);
> +		if (err < 0)
> +			return ERR_PTR(err);
> +	}
> +
> +	err =3D inode_permission(base->d_inode, MAY_EXEC);
> +	if (err)
> +		return ERR_PTR(err);
> +
> +	ret =3D __d_lookup(base, &this);
> +	if (ret)
> +		return ret;

__d_lookup() is a little too low level, as it doesn't call d_revalidate() a=
nd
it doesn't retry if the rename_lock seqlock says it should.

The latter doesn't really matter as we would fall through to the safe
mutex-protected version.
The former isn't much of an issue for most filesystems under nfsd, but still
needs to be handled to some extent.
Also, the comment for __d_lookup says

 * __d_lookup callers must be commented.

The simplest resolution would be:

	/* __d_lookup() is used to try to get a quick answer and avoid the
	 * mutex.  A false-negative does no harm.
	 */
	ret =3D __d_lookup(base, &this);
	if (ret && ret->d_flags & DCACHE_OP_REVALIDATE) {
		dput(ret);
		ret =3D NULL;
	}
	if (ret)
		return ret;


It probably wouldn't be too much harder to add the d_revalidate() call, and
call d_invalidate() if it returns zero. =20

Maybe.


	if (ret && ret->d_flags & DCACHE_OP_REVALIDATE) {
		int err =3D d_revalidate(ret, 0);
		if (err =3D=3D 0) {
			d_invalidate(ret);
			dput(ret);
			ret =3D NULL;
		} else if (err < 0) {
			dput(ret);
			return ERR_PTR(err);
		}
	}


> +	mutex_lock(&base->d_inode->i_mutex);
> +	ret =3D  __lookup_hash(&this, base, 0);
> +	mutex_unlock(&base->d_inode->i_mutex);
> +	return ret;
> +}
> +EXPORT_SYMBOL(lookup_one_len_unlocked);
> +
>  int user_path_at_empty(int dfd, const char __user *name, unsigned flags,
>  		 struct path *path, int *empty)
>  {
> diff --git a/fs/nfsd/nfs3xdr.c b/fs/nfsd/nfs3xdr.c
> index f6e7cbabac5a..01dcd494f781 100644
> --- a/fs/nfsd/nfs3xdr.c
> +++ b/fs/nfsd/nfs3xdr.c
> @@ -823,7 +823,7 @@ compose_entry_fh(struct nfsd3_readdirres *cd, struct =
svc_fh *fhp,
>  		} else
>  			dchild =3D dget(dparent);
>  	} else
> -		dchild =3D lookup_one_len(name, dparent, namlen);
> +		dchild =3D lookup_one_len_unlocked(name, dparent, namlen);
>  	if (IS_ERR(dchild))
>  		return rv;
>  	if (d_mountpoint(dchild))
> diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
> index 158badf945df..2c1adaa0bd2f 100644
> --- a/fs/nfsd/nfs4xdr.c
> +++ b/fs/nfsd/nfs4xdr.c
> @@ -2804,14 +2804,14 @@ nfsd4_encode_dirent_fattr(struct xdr_stream *xdr,=
 struct nfsd4_readdir *cd,
>  	__be32 nfserr;
>  	int ignore_crossmnt =3D 0;
> =20
> -	dentry =3D lookup_one_len(name, cd->rd_fhp->fh_dentry, namlen);
> +	dentry =3D lookup_one_len_unlocked(name, cd->rd_fhp->fh_dentry, namlen);
>  	if (IS_ERR(dentry))
>  		return nfserrno(PTR_ERR(dentry));
>  	if (d_really_is_negative(dentry)) {
>  		/*
> -		 * nfsd_buffered_readdir drops the i_mutex between
> -		 * readdir and calling this callback, leaving a window
> -		 * where this directory entry could have gone away.
> +		 * we're not holding the i_mutex here, so there's
> +		 * a window where this directory entry could have gone
> +		 * away.
>  		 */
>  		dput(dentry);
>  		return nfserr_noent;
> diff --git a/fs/nfsd/vfs.c b/fs/nfsd/vfs.c
> index a30e79900086..4accdb00976b 100644
> --- a/fs/nfsd/vfs.c
> +++ b/fs/nfsd/vfs.c
> @@ -217,6 +217,13 @@ nfsd_lookup_dentry(struct svc_rqst *rqstp, struct sv=
c_fh *fhp,
>  		host_err =3D PTR_ERR(dentry);
>  		if (IS_ERR(dentry))
>  			goto out_nfserr;
> +		if (!(d_inode(dentry) && S_ISREG(d_inode(dentry)->i_mode))) {
> +			/*
> +			 * Never mind, we're not going to open this
> +			 * anyway.  And we don't want to hold it over
> +			 * the userspace upcalls in nfsd_mountpoint. */
> +			fh_unlock(fhp);
> +		}

You could avoid the test by just putting the fh_unlock(fhp) inside the=20

		if (nfsd_mountpoint(dentry, exp)) {

block.  It might also be appropriate for nfsd_mountpoint to fail on
non-directories.

Up to you though.

Thanks.  Feel free to add
  *-by: NeilBrown <neilb@suse.de>

as you see fit.

NeilBrown


>  		/*
>  		 * check if we have crossed a mount point ...
>  		 */
> @@ -1876,7 +1883,6 @@ static __be32 nfsd_buffered_readdir(struct file *fi=
le, nfsd_filldir_t func,
>  	offset =3D *offsetp;
> =20
>  	while (1) {
> -		struct inode *dir_inode =3D file_inode(file);
>  		unsigned int reclen;
> =20
>  		cdp->err =3D nfserr_eof; /* will be cleared on successful read */
> @@ -1895,15 +1901,6 @@ static __be32 nfsd_buffered_readdir(struct file *f=
ile, nfsd_filldir_t func,
>  		if (!size)
>  			break;
> =20
> -		/*
> -		 * Various filldir functions may end up calling back into
> -		 * lookup_one_len() and the file system's ->lookup() method.
> -		 * These expect i_mutex to be held, as it would within readdir.
> -		 */
> -		host_err =3D mutex_lock_killable(&dir_inode->i_mutex);
> -		if (host_err)
> -			break;
> -
>  		de =3D (struct buffered_dirent *)buf.dirent;
>  		while (size > 0) {
>  			offset =3D de->offset;
> @@ -1920,7 +1917,6 @@ static __be32 nfsd_buffered_readdir(struct file *fi=
le, nfsd_filldir_t func,
>  			size -=3D reclen;
>  			de =3D (struct buffered_dirent *)((char *)de + reclen);
>  		}
> -		mutex_unlock(&dir_inode->i_mutex);
>  		if (size > 0) /* We bailed out early */
>  			break;
> =20
> diff --git a/include/linux/namei.h b/include/linux/namei.h
> index c8990779f0c3..bb3a2f7cca67 100644
> --- a/include/linux/namei.h
> +++ b/include/linux/namei.h
> @@ -62,6 +62,7 @@ extern struct dentry *kern_path_locked(const char *, st=
ruct path *);
>  extern int kern_path_mountpoint(int, const char *, struct path *, unsign=
ed int);
> =20
>  extern struct dentry *lookup_one_len(const char *, struct dentry *, int);
> +extern struct dentry *lookup_one_len_unlocked(const char *, struct dentr=
y *, int);
> =20
>  extern int follow_down_one(struct path *);
>  extern int follow_down(struct path *);
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html


--Sig_/rk7h_1DfSy6=F_FS6p.r/=o
Content-Type: application/pgp-signature
Content-Description: OpenPGP digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIVAwUBVUlDlDnsnt1WYoG5AQLCahAAsmVyop4D3Lo5o4sN5mTy1p+NHB3uQJbp
TEg149RWBRSq9V6UD6ljW6AKi99G/M+wL2dgDqGxOWM7vYzPMwkPNlRWRH7SSboA
udTmkBHdNetNz9NrVJuZ/FJ5c/KhkZF7H5Ba5CM1RBWHRiwS+vcHS8X+tAfEYVYP
xO1tOTxP7psPJUCoJx2yrhaAI6Gv8c1WifyzpmHVq0U6YE7wYSd09U//Qi7pZeqa
b0i8gZ2DKNPmq5vSMj/uCKaBBqHMfFfeA0Ps5aFvE+noq2NHuCiN+o7xaZft9EJx
jjfer6lJUTOef8PsIT8069+F+dvFlv1owGGHe72qDzV7x7rYgi04BXZ42xTegGmf
PN8VaIQa9zHoWQfD0M3WL6QAS0An2j0yAhKqMivh2AjojmFFRaEgSMORmAmskRSr
PR08URzSbS7wGlI7eakakPK5v3F9t3oo2HYF2cSf2WbLDNRNNmGSt53mSv8p78MA
JIqKfuTWJND++Z6Xa6DC74s5I5j9OIdGjTwGX2x4P7jBpXDwoE2YBJgG5vGT9XH1
P0Ib2VmtE8YaVlm8L4Wjj4H9CBNHWbL8dB9wmnMaxYjrS9y5MrykckMwTra01hE4
3b05WoIK3Q2dE1jE5D9DhG77/zr0Wa1SHrDW7sCM4FwWHfpJrNgfakvQ7Qi1WtVO
Jn0XJWzkr3w=
=VvgM
-----END PGP SIGNATURE-----

--Sig_/rk7h_1DfSy6=F_FS6p.r/=o--
