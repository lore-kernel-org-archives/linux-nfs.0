Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:39168 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752214Ab1KDVa7 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 4 Nov 2011 17:30:59 -0400
Date: Fri, 4 Nov 2011 17:30:58 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: bjschuma@netapp.com
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH 1/3] NFSD: Added fault injection
Message-ID: <20111104213058.GH721@fieldses.org>
References: <1320168923-29671-1-git-send-email-bjschuma@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1320168923-29671-1-git-send-email-bjschuma@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Nov 01, 2011 at 01:35:21PM -0400, bjschuma@netapp.com wrote:
> From: Bryan Schumaker <bjschuma@netapp.com>
> 
> Fault injection on the NFS server makes it easier to test the client's
> state manager and recovery threads.  Simulating errors on the server is
> easier than finding the right conditions that cause them naturally.
> 
> This patch uses debugfs to add a simple framework for fault injection to
> the server.  This framework is a config option, and can be enabled
> through CONFIG_NFSD_FAULT_INJECTION.  Assuming you have debugfs mounted
> to /sys/debug, a set of files will be created in /sys/debug/nfsd/.
> Writing to any of these files will cause the corresponding action and
> write a log entry to dmesg.

These look good to me, thanks; applying for 3.3.

Oh, just one request for next time:

> Changes in v6:
> - Check the return code when creating debugfs files
> - Clean up fault injection before freeing slabs

In general we don't want this sort of thing in the final changelog.
Better to write the changelog as if this is how you meant to do it all
along, and add this sort of meta-changelog to a coverletter if it's
needed.  I'll cut it out.

--b.

