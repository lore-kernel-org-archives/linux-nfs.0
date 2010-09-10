From: Fred Isaman <iisaman@netapp.com>
Subject: Re: [PATCH 07/13] RFC: pnfs: full mount/umount infrastructure
Date: Fri, 10 Sep 2010 13:53:19 -0700
Message-ID: <AANLkTi=6iEuaeVBUn0aJj8cCtExtX+KeG7Oqt1uDWHEY@mail.gmail.com>
References: <1283450419-5648-1-git-send-email-iisaman@netapp.com>
	<1283450419-5648-8-git-send-email-iisaman@netapp.com>
	<1284146604.10062.68.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: linux-nfs@vger.kernel.org
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:49623 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753835Ab0IJUxU convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 10 Sep 2010 16:53:20 -0400
Received: by bwz11 with SMTP id 11so2606947bwz.19
        for <linux-nfs@vger.kernel.org>; Fri, 10 Sep 2010 13:53:19 -0700 (PDT)
In-Reply-To: <1284146604.10062.68.camel-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Sep 10, 2010 at 12:23 PM, Trond Myklebust
<Trond.Myklebust@netapp.com> wrote:
> On Thu, 2010-09-02 at 14:00 -0400, Fred Isaman wrote:
>> From: The pNFS Team <linux-nfs@vger.kernel.org>
>>
>> Allow a module implementing a layout type to register, and
>> have its mount/umount routines called for filesystems that
>> the server declares support it.
>>
>> Signed-off-by: TBD - melding/reorganization of several patches
>> ---
>> =A0Documentation/filesystems/nfs/00-INDEX | =A0 =A02 +
>> =A0Documentation/filesystems/nfs/pnfs.txt | =A0 48 +++++++++++++++++=
++
>> =A0fs/nfs/Kconfig =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 | =
=A0 =A02 +-
>> =A0fs/nfs/pnfs.c =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
| =A0 79 +++++++++++++++++++++++++++++++-
>> =A0fs/nfs/pnfs.h =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
| =A0 14 ++++++
>> =A05 files changed, 142 insertions(+), 3 deletions(-)
>> =A0create mode 100644 Documentation/filesystems/nfs/pnfs.txt
>>
>> diff --git a/Documentation/filesystems/nfs/00-INDEX b/Documentation/=
filesystems/nfs/00-INDEX
>> index 2f68cd6..8d930b9 100644
>> --- a/Documentation/filesystems/nfs/00-INDEX
>> +++ b/Documentation/filesystems/nfs/00-INDEX
>> @@ -12,5 +12,7 @@ nfs-rdma.txt
>> =A0 =A0 =A0 - how to install and setup the Linux NFS/RDMA client and=
 server software
>> =A0nfsroot.txt
>> =A0 =A0 =A0 - short guide on setting up a diskless box with NFS root=
 filesystem.
