Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:21346 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933139Ab1ESPYO (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 19 May 2011 11:24:14 -0400
Message-ID: <4DD5361D.6010304@netapp.com>
Date: Thu, 19 May 2011 11:24:13 -0400
From: Bryan Schumaker <bjschuma@netapp.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: linux-nfs@vger.kernel.org
Subject: Re: [RFC] NFSD: Added basic fault injection
References: <1305651070-24654-1-git-send-email-bjschuma@netapp.com> <20110519000959.GC26545@fieldses.org>
In-Reply-To: <20110519000959.GC26545@fieldses.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 05/18/2011 08:09 PM, J. Bruce Fields wrote:
> On Tue, May 17, 2011 at 12:51:10PM -0400, bjschuma@netapp.com wrote:
>> From: Bryan Schumaker <bjschuma@netapp.com>
>>
>> I have been looking at adding fault injection to the NFS server in order
>> to test the client's state manager and recovery threads.  Simulating
>> errors on the server seems like the easiest way to guarentee that
>> specific errors happen, and happen when we tell them to.
>>
>> This patch uses debugfs to add a simple framework for fault injection to
>> the server.  This framework is a config option, and can be enabled
>> through CONFIG_NFSD_FAULT_INJECTION.  Assuming you have debugfs mounted
>> to /sys/debug, a set of files will be created in /sys/debug/nfsd/.
>> Writing to any of these files will cause the corresponding action and
>> write a log entry to dmesg.
> 
> Seems like a reasonable thing to do.
> 
>> Suggestions?  Comments?
>>
>> - Bryan
>> ---
>>  fs/nfsd/Kconfig     |   13 ++++++
>>  fs/nfsd/Makefile    |    3 +-
>>  fs/nfsd/nfs4state.c |  117 +++++++++++++++++++++++++++++++++++++++++++++++++++
>>  fs/nfsd/nfsctl.c    |    6 +++
>>  fs/nfsd/nfsd.h      |   12 +++++
>>  5 files changed, 150 insertions(+), 1 deletions(-)
>>
>> diff --git a/fs/nfsd/Kconfig b/fs/nfsd/Kconfig
>> index 18b3e89..8c02eab 100644
>> --- a/fs/nfsd/Kconfig
>> +++ b/fs/nfsd/Kconfig
>> @@ -91,3 +91,16 @@ config NFSD_V4
>>  	  available from http://linux-nfs.org/.
>>  
>>  	  If unsure, say N.
>> +
>> +config NFSD_FAULT_INJECTION
>> +	bool "NFS server manual fault injection"
>> +	depends on NFSD_V4 && DEBUG_KERNEL
>> +	help
>> +	  This option enables support for manually injecting faults
>> +	  into the NFS server.  This is intended to be used for
>> +	  testing error recovery on the NFS client.
>> +	  
>> +	  If unsure, say N.
>> +
>> +
>> +
>> diff --git a/fs/nfsd/Makefile b/fs/nfsd/Makefile
>> index 9b118ee..69eae75 100644
>> --- a/fs/nfsd/Makefile
>> +++ b/fs/nfsd/Makefile
>> @@ -5,7 +5,8 @@
>>  obj-$(CONFIG_NFSD)	+= nfsd.o
>>  
>>  nfsd-y 			:= nfssvc.o nfsctl.o nfsproc.o nfsfh.o vfs.o \
>> -			   export.o auth.o lockd.o nfscache.o nfsxdr.o stats.o
>> +			   export.o auth.o lockd.o nfscache.o nfsxdr.o stats.o \
>> +			   fault_inject.o
>>  nfsd-$(CONFIG_NFSD_V2_ACL) += nfs2acl.o
>>  nfsd-$(CONFIG_NFSD_V3)	+= nfs3proc.o nfs3xdr.o
>>  nfsd-$(CONFIG_NFSD_V3_ACL) += nfs3acl.o
>> diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
>> index 4cf04e1..e46c4ef 100644
>> --- a/fs/nfsd/nfs4state.c
>> +++ b/fs/nfsd/nfs4state.c
>> @@ -2991,6 +2991,123 @@ laundromat_main(struct work_struct *not_used)
>>  	queue_delayed_work(laundry_wq, &laundromat_work, t*HZ);
>>  }
>>  
>> +#ifdef CONFIG_NFSD_FAULT_INJECTION
>> +
>> +void nfsd_forget_all_clients(void)
>> +{
>> +	struct nfs4_client *clp;
>> +	struct list_head *pos, *next, reaplist;
>> +	int count = 0;
>> +
>> +	nfs4_lock_state();
>> +	INIT_LIST_HEAD(&reaplist);
>> +
>> +	spin_lock(&client_lock);
>> +	list_for_each_safe(pos, next, &client_lru) {
>> +		clp = list_entry(pos, struct nfs4_client, cl_lru);
>> +		unhash_client_locked(clp);
>> +		list_add(&clp->cl_lru, &reaplist);
>> +		count ++;
>> +	}
>> +	spin_unlock(&client_lock);
>> +	list_for_each_safe(pos, next, &reaplist) {
>> +		clp = list_entry(pos, struct nfs4_client, cl_lru);
>> +		nfsd4_remove_clid_dir(clp);
>> +		expire_client(clp);
>> +	}
>> +
>> +	nfs4_unlock_state();
>> +	printk(KERN_INFO "%s %s Forgot %d clients", __FILE__, __func__, count);
>> +}
>> +
>> +void nfsd_forget_all_state_owners(void)
>> +{
>> +	struct nfs4_stateowner *sop;
>> +	struct list_head *pos, *next;
>> +	int count = 0;
>> +
>> +	nfs4_lock_state();
>> +	list_for_each_safe(pos, next, &close_lru) {
> 
> Not all state owners are on the close_lru list--just open owners that
> have been closed and are waiting to be reaped.

Ok.  Is the file_hashtbl the right place to look for this?  I think I'm going to change the function so it only deletes open stateids.

> 
> --b.
> 
>> +		sop = list_entry(pos, struct nfs4_stateowner, so_close_lru);
>> +		release_openowner(sop);
>> +		count ++;
>> +	};
>> +	nfs4_unlock_state();
>> +	printk(KERN_INFO "%s %s Forgot %d state owners", __FILE__, __func__, count);
>> +}
>> +
>> +void nfsd_count_all_state_owners(void)
>> +{
>> +	struct list_head *pos, *next;
>> +	int count = 0;
>> +
>> +	nfs4_lock_state();
>> +	list_for_each_safe(pos, next, &close_lru)
>> +		count++;
>> +	nfs4_unlock_state();
>> +	printk(KERN_INFO "%s %s Counted %d state owners", __FILE__, __func__, count);
>> +}
>> +
>> +void nfsd_forget_all_delegations(void)
>> +{
>> +	struct nfs4_file *fp;
>> +	struct nfs4_delegation *dp;
>> +	struct list_head *pos, *next, reaplist;
>> +	unsigned int i;
>> +	unsigned int count = 0;
>> +
>> +	INIT_LIST_HEAD(&reaplist);
>> +
>> +	nfs4_lock_state();
>> +	spin_lock(&recall_lock);
>> +	for (i = 0; i < FILE_HASH_SIZE; i++) {
>> +		list_for_each_entry(fp, &file_hashtbl[i], fi_hash) {
>> +			list_for_each(pos, &fp->fi_delegations) {
>> +				dp = list_entry(pos, struct nfs4_delegation, dl_perfile);
>> +				list_del_init(&dp->dl_perclnt);
>> +				list_move(&dp->dl_recall_lru, &reaplist);
>> +			}
>> +		}
>> +	}
>> +
>> +	spin_unlock(&recall_lock);
>> +	list_for_each_safe(pos, next, &reaplist) {
>> +		dp = list_entry(pos, struct nfs4_delegation, dl_recall_lru);
>> +		list_del_init(&dp->dl_recall_lru);
>> +		unhash_delegation(dp);
>> +		count++;
>> +	}
>> +	nfs4_unlock_state();
>> +
>> +	printk(KERN_INFO "%s %s Forgot %d delegations", __FILE__, __func__, count);
>> +}
>> +
>> +void nfsd_recall_all_delegations(void)
>> +{
>> +	struct nfs4_file *fp;
>> +	struct nfs4_delegation *dp;
>> +	struct list_head *pos;
>> +	unsigned int i;
>> +	unsigned int count = 0;
>> +
>> +	nfs4_lock_state();
>> +	spin_lock(&recall_lock);
>> +	for (i = 0; i < FILE_HASH_SIZE; i++) {
>> +		list_for_each_entry(fp, &file_hashtbl[i], fi_hash) {
>> +			list_for_each(pos, &fp->fi_delegations) {
>> +				dp = list_entry(pos, struct nfs4_delegation, dl_perfile);
>> +				nfsd_break_one_deleg(dp);
>> +				count++;
>> +			}
>> +		}
>> +	}
>> +	spin_unlock(&recall_lock);
>> +	nfs4_unlock_state();
>> +	printk(KERN_INFO "%s %s Recalled %d delegations", __FILE__, __func__, count);
>> +}
>> +
>> +#endif /* CONFIG_NFSD_FAULT_INJECTION */
>> +
>>  static struct nfs4_stateowner *
>>  search_close_lru(u32 st_id, int flags)
>>  {
>> diff --git a/fs/nfsd/nfsctl.c b/fs/nfsd/nfsctl.c
>> index 1f5eae4..1eb3e92 100644
>> --- a/fs/nfsd/nfsctl.c
>> +++ b/fs/nfsd/nfsctl.c
>> @@ -1481,6 +1481,9 @@ static int __init init_nfsd(void)
>>  	retval = nfs4_state_init(); /* nfs4 locking state */
>>  	if (retval)
>>  		return retval;
>> +	retval = nfsd_fault_inject_init(); /* nfsd fault injection controls */
>> +	if (retval)
>> +		goto out_cleanup_fault_injection;
>>  	nfsd_stat_init();	/* Statistics */
>>  	retval = nfsd_reply_cache_init();
>>  	if (retval)
>> @@ -1512,6 +1515,8 @@ out_free_cache:
>>  out_free_stat:
>>  	nfsd_stat_shutdown();
>>  	nfsd4_free_slabs();
>> +out_cleanup_fault_injection:
>> +	nfsd_cleanup_fault_inject();
>>  	return retval;
>>  }
>>  
>> @@ -1525,6 +1530,7 @@ static void __exit exit_nfsd(void)
>>  	nfsd_lockd_shutdown();
>>  	nfsd_idmap_shutdown();
>>  	nfsd4_free_slabs();
>> +	nfsd_cleanup_fault_inject();
>>  	unregister_filesystem(&nfsd_fs_type);
>>  }
>>  
>> diff --git a/fs/nfsd/nfsd.h b/fs/nfsd/nfsd.h
>> index 7ecfa24..4e6dd45 100644
>> --- a/fs/nfsd/nfsd.h
>> +++ b/fs/nfsd/nfsd.h
>> @@ -79,11 +79,18 @@ static inline int nfsd_v4client(struct svc_rqst *rq)
>>  #ifdef CONFIG_NFSD_V4
>>  extern unsigned int max_delegations;
>>  int nfs4_state_init(void);
>> +int nfsd_fault_inject_init(void);
>> +void nfsd_cleanup_fault_inject(void);
>>  void nfsd4_free_slabs(void);
>>  int nfs4_state_start(void);
>>  void nfs4_state_shutdown(void);
>>  void nfs4_reset_lease(time_t leasetime);
>>  int nfs4_reset_recoverydir(char *recdir);
>> +void nfsd_forget_all_clients(void);
>> +void nfsd_forget_all_state_owners(void);
>> +void nfsd_count_all_state_owners(void);
>> +void nfsd_forget_all_delegations(void);
>> +void nfsd_recall_all_delegations(void);
>>  #else
>>  static inline int nfs4_state_init(void) { return 0; }
>>  static inline void nfsd4_free_slabs(void) { }
>> @@ -91,6 +98,11 @@ static inline int nfs4_state_start(void) { return 0; }
>>  static inline void nfs4_state_shutdown(void) { }
>>  static inline void nfs4_reset_lease(time_t leasetime) { }
>>  static inline int nfs4_reset_recoverydir(char *recdir) { return 0; }
>> +static inline void nfsd_forget_all_clients(void) {};
>> +static inline void nfsd_forget_all_state_owners(void) {};
>> +static inline void nfsd_count_all_state_owners(void) {};
>> +static inline void nfsd_forget_all_delegations(void) {};
>> +static inline void nfsd_recall_all_delegations(void) {};
>>  #endif
>>  
>>  /*
>> -- 
>> 1.7.5.1
>>

