From: Fred Isaman <iisaman@netapp.com>
Subject: Re: [PATCH 09/13] RFC: nfs: create and destroy inode's layout cache
Date: Fri, 10 Sep 2010 14:13:50 -0700
Message-ID: <AANLkTi=fJo11j+fHFyZVoQk63RW7sp5oPzAbGd3xcczA@mail.gmail.com>
References: <1283450419-5648-1-git-send-email-iisaman@netapp.com>
	<1283450419-5648-10-git-send-email-iisaman@netapp.com>
	<1284147785.10062.80.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: linux-nfs@vger.kernel.org
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:54787 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755197Ab0IJVNw convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 10 Sep 2010 17:13:52 -0400
Received: by bwz11 with SMTP id 11so2624873bwz.19
        for <linux-nfs@vger.kernel.org>; Fri, 10 Sep 2010 14:13:50 -0700 (PDT)
In-Reply-To: <1284147785.10062.80.camel-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Sep 10, 2010 at 12:43 PM, Trond Myklebust
<Trond.Myklebust@netapp.com> wrote:
> On Thu, 2010-09-02 at 14:00 -0400, Fred Isaman wrote:
>> From: The pNFS Team <linux-nfs@vger.kernel.org>
>>
>> At the start of the io paths, try to grab the relevant layout
>> information. =A0This will initiate the inode's layout cache, but
>> stubs ensure the cache stays empty.
>>
>> Signed-off-by: TBD - melding/reorganization of several patches
>> ---
>> =A0fs/nfs/file.c =A0 =A0 =A0 =A0 =A0| =A0 =A05 ++
>> =A0fs/nfs/inode.c =A0 =A0 =A0 =A0 | =A0 =A03 +
>> =A0fs/nfs/pnfs.c =A0 =A0 =A0 =A0 =A0| =A0140 +++++++++++++++++++++++=
+++++++++++++++++++++++++
>> =A0fs/nfs/pnfs.h =A0 =A0 =A0 =A0 =A0| =A0 39 +++++++++++++
>> =A0fs/nfs/read.c =A0 =A0 =A0 =A0 =A0| =A0 =A03 +
>> =A0include/linux/nfs_fs.h | =A0 =A03 +
>> =A06 files changed, 193 insertions(+), 0 deletions(-)
>>
>> diff --git a/fs/nfs/file.c b/fs/nfs/file.c
>> index eb51bd6..10ebdfb 100644
>> --- a/fs/nfs/file.c
>> +++ b/fs/nfs/file.c
>> @@ -36,6 +36,7 @@
>> =A0#include "internal.h"
>> =A0#include "iostat.h"
>> =A0#include "fscache.h"
>> +#include "pnfs.h"
>>
>> =A0#define NFSDBG_FACILITY =A0 =A0 =A0 =A0 =A0 =A0 =A0NFSDBG_FILE
>>
>> @@ -386,6 +387,10 @@ static int nfs_write_begin(struct file *file, s=
truct address_space *mapping,
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 file->f_path.dentry->d_name.name,
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 mapping->host->i_ino, len, (long long) p=
os);
>>
>> + =A0 =A0 pnfs_update_layout(mapping->host,
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0nfs_file_open_conte=
xt(file),
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0IOMODE_RW);
>> +
>> =A0start:
>> =A0 =A0 =A0 /*
>> =A0 =A0 =A0 =A0* Prevent starvation issues if someone is doing a con=
sistency
>> diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
>> index 7d2d6c7..0dc6dad 100644
>> --- a/fs/nfs/inode.c
>> +++ b/fs/nfs/inode.c
>> @@ -48,6 +48,7 @@
>> =A0#include "internal.h"
>> =A0#include "fscache.h"
>> =A0#include "dns_resolve.h"
>> +#include "pnfs.h"
>>
>> =A0#define NFSDBG_FACILITY =A0 =A0 =A0 =A0 =A0 =A0 =A0NFSDBG_VFS
>>
>> @@ -1409,6 +1410,7 @@ void nfs4_evict_inode(struct inode *inode)
>> =A0{
>> =A0 =A0 =A0 truncate_inode_pages(&inode->i_data, 0);
>> =A0 =A0 =A0 end_writeback(inode);
>> + =A0 =A0 pnfs_destroy_layout(NFS_I(inode));
>> =A0 =A0 =A0 /* If we are holding a delegation, return it! */
>> =A0 =A0 =A0 nfs_inode_return_delegation_noreclaim(inode);
>> =A0 =A0 =A0 /* First call standard NFS clear_inode() code */
>> @@ -1446,6 +1448,7 @@ static inline void nfs4_init_once(struct nfs_i=
node *nfsi)
>> =A0 =A0 =A0 nfsi->delegation =3D NULL;
>> =A0 =A0 =A0 nfsi->delegation_state =3D 0;
>> =A0 =A0 =A0 init_rwsem(&nfsi->rwsem);
>> + =A0 =A0 nfsi->layout =3D NULL;
>> =A0#endif
>> =A0}
>>
>> diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
>> index 8d503fc..65f923b 100644
>> --- a/fs/nfs/pnfs.c
>> +++ b/fs/nfs/pnfs.c
>> @@ -151,3 +151,143 @@ pnfs_unregister_layoutdriver(struct pnfs_layou=
tdriver_type *ld_type)
>> =A0 =A0 =A0 spin_unlock(&pnfs_spinlock);
>> =A0}
>> =A0EXPORT_SYMBOL(pnfs_unregister_layoutdriver);
>> +
>> +static void
>> +get_layout_hdr_locked(struct pnfs_layout_hdr *lo)
>> +{
>> + =A0 =A0 assert_spin_locked(&lo->inode->i_lock);
>> + =A0 =A0 lo->refcount++;
>> +}
>> +
>> +static void
>> +put_layout_hdr_locked(struct pnfs_layout_hdr *lo)
>> +{
>> + =A0 =A0 assert_spin_locked(&lo->inode->i_lock);
>> + =A0 =A0 BUG_ON(lo->refcount <=3D 0);
>> +
>> + =A0 =A0 lo->refcount--;
>> + =A0 =A0 if (!lo->refcount) {
>> + =A0 =A0 =A0 =A0 =A0 =A0 dprintk("%s: freeing layout cache %p\n", _=
_func__, lo);
>> + =A0 =A0 =A0 =A0 =A0 =A0 NFS_I(lo->inode)->layout =3D NULL;
>> + =A0 =A0 =A0 =A0 =A0 =A0 kfree(lo);
>> + =A0 =A0 }
>> +}
>> +
>> +void
>> +pnfs_destroy_layout(struct nfs_inode *nfsi)
>> +{
>> + =A0 =A0 struct pnfs_layout_hdr *lo;
>> +
>> + =A0 =A0 spin_lock(&nfsi->vfs_inode.i_lock);
>> + =A0 =A0 lo =3D nfsi->layout;
>> + =A0 =A0 if (lo) {
>> + =A0 =A0 =A0 =A0 =A0 =A0 /* Matched by refcount set to 1 in alloc_i=
nit_layout_hdr */
>> + =A0 =A0 =A0 =A0 =A0 =A0 put_layout_hdr_locked(lo);
>> + =A0 =A0 }
>> + =A0 =A0 spin_unlock(&nfsi->vfs_inode.i_lock);
>> +}
>> +
>> +/* STUB - pretend LAYOUTGET to server failed */
>> +static struct pnfs_layout_segment *
>> +send_layoutget(struct pnfs_layout_hdr *lo,
>> + =A0 =A0 =A0 =A0struct nfs_open_context *ctx,
>> + =A0 =A0 =A0 =A0u32 iomode)
>> +{
>> + =A0 =A0 struct inode *ino =3D lo->inode;
>> +
>> + =A0 =A0 set_bit(lo_fail_bit(iomode), &lo->state);
>> + =A0 =A0 spin_lock(&ino->i_lock);
>> + =A0 =A0 put_layout_hdr_locked(lo);
>> + =A0 =A0 spin_unlock(&ino->i_lock);
>> + =A0 =A0 return NULL;
>> +}
>> +
>> +static struct pnfs_layout_hdr *
>> +alloc_init_layout_hdr(struct inode *ino)
>> +{
>> + =A0 =A0 struct pnfs_layout_hdr *lo;
>> +
>> + =A0 =A0 lo =3D kzalloc(sizeof(struct pnfs_layout_hdr), GFP_KERNEL)=
;
>> + =A0 =A0 if (!lo)
>> + =A0 =A0 =A0 =A0 =A0 =A0 return NULL;
>> + =A0 =A0 lo->refcount =3D 1;
>> + =A0 =A0 lo->inode =3D ino;
>> + =A0 =A0 return lo;
>> +}
>> +
>> +static struct pnfs_layout_hdr *
>> +pnfs_find_alloc_layout(struct inode *ino)
>> +{
>> + =A0 =A0 struct nfs_inode *nfsi =3D NFS_I(ino);
>> + =A0 =A0 struct pnfs_layout_hdr *new =3D NULL;
>> +
>> + =A0 =A0 dprintk("%s Begin ino=3D%p layout=3D%p\n", __func__, ino, =
nfsi->layout);
>> +
>> + =A0 =A0 assert_spin_locked(&ino->i_lock);
>> + =A0 =A0 if (nfsi->layout)
>> + =A0 =A0 =A0 =A0 =A0 =A0 return nfsi->layout;
>> +
>> + =A0 =A0 spin_unlock(&ino->i_lock);
>> + =A0 =A0 new =3D alloc_init_layout_hdr(ino);
>> + =A0 =A0 spin_lock(&ino->i_lock);
>> +
>> + =A0 =A0 if (likely(nfsi->layout =3D=3D NULL)) =A0 =A0 =A0 /* Won t=
he race? */
>> + =A0 =A0 =A0 =A0 =A0 =A0 nfsi->layout =3D new;
>> + =A0 =A0 else
>> + =A0 =A0 =A0 =A0 =A0 =A0 kfree(new);
>> + =A0 =A0 return nfsi->layout;
>> +}
>> +
>> +/* STUB - LAYOUTGET never succeeds, so cache is empty */
>> +static struct pnfs_layout_segment *
>> +pnfs_has_layout(struct pnfs_layout_hdr *lo, u32 iomode)
>> +{
>> + =A0 =A0 return NULL;
>> +}
>> +
>> +/*
>> + * Layout segment is retreived from the server if not cached.
>> + * The appropriate layout segment is referenced and returned to the=
 caller.
>> + */
>> +struct pnfs_layout_segment *
>> +pnfs_update_layout(struct inode *ino,
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0struct nfs_open_context *ctx,
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0enum pnfs_iomode iomode)
>> +{
>> + =A0 =A0 struct nfs_inode *nfsi =3D NFS_I(ino);
>> + =A0 =A0 struct pnfs_layout_hdr *lo;
>> + =A0 =A0 struct pnfs_layout_segment *lseg =3D NULL;
>> +
>> + =A0 =A0 if (!pnfs_enabled_sb(NFS_SERVER(ino)))
>> + =A0 =A0 =A0 =A0 =A0 =A0 return NULL;
>> + =A0 =A0 spin_lock(&ino->i_lock);
>> + =A0 =A0 lo =3D pnfs_find_alloc_layout(ino);
>> + =A0 =A0 if (lo =3D=3D NULL) {
>> + =A0 =A0 =A0 =A0 =A0 =A0 dprintk("%s ERROR: can't get pnfs_layout_h=
dr\n", __func__);
>> + =A0 =A0 =A0 =A0 =A0 =A0 goto out_unlock;
>> + =A0 =A0 }
>> +
>> + =A0 =A0 /* Check to see if the layout for the given range already =
exists */
>> + =A0 =A0 lseg =3D pnfs_has_layout(lo, iomode);
>> + =A0 =A0 if (lseg) {
>> + =A0 =A0 =A0 =A0 =A0 =A0 dprintk("%s: Using cached lseg %p for iomo=
de %d)\n",
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 __func__, lseg, iomode);
>> + =A0 =A0 =A0 =A0 =A0 =A0 goto out_unlock;
>> + =A0 =A0 }
>> +
>> + =A0 =A0 /* if LAYOUTGET already failed once we don't try again */
>> + =A0 =A0 if (test_bit(lo_fail_bit(iomode), &nfsi->layout->state))
>> + =A0 =A0 =A0 =A0 =A0 =A0 goto out_unlock;
>> +
>> + =A0 =A0 get_layout_hdr_locked(lo);
>> + =A0 =A0 spin_unlock(&ino->i_lock);
>> +
>> + =A0 =A0 lseg =3D send_layoutget(lo, ctx, iomode);
>> +out:
>> + =A0 =A0 dprintk("%s end, state 0x%lx lseg %p\n", __func__,
>> + =A0 =A0 =A0 =A0 =A0 =A0 nfsi->layout->state, lseg);
>> + =A0 =A0 return lseg;
>> +out_unlock:
>> + =A0 =A0 spin_unlock(&ino->i_lock);
>> + =A0 =A0 goto out;
>> +}
>> diff --git a/fs/nfs/pnfs.h b/fs/nfs/pnfs.h
>> index 9049b9a..b63b445 100644
>> --- a/fs/nfs/pnfs.h
>> +++ b/fs/nfs/pnfs.h
>> @@ -14,6 +14,11 @@
>>
>> =A0#define LAYOUT_NFSV4_1_MODULE_PREFIX "nfs-layouttype4"
>>
>> +enum {
>> + =A0 =A0 NFS_LAYOUT_RO_FAILED =3D 0, =A0 =A0 =A0 /* get ro layout f=
ailed stop trying */
>> + =A0 =A0 NFS_LAYOUT_RW_FAILED, =A0 =A0 =A0 =A0 =A0 /* get rw layout=
 failed stop trying */
>> +};
>> +
>> =A0/* Per-layout driver specific registration structure */
>> =A0struct pnfs_layoutdriver_type {
>> =A0 =A0 =A0 struct list_head pnfs_tblid;
>> @@ -22,6 +27,12 @@ struct pnfs_layoutdriver_type {
>> =A0 =A0 =A0 struct layoutdriver_io_operations *ld_io_ops;
>> =A0};
>>
>> +struct pnfs_layout_hdr {
>> + =A0 =A0 int =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 refcount;
> =A0 =A0 =A0 =A0^^^^^ Why not make this 'unsigned int', and/or 'unsign=
ed long'?

OK.

=46red

>> + =A0 =A0 unsigned long =A0 =A0 =A0 =A0 =A0 state;
>> + =A0 =A0 struct inode =A0 =A0 =A0 =A0 =A0 =A0*inode;
>> +};
>> +
>> =A0/* Layout driver I/O operations. */
>> =A0struct layoutdriver_io_operations {
>> =A0 =A0 =A0 /* Registration information for a new mounted file syste=
m */
>> @@ -32,11 +43,39 @@ struct layoutdriver_io_operations {
>> =A0extern int pnfs_register_layoutdriver(struct pnfs_layoutdriver_ty=
pe *);
>> =A0extern void pnfs_unregister_layoutdriver(struct pnfs_layoutdriver=
_type *);
>>
>> +struct pnfs_layout_segment *
>> +pnfs_update_layout(struct inode *ino, struct nfs_open_context *ctx,
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0enum pnfs_iomode access_type);
>> =A0void set_pnfs_layoutdriver(struct nfs_server *, u32 id);
>> =A0void unset_pnfs_layoutdriver(struct nfs_server *);
>> +void pnfs_destroy_layout(struct nfs_inode *);
>> +
>> +
>> +static inline int lo_fail_bit(u32 iomode)
>> +{
>> + =A0 =A0 return iomode =3D=3D IOMODE_RW ?
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0NFS_LAYOUT_RW_FAILED : =
NFS_LAYOUT_RO_FAILED;
>> +}
>> +
>> +/* Return true if a layout driver is being used for this mountpoint=
 */
>> +static inline int pnfs_enabled_sb(struct nfs_server *nfss)
>> +{
>> + =A0 =A0 return nfss->pnfs_curr_ld !=3D NULL;
>> +}
>>
>> =A0#else =A0/* CONFIG_NFS_V4_1 */
>>
>> +static inline void pnfs_destroy_layout(struct nfs_inode *nfsi)
>> +{
>> +}
>> +
>> +static inline struct pnfs_layout_segment *
>> +pnfs_update_layout(struct inode *ino, struct nfs_open_context *ctx,
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0enum pnfs_iomode access_type)
>> +{
>> + =A0 =A0 return NULL;
>> +}
>> +
>> =A0static inline void set_pnfs_layoutdriver(struct nfs_server *s, u3=
2 id)
>> =A0{
>> =A0}
>> diff --git a/fs/nfs/read.c b/fs/nfs/read.c
>> index 87adc27..f7eb66f 100644
>> --- a/fs/nfs/read.c
>> +++ b/fs/nfs/read.c
>> @@ -25,6 +25,7 @@
>> =A0#include "internal.h"
>> =A0#include "iostat.h"
>> =A0#include "fscache.h"
>> +#include "pnfs.h"
>>
>> =A0#define NFSDBG_FACILITY =A0 =A0 =A0 =A0 =A0 =A0 =A0NFSDBG_PAGECAC=
HE
>>
>> @@ -121,6 +122,7 @@ int nfs_readpage_async(struct nfs_open_context *=
ctx, struct inode *inode,
>> =A0 =A0 =A0 len =3D nfs_page_length(page);
>> =A0 =A0 =A0 if (len =3D=3D 0)
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 return nfs_return_empty_page(page);
>> + =A0 =A0 pnfs_update_layout(inode, ctx, IOMODE_READ);
>> =A0 =A0 =A0 new =3D nfs_create_request(ctx, inode, page, 0, len);
>> =A0 =A0 =A0 if (IS_ERR(new)) {
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 unlock_page(page);
>> @@ -625,6 +627,7 @@ int nfs_readpages(struct file *filp, struct addr=
ess_space *mapping,
>> =A0 =A0 =A0 if (ret =3D=3D 0)
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto read_complete; /* all pages were re=
ad */
>>
>> + =A0 =A0 pnfs_update_layout(inode, desc.ctx, IOMODE_READ);
>> =A0 =A0 =A0 if (rsize < PAGE_CACHE_SIZE)
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 nfs_pageio_init(&pgio, inode, nfs_pagein=
_multi, rsize, 0);
>> =A0 =A0 =A0 else
>> diff --git a/include/linux/nfs_fs.h b/include/linux/nfs_fs.h
>> index a0f49a3..ebd87a9 100644
>> --- a/include/linux/nfs_fs.h
>> +++ b/include/linux/nfs_fs.h
>> @@ -188,6 +188,9 @@ struct nfs_inode {
>> =A0 =A0 =A0 struct nfs_delegation =A0 *delegation;
>> =A0 =A0 =A0 fmode_t =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0delegation_st=
ate;
>> =A0 =A0 =A0 struct rw_semaphore =A0 =A0 rwsem;
>> +
>> + =A0 =A0 /* pNFS layout information */
>> + =A0 =A0 struct pnfs_layout_hdr *layout;
>> =A0#endif /* CONFIG_NFS_V4*/
>> =A0#ifdef CONFIG_NFS_FSCACHE
>> =A0 =A0 =A0 struct fscache_cookie =A0 *fscache;
>
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" =
in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at =A0http://vger.kernel.org/majordomo-info.html
>
