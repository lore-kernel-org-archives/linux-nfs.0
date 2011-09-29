Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:44241 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753614Ab1I2T0s (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 29 Sep 2011 15:26:48 -0400
Message-ID: <4E84C676.1000004@netapp.com>
Date: Thu, 29 Sep 2011 15:26:46 -0400
From: Bryan Schumaker <bjschuma@netapp.com>
To: Chuck Lever <chuck.lever@oracle.com>
CC: bfields@fieldses.org, linux-nfs@vger.kernel.org
Subject: Re: [PATCH v3 1/3] NFSD: Added fault injection
References: <1317322765-19094-1-git-send-email-bjschuma@netapp.com> <A7558C0C-378A-42E3-AC37-8152C50972DB@oracle.com> <4E84C3D7.9040206@netapp.com> <B069285B-09F2-4D66-AD3A-75E76C1D7DE9@oracle.com>
In-Reply-To: <B069285B-09F2-4D66-AD3A-75E76C1D7DE9@oracle.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 09/29/2011 03:22 PM, Chuck Lever wrote:
> 
> On Sep 29, 2011, at 3:15 PM, Bryan Schumaker wrote:
> 
>> On 09/29/2011 03:06 PM, Chuck Lever wrote:
>>>
>>> On Sep 29, 2011, at 2:59 PM, bjschuma@netapp.com wrote:
>>>
>>>> From: Bryan Schumaker <bjschuma@netapp.com>
>>>>
>>>> Fault injection on the NFS server makes it easier to test the client's
>>>> state manager and recovery threads.  Simulating errors on the server is
>>>> easier than finding the right conditions that cause them naturally.
>>>>
>>>> This patch uses debugfs to add a simple framework for fault injection to
>>>> the server.  This framework is a config option, and can be enabled
>>>> through CONFIG_NFSD_FAULT_INJECTION.  Assuming you have debugfs mounted
>>>> to /sys/debug, a set of files will be created in /sys/debug/nfsd/.
>>>> Writing to any of these files will cause the corresponding action and
>>>> write a log entry to dmesg.
>>>>
>>>> Changes in v3:
>>>> - Code cleanup and better use of generic functions
>>>> - Allow the user to input the number of state objects to delete
>>>> - Remove "forget_everything()" since forgetting a client is basically
>>>> the same thing
>>>>
>>>> Changes in v2:
>>>> - Replaced "forget all state owners" with "forget all open owners"
>>>> - Include fs/nfsd/fault_inject.c in the patch
>>>>
>>>> Signed-off-by: Bryan Schumaker <bjschuma@netapp.com>
>>>> ---
>>>> fs/nfsd/Kconfig        |   10 ++++
>>>> fs/nfsd/Makefile       |    3 +-
>>>> fs/nfsd/fault_inject.c |  102 ++++++++++++++++++++++++++++++++++++++++++
>>>> fs/nfsd/nfs4state.c    |  115 ++++++++++++++++++++++++++++++++++++++++++++++++
>>>> fs/nfsd/nfsctl.c       |    6 +++
>>>> fs/nfsd/nfsd.h         |   12 +++++
>>>> 6 files changed, 247 insertions(+), 1 deletions(-)
>>>> create mode 100644 fs/nfsd/fault_inject.c
>>>>
>>>> diff --git a/fs/nfsd/Kconfig b/fs/nfsd/Kconfig
>>>> index 10e6366..52fdd1c 100644
>>>> --- a/fs/nfsd/Kconfig
>>>> +++ b/fs/nfsd/Kconfig
>>>> @@ -80,3 +80,13 @@ config NFSD_V4
>>>> 	  available from http://linux-nfs.org/.
>>>>
>>>> 	  If unsure, say N.
>>>> +
>>>> +config NFSD_FAULT_INJECTION
>>>> +	bool "NFS server manual fault injection"
>>>> +	depends on NFSD_V4 && DEBUG_KERNEL
>>>> +	help
>>>> +	  This option enables support for manually injectiong faults
>>>> +	  into the NFS server.  This is intended to be used for
>>>> +	  testing error recovery on the NFS client.
>>>> +
>>>> +	  If unsure, say N.
>>>> diff --git a/fs/nfsd/Makefile b/fs/nfsd/Makefile
>>>> index 9b118ee..69eae75 100644
>>>> --- a/fs/nfsd/Makefile
>>>> +++ b/fs/nfsd/Makefile
>>>> @@ -5,7 +5,8 @@
>>>> obj-$(CONFIG_NFSD)	+= nfsd.o
>>>>
>>>> nfsd-y 			:= nfssvc.o nfsctl.o nfsproc.o nfsfh.o vfs.o \
>>>> -			   export.o auth.o lockd.o nfscache.o nfsxdr.o stats.o
>>>> +			   export.o auth.o lockd.o nfscache.o nfsxdr.o stats.o \
>>>> +			   fault_inject.o
>>>> nfsd-$(CONFIG_NFSD_V2_ACL) += nfs2acl.o
>>>> nfsd-$(CONFIG_NFSD_V3)	+= nfs3proc.o nfs3xdr.o
>>>> nfsd-$(CONFIG_NFSD_V3_ACL) += nfs3acl.o
>>>> diff --git a/fs/nfsd/fault_inject.c b/fs/nfsd/fault_inject.c
>>>> new file mode 100644
>>>> index 0000000..2139883
>>>> --- /dev/null
>>>> +++ b/fs/nfsd/fault_inject.c
>>>> @@ -0,0 +1,102 @@
>>>> +#ifdef CONFIG_NFSD_FAULT_INJECTION
>>>
>>> The usual practice is to conditionally compile this source file via a Makefile variable, not by wrapping the whole source file in an ifdef.  You can see examples of this in the Makefile hunk above.
>> Yeah, I see that now (although I don't know how I missed it earlier).  Thanks!
>>
>>>
>>> General comment, though: would it make sense to add fault injection points to lockd as well?
>> That would probably be the easiest way to force lock recovery over v2 and v3, which sounds useful to me.
> 
> Useful, yes; but unfortunately that's not as simple as it sounds.  If you just want to hook into the reboot recovery code in fs/lockd/host.c, you need an additional parameter (which is managed by statd) to narrow the lock clearing to a single client.  Now, if you're thinking of clearing all locks and triggering a grace period, that might be easier to do.
I'm not sure how the users could specify a client to use to clear locks, so that would make it harder to narrow to one client.  I'll probably mimic what I do with v4 and clear the first n locks that I find, and let users specify the value of n.

> 
>>  I think I already have it on a todo list somewhere...
>>
>> - Bryan
>>
>>>
>>>> +
>>>> +#include <linux/types.h>
>>>> +#include <linux/fs.h>
>>>> +#include <linux/debugfs.h>
>>>> +#include <linux/module.h>
>>>> +
>>>> +#include "state.h"
>>>> +#include "nfsd.h"
>>>> +
>>>> +struct nfsd_fault_inject_op {
>>>> +	char *action;
>>>> +	char *item;
>>>> +	char *file;
>>>> +	int file_data;
>>>> +	void (*func)(u64);
>>>> +};
>>>> +
>>>> +#define INJECTION_OP(op_action, op_item, op_func)	\
>>>> +{							\
>>>> +	.action = op_action,				\
>>>> +	.item   = op_item,				\
>>>> +	.file   = op_action"_"op_item,			\
>>>> +	.func   = op_func,				\
>>>> +}
>>>> +
>>>> +static struct nfsd_fault_inject_op inject_ops[] = {
>>>> +	INJECTION_OP("forget", "clients",     nfsd_forget_clients),
>>>> +	INJECTION_OP("forget", "locks",       nfsd_forget_locks),
>>>> +	INJECTION_OP("forget", "openowners",  nfsd_forget_openowners),
>>>> +	INJECTION_OP("forget", "delegations", nfsd_forget_delegations),
>>>> +	INJECTION_OP("recall", "delegations", nfsd_recall_delegations),
>>>> +};
>>>> +
>>>> +static long int NUM_INJECT_OPS = sizeof(inject_ops) / sizeof(struct nfsd_fault_inject_op);
>>>> +static struct dentry *debug_dir;
>>>> +
>>>> +static int nfsd_inject_set(void *data, u64 val)
>>>> +{
>>>> +	int i;
>>>> +	struct nfsd_fault_inject_op *op;
>>>> +
>>>> +	for (i = 0; i < NUM_INJECT_OPS; i++) {
>>>> +		op = &inject_ops[i];
>>>> +		if (&op->file_data == data) {
>>>> +			if (val == 0) {
>>>> +				printk(KERN_INFO "NFSD: Server %sing all %s",
>>>> +				op->action, op->item);
>>>> +			} else {
>>>> +				printk(KERN_INFO "NFSD: Server %sing at most %llu %s",
>>>> +				op->action, val, op->item);
>>>> +			}
>>>> +			op->func(val);
>>>> +		}
>>>> +	}
>>>> +	return 0;
>>>> +}
>>>> +
>>>> +static int nfsd_inject_get(void *data, u64 *val)
>>>> +{
>>>> +	return 0;
>>>> +}
>>>> +
>>>> +DEFINE_SIMPLE_ATTRIBUTE(fops_nfsd, nfsd_inject_get, nfsd_inject_set, "%llu\n");
>>>> +
>>>> +void nfsd_fault_inject_cleanup(void)
>>>> +{
>>>> +	debugfs_remove_recursive(debug_dir);
>>>> +}
>>>> +
>>>> +int nfsd_fault_inject_init(void)
>>>> +{
>>>> +	unsigned int i;
>>>> +	struct nfsd_fault_inject_op *op;
>>>> +	mode_t mode = S_IFREG | S_IRUSR | S_IWUSR;
>>>> +
>>>> +	debug_dir = debugfs_create_dir("nfsd", NULL);
>>>> +	if (!debug_dir)
>>>> +		goto fail;
>>>> +
>>>> +	for (i = 0; i < NUM_INJECT_OPS; i++) {
>>>> +		op = &inject_ops[i];
>>>> +		debugfs_create_file(op->file, mode, debug_dir, &op->file_data, &fops_nfsd);
>>>> +	}
>>>> +	return 0;
>>>> +
>>>> +fail:
>>>> +	nfsd_fault_inject_cleanup();
>>>> +	return -ENOMEM;
>>>> +}
>>>> +
>>>> +#else /* CONFIG_NFSD_FAULT_INJECTION */
>>>> +
>>>> +inline void nfsd_fault_inject_cleanup(void)
>>>> +{}
>>>> +
>>>> +inline int nfsd_fault_inject_init(void)
>>>> +{
>>>> +	return 0;
>>>> +}
>>>> +
>>>> +#endif /* CONFIG_NFSD_FAULT_INJECTION */
>>>> diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
>>>> index 05f4c69..64fa6b0 100644
>>>> --- a/fs/nfsd/nfs4state.c
>>>> +++ b/fs/nfsd/nfs4state.c
>>>> @@ -4358,6 +4358,121 @@ nfs4_check_open_reclaim(clientid_t *clid)
>>>> 	return nfs4_find_reclaim_client(clid) ? nfs_ok : nfserr_reclaim_bad;
>>>> }
>>>>
>>>> +#ifdef CONFIG_NFSD_FAULT_INJECTION
>>>> +
>>>> +void nfsd_forget_clients(u64 num)
>>>> +{
>>>> +	struct nfs4_client *clp, *next;
>>>> +	int count = 0;
>>>> +
>>>> +	nfs4_lock_state();
>>>> +	list_for_each_entry_safe(clp, next, &client_lru, cl_lru) {
>>>> +		nfsd4_remove_clid_dir(clp);
>>>> +		expire_client(clp);
>>>> +		if (++count == num)
>>>> +			break;
>>>> +	}
>>>> +	nfs4_unlock_state();
>>>> +
>>>> +	printk(KERN_INFO "NFSD: Forgot %d clients", count);
>>>> +}
>>>> +
>>>> +static void release_lockowner_sop(struct nfs4_stateowner *sop)
>>>> +{
>>>> +	release_lockowner(lockowner(sop));
>>>> +}
>>>> +
>>>> +static void release_openowner_sop(struct nfs4_stateowner *sop)
>>>> +{
>>>> +	release_openowner(openowner(sop));
>>>> +}
>>>> +
>>>> +static int nfsd_release_n_owners(u64 num,
>>>> +				struct list_head hashtbl[],
>>>> +				unsigned int hashtbl_size,
>>>> +				void (*release_sop)(struct nfs4_stateowner *))
>>>> +{
>>>> +	int i, count = 0;
>>>> +	struct nfs4_stateowner *sop, *next;
>>>> +
>>>> +	for (i = 0; i < hashtbl_size; i++) {
>>>> +		list_for_each_entry_safe(sop, next, &hashtbl[i], so_strhash) {
>>>> +			release_sop(sop);
>>>> +			if (++count == num)
>>>> +				return count;
>>>> +		}
>>>> +	}
>>>> +	return count;
>>>> +}
>>>> +
>>>> +void nfsd_forget_locks(u64 num)
>>>> +{
>>>> +	int count;
>>>> +
>>>> +	nfs4_lock_state();
>>>> +	count = nfsd_release_n_owners(num, lock_ownerstr_hashtbl,
>>>> +				     LOCK_HASH_SIZE, release_lockowner_sop);
>>>> +	nfs4_unlock_state();
>>>> +
>>>> +	printk(KERN_INFO "NFSD: Forgot %d locks", count);
>>>> +}
>>>> +
>>>> +void nfsd_forget_openowners(u64 num)
>>>> +{
>>>> +	int count;
>>>> +
>>>> +	nfs4_lock_state();
>>>> +	count = nfsd_release_n_owners(num, open_ownerstr_hashtbl,
>>>> +				     OPEN_OWNER_HASH_SIZE, release_openowner_sop);
>>>> +	nfs4_unlock_state();
>>>> +
>>>> +	printk(KERN_INFO "NFSD: Forgot %d open owners", count);
>>>> +}
>>>> +
>>>> +int nfsd_process_n_delegations(u64 num, void (*deleg_func)(struct nfs4_delegation *))
>>>> +{
>>>> +	int i, count = 0;
>>>> +	struct nfs4_file *fp;
>>>> +	struct nfs4_delegation *dp, *next;
>>>> +
>>>> +	for (i = 0; i < FILE_HASH_SIZE; i++) {
>>>> +		list_for_each_entry(fp, &file_hashtbl[i], fi_hash) {
>>>> +			list_for_each_entry_safe(dp, next, &fp->fi_delegations, dl_perfile) {
>>>> +				deleg_func(dp);
>>>> +				if (++count == num)
>>>> +					return count;
>>>> +			}
>>>> +		}
>>>> +	}
>>>> +	return count;
>>>> +}
>>>> +
>>>> +void nfsd_forget_delegations(u64 num)
>>>> +{
>>>> +	unsigned int count;
>>>> +
>>>> +	nfs4_lock_state();
>>>> +	count = nfsd_process_n_delegations(num, unhash_delegation);
>>>> +	nfs4_unlock_state();
>>>> +
>>>> +	printk(KERN_INFO "NFSD: Forgot %d delegations", count);
>>>> +}
>>>> +
>>>> +void nfsd_recall_delegations(u64 num)
>>>> +{
>>>> +	unsigned int count;
>>>> +
>>>> +	nfs4_lock_state();
>>>> +	spin_lock(&recall_lock);
>>>> +	count = nfsd_process_n_delegations(num, nfsd_break_one_deleg);
>>>> +	spin_unlock(&recall_lock);
>>>> +	nfs4_unlock_state();
>>>> +
>>>> +	printk(KERN_INFO "NFSD: Recalled %d delegations", count);
>>>> +}
>>>> +
>>>> +#endif /* CONFIG_NFSD_FAULT_INJECTION */
>>>> +
>>>> /* initialization to perform at module load time: */
>>>>
>>>> int
>>>> diff --git a/fs/nfsd/nfsctl.c b/fs/nfsd/nfsctl.c
>>>> index db34a58..e2f1b5a 100644
>>>> --- a/fs/nfsd/nfsctl.c
>>>> +++ b/fs/nfsd/nfsctl.c
>>>> @@ -1130,6 +1130,9 @@ static int __init init_nfsd(void)
>>>> 	retval = nfs4_state_init(); /* nfs4 locking state */
>>>> 	if (retval)
>>>> 		return retval;
>>>> +	retval = nfsd_fault_inject_init(); /* nfsd fault injection controls */
>>>> +	if (retval)
>>>> +		goto out_cleanup_fault_injection;
>>>> 	nfsd_stat_init();	/* Statistics */
>>>> 	retval = nfsd_reply_cache_init();
>>>> 	if (retval)
>>>> @@ -1161,6 +1164,8 @@ out_free_cache:
>>>> out_free_stat:
>>>> 	nfsd_stat_shutdown();
>>>> 	nfsd4_free_slabs();
>>>> +out_cleanup_fault_injection:
>>>> +	nfsd_fault_inject_cleanup();
>>>> 	return retval;
>>>> }
>>>>
>>>> @@ -1174,6 +1179,7 @@ static void __exit exit_nfsd(void)
>>>> 	nfsd_lockd_shutdown();
>>>> 	nfsd_idmap_shutdown();
>>>> 	nfsd4_free_slabs();
>>>> +	nfsd_fault_inject_cleanup();
>>>> 	unregister_filesystem(&nfsd_fs_type);
>>>> }
>>>>
>>>> diff --git a/fs/nfsd/nfsd.h b/fs/nfsd/nfsd.h
>>>> index 58134a2..3ea303d 100644
>>>> --- a/fs/nfsd/nfsd.h
>>>> +++ b/fs/nfsd/nfsd.h
>>>> @@ -105,11 +105,18 @@ static inline int nfsd_v4client(struct svc_rqst *rq)
>>>> #ifdef CONFIG_NFSD_V4
>>>> extern unsigned int max_delegations;
>>>> int nfs4_state_init(void);
>>>> +int nfsd_fault_inject_init(void);
>>>> +void nfsd_fault_inject_cleanup(void);
>>>> void nfsd4_free_slabs(void);
>>>> int nfs4_state_start(void);
>>>> void nfs4_state_shutdown(void);
>>>> void nfs4_reset_lease(time_t leasetime);
>>>> int nfs4_reset_recoverydir(char *recdir);
>>>> +void nfsd_forget_clients(u64);
>>>> +void nfsd_forget_locks(u64);
>>>> +void nfsd_forget_openowners(u64);
>>>> +void nfsd_forget_delegations(u64);
>>>> +void nfsd_recall_delegations(u64);
>>>> #else
>>>> static inline int nfs4_state_init(void) { return 0; }
>>>> static inline void nfsd4_free_slabs(void) { }
>>>> @@ -117,6 +124,11 @@ static inline int nfs4_state_start(void) { return 0; }
>>>> static inline void nfs4_state_shutdown(void) { }
>>>> static inline void nfs4_reset_lease(time_t leasetime) { }
>>>> static inline int nfs4_reset_recoverydir(char *recdir) { return 0; }
>>>> +static inline void nfsd_forget_clients(u64) {}
>>>> +static inline void nfsd_forget_locks(u64) {}
>>>> +static inline void nfsd_forget_openowners(u64) {}
>>>> +static inline void nfsd_forget_delegations(u64) {}
>>>> +static inline void nfsd_recall_delegations(u64) {}
>>>> #endif
>>>>
>>>> /*
>>>> -- 
>>>> 1.7.6.4
>>>>
>>>> --
>>>> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
>>>> the body of a message to majordomo@vger.kernel.org
>>>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>>>
>>
> 

