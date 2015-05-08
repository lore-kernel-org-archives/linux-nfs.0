Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:33674 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751030AbbEHEkm (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 8 May 2015 00:40:42 -0400
Date: Fri, 8 May 2015 14:40:31 +1000
From: NeilBrown <neilb@suse.de>
To: Kinglong Mee <kinglongmee@gmail.com>
Cc: "J. Bruce Fields" <bfields@fieldses.org>, linux-fsdevel@vger.kernel.org,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        Al Viro <viro@zeniv.linux.org.uk>,
        Trond Myklebust <trond.myklebust@primarydata.com>
Subject: Re: [PATCH 4/4] nfsd: Pin to vfsmnt instead of mntget
Message-ID: <20150508144031.6f0d3cda@notabene.brown>
In-Reply-To: <554A154B.6040103@gmail.com>
References: <554A149B.5060102@gmail.com>
	<554A154B.6040103@gmail.com>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 boundary="Sig_/ud16PXgyvF.y3fdCJsbSZTQ"; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--Sig_/ud16PXgyvF.y3fdCJsbSZTQ
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

On Wed, 06 May 2015 21:21:15 +0800 Kinglong Mee <kinglongmee@gmail.com> wro=
te:

> If there are some mount points(not exported for nfs) under pseudo root,
> after client's operation of those entry under the root, anyone *can't*
> unmount those mount points until export cache expired.
>=20
> # cat /etc/exports
> /nfs/xfs        *(rw,insecure,no_subtree_check,no_root_squash)
> /nfs/pnfs       *(rw,insecure,no_subtree_check,no_root_squash)
> # ll /nfs/
> total 0
> drwxr-xr-x. 3 root root 84 Apr 21 22:27 pnfs
> drwxr-xr-x. 3 root root 84 Apr 21 22:27 test
> drwxr-xr-x. 2 root root  6 Apr 20 22:01 xfs
> # mount /dev/sde /nfs/test
> # df
> Filesystem                      1K-blocks    Used Available Use% Mounted =
on
> ......
> /dev/sdd                          1038336   32944   1005392   4% /nfs/pnfs
> /dev/sdc                         10475520   32928  10442592   1% /nfs/xfs
> /dev/sde                           999320    1284    929224   1% /nfs/test
> # mount -t nfs 127.0.0.1:/nfs/ /mnt
> # ll /mnt/*/
> /mnt/pnfs/:
> total 0
> -rw-r--r--. 1 root root 0 Apr 21 22:23 attr
> drwxr-xr-x. 2 root root 6 Apr 21 22:19 tmp
>=20
> /mnt/xfs/:
> total 0
> # umount /nfs/test/
> umount: /nfs/test/: target is busy
>         (In some cases useful info about processes that
>          use the device is found by lsof(8) or fuser(1).)
>=20
> I don't think that's user expect, they want umount /nfs/test/.
>=20
> It's caused by exports cache of nfsd holds the reference of
> the path (here is /nfs/test/), so, it can't be umounted.
>=20
> The patch site using fs_pin instead of mntget for export cache,
> user at nfs server can unmount any mount points includes exported
> for nfs. Maybe, only umounted for unexported mount points is better?


Thanks for this patch.  It looks good!

My only comment on the code is that I would really like to see a
"path_get_pin()" and "path_put_unpin()" rather than open coding:

> +	dget(item->ek_path.dentry);
> +	pin_insert_group(&new->ek_pin, item->ek_path.mnt, NULL);

and=20

> +		dput(key->ek_path.dentry);
> +		pin_remove(&key->ek_pin);


But the question you raise is an important one:  Exactly which filesystems
should be allowed to be unmounted?
This is a change in behaviour - is it one that people uniformly would want?

The kernel doesn't currently know which file systems were explicitly listed
in /etc/exports, and which were found by following a 'crossmnt'.
It could guess and allow the unmounting of anything below a 'crossmnt', but=
 I
wouldn't be comfortable with that - it is error prone.

mountd does know what is in /etc/exports, and could tell the kernel.
For the expkey cache, we could always use path_get_pin.
For the export cache (where flags are available) we could use path_get
or path_get_pin depending on some new flag.

I'm not really sure it is worth it.  I would rather the filesystems could
always be unmounted.  But doing that could possibly break someone's work
flow.  Maybe.

Or maybe I'm seeing problems where there aren't any.

Anyone else have an opinion?

Thanks,
NeilBrown



>=20
> Signed-off-by: Kinglong Mee <kinglongmee@gmail.com>
> ---
>  fs/nfsd/export.c | 37 ++++++++++++++++++++++++++++++-------
>  fs/nfsd/export.h | 10 +++++++++-
>  2 files changed, 39 insertions(+), 8 deletions(-)
>=20
> diff --git a/fs/nfsd/export.c b/fs/nfsd/export.c
> index f79521a..80f82f5 100644
> --- a/fs/nfsd/export.c
> +++ b/fs/nfsd/export.c
> @@ -42,10 +42,12 @@ static void expkey_put(struct kref *ref)
>  	struct svc_expkey *key =3D container_of(ref, struct svc_expkey, h.ref);
> =20
>  	if (test_bit(CACHE_VALID, &key->h.flags) &&
> -	    !test_bit(CACHE_NEGATIVE, &key->h.flags))
> -		path_put(&key->ek_path);
> +	    !test_bit(CACHE_NEGATIVE, &key->h.flags)) {
> +		dput(key->ek_path.dentry);
> +		pin_remove(&key->ek_pin);
> +	}
>  	auth_domain_put(key->ek_client);
> -	kfree(key);
> +	kfree_rcu(key, rcu_head);
>  }
> =20
>  static void expkey_request(struct cache_detail *cd,
> @@ -120,6 +122,7 @@ static int expkey_parse(struct cache_detail *cd, char=
 *mesg, int mlen)
>  		goto out;
> =20
>  	key.ek_client =3D dom;=09
> +	key.cd =3D cd;
>  	key.ek_fsidtype =3D fsidtype;
>  	memcpy(key.ek_fsid, buf, len);
> =20
> @@ -210,6 +213,13 @@ static inline void expkey_init(struct cache_head *cn=
ew,
>  	new->ek_fsidtype =3D item->ek_fsidtype;
> =20
>  	memcpy(new->ek_fsid, item->ek_fsid, sizeof(new->ek_fsid));
> +	new->cd =3D item->cd;
> +}
> +
> +static void expkey_pin_kill(struct fs_pin *pin)
> +{
> +	struct svc_expkey *key =3D container_of(pin, struct svc_expkey, ek_pin);
> +	cache_force_expire(key->cd, &key->h);
>  }
> =20
>  static inline void expkey_update(struct cache_head *cnew,
> @@ -218,8 +228,10 @@ static inline void expkey_update(struct cache_head *=
cnew,
>  	struct svc_expkey *new =3D container_of(cnew, struct svc_expkey, h);
>  	struct svc_expkey *item =3D container_of(citem, struct svc_expkey, h);
> =20
> +	init_fs_pin(&new->ek_pin, expkey_pin_kill);
>  	new->ek_path =3D item->ek_path;
> -	path_get(&item->ek_path);
> +	dget(item->ek_path.dentry);
> +	pin_insert_group(&new->ek_pin, item->ek_path.mnt, NULL);
>  }
> =20
>  static struct cache_head *expkey_alloc(void)
> @@ -309,11 +321,13 @@ static void nfsd4_fslocs_free(struct nfsd4_fs_locat=
ions *fsloc)
>  static void svc_export_put(struct kref *ref)
>  {
>  	struct svc_export *exp =3D container_of(ref, struct svc_export, h.ref);
> -	path_put(&exp->ex_path);
> +
> +	dput(exp->ex_path.dentry);
> +	pin_remove(&exp->ex_pin);
>  	auth_domain_put(exp->ex_client);
>  	nfsd4_fslocs_free(&exp->ex_fslocs);
>  	kfree(exp->ex_uuid);
> -	kfree(exp);
> +	kfree_rcu(exp, rcu_head);
>  }
> =20
>  static void svc_export_request(struct cache_detail *cd,
> @@ -694,15 +708,23 @@ static int svc_export_match(struct cache_head *a, s=
truct cache_head *b)
>  		path_equal(&orig->ex_path, &new->ex_path);
>  }
> =20
> +static void export_pin_kill(struct fs_pin *pin)
> +{
> +	struct svc_export *exp =3D container_of(pin, struct svc_export, ex_pin);
> +	cache_force_expire(exp->cd, &exp->h);
> +}
> +
>  static void svc_export_init(struct cache_head *cnew, struct cache_head *=
citem)
>  {
>  	struct svc_export *new =3D container_of(cnew, struct svc_export, h);
>  	struct svc_export *item =3D container_of(citem, struct svc_export, h);
> =20
> +	init_fs_pin(&new->ex_pin, export_pin_kill);
>  	kref_get(&item->ex_client->ref);
>  	new->ex_client =3D item->ex_client;
>  	new->ex_path =3D item->ex_path;
> -	path_get(&item->ex_path);
> +	dget(item->ex_path.dentry);
> +	pin_insert_group(&new->ex_pin, item->ex_path.mnt, NULL);
>  	new->ex_fslocs.locations =3D NULL;
>  	new->ex_fslocs.locations_count =3D 0;
>  	new->ex_fslocs.migrated =3D 0;
> @@ -811,6 +833,7 @@ exp_find_key(struct cache_detail *cd, struct auth_dom=
ain *clp, int fsid_type,
> =20
>  	key.ek_client =3D clp;
>  	key.ek_fsidtype =3D fsid_type;
> +	key.cd =3D cd;
>  	memcpy(key.ek_fsid, fsidv, key_len(fsid_type));
> =20
>  	ek =3D svc_expkey_lookup(cd, &key);
> diff --git a/fs/nfsd/export.h b/fs/nfsd/export.h
> index 1f52bfc..1cf6ada 100644
> --- a/fs/nfsd/export.h
> +++ b/fs/nfsd/export.h
> @@ -4,6 +4,7 @@
>  #ifndef NFSD_EXPORT_H
>  #define NFSD_EXPORT_H
> =20
> +#include <linux/fs_pin.h>
>  #include <linux/sunrpc/cache.h>
>  #include <uapi/linux/nfsd/export.h>
> =20
> @@ -46,6 +47,8 @@ struct exp_flavor_info {
> =20
>  struct svc_export {
>  	struct cache_head	h;
> +	struct cache_detail	*cd;
> +
>  	struct auth_domain *	ex_client;
>  	int			ex_flags;
>  	struct path		ex_path;
> @@ -58,7 +61,9 @@ struct svc_export {
>  	struct exp_flavor_info	ex_flavors[MAX_SECINFO_LIST];
>  	enum pnfs_layouttype	ex_layout_type;
>  	struct nfsd4_deviceid_map *ex_devid_map;
> -	struct cache_detail	*cd;
> +
> +	struct fs_pin		ex_pin;
> +	struct rcu_head		rcu_head;
>  };
> =20
>  /* an "export key" (expkey) maps a filehandlefragement to an
> @@ -67,12 +72,15 @@ struct svc_export {
>   */
>  struct svc_expkey {
>  	struct cache_head	h;
> +	struct cache_detail	*cd;
> =20
>  	struct auth_domain *	ek_client;
>  	int			ek_fsidtype;
>  	u32			ek_fsid[6];
> =20
>  	struct path		ek_path;
> +	struct fs_pin		ek_pin;
> +	struct rcu_head		rcu_head;
>  };
> =20
>  #define EX_ISSYNC(exp)		(!((exp)->ex_flags & NFSEXP_ASYNC))


--Sig_/ud16PXgyvF.y3fdCJsbSZTQ
Content-Type: application/pgp-signature
Content-Description: OpenPGP digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIVAwUBVUw+QDnsnt1WYoG5AQJ9bw/9HFNkeNfarAeT9rqYAC73tiWYSCwnkmLk
ItNEu397IPNr4cUpwx0jC0vtGlOIL8w+SyJMmmuvm/D/4kyn8uOW2y6LAeV1Hqww
gMxgfPORWsUvAKsm0VIzzeMXpRkzGhbFEMI6uiQL/lF0oSUPalC5cbIHnjkA+/yC
9AUX/7k3CRc1kmxCcN5uqu9dnPK4NQWGLQvFm2QDLHjClPS2xc2pnriZ5sqtHBE5
j1oIe+56Jgo5aE6hObUzbO8Hqj5bIB9DrmDlSlmA2uhNDdX1ZFWrOjfSxH7TrSfC
npr40FKiJFxjYwv+aDseum4x/kLq66bMRz2GrA1OrxHnYrZdW6SsFUSydlMaFC81
865X5nMjkQqhqPvuWq4bWC237BTMdXn2VcKfqLr39yYUxH1Eq6GOVig3T3MeYDGc
xe8lH4UdTNadyuiEWYPST9dko8Cjb91K2026xFOO2jw/vP6MiB0o4Km3M3pEOhu2
2RrtVdWkqiRuwQAyY+7v1TSLC4ZuXErG/4QovuV3SPpRC1w3mqw1/6Sqpg9WxkvZ
KauHswDqvjd/epZkgeMs917Oey56q80QUp/UFmznr6lDWhC+EG75a872bWLmH4HJ
pA6c76FMkIjolFGQqdFTGgcap8bT+UQ+h2GSrsD8BhDKU9FJ9/R0u9qexSWnzw5V
lui/fBQdChs=
=jii6
-----END PGP SIGNATURE-----

--Sig_/ud16PXgyvF.y3fdCJsbSZTQ--
