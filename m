From: "William A. (Andy) Adamson" <androsadamson@gmail.com>
Subject: Re: [pnfs] [PATCH 1/3] SQUASHME pnfs_submit: generic device ID cache
Date: Thu, 22 Apr 2010 11:47:02 -0400
Message-ID: <v2h89c397151004220847v3a31c493s4089d0cd53cf3e19@mail.gmail.com>
References: <1271433175-4631-1-git-send-email-andros@netapp.com>
	 <1271433175-4631-2-git-send-email-andros@netapp.com>
	 <u2n89c397151004160904m9e862360xcaf0e187640b0177@mail.gmail.com>
	 <4BCE9456.4080904@panasas.com>
	 <l2l89c397151004210822j8b43009o3a9e78ceed901fd9@mail.gmail.com>
	 <4BD03108.5010205@panasas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: pnfs@linux-nfs.org, linux-nfs@vger.kernel.org
To: Benny Halevy <bhalevy@panasas.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-gy0-f174.google.com ([209.85.160.174]:65157 "EHLO
	mail-gy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755433Ab0DVPrI convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 22 Apr 2010 11:47:08 -0400
Received: by gyg13 with SMTP id 13so4521386gyg.19
        for <linux-nfs@vger.kernel.org>; Thu, 22 Apr 2010 08:47:02 -0700 (PDT)
In-Reply-To: <4BD03108.5010205@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Apr 22, 2010 at 7:20 AM, Benny Halevy <bhalevy@panasas.com> wro=
te:
> On Apr. 21, 2010, 18:22 +0300, "William A. (Andy) Adamson" <androsada=
mson@gmail.com> wrote:
>> On Wed, Apr 21, 2010 at 1:59 AM, Benny Halevy <bhalevy@panasas.com> =
wrote:
>>> On Apr. 16, 2010, 19:04 +0300, "William A. (Andy) Adamson" <androsa=
damson@gmail.com> wrote:
>>>> On Fri, Apr 16, 2010 at 11:52 AM, =A0<andros@netapp.com> wrote:
>>>>> From: Andy Adamson <andros@netapp.com>
>>>>>
>>>>> A shared RCU device ID cache servicing multiple mounts of a singl=
e layout type
>>>>> per meta data server (struct nfs_client).
>>>>>
>>>>> Device IDs of type deviceid4 are required by all layout types, lo=
ng lived and
>>>>> read at each I/O. =A0They are added to the deviceid cache at firs=
t reference by
>>>>> a layout via GETDEVICEINFO and (currently) are only removed at um=
ount.
>>>>>
>>>>> Reference count the device ID cache for each mounted file system
>>>>> in the initialize_mountpoint layoutdriver_io_operation.
>>>>>
>>>>> Dereference the device id cache on file system in the uninitializ=
e_mountpoint
>>>>> layoutdriver_io_operation called at umount
>>>>>
>>>>> Signed-off-by: Andy Adamson <andros@netapp.com>
>>>>> ---
>>>>> =A0fs/nfs/pnfs.c =A0 =A0 =A0 =A0 =A0 =A0 | =A0119 +++++++++++++++=
++++++++++++++++++++++++++++++
>>>>> =A0include/linux/nfs4_pnfs.h | =A0 27 ++++++++++
>>>>> =A0include/linux/nfs_fs_sb.h | =A0 =A01 +
>>>>> =A03 files changed, 147 insertions(+), 0 deletions(-)
>>>>>
>>>>> diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
>>>>> index 91572aa..8492aef 100644
>>>>> --- a/fs/nfs/pnfs.c
>>>>> +++ b/fs/nfs/pnfs.c
>>>>> @@ -45,6 +45,7 @@
>>>>> =A0#include <linux/nfs4.h>
>>>>> =A0#include <linux/pnfs_xdr.h>
>>>>> =A0#include <linux/nfs4_pnfs.h>
>>>>> +#include <linux/rculist.h>
>>>>>
>>>>> =A0#include "internal.h"
>>>>> =A0#include "nfs4_fs.h"
>>>>> @@ -2296,3 +2297,121 @@ struct pnfs_client_operations pnfs_ops =3D=
 {
>>>>>
>>>>> =A0EXPORT_SYMBOL(pnfs_unregister_layoutdriver);
>>>>> =A0EXPORT_SYMBOL(pnfs_register_layoutdriver);
>>>>> +
>>>>> +
>>>>> +/* Device ID cache. Supports one layout type per struct nfs_clie=
nt */
>>>>> +int
>>>>> +nfs4_alloc_init_deviceid_cache(struct nfs_client *clp,
>>>>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0void (*free_call=
back)(struct rcu_head *))
>>>>> +{
>>>>> + =A0 =A0 =A0 struct nfs4_deviceid_cache *c;
>>>>> +
>>>>> + =A0 =A0 =A0 c =3D kzalloc(sizeof(struct nfs4_deviceid_cache), G=
=46P_KERNEL);
>>>>> + =A0 =A0 =A0 if (!c)
>>>>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return -ENOMEM;
>>>>> + =A0 =A0 =A0 spin_lock(&clp->cl_lock);
>>>>> + =A0 =A0 =A0 if (clp->cl_devid_cache !=3D NULL) {
>>>>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 kref_get(&clp->cl_devid_cache->dc_k=
ref);
>>>>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 spin_unlock(&clp->cl_lock);
>>>>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 dprintk("%s [kref [%d]]\n", __func_=
_,
>>>>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 atomic_read(&clp->c=
l_devid_cache->dc_kref.refcount));
>>>>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 kfree(c);
>>>>> + =A0 =A0 =A0 } else {
>>>>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 spin_lock_init(&c->dc_lock);
>>>>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 INIT_LIST_HEAD(&c->dc_deviceids);
>>>>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 kref_init(&c->dc_kref);
>>>>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 c->dc_free_callback =3D free_callba=
ck;
>>>>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 c->dc_clp =3D clp;
>>>>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 clp->cl_devid_cache =3D c;
>>>>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 spin_unlock(&clp->cl_lock);
>>>>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 dprintk("%s [new]\n", __func__);
>>>>> + =A0 =A0 =A0 }
>>>>> + =A0 =A0 =A0 return 0;
>>>>> +}
>>>>> +EXPORT_SYMBOL(nfs4_alloc_init_deviceid_cache);
>>>>> +
>>>>> +void
>>>>> +nfs4_init_deviceid_node(struct nfs4_deviceid *d)
>>>>> +{
>>>>> + =A0 =A0 =A0 INIT_LIST_HEAD(&d->de_node);
>>>>> + =A0 =A0 =A0 INIT_RCU_HEAD(&d->de_rcu);
>>>>> +}
>>>>> +EXPORT_SYMBOL(nfs4_init_deviceid_node);
>>>>> +
>>>>> +struct nfs4_deviceid *
>>>>> +nfs4_find_deviceid(struct nfs4_deviceid_cache *c, struct pnfs_de=
viceid *id)
>>>>> +{
>>>>> + =A0 =A0 =A0 struct nfs4_deviceid *d;
>>>>> +
>>>>> + =A0 =A0 =A0 rcu_read_lock();
>>>>> + =A0 =A0 =A0 list_for_each_entry_rcu(d, &c->dc_deviceids, de_nod=
e) {
>>>>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (!memcmp(&d->de_id, id, NFS4_PNF=
S_DEVICEID4_SIZE)) {
>>>>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 rcu_read_unlock();
>>>>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 return d;
>>>>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
>>>>> + =A0 =A0 =A0 }
>>>>> + =A0 =A0 =A0 rcu_read_unlock();
>>>
>>> I hope this is worth the added complexity...
>>>
>>> Out of curiosity, do you have a benchmark comparing the cost
>>> of rcu_read_lock (and unlock) vs. spin_lock(&c->dc_lock)?
>>
>> The deviceid cache is read at each I/O. If we use a spin_lock to
>
> Yeah, I see where this goes...
> In the objects layout driver we get a reference on the device structu=
re
> at alloc_lseg time and keep a pointer to it throughout the lseg's lif=
e time.
> This saves the deviceid lookup on every I/O.

Perhaps that is a better way to go. How many deviceid's is 'normal'
for the object driver?

-->Andy


>
> Benny
>
>> protect the deviceid cache, this would mean that all I/0 is serializ=
ed
>> behind the spin_lock even though the deviceid cache is changed
>> infrequently. The RCU allows readers to "run almost naked" and does
>> not serialize I/O behind reading the deviceid cache.
>>
>> So I think it is worth it. I have not benchmarked the difference.
>>
>>
>>>
>>>>> + =A0 =A0 =A0 return NULL;
>>>>> +}
>>>>> +EXPORT_SYMBOL(nfs4_find_deviceid);
>>>>> +
>>>>> +/*
>>>>> + * Add or kref_get a deviceid.
>>>>> + * GETDEVICEINFOs for same deviceid can race. If deviceid is fou=
nd, discard new
>>>>> + */
>>>>> +void
>>>>> +nfs4_add_deviceid(struct nfs4_deviceid_cache *c, struct nfs4_dev=
iceid *new)
>>>>> +{
>>>>> + =A0 =A0 =A0 struct nfs4_deviceid *d;
>>>>> +
>>>>> + =A0 =A0 =A0 spin_lock(&c->dc_lock);
>>>>> + =A0 =A0 =A0 list_for_each_entry_rcu(d, &c->dc_deviceids, de_nod=
e) {
>>>>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (!memcmp(&d->de_id, &new->de_id,=
 NFS4_PNFS_DEVICEID4_SIZE)) {
>>>>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 spin_unlock(&c->dc_=
lock);
>>>>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 dprintk("%s [discar=
d]\n", __func__);
>>>>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 c->dc_free_callback=
(&new->de_rcu);
>>>>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
>>>>> + =A0 =A0 =A0 }
>>>>> + =A0 =A0 =A0 list_add_rcu(&new->de_node, &c->dc_deviceids);
>>>>> + =A0 =A0 =A0 spin_unlock(&c->dc_lock);
>>>>> + =A0 =A0 =A0 dprintk("%s [new]\n", __func__);
>>>>> +}
>>>>> +EXPORT_SYMBOL(nfs4_add_deviceid);
>>>>> +
>>>>> +static int
>>>>> +nfs4_remove_deviceid(struct nfs4_deviceid_cache *c)
>>>>> +{
>>>>> + =A0 =A0 =A0 struct nfs4_deviceid *d;
>>>>> +
>>>>> + =A0 =A0 =A0 spin_lock(&c->dc_lock);
>>>>> + =A0 =A0 =A0 list_for_each_entry_rcu(d, &c->dc_deviceids, de_nod=
e) {
>>>>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 list_del_rcu(&d->de_node);
>>>>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 spin_unlock(&c->dc_lock);
>>>>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 synchronize_rcu();
>>>>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 c->dc_free_callback(&d->de_rcu);
>>>>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return 1;
>>>>> + =A0 =A0 =A0 }
>>>>> + =A0 =A0 =A0 spin_unlock(&c->dc_lock);
>>>>> + =A0 =A0 =A0 return 0;
>>>>> +}
>>>>> +
>>>>> +static void
>>>>> +nfs4_free_deviceid_cache(struct kref *kref)
>>>>> +{
>>>>> + =A0 =A0 =A0 struct nfs4_deviceid_cache *cache =3D
>>>>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 container_of(kref, struct nfs4_devi=
ceid_cache, dc_kref);
>>>>> + =A0 =A0 =A0 int more =3D 1;
>>>>> +
>>>>> + =A0 =A0 =A0 while (more)
>>>>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 more =3D nfs4_remove_deviceid(cache=
);
>>>>> + =A0 =A0 =A0 cache->dc_clp->cl_devid_cache =3D NULL;
>>>>
>>>> Need to take the cl_lock around this assignment
>>>>
>>>> spin_lock(&cache->dc_clp->cl_lock);
>>>> cache->dc_clp->cl_devid_cache =3D NULL
>>>> spin_unlock(&cache->dc_clp->cl_lock);
>>>>
>>>>
>>>
>>> That must happen atomically before kref_put.
>>> It's illegal to have cl_devid_cache be referenced by cache->dc_clp
>>> without a reference count backing it up.
>>> Otherwise, if accessed concurrently to this piece of code
>>> someone might call kref_get while the refcount is zero.
>>>
>>> Normally, you'd first clear the referencing pointer to prevent any
>>> new reference to it and only then kref_put it, e.g.:
>>>
>>> spin_lock(&cache->dc_clp->cl_lock);
>>> tmp =3D cache->dc_clp->cl_devid_cache;
>>> cache->dc_clp->cl_devid_cache =3D NULL
>>> spin_unlock(&cache->dc_clp->cl_lock);
>>> kref_put(&tmp->dc_kref, nfs4_free_deviceid_cache);
>>
>> Good point. Thanks for the review. I'll rethink and resend
>>
>> -->Andy
>>
>>>
>>> Benny
>>>
>>>>> + =A0 =A0 =A0 kfree(cache);
>>>>> +}
>>>>> +
>>>>> +void
>>>>> +nfs4_put_deviceid_cache(struct nfs4_deviceid_cache *c)
>>>>> +{
>>>>> + =A0 =A0 =A0 dprintk("%s [%d]\n", __func__, atomic_read(&c->dc_k=
ref.refcount));
>>>>> + =A0 =A0 =A0 kref_put(&c->dc_kref, nfs4_free_deviceid_cache);
>>>>> +}
>>>>> +EXPORT_SYMBOL(nfs4_put_deviceid_cache);
>>>>> diff --git a/include/linux/nfs4_pnfs.h b/include/linux/nfs4_pnfs.=
h
>>>>> index 1d521f4..2a88a06 100644
>>>>> --- a/include/linux/nfs4_pnfs.h
>>>>> +++ b/include/linux/nfs4_pnfs.h
>>>>> @@ -281,6 +281,33 @@ struct pnfs_devicelist {
>>>>> =A0 =A0 =A0 =A0struct pnfs_deviceid =A0 =A0dev_id[NFS4_PNFS_GETDE=
VLIST_MAXNUM];
>>>>> =A0};
>>>>>
>>>>> +/*
>>>>> + * Device ID RCU cache. A device ID is unique per client ID and =
layout type.
>>>>> + */
>>>>> +struct nfs4_deviceid_cache {
>>>>> + =A0 =A0 =A0 spinlock_t =A0 =A0 =A0 =A0 =A0 =A0 =A0dc_lock;
>>>>> + =A0 =A0 =A0 struct list_head =A0 =A0 =A0 =A0dc_deviceids;
>>>>> + =A0 =A0 =A0 struct kref =A0 =A0 =A0 =A0 =A0 =A0 dc_kref;
>>>>> + =A0 =A0 =A0 void =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0(*dc_fr=
ee_callback)(struct rcu_head *);
>>>>> + =A0 =A0 =A0 struct nfs_client =A0 =A0 =A0 *dc_clp;
>>>>> +};
>>>>> +
>>>>> +/* Device ID cache node */
>>>>> +struct nfs4_deviceid {
>>>>> + =A0 =A0 =A0 struct list_head =A0 =A0 =A0 =A0de_node;
>>>>> + =A0 =A0 =A0 struct rcu_head =A0 =A0 =A0 =A0 de_rcu;
>>>>> + =A0 =A0 =A0 struct pnfs_deviceid =A0 =A0de_id;
>>>>> +};
>>>>> +
>>>>> +extern int nfs4_alloc_init_deviceid_cache(struct nfs_client *,
>>>>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 voi=
d (*free_callback)(struct rcu_head *));
>>>>> +extern void nfs4_put_deviceid_cache(struct nfs4_deviceid_cache *=
);
>>>>> +extern void nfs4_init_deviceid_node(struct nfs4_deviceid *);
>>>>> +extern struct nfs4_deviceid *nfs4_find_deviceid(struct nfs4_devi=
ceid_cache *,
>>>>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 str=
uct pnfs_deviceid *);
>>>>> +extern void nfs4_add_deviceid(struct nfs4_deviceid_cache *,
>>>>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 str=
uct nfs4_deviceid *);
>>>>> +
>>>>> =A0/* pNFS client callback functions.
>>>>> =A0* These operations allow the layout driver to access pNFS clie=
nt
>>>>> =A0* specific information or call pNFS client->server operations.
>>>>> diff --git a/include/linux/nfs_fs_sb.h b/include/linux/nfs_fs_sb.=
h
>>>>> index 8522461..ef2e18e 100644
>>>>> --- a/include/linux/nfs_fs_sb.h
>>>>> +++ b/include/linux/nfs_fs_sb.h
>>>>> @@ -87,6 +87,7 @@ struct nfs_client {
>>>>> =A0 =A0 =A0 =A0u32 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 cl_exc=
hange_flags;
>>>>> =A0 =A0 =A0 =A0struct nfs4_session =A0 =A0 *cl_session; =A0 =A0/*=
 sharred session */
>>>>> =A0 =A0 =A0 =A0struct list_head =A0 =A0 =A0 =A0cl_lo_inodes; =A0 =
/* Inodes having layouts */
>>>>> + =A0 =A0 =A0 struct nfs4_deviceid_cache *cl_devid_cache; /* pNFS=
 deviceid cache */
>>>>> =A0#endif /* CONFIG_NFS_V4_1 */
>>>>>
>>>>> =A0#ifdef CONFIG_NFS_FSCACHE
>>>>> --
>>>>> 1.6.6
>>>>>
>>>>> --
>>>>> To unsubscribe from this list: send the line "unsubscribe linux-n=
fs" in
>>>>> the body of a message to majordomo@vger.kernel.org
>>>>> More majordomo info at =A0http://vger.kernel.org/majordomo-info.h=
tml
>>>>>
>>>> _______________________________________________
>>>> pNFS mailing list
>>>> pNFS@linux-nfs.org
>>>> http://linux-nfs.org/cgi-bin/mailman/listinfo/pnfs
>>>
>
>
> --
> Benny Halevy
> Software Architect
> Panasas, Inc.
> bhalevy@panasas.com
> Tel/Fax: +972-3-647-8340
> Mobile: +972-54-802-8340
>
> Panasas: The Leader in Parallel Storage
> www.panasas.com
>
