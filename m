From: Benny Halevy <bhalevy@panasas.com>
Subject: Re: [pnfs] [PATCH 1/3] SQUASHME pnfs_submit: generic device ID cache
Date: Wed, 21 Apr 2010 08:59:50 +0300
Message-ID: <4BCE9456.4080904@panasas.com>
References: <1271433175-4631-1-git-send-email-andros@netapp.com>	<1271433175-4631-2-git-send-email-andros@netapp.com> <u2n89c397151004160904m9e862360xcaf0e187640b0177@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: pnfs@linux-nfs.org, Andy Adamson <andros@netapp.com>,
	linux-nfs@vger.kernel.org
To: "William A. (Andy) Adamson" <androsadamson@gmail.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:65491 "EHLO
	daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751701Ab0DUF7z (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 21 Apr 2010 01:59:55 -0400
In-Reply-To: <u2n89c397151004160904m9e862360xcaf0e187640b0177-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Apr. 16, 2010, 19:04 +0300, "William A. (Andy) Adamson" <androsadamson@gmail.com> wrote:
> On Fri, Apr 16, 2010 at 11:52 AM,  <andros@netapp.com> wrote:
>> From: Andy Adamson <andros@netapp.com>
>>
>> A shared RCU device ID cache servicing multiple mounts of a single layout type
>> per meta data server (struct nfs_client).
>>
>> Device IDs of type deviceid4 are required by all layout types, long lived and
>> read at each I/O.  They are added to the deviceid cache at first reference by
>> a layout via GETDEVICEINFO and (currently) are only removed at umount.
>>
>> Reference count the device ID cache for each mounted file system
>> in the initialize_mountpoint layoutdriver_io_operation.
>>
>> Dereference the device id cache on file system in the uninitialize_mountpoint
>> layoutdriver_io_operation called at umount
>>
>> Signed-off-by: Andy Adamson <andros@netapp.com>
>> ---
>>  fs/nfs/pnfs.c             |  119 +++++++++++++++++++++++++++++++++++++++++++++
>>  include/linux/nfs4_pnfs.h |   27 ++++++++++
>>  include/linux/nfs_fs_sb.h |    1 +
>>  3 files changed, 147 insertions(+), 0 deletions(-)
>>
>> diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
>> index 91572aa..8492aef 100644
>> --- a/fs/nfs/pnfs.c
>> +++ b/fs/nfs/pnfs.c
>> @@ -45,6 +45,7 @@
>>  #include <linux/nfs4.h>
>>  #include <linux/pnfs_xdr.h>
>>  #include <linux/nfs4_pnfs.h>
>> +#include <linux/rculist.h>
>>
>>  #include "internal.h"
>>  #include "nfs4_fs.h"
>> @@ -2296,3 +2297,121 @@ struct pnfs_client_operations pnfs_ops = {
>>
>>  EXPORT_SYMBOL(pnfs_unregister_layoutdriver);
>>  EXPORT_SYMBOL(pnfs_register_layoutdriver);
>> +
>> +
>> +/* Device ID cache. Supports one layout type per struct nfs_client */
>> +int
>> +nfs4_alloc_init_deviceid_cache(struct nfs_client *clp,
>> +                        void (*free_callback)(struct rcu_head *))
>> +{
>> +       struct nfs4_deviceid_cache *c;
>> +
>> +       c = kzalloc(sizeof(struct nfs4_deviceid_cache), GFP_KERNEL);
>> +       if (!c)
>> +               return -ENOMEM;
>> +       spin_lock(&clp->cl_lock);
>> +       if (clp->cl_devid_cache != NULL) {
>> +               kref_get(&clp->cl_devid_cache->dc_kref);
>> +               spin_unlock(&clp->cl_lock);
>> +               dprintk("%s [kref [%d]]\n", __func__,
>> +                       atomic_read(&clp->cl_devid_cache->dc_kref.refcount));
>> +               kfree(c);
>> +       } else {
>> +               spin_lock_init(&c->dc_lock);
>> +               INIT_LIST_HEAD(&c->dc_deviceids);
>> +               kref_init(&c->dc_kref);
>> +               c->dc_free_callback = free_callback;
>> +               c->dc_clp = clp;
>> +               clp->cl_devid_cache = c;
>> +               spin_unlock(&clp->cl_lock);
>> +               dprintk("%s [new]\n", __func__);
>> +       }
>> +       return 0;
>> +}
>> +EXPORT_SYMBOL(nfs4_alloc_init_deviceid_cache);
>> +
>> +void
>> +nfs4_init_deviceid_node(struct nfs4_deviceid *d)
>> +{
>> +       INIT_LIST_HEAD(&d->de_node);
>> +       INIT_RCU_HEAD(&d->de_rcu);
>> +}
>> +EXPORT_SYMBOL(nfs4_init_deviceid_node);
>> +
>> +struct nfs4_deviceid *
>> +nfs4_find_deviceid(struct nfs4_deviceid_cache *c, struct pnfs_deviceid *id)
>> +{
>> +       struct nfs4_deviceid *d;
>> +
>> +       rcu_read_lock();
>> +       list_for_each_entry_rcu(d, &c->dc_deviceids, de_node) {
>> +               if (!memcmp(&d->de_id, id, NFS4_PNFS_DEVICEID4_SIZE)) {
>> +                       rcu_read_unlock();
>> +                       return d;
>> +               }
>> +       }
>> +       rcu_read_unlock();

I hope this is worth the added complexity...

Out of curiosity, do you have a benchmark comparing the cost
of rcu_read_lock (and unlock) vs. spin_lock(&c->dc_lock)?

>> +       return NULL;
>> +}
>> +EXPORT_SYMBOL(nfs4_find_deviceid);
>> +
>> +/*
>> + * Add or kref_get a deviceid.
>> + * GETDEVICEINFOs for same deviceid can race. If deviceid is found, discard new
>> + */
>> +void
>> +nfs4_add_deviceid(struct nfs4_deviceid_cache *c, struct nfs4_deviceid *new)
>> +{
>> +       struct nfs4_deviceid *d;
>> +
>> +       spin_lock(&c->dc_lock);
>> +       list_for_each_entry_rcu(d, &c->dc_deviceids, de_node) {
>> +               if (!memcmp(&d->de_id, &new->de_id, NFS4_PNFS_DEVICEID4_SIZE)) {
>> +                       spin_unlock(&c->dc_lock);
>> +                       dprintk("%s [discard]\n", __func__);
>> +                       c->dc_free_callback(&new->de_rcu);
>> +               }
>> +       }
>> +       list_add_rcu(&new->de_node, &c->dc_deviceids);
>> +       spin_unlock(&c->dc_lock);
>> +       dprintk("%s [new]\n", __func__);
>> +}
>> +EXPORT_SYMBOL(nfs4_add_deviceid);
>> +
>> +static int
>> +nfs4_remove_deviceid(struct nfs4_deviceid_cache *c)
>> +{
>> +       struct nfs4_deviceid *d;
>> +
>> +       spin_lock(&c->dc_lock);
>> +       list_for_each_entry_rcu(d, &c->dc_deviceids, de_node) {
>> +               list_del_rcu(&d->de_node);
>> +               spin_unlock(&c->dc_lock);
>> +               synchronize_rcu();
>> +               c->dc_free_callback(&d->de_rcu);
>> +               return 1;
>> +       }
>> +       spin_unlock(&c->dc_lock);
>> +       return 0;
>> +}
>> +
>> +static void
>> +nfs4_free_deviceid_cache(struct kref *kref)
>> +{
>> +       struct nfs4_deviceid_cache *cache =
>> +               container_of(kref, struct nfs4_deviceid_cache, dc_kref);
>> +       int more = 1;
>> +
>> +       while (more)
>> +               more = nfs4_remove_deviceid(cache);
>> +       cache->dc_clp->cl_devid_cache = NULL;
> 
> Need to take the cl_lock around this assignment
> 
> spin_lock(&cache->dc_clp->cl_lock);
> cache->dc_clp->cl_devid_cache = NULL
> spin_unlock(&cache->dc_clp->cl_lock);
> 
> 

That must happen atomically before kref_put.
It's illegal to have cl_devid_cache be referenced by cache->dc_clp
without a reference count backing it up.
Otherwise, if accessed concurrently to this piece of code
someone might call kref_get while the refcount is zero.

Normally, you'd first clear the referencing pointer to prevent any
new reference to it and only then kref_put it, e.g.:

spin_lock(&cache->dc_clp->cl_lock);
tmp = cache->dc_clp->cl_devid_cache;
cache->dc_clp->cl_devid_cache = NULL
spin_unlock(&cache->dc_clp->cl_lock);
kref_put(&tmp->dc_kref, nfs4_free_deviceid_cache);

Benny

>> +       kfree(cache);
>> +}
>> +
>> +void
>> +nfs4_put_deviceid_cache(struct nfs4_deviceid_cache *c)
>> +{
>> +       dprintk("%s [%d]\n", __func__, atomic_read(&c->dc_kref.refcount));
>> +       kref_put(&c->dc_kref, nfs4_free_deviceid_cache);
>> +}
>> +EXPORT_SYMBOL(nfs4_put_deviceid_cache);
>> diff --git a/include/linux/nfs4_pnfs.h b/include/linux/nfs4_pnfs.h
>> index 1d521f4..2a88a06 100644
>> --- a/include/linux/nfs4_pnfs.h
>> +++ b/include/linux/nfs4_pnfs.h
>> @@ -281,6 +281,33 @@ struct pnfs_devicelist {
>>        struct pnfs_deviceid    dev_id[NFS4_PNFS_GETDEVLIST_MAXNUM];
>>  };
>>
>> +/*
>> + * Device ID RCU cache. A device ID is unique per client ID and layout type.
>> + */
>> +struct nfs4_deviceid_cache {
>> +       spinlock_t              dc_lock;
>> +       struct list_head        dc_deviceids;
>> +       struct kref             dc_kref;
>> +       void                    (*dc_free_callback)(struct rcu_head *);
>> +       struct nfs_client       *dc_clp;
>> +};
>> +
>> +/* Device ID cache node */
>> +struct nfs4_deviceid {
>> +       struct list_head        de_node;
>> +       struct rcu_head         de_rcu;
>> +       struct pnfs_deviceid    de_id;
>> +};
>> +
>> +extern int nfs4_alloc_init_deviceid_cache(struct nfs_client *,
>> +                               void (*free_callback)(struct rcu_head *));
>> +extern void nfs4_put_deviceid_cache(struct nfs4_deviceid_cache *);
>> +extern void nfs4_init_deviceid_node(struct nfs4_deviceid *);
>> +extern struct nfs4_deviceid *nfs4_find_deviceid(struct nfs4_deviceid_cache *,
>> +                               struct pnfs_deviceid *);
>> +extern void nfs4_add_deviceid(struct nfs4_deviceid_cache *,
>> +                               struct nfs4_deviceid *);
>> +
>>  /* pNFS client callback functions.
>>  * These operations allow the layout driver to access pNFS client
>>  * specific information or call pNFS client->server operations.
>> diff --git a/include/linux/nfs_fs_sb.h b/include/linux/nfs_fs_sb.h
>> index 8522461..ef2e18e 100644
>> --- a/include/linux/nfs_fs_sb.h
>> +++ b/include/linux/nfs_fs_sb.h
>> @@ -87,6 +87,7 @@ struct nfs_client {
>>        u32                     cl_exchange_flags;
>>        struct nfs4_session     *cl_session;    /* sharred session */
>>        struct list_head        cl_lo_inodes;   /* Inodes having layouts */
>> +       struct nfs4_deviceid_cache *cl_devid_cache; /* pNFS deviceid cache */
>>  #endif /* CONFIG_NFS_V4_1 */
>>
>>  #ifdef CONFIG_NFS_FSCACHE
>> --
>> 1.6.6
>>
>> --
>> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>>
> _______________________________________________
> pNFS mailing list
> pNFS@linux-nfs.org
> http://linux-nfs.org/cgi-bin/mailman/listinfo/pnfs
