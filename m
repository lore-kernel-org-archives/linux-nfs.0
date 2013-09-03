Return-Path: linux-nfs-owner@vger.kernel.org
Received: from userp1040.oracle.com ([156.151.31.81]:37981 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753910Ab3ICSTp convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 3 Sep 2013 14:19:45 -0400
Content-Type: text/plain; charset=windows-1252
Mime-Version: 1.0 (Mac OS X Mail 6.5 \(1508\))
Subject: Re: [PATCH v2 07/33] NFS: Enable slot table helpers for NFSv4.0
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <1378227026.6410.11.camel@leira.trondhjem.org>
Date: Tue, 3 Sep 2013 14:19:39 -0400
Cc: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Message-Id: <5E30092F-9FB2-460F-9DF8-9E808E1AD7BA@oracle.com>
References: <20130809161957.5362.90865.stgit@seurat.1015granger.net> <20130809164844.5362.23032.stgit@seurat.1015granger.net> <1378227026.6410.11.camel@leira.trondhjem.org>
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Sep 3, 2013, at 12:50 PM, "Myklebust, Trond" <Trond.Myklebust@netapp.com> wrote:

> On Fri, 2013-08-09 at 12:48 -0400, Chuck Lever wrote:
>> I'd like to re-use NFSv4.1's slot table machinery for NFSv4.0
>> transport blocking.  Re-organize some of nfs4session.c so the slot
>> table code is built even when NFS_V4_1 is disabled.
>> 
>> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
>> ---
>> fs/nfs/Makefile      |    4 ++--
>> fs/nfs/nfs4session.c |   29 +++++++++++++++++++++--------
>> fs/nfs/nfs4session.h |   28 +++++++++++++---------------
>> fs/nfs/nfs4state.c   |    9 ---------
>> 4 files changed, 36 insertions(+), 34 deletions(-)
>> 
>> diff --git a/fs/nfs/Makefile b/fs/nfs/Makefile
>> index e0bb048..2839bfe 100644
>> --- a/fs/nfs/Makefile
>> +++ b/fs/nfs/Makefile
>> @@ -21,10 +21,10 @@ nfsv3-$(CONFIG_NFS_V3_ACL) += nfs3acl.o
>> obj-$(CONFIG_NFS_V4) += nfsv4.o
>> nfsv4-y := nfs4proc.o nfs4xdr.o nfs4state.o nfs4renewd.o nfs4super.o nfs4file.o \
>> 	  delegation.o idmap.o callback.o callback_xdr.o callback_proc.o \
>> -	  nfs4namespace.o nfs4getroot.o nfs4client.o dns_resolve.o
>> +	  nfs4namespace.o nfs4getroot.o nfs4client.o dns_resolve.o nfs4session.o
>> nfsv4-$(CONFIG_NFS_USE_LEGACY_DNS) += cache_lib.o
>> nfsv4-$(CONFIG_SYSCTL)	+= nfs4sysctl.o
>> -nfsv4-$(CONFIG_NFS_V4_1)	+= nfs4session.o pnfs.o pnfs_dev.o
>> +nfsv4-$(CONFIG_NFS_V4_1)	+= pnfs.o pnfs_dev.o
>> 
>> obj-$(CONFIG_PNFS_FILE_LAYOUT) += nfs_layout_nfsv41_files.o
>> nfs_layout_nfsv41_files-y := nfs4filelayout.o nfs4filelayoutdev.o
>> diff --git a/fs/nfs/nfs4session.c b/fs/nfs/nfs4session.c
>> index 0161ad2..746675b 100644
>> --- a/fs/nfs/nfs4session.c
>> +++ b/fs/nfs/nfs4session.c
>> @@ -44,6 +44,17 @@ static void nfs4_shrink_slot_table(struct nfs4_slot_table  *tbl, u32 newsize)
>> 	}
>> }
>> 
>> +/**
>> + * nfs4_slot_tbl_drain_complete - wake waiters when drain is complete
>> + * @tbl - controlling slot table
>> + *
>> + */
>> +void nfs4_slot_tbl_drain_complete(struct nfs4_slot_table *tbl)
>> +{
>> +	if (nfs4_slot_tbl_draining(tbl))
>> +		complete(&tbl->complete);
>> +}
>> +
>> /*
>>  * nfs4_free_slot - free a slot and efficiently update slot table.
>>  *
>> @@ -212,13 +223,6 @@ out:
>> 	return ret;
>> }
>> 
>> -/* Destroy the slot table */
>> -static void nfs4_destroy_slot_tables(struct nfs4_session *session)
>> -{
>> -	nfs4_shrink_slot_table(&session->fc_slot_table, 0);
>> -	nfs4_shrink_slot_table(&session->bc_slot_table, 0);
>> -}
>> -
>> static bool nfs41_assign_slot(struct rpc_task *task, void *pslot)
>> {
>> 	struct nfs4_sequence_args *args = task->tk_msg.rpc_argp;
>> @@ -383,6 +387,15 @@ void nfs41_update_target_slotid(struct nfs4_slot_table *tbl,
>> 	spin_unlock(&tbl->slot_tbl_lock);
>> }
>> 
>> +#if defined(CONFIG_NFS_V4_1)
>> +
>> +/* Destroy the slot table */
>> +static void nfs4_destroy_slot_tables(struct nfs4_session *session)
>> +{
>> +	nfs4_shrink_slot_table(&session->fc_slot_table, 0);
>> +	nfs4_shrink_slot_table(&session->bc_slot_table, 0);
>> +}
>> +
>> /*
>>  * Initialize or reset the forechannel and backchannel tables
>>  */
>> @@ -513,4 +526,4 @@ int nfs4_init_ds_session(struct nfs_client *clp, unsigned long lease_time)
>> }
>> EXPORT_SYMBOL_GPL(nfs4_init_ds_session);
>> 
>> -
>> +#endif	/* defined(CONFIG_NFS_V4_1) */
>> diff --git a/fs/nfs/nfs4session.h b/fs/nfs/nfs4session.h
>> index 3a153d8..23d26b4 100644
>> --- a/fs/nfs/nfs4session.h
>> +++ b/fs/nfs/nfs4session.h
>> @@ -72,15 +72,24 @@ enum nfs4_session_state {
>> 	NFS4_SESSION_INITING,
>> };
>> 
>> -#if defined(CONFIG_NFS_V4_1)
>> extern struct nfs4_slot *nfs4_alloc_slot(struct nfs4_slot_table *tbl);
>> extern void nfs4_free_slot(struct nfs4_slot_table *tbl, struct nfs4_slot *slot);
>> -
>> -extern void nfs41_set_target_slotid(struct nfs4_slot_table *tbl,
>> -		u32 target_highest_slotid);
>> +extern void nfs4_slot_tbl_drain_complete(struct nfs4_slot_table *tbl);
>> extern void nfs41_update_target_slotid(struct nfs4_slot_table *tbl,
>> 		struct nfs4_slot *slot,
>> 		struct nfs4_sequence_res *res);
>> +bool nfs41_wake_and_assign_slot(struct nfs4_slot_table *tbl,
>> +		struct nfs4_slot *slot);
>> +void nfs41_wake_slot_table(struct nfs4_slot_table *tbl);
>> +
>> +static inline bool nfs4_slot_tbl_draining(struct nfs4_slot_table *tbl)
>> +{
>> +	return !!test_bit(NFS4_SLOT_TBL_DRAINING, &tbl->slot_tbl_state);
>> +}
>> +
>> +#if defined(CONFIG_NFS_V4_1)
>> +extern void nfs41_set_target_slotid(struct nfs4_slot_table *tbl,
>> +		u32 target_highest_slotid);
>> 
>> extern int nfs4_setup_session_slot_tables(struct nfs4_session *ses);
>> 
>> @@ -89,17 +98,6 @@ extern void nfs4_destroy_session(struct nfs4_session *session);
>> extern int nfs4_init_session(struct nfs_client *clp);
>> extern int nfs4_init_ds_session(struct nfs_client *, unsigned long);
>> 
>> -extern void nfs4_slot_tbl_drain_complete(struct nfs4_slot_table *tbl);
>> -
>> -static inline bool nfs4_slot_tbl_draining(struct nfs4_slot_table *tbl)
>> -{
>> -	return !!test_bit(NFS4_SLOT_TBL_DRAINING, &tbl->slot_tbl_state);
>> -}
>> -
>> -bool nfs41_wake_and_assign_slot(struct nfs4_slot_table *tbl,
>> -		struct nfs4_slot *slot);
>> -void nfs41_wake_slot_table(struct nfs4_slot_table *tbl);
>> -
>> /*
>>  * Determine if sessions are in use.
>>  */
>> diff --git a/fs/nfs/nfs4state.c b/fs/nfs/nfs4state.c
>> index 6818964..8826df3 100644
>> --- a/fs/nfs/nfs4state.c
>> +++ b/fs/nfs/nfs4state.c
>> @@ -260,15 +260,6 @@ static void nfs4_end_drain_session(struct nfs_client *clp)
>> 	}
>> }
>> 
>> -/*
>> - * Signal state manager thread if session fore channel is drained
>> - */
>> -void nfs4_slot_tbl_drain_complete(struct nfs4_slot_table *tbl)
>> -{
>> -	if (nfs4_slot_tbl_draining(tbl))
>> -		complete(&tbl->complete);
>> -}
>> -
>> static int nfs4_drain_slot_tbl(struct nfs4_slot_table *tbl)
>> {
>> 	set_bit(NFS4_SLOT_TBL_DRAINING, &tbl->slot_tbl_state);
>> 
>> --
>> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
> when compiled without CONFIG_NFS_V4_1, sparse complains:
> 
> [trondmy@leira linux-nfs]$ make O=../object.x86_64 W=1 C=2 fs/nfs/nfs4session.o
> make[2]: Nothing to be done for `all'.
> make[2]: Nothing to be done for `relocs'.
>  Using /home/trondmy/devel/kernel/linux-nfs as source for kernel
>  GEN     /home/trondmy/devel/kernel/object.x86_64/Makefile
>  CHK     include/generated/uapi/linux/version.h
>  CHK     include/generated/utsrelease.h
>  CALL    /home/trondmy/devel/kernel/linux-nfs/scripts/checksyscalls.sh
>  CHECK   /home/trondmy/devel/kernel/linux-nfs/scripts/mod/empty.c
>  CHECK   /home/trondmy/devel/kernel/linux-nfs/fs/nfs/nfs4session.c
> /home/trondmy/devel/kernel/linux-nfs/fs/nfs/nfs4session.c:304:6: warning: symbol 'nfs41_set_target_slotid' was not declared. Should it be static?
> /home/trondmy/devel/kernel/linux-nfs/include/linux/err.h:34:16: warning: dereference of noderef expression
> /home/trondmy/devel/kernel/linux-nfs/include/linux/err.h:34:16: warning: dereference of noderef expression
> /home/trondmy/devel/kernel/linux-nfs/include/linux/err.h:34:16: warning: dereference of noderef expression
> /home/trondmy/devel/kernel/linux-nfs/include/linux/err.h:34:16: warning: dereference of noderef expression
>  CC [M]  fs/nfs/nfs4session.o
> /home/trondmy/devel/kernel/linux-nfs/fs/nfs/nfs4session.c:304:6: warning: no previous prototype for ‘nfs41_set_target_slotid’ [-Wmissing-prototypes]
> void nfs41_set_target_slotid(struct nfs4_slot_table *tbl,
>      ^
> /home/trondmy/devel/kernel/linux-nfs/fs/nfs/nfs4session.c:200:12: warning: ‘nfs4_realloc_slot_table’ defined but not used [-Wunused-function]
> static int nfs4_realloc_slot_table(struct nfs4_slot_table *tbl,

There is a trivial fix in fs/nfs/nfs4session.h.  I'm testing to see if that will cause merge conflicts with subsequent patches... or I can send a fix that applies on top of the series.  Up to you.

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com




