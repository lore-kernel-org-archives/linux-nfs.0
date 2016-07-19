Return-Path: <trondmy@primarydata.com>
From: Trond Myklebust <trondmy@primarydata.com>
To: Coddington Benjamin <bcodding@redhat.com>
CC: List Linux <linux-nfs@vger.kernel.org>,
        Schumaker Anna
	<anna.schumaker@netapp.com>, hch <hch@lst.de>
Subject: Re: [PATCH] pnfs/blocklayout: put deviceid node after releasing
 bl_ext_lock
Date: Tue, 19 Jul 2016 12:25:45 +0000
Message-ID: <5F0069E8-CCD7-42B0-B391-F1D4B0B9C0AF@primarydata.com>
References: <0ca3d07057a20e89726de2f0e9ff8c7fcb6ac3d9.1465589365.git.bcodding@redhat.com>
In-Reply-To: <0ca3d07057a20e89726de2f0e9ff8c7fcb6ac3d9.1465589365.git.bcodding@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=WINDOWS-1252
List-ID: <linux-nfs.vger.kernel.org>

Hi Ben,

> On Jun 10, 2016, at 16:37, Benjamin Coddington <bcodding@redhat.com> wrot=
e:
>=20
> The last put of deviceid nodes for SCSI layouts may sleep, so we shouldn'=
t
> hold any spinlocks.  Make sure we put them outside the bl_ext_lock.
>=20
> Signed-off-by: Benjamin Coddington <bcodding@redhat.com>
> ---
> fs/nfs/blocklayout/extent_tree.c | 27 +++++++++++++++++++++------
> 1 file changed, 21 insertions(+), 6 deletions(-)
>=20
> diff --git a/fs/nfs/blocklayout/extent_tree.c b/fs/nfs/blocklayout/extent=
_tree.c
> index 720b3ff55fa9..992bcb19c11e 100644
> --- a/fs/nfs/blocklayout/extent_tree.c
> +++ b/fs/nfs/blocklayout/extent_tree.c
> @@ -121,6 +121,16 @@ ext_try_to_merge_right(struct rb_root *root, struct =
pnfs_block_extent *be)
> =09return be;
> }
>=20
> +static void __ext_put_deviceids(struct list_head *head)
> +{
> +=09struct pnfs_block_extent *be, *tmp;
> +
> +=09list_for_each_entry_safe(be, tmp, head, be_list) {
> +=09=09nfs4_put_deviceid_node(be->be_device);
> +=09=09kfree(be);
> +=09}

This definitely needs a list_del()=85 I only noticed this morning after hun=
ting for the OOM that Christoph says turned up after this weekend.

> +}
> +
> static void
> __ext_tree_insert(struct rb_root *root,
> =09=09struct pnfs_block_extent *new, bool merge_ok)
> @@ -163,7 +173,8 @@ free_new:
> }
>=20
> static int
> -__ext_tree_remove(struct rb_root *root, sector_t start, sector_t end)
> +__ext_tree_remove(struct rb_root *root,
> +=09=09sector_t start, sector_t end, struct list_head *tmp)
> {
> =09struct pnfs_block_extent *be;
> =09sector_t len1 =3D 0, len2 =3D 0;
> @@ -223,8 +234,7 @@ __ext_tree_remove(struct rb_root *root, sector_t star=
t, sector_t end)
> =09=09=09struct pnfs_block_extent *next =3D ext_tree_next(be);
>=20
> =09=09=09rb_erase(&be->be_node, root);
> -=09=09=09nfs4_put_deviceid_node(be->be_device);
> -=09=09=09kfree(be);
> +=09=09=09list_add_tail(&be->be_list, tmp);
> =09=09=09be =3D next;
> =09=09}
>=20
> @@ -350,16 +360,18 @@ int ext_tree_remove(struct pnfs_block_layout *bl, b=
ool rw,
> =09=09sector_t start, sector_t end)
> {
> =09int err, err2;
> +=09LIST_HEAD(tmp);
>=20
> =09spin_lock(&bl->bl_ext_lock);
> -=09err =3D __ext_tree_remove(&bl->bl_ext_ro, start, end);
> +=09err =3D __ext_tree_remove(&bl->bl_ext_ro, start, end, &tmp);
> =09if (rw) {
> -=09=09err2 =3D __ext_tree_remove(&bl->bl_ext_rw, start, end);
> +=09=09err2 =3D __ext_tree_remove(&bl->bl_ext_rw, start, end, &tmp);
> =09=09if (!err)
> =09=09=09err =3D err2;
> =09}
> =09spin_unlock(&bl->bl_ext_lock);
>=20
> +=09__ext_put_deviceids(&tmp);
> =09return err;
> }
>=20
> @@ -396,12 +408,13 @@ ext_tree_mark_written(struct pnfs_block_layout *bl,=
 sector_t start,
> =09sector_t end =3D start + len;
> =09struct pnfs_block_extent *be;
> =09int err =3D 0;
> +=09LIST_HEAD(tmp);
>=20
> =09spin_lock(&bl->bl_ext_lock);
> =09/*
> =09 * First remove all COW extents or holes from written to range.
> =09 */
> -=09err =3D __ext_tree_remove(&bl->bl_ext_ro, start, end);
> +=09err =3D __ext_tree_remove(&bl->bl_ext_ro, start, end, &tmp);
> =09if (err)
> =09=09goto out;
>=20
> @@ -459,6 +472,8 @@ ext_tree_mark_written(struct pnfs_block_layout *bl, s=
ector_t start,
> =09}
> out:
> =09spin_unlock(&bl->bl_ext_lock);
> +
> +=09__ext_put_deviceids(&tmp);
> =09return err;
> }
>=20
> --=20
> 2.5.5
>=20
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>=20
