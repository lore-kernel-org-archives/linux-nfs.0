From: "William A. (Andy) Adamson" <androsadamson@gmail.com>
Subject: Re: [pnfs] [PATCH 1/3] SQUASHME pnfs_submit: generic device ID cache
Date: Mon, 3 May 2010 09:57:57 -0400
Message-ID: <o2j89c397151005030657h111fd2afnac57ba73b97011d2@mail.gmail.com>
References: <1272298699-11411-1-git-send-email-andros@netapp.com>
	 <1272298699-11411-2-git-send-email-andros@netapp.com>
	 <4BDEB815.6030200@panasas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: linux-nfs@vger.kernel.org
To: Benny Halevy <bhalevy@panasas.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-gw0-f46.google.com ([74.125.83.46]:44487 "EHLO
	mail-gw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759395Ab0ECN57 convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 3 May 2010 09:57:59 -0400
Received: by gwj19 with SMTP id 19so1113896gwj.19
        for <linux-nfs@vger.kernel.org>; Mon, 03 May 2010 06:57:58 -0700 (PDT)
In-Reply-To: <4BDEB815.6030200@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, May 3, 2010 at 7:48 AM, Benny Halevy <bhalevy@panasas.com> wrot=
e:
> On Apr. 26, 2010, 19:18 +0300, andros@netapp.com wrote:
>> From: Andy Adamson <andros@netapp.com>
>>
>> A shared RCU device ID cache servicing multiple mounts of a single l=
ayout type
>> per meta data server (struct nfs_client).
>>
>> Device IDs of type deviceid4 are required by all layout types, long =
lived and
>> read at each I/O. =A0They are added to the deviceid cache at first r=
eference by
>> a layout via GETDEVICEINFO and (currently) are only removed at umoun=
t.
>>
>> Reference count the device ID cache for each mounted file system
>> in the initialize_mountpoint layoutdriver_io_operation.
>>
>> Dereference the device id cache on file system in the uninitialize_m=
ountpoint
>> layoutdriver_io_operation called at umount
>>
>> Each layoutsegment assigns a pointer and takes a reference to the
>> nfs4_deviceid structure identified by the layout deviceid.
>> This is so that there are no deviceid lookups for the normal I/O pat=
h.
>>
>> Even thought required by all layouttypes, the deviceid is not expose=
d in the
>> LAYOUTGET4res but is instead hidden in the opaque layouttype4.
>>
>> Therefore, each layout type alloc_lseg calls nfs4_set_layout_devicei=
d,
>> and free_lseg calls nfs4_unset_layout_deviceid.
>>
>> While the file layout driver will not cache very many deviceid's, th=
e object
>> and block layout drivers could cache 100's for a large installation.
>> Use an hlist.
>>
>> Signed-off-by: Andy Adamson <andros@netapp.com>
>> ---
>> =A0fs/nfs/pnfs.c =A0 =A0 =A0 =A0 =A0 =A0 | =A0167 ++++++++++++++++++=
+++++++++++++++++++++++++++
>> =A0include/linux/nfs4_pnfs.h | =A0 50 +++++++++++++
>> =A0include/linux/nfs_fs_sb.h | =A0 =A01 +
>> =A03 files changed, 218 insertions(+), 0 deletions(-)
>>
>> diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
>> index 91572aa..bf906cc 100644
>> --- a/fs/nfs/pnfs.c
>> +++ b/fs/nfs/pnfs.c
>> @@ -45,6 +45,7 @@
>> =A0#include <linux/nfs4.h>
>> =A0#include <linux/pnfs_xdr.h>
>> =A0#include <linux/nfs4_pnfs.h>
>> +#include <linux/rculist.h>
>>
>> =A0#include "internal.h"
>> =A0#include "nfs4_fs.h"
>> @@ -2296,3 +2297,169 @@ struct pnfs_client_operations pnfs_ops =3D {
>>
>> =A0EXPORT_SYMBOL(pnfs_unregister_layoutdriver);
>> =A0EXPORT_SYMBOL(pnfs_register_layoutdriver);
>> +
>> +
>> +/* Device ID cache. Supports one layout type per struct nfs_client =
*/
>> +int
>> +nfs4_alloc_init_deviceid_cache(struct nfs_client *clp,
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0void (*free_callback)(s=
truct kref *))
>> +{
>> + =A0 =A0 struct nfs4_deviceid_cache *c;
>> +
>> + =A0 =A0 c =3D kzalloc(sizeof(struct nfs4_deviceid_cache), GFP_KERN=
EL);
>> + =A0 =A0 if (!c)
>> + =A0 =A0 =A0 =A0 =A0 =A0 return -ENOMEM;
>> + =A0 =A0 spin_lock(&clp->cl_lock);
>> + =A0 =A0 if (clp->cl_devid_cache !=3D NULL) {
>> + =A0 =A0 =A0 =A0 =A0 =A0 kref_get(&clp->cl_devid_cache->dc_kref);
>> + =A0 =A0 =A0 =A0 =A0 =A0 spin_unlock(&clp->cl_lock);
>> + =A0 =A0 =A0 =A0 =A0 =A0 dprintk("%s [kref [%d]]\n", __func__,
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 atomic_read(&clp->cl_devid=
_cache->dc_kref.refcount));
>> + =A0 =A0 =A0 =A0 =A0 =A0 kfree(c);
>> + =A0 =A0 } else {
>> + =A0 =A0 =A0 =A0 =A0 =A0 int i;
>> +
>> + =A0 =A0 =A0 =A0 =A0 =A0 spin_lock_init(&c->dc_lock);
>> + =A0 =A0 =A0 =A0 =A0 =A0 for (i =3D 0; i < NFS4_DEVICE_ID_HASH_SIZE=
 ; i++)
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 INIT_HLIST_HEAD(&c->dc_dev=
iceids[i]);
>> + =A0 =A0 =A0 =A0 =A0 =A0 kref_init(&c->dc_kref);
>> + =A0 =A0 =A0 =A0 =A0 =A0 c->dc_free_callback =3D free_callback;
>> + =A0 =A0 =A0 =A0 =A0 =A0 clp->cl_devid_cache =3D c;
>> + =A0 =A0 =A0 =A0 =A0 =A0 spin_unlock(&clp->cl_lock);
>> + =A0 =A0 =A0 =A0 =A0 =A0 dprintk("%s [new]\n", __func__);
>> + =A0 =A0 }
>> + =A0 =A0 return 0;
>> +}
>> +EXPORT_SYMBOL(nfs4_alloc_init_deviceid_cache);
>> +
>> +void
>> +nfs4_init_deviceid_node(struct nfs4_deviceid *d)
>> +{
>> + =A0 =A0 INIT_HLIST_NODE(&d->de_node);
>> + =A0 =A0 kref_init(&d->de_kref);
>> +}
>> +EXPORT_SYMBOL(nfs4_init_deviceid_node);
>> +
>> +/* Called from layoutdriver_io_operations->alloc_lseg */
>> +void
>> +nfs4_set_layout_deviceid(struct pnfs_layout_segment *l, struct nfs4=
_deviceid *d)
>> +{
>> + =A0 =A0 dprintk("%s [%d]\n", __func__, atomic_read(&d->de_kref.ref=
count));
>> + =A0 =A0 l->deviceid =3D d;
>> + =A0 =A0 kref_get(&d->de_kref);
>> +}
>> +EXPORT_SYMBOL(nfs4_set_layout_deviceid);
>> +
>> +/* Called from layoutdriver_io_operations->free_lseg */
>> +void
>> +nfs4_unset_layout_deviceid(struct pnfs_layout_segment *l,
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0struct nfs4_devicei=
d *d,
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0void (*free_callbac=
k)(struct kref *))
>> +{
>> + =A0 =A0 dprintk("%s [%d]\n", __func__, atomic_read(&d->de_kref.ref=
count));
>> + =A0 =A0 l->deviceid =3D NULL;
>> + =A0 =A0 kref_put(&d->de_kref, free_callback);
>> +}
>> +EXPORT_SYMBOL(nfs4_unset_layout_deviceid);
>> +
>> +struct nfs4_deviceid *
>> +nfs4_find_deviceid(struct nfs4_deviceid_cache *c, struct pnfs_devic=
eid *id)
>> +{
>> + =A0 =A0 struct nfs4_deviceid *d;
>> + =A0 =A0 struct hlist_node *n;
>> + =A0 =A0 long hash =3D nfs4_deviceid_hash(id);
>> +
>> + =A0 =A0 dprintk("--> %s hash %ld\n", __func__, hash);
>> + =A0 =A0 rcu_read_lock();
>> + =A0 =A0 hlist_for_each_entry_rcu(d, n, &c->dc_deviceids[hash], de_=
node) {
>> + =A0 =A0 =A0 =A0 =A0 =A0 if (!memcmp(&d->de_id, id, NFS4_PNFS_DEVIC=
EID4_SIZE)) {
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 rcu_read_unlock();
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 return d;
>> + =A0 =A0 =A0 =A0 =A0 =A0 }
>> + =A0 =A0 }
>> + =A0 =A0 rcu_read_unlock();
>> + =A0 =A0 return NULL;
>> +}
>> +EXPORT_SYMBOL(nfs4_find_deviceid);
>> +
>> +/*
>> + * Add or kref_get a deviceid.
>> + * GETDEVICEINFOs for same deviceid can race. If deviceid is found,=
 discard new
>> + */
>> +struct nfs4_deviceid *
>> +nfs4_add_deviceid(struct nfs4_deviceid_cache *c, struct nfs4_device=
id *new)
>> +{
>> + =A0 =A0 struct nfs4_deviceid *d;
>> + =A0 =A0 struct hlist_node *n;
>> + =A0 =A0 long hash =3D nfs4_deviceid_hash(&new->de_id);
>> +
>> + =A0 =A0 dprintk("--> %s hash %ld\n", __func__, hash);
>> + =A0 =A0 spin_lock(&c->dc_lock);
>> + =A0 =A0 hlist_for_each_entry_rcu(d, n, &c->dc_deviceids[hash], de_=
node) {
>> + =A0 =A0 =A0 =A0 =A0 =A0 if (!memcmp(&d->de_id, &new->de_id, NFS4_P=
NFS_DEVICEID4_SIZE)) {
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 spin_unlock(&c->dc_lock);
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 dprintk("%s [discard]\n", =
__func__);
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 c->dc_free_callback(&new->=
de_kref);
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 return d;
>> + =A0 =A0 =A0 =A0 =A0 =A0 }
>> + =A0 =A0 }
>> + =A0 =A0 hlist_add_head_rcu(&new->de_node, &c->dc_deviceids[hash]);
>> + =A0 =A0 spin_unlock(&c->dc_lock);
>> + =A0 =A0 dprintk("%s [new]\n", __func__);
>> + =A0 =A0 return new;
>> +}
>> +EXPORT_SYMBOL(nfs4_add_deviceid);
>> +
>> +static int
>> +nfs4_remove_deviceid(struct nfs4_deviceid_cache *c, long hash)
>> +{
>> + =A0 =A0 struct nfs4_deviceid *d;
>> + =A0 =A0 struct hlist_node *n;
>> +
>> + =A0 =A0 dprintk("--> %s hash %ld\n", __func__, hash);
>> + =A0 =A0 spin_lock(&c->dc_lock);
>> + =A0 =A0 hlist_for_each_entry_rcu(d, n, &c->dc_deviceids[hash], de_=
node) {
>> + =A0 =A0 =A0 =A0 =A0 =A0 hlist_del_rcu(&d->de_node);
>> + =A0 =A0 =A0 =A0 =A0 =A0 spin_unlock(&c->dc_lock);
>> + =A0 =A0 =A0 =A0 =A0 =A0 synchronize_rcu();
>> + =A0 =A0 =A0 =A0 =A0 =A0 dprintk("%s [%d]\n", __func__,
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 atomic_read(&d->de_kref.re=
fcount));
>> + =A0 =A0 =A0 =A0 =A0 =A0 kref_put(&d->de_kref, c->dc_free_callback)=
;
>> + =A0 =A0 =A0 =A0 =A0 =A0 return 1;
>> + =A0 =A0 }
>> + =A0 =A0 spin_unlock(&c->dc_lock);
>> + =A0 =A0 return 0;
>> +}
>> +
>> +static void
>> +nfs4_free_deviceid_cache(struct kref *kref)
>> +{
>> + =A0 =A0 struct nfs4_deviceid_cache *cache =3D
>> + =A0 =A0 =A0 =A0 =A0 =A0 container_of(kref, struct nfs4_deviceid_ca=
che, dc_kref);
>> + =A0 =A0 int more;
>> + =A0 =A0 long i;
>> +
>> + =A0 =A0 for (i =3D 0; i < NFS4_DEVICE_ID_HASH_SIZE; i++) {
>> + =A0 =A0 =A0 =A0 =A0 =A0 more =3D 1;
>> + =A0 =A0 =A0 =A0 =A0 =A0 while (more)
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 more =3D nfs4_remove_devic=
eid(cache, i);
>
> Andy, this can be simplified to
>
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0while (nfs4_remove_deviceid(cache, i))
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0;
>
> If ok with you, I'll make this change upon merging.

Yes - looks fine, thanks.

-->Andy

>
> Benny
>
>> + =A0 =A0 }
>> + =A0 =A0 kfree(cache);
>> +}
>> +
>> +void
>> +nfs4_put_deviceid_cache(struct nfs_client *clp)
>> +{
>> + =A0 =A0 struct nfs4_deviceid_cache *tmp =3D clp->cl_devid_cache;
>> + =A0 =A0 int refcount;
>> +
>> + =A0 =A0 dprintk("--> %s cl_devid_cache %p\n", __func__, clp->cl_de=
vid_cache);
>> + =A0 =A0 spin_lock(&clp->cl_lock);
>> + =A0 =A0 refcount =3D atomic_read(&clp->cl_devid_cache->dc_kref.ref=
count);
>> + =A0 =A0 if (refcount =3D=3D 1)
>> + =A0 =A0 =A0 =A0 =A0 =A0 clp->cl_devid_cache =3D NULL;
>> + =A0 =A0 spin_unlock(&clp->cl_lock);
>> + =A0 =A0 dprintk("%s [%d]\n", __func__, refcount);
>> + =A0 =A0 kref_put(&tmp->dc_kref, nfs4_free_deviceid_cache);
>> +}
>> +EXPORT_SYMBOL(nfs4_put_deviceid_cache);
>> diff --git a/include/linux/nfs4_pnfs.h b/include/linux/nfs4_pnfs.h
>> index 3caac60..3b7aeb7 100644
>> --- a/include/linux/nfs4_pnfs.h
>> +++ b/include/linux/nfs4_pnfs.h
>> @@ -106,6 +106,7 @@ struct pnfs_layout_segment {
>> =A0 =A0 =A0 struct kref kref;
>> =A0 =A0 =A0 bool valid;
>> =A0 =A0 =A0 struct pnfs_layout_type *layout;
>> + =A0 =A0 struct nfs4_deviceid *deviceid;
>> =A0 =A0 =A0 u8 ld_data[]; =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* lay=
out driver private data */
>> =A0};
>>
>> @@ -275,6 +276,55 @@ struct pnfs_devicelist {
>> =A0 =A0 =A0 struct pnfs_deviceid =A0 =A0dev_id[NFS4_PNFS_GETDEVLIST_=
MAXNUM];
>> =A0};
>>
>> +/*
>> + * Device ID RCU cache. A device ID is unique per client ID and lay=
out type.
>> + */
>> +#define NFS4_DEVICE_ID_HASH_BITS =A0 =A0 5
>> +#define NFS4_DEVICE_ID_HASH_SIZE =A0 =A0 (1 << NFS4_DEVICE_ID_HASH_=
BITS)
>> +#define NFS4_DEVICE_ID_HASH_MASK =A0 =A0 (NFS4_DEVICE_ID_HASH_SIZE =
- 1)
>> +
>> +static inline u32
>> +nfs4_deviceid_hash(struct pnfs_deviceid *id)
>> +{
>> + =A0 =A0 unsigned char *cptr =3D (unsigned char *)id->data;
>> + =A0 =A0 unsigned int nbytes =3D NFS4_PNFS_DEVICEID4_SIZE;
>> + =A0 =A0 u32 x =3D 0;
>> +
>> + =A0 =A0 while (nbytes--) {
>> + =A0 =A0 =A0 =A0 =A0 =A0 x *=3D 37;
>> + =A0 =A0 =A0 =A0 =A0 =A0 x +=3D *cptr++;
>> + =A0 =A0 }
>> + =A0 =A0 return x & NFS4_DEVICE_ID_HASH_MASK;
>> +}
>> +
>> +struct nfs4_deviceid_cache {
>> + =A0 =A0 spinlock_t =A0 =A0 =A0 =A0 =A0 =A0 =A0dc_lock;
>> + =A0 =A0 struct kref =A0 =A0 =A0 =A0 =A0 =A0 dc_kref;
>> + =A0 =A0 void =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0(*dc_free_call=
back)(struct kref *);
>> + =A0 =A0 struct hlist_head =A0 =A0 =A0 dc_deviceids[NFS4_DEVICE_ID_=
HASH_SIZE];
>> +};
>> +
>> +/* Device ID cache node */
>> +struct nfs4_deviceid {
>> + =A0 =A0 struct hlist_node =A0 =A0 =A0 de_node;
>> + =A0 =A0 struct pnfs_deviceid =A0 =A0de_id;
>> + =A0 =A0 struct kref =A0 =A0 =A0 =A0 =A0 =A0 de_kref;
>> +};
>> +
>> +extern int nfs4_alloc_init_deviceid_cache(struct nfs_client *,
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 void (*fre=
e_callback)(struct kref *));
>> +extern void nfs4_put_deviceid_cache(struct nfs_client *);
>> +extern void nfs4_init_deviceid_node(struct nfs4_deviceid *);
>> +extern struct nfs4_deviceid *nfs4_find_deviceid(struct nfs4_devicei=
d_cache *,
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 struct pnf=
s_deviceid *);
>> +extern struct nfs4_deviceid *nfs4_add_deviceid(struct nfs4_deviceid=
_cache *,
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 struct nfs=
4_deviceid *);
>> +extern void nfs4_set_layout_deviceid(struct pnfs_layout_segment *,
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 struct nfs=
4_deviceid *);
>> +extern void nfs4_unset_layout_deviceid(struct pnfs_layout_segment *=
,
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 struct nfs=
4_deviceid *,
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 void (*fre=
e_callback)(struct kref *));
>> +
>> =A0/* pNFS client callback functions.
>> =A0 * These operations allow the layout driver to access pNFS client
>> =A0 * specific information or call pNFS client->server operations.
>> diff --git a/include/linux/nfs_fs_sb.h b/include/linux/nfs_fs_sb.h
>> index 8522461..ef2e18e 100644
>> --- a/include/linux/nfs_fs_sb.h
>> +++ b/include/linux/nfs_fs_sb.h
>> @@ -87,6 +87,7 @@ struct nfs_client {
>> =A0 =A0 =A0 u32 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 cl_exchange_=
flags;
>> =A0 =A0 =A0 struct nfs4_session =A0 =A0 *cl_session; =A0 =A0/* sharr=
ed session */
>> =A0 =A0 =A0 struct list_head =A0 =A0 =A0 =A0cl_lo_inodes; =A0 /* Ino=
des having layouts */
>> + =A0 =A0 struct nfs4_deviceid_cache *cl_devid_cache; /* pNFS device=
id cache */
>> =A0#endif /* CONFIG_NFS_V4_1 */
>>
>> =A0#ifdef CONFIG_NFS_FSCACHE
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" =
in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at =A0http://vger.kernel.org/majordomo-info.html
>
