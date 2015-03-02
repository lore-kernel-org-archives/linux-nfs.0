Return-Path: linux-nfs-owner@vger.kernel.org
Received: from aserp1040.oracle.com ([141.146.126.69]:44120 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752064AbbCBCfM convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 1 Mar 2015 21:35:12 -0500
Content-Type: text/plain; charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 7.3 \(1878.6\))
Subject: Re: [PATCH v3 1/8] NFS: Add a helper to set attribute barriers
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <1425097030-9376-1-git-send-email-trond.myklebust@primarydata.com>
Date: Sun, 1 Mar 2015 21:35:08 -0500
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-Id: <A9EDBAEB-B4C1-4C50-9312-108308C283DF@oracle.com>
References: <1425097030-9376-1-git-send-email-trond.myklebust@primarydata.com>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Feb 27, 2015, at 11:17 PM, Trond Myklebust <trond.myklebust@primarydata.com> wrote:

> Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>

Tested-by: Chuck Lever <chuck.lever@oracle.com>

I applied this series and the patch that addresses the generic/133
O_DIRECT regression to stock 3.19.0.

I tested using xfstests with NFSv3 and NFSv4.0, Solaris 11 update 2
and Linux 3.19 servers. No new test failures (between 2 and 4
failures out of 55 tests run, which is typical).

I also used dbench and fio to look for performance regressions.
No regression found so far.



> ---
> fs/nfs/inode.c         | 16 ++++++++++++++++
> include/linux/nfs_fs.h |  1 +
> 2 files changed, 17 insertions(+)
> 
> diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
> index 83107be3dd01..b0cbc1ba82da 100644
> --- a/fs/nfs/inode.c
> +++ b/fs/nfs/inode.c
> @@ -1260,6 +1260,22 @@ void nfs_fattr_init(struct nfs_fattr *fattr)
> }
> EXPORT_SYMBOL_GPL(nfs_fattr_init);
> 
> +/**
> + * nfs_fattr_set_barrier
> + * @fattr: attributes
> + *
> + * Used to set a barrier after an attribute was updated. This
> + * barrier ensures that older attributes from RPC calls that may
> + * have raced with our update cannot clobber these new values.
> + * Note that you are still responsible for ensuring that other
> + * operations which change the attribute on the server do not
> + * collide.
> + */
> +void nfs_fattr_set_barrier(struct nfs_fattr *fattr)
> +{
> +	fattr->gencount = nfs_inc_attr_generation_counter();
> +}
> +
> struct nfs_fattr *nfs_alloc_fattr(void)
> {
> 	struct nfs_fattr *fattr;
> diff --git a/include/linux/nfs_fs.h b/include/linux/nfs_fs.h
> index 2f77e0c651c8..3a4ffb5856cd 100644
> --- a/include/linux/nfs_fs.h
> +++ b/include/linux/nfs_fs.h
> @@ -369,6 +369,7 @@ extern struct nfs_lock_context *nfs_get_lock_context(struct nfs_open_context *ct
> extern void nfs_put_lock_context(struct nfs_lock_context *l_ctx);
> extern u64 nfs_compat_user_ino64(u64 fileid);
> extern void nfs_fattr_init(struct nfs_fattr *fattr);
> +extern void nfs_fattr_set_barrier(struct nfs_fattr *fattr);
> extern unsigned long nfs_inc_attr_generation_counter(void);
> 
> extern struct nfs_fattr *nfs_alloc_fattr(void);
> -- 
> 2.1.0
> 

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com



