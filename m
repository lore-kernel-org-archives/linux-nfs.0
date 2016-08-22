Return-Path: <trondmy@primarydata.com>
From: Trond Myklebust <trondmy@primarydata.com>
To: Coddington Benjamin <bcodding@redhat.com>
CC: List Linux NFS Mailing <linux-nfs@vger.kernel.org>,
        Schumaker Anna
	<anna.schumaker@netapp.com>, hch <hch@lst.de>
Subject: Re: [PATCH v2] pnfs/blocklayout: update last_write_offset atomically
 with extents
Date: Mon, 22 Aug 2016 15:34:50 +0000
Message-ID: <D2EA3F31-4360-4850-8E0A-AFCBB4EC75CC@primarydata.com>
References: <a754067b5a8252a10a0bcfa23c4229cf3d7b1adf.1471535578.git.bcodding@redhat.com>
 <d589c4985ebf916dcaf70a1c5e3bea809d2df696.1471873308.git.bcodding@redhat.com>
In-Reply-To: <d589c4985ebf916dcaf70a1c5e3bea809d2df696.1471873308.git.bcodding@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=WINDOWS-1252
List-ID: <linux-nfs.vger.kernel.org>


> On Aug 22, 2016, at 09:48, Benjamin Coddington <bcodding@redhat.com> wrot=
e:
>=20
> Change from v1:
>=20
> Instead of moving the i_lock protected region around, store last written
> byte for block layouts on struct pnfs_block_layout and use that when
> encoding LAYOUTCOMMIT.
>=20
> 8<-----------------------------------------------------------------------=
-
>=20
> Block/SCSI layout write completion may add committable extents to the
> extent tree before updating the layout's last-written byte under the inod=
e
> lock.  If a sync happens before this value is updated, then
> prepare_layoutcommit may find and encode these extents which would produc=
e
> a LAYOUTCOMMIT request whose encoded extents are larger than the request'=
s
> loca_length.
>=20
> Fix this by using a last-written byte value that is updated atomically wi=
th
> the extent tree.
>=20
> Signed-off-by: Benjamin Coddington <bcodding@redhat.com>
> ---
> fs/nfs/blocklayout/blocklayout.c | 2 +-
> fs/nfs/blocklayout/blocklayout.h | 3 ++-
> fs/nfs/blocklayout/extent_tree.c | 8 +++++---
> 3 files changed, 8 insertions(+), 5 deletions(-)
>=20
> diff --git a/fs/nfs/blocklayout/blocklayout.c b/fs/nfs/blocklayout/blockl=
ayout.c
> index 17a42e4eb872..25cdd559831c 100644
> --- a/fs/nfs/blocklayout/blocklayout.c
> +++ b/fs/nfs/blocklayout/blocklayout.c
> @@ -344,7 +344,7 @@ static void bl_write_cleanup(struct work_struct *work=
)
> =09=09=09PAGE_SIZE - 1) & (loff_t)PAGE_MASK;
>=20
> =09=09ext_tree_mark_written(bl, start >> SECTOR_SHIFT,
> -=09=09=09=09=09(end - start) >> SECTOR_SHIFT);
> +=09=09=09=09=09(end - start) >> SECTOR_SHIFT, end);
> =09}
>=20
> =09pnfs_ld_write_done(hdr);
> diff --git a/fs/nfs/blocklayout/blocklayout.h b/fs/nfs/blocklayout/blockl=
ayout.h
> index 18e6fd0b9506..efc007f00742 100644
> --- a/fs/nfs/blocklayout/blocklayout.h
> +++ b/fs/nfs/blocklayout/blocklayout.h
> @@ -141,6 +141,7 @@ struct pnfs_block_layout {
> =09struct rb_root=09=09bl_ext_ro;
> =09spinlock_t=09=09bl_ext_lock;   /* Protects list manipulation */
> =09bool=09=09=09bl_scsi_layout;
> +=09u64=09=09=09bl_lwb;
> };
>=20
> static inline struct pnfs_block_layout *
> @@ -182,7 +183,7 @@ int ext_tree_insert(struct pnfs_block_layout *bl,
> int ext_tree_remove(struct pnfs_block_layout *bl, bool rw, sector_t start=
,
> =09=09sector_t end);
> int ext_tree_mark_written(struct pnfs_block_layout *bl, sector_t start,
> -=09=09sector_t len);
> +=09=09sector_t len, u64 lwb);
> bool ext_tree_lookup(struct pnfs_block_layout *bl, sector_t isect,
> =09=09struct pnfs_block_extent *ret, bool rw);
> int ext_tree_prepare_commit(struct nfs4_layoutcommit_args *arg);
> diff --git a/fs/nfs/blocklayout/extent_tree.c b/fs/nfs/blocklayout/extent=
_tree.c
> index 992bcb19c11e..8d08dfe1e057 100644
> --- a/fs/nfs/blocklayout/extent_tree.c
> +++ b/fs/nfs/blocklayout/extent_tree.c
> @@ -402,7 +402,7 @@ ext_tree_split(struct rb_root *root, struct pnfs_bloc=
k_extent *be,
>=20
> int
> ext_tree_mark_written(struct pnfs_block_layout *bl, sector_t start,
> -=09=09sector_t len)
> +=09=09sector_t len, u64 lwb)
> {
> =09struct rb_root *root =3D &bl->bl_ext_rw;
> =09sector_t end =3D start + len;
> @@ -471,6 +471,7 @@ ext_tree_mark_written(struct pnfs_block_layout *bl, s=
ector_t start,
> =09=09}
> =09}
> out:
> +=09bl->bl_lwb =3D lwb;
> =09spin_unlock(&bl->bl_ext_lock);
>=20
> =09__ext_put_deviceids(&tmp);
> @@ -518,7 +519,7 @@ static __be32 *encode_scsi_range(struct pnfs_block_ex=
tent *be, __be32 *p)
> }
>=20
> static int ext_tree_encode_commit(struct pnfs_block_layout *bl, __be32 *p=
,
> -=09=09size_t buffer_size, size_t *count)
> +=09=09size_t buffer_size, size_t *count, __u64 *lastbyte)
> {
> =09struct pnfs_block_extent *be;
> =09int ret =3D 0;
> @@ -541,6 +542,7 @@ static int ext_tree_encode_commit(struct pnfs_block_l=
ayout *bl, __be32 *p,
> =09=09else
> =09=09=09p =3D encode_block_extent(be, p);
> =09=09be->be_tag =3D EXTENT_COMMITTING;
> +=09=09*lastbyte =3D bl->bl_lwb - 1;
> =09}
> =09spin_unlock(&bl->bl_ext_lock);
>=20
> @@ -564,7 +566,7 @@ ext_tree_prepare_commit(struct nfs4_layoutcommit_args=
 *arg)
> =09arg->layoutupdate_pages =3D &arg->layoutupdate_page;
>=20
> retry:
> -=09ret =3D ext_tree_encode_commit(bl, start_p + 1, buffer_size, &count);
> +=09ret =3D ext_tree_encode_commit(bl, start_p + 1, buffer_size, &count, =
&arg->lastbytewritten);
> =09if (unlikely(ret)) {
> =09=09ext_tree_free_commitdata(arg, buffer_size);
>=20

That looks good. Thanks!

Trond
