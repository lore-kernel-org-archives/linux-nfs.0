Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cantor2.suse.de ([195.135.220.15]:41317 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750885Ab3BTWcp (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 20 Feb 2013 17:32:45 -0500
Date: Thu, 21 Feb 2013 09:32:25 +1100
From: NeilBrown <neilb@suse.de>
To: Jeff Layton <jlayton@redhat.com>
Cc: viro@ZenIV.linux.org.uk, trond.myklebust@netapp.com,
        linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org
Subject: Re: [PATCH v1] vfs: kill FS_REVAL_DOT by adding a d_reval_jumped
 dentry op
Message-ID: <20130221093225.5390bb77@notabene.brown>
In-Reply-To: <1361377145-28094-1-git-send-email-jlayton@redhat.com>
References: <1361377145-28094-1-git-send-email-jlayton@redhat.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=PGP-SHA1;
 boundary="Sig_/Ntxumm1byPrpSLvaCpPcLNI"; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--Sig_/Ntxumm1byPrpSLvaCpPcLNI
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

On Wed, 20 Feb 2013 11:19:05 -0500 Jeff Layton <jlayton@redhat.com> wrote:

> The following set of operations on a NFS client and server will cause
>=20
>     server# mkdir a
>     client# cd a
>     server# mv a a.bak
>     client# sleep 30  # (or whatever the dir attrcache timeout is)
>     client# stat .
>     stat: cannot stat =E2=80=98.=E2=80=99: Stale NFS file handle
>=20
> Obviously, we should not be getting an ESTALE error back there since the
> inode still exists on the server. The problem is that the lookup code
> will call d_revalidate on the dentry that "." refers to, because NFS has
> FS_REVAL_DOT set.
>=20
> nfs_lookup_revalidate will see that the parent directory has changed and
> will try to reverify the dentry by redoing a LOOKUP. That of course
> fails, so the lookup code returns ESTALE.
>=20
> The problem here is that d_revalidate is really a bad fit for this case.
> What we really want to know at this point is whether the inode is still
> good or not, but we don't really care what name it goes by or whether
> the dcache is still valid.
>=20
> Add a new d_op->d_reval_jumped operation and have complete_walk call
> that instead of d_revalidate. The intent there is to allow for a
> "weaker" d_revalidate that just checks to see whether the inode is still
> good. This is also gives us an opportunity to kill off the FS_REVAL_DOT
> special casing.
>=20
> In a perfect world, this would be a new inode operation instead, but
> I don't see a way to cleanly handle that for 9p, which needs a
> dentry in order to get a fid.

The earlier i_op->revalidate inode operation took a 'dentry', not an inode.
If you look at struct inode_operations, you will see that 8 of them take a
dentry as their first argument.

Never the less, I would leave it in dentry_operations.  It makes it easier =
to
use the DCACHE_OP_ optimisation.


>=20
> Cc: NeilBrown <neilb@suse.de>
> Signed-off-by: Jeff Layton <jlayton@redhat.com>
> ---
>  Documentation/filesystems/Locking |  2 ++
>  Documentation/filesystems/vfs.txt | 32 ++++++++++++++++++++++++++--
>  fs/9p/vfs_dentry.c                |  1 +
>  fs/9p/vfs_super.c                 |  2 +-
>  fs/dcache.c                       |  3 +++
>  fs/namei.c                        |  8 ++-----
>  fs/nfs/dir.c                      | 45 +++++++++++++++++++++++++++++++++=
++++++
>  fs/nfs/nfs4super.c                |  6 +++---
>  fs/nfs/super.c                    |  6 +++---
>  include/linux/dcache.h            |  3 +++
>  include/linux/fs.h                |  1 -
>  11 files changed, 93 insertions(+), 16 deletions(-)
>=20
> diff --git a/Documentation/filesystems/Locking b/Documentation/filesystem=
s/Locking
> index f48e0c6..9718b667 100644
> --- a/Documentation/filesystems/Locking
> +++ b/Documentation/filesystems/Locking
> @@ -10,6 +10,7 @@ be able to use diff(1).
>  --------------------------- dentry_operations --------------------------
>  prototypes:
>  	int (*d_revalidate)(struct dentry *, unsigned int);
> +	int (*d_reval_jumped)(struct dentry *, unsigned int);
>  	int (*d_hash)(const struct dentry *, const struct inode *,
>  			struct qstr *);
>  	int (*d_compare)(const struct dentry *, const struct inode *,

I cannot get excited about the name "d_reval_jumped" .... though once you
read the explanation in the doco (thanks for that) it makes sense.  I guess
I'll get used to it.

>  /*
> + * A weaker form of d_revalidate for revalidating just the dentry->d_ino=
de
> + * when we don't really care about the dentry name. This is called when a
> + * pathwalk ends on a dentry that was not found via a normal lookup in t=
he
> + * parent dir (e.g.: ".", "..", procfs symlinks or mountpoint traversals=
).
> + *
> + * In this situation, we just want to verify that the inode itself is OK
> + * since the dentry might have changed on the server.
> + */
> +static int nfs_reval_jumped(struct dentry *dentry, unsigned int flags)
> +{
> +	int error;
> +	struct inode *inode =3D dentry->d_inode;
> +
> +	if (flags & LOOKUP_RCU)
> +		return -ECHILD;
> +
> +	/*
> +	 * I believe we can only get a negative dentry here in the case of a
> +	 * procfs-style symlink. Just assume it's correct for now, but we may
> +	 * eventually need to do something more here.
> +	 */
> +	if (!inode) {
> +		dfprintk(LOOKUPCACHE, "%s: %s/%s has negative inode\n",
> +				__func__, dentry->d_parent->d_name.name,
> +				dentry->d_name.name);
> +		return 1;
> +	}
> +
> +	if (is_bad_inode(inode)) {
> +		dfprintk(LOOKUPCACHE, "%s: %s/%s has dud inode\n",
> +				__func__, dentry->d_parent->d_name.name,
> +				dentry->d_name.name);
> +		return 0;
> +	}
> +
> +	error =3D nfs_revalidate_inode(NFS_SERVER(inode), inode);
> +	dfprintk(LOOKUPCACHE, "NFS: %s: inode %lu is %s\n",
> +			__func__, inode->i_ino, error ? "invalid" : "valid");
> +	if (error)
> +		return 0;
> +	return 1;
> +}

I wonder if we can delay the "-ECHILD" return a bit.
Leaving it to after the first two tests should be safe, but doesn't gain us
anything.

Open-coding the nfs_revalidate_inode as:
	if (!(NFS_I(inode)->cache_validity & NFS_INO_INVALID_ATTR)
			&& !nfs_attribute_cache_expired(inode))
		return NFS_STALE(inode) ? 0 : 1;
	error =3D __nfs_revalidate_inode(server, inode);

and then inserting the -ECHILD code in before the __nfs_revalidate_inode
should be safe, and means we still benefit from the RCU path in the common
case.
Of course, for that to be really useful, nfs_lookup_revalidate would need to
be changed to only return -ECHILD if it really needed to block, and  maybe
that is too hard, or at least is a job for another day.

Otherwise, looks good - thanks.

Reviewed-by: NeilBrown <neilb@suse.de>


NeilBrown

--Sig_/Ntxumm1byPrpSLvaCpPcLNI
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.19 (GNU/Linux)

iQIVAwUBUSVO+Tnsnt1WYoG5AQIhHw//cV+7nfi3URucqMR6lhZiuTlmbISrV0M3
dUenSz/dVIZIh8qQK5wR8WetN4tT0cjUfGKyNS2KuM4sxT7DO6ZGKSf018hcFv7V
c2Px+tnr7lxghcCFbkrsAD1l0em6qc0TLrcph/FaUikVYilsEui62hE5ZRnlSkyu
yggQpPXVAtClWdKeZpAL6bEd7EII2GUCtUIzju3AK7dmRPZ7vD5Rv66vq3PLed8f
zhUNYFB/bgvsv6QVYjaz8mdApq+ukeg/Cdod1qdhnKI3H4IjtWL0Y7hQFSvNp0K9
CFBf3GQoYGQ1sAQa1ZBjaUPopVz/P+ikQBGAHIQ3tefEGNzuyNdb+IKFLNREYQth
3NxVzcnGJu+WyFUHdwrP3GcJ+21R3PjYauxVcZ9fP60Yma0aPrkWL8ENt3NyY3SX
Z8AYNY6a0m2o6qeWU82TcOl0TiTuDn9kookVQDSB6FH8CcPSpw0HhLyNV8uO40Ze
+7vpY24UChXKc1QBM7YNVqGQ1egRms0BR1tD8Zsp4c34ACkfs38wLLx4FcJH4ugb
n67EcHjn3mh/az2GDrL319VIocfdlfFKZqa+w+1nJS5hFBdYWNZqCoogGPesz2ko
/AB01qb8X0Hau0ZWSViLByGRazdpahTm9E6zmJ8smaIs8wW98QYIlMSfKhmkBl38
AZRrh2Hamos=
=Quqa
-----END PGP SIGNATURE-----

--Sig_/Ntxumm1byPrpSLvaCpPcLNI--
