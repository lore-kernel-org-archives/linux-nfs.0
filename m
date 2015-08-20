Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ig0-f182.google.com ([209.85.213.182]:35615 "EHLO
	mail-ig0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752823AbbHTXLk (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 20 Aug 2015 19:11:40 -0400
Received: by igbjg10 with SMTP id jg10so2493402igb.0
        for <linux-nfs@vger.kernel.org>; Thu, 20 Aug 2015 16:11:40 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1440069440-27454-3-git-send-email-jeff.layton@primarydata.com>
References: <1440069440-27454-1-git-send-email-jeff.layton@primarydata.com> <1440069440-27454-3-git-send-email-jeff.layton@primarydata.com>
From: Peng Tao <bergwolf@primarydata.com>
Date: Thu, 20 Aug 2015 16:11:20 -0700
Message-ID: <CAKVebiXP-xOrTYVmYLv-RkQqWsqokHzX1vikVf-pd=iQDZ5ZGQ@mail.gmail.com>
Subject: Re: [PATCH v3 02/20] nfsd: add a new struct file caching facility to nfsd
To: Jeff Layton <jlayton@poochiereds.net>
Cc: bfields@fieldses.org, Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Christoph Hellwig <hch@lst.de>, kinglongmee@gmail.com
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Aug 20, 2015 at 4:17 AM, Jeff Layton <jlayton@poochiereds.net> wrote:
> Currently, NFSv2/3 reads and writes have to open a file, do the read or
> write and then close it again for each RPC. This is highly inefficient,
> especially when the underlying filesystem has a relatively slow open
> routine.
>
> This patch adds a new open file cache to knfsd. Rather than doing an
> open for each RPC, the read/write handlers can call into this cache to
> see if there is one already there for the correct filehandle and
> NFS_MAY_READ/WRITE flags.
>
> If there isn't an entry, then we create a new one and attempt to
> perform the open. If there is, then we wait until the entry is fully
> instantiated and return it if it is at the end of the wait. If it's
> not, then we attempt to take over construction.
>
> Since the main goal is to speed up NFSv2/3 I/O, we don't want to
> close these files on last put of these objects. We need to keep them
> around for a little while since we never know when the next READ/WRITE
> will come in.
>
> Signed-off-by: Jeff Layton <jeff.layton@primarydata.com>
> ---
>  fs/nfsd/Makefile    |   3 +-
>  fs/nfsd/filecache.c | 273 ++++++++++++++++++++++++++++++++++++++++++++++++++++
>  fs/nfsd/filecache.h |  29 ++++++
>  fs/nfsd/nfssvc.c    |  10 +-
>  4 files changed, 313 insertions(+), 2 deletions(-)
>  create mode 100644 fs/nfsd/filecache.c
>  create mode 100644 fs/nfsd/filecache.h
>
> diff --git a/fs/nfsd/Makefile b/fs/nfsd/Makefile
> index 9a6028e120c6..8908bb467727 100644
> --- a/fs/nfsd/Makefile
> +++ b/fs/nfsd/Makefile
> @@ -10,7 +10,8 @@ obj-$(CONFIG_NFSD)    += nfsd.o
>  nfsd-y                 += trace.o
>
>  nfsd-y                         += nfssvc.o nfsctl.o nfsproc.o nfsfh.o vfs.o \
> -                          export.o auth.o lockd.o nfscache.o nfsxdr.o stats.o
> +                          export.o auth.o lockd.o nfscache.o nfsxdr.o \
> +                          stats.o filecache.o
>  nfsd-$(CONFIG_NFSD_FAULT_INJECTION) += fault_inject.o
>  nfsd-$(CONFIG_NFSD_V2_ACL) += nfs2acl.o
>  nfsd-$(CONFIG_NFSD_V3) += nfs3proc.o nfs3xdr.o
> diff --git a/fs/nfsd/filecache.c b/fs/nfsd/filecache.c
> new file mode 100644
> index 000000000000..5bb56fa9002f
> --- /dev/null
> +++ b/fs/nfsd/filecache.c
> @@ -0,0 +1,273 @@
> +/*
> + * Open file cache.
> + *
> + * (c) 2015 - Jeff Layton <jeff.layton@primarydata.com>
> + */
> +
> +#include <linux/hash.h>
> +#include <linux/slab.h>
> +#include <linux/hash.h>
> +#include <linux/file.h>
> +#include <linux/sched.h>
> +
> +#include "vfs.h"
> +#include "nfsd.h"
> +#include "nfsfh.h"
> +#include "filecache.h"
> +
> +#define NFSDDBG_FACILITY       NFSDDBG_FH
> +
> +/* hash table for nfs4_file */
> +#define NFSD_FILE_HASH_BITS                   8
> +#define NFSD_FILE_HASH_SIZE                  (1 << NFSD_FILE_HASH_BITS)
> +
> +/* We only care about NFSD_MAY_READ/WRITE for this cache */
> +#define NFSD_FILE_MAY_MASK     (NFSD_MAY_READ|NFSD_MAY_WRITE)
> +
> +struct nfsd_fcache_bucket {
> +       struct hlist_head       nfb_head;
> +       spinlock_t              nfb_lock;
> +};
> +
> +static struct nfsd_fcache_bucket       *nfsd_file_hashtbl;
> +
> +static struct nfsd_file *
> +nfsd_file_alloc(struct inode *inode, unsigned int may, unsigned int hashval)
> +{
> +       struct nfsd_file *nf;
> +
> +       /* FIXME: create a new slabcache for these? */
> +       nf = kzalloc(sizeof(*nf), GFP_KERNEL);
> +       if (nf) {
> +               INIT_HLIST_NODE(&nf->nf_node);
> +               INIT_LIST_HEAD(&nf->nf_dispose);
> +               nf->nf_inode = inode;
> +               nf->nf_hashval = hashval;
> +               atomic_set(&nf->nf_ref, 1);
> +               nf->nf_may = NFSD_FILE_MAY_MASK & may;
> +       }
> +       return nf;
> +}
> +
> +static void
> +nfsd_file_put_final(struct nfsd_file *nf)
> +{
> +       if (nf->nf_file)
> +               fput(nf->nf_file);
> +       kfree_rcu(nf, nf_rcu);
> +}
> +
> +static bool
> +nfsd_file_unhash(struct nfsd_file *nf)
> +{
> +       lockdep_assert_held(&nfsd_file_hashtbl[nf->nf_hashval].nfb_lock);
> +
> +       if (test_bit(NFSD_FILE_HASHED, &nf->nf_flags)) {
> +               clear_bit(NFSD_FILE_HASHED, &nf->nf_flags);
nit: why not test_and_clear_bit()?

> +               hlist_del_rcu(&nf->nf_node);
> +               return true;
> +       }
> +       return false;
> +}
> +
> +static void
> +nfsd_file_unhash_and_release_locked(struct nfsd_file *nf, struct list_head *dispose)
> +{
> +       lockdep_assert_held(&nfsd_file_hashtbl[nf->nf_hashval].nfb_lock);
> +
> +       if (!nfsd_file_unhash(nf))
> +               return;
> +       if (!atomic_dec_and_test(&nf->nf_ref))
> +               return;
> +
> +       list_add(&nf->nf_dispose, dispose);
> +}
> +
> +void
> +nfsd_file_put(struct nfsd_file *nf)
> +{
> +       if (!atomic_dec_and_test(&nf->nf_ref))
> +               return;
> +
> +       WARN_ON(test_bit(NFSD_FILE_HASHED, &nf->nf_flags));
> +       nfsd_file_put_final(nf);
> +}
> +
> +struct nfsd_file *
> +nfsd_file_get(struct nfsd_file *nf)
> +{
> +       if (likely(atomic_inc_not_zero(&nf->nf_ref)))
> +               return nf;
> +       return NULL;
> +}
> +
> +static void
> +nfsd_file_dispose_list(struct list_head *dispose)
> +{
> +       struct nfsd_file *nf;
> +
> +       while(!list_empty(dispose)) {
> +               nf = list_first_entry(dispose, struct nfsd_file, nf_dispose);
> +               list_del(&nf->nf_dispose);
> +               nfsd_file_put_final(nf);
> +       }
> +}
> +
> +int
> +nfsd_file_cache_init(void)
> +{
> +       unsigned int i;
> +
> +       if (nfsd_file_hashtbl)
> +               return 0;
> +
> +       nfsd_file_hashtbl = kcalloc(NFSD_FILE_HASH_SIZE,
> +                               sizeof(*nfsd_file_hashtbl), GFP_KERNEL);
> +       if (!nfsd_file_hashtbl)
> +               goto out_nomem;
> +
> +       for (i = 0; i < NFSD_FILE_HASH_SIZE; i++) {
> +               INIT_HLIST_HEAD(&nfsd_file_hashtbl[i].nfb_head);
> +               spin_lock_init(&nfsd_file_hashtbl[i].nfb_lock);
> +       }
> +
> +       return 0;
> +out_nomem:
> +       printk(KERN_ERR "nfsd: failed to init nfsd file cache\n");
> +       return -ENOMEM;
> +}
> +
> +void
> +nfsd_file_cache_shutdown(void)
> +{
> +       unsigned int            i;
> +       struct nfsd_file        *nf;
> +       LIST_HEAD(dispose);
> +
> +       for (i = 0; i < NFSD_FILE_HASH_SIZE; i++) {
> +               spin_lock(&nfsd_file_hashtbl[i].nfb_lock);
> +               while(!hlist_empty(&nfsd_file_hashtbl[i].nfb_head)) {
> +                       nf = hlist_entry(nfsd_file_hashtbl[i].nfb_head.first,
> +                                        struct nfsd_file, nf_node);
> +                       nfsd_file_unhash_and_release_locked(nf, &dispose);
> +               }
> +               spin_unlock(&nfsd_file_hashtbl[i].nfb_lock);
> +               nfsd_file_dispose_list(&dispose);
> +       }
> +       kfree(nfsd_file_hashtbl);
> +       nfsd_file_hashtbl = NULL;
> +}
> +
> +/*
> + * Search nfsd_file_hashtbl[] for file. We hash on the filehandle and also on
> + * the NFSD_MAY_READ/WRITE flags. If the file is open for r/w, then it's usable
> + * for either.
> + */
> +static struct nfsd_file *
> +nfsd_file_find_locked(struct inode *inode, unsigned int may_flags,
> +                       unsigned int hashval)
> +{
> +       struct nfsd_file *nf;
> +       unsigned char need = may_flags & NFSD_FILE_MAY_MASK;
> +
> +       hlist_for_each_entry_rcu(nf, &nfsd_file_hashtbl[hashval].nfb_head,
> +                                nf_node) {
> +               if ((need & nf->nf_may) != need)
> +                       continue;
> +               if (nf->nf_inode == inode)
> +                       return nfsd_file_get(nf);
> +       }
> +       return NULL;
> +}
> +
> +__be32
> +nfsd_file_acquire(struct svc_rqst *rqstp, struct svc_fh *fhp,
> +                 unsigned int may_flags, struct nfsd_file **pnf)
> +{
> +       __be32  status = nfs_ok;
> +       struct nfsd_file *nf, *new = NULL;
> +       struct inode *inode;
> +       unsigned int hashval;
> +
> +       /* FIXME: skip this if fh_dentry is already set? */
> +       status = fh_verify(rqstp, fhp, S_IFREG, may_flags);
> +       if (status != nfs_ok)
> +               return status;
> +
> +       /* Mask off any extraneous bits */
> +       may_flags &= NFSD_FILE_MAY_MASK;
> +
> +       inode = d_inode(fhp->fh_dentry);
> +       hashval = (unsigned int)hash_ptr(inode, NFSD_FILE_HASH_BITS);
> +retry:
> +       rcu_read_lock();
> +       nf = nfsd_file_find_locked(inode, may_flags, hashval);
> +       rcu_read_unlock();
> +       if (nf)
> +               goto wait_for_construction;
> +
> +       if (!new) {
> +               new = nfsd_file_alloc(inode, may_flags, hashval);
> +               if (!new)
> +                       return nfserr_jukebox;
> +       }
> +
> +       spin_lock(&nfsd_file_hashtbl[hashval].nfb_lock);
> +       nf = nfsd_file_find_locked(inode, may_flags, hashval);
> +       if (likely(nf == NULL)) {
> +               /* Take reference for the hashtable */
> +               atomic_inc(&new->nf_ref);
> +               __set_bit(NFSD_FILE_HASHED, &new->nf_flags);
> +               __set_bit(NFSD_FILE_PENDING, &new->nf_flags);
> +               hlist_add_head_rcu(&new->nf_node,
> +                               &nfsd_file_hashtbl[hashval].nfb_head);
> +               spin_unlock(&nfsd_file_hashtbl[hashval].nfb_lock);
> +               nf = new;
> +               new = NULL;
> +               goto open_file;
> +       }
> +       spin_unlock(&nfsd_file_hashtbl[hashval].nfb_lock);
> +
> +wait_for_construction:
> +       wait_on_bit(&nf->nf_flags, NFSD_FILE_PENDING, TASK_UNINTERRUPTIBLE);
> +
> +       /* Did construction of this file fail? */
> +       if (!nf->nf_file) {
> +               /*
> +                * We can only take over construction for this nfsd_file if the
> +                * MAY flags are equal. Otherwise, we put the reference and try
> +                * again.
> +                */
> +               if (may_flags != nf->nf_may) {
> +                       nfsd_file_put(nf);
> +                       goto retry;
> +               }
> +
> +               /* try to take over construction for this file */
> +               if (test_and_set_bit(NFSD_FILE_PENDING, &nf->nf_flags))
> +                       goto wait_for_construction;
> +               goto open_file;
> +       }
> +
> +       /*
> +        * We have a file that was opened in the context of another rqst. We
> +        * must check permissions. Since we're dealing with open files here,
> +        * we always want to set the OWNER_OVERRIDE bit.
> +        */
> +       status = nfsd_permission(rqstp, fhp->fh_export, fhp->fh_dentry,
> +                                       may_flags|NFSD_MAY_OWNER_OVERRIDE);
> +out:
> +       if (status == nfs_ok)
> +               *pnf = nf;
> +       else
> +               nfsd_file_put(nf);
> +
> +       if (new)
> +               nfsd_file_put(new);
> +       return status;
> +open_file:
> +       status = nfsd_open(rqstp, fhp, S_IFREG, may_flags, &nf->nf_file);
> +       clear_bit(NFSD_FILE_PENDING, &nf->nf_flags);
DO you need clear_bit_unlock() and smp_mb__after_atomic() to make sure
waiters can see the flag change when they are waken up?

Cheers,
Tao
> +       wake_up_bit(&nf->nf_flags, NFSD_FILE_PENDING);
> +       goto out;
> +}
> diff --git a/fs/nfsd/filecache.h b/fs/nfsd/filecache.h
> new file mode 100644
> index 000000000000..b0f500353ed4
> --- /dev/null
> +++ b/fs/nfsd/filecache.h
> @@ -0,0 +1,29 @@
> +#ifndef _FS_NFSD_FILECACHE_H
> +#define _FS_NFSD_FILECACHE_H
> +/*
> + * A representation of a file that has been opened by knfsd. These are hashed
> + * in the hashtable by inode pointer value. Note that this object doesn't
> + * hold a reference to the inode by itself, so the nf_inode pointer should
> + * never be dereferenced, only be used for comparison.
> + */
> +struct nfsd_file {
> +       struct hlist_node       nf_node;
> +       struct list_head        nf_dispose;
> +       struct rcu_head         nf_rcu;
> +       struct file             *nf_file;
> +#define NFSD_FILE_HASHED       (0)
> +#define NFSD_FILE_PENDING      (1)
> +       unsigned long           nf_flags;
> +       struct inode            *nf_inode;
> +       unsigned int            nf_hashval;
> +       atomic_t                nf_ref;
> +       unsigned char           nf_may;
> +};
> +
> +int nfsd_file_cache_init(void);
> +void nfsd_file_cache_shutdown(void);
> +void nfsd_file_put(struct nfsd_file *nf);
> +struct nfsd_file *nfsd_file_get(struct nfsd_file *nf);
> +__be32 nfsd_file_acquire(struct svc_rqst *rqstp, struct svc_fh *fhp,
> +                 unsigned int may_flags, struct nfsd_file **nfp);
> +#endif /* _FS_NFSD_FILECACHE_H */
> diff --git a/fs/nfsd/nfssvc.c b/fs/nfsd/nfssvc.c
> index ad4e2377dd63..d816bb3faa6e 100644
> --- a/fs/nfsd/nfssvc.c
> +++ b/fs/nfsd/nfssvc.c
> @@ -22,6 +22,7 @@
>  #include "cache.h"
>  #include "vfs.h"
>  #include "netns.h"
> +#include "filecache.h"
>
>  #define NFSDDBG_FACILITY       NFSDDBG_SVC
>
> @@ -224,11 +225,17 @@ static int nfsd_startup_generic(int nrservs)
>         if (ret)
>                 goto dec_users;
>
> -       ret = nfs4_state_start();
> +       ret = nfsd_file_cache_init();
>         if (ret)
>                 goto out_racache;
> +
> +       ret = nfs4_state_start();
> +       if (ret)
> +               goto out_file_cache;
>         return 0;
>
> +out_file_cache:
> +       nfsd_file_cache_shutdown();
>  out_racache:
>         nfsd_racache_shutdown();
>  dec_users:
> @@ -242,6 +249,7 @@ static void nfsd_shutdown_generic(void)
>                 return;
>
>         nfs4_state_shutdown();
> +       nfsd_file_cache_shutdown();
>         nfsd_racache_shutdown();
>  }
>
> --
> 2.4.3
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
