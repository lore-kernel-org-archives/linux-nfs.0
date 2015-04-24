Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:57941 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753880AbbDXDAy (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 23 Apr 2015 23:00:54 -0400
Date: Fri, 24 Apr 2015 13:00:45 +1000
From: NeilBrown <neilb@suse.de>
To: Kinglong Mee <kinglongmee@gmail.com>
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH RFC] NFSD: fix cannot umounting mount points under
 pseudo root
Message-ID: <20150424130045.6bbdb2f9@notabene.brown>
In-Reply-To: <5538EB18.7080802@gmail.com>
References: <553663B7.7030506@gmail.com>
	<20150421215417.GE13782@fieldses.org>
	<553781E2.1000900@gmail.com>
	<20150422150703.GA1247@fieldses.org>
	<20150423094431.1a8aa68b@notabene.brown>
	<5538EB18.7080802@gmail.com>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 boundary="Sig_/IQtTFDURajbRYh/Dopef9SR"; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--Sig_/IQtTFDURajbRYh/Dopef9SR
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

On Thu, 23 Apr 2015 20:52:40 +0800 Kinglong Mee <kinglongmee@gmail.com> wro=
te:

> On 4/23/2015 7:44 AM, NeilBrown wrote:
> > On Wed, 22 Apr 2015 11:07:03 -0400 "J. Bruce Fields" <bfields@fieldses.=
org>
> > wrote:
> >>> Reference of dentry/mnt is like a cache, avoids re-finding of them,
> >>> it is necessary to store them in svc_export.
> >>>
> >>> Neil points out another way of 'fs_pin', I will check that.
> >>
> >> Yes, that'd be interesting.  On a very quick look--I don't understand
> >> what it's meant to do at all.  But if it does provide a way to get a
> >> callback on umount, that'd certainly be interesting....
> >=20
> > Yeah, on a quick look it isn't really obvious at all.
> >=20
> > But I didn't read the code.  I read
> >  https://lwn.net/Articles/636730/
> >=20
> > which says:
> >=20
> >     In its place is a mechanism by which an object can be added to a vf=
smount
> >     structure (which represents a mounted filesystem); that object supp=
orts=20
> >     only one method: kill(). These "pin" objects hang around until the =
final
> >     reference to the vfsmount goes away, at which point each one's kill=
() function
> >     is called. It thus is a clean mechanism for performing cleanup when=
 a filesystem
> >     goes away.
> >=20
> > This is used to close "BSD process accounting" files on umount, and sou=
nd
> > like the perfect interface for flushing things from the sunrpc cache on
> > umount.
>=20
> I have review those codes in fs/fs_pin.c and kernel/acct.c.
> 'fs_pin' is used to fix the race between file->f_path.mnt for acct
> and umount, file->f_path.mnt just holds the reference of vfsmount
> but not keep busy, umount will check the reference and return busy.
>=20
> The logical is same as sunrpc cache for exports.
>=20
> Before commit 3064c3563b ("death to mnt_pinned"), acct uses a hack
> method, acct get a pin to vfsmount and then put the reference,
> so umount finds no other reference and callback those pins in vfsmount,
> at last umount success.
>=20
> After that commit, besides pin to original vfsmount and put the reference
> of the original vfsmount, acct clone the vfsmount storing in file->f_path=
.mnt.
>=20
> The different between those two methods is the value of file->f_path.mnt,
> the first one, it contains the original vfsmnt without reference,
> the second one, contains a cloned vfsmnt with reference.
>=20
> I have test the first method, pins to vfsmount for all exports cache,
> nfsd can work but sometimes will delay or hang at rpc.mountd's calling
> of name_to_handle_at, I can't find the reason.

A kernel stack trace of exactly where it is hanging would help a lot.


>=20
> Also test the second method, there are many problem caused by the cloned
> vfsmount, mnt_clone_internal() change mnt_root values to the path dentry.
>=20
> Those cases are tested for all exports cache, but, I think nfsd should
> put the reference of vfsmount when finding exports upcall fail.
> The success exports cache should also take it.
>=20
> The following is a draft of the first method.

