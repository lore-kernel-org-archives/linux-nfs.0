From: "William A. (Andy) Adamson" <androsadamson@gmail.com>
Subject: Re: [PATCH 1/3] SQUASHME pnfs_submit: generic device ID cache
Date: Fri, 16 Apr 2010 12:04:54 -0400
Message-ID: <u2n89c397151004160904m9e862360xcaf0e187640b0177@mail.gmail.com>
References: <1271433175-4631-1-git-send-email-andros@netapp.com>
	 <1271433175-4631-2-git-send-email-andros@netapp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: linux-nfs@vger.kernel.org, Andy Adamson <andros@netapp.com>
To: pnfs@linux-nfs.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-gy0-f174.google.com ([209.85.160.174]:41842 "EHLO
	mail-gy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756615Ab0DPQE4 convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 16 Apr 2010 12:04:56 -0400
Received: by gyg13 with SMTP id 13so1426088gyg.19
        for <linux-nfs@vger.kernel.org>; Fri, 16 Apr 2010 09:04:54 -0700 (PDT)
In-Reply-To: <1271433175-4631-2-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Apr 16, 2010 at 11:52 AM,  <andros@netapp.com> wrote:
> From: Andy Adamson <andros@netapp.com>
>
> A shared RCU device ID cache servicing multiple mounts of a single la=
yout type
> per meta data server (struct nfs_client).
>
> Device IDs of type deviceid4 are required by all layout types, long l=
ived and
> read at each I/O. =A0They are added to the deviceid cache at first re=
ference by
> a layout via GETDEVICEINFO and (currently) are only removed at umount=
=2E
>
> Reference count the device ID cache for each mounted file system
> in the initialize_mountpoint layoutdriver_io_operation.
>
> Dereference the device id cache on file system in the uninitialize_mo=
untpoint
> layoutdriver_io_operation called at umount
>
> Signed-off-by: Andy Adamson <andros@netapp.com>
> ---
> =A0fs/nfs/pnfs.c =A0 =A0 =A0 =A0 =A0 =A0 | =A0119 +++++++++++++++++++=
++++++++++++++++++++++++++
> =A0include/linux/nfs4_pnfs.h | =A0 27 ++++++++++
> =A0include/linux/nfs_fs_sb.h | =A0 =A01 +
> =A03 files changed, 147 insertions(+), 0 deletions(-)
>
> diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
> index 91572aa..8492aef 100644
> --- a/fs/nfs/pnfs.c
> +++ b/fs/nfs/pnfs.c
> @@ -45,6 +45,7 @@
> =A0#include <linux/nfs4.h>
> =A0#include <linux/pnfs_xdr.h>
> =A0#include <linux/nfs4_pnfs.h>
> +#include <linux/rculist.h>
>
> =A0#include "internal.h"
> =A0#include "nfs4_fs.h"
> @@ -2296,3 +2297,121 @@ struct pnfs_client_operations pnfs_ops =3D {
>
> =A0EXPORT_SYMBOL(pnfs_unregister_layoutdriver);
> =A0EXPORT_SYMBOL(pnfs_register_layoutdriver);
> +
> +
> +/* Device ID cache. Supports one layout type per struct nfs_client *=
/
> +int
> +nfs4_alloc_init_deviceid_cache(struct nfs_client *clp,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0void (*free_callback=
)(struct rcu_head *))
> +{
> + =A0 =A0 =A0 struct nfs4_deviceid_cache *c;
> +
> + =A0 =A0 =A0 c =3D kzalloc(sizeof(struct nfs4_deviceid_cache), GFP_K=
ERNEL);
> + =A0 =A0 =A0 if (!c)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return -ENOMEM;
> + =A0 =A0 =A0 spin_lock(&clp->cl_lock);
> + =A0 =A0 =A0 if (clp->cl_devid_cache !=3D NULL) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 kref_get(&clp->cl_devid_cache->dc_kref)=
;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 spin_unlock(&clp->cl_lock);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 dprintk("%s [kref [%d]]\n", __func__,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 atomic_read(&clp->cl_de=
vid_cache->dc_kref.refcount));
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 kfree(c);
> + =A0 =A0 =A0 } else {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 spin_lock_init(&c->dc_lock);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 INIT_LIST_HEAD(&c->dc_deviceids);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 kref_init(&c->dc_kref);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 c->dc_free_callback =3D free_callback;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 c->dc_clp =3D clp;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 clp->cl_devid_cache =3D c;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 spin_unlock(&clp->cl_lock);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 dprintk("%s [new]\n", __func__);
> + =A0 =A0 =A0 }
> + =A0 =A0 =A0 return 0;
> +}
> +EXPORT_SYMBOL(nfs4_alloc_init_deviceid_cache);
> +
> +void
> +nfs4_init_deviceid_node(struct nfs4_deviceid *d)
> +{
> + =A0 =A0 =A0 INIT_LIST_HEAD(&d->de_node);
> + =A0 =A0 =A0 INIT_RCU_HEAD(&d->de_rcu);
> +}
> +EXPORT_SYMBOL(nfs4_init_deviceid_node);
> +
> +struct nfs4_deviceid *
> +nfs4_find_deviceid(struct nfs4_deviceid_cache *c, struct pnfs_device=
id *id)
> +{
> + =A0 =A0 =A0 struct nfs4_deviceid *d;
> +
> + =A0 =A0 =A0 rcu_read_lock();
> + =A0 =A0 =A0 list_for_each_entry_rcu(d, &c->dc_deviceids, de_node) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (!memcmp(&d->de_id, id, NFS4_PNFS_DE=
VICEID4_SIZE)) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 rcu_read_unlock();
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 return d;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
> + =A0 =A0 =A0 }
> + =A0 =A0 =A0 rcu_read_unlock();
> + =A0 =A0 =A0 return NULL;
> +}
> +EXPORT_SYMBOL(nfs4_find_deviceid);
> +
> +/*
> + * Add or kref_get a deviceid.
> + * GETDEVICEINFOs for same deviceid can race. If deviceid is found, =
discard new
> + */
> +void
> +nfs4_add_deviceid(struct nfs4_deviceid_cache *c, struct nfs4_devicei=
d *new)
> +{
> + =A0 =A0 =A0 struct nfs4_deviceid *d;
> +
> + =A0 =A0 =A0 spin_lock(&c->dc_lock);
> + =A0 =A0 =A0 list_for_each_entry_rcu(d, &c->dc_deviceids, de_node) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (!memcmp(&d->de_id, &new->de_id, NFS=
4_PNFS_DEVICEID4_SIZE)) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 spin_unlock(&c->dc_lock=
);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 dprintk("%s [discard]\n=
", __func__);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 c->dc_free_callback(&ne=
w->de_rcu);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
> + =A0 =A0 =A0 }
> + =A0 =A0 =A0 list_add_rcu(&new->de_node, &c->dc_deviceids);
> + =A0 =A0 =A0 spin_unlock(&c->dc_lock);
> + =A0 =A0 =A0 dprintk("%s [new]\n", __func__);
> +}
> +EXPORT_SYMBOL(nfs4_add_deviceid);
> +
> +static int
> +nfs4_remove_deviceid(struct nfs4_deviceid_cache *c)
> +{
> + =A0 =A0 =A0 struct nfs4_deviceid *d;
> +
> + =A0 =A0 =A0 spin_lock(&c->dc_lock);
> + =A0 =A0 =A0 list_for_each_entry_rcu(d, &c->dc_deviceids, de_node) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 list_del_rcu(&d->de_node);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 spin_unlock(&c->dc_lock);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 synchronize_rcu();
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 c->dc_free_callback(&d->de_rcu);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return 1;
> + =A0 =A0 =A0 }
> + =A0 =A0 =A0 spin_unlock(&c->dc_lock);
> + =A0 =A0 =A0 return 0;
> +}
> +
> +static void
> +nfs4_free_deviceid_cache(struct kref *kref)
> +{
> + =A0 =A0 =A0 struct nfs4_deviceid_cache *cache =3D
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 container_of(kref, struct nfs4_deviceid=
_cache, dc_kref);
> + =A0 =A0 =A0 int more =3D 1;
> +
> + =A0 =A0 =A0 while (more)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 more =3D nfs4_remove_deviceid(cache);
> + =A0 =A0 =A0 cache->dc_clp->cl_devid_cache =3D NULL;

Need to take the cl_lock around this assignment

spin_lock(&cache->dc_clp->cl_lock);
cache->dc_clp->cl_devid_cache =3D NULL
spin_unlock(&cache->dc_clp->cl_lock);


> + =A0 =A0 =A0 kfree(cache);
> +}
> +
> +void
> +nfs4_put_deviceid_cache(struct nfs4_deviceid_cache *c)
> +{
> + =A0 =A0 =A0 dprintk("%s [%d]\n", __func__, atomic_read(&c->dc_kref.=
refcount));
> + =A0 =A0 =A0 kref_put(&c->dc_kref, nfs4_free_deviceid_cache);
> +}
> +EXPORT_SYMBOL(nfs4_put_deviceid_cache);
> diff --git a/include/linux/nfs4_pnfs.h b/include/linux/nfs4_pnfs.h
> index 1d521f4..2a88a06 100644
> --- a/include/linux/nfs4_pnfs.h
> +++ b/include/linux/nfs4_pnfs.h
> @@ -281,6 +281,33 @@ struct pnfs_devicelist {
> =A0 =A0 =A0 =A0struct pnfs_deviceid =A0 =A0dev_id[NFS4_PNFS_GETDEVLIS=
T_MAXNUM];
> =A0};
>
> +/*
> + * Device ID RCU cache. A device ID is unique per client ID and layo=
ut type.
> + */
> +struct nfs4_deviceid_cache {
> + =A0 =A0 =A0 spinlock_t =A0 =A0 =A0 =A0 =A0 =A0 =A0dc_lock;
> + =A0 =A0 =A0 struct list_head =A0 =A0 =A0 =A0dc_deviceids;
> + =A0 =A0 =A0 struct kref =A0 =A0 =A0 =A0 =A0 =A0 dc_kref;
> + =A0 =A0 =A0 void =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0(*dc_free_c=
allback)(struct rcu_head *);
> + =A0 =A0 =A0 struct nfs_client =A0 =A0 =A0 *dc_clp;
> +};
> +
> +/* Device ID cache node */
> +struct nfs4_deviceid {
> + =A0 =A0 =A0 struct list_head =A0 =A0 =A0 =A0de_node;
> + =A0 =A0 =A0 struct rcu_head =A0 =A0 =A0 =A0 de_rcu;
> + =A0 =A0 =A0 struct pnfs_deviceid =A0 =A0de_id;
> +};
> +
> +extern int nfs4_alloc_init_deviceid_cache(struct nfs_client *,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 void (*=
free_callback)(struct rcu_head *));
> +extern void nfs4_put_deviceid_cache(struct nfs4_deviceid_cache *);
> +extern void nfs4_init_deviceid_node(struct nfs4_deviceid *);
> +extern struct nfs4_deviceid *nfs4_find_deviceid(struct nfs4_deviceid=
_cache *,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 struct =
pnfs_deviceid *);
> +extern void nfs4_add_deviceid(struct nfs4_deviceid_cache *,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 struct =
nfs4_deviceid *);
> +
> =A0/* pNFS client callback functions.
> =A0* These operations allow the layout driver to access pNFS client
> =A0* specific information or call pNFS client->server operations.
> diff --git a/include/linux/nfs_fs_sb.h b/include/linux/nfs_fs_sb.h
> index 8522461..ef2e18e 100644
> --- a/include/linux/nfs_fs_sb.h
> +++ b/include/linux/nfs_fs_sb.h
> @@ -87,6 +87,7 @@ struct nfs_client {
> =A0 =A0 =A0 =A0u32 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 cl_exchang=
e_flags;
> =A0 =A0 =A0 =A0struct nfs4_session =A0 =A0 *cl_session; =A0 =A0/* sha=
rred session */
> =A0 =A0 =A0 =A0struct list_head =A0 =A0 =A0 =A0cl_lo_inodes; =A0 /* I=
nodes having layouts */
> + =A0 =A0 =A0 struct nfs4_deviceid_cache *cl_devid_cache; /* pNFS dev=
iceid cache */
> =A0#endif /* CONFIG_NFS_V4_1 */
>
> =A0#ifdef CONFIG_NFS_FSCACHE
> --
> 1.6.6
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" =
in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at =A0http://vger.kernel.org/majordomo-info.html
>