>> +pnfs.txt
>> + =A0 =A0 - short explanation of some of the internals of the pnfs c=
ode
>> =A0rpc-cache.txt
>> =A0 =A0 =A0 - introduction to the caching mechanisms in the sunrpc l=
ayer.
>> diff --git a/Documentation/filesystems/nfs/pnfs.txt b/Documentation/=
filesystems/nfs/pnfs.txt
>> new file mode 100644
>> index 0000000..bc0b9cf
>> --- /dev/null
>> +++ b/Documentation/filesystems/nfs/pnfs.txt
>> @@ -0,0 +1,48 @@
>> +Reference counting in pnfs:
>> +=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D
>> +
>> +The are several inter-related caches. =A0We have layouts which can
>> +reference multiple devices, each of which can reference multiple da=
ta servers.
>> +Each data server can be referenced by multiple devices. =A0Each dev=
ice
>> +can be referenced by multiple layouts. =A0To keep all of this strai=
ght,
>> +we need to reference count.
>> +
>> +
>> +struct pnfs_layout_hdr
>> +----------------------
>> +The on-the-wire command LAYOUTGET corresponds to struct
>> +pnfs_layout_segment, usually referred to by the variable name lseg.
>> +Each nfs_inode may hold a pointer to a cache of of these layout
>> +segments in nfsi->layout, of type struct pnfs_layout_hdr.
>> +
>> +We reference the header for the inode pointing to it, across each
>> +outstanding RPC call that references it (LAYOUTGET, LAYOUTRETURN,
>> +LAYOUTCOMMIT), and for each lseg held within.
>> +
>> +Each header is also (when non-empty) put on a list associated with
>> +struct nfs_client (cl_layouts). =A0Being put on this list does not =
bump
>> +the reference count, as the layout is kept around by the lseg that
>> +keeps it in the list.
>> +
>> +deviceid_cache
>> +--------------
>> +lsegs reference device ids, which are resolved per nfs_client and
>> +layout driver type. =A0The device ids are held in a RCU cache (stru=
ct
>> +nfs4_deviceid_cache). =A0The cache itself is referenced across each
>> +mount. =A0The entries (struct nfs4_deviceid) themselves are held ac=
ross
>> +the lifetime of each lseg referencing them.
>> +
>> +RCU is used because the deviceid is basically a write once, read ma=
ny
>> +data structure. =A0The hlist size of 32 buckets needs better
>> +justification, but seems reasonable given that we can have multiple
>> +deviceid's per filesystem, and multiple filesystems per nfs_client.
>> +
>> +The hash code is copied from the nfsd code base. =A0A discussion of
>> +hashing and variations of this algorithm can be found at:
>> +http://groups.google.com/group/comp.lang.c/browse_thread/thread/952=
2965e2b8d3809
>> +
>> +data server cache
>> +-----------------
>> +file driver devices refer to data servers, which are kept in a modu=
le
>> +level cache. =A0Its reference is held over the lifetime of the devi=
ceid
>> +pointing to it.
>> diff --git a/fs/nfs/Kconfig b/fs/nfs/Kconfig
>> index 6c2aad4..5f1b936 100644
>> --- a/fs/nfs/Kconfig
>> +++ b/fs/nfs/Kconfig
>> @@ -78,7 +78,7 @@ config NFS_V4_1
>> =A0 =A0 =A0 depends on NFS_V4 && EXPERIMENTAL
>> =A0 =A0 =A0 help
>> =A0 =A0 =A0 =A0 This option enables support for minor version 1 of t=
he NFSv4 protocol
>> - =A0 =A0 =A0 (draft-ietf-nfsv4-minorversion1) in the kernel's NFS c=
lient.
>> + =A0 =A0 =A0 (RFC 5661) in the kernel's NFS client.
>>
>> =A0 =A0 =A0 =A0 If unsure, say N.
>>
>> diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
>> index 2e5dba1..8d503fc 100644
>> --- a/fs/nfs/pnfs.c
>> +++ b/fs/nfs/pnfs.c
>> @@ -32,16 +32,48 @@
>>
>> =A0#define NFSDBG_FACILITY =A0 =A0 =A0 =A0 =A0 =A0 =A0NFSDBG_PNFS
>>
>> -/* STUB that returns the equivalent of "no module found" */
>> +/* Locking:
>> + *
>> + * pnfs_spinlock:
>> + * =A0 =A0 =A0protects pnfs_modules_tbl.
>> + */
>> +static DEFINE_SPINLOCK(pnfs_spinlock);
>> +
>> +/*
>> + * pnfs_modules_tbl holds all pnfs modules
>> + */
>> +static LIST_HEAD(pnfs_modules_tbl);
>> +
>> +/* Return the registered pnfs layout driver module matching given i=
d */
>> +static struct pnfs_layoutdriver_type *
>> +find_pnfs_driver_locked(u32 id) {
>> + =A0 =A0 struct =A0pnfs_layoutdriver_type *local;
>> +
>> + =A0 =A0 dprintk("PNFS: %s: Searching for %u\n", __func__, id);
>> + =A0 =A0 list_for_each_entry(local, &pnfs_modules_tbl, pnfs_tblid)
>> + =A0 =A0 =A0 =A0 =A0 =A0 if (local->id =3D=3D id)
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto out;
>> + =A0 =A0 local =3D NULL;
>> +out:
>> + =A0 =A0 return local;
>> +}
>> +
>> =A0static struct pnfs_layoutdriver_type *
>> =A0find_pnfs_driver(u32 id) {
>> - =A0 =A0 return NULL;
>> + =A0 =A0 struct =A0pnfs_layoutdriver_type *local;
>> +
>> + =A0 =A0 spin_lock(&pnfs_spinlock);
>> + =A0 =A0 local =3D find_pnfs_driver_locked(id);
>
> Don't you want some kind of reference count on this? I'd assume that =
you
> probably need a module_get() with a corresponding module_put() when y=
ou
> are done using the layoutdriver.
>

OK


>> + =A0 =A0 spin_unlock(&pnfs_spinlock);
>> + =A0 =A0 return local;
>> =A0}
>>
>> =A0/* Unitialize a mountpoint in a layout driver */
>> =A0void
>> =A0unset_pnfs_layoutdriver(struct nfs_server *nfss)
>> =A0{
>> + =A0 =A0 if (nfss->pnfs_curr_ld)
>> + =A0 =A0 =A0 =A0 =A0 =A0 nfss->pnfs_curr_ld->ld_io_ops->uninitializ=
e_mountpoint(nfss->nfs_client);
>
> That 'uninitialize_mountpoint' name doesn't make any sense. The
> nfs_client parameter isn't associated to a particular mountpoint.
>
>> =A0 =A0 =A0 nfss->pnfs_curr_ld =3D NULL;
>> =A0}
>>
>> @@ -68,6 +100,12 @@ set_pnfs_layoutdriver(struct nfs_server *server,=
 u32 id)
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto out_no_driver;
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
>> =A0 =A0 =A0 }
>> + =A0 =A0 if (ld_type->ld_io_ops->initialize_mountpoint(server->nfs_=
client)) {
>
> Ditto.
>

OK.

=46red

>> + =A0 =A0 =A0 =A0 =A0 =A0 printk(KERN_ERR
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0"%s: Error initializing mou=
nt point for layout driver %u.\n",
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0__func__, id);
>> + =A0 =A0 =A0 =A0 =A0 =A0 goto out_no_driver;
>> + =A0 =A0 }
>> =A0 =A0 =A0 server->pnfs_curr_ld =3D ld_type;
>> =A0 =A0 =A0 dprintk("%s: pNFS module for %u set\n", __func__, id);
>> =A0 =A0 =A0 return;
>> @@ -76,3 +114,40 @@ out_no_driver:
>> =A0 =A0 =A0 dprintk("%s: Using NFSv4 I/O\n", __func__);
>> =A0 =A0 =A0 server->pnfs_curr_ld =3D NULL;
>> =A0}
>> +
>> +int
>> +pnfs_register_layoutdriver(struct pnfs_layoutdriver_type *ld_type)
>> +{
>> + =A0 =A0 struct layoutdriver_io_operations *io_ops =3D ld_type->ld_=
io_ops;
>> + =A0 =A0 int status =3D -EINVAL;
>> +
>> + =A0 =A0 if (!io_ops) {
>> + =A0 =A0 =A0 =A0 =A0 =A0 printk(KERN_ERR "%s Layout driver must pro=
vide io_ops\n",
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 __func__);
>> + =A0 =A0 =A0 =A0 =A0 =A0 return status;
>> + =A0 =A0 }
>> +
>> + =A0 =A0 spin_lock(&pnfs_spinlock);
>> + =A0 =A0 if (!find_pnfs_driver_locked(ld_type->id)) {
>> + =A0 =A0 =A0 =A0 =A0 =A0 list_add(&ld_type->pnfs_tblid, &pnfs_modul=
es_tbl);
>> + =A0 =A0 =A0 =A0 =A0 =A0 status =3D 0;
>> + =A0 =A0 =A0 =A0 =A0 =A0 dprintk("%s Registering id:%u name:%s\n", =
__func__, ld_type->id,
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 ld_type->name);
>> + =A0 =A0 } else
>> + =A0 =A0 =A0 =A0 =A0 =A0 printk(KERN_ERR "%s Module with id %d alre=
ady loaded!\n",
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 __func__, ld_type->id);
>> + =A0 =A0 spin_unlock(&pnfs_spinlock);
>> +
>> + =A0 =A0 return status;
>> +}
>> +EXPORT_SYMBOL(pnfs_register_layoutdriver);
>> +
>> +void
>> +pnfs_unregister_layoutdriver(struct pnfs_layoutdriver_type *ld_type=
)
>> +{
>> + =A0 =A0 dprintk("%s Deregistering id:%u\n", __func__, ld_type->id)=
;
>> + =A0 =A0 spin_lock(&pnfs_spinlock);
>> + =A0 =A0 list_del(&ld_type->pnfs_tblid);
>> + =A0 =A0 spin_unlock(&pnfs_spinlock);
>> +}
>> +EXPORT_SYMBOL(pnfs_unregister_layoutdriver);
>> diff --git a/fs/nfs/pnfs.h b/fs/nfs/pnfs.h
>> index 3281fbf..9049b9a 100644
>> --- a/fs/nfs/pnfs.h
>> +++ b/fs/nfs/pnfs.h
>> @@ -16,8 +16,22 @@
>>
>> =A0/* Per-layout driver specific registration structure */
>> =A0struct pnfs_layoutdriver_type {
>> + =A0 =A0 struct list_head pnfs_tblid;
>> + =A0 =A0 const u32 id;
>> + =A0 =A0 const char *name;
>> + =A0 =A0 struct layoutdriver_io_operations *ld_io_ops;
>> =A0};
>>
>> +/* Layout driver I/O operations. */
>> +struct layoutdriver_io_operations {
>> + =A0 =A0 /* Registration information for a new mounted file system =
*/
>> + =A0 =A0 int (*initialize_mountpoint) (struct nfs_client *);
>> + =A0 =A0 int (*uninitialize_mountpoint) (struct nfs_client *);
>> +};
>> +
>> +extern int pnfs_register_layoutdriver(struct pnfs_layoutdriver_type=
 *);
>> +extern void pnfs_unregister_layoutdriver(struct pnfs_layoutdriver_t=
ype *);
>> +
>> =A0void set_pnfs_layoutdriver(struct nfs_server *, u32 id);
>> =A0void unset_pnfs_layoutdriver(struct nfs_server *);
>>
>
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" =
in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at =A0http://vger.kernel.org/majordomo-info.html
>
