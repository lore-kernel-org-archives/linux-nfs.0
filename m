Return-Path: linux-nfs-owner@vger.kernel.org
Received: from rcsinet15.oracle.com ([148.87.113.117]:19120 "EHLO
	rcsinet15.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759230Ab2AMVZy convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 13 Jan 2012 16:25:54 -0500
Subject: Re: [PATCH 43/44] NFS: Export functions needed by a v4 module
Mime-Version: 1.0 (Apple Message framework v1251.1)
Content-Type: text/plain; charset=us-ascii
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <4F109E4F.3060201@netapp.com>
Date: Fri, 13 Jan 2012 16:25:14 -0500
Cc: trond.myklebust@netapp.com, linux-nfs@vger.kernel.org
Message-Id: <F641B4A2-4655-4F1C-B7FC-11ED3982D588@oracle.com>
References: <1326485453-1350-1-git-send-email-bjschuma@netapp.com> <1326485453-1350-44-git-send-email-bjschuma@netapp.com> <EA1EBEFB-A2C7-4696-B32F-BE83B4871E52@oracle.com> <4F109C99.7030809@netapp.com> <4F109E4F.3060201@netapp.com>
To: Bryan Schumaker <bjschuma@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Jan 13, 2012, at 4:12 PM, Bryan Schumaker wrote:

> On Fri Jan 13 16:05:29 2012, Bryan Schumaker wrote:
>> On Fri Jan 13 15:48:38 2012, Chuck Lever wrote:
>>> 
>>> On Jan 13, 2012, at 3:10 PM, bjschuma@netapp.com wrote:
>>> 
>>>> From: Bryan Schumaker <bjschuma@netapp.com>
>>>> 
>>>> The v4 code uses these functions in the generic client, so they need to
>>>> be available to modules.
>>> 
>>> If you add the EXPORT_SYMBOL() macros in separate patches, is that bisect-able?  Seems like you should add the macros when you move functions.
>> 
>> I thought it was since it would detect namespace collisions... I can 
>> fix it if I need to.
>> 
>>> 
>>> It seems like an enormous amount of code movement.  Isn't there a way to accomplish modularization without moving things into separate directories?
>> 
>> Not that I know of.  I found examples for compiling directories as 
>> modules, but not specific files or parts of files.
> 
> I should have looked at how obj-$(CONFIG_PNFS_FILE_LAYOUT) is done, so 
> it is possible.  I would still need to split out a lot of the code into 
> nfs4 specific files to get the module to compile.

Do you have specific examples of what needs to be split?

> This would create a 
> lot more files in fs/nfs/ directory, especially for NFS v4.  I figured 
> subdirectories might be easier to work with, especially if we're going 
> to name everything with nfs3 or nfs4 as a prefix anyway.

Moving existing code around like this makes it harder to forward and back-port patches, and it truncates the "git blame" history on all these files.  Ideally we might want subdirectories, if we were starting from scratch, but that's not where we are today.

I vote for starting with something simpler, for example modularizing just NFSv2 and NFSv3.  We might want to split this work over more than one kernel release anyway, to avoid introducing a lot of churn and bugs all at once, and that's one way to divide the effort.

> - Bryan
> 
>> 
>>> 
>>>> Signed-off-by: Bryan Schumaker <bjschuma@netapp.com>
>>>> ---
>>>> fs/nfs/client.c      |    2 ++
>>>> fs/nfs/dir.c         |    2 ++
>>>> fs/nfs/dns_resolve.c |    4 ++++
>>>> fs/nfs/fscache.c     |    4 ++++
>>>> fs/nfs/inode.c       |    9 +++++++++
>>>> fs/nfs/namespace.c   |    1 +
>>>> fs/nfs/super.c       |    2 ++
>>>> fs/nfs/unlink.c      |    3 +++
>>>> fs/nfs/write.c       |    2 ++
>>>> 9 files changed, 29 insertions(+), 0 deletions(-)
>>>> 
>>>> diff --git a/fs/nfs/client.c b/fs/nfs/client.c
>>>> index 2c3f50e..0e4ddbe 100644
>>>> --- a/fs/nfs/client.c
>>>> +++ b/fs/nfs/client.c
>>>> @@ -913,6 +913,7 @@ void nfs_server_insert_lists(struct nfs_server *server)
>>>> 	spin_unlock(&nfs_client_lock);
>>>> 
>>>> }
>>>> +EXPORT_SYMBOL_GPL(nfs_server_insert_lists);
>>>> 
>>>> static void nfs_server_remove_lists(struct nfs_server *server)
>>>> {
>>>> @@ -992,6 +993,7 @@ void nfs_free_server(struct nfs_server *server)
>>>> 	nfs_release_automount_timer();
>>>> 	dprintk("<-- nfs_free_server()\n");
>>>> }
>>>> +EXPORT_SYMBOL_GPL(nfs_free_server);
>>>> 
>>>> /*
>>>> * Create a version 2 or 3 volume record
>>>> diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
>>>> index 210284f..909f8de 100644
>>>> --- a/fs/nfs/dir.c
>>>> +++ b/fs/nfs/dir.c
>>>> @@ -917,6 +917,7 @@ void nfs_force_lookup_revalidate(struct inode *dir)
>>>> {
>>>> 	NFS_I(dir)->cache_change_attribute++;
>>>> }
>>>> +EXPORT_SYMBOL_GPL(nfs_force_lookup_revalidate);
>>>> 
>>>> /*
>>>> * A check for whether or not the parent directory has changed.
>>>> @@ -1932,6 +1933,7 @@ int nfs_may_open(struct inode *inode, struct rpc_cred *cred, int openflags)
>>>> {
>>>> 	return nfs_do_access(inode, cred, nfs_open_permission_mask(openflags));
>>>> }
>>>> +EXPORT_SYMBOL_GPL(nfs_may_open);
>>>> 
>>>> int nfs_permission(struct inode *inode, int mask)
>>>> {
>>>> diff --git a/fs/nfs/dns_resolve.c b/fs/nfs/dns_resolve.c
>>>> index a6e711a..8b9aeba 100644
>>>> --- a/fs/nfs/dns_resolve.c
>>>> +++ b/fs/nfs/dns_resolve.c
>>>> @@ -6,6 +6,8 @@
>>>> * Resolves DNS hostnames into valid ip addresses
>>>> */
>>>> 
>>>> +#include <linux/module.h>
>>>> +
>>>> #ifdef CONFIG_NFS_USE_KERNEL_DNS
>>>> 
>>>> #include <linux/sunrpc/clnt.h>
>>>> @@ -26,6 +28,7 @@ ssize_t nfs_dns_resolve_name(char *name, size_t namelen,
>>>> 	kfree(ip_addr);
>>>> 	return ret;
>>>> }
>>>> +EXPORT_SYMBOL_GPL(nfs_dns_resolve_name);
>>>> 
>>>> #else
>>>> 
>>>> @@ -358,6 +361,7 @@ ssize_t nfs_dns_resolve_name(char *name, size_t namelen,
>>>> 		ret = -ESRCH;
>>>> 	return ret;
>>>> }
>>>> +EXPORT_SYMBOL_GPL(nfs_dns_resolve_name);
>>>> 
>>>> int nfs_dns_resolver_init(void)
>>>> {
>>>> diff --git a/fs/nfs/fscache.c b/fs/nfs/fscache.c
>>>> index 419119c..94e2d51 100644
>>>> --- a/fs/nfs/fscache.c
>>>> +++ b/fs/nfs/fscache.c
>>>> @@ -9,6 +9,7 @@
>>>> * 2 of the Licence, or (at your option) any later version.
>>>> */
>>>> 
>>>> +#include <linux/module.h>
>>>> #include <linux/init.h>
>>>> #include <linux/kernel.h>
>>>> #include <linux/sched.h>
>>>> @@ -163,6 +164,7 @@ non_unique:
>>>> 	printk(KERN_WARNING "NFS:"
>>>> 	       " Cache request denied due to non-unique superblock keys\n");
>>>> }
>>>> +EXPORT_SYMBOL_GPL(nfs_fscache_get_super_cookie);
>>>> 
>>>> /*
>>>> * release a per-superblock cookie
>>>> @@ -185,6 +187,7 @@ void nfs_fscache_release_super_cookie(struct super_block *sb)
>>>> 		nfss->fscache_key = NULL;
>>>> 	}
>>>> }
>>>> +EXPORT_SYMBOL_GPL(nfs_fscache_release_super_cookie);
>>>> 
>>>> /*
>>>> * Initialise the per-inode cache cookie pointer for an NFS inode.
>>>> @@ -318,6 +321,7 @@ void nfs_fscache_set_inode_cookie(struct inode *inode, struct file *filp)
>>>> 		nfs_fscache_inode_unlock(inode);
>>>> 	}
>>>> }
>>>> +EXPORT_SYMBOL_GPL(nfs_fscache_set_inode_cookie);
>>>> 
>>>> /*
>>>> * Replace a per-inode cookie due to revalidation detecting a file having
>>>> diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
>>>> index 57a68b8..d7afc2b 100644
>>>> --- a/fs/nfs/inode.c
>>>> +++ b/fs/nfs/inode.c
>>>> @@ -81,6 +81,7 @@ int nfs_wait_bit_killable(void *word)
>>>> 	schedule();
>>>> 	return 0;
>>>> }
>>>> +EXPORT_SYMBOL_GPL(nfs_wait_bit_killable);
>>>> 
>>>> /**
>>>> * nfs_compat_user_ino64 - returns the user-visible inode number
>>>> @@ -421,6 +422,7 @@ out_no_inode:
>>>> 	dprintk("nfs_fhget: iget failed with error %ld\n", PTR_ERR(inode));
>>>> 	goto out;
>>>> }
>>>> +EXPORT_SYMBOL_GPL(nfs_fhget);
>>>> 
>>>> #define NFS_VALID_ATTRS (ATTR_MODE|ATTR_UID|ATTR_GID|ATTR_SIZE|ATTR_ATIME|ATTR_ATIME_SET|ATTR_MTIME|ATTR_MTIME_SET|ATTR_FILE)
>>>> 
>>>> @@ -673,6 +675,7 @@ struct nfs_open_context *alloc_nfs_open_context(struct dentry *dentry, struct rp
>>>> 	}
>>>> 	return ctx;
>>>> }
>>>> +EXPORT_SYMBOL_GPL(alloc_nfs_open_context);
>>>> 
>>>> struct nfs_open_context *get_nfs_open_context(struct nfs_open_context *ctx)
>>>> {
>>>> @@ -680,6 +683,7 @@ struct nfs_open_context *get_nfs_open_context(struct nfs_open_context *ctx)
>>>> 		atomic_inc(&ctx->lock_context.count);
>>>> 	return ctx;
>>>> }
>>>> +EXPORT_SYMBOL_GPL(get_nfs_open_context);
>>>> 
>>>> static void __put_nfs_open_context(struct nfs_open_context *ctx, int is_sync)
>>>> {
>>>> @@ -706,6 +710,7 @@ void put_nfs_open_context(struct nfs_open_context *ctx)
>>>> {
>>>> 	__put_nfs_open_context(ctx, 0);
>>>> }
>>>> +EXPORT_SYMBOL_GPL(put_nfs_open_context);
>>>> 
>>>> /*
>>>> * Ensure that mmap has a recent RPC credential for use when writing out
>>>> @@ -721,6 +726,7 @@ void nfs_file_set_open_context(struct file *filp, struct nfs_open_context *ctx)
>>>> 	list_add(&ctx->list, &nfsi->open_files);
>>>> 	spin_unlock(&inode->i_lock);
>>>> }
>>>> +EXPORT_SYMBOL_GPL(nfs_file_set_open_context);
>>>> 
>>>> /*
>>>> * Given an inode, search for an open context with the desired characteristics
>>>> @@ -1473,6 +1479,7 @@ struct inode *nfs_alloc_inode(struct super_block *sb)
>>>> #endif /* CONFIG_NFS_V4 */
>>>> 	return &nfsi->vfs_inode;
>>>> }
>>>> +EXPORT_SYMBOL_GPL(nfs_alloc_inode);
>>>> 
>>>> static void nfs_i_callback(struct rcu_head *head)
>>>> {
>>>> @@ -1485,6 +1492,7 @@ void nfs_destroy_inode(struct inode *inode)
>>>> {
>>>> 	call_rcu(&inode->i_rcu, nfs_i_callback);
>>>> }
>>>> +EXPORT_SYMBOL_GPL(nfs_destroy_inode);
>>>> 
>>>> static inline void nfs4_init_once(struct nfs_inode *nfsi)
>>>> {
>>>> @@ -1534,6 +1542,7 @@ static void nfs_destroy_inodecache(void)
>>>> }
>>>> 
>>>> struct workqueue_struct *nfsiod_workqueue;
>>>> +EXPORT_SYMBOL_GPL(nfsiod_workqueue);
>>>> 
>>>> /*
>>>> * start up the nfsiod workqueue
>>>> diff --git a/fs/nfs/namespace.c b/fs/nfs/namespace.c
>>>> index 203b4b3..d311128 100644
>>>> --- a/fs/nfs/namespace.c
>>>> +++ b/fs/nfs/namespace.c
>>>> @@ -114,6 +114,7 @@ Elong_unlock:
>>>> Elong:
>>>> 	return ERR_PTR(-ENAMETOOLONG);
>>>> }
>>>> +EXPORT_SYMBOL_GPL(nfs_path);
>>>> 
>>>> #if IS_ENABLED(CONFIG_NFS_V4)
>>>> rpc_authflavor_t nfs_find_best_sec(struct nfs4_secinfo_flavors *flavors)
>>>> diff --git a/fs/nfs/super.c b/fs/nfs/super.c
>>>> index 2c8ed6f..d2d1b6b 100644
>>>> --- a/fs/nfs/super.c
>>>> +++ b/fs/nfs/super.c
>>>> @@ -356,6 +356,7 @@ void nfs_sb_active(struct super_block *sb)
>>>> 	if (atomic_inc_return(&server->active) == 1)
>>>> 		atomic_inc(&sb->s_active);
>>>> }
>>>> +EXPORT_SYMBOL_GPL(nfs_sb_active);
>>>> 
>>>> void nfs_sb_deactive(struct super_block *sb)
>>>> {
>>>> @@ -364,6 +365,7 @@ void nfs_sb_deactive(struct super_block *sb)
>>>> 	if (atomic_dec_and_test(&server->active))
>>>> 		deactivate_super(sb);
>>>> }
>>>> +EXPORT_SYMBOL_GPL(nfs_sb_deactive);
>>>> 
>>>> /*
>>>> * Deliver file system statistics to userspace
>>>> diff --git a/fs/nfs/unlink.c b/fs/nfs/unlink.c
>>>> index 9f04700..32c1d70 100644
>>>> --- a/fs/nfs/unlink.c
>>>> +++ b/fs/nfs/unlink.c
>>>> @@ -5,6 +5,7 @@
>>>> *
>>>> */
>>>> 
>>>> +#include <linux/module.h>
>>>> #include <linux/slab.h>
>>>> #include <linux/string.h>
>>>> #include <linux/dcache.h>
>>>> @@ -229,6 +230,7 @@ void nfs_block_sillyrename(struct dentry *dentry)
>>>> 
>>>> 	wait_event(nfsi->waitqueue, atomic_cmpxchg(&nfsi->silly_count, 1, 0) == 1);
>>>> }
>>>> +EXPORT_SYMBOL_GPL(nfs_block_sillyrename);
>>>> 
>>>> void nfs_unblock_sillyrename(struct dentry *dentry)
>>>> {
>>>> @@ -250,6 +252,7 @@ void nfs_unblock_sillyrename(struct dentry *dentry)
>>>> 	}
>>>> 	spin_unlock(&dir->i_lock);
>>>> }
>>>> +EXPORT_SYMBOL_GPL(nfs_unblock_sillyrename);
>>>> 
>>>> /**
>>>> * nfs_async_unlink - asynchronous unlinking of a file
>>>> diff --git a/fs/nfs/write.c b/fs/nfs/write.c
>>>> index f9ca30c..0750ebb 100644
>>>> --- a/fs/nfs/write.c
>>>> +++ b/fs/nfs/write.c
>>>> @@ -1608,6 +1608,7 @@ int nfs_write_inode(struct inode *inode, struct writeback_control *wbc)
>>>> 	}
>>>> 	return ret;
>>>> }
>>>> +EXPORT_SYMBOL_GPL(nfs_write_inode);
>>>> 
>>>> /*
>>>> * flush the inode to disk.
>>>> @@ -1623,6 +1624,7 @@ int nfs_wb_all(struct inode *inode)
>>>> 
>>>> 	return sync_inode(inode, &wbc);
>>>> }
>>>> +EXPORT_SYMBOL_GPL(nfs_wb_all);
>>>> 
>>>> int nfs_wb_page_cancel(struct inode *inode, struct page *page)
>>>> {
>>>> -- 
>>>> 1.7.8.3
>>>> 
>>>> --
>>>> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
>>>> the body of a message to majordomo@vger.kernel.org
>>>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>>> 
>> 
>> 
> 
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com




