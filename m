Return-Path: <trondmy@primarydata.com>
From: Trond Myklebust <trondmy@primarydata.com>
To: Coddington Benjamin <bcodding@redhat.com>
CC: List Linux NFS Mailing <linux-nfs@vger.kernel.org>,
        Trond Myklebust
	<trondmy@primarydata.com>,
        Schumaker Anna <anna.schumaker@netapp.com>, hch
	<hch@lst.de>
Subject: Re: [PATCH] pnfs/blocklayout: update last_write_offset atomically
 with extents
Date: Thu, 18 Aug 2016 18:19:19 +0000
Message-ID: <FF778D94-8CA1-4FEE-A4EE-C170ECA4E1C2@primarydata.com>
References: <a754067b5a8252a10a0bcfa23c4229cf3d7b1adf.1471535578.git.bcodding@redhat.com>
In-Reply-To: <a754067b5a8252a10a0bcfa23c4229cf3d7b1adf.1471535578.git.bcodding@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=WINDOWS-1252
List-ID: <linux-nfs.vger.kernel.org>

Hi Ben,

Thanks for continuing to work on this.

> On Aug 18, 2016, at 11:55, Benjamin Coddington <bcodding@redhat.com> wrot=
e:
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
> Fix this by holding the i_lock while marking extents writeable and updati=
ng
> the value of the last written byte.  Then extending the i_lock over
> prepare_layoutcommit in pnfs_layoutcommit_inode() ensures we won't find
> extents starting beyond the current last written byte.
>=20
> Signed-off-by: Benjamin Coddington <bcodding@redhat.com>
> ---
> fs/nfs/blocklayout/blocklayout.c | 3 +++
> fs/nfs/pnfs.c                    | 4 +---
> 2 files changed, 4 insertions(+), 3 deletions(-)
>=20
> diff --git a/fs/nfs/blocklayout/blocklayout.c b/fs/nfs/blocklayout/blockl=
ayout.c
> index 17a42e4eb872..36923b55f4f8 100644
> --- a/fs/nfs/blocklayout/blocklayout.c
> +++ b/fs/nfs/blocklayout/blocklayout.c
> @@ -343,8 +343,11 @@ static void bl_write_cleanup(struct work_struct *wor=
k)
> =09=09u64 end =3D (hdr->args.offset + hdr->args.count +
> =09=09=09PAGE_SIZE - 1) & (loff_t)PAGE_MASK;
>=20
> +=09=09spin_lock(&hdr->inode->i_lock);
> +=09=09bl->bl_layout.plh_lwb =3D hdr->args.offset + hdr->res.count;
> =09=09ext_tree_mark_written(bl, start >> SECTOR_SHIFT,
> =09=09=09=09=09(end - start) >> SECTOR_SHIFT);
> +=09=09spin_unlock(&hdr->inode->i_lock);
> =09}
>=20
> =09pnfs_ld_write_done(hdr);
> diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
> index 4110c1dc8f68..978df68c498c 100644
> --- a/fs/nfs/pnfs.c
> +++ b/fs/nfs/pnfs.c
> @@ -2386,7 +2386,6 @@ pnfs_layoutcommit_inode(struct inode *inode, bool s=
ync)
> =09end_pos =3D nfsi->layout->plh_lwb;
>=20
> =09nfs4_stateid_copy(&data->args.stateid, &nfsi->layout->plh_stateid);
> -=09spin_unlock(&inode->i_lock);
>=20
> =09data->args.inode =3D inode;
> =09data->cred =3D get_rpccred(nfsi->layout->plh_lc_cred);
> @@ -2403,14 +2402,13 @@ pnfs_layoutcommit_inode(struct inode *inode, bool=
 sync)
> =09=09status =3D ld->prepare_layoutcommit(&data->args);

Doesn=92t ext_tree_prepare_commit() contain a GFP_NOFS allocation that coul=
d sleep?

> =09=09if (status) {
> =09=09=09put_rpccred(data->cred);
> -=09=09=09spin_lock(&inode->i_lock);
> =09=09=09set_bit(NFS_INO_LAYOUTCOMMIT, &nfsi->flags);
> =09=09=09if (end_pos > nfsi->layout->plh_lwb)
> =09=09=09=09nfsi->layout->plh_lwb =3D end_pos;
> =09=09=09goto out_unlock;
> =09=09}
> =09}
> -
> +=09spin_unlock(&inode->i_lock);
>=20
> =09status =3D nfs4_proc_layoutcommit(data, sync);
> out:
> --=20
> 2.5.5
>=20
