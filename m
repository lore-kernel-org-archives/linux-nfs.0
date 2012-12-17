Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:46128 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752254Ab2LQMr6 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 17 Dec 2012 07:47:58 -0500
Date: Mon, 17 Dec 2012 07:47:11 -0500
From: Jeff Layton <jlayton@redhat.com>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: "neilb@suse.de" <neilb@suse.de>, Ricky Ng-Adam <rngadam@lophilo.com>,
        Al Viro <viro@ZenIV.linux.org.uk>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 1/2] NFS: Ensure that we always drop inodes that have
 been marked as stale
Message-ID: <20121217074711.0c4e41d3@tlielax.poochiereds.net>
In-Reply-To: <1355521981-50094-1-git-send-email-Trond.Myklebust@netapp.com>
References: <20121214075138.7ab828da@tlielax.poochiereds.net>
	<1355521981-50094-1-git-send-email-Trond.Myklebust@netapp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, 14 Dec 2012 16:53:00 -0500
Trond Myklebust <Trond.Myklebust@netapp.com> wrote:

> There is no need to cache stale inodes.
> 
> Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
> ---
>  fs/nfs/inode.c     | 6 ++++++
>  fs/nfs/internal.h  | 1 +
>  fs/nfs/nfs4super.c | 1 +
>  fs/nfs/super.c     | 1 +
>  4 files changed, 9 insertions(+)
> 
> diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
> index 117183b..2faae14 100644
> --- a/fs/nfs/inode.c
> +++ b/fs/nfs/inode.c
> @@ -107,6 +107,12 @@ u64 nfs_compat_user_ino64(u64 fileid)
>  	return ino;
>  }
>  
> +int nfs_drop_inode(struct inode *inode)
> +{
> +	return NFS_STALE(inode) || generic_drop_inode(inode);
> +}
> +EXPORT_SYMBOL_GPL(nfs_drop_inode);
> +
>  void nfs_clear_inode(struct inode *inode)
>  {
>  	/*
> diff --git a/fs/nfs/internal.h b/fs/nfs/internal.h
> index 89c1ee4..f0e6c7d 100644
> --- a/fs/nfs/internal.h
> +++ b/fs/nfs/internal.h
> @@ -296,6 +296,7 @@ extern struct workqueue_struct *nfsiod_workqueue;
>  extern struct inode *nfs_alloc_inode(struct super_block *sb);
>  extern void nfs_destroy_inode(struct inode *);
>  extern int nfs_write_inode(struct inode *, struct writeback_control *);
> +extern int nfs_drop_inode(struct inode *);
>  extern void nfs_clear_inode(struct inode *);
>  extern void nfs_evict_inode(struct inode *);
>  void nfs_zap_acl_cache(struct inode *inode);
> diff --git a/fs/nfs/nfs4super.c b/fs/nfs/nfs4super.c
> index bd61221..84d2e9e 100644
> --- a/fs/nfs/nfs4super.c
> +++ b/fs/nfs/nfs4super.c
> @@ -51,6 +51,7 @@ static const struct super_operations nfs4_sops = {
>  	.alloc_inode	= nfs_alloc_inode,
>  	.destroy_inode	= nfs_destroy_inode,
>  	.write_inode	= nfs4_write_inode,
> +	.drop_inode	= nfs_drop_inode,
>  	.put_super	= nfs_put_super,
>  	.statfs		= nfs_statfs,
>  	.evict_inode	= nfs4_evict_inode,
> diff --git a/fs/nfs/super.c b/fs/nfs/super.c
> index e12cea4..aa5315b 100644
> --- a/fs/nfs/super.c
> +++ b/fs/nfs/super.c
> @@ -308,6 +308,7 @@ const struct super_operations nfs_sops = {
>  	.alloc_inode	= nfs_alloc_inode,
>  	.destroy_inode	= nfs_destroy_inode,
>  	.write_inode	= nfs_write_inode,
> +	.drop_inode	= nfs_drop_inode,
>  	.put_super	= nfs_put_super,
>  	.statfs		= nfs_statfs,
>  	.evict_inode	= nfs_evict_inode,

Testing with both of these patches shows that it does fix the
reproducer that Neil came up with.

-- 
Jeff Layton <jlayton@redhat.com>
