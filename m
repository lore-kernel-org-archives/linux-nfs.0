Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f67.google.com ([209.85.214.67]:34127 "EHLO
	mail-it0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751999AbcFWQhE convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 23 Jun 2016 12:37:04 -0400
Content-Type: text/plain; charset=utf-8
Mime-Version: 1.0 (Mac OS X Mail 9.3 \(3124\))
Subject: Re: [RFC v3 42/45] nfs: Add richacl support
From: Weston Andros Adamson <dros@monkey.org>
In-Reply-To: <39cf890265e2a906a1cf41d6949b5be69903a064.1429868795.git.agruenba@redhat.com>
Date: Thu, 23 Jun 2016 12:37:00 -0400
Cc: Linux Kernel <linux-kernel@vger.kernel.org>, linux-fsdevel@vger.kernel.org,
        linux-nfs list <linux-nfs@vger.kernel.org>,
        Weston Adamson <dros@primarydata.com>
Message-Id: <56F61F7E-9B41-45DD-B478-FE9329DD9983@monkey.org>
References: <cover.1429868795.git.agruenba@redhat.com> <cover.1429868795.git.agruenba@redhat.com> <39cf890265e2a906a1cf41d6949b5be69903a064.1429868795.git.agruenba@redhat.com>
To: Andreas Gruenbacher <andreas.gruenbacher@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


> On Apr 24, 2015, at 7:04 AM, Andreas Gruenbacher <andreas.gruenbacher@gmail.com> wrote:
> 
> Changes nfs to support the "system.richacl" xattr instead of "system.nfs4_acl".
> 
> The "system.nfs4_acl" xattr nfs uses directly exposes the on-the-wire format of
> NFSv4's acl attribute to user space. This has at least two downsides: (1) the
> format is different from other file systems, so user-space code needs to be nfs
> filesystem aware; (2) when symbolic user@domain and group@domain names are used
> in the acl, user-space needs to perform ID mapping in the same way as the
> kernel.
> 
> Previously, when user-space requested only the length of the "system.nfs4_acl"
> attribute, nfs didn't need to retrieve the entire "system.nfs4_acl" attribute;
> retrieving its length was enough.  With the "system.richacl" xattr, the length
> of "system.richacl" cannot be computed from the length of the NFSv4 acl
> attribute, so we always need to retrieve and cache the acl even when user-space
> only asks for the length of the "system.richacl" attribute.
> 
> Because the nfs client now knows which kind of acl the user is trying to set,
> it will now no longer sends acls with deny entries to servers which didn't
> declare support for that feature.  The maximum supported size of the NFSv4 acl
> attribute is now hard coded in the client code and no longer depends on the
> size of the buffer the user provides to the getxattr system call.  When an acl
> exceeds this limit, getxattr fails with errno set to ENOMEM.
> 
> Signed-off-by: Andreas Gruenbacher <agruenba@redhat.com>
> ---
> fs/nfs/inode.c            |   3 -
> fs/nfs/nfs4proc.c         | 354 ++++++++++++++++++++--------------------------
> fs/nfs/nfs4xdr.c          | 224 +++++++++++++++++++++++++----
> fs/nfs/super.c            |   4 +-
> include/linux/nfs_fs.h    |   1 -
> include/linux/nfs_fs_sb.h |   2 +
> include/linux/nfs_xdr.h   |   8 +-
> 7 files changed, 357 insertions(+), 239 deletions(-)
> 
> diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
> index d42dff6..e67f72e 100644
> --- a/fs/nfs/inode.c
> +++ b/fs/nfs/inode.c
> @@ -1824,9 +1824,6 @@ struct inode *nfs_alloc_inode(struct super_block *sb)
> 		return NULL;
> 	nfsi->flags = 0UL;
> 	nfsi->cache_validity = 0UL;
> -#if IS_ENABLED(CONFIG_NFS_V4)
> -	nfsi->nfs4_acl = NULL;
> -#endif /* CONFIG_NFS_V4 */
> 	return &nfsi->vfs_inode;
> }
> EXPORT_SYMBOL_GPL(nfs_alloc_inode);
> diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
> index 8c50670..c2ba4f0 100644
> --- a/fs/nfs/nfs4proc.c
> +++ b/fs/nfs/nfs4proc.c
> @@ -55,6 +55,8 @@
> #include <linux/xattr.h>
> #include <linux/utsname.h>
> #include <linux/freezer.h>
> +#include <linux/richacl.h>
> +#include <linux/richacl_xattr.h>
> 
> #include "nfs4_fs.h"
> #include "delegation.h"
> @@ -2892,15 +2894,18 @@ static int _nfs4_server_capabilities(struct nfs_server *server, struct nfs_fh *f
> 			res.attr_bitmask[2] &= FATTR4_WORD2_NFS42_MASK;
> 		}
> 		memcpy(server->attr_bitmask, res.attr_bitmask, sizeof(server->attr_bitmask));
> -		server->caps &= ~(NFS_CAP_ACLS|NFS_CAP_HARDLINKS|
> -				NFS_CAP_SYMLINKS|NFS_CAP_FILEID|
> +		server->caps &= ~(NFS_CAP_ALLOW_ACLS|NFS_CAP_DENY_ACLS|
> +				NFS_CAP_HARDLINKS|NFS_CAP_SYMLINKS|NFS_CAP_FILEID|
> 				NFS_CAP_MODE|NFS_CAP_NLINK|NFS_CAP_OWNER|
> 				NFS_CAP_OWNER_GROUP|NFS_CAP_ATIME|
> 				NFS_CAP_CTIME|NFS_CAP_MTIME|
> 				NFS_CAP_SECURITY_LABEL);
> -		if (res.attr_bitmask[0] & FATTR4_WORD0_ACL &&
> -				res.acl_bitmask & ACL4_SUPPORT_ALLOW_ACL)
> -			server->caps |= NFS_CAP_ACLS;
> +		if (res.attr_bitmask[0] & FATTR4_WORD0_ACL) {
> +			if (res.acl_bitmask & ACL4_SUPPORT_ALLOW_ACL)
> +				server->caps |= NFS_CAP_ALLOW_ACLS;
> +			if (res.acl_bitmask & ACL4_SUPPORT_DENY_ACL)
> +				server->caps |= NFS_CAP_DENY_ACLS;
> +		}
> 		if (res.has_links != 0)
> 			server->caps |= NFS_CAP_HARDLINKS;
> 		if (res.has_symlinks != 0)
> @@ -4428,45 +4433,11 @@ static int nfs4_proc_renew(struct nfs_client *clp, struct rpc_cred *cred)
> 	return 0;
> }
> 
> -static inline int nfs4_server_supports_acls(struct nfs_server *server)
> -{
> -	return server->caps & NFS_CAP_ACLS;
> -}
> -
> -/* Assuming that XATTR_SIZE_MAX is a multiple of PAGE_SIZE, and that
> - * it's OK to put sizeof(void) * (XATTR_SIZE_MAX/PAGE_SIZE) bytes on
> - * the stack.
> +/* A arbitrary limit; we allocate at most DIV_ROUND_UP(NFS4ACL_SIZE_MAX,
> + * PAGE_SIZE) pages and put an array of DIV_ROUND_UP(NFS4ACL_SIZE_MAX,
> + * PAGE_SIZE) pages on the stack when encoding or decoding acls.
>  */
> -#define NFS4ACL_MAXPAGES DIV_ROUND_UP(XATTR_SIZE_MAX, PAGE_SIZE)
> -
> -static int buf_to_pages_noslab(const void *buf, size_t buflen,
> -		struct page **pages)
> -{
> -	struct page *newpage, **spages;
> -	int rc = 0;
> -	size_t len;
> -	spages = pages;
> -
> -	do {
> -		len = min_t(size_t, PAGE_SIZE, buflen);
> -		newpage = alloc_page(GFP_KERNEL);
> -
> -		if (newpage == NULL)
> -			goto unwind;
> -		memcpy(page_address(newpage), buf, len);
> -                buf += len;
> -                buflen -= len;
> -		*pages++ = newpage;
> -		rc++;
> -	} while (buflen != 0);
> -
> -	return rc;
> -
> -unwind:
> -	for(; rc > 0; rc--)
> -		__free_page(spages[rc-1]);
> -	return -ENOMEM;
> -}
> +#define NFS4ACL_SIZE_MAX 65536
> 
> struct nfs4_cached_acl {
> 	int cached;
> @@ -4474,66 +4445,9 @@ struct nfs4_cached_acl {
> 	char data[0];
> };
> 
> -static void nfs4_set_cached_acl(struct inode *inode, struct nfs4_cached_acl *acl)
> -{
> -	struct nfs_inode *nfsi = NFS_I(inode);
> -
> -	spin_lock(&inode->i_lock);
> -	kfree(nfsi->nfs4_acl);
> -	nfsi->nfs4_acl = acl;
> -	spin_unlock(&inode->i_lock);
> -}
> -
> static void nfs4_zap_acl_attr(struct inode *inode)
> {
> -	nfs4_set_cached_acl(inode, NULL);
> -}
> -
> -static inline ssize_t nfs4_read_cached_acl(struct inode *inode, char *buf, size_t buflen)
> -{
> -	struct nfs_inode *nfsi = NFS_I(inode);
> -	struct nfs4_cached_acl *acl;
> -	int ret = -ENOENT;
> -
> -	spin_lock(&inode->i_lock);
> -	acl = nfsi->nfs4_acl;
> -	if (acl == NULL)
> -		goto out;
> -	if (buf == NULL) /* user is just asking for length */
> -		goto out_len;
> -	if (acl->cached == 0)
> -		goto out;
> -	ret = -ERANGE; /* see getxattr(2) man page */
> -	if (acl->len > buflen)
> -		goto out;
> -	memcpy(buf, acl->data, acl->len);
> -out_len:
> -	ret = acl->len;
> -out:
> -	spin_unlock(&inode->i_lock);
> -	return ret;
> -}
> -
> -static void nfs4_write_cached_acl(struct inode *inode, struct page **pages, size_t pgbase, size_t acl_len)
> -{
> -	struct nfs4_cached_acl *acl;
> -	size_t buflen = sizeof(*acl) + acl_len;
> -
> -	if (buflen <= PAGE_SIZE) {
> -		acl = kmalloc(buflen, GFP_KERNEL);
> -		if (acl == NULL)
> -			goto out;
> -		acl->cached = 1;
> -		_copy_from_pages(acl->data, pages, pgbase, acl_len);
> -	} else {
> -		acl = kmalloc(sizeof(*acl), GFP_KERNEL);
> -		if (acl == NULL)
> -			goto out;
> -		acl->cached = 0;
> -	}
> -	acl->len = acl_len;
> -out:
> -	nfs4_set_cached_acl(inode, acl);
> +	forget_cached_richacl(inode);
> }
> 
> /*
> @@ -4546,121 +4460,128 @@ out:
>  * length. The next getxattr call will then produce another round trip to
>  * the server, this time with the input buf of the required size.
>  */
> -static ssize_t __nfs4_get_acl_uncached(struct inode *inode, void *buf, size_t buflen)
> +static struct richacl *__nfs4_get_acl_uncached(struct inode *inode)
> {
> -	struct page *pages[NFS4ACL_MAXPAGES] = {NULL, };
> +	struct nfs_server *server = NFS_SERVER(inode);
> +	struct page *pages[DIV_ROUND_UP(NFS4ACL_SIZE_MAX, PAGE_SIZE)] = {};
> 	struct nfs_getaclargs args = {
> 		.fh = NFS_FH(inode),
> 		.acl_pages = pages,
> -		.acl_len = buflen,
> +		.acl_len = ARRAY_SIZE(pages) * PAGE_SIZE,
> 	};
> 	struct nfs_getaclres res = {
> -		.acl_len = buflen,
> +		.server = server,
> 	};
> 	struct rpc_message msg = {
> 		.rpc_proc = &nfs4_procedures[NFSPROC4_CLNT_GETACL],
> 		.rpc_argp = &args,
> 		.rpc_resp = &res,
> 	};
> -	unsigned int npages = DIV_ROUND_UP(buflen, PAGE_SIZE);
> -	int ret = -ENOMEM, i;
> +	mode_t mode;
> +	int err, i;
> 
> -	/* As long as we're doing a round trip to the server anyway,
> -	 * let's be prepared for a page of acl data. */
> -	if (npages == 0)
> -		npages = 1;
> -	if (npages > ARRAY_SIZE(pages))
> -		return -ERANGE;
> -
> -	for (i = 0; i < npages; i++) {
> -		pages[i] = alloc_page(GFP_KERNEL);
> -		if (!pages[i])
> +	if (ARRAY_SIZE(pages) > 1) {
> +		/* for decoding across pages */
> +		res.acl_scratch = alloc_page(GFP_KERNEL);
> +		err = -ENOMEM;
> +		if (!res.acl_scratch)
> 			goto out_free;
> 	}
> 
> -	/* for decoding across pages */
> -	res.acl_scratch = alloc_page(GFP_KERNEL);
> -	if (!res.acl_scratch)
> -		goto out_free;
> -
> -	args.acl_len = npages * PAGE_SIZE;
> -
> -	dprintk("%s  buf %p buflen %zu npages %d args.acl_len %zu\n",
> -		__func__, buf, buflen, npages, args.acl_len);
> -	ret = nfs4_call_sync(NFS_SERVER(inode)->client, NFS_SERVER(inode),
> +	dprintk("%s  args.acl_len %zu\n",
> +		__func__, args.acl_len);
> +	err = nfs4_call_sync(NFS_SERVER(inode)->client, NFS_SERVER(inode),
> 			     &msg, &args.seq_args, &res.seq_res, 0);
> -	if (ret)
> +	if (err)
> 		goto out_free;
> 
> -	/* Handle the case where the passed-in buffer is too short */
> -	if (res.acl_flags & NFS4_ACL_TRUNC) {
> -		/* Did the user only issue a request for the acl length? */
> -		if (buf == NULL)
> -			goto out_ok;
> -		ret = -ERANGE;
> -		goto out_free;
> -	}
> -	nfs4_write_cached_acl(inode, pages, res.acl_data_offset, res.acl_len);
> -	if (buf) {
> -		if (res.acl_len > buflen) {
> -			ret = -ERANGE;
> -			goto out_free;
> -		}
> -		_copy_from_pages(buf, pages, res.acl_data_offset, res.acl_len);
> -	}
> -out_ok:
> -	ret = res.acl_len;
> +	mode = inode->i_mode & S_IFMT;
> +	if (__richacl_equiv_mode(res.acl, &mode) == 0 &&
> +	    ((mode ^ res.mode) & S_IRWXUGO) == 0) {
> +		richacl_put(res.acl);
> +		res.acl = NULL;
> +	} else
> +		richacl_compute_max_masks(res.acl);
> +	/* FIXME: Set inode->i_mode from res->mode?  */
> +	set_cached_richacl(inode, res.acl);
> +	err = 0;
> +
> out_free:
> -	for (i = 0; i < npages; i++)
> -		if (pages[i])
> -			__free_page(pages[i]);
> +	if (err) {
> +		richacl_put(res.acl);
> +		res.acl = ERR_PTR(err);
> +	}
> +	for (i = 0; i < ARRAY_SIZE(pages) && pages[i]; i++)
> +		__free_page(pages[i]);
> 	if (res.acl_scratch)
> 		__free_page(res.acl_scratch);
> -	return ret;
> +	return res.acl;
> }
> 
> -static ssize_t nfs4_get_acl_uncached(struct inode *inode, void *buf, size_t buflen)
> +static struct richacl *nfs4_get_acl_uncached(struct inode *inode)
> {
> 	struct nfs4_exception exception = { };
> -	ssize_t ret;
> +	struct richacl *acl;
> 	do {
> -		ret = __nfs4_get_acl_uncached(inode, buf, buflen);
> -		trace_nfs4_get_acl(inode, ret);
> -		if (ret >= 0)
> +		acl = __nfs4_get_acl_uncached(inode);
> +		trace_nfs4_get_acl(inode, IS_ERR(acl) ? PTR_ERR(acl) : 0);
> +		if (!IS_ERR(acl))
> 			break;
> -		ret = nfs4_handle_exception(NFS_SERVER(inode), ret, &exception);
> +		acl = ERR_PTR(nfs4_handle_exception(NFS_SERVER(inode), PTR_ERR(acl), &exception));
> 	} while (exception.retry);
> -	return ret;
> +	return acl;
> }
> 
> -static ssize_t nfs4_proc_get_acl(struct inode *inode, void *buf, size_t buflen)
> +static struct richacl *nfs4_proc_get_acl(struct inode *inode)
> {
> 	struct nfs_server *server = NFS_SERVER(inode);
> +	struct richacl *acl;
> 	int ret;
> 
> -	if (!nfs4_server_supports_acls(server))
> -		return -EOPNOTSUPP;
> +	if (!(server->caps & (NFS_CAP_ALLOW_ACLS | NFS_CAP_DENY_ACLS)))
> +		return ERR_PTR(-EOPNOTSUPP);
> 	ret = nfs_revalidate_inode(server, inode);
> 	if (ret < 0)
> -		return ret;
> +		return ERR_PTR(ret);
> 	if (NFS_I(inode)->cache_validity & NFS_INO_INVALID_ACL)
> 		nfs_zap_acl_cache(inode);
> -	ret = nfs4_read_cached_acl(inode, buf, buflen);
> -	if (ret != -ENOENT)
> -		/* -ENOENT is returned if there is no ACL or if there is an ACL
> -		 * but no cached acl data, just the acl length */
> -		return ret;
> -	return nfs4_get_acl_uncached(inode, buf, buflen);
> +	acl = get_cached_richacl(inode);
> +	if (acl != ACL_NOT_CACHED)
> +		return acl;
> +	return nfs4_get_acl_uncached(inode);
> +}
> +
> +static int
> +richacl_supported(struct nfs_server *server, struct richacl *acl)
> +{
> +	struct richace *ace;
> +
> +	if (!(server->caps & (NFS_CAP_ALLOW_ACLS | NFS_CAP_DENY_ACLS)))
> +		return -EOPNOTSUPP;
> +
> +	richacl_for_each_entry(ace, acl) {
> +		if (richace_is_allow(ace)) {
> +			if (!(server->caps & NFS_CAP_ALLOW_ACLS))
> +				return -EINVAL;
> +		} else if (richace_is_deny(ace)) {
> +			if (!(server->caps & NFS_CAP_DENY_ACLS))
> +				return -EINVAL;
> +		} else
> +			return -EINVAL;
> +	}
> +	return 0;
> }
> 
> -static int __nfs4_proc_set_acl(struct inode *inode, const void *buf, size_t buflen)
> +static int __nfs4_proc_set_acl(struct inode *inode, struct richacl *acl)
> {
> 	struct nfs_server *server = NFS_SERVER(inode);
> -	struct page *pages[NFS4ACL_MAXPAGES];
> +	struct page *pages[DIV_ROUND_UP(NFS4ACL_SIZE_MAX, PAGE_SIZE) + 1 /* scratch */] = {};
> 	struct nfs_setaclargs arg = {
> +		.server		= server,
> 		.fh		= NFS_FH(inode),
> +		.acl		= acl,
> 		.acl_pages	= pages,
> -		.acl_len	= buflen,
> +		.acl_len	= ARRAY_SIZE(pages) * PAGE_SIZE,
> 	};
> 	struct nfs_setaclres res;
> 	struct rpc_message msg = {
> @@ -4668,16 +4589,12 @@ static int __nfs4_proc_set_acl(struct inode *inode, const void *buf, size_t bufl
> 		.rpc_argp	= &arg,
> 		.rpc_resp	= &res,
> 	};
> -	unsigned int npages = DIV_ROUND_UP(buflen, PAGE_SIZE);
> 	int ret, i;
> 
> -	if (!nfs4_server_supports_acls(server))
> -		return -EOPNOTSUPP;
> -	if (npages > ARRAY_SIZE(pages))
> -		return -ERANGE;
> -	i = buf_to_pages_noslab(buf, buflen, arg.acl_pages);
> -	if (i < 0)
> -		return i;
> +	ret = richacl_supported(server, acl);
> +	if (ret)
> +		return ret;
> +
> 	nfs4_inode_return_delegation(inode);
> 	ret = nfs4_call_sync(server->client, server, &msg, &arg.seq_args, &res.seq_res, 1);
> 
> @@ -4685,8 +4602,8 @@ static int __nfs4_proc_set_acl(struct inode *inode, const void *buf, size_t bufl
> 	 * Free each page after tx, so the only ref left is
> 	 * held by the network stack
> 	 */
> -	for (; i > 0; i--)
> -		put_page(pages[i-1]);
> +	for (i = 0; pages[i]; i++)
> +		put_page(pages[i]);
> 
> 	/*
> 	 * Acl update can result in inode attribute update.
> @@ -4700,12 +4617,12 @@ static int __nfs4_proc_set_acl(struct inode *inode, const void *buf, size_t bufl
> 	return ret;
> }
> 
> -static int nfs4_proc_set_acl(struct inode *inode, const void *buf, size_t buflen)
> +static int nfs4_proc_set_acl(struct inode *inode, struct richacl *acl)
> {
> 	struct nfs4_exception exception = { };
> 	int err;
> 	do {
> -		err = __nfs4_proc_set_acl(inode, buf, buflen);
> +		err = __nfs4_proc_set_acl(inode, acl);
> 		trace_nfs4_set_acl(inode, err);
> 		err = nfs4_handle_exception(NFS_SERVER(inode), err,
> 				&exception);
> @@ -6102,38 +6019,69 @@ nfs4_release_lockowner(struct nfs_server *server, struct nfs4_lock_state *lsp)
> 	rpc_call_async(server->client, &msg, 0, &nfs4_release_lockowner_ops, data);
> }
> 
> -#define XATTR_NAME_NFSV4_ACL "system.nfs4_acl"
> -
> -static int nfs4_xattr_set_nfs4_acl(struct dentry *dentry, const char *key,
> -				   const void *buf, size_t buflen,
> -				   int flags, int type)
> +static int nfs4_xattr_set_richacl(struct dentry *dentry, const char *key,
> +				  const void *buf, size_t buflen,
> +				  int flags, int handler_flags)
> {
> +	struct richacl *acl;
> +	int error;
> +
> 	if (strcmp(key, "") != 0)
> 		return -EINVAL;
> 
> -	return nfs4_proc_set_acl(dentry->d_inode, buf, buflen);
> +	if (buf) {
> +		acl = richacl_from_xattr(&init_user_ns, buf, buflen);
> +		if (IS_ERR(acl))
> +			return PTR_ERR(acl);
> +		error = richacl_apply_masks(&acl);

Hi Andreas,

First, let me say thanks for all the work! We (Primary Data) have been using
samba with the vfs_richacl module reexporting an nfsv4.2 mount and things are
working pretty well. You can count on us for testing, bug fixing and code review.

Now for my question: It looks like this call to richacl_apply_masks in the client
xattr_set path exists so that the knfsd permission check algorithm works correctly.
This makes some pretty big assumptions about the server’s implementation.
There are other servers out there besides knfsd!

I think this will have to be fixed before this patch can be accepted. I’m willing to
help, but I’m wondering where this should be fixed:

Do we call richacl_apply_masks on the server before setting the xattr so the
normalized acl is saved, or should we save the ACL as-is and call
richacl_apply_masks before it’s used?

Thanks,

-dros

> +	} else {
> +		/*
> +		 * "Remove the acl"; only permissions granted by the mode
> +		 * remain.  We are using the cached mode here which could be
> +		 * outdated; should we do a GETATTR first to narrow down the
> +		 * race window?
> +		 */
> +		acl = richacl_from_mode_unmasked(dentry->d_inode->i_mode);
> +		error = 0;
> +	}
> +
> +	if (!error)
> +		error = nfs4_proc_set_acl(dentry->d_inode, acl);
> +	richacl_put(acl);
> +	return error;
> }
> 
> -static int nfs4_xattr_get_nfs4_acl(struct dentry *dentry, const char *key,
> -				   void *buf, size_t buflen, int type)
> +static int nfs4_xattr_get_richacl(struct dentry *dentry, const char *key,
> +				  void *buf, size_t buflen, int handler_flags)
> {
> +	struct richacl *acl;
> +	int error;
> +
> 	if (strcmp(key, "") != 0)
> 		return -EINVAL;
> 
> -	return nfs4_proc_get_acl(dentry->d_inode, buf, buflen);
> +	acl = nfs4_proc_get_acl(dentry->d_inode);
> +	if (IS_ERR(acl))
> +		return PTR_ERR(acl);
> +	if (acl == NULL)
> +		return -ENODATA;
> +	error = richacl_to_xattr(&init_user_ns, acl, buf, buflen);
> +	richacl_put(acl);
> +	return error;
> }
> 
> -static size_t nfs4_xattr_list_nfs4_acl(struct dentry *dentry, char *list,
> -				       size_t list_len, const char *name,
> -				       size_t name_len, int type)
> +static size_t nfs4_xattr_list_richacl(struct dentry *dentry, char *list,
> +				      size_t list_len, const char *name,
> +				      size_t name_len, int handler_flags)
> {
> -	size_t len = sizeof(XATTR_NAME_NFSV4_ACL);
> +	struct nfs_server *server = NFS_SERVER(dentry->d_inode);
> +	size_t len = sizeof(XATTR_NAME_RICHACL);
> 
> -	if (!nfs4_server_supports_acls(NFS_SERVER(dentry->d_inode)))
> +	if (!(server->caps & (NFS_CAP_ALLOW_ACLS | NFS_CAP_DENY_ACLS)))
> 		return 0;
> 
> 	if (list && len <= list_len)
> -		memcpy(list, XATTR_NAME_NFSV4_ACL, len);
> +		memcpy(list, XATTR_NAME_RICHACL, len);
> 	return len;
> }
> 
> @@ -8656,15 +8604,15 @@ const struct nfs_rpc_ops nfs_v4_clientops = {
> 	.clone_server	= nfs_clone_server,
> };
> 
> -static const struct xattr_handler nfs4_xattr_nfs4_acl_handler = {
> -	.prefix	= XATTR_NAME_NFSV4_ACL,
> -	.list	= nfs4_xattr_list_nfs4_acl,
> -	.get	= nfs4_xattr_get_nfs4_acl,
> -	.set	= nfs4_xattr_set_nfs4_acl,
> +static const struct xattr_handler nfs4_xattr_richacl_handler = {
> +	.prefix	= XATTR_NAME_RICHACL,
> +	.list	= nfs4_xattr_list_richacl,
> +	.get	= nfs4_xattr_get_richacl,
> +	.set	= nfs4_xattr_set_richacl,
> };
> 
> const struct xattr_handler *nfs4_xattr_handlers[] = {
> -	&nfs4_xattr_nfs4_acl_handler,
> +	&nfs4_xattr_richacl_handler,
> #ifdef CONFIG_NFS_V4_SECURITY_LABEL
> 	&nfs4_xattr_nfs4_label_handler,
> #endif
> diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
> index 4372fc4..8ccc2a0 100644
> --- a/fs/nfs/nfs4xdr.c
> +++ b/fs/nfs/nfs4xdr.c
> @@ -53,6 +53,9 @@
> #include <linux/nfs4.h>
> #include <linux/nfs_fs.h>
> #include <linux/nfs_idmap.h>
> +#include <linux/richacl.h>
> +#include <linux/richacl_xattr.h>  /* for RICHACL_XATTR_MAX_COUNT */
> +#include <linux/nfs4acl.h>
> 
> #include "nfs4_fs.h"
> #include "internal.h"
> @@ -1632,19 +1635,131 @@ encode_restorefh(struct xdr_stream *xdr, struct compound_hdr *hdr)
> 	encode_op_hdr(xdr, OP_RESTOREFH, decode_restorefh_maxsz, hdr);
> }
> 
> -static void
> -encode_setacl(struct xdr_stream *xdr, struct nfs_setaclargs *arg, struct compound_hdr *hdr)
> +static int
> +nfs4_encode_user(struct xdr_stream *xdr, const struct nfs_server *server, kuid_t uid)
> +{
> +	char name[IDMAP_NAMESZ];
> +	int len;
> +	__be32 *p;
> +
> +	len = nfs_map_uid_to_name(server, uid, name, IDMAP_NAMESZ);
> +	if (len < 0) {
> +		dprintk("nfs: couldn't resolve uid %d to string\n",
> +				from_kuid(&init_user_ns, uid));
> +		return -ENOENT;
> +	}
> +	p = xdr_reserve_space(xdr, 4 + len);
> +	if (!p)
> +		return -EIO;
> +	p = xdr_encode_opaque(p, name, len);
> +	return 0;
> +}
> +
> +static int
> +nfs4_encode_group(struct xdr_stream *xdr, const struct nfs_server *server, kgid_t gid)
> +{
> +	char name[IDMAP_NAMESZ];
> +	int len;
> +	__be32 *p;
> +
> +	len = nfs_map_gid_to_group(server, gid, name, IDMAP_NAMESZ);
> +	if (len < 0) {
> +		dprintk("nfs: couldn't resolve gid %d to string\n",
> +				from_kgid(&init_user_ns, gid));
> +		return -ENOENT;
> +	}
> +	p = xdr_reserve_space(xdr, 4 + len);
> +	if (!p)
> +		return -EIO;
> +	p = xdr_encode_opaque(p, name, len);
> +	return 0;
> +}
> +
> +static int
> +nfs4_encode_ace_who(struct xdr_stream *xdr, const struct nfs_server *server,
> +		    struct richace *ace)
> {
> 	__be32 *p;
> 
> +	if (ace->e_flags & RICHACE_SPECIAL_WHO) {
> +		unsigned int special_id = ace->e_id.special;
> +		const char *who;
> +		unsigned int len;
> +
> +		if (!nfs4acl_special_id_to_who(special_id, &who, &len)) {
> +			WARN_ON_ONCE(1);
> +			return -EIO;
> +		}
> +		p = xdr_reserve_space(xdr, 4 + len);
> +		if (!p)
> +			return -EIO;
> +		p = xdr_encode_opaque(p, who, len);
> +		return 0;
> +	}
> +	if (ace->e_flags & RICHACE_IDENTIFIER_GROUP)
> +		return nfs4_encode_group(xdr, server, ace->e_id.gid);
> +	else
> +		return nfs4_encode_user(xdr, server, ace->e_id.uid);
> +}
> +
> +static int
> +encode_setacl(struct xdr_stream *xdr, struct nfs_setaclargs *arg, struct compound_hdr *hdr)
> +{
> +	int attrlen_offset;
> +	__be32 attrlen, *p;
> +	struct richace *ace;
> +
> 	encode_op_hdr(xdr, OP_SETATTR, decode_setacl_maxsz, hdr);
> 	encode_nfs4_stateid(xdr, &zero_stateid);
> +
> +	/* Encode attribute bitmap. */
> 	p = reserve_space(xdr, 2*4);
> 	*p++ = cpu_to_be32(1);
> 	*p = cpu_to_be32(FATTR4_WORD0_ACL);
> -	p = reserve_space(xdr, 4);
> -	*p = cpu_to_be32(arg->acl_len);
> -	xdr_write_pages(xdr, arg->acl_pages, 0, arg->acl_len);
> +
> +	attrlen_offset = xdr->buf->len;
> +	p = xdr_reserve_space(xdr, 4);
> +	if (!p)
> +		goto fail;
> +	p++;  /* to be backfilled later */
> +
> +	p = xdr_reserve_space(xdr, 4);
> +	if (!p)
> +		goto fail;
> +	if (arg->acl == NULL) {
> +		*p++ = cpu_to_be32(0);
> +		return 0;
> +	}
> +	*p++ = cpu_to_be32(arg->acl->a_count);
> +
> +	/* Add space for the acl entries. */
> +	xdr_inline_pages(xdr->buf, xdr->buf->len, arg->acl_pages, 0, arg->acl_len);
> +
> +	if (arg->acl->a_flags)
> +		return -EINVAL;
> +
> +	richacl_for_each_entry(ace, arg->acl) {
> +		if (ace->e_flags & RICHACE_INHERITED_ACE)
> +			return -EINVAL;
> +		if (ace->e_mask & ~NFS4_ACE_MASK_ALL)
> +			return -EINVAL;
> +
> +		p = xdr_reserve_space(xdr, 4*3);
> +		if (!p)
> +			goto fail;
> +		*p++ = cpu_to_be32(ace->e_type);
> +		*p++ = cpu_to_be32(ace->e_flags & ~RICHACE_SPECIAL_WHO);
> +		*p++ = cpu_to_be32(ace->e_mask & NFS4_ACE_MASK_ALL);
> +		if (nfs4_encode_ace_who(xdr, arg->server, ace) != 0)
> +			goto fail;
> +	}
> +
> +	attrlen = htonl(xdr->buf->len - attrlen_offset - 4);
> +	write_bytes_to_xdr_buf(xdr->buf, attrlen_offset, &attrlen, 4);
> +	return 0;
> +
> +fail:
> +	return -ENOMEM;
> }
> 
> static void
> @@ -2514,7 +2629,7 @@ static int nfs4_xdr_enc_getacl(struct rpc_rqst *req, struct xdr_stream *xdr,
> 	encode_sequence(xdr, &args->seq_args, &hdr);
> 	encode_putfh(xdr, args->fh, &hdr);
> 	replen = hdr.replen + op_decode_hdr_maxsz + 1;
> -	encode_getattr_two(xdr, FATTR4_WORD0_ACL, 0, &hdr);
> +	encode_getattr_two(xdr, FATTR4_WORD0_ACL, FATTR4_WORD1_MODE, &hdr);
> 
> 	xdr_inline_pages(&req->rq_rcv_buf, replen << 2,
> 		args->acl_pages, 0, args->acl_len);
> @@ -5236,27 +5351,64 @@ decode_restorefh(struct xdr_stream *xdr)
> 	return decode_op_hdr(xdr, OP_RESTOREFH);
> }
> 
> +static int
> +nfs4_decode_ace_who(struct richace *ace, const struct nfs_server *server,
> +		    struct xdr_stream *xdr)
> +{
> +	char *who;
> +	u32 len;
> +	int special_id;
> +	__be32 *p;
> +	int error;
> +
> +	p = xdr_inline_decode(xdr, 4);
> +	if (!p)
> +		return -ENOMEM;  /* acl truncated */
> +	len = be32_to_cpup(p++);
> +	if (len >= XDR_MAX_NETOBJ) {
> +		dprintk("%s: name too long (%u)!\n",
> +			__func__, len);
> +		return -EIO;
> +	}
> +	who = (char *)xdr_inline_decode(xdr, len);
> +	if (!who)
> +		return -ENOMEM;  /* acl truncated */
> +
> +	special_id = nfs4acl_who_to_special_id(who, len);
> +	if (special_id >= 0) {
> +		ace->e_flags |= RICHACE_SPECIAL_WHO;
> +		ace->e_flags &= ~RICHACE_IDENTIFIER_GROUP;
> +		ace->e_id.special = special_id;
> +		return 0;
> +	}
> +	if (ace->e_flags & RICHACE_IDENTIFIER_GROUP) {
> +		error = nfs_map_group_to_gid(server, who, len, &ace->e_id.gid);
> +		if (error)
> +			dprintk("%s: nfs_map_group_to_gid failed!\n",
> +					__func__);
> +	} else {
> +		error = nfs_map_name_to_uid(server, who, len, &ace->e_id.uid);
> +		if (error)
> +			dprintk("%s: nfs_map_name_to_uid failed!\n",
> +					__func__);
> +	}
> +	return error;
> +}
> +
> static int decode_getacl(struct xdr_stream *xdr, struct rpc_rqst *req,
> 			 struct nfs_getaclres *res)
> {
> 	static const uint32_t attrs_allowed[3] = {
> 		[0] = FATTR4_WORD0_ACL,
> +		[1] = FATTR4_WORD1_MODE,
> 	};
> 	unsigned int savep;
> 	uint32_t attrlen,
> 		 bitmap[3] = {0};
> 	int status;
> -	unsigned int pg_offset;
> 
> -	res->acl_len = 0;
> 	if ((status = decode_op_hdr(xdr, OP_GETATTR)) != 0)
> 		goto out;
> -
> -	xdr_enter_page(xdr, xdr->buf->page_len);
> -
> -	/* Calculate the offset of the page data */
> -	pg_offset = xdr->buf->head[0].iov_len;
> -
> 	if ((status = decode_attr_bitmap(xdr, bitmap)) != 0)
> 		goto out;
> 	if ((status = verify_attrs_allowed(bitmap, attrs_allowed)) != 0)
> @@ -5265,22 +5417,37 @@ static int decode_getacl(struct xdr_stream *xdr, struct rpc_rqst *req,
> 		goto out;
> 
> 	if (likely(bitmap[0] & FATTR4_WORD0_ACL)) {
> +		struct richace *ace;
> +		uint32_t count;
> +		__be32 *p;
> 
> -		/* The bitmap (xdr len + bitmaps) and the attr xdr len words
> -		 * are stored with the acl data to handle the problem of
> -		 * variable length bitmaps.*/
> -		res->acl_data_offset = xdr_stream_pos(xdr) - pg_offset;
> -		res->acl_len = attrlen;
> -
> -		/* Check for receive buffer overflow */
> -		if (res->acl_len > (xdr->nwords << 2) ||
> -		    res->acl_len + res->acl_data_offset > xdr->buf->page_len) {
> -			res->acl_flags |= NFS4_ACL_TRUNC;
> -			dprintk("NFS: acl reply: attrlen %u > page_len %u\n",
> -					attrlen, xdr->nwords << 2);
> +		p = xdr_inline_decode(xdr, 4);
> +		if (unlikely(!p))
> +			return -ENOMEM;  /* acl truncated */
> +		count = be32_to_cpup(p);
> +		if (count > RICHACL_XATTR_MAX_COUNT)
> +			return -EIO;
> +		res->acl = richacl_alloc(count, GFP_KERNEL);
> +		if (!res->acl)
> +			return -ENOMEM;
> +		richacl_for_each_entry(ace, res->acl) {
> +			p = xdr_inline_decode(xdr, 4*3);
> +			if (unlikely(!p))
> +				return -ENOMEM;  /* acl truncated */
> +			ace->e_type = be32_to_cpup(p++);
> +			ace->e_flags = be32_to_cpup(p++);
> +			if (ace->e_flags & RICHACE_SPECIAL_WHO)
> +				return -EIO;
> +			ace->e_mask = be32_to_cpup(p++);
> +			status = nfs4_decode_ace_who(ace, res->server, xdr);
> +			if (status)
> +				goto out;
> 		}
> 	} else
> 		status = -EOPNOTSUPP;
> +	if ((status = decode_attr_mode(xdr, bitmap, &res->mode)) < 0)
> +		goto out;
> +	status = 0;
> 
> out:
> 	return status;
> @@ -6298,6 +6465,7 @@ out:
> static int nfs4_xdr_enc_setacl(struct rpc_rqst *req, struct xdr_stream *xdr,
> 			       void *obj)
> {
> +	int error;
> 	struct nfs_setaclargs *args = obj;
> 	struct compound_hdr hdr = {
> 		.minorversion = nfs4_xdr_minorversion(&args->seq_args),
> @@ -6306,7 +6474,9 @@ static int nfs4_xdr_enc_setacl(struct rpc_rqst *req, struct xdr_stream *xdr,
> 	encode_compound_hdr(xdr, req, &hdr);
> 	encode_sequence(xdr, &args->seq_args, &hdr);
> 	encode_putfh(xdr, args->fh, &hdr);
> -	encode_setacl(xdr, args, &hdr);
> +	error = encode_setacl(xdr, args, &hdr);
> +	if (error)
> +		return error;
> 	encode_nops(&hdr);
> 	return 0;
> }
> diff --git a/fs/nfs/super.c b/fs/nfs/super.c
> index 322b2de02..fb904ec 100644
> --- a/fs/nfs/super.c
> +++ b/fs/nfs/super.c
> @@ -2318,7 +2318,7 @@ void nfs_fill_super(struct super_block *sb, struct nfs_mount_info *mount_info)
> 		/* The VFS shouldn't apply the umask to mode bits. We will do
> 		 * so ourselves when necessary.
> 		 */
> -		sb->s_flags |= MS_POSIXACL;
> +		sb->s_flags |= MS_RICHACL;
> 		sb->s_time_gran = 1;
> 	}
> 
> @@ -2345,7 +2345,7 @@ void nfs_clone_super(struct super_block *sb, struct nfs_mount_info *mount_info)
> 		/* The VFS shouldn't apply the umask to mode bits. We will do
> 		 * so ourselves when necessary.
> 		 */
> -		sb->s_flags |= MS_POSIXACL;
> +		sb->s_flags |= MS_RICHACL;
> 	}
> 
>  	nfs_initialise_sb(sb);
> diff --git a/include/linux/nfs_fs.h b/include/linux/nfs_fs.h
> index b01ccf3..4eac89d7 100644
> --- a/include/linux/nfs_fs.h
> +++ b/include/linux/nfs_fs.h
> @@ -176,7 +176,6 @@ struct nfs_inode {
> 	wait_queue_head_t	waitqueue;
> 
> #if IS_ENABLED(CONFIG_NFS_V4)
> -	struct nfs4_cached_acl	*nfs4_acl;
>         /* NFSv4 state */
> 	struct list_head	open_states;
> 	struct nfs_delegation __rcu *delegation;
> diff --git a/include/linux/nfs_fs_sb.h b/include/linux/nfs_fs_sb.h
> index 5e1273d..df994aa 100644
> --- a/include/linux/nfs_fs_sb.h
> +++ b/include/linux/nfs_fs_sb.h
> @@ -237,5 +237,7 @@ struct nfs_server {
> #define NFS_CAP_SEEK		(1U << 19)
> #define NFS_CAP_ALLOCATE	(1U << 20)
> #define NFS_CAP_DEALLOCATE	(1U << 21)
> +#define NFS_CAP_ALLOW_ACLS	(1U << 22)
> +#define NFS_CAP_DENY_ACLS	(1U << 23)
> 
> #endif
> diff --git a/include/linux/nfs_xdr.h b/include/linux/nfs_xdr.h
> index 92134cf..77097ec 100644
> --- a/include/linux/nfs_xdr.h
> +++ b/include/linux/nfs_xdr.h
> @@ -638,7 +638,9 @@ struct nfs_setattrargs {
> 
> struct nfs_setaclargs {
> 	struct nfs4_sequence_args	seq_args;
> +	const struct nfs_server *	server;
> 	struct nfs_fh *			fh;
> +	struct richacl *		acl;
> 	size_t				acl_len;
> 	struct page **			acl_pages;
> };
> @@ -658,9 +660,9 @@ struct nfs_getaclargs {
> #define NFS4_ACL_TRUNC		0x0001	/* ACL was truncated */
> struct nfs_getaclres {
> 	struct nfs4_sequence_res	seq_res;
> -	size_t				acl_len;
> -	size_t				acl_data_offset;
> -	int				acl_flags;
> +	const struct nfs_server *	server;
> +	struct richacl *		acl;
> +	umode_t				mode;
> 	struct page *			acl_scratch;
> };
> 
> -- 
> 2.1.0
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

