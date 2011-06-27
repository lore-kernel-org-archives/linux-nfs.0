Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:6364 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754093Ab1F0UCL (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 27 Jun 2011 16:02:11 -0400
Message-ID: <4E08E1A0.9020101@netapp.com>
Date: Mon, 27 Jun 2011 16:01:36 -0400
From: Bryan Schumaker <bjschuma@netapp.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [RFC v2] NFSD: Added basic fault injection
References: <4DD6AF42.5050502@netapp.com> <20110623195526.GA12357@fieldses.org> <4E087ABE.5090108@netapp.com>
In-Reply-To: <4E087ABE.5090108@netapp.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 06/27/2011 08:42 AM, Bryan Schumaker wrote:
> On 06/23/2011 03:55 PM, J. Bruce Fields wrote:
>> On Fri, May 20, 2011 at 02:13:22PM -0400, Bryan Schumaker wrote:
>>> I have been looking at adding fault injection to the NFS server in order
>>> to test the client's state manager and recovery threads.  Simulating
>>> errors on the server seems like the easiest way to guarentee that
>>> specific errors happen, and happen when we tell them to.
>>>
>>> This patch uses debugfs to add a simple framework for fault injection to
>>> the server.  This framework is a config option, and can be enabled
>>> through CONFIG_NFSD_FAULT_INJECTION.  Assuming you have debugfs mounted
>>> to /sys/debug, a set of files will be created in /sys/debug/nfsd/.
>>> Writing to any of these files will cause the corresponding action and
>>> write a log entry to dmesg.
>>>
>>> Changes in v2:
>>> - Replaced "forget all state owners" with "forget all open owners"
>>> - Include fs/nfsd/fault_inject.c in the patch
>>>
>>> Suggestions?  Comments?
>>
>> If this is still the most recent version of the patch, and if you can
>> confirm that this has been tried and found useful for testing the
>> client, then I'll go ahead and apply for 3.1.
> 
> Yes, this is the most recent version of the patch.  It is part of my Jenkins setup, but I haven't been running it on a regular basis recently.

Trond and I just talked about more things to add in for fault injection, so I'll hopefully have a new version sometime in the near future.

> 
> - Bryan
> 
>>
>> --b.
>>
>>>
>>> - Bryan
>>> ---
>>> diff --git a/fs/nfsd/Kconfig b/fs/nfsd/Kconfig
>>> index 18b3e89..8c02eab 100644
>>> --- a/fs/nfsd/Kconfig
>>> +++ b/fs/nfsd/Kconfig
>>> @@ -91,3 +91,16 @@ config NFSD_V4
>>>  	  available from http://linux-nfs.org/.
>>>  
>>>  	  If unsure, say N.
>>> +
>>> +config NFSD_FAULT_INJECTION
>>> +	bool "NFS server manual fault injection"
>>> +	depends on NFSD_V4 && DEBUG_KERNEL
>>> +	help
>>> +	  This option enables support for manually injecting faults
>>> +	  into the NFS server.  This is intended to be used for
>>> +	  testing error recovery on the NFS client.
>>> +	  
>>> +	  If unsure, say N.
>>> +
>>> +
>>> +
>>> diff --git a/fs/nfsd/Makefile b/fs/nfsd/Makefile
>>> index 9b118ee..69eae75 100644
>>> --- a/fs/nfsd/Makefile
>>> +++ b/fs/nfsd/Makefile
>>> @@ -5,7 +5,8 @@
>>>  obj-$(CONFIG_NFSD)	+= nfsd.o
>>>  
>>>  nfsd-y 			:= nfssvc.o nfsctl.o nfsproc.o nfsfh.o vfs.o \
>>> -			   export.o auth.o lockd.o nfscache.o nfsxdr.o stats.o
>>> +			   export.o auth.o lockd.o nfscache.o nfsxdr.o stats.o \
>>> +			   fault_inject.o
>>>  nfsd-$(CONFIG_NFSD_V2_ACL) += nfs2acl.o
>>>  nfsd-$(CONFIG_NFSD_V3)	+= nfs3proc.o nfs3xdr.o
>>>  nfsd-$(CONFIG_NFSD_V3_ACL) += nfs3acl.o
>>> diff --git a/fs/nfsd/fault_inject.c b/fs/nfsd/fault_inject.c
>>> new file mode 100644
>>> index 0000000..3dd1c32
>>> --- /dev/null
>>> +++ b/fs/nfsd/fault_inject.c
>>> @@ -0,0 +1,106 @@
>>> +
>>> +#ifdef CONFIG_NFSD_FAULT_INJECTION
>>> +
>>> +#include <linux/types.h>
>>> +#include <linux/fs.h>
>>> +#include <linux/debugfs.h>
>>> +#include <linux/module.h>
>>> +
>>> +#include "state.h"
>>> +#include "nfsd.h"
>>> +
>>> +static void nfsd_forget_everything(void);
>>> +
>>> +struct nfsd_fault_inject_op {
>>> +	char *name;
>>> +	char *text;
>>> +	int file_data;
>>> +	void (*func)(void);
>>> +};
>>> +
>>> +#define INJECTION_OP(op_name, op_text, op_func) \
>>> +{				\
>>> +	.name = op_name,	\
>>> +	.text = op_text,	\
>>> +	.func = op_func,	\
>>> +}
>>> +
>>> +static struct nfsd_fault_inject_op inject_ops[] = {
>>> +	INJECTION_OP("forget_clients",     "forget all clients",     nfsd_forget_all_clients),
>>> +	INJECTION_OP("forget_locks",       "forget all locks",       nfsd_forget_all_locks),
>>> +	INJECTION_OP("forget_open_owners", "forget all open owners", nfsd_forget_all_open_owners),
>>> +	INJECTION_OP("forget_delegations", "forget all delegations", nfsd_forget_all_delegations),
>>> +	INJECTION_OP("forget_everything",  "forget everything",      nfsd_forget_everything),
>>> +	INJECTION_OP("recall_delegations", "recall all delegations", nfsd_recall_all_delegations),
>>> +};
>>> +
>>> +static long int NUM_INJECT_OPS = sizeof(inject_ops) / sizeof(struct nfsd_fault_inject_op);
>>> +static struct dentry *debug_dir;
>>> +
>>> +static void nfsd_forget_everything(void)
>>> +{
>>> +	nfsd_forget_all_clients();
>>> +	nfsd_forget_all_locks();
>>> +	nfsd_forget_all_open_owners();
>>> +	nfsd_forget_all_delegations();
>>> +}
>>> +
>>> +static int nfsd_inject_set(void *data, u64 val)
>>> +{
>>> +	int i;
>>> +	for (i = 0; i < NUM_INJECT_OPS; i++) {
>>> +		if (&inject_ops[i].file_data == data) {
>>> +			printk(KERN_INFO "%s %s Server will %s", __FILE__, __func__, inject_ops[i].text);
>>> +			inject_ops[i].func();
>>> +		}
>>> +	}
>>> +	return 0;
>>> +}
>>> +
>>> +static int nfsd_inject_get(void *data, u64 *val)
>>> +{
>>> +	return 0;
>>> +}
>>> +
>>> +DEFINE_SIMPLE_ATTRIBUTE(fops_nfsd, nfsd_inject_get, nfsd_inject_set, "%llu\n");
>>> +
>>> +void
>>> +nfsd_cleanup_fault_inject(void)
>>> +{
>>> +	debugfs_remove_recursive(debug_dir);
>>> +}
>>> +
>>> +int
>>> +nfsd_fault_inject_init(void)
>>> +{
>>> +	unsigned int i;
>>> +	struct nfsd_fault_inject_op *op;
>>> +	mode_t mode = S_IFREG | S_IRUSR | S_IWUSR;
>>> +
>>> +	debug_dir = debugfs_create_dir("nfsd", NULL);
>>> +	if (!debug_dir)
>>> +		goto fail;
>>> +
>>> +	for (i = 0; i < NUM_INJECT_OPS; i++) {
>>> +		op = &inject_ops[i];
>>> +		debugfs_create_file(op->name, mode, debug_dir, &op->file_data, &fops_nfsd);
>>> +	}
>>> +	return 0;
>>> +fail:
>>> +	nfsd_cleanup_fault_inject();
>>> +	return -ENOMEM;
>>> +}
>>> +
>>> +#else /* CONFIG_NFSD_FAULT_INJECTION */
>>> +
>>> +inline void
>>> +nfsd_cleanup_fault_inject(void)
>>> +{}
>>> +
>>> +inline int
>>> +nfsd_fault_inject_init(void)
>>> +{
>>> +	return 0;
>>> +}
>>> +
>>> +#endif /* CONFIG_NFSD_FAULT_INJECTION */
>>> diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
>>> index 4cf04e1..f555e02 100644
>>> --- a/fs/nfsd/nfs4state.c
>>> +++ b/fs/nfsd/nfs4state.c
>>> @@ -4274,6 +4274,144 @@ nfs4_check_open_reclaim(clientid_t *clid)
>>>  	return nfs4_find_reclaim_client(clid) ? nfs_ok : nfserr_reclaim_bad;
>>>  }
>>>  
>>> +#ifdef CONFIG_NFSD_FAULT_INJECTION
>>> +
>>> +void nfsd_forget_all_clients(void)
>>> +{
>>> +	struct nfs4_client *clp;
>>> +	struct list_head *pos, *next, reaplist;
>>> +	int count = 0;
>>> +
>>> +	nfs4_lock_state();
>>> +	INIT_LIST_HEAD(&reaplist);
>>> +
>>> +	spin_lock(&client_lock);
>>> +	list_for_each_safe(pos, next, &client_lru) {
>>> +		clp = list_entry(pos, struct nfs4_client, cl_lru);
>>> +		unhash_client_locked(clp);
>>> +		list_add(&clp->cl_lru, &reaplist);
>>> +		count ++;
>>> +	}
>>> +	spin_unlock(&client_lock);
>>> +	list_for_each_safe(pos, next, &reaplist) {
>>> +		clp = list_entry(pos, struct nfs4_client, cl_lru);
>>> +		nfsd4_remove_clid_dir(clp);
>>> +		expire_client(clp);
>>> +	}
>>> +
>>> +	nfs4_unlock_state();
>>> +	printk(KERN_INFO "%s %s Forgot %d clients", __FILE__, __func__, count);
>>> +}
>>> +
>>> +void nfsd_forget_all_locks(void)
>>> +{
>>> +	struct nfs4_stateid *stp;
>>> +	struct nfs4_stateowner *sop;
>>> +	struct list_head reaplist;
>>> +	int count = 0;
>>> +	int i;
>>> +
>>> +	INIT_LIST_HEAD(&reaplist);
>>> +	nfs4_lock_state();
>>> +	for (i = 0; i < LOCK_HASH_SIZE; i++) {
>>> +		list_for_each_entry(sop, &lock_ownerid_hashtbl[i], so_idhash) {
>>> +			list_for_each_entry(stp, &sop->so_stateids, st_perstateowner) {
>>> +				list_add(&sop->so_perclient, &reaplist);
>>> +			}
>>> +		}
>>> +	}
>>> +
>>> +	while (!list_empty(&reaplist)) {
>>> +		sop = list_entry(reaplist.next, struct nfs4_stateowner, so_perclient);
>>> +		list_del(&sop->so_perclient);
>>> +		release_lockowner(sop);
>>> +		count ++;
>>> +	}
>>> +	nfs4_unlock_state();
>>> +
>>> +	printk(KERN_INFO "%s %s Forgot %d locks", __FILE__, __func__, count);
>>> +}
>>> +
>>> +void nfsd_forget_all_open_owners(void)
>>> +{
>>> +	struct nfs4_stateid *stp, *next;
>>> +	unsigned int i;
>>> +	int count = 0;
>>> +
>>> +	nfs4_lock_state();
>>> +	for (i = 0; i < STATEID_HASH_SIZE; i++) {
>>> +		list_for_each_entry_safe(stp, next, &stateid_hashtbl[i], st_hash) {
>>> +			if (stp->st_openstp == NULL) {
>>> +				release_openowner(stp->st_stateowner);
>>> +				count++;
>>> +			}
>>> +		}
>>> +	}
>>> +	nfs4_unlock_state();
>>> +	printk(KERN_INFO "%s %s Forgot %d open owners", __FILE__, __func__, count);
>>> +}
>>> +
>>> +void nfsd_forget_all_delegations(void)
>>> +{
>>> +	struct nfs4_file *fp;
>>> +	struct nfs4_delegation *dp;
>>> +	struct list_head *pos, *next, reaplist;
>>> +	unsigned int i;
>>> +	unsigned int count = 0;
>>> +
>>> +	INIT_LIST_HEAD(&reaplist);
>>> +
>>> +	nfs4_lock_state();
>>> +	spin_lock(&recall_lock);
>>> +	for (i = 0; i < FILE_HASH_SIZE; i++) {
>>> +		list_for_each_entry(fp, &file_hashtbl[i], fi_hash) {
>>> +			list_for_each(pos, &fp->fi_delegations) {
>>> +				dp = list_entry(pos, struct nfs4_delegation, dl_perfile);
>>> +				list_del_init(&dp->dl_perclnt);
>>> +				list_move(&dp->dl_recall_lru, &reaplist);
>>> +			}
>>> +		}
>>> +	}
>>> +
>>> +	spin_unlock(&recall_lock);
>>> +	list_for_each_safe(pos, next, &reaplist) {
>>> +		dp = list_entry(pos, struct nfs4_delegation, dl_recall_lru);
>>> +		list_del_init(&dp->dl_recall_lru);
>>> +		unhash_delegation(dp);
>>> +		count++;
>>> +	}
>>> +	nfs4_unlock_state();
>>> +
>>> +	printk(KERN_INFO "%s %s Forgot %d delegations", __FILE__, __func__, count);
>>> +}
>>> +
>>> +void nfsd_recall_all_delegations(void)
>>> +{
>>> +	struct nfs4_file *fp;
>>> +	struct nfs4_delegation *dp;
>>> +	struct list_head *pos;
>>> +	unsigned int i;
>>> +	unsigned int count = 0;
>>> +
>>> +	nfs4_lock_state();
>>> +	spin_lock(&recall_lock);
>>> +	for (i = 0; i < FILE_HASH_SIZE; i++) {
>>> +		list_for_each_entry(fp, &file_hashtbl[i], fi_hash) {
>>> +			list_for_each(pos, &fp->fi_delegations) {
>>> +				dp = list_entry(pos, struct nfs4_delegation, dl_perfile);
>>> +				nfsd_break_one_deleg(dp);
>>> +				count++;
>>> +			}
>>> +		}
>>> +	}
>>> +	spin_unlock(&recall_lock);
>>> +	nfs4_unlock_state();
>>> +	printk(KERN_INFO "%s %s Recalled %d delegations", __FILE__, __func__, count);
>>> +}
>>> +
>>> +#endif /* CONFIG_NFSD_FAULT_INJECTION */
>>> +
>>> +
>>>  /* initialization to perform at module load time: */
>>>  
>>>  int
>>> diff --git a/fs/nfsd/nfsctl.c b/fs/nfsd/nfsctl.c
>>> index 1f5eae4..1eb3e92 100644
>>> --- a/fs/nfsd/nfsctl.c
>>> +++ b/fs/nfsd/nfsctl.c
>>> @@ -1481,6 +1481,9 @@ static int __init init_nfsd(void)
>>>  	retval = nfs4_state_init(); /* nfs4 locking state */
>>>  	if (retval)
>>>  		return retval;
>>> +	retval = nfsd_fault_inject_init(); /* nfsd fault injection controls */
>>> +	if (retval)
>>> +		goto out_cleanup_fault_injection;
>>>  	nfsd_stat_init();	/* Statistics */
>>>  	retval = nfsd_reply_cache_init();
>>>  	if (retval)
>>> @@ -1512,6 +1515,8 @@ out_free_cache:
>>>  out_free_stat:
>>>  	nfsd_stat_shutdown();
>>>  	nfsd4_free_slabs();
>>> +out_cleanup_fault_injection:
>>> +	nfsd_cleanup_fault_inject();
>>>  	return retval;
>>>  }
>>>  
>>> @@ -1525,6 +1530,7 @@ static void __exit exit_nfsd(void)
>>>  	nfsd_lockd_shutdown();
>>>  	nfsd_idmap_shutdown();
>>>  	nfsd4_free_slabs();
>>> +	nfsd_cleanup_fault_inject();
>>>  	unregister_filesystem(&nfsd_fs_type);
>>>  }
>>>  
>>> diff --git a/fs/nfsd/nfsd.h b/fs/nfsd/nfsd.h
>>> index 7ecfa24..4a6cded 100644
>>> --- a/fs/nfsd/nfsd.h
>>> +++ b/fs/nfsd/nfsd.h
>>> @@ -79,11 +79,18 @@ static inline int nfsd_v4client(struct svc_rqst *rq)
>>>  #ifdef CONFIG_NFSD_V4
>>>  extern unsigned int max_delegations;
>>>  int nfs4_state_init(void);
>>> +int nfsd_fault_inject_init(void);
>>> +void nfsd_cleanup_fault_inject(void);
>>>  void nfsd4_free_slabs(void);
>>>  int nfs4_state_start(void);
>>>  void nfs4_state_shutdown(void);
>>>  void nfs4_reset_lease(time_t leasetime);
>>>  int nfs4_reset_recoverydir(char *recdir);
>>> +void nfsd_forget_all_clients(void);
>>> +void nfsd_forget_all_locks(void);
>>> +void nfsd_forget_all_open_owners(void);
>>> +void nfsd_forget_all_delegations(void);
>>> +void nfsd_recall_all_delegations(void);
>>>  #else
>>>  static inline int nfs4_state_init(void) { return 0; }
>>>  static inline void nfsd4_free_slabs(void) { }
>>> @@ -91,6 +98,11 @@ static inline int nfs4_state_start(void) { return 0; }
>>>  static inline void nfs4_state_shutdown(void) { }
>>>  static inline void nfs4_reset_lease(time_t leasetime) { }
>>>  static inline int nfs4_reset_recoverydir(char *recdir) { return 0; }
>>> +static inline void nfsd_forget_all_clients(void) {};
>>> +static inline void nfsd_forget_all_locks(void) {};
>>> +static inline void nfsd_forget_all_open_owners(void) {};
>>> +static inline void nfsd_forget_all_delegations(void) {};
>>> +static inline void nfsd_recall_all_delegations(void) {};
>>>  #endif
>>>  
>>>  /*
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