I think the first method sounds a lot better than the second.

>=20
> thanks,
> Kinglong Mee
>=20
> ----------------------------------------------------------------------
> diff --git a/fs/fs_pin.c b/fs/fs_pin.c
> index 611b540..553e8b1 100644
> --- a/fs/fs_pin.c
> +++ b/fs/fs_pin.c
> @@ -17,6 +17,7 @@ void pin_remove(struct fs_pin *pin)
>  	wake_up_locked(&pin->wait);
>  	spin_unlock_irq(&pin->wait.lock);
>  }
> +EXPORT_SYMBOL(pin_remove);
> =20
>  void pin_insert_group(struct fs_pin *pin, struct vfsmount *m, struct hli=
st_head *p)
>  {
> @@ -26,11 +27,13 @@ void pin_insert_group(struct fs_pin *pin, struct vfsm=
ount *m, struct hlist_head
>  	hlist_add_head(&pin->m_list, &real_mount(m)->mnt_pins);
>  	spin_unlock(&pin_lock);
>  }
> +EXPORT_SYMBOL(pin_insert_group);
> =20
>  void pin_insert(struct fs_pin *pin, struct vfsmount *m)
>  {
>  	pin_insert_group(pin, m, &m->mnt_sb->s_pins);
>  }
> +EXPORT_SYMBOL(pin_insert);
> =20
>  void pin_kill(struct fs_pin *p)
>  {
> diff --git a/fs/nfsd/export.c b/fs/nfsd/export.c
> index c3e3b6e..3e3df8c 100644
> --- a/fs/nfsd/export.c
> +++ b/fs/nfsd/export.c
> @@ -309,7 +309,7 @@ static void nfsd4_fslocs_free(struct nfsd4_fs_locatio=
ns *fsloc)
>  static void svc_export_put(struct kref *ref)
>  {
>  	struct svc_export *exp =3D container_of(ref, struct svc_export, h.ref);
> -	path_put(&exp->ex_path);
> +	pin_remove(&exp->ex_pin);
>  	auth_domain_put(exp->ex_client);
>  	nfsd4_fslocs_free(&exp->ex_fslocs);
>  	kfree(exp->ex_uuid);
> @@ -695,15 +695,26 @@ static int svc_export_match(struct cache_head *a, s=
truct cache_head *b)
>  		orig->ex_path.mnt =3D=3D new->ex_path.mnt;
>  }
> =20
> +static void export_pin_kill(struct fs_pin *pin)
> +{
> +	struct svc_export *exp =3D container_of(pin, struct svc_export, ex_pin);
> +
> +	write_lock(&exp->cd->hash_lock);
> +	cache_mark_expired(&exp->h);
> +	pin_remove(pin);
> +	write_unlock(&exp->cd->hash_lock);
> +}

I think you need to add some sort of delay here.  The svc_export entry might
still be in active use by an nfsd thread and you need to wait for that to
complete.

I think you need to wait for the refcnt to drop to '1'.  Maybe create a
global wait_queue to wait for that.

Actually... svc_expkey contains a reference to a 'path' too, so you need to
use pinning to purge those when the filesystem is unmounted.

Oh.. and you don't want to call 'pin_remove' from export_pin_kill().  It is
called from svc_export_put() and calling from both could be problematic.

Hmmm...  Ahhhh.

If you get export_pin_kill to only call cache_mark_expired() (maybe move the
locking into that function) and *not* call pin_remove(), then the pin will
remain on the list and ->done will be -1.
So mnt_pin_kill will loop around and this time pin_kill() will wait for
p->done to be set.
So we really need that thing to be removed from cache promptly.  I don't
think we can wait for the next time cache_clean will be run.  We could
call cache_flush, but I think I'd rather remove just that one entry.

Also.... this requires that the pin (and the struct containing it) be freed
using RCU.

So:
 - add an rcu_head to svc_export and svc_expkey
 - use rcu_kfree to free both those objects
 - write a 'cache_force_expire()' which sets the expiry time, and then
   removes the entry from the cache.
 - Use pin_insert_group rather then mntget for both svc_export and svc_expk=
ey
 - have the 'kill' functions for both call cache_force_expire(), but *not*
   pin_remove


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
> +	pin_insert_group(&new->ex_pin, new->ex_path.mnt, NULL);

This doesn't look right.  path_get does a 'mntget()' and a 'dget()'.
You are replacing 'mntget()' with 'pin_insert_group()', but I think you sti=
ll
need the dget().

Similarly you need a dput() up where you removed path_put().


Thanks for working on this!

NeilBrown



>  	new->ex_fslocs.locations =3D NULL;
>  	new->ex_fslocs.locations_count =3D 0;
>  	new->ex_fslocs.migrated =3D 0;
> diff --git a/fs/nfsd/export.h b/fs/nfsd/export.h
> index 1f52bfc..718a27e 100644
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
> @@ -49,6 +50,7 @@ struct svc_export {
>  	struct auth_domain *	ex_client;
>  	int			ex_flags;
>  	struct path		ex_path;
> +	struct fs_pin		ex_pin;
>  	kuid_t			ex_anon_uid;
>  	kgid_t			ex_anon_gid;
>  	int			ex_fsid;
> diff --git a/include/linux/sunrpc/cache.h b/include/linux/sunrpc/cache.h
> index 437ddb6..6936684 100644
> --- a/include/linux/sunrpc/cache.h
> +++ b/include/linux/sunrpc/cache.h
> @@ -206,6 +206,11 @@ static inline int cache_is_expired(struct cache_deta=
il *detail, struct cache_hea
>  		(detail->flush_time > h->last_refresh);
>  }
> =20
> +static inline void cache_mark_expired(struct cache_head *h)
> +{
> +	h->expiry_time =3D seconds_since_boot() - 1;
> +}
> +
>  extern int cache_check(struct cache_detail *detail,
>  		       struct cache_head *h, struct cache_req *rqstp);
>  extern void cache_flush(void);
>=20
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html


--Sig_/IQtTFDURajbRYh/Dopef9SR
Content-Type: application/pgp-signature
Content-Description: OpenPGP digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIVAwUBVTmx3Tnsnt1WYoG5AQJZxg/8CPcE5oAa+99JCLE17+EYf9W+ixi/76/M
oaJ+6uH2/4J7yJbK0S91YQeN3pOSp3JUKlrk5bCetup/1jr+++9zkkpVWGS7FJAT
XJEVWfqhSgrXc8TAyCxUzaODiDhBCjcn48RWf4pQvaqJmjUWph3MUdRmCawBLOr6
Yv3OpjBG87nnzgr5mrPdIjRz0juPVsoIg2Bk8FSWtanCE7V8TiDY/rI6+YEnpmRq
1BM5tUpfQQTXlTD6ZzCSuu7SyY0/40qxauUJGTjEng6OU40EbdnNYxIYGNZAdDKm
ro8OI+s36hYucyAMKkGCF+MuXggCGSmgv/oLNzjQVYB6vJHDAuNDoRZDPnpWbw7V
az4gXeZCcBhvkxlWPcKblVdg57Fbt6aEr3EeY8iQHgd0K/drTErczAVVCW4amQCM
fzroKG4QgPIhGcqZBfCHddaI8YG6H4DYFjGhrW7/LXmD6IQLRRllwk+gbjl4l8kv
9gWM2OLc33JrCrMGo4+rv1ALO1nzPgzLOIIu16dnFfl9D7c841BzbdImn4zzB2Kq
XcSFrkg1evY1uzvBeT2Batfo117W4j1IZB7Xc2oMM8Rv4HUbprNTfuYz6moosnns
QP+qFYd+FyQkEInVhM7snNJFu2hpso2S8a1xPAM9fElORAo7bjaA22JyP4uFbeBa
affsxJftAgc=
=btmZ
-----END PGP SIGNATURE-----

--Sig_/IQtTFDURajbRYh/Dopef9SR--
