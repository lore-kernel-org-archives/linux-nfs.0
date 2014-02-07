Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cantor2.suse.de ([195.135.220.15]:58309 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750818AbaBGEan (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 6 Feb 2014 23:30:43 -0500
Date: Fri, 7 Feb 2014 15:30:28 +1100
From: NeilBrown <neilb@suse.de>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: Jeff Layton <jlayton@poochiereds.net>,
        "Mkrtchyan, Tigran" <tigran.mkrtchyan@desy.de>,
        Jim Rees <rees@umich.edu>, linux-nfs <linux-nfs@vger.kernel.org>
Subject: Re: readdir vs. getattr
Message-ID: <20140207153028.7df0d209@notabene.brown>
In-Reply-To: <1391724779.6399.2.camel@leira.trondhjem.org>
References: <CAGue13pe_ZH_Eto-jL3mLjTNGFK26izTarnZdjs3eL82A2Z37w@mail.gmail.com>
	<20130404151507.GA8484@umich.edu>
	<CAGue13o6X5S3ppTX_fmMCTCX=7Mq_57YQEsb_hkOKwN9iOHwEQ@mail.gmail.com>
	<1365090480.10726.22.camel@leira.trondhjem.org>
	<20140129182532.7479eeda@notabene.brown>
	<1342984553.746756.1390987303295.JavaMail.zimbra@desy.de>
	<20140129071841.1979a48c@tlielax.poochiereds.net>
	<20140206134539.53d09434@notabene.brown>
	<20140206135101.1cc83442@notabene.brown>
	<1391724779.6399.2.camel@leira.trondhjem.org>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=PGP-SHA1;
 boundary="Sig_/bpqWLNOh0MGlstid+rj83Nz"; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--Sig_/bpqWLNOh0MGlstid+rj83Nz
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

On Thu, 06 Feb 2014 17:12:59 -0500 Trond Myklebust
<trond.myklebust@primarydata.com> wrote:

> On Thu, 2014-02-06 at 13:51 +1100, NeilBrown wrote:
> > On Thu, 6 Feb 2014 13:45:39 +1100 NeilBrown <neilb@suse.de> wrote:
> >=20
> >=20
> > > The change to nfs_update_inode fixes an issue that had me stumped for=
 a
> > > while.  It was still sending lots of GETATTR requests even after it h=
ad
> > > switched to READDIRPLUS instead of using cached info.  So that might =
be a
> > > genuine bug that should be fixed independently of this patch.
> >=20
> > I managed to post the wrong version of the patch, which didn't have this
> > change.  Sorry.
> >=20
> > Here is the real one.
> >=20
> > NeilBrown
>=20
> Hi Neil,
>=20
> Is there any reason why this patch couldn't just be replaced with the
> following?

Well.... the following doesn't make any change in my test case. :-(

In my test case there is a large directory on the server which doesn't chan=
ge.
The client sends lots of requests to see if it has changed, but it hasn't.
(Tested with the labeled-NFS-regression fix applied)

Your patch only changes behaviour if nfs_force_lookup_revalidate is called,
and that is only called when NFS_ATTR_FATTR_CHANGE is set, or when an NFSv4
client modifies the directory.  Neither of those are happening.

Thanks,
NeilBrown


> (Please note the separate fix for the labeled NFS regression that you
> pointed out.)
>=20
> Cheers
>   Trond
>=20
> 8<-------------------------------------------------------------------
> >From fda6d0fb7988fd7d541ef6d1023bca92b0e10333 Mon Sep 17 00:00:00 2001
> From: Trond Myklebust <trond.myklebust@primarydata.com>
> Date: Thu, 6 Feb 2014 16:45:21 -0500
> Subject: [PATCH] NFS: Use readdirplus in order to efficiently revalidate =
whole
>  directories
>=20
> When we call nfs_force_lookup_revalidate() in order to force a full
> lookup of all child dentries of a directory, it makes sense to use
> readdirplus to perform that revalidation as efficiently as possible.
>=20
> Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
> ---
>  fs/nfs/dir.c | 20 ++++++++++++++++++++
>  1 file changed, 20 insertions(+)
>=20
> diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
> index be38b573495a..2abcae330ad0 100644
> --- a/fs/nfs/dir.c
> +++ b/fs/nfs/dir.c
> @@ -437,6 +437,24 @@ void nfs_advise_use_readdirplus(struct inode *dir)
>  	set_bit(NFS_INO_ADVISE_RDPLUS, &NFS_I(dir)->flags);
>  }
> =20
> +/*
> + * Force use of readdirplus to ensure efficient revalidation of
> + * the directory child dentries when we know that we will need
> + * to revalidate the whole directory.
> + *
> + * Caller must hold dir->i_lock.
> + */
> +static
> +void nfs_force_use_readdirplus(struct inode *dir)
> +{
> +	if (nfs_server_capable(dir, NFS_CAP_READDIRPLUS)) {
> +		struct nfs_inode *nfsi =3D NFS_I(dir);
> +
> +		set_bit(NFS_INO_ADVISE_RDPLUS, &nfsi->flags);
> +		nfsi->cache_validity |=3D NFS_INO_INVALID_DATA;
> +	}
> +}
> +
>  static
>  void nfs_prime_dcache(struct dentry *parent, struct nfs_entry *entry)
>  {
> @@ -942,12 +960,14 @@ static int nfs_fsync_dir(struct file *filp, loff_t =
start, loff_t end,
>   * This forces the revalidation code in nfs_lookup_revalidate() to do a
>   * full lookup on all child dentries of 'dir' whenever a change occurs
>   * on the server that might have invalidated our dcache.
> + * Call nfs_force_use_readdirplus for efficiency.
>   *
>   * The caller should be holding dir->i_lock
>   */
>  void nfs_force_lookup_revalidate(struct inode *dir)
>  {
>  	NFS_I(dir)->cache_change_attribute++;
> +	nfs_force_use_readdirplus(dir);
>  }
>  EXPORT_SYMBOL_GPL(nfs_force_lookup_revalidate);
> =20


--Sig_/bpqWLNOh0MGlstid+rj83Nz
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.22 (GNU/Linux)

iQIVAwUBUvRhZDnsnt1WYoG5AQLJTw/+M4e22u1q1C9PTUSvXj34CgKxxGb/zdeA
5lN7ExsWe6QxrmJSLi0E8it0vxRTIw1zGhwzAMzJpBQPS75i0BIvO2DAMLfTB4wy
cIduTTndmAhxqaEGFSGsepLW6uNeANqk3LKDUFUS7B1zWpUM+YoFgTG3HQwPDQ4E
Wb3OEG/JwNol7yUjNfFJ4ibz4GsoZQolzHAwnObrvh3GeIoxxJFD2LMLsbAddUCU
0Q31E8+i1UMEZKhRdGGadnkv4d8bQmty/q5DbOgNzhkf0ObzAji31Sfb6jPjxOBK
UlZu7lYCGYFx87piVIcwAt2Kvca/5+v2yLwDPhEV2Y+BZijBAij7MeO9JnDUjXck
r2LcnQWUTgJ5yksxg7LGbxV0IuJhLVo1VYOF0s4XhRCzup2MzLXQscW8wSsoWjk5
nZQ2gjQLl+w8wflaJVyX4T6Z/UbwprG6Q80MJJgt/0lxVjv0z75+2jCYHsfFM0bO
zyt2MYtJ8dNacgYqNKRnUXKhWnBDeUw0SHdNgRU3VahXws9XJwFax/3W+rWfgezJ
oh0S+2SED0iPIYm5izg2qiHg8K9UrfwOmk98awxMdfsiDWbQX3MaOO4+4H7Q+55i
T9zBtXGcL6WDxcZ6XAtzxKlxiDT2MdgAsrjlbYYqVdeEJUyDXf2e1X91Orj7m6P7
UKMm/X5sARo=
=wSZz
-----END PGP SIGNATURE-----

--Sig_/bpqWLNOh0MGlstid+rj83Nz--