> 
> Changes in v5:
> - Fill out inject_ops[] array without a macro
> - Simplify debug messages and file creation
> 
> Changes in v4:
> - Move fault injection function declarations to a new .h file
> - Use the Makefile to selectively compile fault_injection.c
> - Add copyright notices to top of files
> 
> Changes in v3:
> - Code cleanup and better use of generic functions
> - Allow the user to input the number of state objects to delete
> - Remove "forget_everything()" since forgetting a client is basically
>   the same thing
> 
> Changes in v2:
> - Replaced "forget all state owners" with "forget all open owners"
> - Include fs/nfsd/fault_inject.c in the patch
> 
> Signed-off-by: Bryan Schumaker <bjschuma@netapp.com>
> ---
>  fs/nfsd/Kconfig        |   10 ++++
>  fs/nfsd/Makefile       |    1 +
>  fs/nfsd/fault_inject.c |   91 ++++++++++++++++++++++++++++++++++++++
>  fs/nfsd/fault_inject.h |   28 ++++++++++++
>  fs/nfsd/nfs4state.c    |  115 ++++++++++++++++++++++++++++++++++++++++++++++++
>  fs/nfsd/nfsctl.c       |    7 +++
>  6 files changed, 252 insertions(+), 0 deletions(-)
>  create mode 100644 fs/nfsd/fault_inject.c
>  create mode 100644 fs/nfsd/fault_inject.h
> 
> diff --git a/fs/nfsd/Kconfig b/fs/nfsd/Kconfig
> index 10e6366..8df1ea4 100644
> --- a/fs/nfsd/Kconfig
> +++ b/fs/nfsd/Kconfig
> @@ -80,3 +80,13 @@ config NFSD_V4
>  	  available from http://linux-nfs.org/.
>  
>  	  If unsure, say N.
> +
> +config NFSD_FAULT_INJECTION
> +	bool "NFS server manual fault injection"
> +	depends on NFSD_V4 && DEBUG_KERNEL
> +	help
> +	  This option enables support for manually injecting faults
> +	  into the NFS server.  This is intended to be used for
> +	  testing error recovery on the NFS client.
> +
> +	  If unsure, say N.
> diff --git a/fs/nfsd/Makefile b/fs/nfsd/Makefile
> index 9b118ee..af32ef0 100644
> --- a/fs/nfsd/Makefile
> +++ b/fs/nfsd/Makefile
> @@ -6,6 +6,7 @@ obj-$(CONFIG_NFSD)	+= nfsd.o
>  
>  nfsd-y 			:= nfssvc.o nfsctl.o nfsproc.o nfsfh.o vfs.o \
>  			   export.o auth.o lockd.o nfscache.o nfsxdr.o stats.o
> +nfsd-$(CONFIG_NFSD_FAULT_INJECTION) += fault_inject.o
>  nfsd-$(CONFIG_NFSD_V2_ACL) += nfs2acl.o
>  nfsd-$(CONFIG_NFSD_V3)	+= nfs3proc.o nfs3xdr.o
>  nfsd-$(CONFIG_NFSD_V3_ACL) += nfs3acl.o
> diff --git a/fs/nfsd/fault_inject.c b/fs/nfsd/fault_inject.c
> new file mode 100644
> index 0000000..ce7f075
> --- /dev/null
> +++ b/fs/nfsd/fault_inject.c
> @@ -0,0 +1,91 @@
> +/*
> + * Copyright (c) 2011 Bryan Schumaker <bjschuma@netapp.com>
> + *
> + * Uses debugfs to create fault injection points for client testing
> + */
> +
> +#include <linux/types.h>
> +#include <linux/fs.h>
> +#include <linux/debugfs.h>
> +#include <linux/module.h>
> +
> +#include "state.h"
> +#include "fault_inject.h"
> +
> +struct nfsd_fault_inject_op {
> +	char *file;
> +	void (*func)(u64);
> +};
> +
> +static struct nfsd_fault_inject_op inject_ops[] = {
> +	{
> +		.file   = "forget_clients",
> +		.func   = nfsd_forget_clients,
> +	},
> +	{
> +		.file   = "forget_locks",
> +		.func   = nfsd_forget_locks,
> +	},
> +	{
> +		.file   = "forget_openowners",
> +		.func   = nfsd_forget_openowners,
> +	},
> +	{
> +		.file   = "forget_delegations",
> +		.func   = nfsd_forget_delegations,
> +	},
> +	{
> +		.file   = "recall_delegations",
> +		.func   = nfsd_recall_delegations,
> +	},
> +};
> +
> +static long int NUM_INJECT_OPS = sizeof(inject_ops) / sizeof(struct nfsd_fault_inject_op);
> +static struct dentry *debug_dir;
> +
> +static int nfsd_inject_set(void *op_ptr, u64 val)
> +{
> +	struct nfsd_fault_inject_op *op = op_ptr;
> +
> +	if (val == 0)
> +		printk(KERN_INFO "NFSD Fault Injection: %s (all)", op->file);
> +	else
> +		printk(KERN_INFO "NFSD Fault Injection: %s (n = %llu)", op->file, val);
> +
> +	op->func(val);
> +	return 0;
> +}
> +
> +static int nfsd_inject_get(void *data, u64 *val)
> +{
> +	return 0;
> +}
> +
> +DEFINE_SIMPLE_ATTRIBUTE(fops_nfsd, nfsd_inject_get, nfsd_inject_set, "%llu\n");
> +
> +void nfsd_fault_inject_cleanup(void)
> +{
> +	debugfs_remove_recursive(debug_dir);
> +}
> +
> +int nfsd_fault_inject_init(void)
> +{
> +	unsigned int i;
> +	struct nfsd_fault_inject_op *op;
> +	mode_t mode = S_IFREG | S_IRUSR | S_IWUSR;
> +
> +	debug_dir = debugfs_create_dir("nfsd", NULL);
> +	if (!debug_dir)
> +		goto fail;
> +
> +	for (i = 0; i < NUM_INJECT_OPS; i++) {
> +		op = &inject_ops[i];
> +		if (!debugfs_create_file(op->file, mode, debug_dir, op, &fops_nfsd))
> +			goto fail;
> +	}
> +	return 0;
> +
> +fail:
> +	nfsd_fault_inject_cleanup();
> +	return -ENOMEM;
> +}
> diff --git a/fs/nfsd/fault_inject.h b/fs/nfsd/fault_inject.h
> new file mode 100644
> index 0000000..90bd057
> --- /dev/null
> +++ b/fs/nfsd/fault_inject.h
> @@ -0,0 +1,28 @@
> +/*
> + * Copyright (c) 2011 Bryan Schumaker <bjschuma@netapp.com>
> + *
> + * Function definitions for fault injection
> + */
> +
> +#ifndef LINUX_NFSD_FAULT_INJECT_H
> +#define LINUX_NFSD_FAULT_INJECT_H
> +
> +#ifdef CONFIG_NFSD_FAULT_INJECTION
> +int nfsd_fault_inject_init(void);
> +void nfsd_fault_inject_cleanup(void);
> +void nfsd_forget_clients(u64);
> +void nfsd_forget_locks(u64);
> +void nfsd_forget_openowners(u64);
> +void nfsd_forget_delegations(u64);
> +void nfsd_recall_delegations(u64);
> +#else /* CONFIG_NFSD_FAULT_INJECTION */
> +static inline int nfsd_fault_inject_init(void) { return 0; }
> +static inline void nfsd_fault_inject_cleanup(void) {}
> +static inline void nfsd_forget_clients(u64 num) {}
> +static inline void nfsd_forget_locks(u64 num) {}
> +static inline void nfsd_forget_openowners(u64 num) {}
> +static inline void nfsd_forget_delegations(u64 num) {}
> +static inline void nfsd_recall_delegations(u64 num) {}
> +#endif /* CONFIG_NFSD_FAULT_INJECTION */
> +
> +#endif /* LINUX_NFSD_FAULT_INJECT_H */
> diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
> index 47e94e3..3c3762e 100644
> --- a/fs/nfsd/nfs4state.c
> +++ b/fs/nfsd/nfs4state.c
> @@ -4394,6 +4394,121 @@ nfs4_check_open_reclaim(clientid_t *clid)
>  	return nfs4_find_reclaim_client(clid) ? nfs_ok : nfserr_reclaim_bad;
>  }
>  
> +#ifdef CONFIG_NFSD_FAULT_INJECTION
> +
> +void nfsd_forget_clients(u64 num)
> +{
> +	struct nfs4_client *clp, *next;
> +	int count = 0;
> +
> +	nfs4_lock_state();
> +	list_for_each_entry_safe(clp, next, &client_lru, cl_lru) {
> +		nfsd4_remove_clid_dir(clp);
> +		expire_client(clp);
> +		if (++count == num)
> +			break;
> +	}
> +	nfs4_unlock_state();
> +
> +	printk(KERN_INFO "NFSD: Forgot %d clients", count);
> +}
> +
> +static void release_lockowner_sop(struct nfs4_stateowner *sop)
> +{
> +	release_lockowner(lockowner(sop));
> +}
> +
> +static void release_openowner_sop(struct nfs4_stateowner *sop)
> +{
> +	release_openowner(openowner(sop));
> +}
> +
> +static int nfsd_release_n_owners(u64 num,
> +				struct list_head hashtbl[],
> +				unsigned int hashtbl_size,
> +				void (*release_sop)(struct nfs4_stateowner *))
> +{
> +	int i, count = 0;
> +	struct nfs4_stateowner *sop, *next;
> +
> +	for (i = 0; i < hashtbl_size; i++) {
> +		list_for_each_entry_safe(sop, next, &hashtbl[i], so_strhash) {
> +			release_sop(sop);
> +			if (++count == num)
> +				return count;
> +		}
> +	}
> +	return count;
> +}
> +
> +void nfsd_forget_locks(u64 num)
> +{
> +	int count;
> +
> +	nfs4_lock_state();
> +	count = nfsd_release_n_owners(num, lock_ownerstr_hashtbl,
> +				     LOCK_HASH_SIZE, release_lockowner_sop);
> +	nfs4_unlock_state();
> +
> +	printk(KERN_INFO "NFSD: Forgot %d locks", count);
> +}
> +
> +void nfsd_forget_openowners(u64 num)
> +{
> +	int count;
> +
> +	nfs4_lock_state();
> +	count = nfsd_release_n_owners(num, open_ownerstr_hashtbl,
> +				     OPEN_OWNER_HASH_SIZE, release_openowner_sop);
> +	nfs4_unlock_state();
> +
> +	printk(KERN_INFO "NFSD: Forgot %d open owners", count);
> +}
> +
> +int nfsd_process_n_delegations(u64 num, void (*deleg_func)(struct nfs4_delegation *))
> +{
> +	int i, count = 0;
> +	struct nfs4_file *fp;
> +	struct nfs4_delegation *dp, *next;
> +
> +	for (i = 0; i < FILE_HASH_SIZE; i++) {
> +		list_for_each_entry(fp, &file_hashtbl[i], fi_hash) {
> +			list_for_each_entry_safe(dp, next, &fp->fi_delegations, dl_perfile) {
> +				deleg_func(dp);
> +				if (++count == num)
> +					return count;
> +			}
> +		}
> +	}
> +	return count;
> +}
> +
> +void nfsd_forget_delegations(u64 num)
> +{
> +	unsigned int count;
> +
> +	nfs4_lock_state();
> +	count = nfsd_process_n_delegations(num, unhash_delegation);
> +	nfs4_unlock_state();
> +
> +	printk(KERN_INFO "NFSD: Forgot %d delegations", count);
> +}
> +
> +void nfsd_recall_delegations(u64 num)
> +{
> +	unsigned int count;
> +
> +	nfs4_lock_state();
> +	spin_lock(&recall_lock);
> +	count = nfsd_process_n_delegations(num, nfsd_break_one_deleg);
> +	spin_unlock(&recall_lock);
> +	nfs4_unlock_state();
> +
> +	printk(KERN_INFO "NFSD: Recalled %d delegations", count);
> +}
> +
> +#endif /* CONFIG_NFSD_FAULT_INJECTION */
> +
>  /* initialization to perform at module load time: */
>  
>  int
> diff --git a/fs/nfsd/nfsctl.c b/fs/nfsd/nfsctl.c
> index db34a58..34c841a 100644
> --- a/fs/nfsd/nfsctl.c
> +++ b/fs/nfsd/nfsctl.c
> @@ -17,6 +17,7 @@
>  #include "idmap.h"
>  #include "nfsd.h"
>  #include "cache.h"
> +#include "fault_inject.h"
>  
>  /*
>   *	We have a single directory with several nodes in it.
> @@ -1130,6 +1131,9 @@ static int __init init_nfsd(void)
>  	retval = nfs4_state_init(); /* nfs4 locking state */
>  	if (retval)
>  		return retval;
> +	retval = nfsd_fault_inject_init(); /* nfsd fault injection controls */
> +	if (retval)
> +		goto out_free_slabs;
>  	nfsd_stat_init();	/* Statistics */
>  	retval = nfsd_reply_cache_init();
>  	if (retval)
> @@ -1160,6 +1164,8 @@ out_free_cache:
>  	nfsd_reply_cache_shutdown();
>  out_free_stat:
>  	nfsd_stat_shutdown();
> +	nfsd_fault_inject_cleanup();
> +out_free_slabs:
>  	nfsd4_free_slabs();
>  	return retval;
>  }
> @@ -1174,6 +1180,7 @@ static void __exit exit_nfsd(void)
>  	nfsd_lockd_shutdown();
>  	nfsd_idmap_shutdown();
>  	nfsd4_free_slabs();
> +	nfsd_fault_inject_cleanup();
>  	unregister_filesystem(&nfsd_fs_type);
>  }
>  
> -- 
> 1.7.7
> 
