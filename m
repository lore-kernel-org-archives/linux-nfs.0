Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-wm0-f68.google.com ([74.125.82.68]:35033 "EHLO
	mail-wm0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751103AbcGOIAw convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 15 Jul 2016 04:00:52 -0400
MIME-Version: 1.0
In-Reply-To: <56F61F7E-9B41-45DD-B478-FE9329DD9983@monkey.org>
References: <cover.1429868795.git.agruenba@redhat.com> <39cf890265e2a906a1cf41d6949b5be69903a064.1429868795.git.agruenba@redhat.com>
 <56F61F7E-9B41-45DD-B478-FE9329DD9983@monkey.org>
From: =?UTF-8?Q?Andreas_Gr=C3=BCnbacher?= <andreas.gruenbacher@gmail.com>
Date: Fri, 15 Jul 2016 10:00:49 +0200
Message-ID: <CAHpGcMLdH6HC_JdnO+JS6928U7PSLOV9vZfR085TLmFmt_v__g@mail.gmail.com>
Subject: Re: [RFC v3 42/45] nfs: Add richacl support
To: Weston Andros Adamson <dros@monkey.org>
Cc: Linux Kernel <linux-kernel@vger.kernel.org>,
        Linux FS-devel Mailing List <linux-fsdevel@vger.kernel.org>,
        linux-nfs list <linux-nfs@vger.kernel.org>,
        Weston Adamson <dros@primarydata.com>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Andy,

2016-06-23 18:37 GMT+02:00 Weston Andros Adamson <dros@monkey.org>:
>> On Apr 24, 2015, at 7:04 AM, Andreas Gruenbacher <andreas.gruenbacher@gmail.com> wrote:
>> Changes nfs to support the "system.richacl" xattr instead of "system.nfs4_acl".
>>
>> The "system.nfs4_acl" xattr nfs uses directly exposes the on-the-wire format of
>> NFSv4's acl attribute to user space. This has at least two downsides: (1) the
>> format is different from other file systems, so user-space code needs to be nfs
>> filesystem aware; (2) when symbolic user@domain and group@domain names are used
>> in the acl, user-space needs to perform ID mapping in the same way as the
>> kernel.
>>
>> Previously, when user-space requested only the length of the "system.nfs4_acl"
>> attribute, nfs didn't need to retrieve the entire "system.nfs4_acl" attribute;
>> retrieving its length was enough.  With the "system.richacl" xattr, the length
>> of "system.richacl" cannot be computed from the length of the NFSv4 acl
>> attribute, so we always need to retrieve and cache the acl even when user-space
>> only asks for the length of the "system.richacl" attribute.
>>
>> Because the nfs client now knows which kind of acl the user is trying to set,
>> it will now no longer sends acls with deny entries to servers which didn't
>> declare support for that feature.  The maximum supported size of the NFSv4 acl
>> attribute is now hard coded in the client code and no longer depends on the
>> size of the buffer the user provides to the getxattr system call.  When an acl
>> exceeds this limit, getxattr fails with errno set to ENOMEM.
>>
>> Signed-off-by: Andreas Gruenbacher <agruenba@redhat.com>
>> ---
>> fs/nfs/inode.c            |   3 -
>> fs/nfs/nfs4proc.c         | 354 ++++++++++++++++++++--------------------------
>> fs/nfs/nfs4xdr.c          | 224 +++++++++++++++++++++++++----
>> fs/nfs/super.c            |   4 +-
>> include/linux/nfs_fs.h    |   1 -
>> include/linux/nfs_fs_sb.h |   2 +
>> include/linux/nfs_xdr.h   |   8 +-
>> 7 files changed, 357 insertions(+), 239 deletions(-)
>>
>> diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
>> index d42dff6..e67f72e 100644
>> --- a/fs/nfs/inode.c
>> +++ b/fs/nfs/inode.c
>> @@ -1824,9 +1824,6 @@ struct inode *nfs_alloc_inode(struct super_block *sb)
>>               return NULL;
>>       nfsi->flags = 0UL;
>>       nfsi->cache_validity = 0UL;
>> -#if IS_ENABLED(CONFIG_NFS_V4)
>> -     nfsi->nfs4_acl = NULL;
>> -#endif /* CONFIG_NFS_V4 */
>>       return &nfsi->vfs_inode;
>> }
>> EXPORT_SYMBOL_GPL(nfs_alloc_inode);
>> diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
>> index 8c50670..c2ba4f0 100644
>> --- a/fs/nfs/nfs4proc.c
>> +++ b/fs/nfs/nfs4proc.c
>> @@ -55,6 +55,8 @@
>> #include <linux/xattr.h>
>> #include <linux/utsname.h>
>> #include <linux/freezer.h>
>> +#include <linux/richacl.h>
>> +#include <linux/richacl_xattr.h>
>>
>> #include "nfs4_fs.h"
>> #include "delegation.h"
>> @@ -2892,15 +2894,18 @@ static int _nfs4_server_capabilities(struct nfs_server *server, struct nfs_fh *f
>>                       res.attr_bitmask[2] &= FATTR4_WORD2_NFS42_MASK;
>>               }
>>               memcpy(server->attr_bitmask, res.attr_bitmask, sizeof(server->attr_bitmask));
>> -             server->caps &= ~(NFS_CAP_ACLS|NFS_CAP_HARDLINKS|
>> -                             NFS_CAP_SYMLINKS|NFS_CAP_FILEID|
>> +             server->caps &= ~(NFS_CAP_ALLOW_ACLS|NFS_CAP_DENY_ACLS|
>> +                             NFS_CAP_HARDLINKS|NFS_CAP_SYMLINKS|NFS_CAP_FILEID|
>>                               NFS_CAP_MODE|NFS_CAP_NLINK|NFS_CAP_OWNER|
>>                               NFS_CAP_OWNER_GROUP|NFS_CAP_ATIME|
>>                               NFS_CAP_CTIME|NFS_CAP_MTIME|
>>                               NFS_CAP_SECURITY_LABEL);
>> -             if (res.attr_bitmask[0] & FATTR4_WORD0_ACL &&
>> -                             res.acl_bitmask & ACL4_SUPPORT_ALLOW_ACL)
>> -                     server->caps |= NFS_CAP_ACLS;
>> +             if (res.attr_bitmask[0] & FATTR4_WORD0_ACL) {
>> +                     if (res.acl_bitmask & ACL4_SUPPORT_ALLOW_ACL)
>> +                             server->caps |= NFS_CAP_ALLOW_ACLS;
>> +                     if (res.acl_bitmask & ACL4_SUPPORT_DENY_ACL)
>> +                             server->caps |= NFS_CAP_DENY_ACLS;
>> +             }
>>               if (res.has_links != 0)
>>                       server->caps |= NFS_CAP_HARDLINKS;
>>               if (res.has_symlinks != 0)
>> @@ -4428,45 +4433,11 @@ static int nfs4_proc_renew(struct nfs_client *clp, struct rpc_cred *cred)
>>       return 0;
>> }
>>
>> -static inline int nfs4_server_supports_acls(struct nfs_server *server)
>> -{
>> -     return server->caps & NFS_CAP_ACLS;
>> -}
>> -
>> -/* Assuming that XATTR_SIZE_MAX is a multiple of PAGE_SIZE, and that
>> - * it's OK to put sizeof(void) * (XATTR_SIZE_MAX/PAGE_SIZE) bytes on
>> - * the stack.
>> +/* A arbitrary limit; we allocate at most DIV_ROUND_UP(NFS4ACL_SIZE_MAX,
>> + * PAGE_SIZE) pages and put an array of DIV_ROUND_UP(NFS4ACL_SIZE_MAX,
>> + * PAGE_SIZE) pages on the stack when encoding or decoding acls.
>>  */
>> -#define NFS4ACL_MAXPAGES DIV_ROUND_UP(XATTR_SIZE_MAX, PAGE_SIZE)
>> -
>> -static int buf_to_pages_noslab(const void *buf, size_t buflen,
>> -             struct page **pages)
>> -{
>> -     struct page *newpage, **spages;
>> -     int rc = 0;
>> -     size_t len;
>> -     spages = pages;
>> -
>> -     do {
>> -             len = min_t(size_t, PAGE_SIZE, buflen);
>> -             newpage = alloc_page(GFP_KERNEL);
>> -
>> -             if (newpage == NULL)
>> -                     goto unwind;
>> -             memcpy(page_address(newpage), buf, len);
>> -                buf += len;
>> -                buflen -= len;
>> -             *pages++ = newpage;
>> -             rc++;
>> -     } while (buflen != 0);
>> -
>> -     return rc;
>> -
>> -unwind:
>> -     for(; rc > 0; rc--)
>> -             __free_page(spages[rc-1]);
>> -     return -ENOMEM;
>> -}
>> +#define NFS4ACL_SIZE_MAX 65536
>>
>> struct nfs4_cached_acl {
>>       int cached;
>> @@ -4474,66 +4445,9 @@ struct nfs4_cached_acl {
>>       char data[0];
>> };
>>
>> -static void nfs4_set_cached_acl(struct inode *inode, struct nfs4_cached_acl *acl)
>> -{
>> -     struct nfs_inode *nfsi = NFS_I(inode);
>> -
>> -     spin_lock(&inode->i_lock);
>> -     kfree(nfsi->nfs4_acl);
>> -     nfsi->nfs4_acl = acl;
>> -     spin_unlock(&inode->i_lock);
>> -}
>> -
>> static void nfs4_zap_acl_attr(struct inode *inode)
>> {
>> -     nfs4_set_cached_acl(inode, NULL);
>> -}
>> -
>> -static inline ssize_t nfs4_read_cached_acl(struct inode *inode, char *buf, size_t buflen)
>> -{
>> -     struct nfs_inode *nfsi = NFS_I(inode);
>> -     struct nfs4_cached_acl *acl;
>> -     int ret = -ENOENT;
>> -
>> -     spin_lock(&inode->i_lock);
>> -     acl = nfsi->nfs4_acl;
>> -     if (acl == NULL)
>> -             goto out;
>> -     if (buf == NULL) /* user is just asking for length */
>> -             goto out_len;
>> -     if (acl->cached == 0)
>> -             goto out;
>> -     ret = -ERANGE; /* see getxattr(2) man page */
>> -     if (acl->len > buflen)
>> -             goto out;
>> -     memcpy(buf, acl->data, acl->len);
>> -out_len:
>> -     ret = acl->len;
>> -out:
>> -     spin_unlock(&inode->i_lock);
>> -     return ret;
>> -}
>> -
>> -static void nfs4_write_cached_acl(struct inode *inode, struct page **pages, size_t pgbase, size_t acl_len)
>> -{
>> -     struct nfs4_cached_acl *acl;
>> -     size_t buflen = sizeof(*acl) + acl_len;
>> -
>> -     if (buflen <= PAGE_SIZE) {
>> -             acl = kmalloc(buflen, GFP_KERNEL);
>> -             if (acl == NULL)
>> -                     goto out;
>> -             acl->cached = 1;
>> -             _copy_from_pages(acl->data, pages, pgbase, acl_len);
>> -     } else {
>> -             acl = kmalloc(sizeof(*acl), GFP_KERNEL);
>> -             if (acl == NULL)
>> -                     goto out;
>> -             acl->cached = 0;
>> -     }
>> -     acl->len = acl_len;
>> -out:
>> -     nfs4_set_cached_acl(inode, acl);
>> +     forget_cached_richacl(inode);
>> }
>>
>> /*
>> @@ -4546,121 +4460,128 @@ out:
>>  * length. The next getxattr call will then produce another round trip to
>>  * the server, this time with the input buf of the required size.
>>  */
>> -static ssize_t __nfs4_get_acl_uncached(struct inode *inode, void *buf, size_t buflen)
>> +static struct richacl *__nfs4_get_acl_uncached(struct inode *inode)
>> {
>> -     struct page *pages[NFS4ACL_MAXPAGES] = {NULL, };
>> +     struct nfs_server *server = NFS_SERVER(inode);
>> +     struct page *pages[DIV_ROUND_UP(NFS4ACL_SIZE_MAX, PAGE_SIZE)] = {};
>>       struct nfs_getaclargs args = {
>>               .fh = NFS_FH(inode),
>>               .acl_pages = pages,
>> -             .acl_len = buflen,
>> +             .acl_len = ARRAY_SIZE(pages) * PAGE_SIZE,
>>       };
>>       struct nfs_getaclres res = {
>> -             .acl_len = buflen,
>> +             .server = server,
>>       };
>>       struct rpc_message msg = {
>>               .rpc_proc = &nfs4_procedures[NFSPROC4_CLNT_GETACL],
>>               .rpc_argp = &args,
>>               .rpc_resp = &res,
>>       };
>> -     unsigned int npages = DIV_ROUND_UP(buflen, PAGE_SIZE);
>> -     int ret = -ENOMEM, i;
>> +     mode_t mode;
>> +     int err, i;
>>
>> -     /* As long as we're doing a round trip to the server anyway,
>> -      * let's be prepared for a page of acl data. */
>> -     if (npages == 0)
>> -             npages = 1;
>> -     if (npages > ARRAY_SIZE(pages))
>> -             return -ERANGE;
>> -
>> -     for (i = 0; i < npages; i++) {
>> -             pages[i] = alloc_page(GFP_KERNEL);
>> -             if (!pages[i])
>> +     if (ARRAY_SIZE(pages) > 1) {
>> +             /* for decoding across pages */
>> +             res.acl_scratch = alloc_page(GFP_KERNEL);
>> +             err = -ENOMEM;
>> +             if (!res.acl_scratch)
>>                       goto out_free;
>>       }
>>
>> -     /* for decoding across pages */
>> -     res.acl_scratch = alloc_page(GFP_KERNEL);
>> -     if (!res.acl_scratch)
>> -             goto out_free;
>> -
>> -     args.acl_len = npages * PAGE_SIZE;
>> -
>> -     dprintk("%s  buf %p buflen %zu npages %d args.acl_len %zu\n",
>> -             __func__, buf, buflen, npages, args.acl_len);
>> -     ret = nfs4_call_sync(NFS_SERVER(inode)->client, NFS_SERVER(inode),
>> +     dprintk("%s  args.acl_len %zu\n",
>> +             __func__, args.acl_len);
>> +     err = nfs4_call_sync(NFS_SERVER(inode)->client, NFS_SERVER(inode),
>>                            &msg, &args.seq_args, &res.seq_res, 0);
>> -     if (ret)
>> +     if (err)
>>               goto out_free;
>>
>> -     /* Handle the case where the passed-in buffer is too short */
>> -     if (res.acl_flags & NFS4_ACL_TRUNC) {
>> -             /* Did the user only issue a request for the acl length? */
>> -             if (buf == NULL)
>> -                     goto out_ok;
>> -             ret = -ERANGE;
>> -             goto out_free;
>> -     }
>> -     nfs4_write_cached_acl(inode, pages, res.acl_data_offset, res.acl_len);
>> -     if (buf) {
>> -             if (res.acl_len > buflen) {
>> -                     ret = -ERANGE;
>> -                     goto out_free;
>> -             }
>> -             _copy_from_pages(buf, pages, res.acl_data_offset, res.acl_len);
>> -     }
>> -out_ok:
>> -     ret = res.acl_len;
>> +     mode = inode->i_mode & S_IFMT;
>> +     if (__richacl_equiv_mode(res.acl, &mode) == 0 &&
>> +         ((mode ^ res.mode) & S_IRWXUGO) == 0) {
>> +             richacl_put(res.acl);
>> +             res.acl = NULL;
>> +     } else
>> +             richacl_compute_max_masks(res.acl);
>> +     /* FIXME: Set inode->i_mode from res->mode?  */
>> +     set_cached_richacl(inode, res.acl);
>> +     err = 0;
>> +
>> out_free:
>> -     for (i = 0; i < npages; i++)
>> -             if (pages[i])
>> -                     __free_page(pages[i]);
>> +     if (err) {
>> +             richacl_put(res.acl);
>> +             res.acl = ERR_PTR(err);
>> +     }
>> +     for (i = 0; i < ARRAY_SIZE(pages) && pages[i]; i++)
>> +             __free_page(pages[i]);
>>       if (res.acl_scratch)
>>               __free_page(res.acl_scratch);
>> -     return ret;
>> +     return res.acl;
>> }
>>
>> -static ssize_t nfs4_get_acl_uncached(struct inode *inode, void *buf, size_t buflen)
>> +static struct richacl *nfs4_get_acl_uncached(struct inode *inode)
>> {
>>       struct nfs4_exception exception = { };
>> -     ssize_t ret;
>> +     struct richacl *acl;
>>       do {
>> -             ret = __nfs4_get_acl_uncached(inode, buf, buflen);
>> -             trace_nfs4_get_acl(inode, ret);
>> -             if (ret >= 0)
>> +             acl = __nfs4_get_acl_uncached(inode);
>> +             trace_nfs4_get_acl(inode, IS_ERR(acl) ? PTR_ERR(acl) : 0);
>> +             if (!IS_ERR(acl))
>>                       break;
>> -             ret = nfs4_handle_exception(NFS_SERVER(inode), ret, &exception);
>> +             acl = ERR_PTR(nfs4_handle_exception(NFS_SERVER(inode), PTR_ERR(acl), &exception));
>>       } while (exception.retry);
>> -     return ret;
>> +     return acl;
>> }
>>
>> -static ssize_t nfs4_proc_get_acl(struct inode *inode, void *buf, size_t buflen)
>> +static struct richacl *nfs4_proc_get_acl(struct inode *inode)
>> {
>>       struct nfs_server *server = NFS_SERVER(inode);
>> +     struct richacl *acl;
>>       int ret;
>>
>> -     if (!nfs4_server_supports_acls(server))
>> -             return -EOPNOTSUPP;
>> +     if (!(server->caps & (NFS_CAP_ALLOW_ACLS | NFS_CAP_DENY_ACLS)))
>> +             return ERR_PTR(-EOPNOTSUPP);
>>       ret = nfs_revalidate_inode(server, inode);
>>       if (ret < 0)
>> -             return ret;
>> +             return ERR_PTR(ret);
>>       if (NFS_I(inode)->cache_validity & NFS_INO_INVALID_ACL)
>>               nfs_zap_acl_cache(inode);
>> -     ret = nfs4_read_cached_acl(inode, buf, buflen);
>> -     if (ret != -ENOENT)
>> -             /* -ENOENT is returned if there is no ACL or if there is an ACL
>> -              * but no cached acl data, just the acl length */
>> -             return ret;
>> -     return nfs4_get_acl_uncached(inode, buf, buflen);
>> +     acl = get_cached_richacl(inode);
>> +     if (acl != ACL_NOT_CACHED)
>> +             return acl;
>> +     return nfs4_get_acl_uncached(inode);
>> +}
>> +
>> +static int
>> +richacl_supported(struct nfs_server *server, struct richacl *acl)
>> +{
>> +     struct richace *ace;
>> +
>> +     if (!(server->caps & (NFS_CAP_ALLOW_ACLS | NFS_CAP_DENY_ACLS)))
>> +             return -EOPNOTSUPP;
>> +
>> +     richacl_for_each_entry(ace, acl) {
>> +             if (richace_is_allow(ace)) {
>> +                     if (!(server->caps & NFS_CAP_ALLOW_ACLS))
>> +                             return -EINVAL;
>> +             } else if (richace_is_deny(ace)) {
>> +                     if (!(server->caps & NFS_CAP_DENY_ACLS))
>> +                             return -EINVAL;
>> +             } else
>> +                     return -EINVAL;
>> +     }
>> +     return 0;
>> }
>>
>> -static int __nfs4_proc_set_acl(struct inode *inode, const void *buf, size_t buflen)
>> +static int __nfs4_proc_set_acl(struct inode *inode, struct richacl *acl)
>> {
>>       struct nfs_server *server = NFS_SERVER(inode);
>> -     struct page *pages[NFS4ACL_MAXPAGES];
>> +     struct page *pages[DIV_ROUND_UP(NFS4ACL_SIZE_MAX, PAGE_SIZE) + 1 /* scratch */] = {};
>>       struct nfs_setaclargs arg = {
>> +             .server         = server,
>>               .fh             = NFS_FH(inode),
>> +             .acl            = acl,
>>               .acl_pages      = pages,
>> -             .acl_len        = buflen,
>> +             .acl_len        = ARRAY_SIZE(pages) * PAGE_SIZE,
>>       };
>>       struct nfs_setaclres res;
>>       struct rpc_message msg = {
>> @@ -4668,16 +4589,12 @@ static int __nfs4_proc_set_acl(struct inode *inode, const void *buf, size_t bufl
>>               .rpc_argp       = &arg,
>>               .rpc_resp       = &res,
>>       };
>> -     unsigned int npages = DIV_ROUND_UP(buflen, PAGE_SIZE);
>>       int ret, i;
>>
>> -     if (!nfs4_server_supports_acls(server))
>> -             return -EOPNOTSUPP;
>> -     if (npages > ARRAY_SIZE(pages))
>> -             return -ERANGE;
>> -     i = buf_to_pages_noslab(buf, buflen, arg.acl_pages);
>> -     if (i < 0)
>> -             return i;
>> +     ret = richacl_supported(server, acl);
>> +     if (ret)
>> +             return ret;
>> +
>>       nfs4_inode_return_delegation(inode);
>>       ret = nfs4_call_sync(server->client, server, &msg, &arg.seq_args, &res.seq_res, 1);
>>
>> @@ -4685,8 +4602,8 @@ static int __nfs4_proc_set_acl(struct inode *inode, const void *buf, size_t bufl
>>        * Free each page after tx, so the only ref left is
>>        * held by the network stack
>>        */
>> -     for (; i > 0; i--)
>> -             put_page(pages[i-1]);
>> +     for (i = 0; pages[i]; i++)
>> +             put_page(pages[i]);
>>
>>       /*
>>        * Acl update can result in inode attribute update.
>> @@ -4700,12 +4617,12 @@ static int __nfs4_proc_set_acl(struct inode *inode, const void *buf, size_t bufl
>>       return ret;
>> }
>>
>> -static int nfs4_proc_set_acl(struct inode *inode, const void *buf, size_t buflen)
>> +static int nfs4_proc_set_acl(struct inode *inode, struct richacl *acl)
>> {
>>       struct nfs4_exception exception = { };
>>       int err;
>>       do {
>> -             err = __nfs4_proc_set_acl(inode, buf, buflen);
>> +             err = __nfs4_proc_set_acl(inode, acl);
>>               trace_nfs4_set_acl(inode, err);
>>               err = nfs4_handle_exception(NFS_SERVER(inode), err,
>>                               &exception);
>> @@ -6102,38 +6019,69 @@ nfs4_release_lockowner(struct nfs_server *server, struct nfs4_lock_state *lsp)
>>       rpc_call_async(server->client, &msg, 0, &nfs4_release_lockowner_ops, data);
>> }
>>
>> -#define XATTR_NAME_NFSV4_ACL "system.nfs4_acl"
>> -
>> -static int nfs4_xattr_set_nfs4_acl(struct dentry *dentry, const char *key,
>> -                                const void *buf, size_t buflen,
>> -                                int flags, int type)
>> +static int nfs4_xattr_set_richacl(struct dentry *dentry, const char *key,
>> +                               const void *buf, size_t buflen,
>> +                               int flags, int handler_flags)
>> {
>> +     struct richacl *acl;
>> +     int error;
>> +
>>       if (strcmp(key, "") != 0)
>>               return -EINVAL;
>>
>> -     return nfs4_proc_set_acl(dentry->d_inode, buf, buflen);
>> +     if (buf) {
>> +             acl = richacl_from_xattr(&init_user_ns, buf, buflen);
>> +             if (IS_ERR(acl))
>> +                     return PTR_ERR(acl);
>> +             error = richacl_apply_masks(&acl);
>
> Hi Andreas,
>
> First, let me say thanks for all the work! We (Primary Data) have been using
> samba with the vfs_richacl module reexporting an nfsv4.2 mount and things are
> working pretty well. You can count on us for testing, bug fixing and code review.

Thanks!

> Now for my question: It looks like this call to richacl_apply_masks in the client
> xattr_set path exists so that the knfsd permission check algorithm works correctly.
> This makes some pretty big assumptions about the server’s implementation.
> There are other servers out there besides knfsd!
>
> I think this will have to be fixed before this patch can be accepted. I’m willing to
> help, but I’m wondering where this should be fixed:
>
> Do we call richacl_apply_masks on the server before setting the xattr so the
> normalized acl is saved, or should we save the ACL as-is and call
> richacl_apply_masks before it’s used?

nfs4_xattr_set_richacl is invoked client-side, by setting the
"system.richacl" xattr, with a Richacl as the argument. The NFSv4
protocol doesn't know about file masks, so the Richacl must be
translated into a pure NFSv4 ACL. This is what richacl_apply_masks
effectively does. The resulting NFSv4 ACL is then sent to the server.

On the server side, some of the exported filesystems may support
richacls. Before those can be sent to an NFSv4 client,
richacl_apply_masks is used to turn the Richacl into an NFSv4 ACL as
well.

(Ideally, we'd have an NFSv4 protocol extension that would allow us to
preserve the file masks between servers and clients that understand
them, and we could get rid of richacl_apply_masks in that case.)

Thanks,
Andreas
