Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet10.oracle.com ([148.87.113.121]:39443 "EHLO
	rcsinet10.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756240Ab1ELPhk convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 12 May 2011 11:37:40 -0400
Subject: Re: [PATCH 16/16] NFS: Implement support for NFS4ERR_LEASE_MOVED
Content-Type: text/plain; charset=us-ascii
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <4DC9D636.3050307@excfb.com>
Date: Thu, 12 May 2011 11:37:29 -0400
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-Id: <B1649987-7ED1-4505-8256-A4346E8A35A1@oracle.com>
References: <20110509192522.16568.59082.stgit@matisse.1015granger.net> <20110509193853.16568.93770.stgit@matisse.1015granger.net> <A5DC12D9-0FAB-43B4-9FA7-822A6152C73A@oracle.com> <4DC9D636.3050307@excfb.com>
To: Trond Myklebust <trond.myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0


On May 10, 2011, at 8:20 PM, Tom Haynes wrote:

> On 5/9/11 5:48 PM, Chuck Lever wrote:
>> On May 9, 2011, at 3:38 PM, Chuck Lever wrote:
>> 
>>> To recover from NFS4ERR_LEASE_MOVED, walk the cl_superblocks list and
>>> invoke nfs4_try_migration() on each server's root file handle.
>>> nfs4_try_migration() should automatically determine whether that file
>>> system has migrated, and then perform recovery for it.
>>> 
>>> The per-filesystem migration probe also informs minor version zero
>>> servers that this client should no longer receive NFS4ERR_LEASE_MOVED.
>> I see one thing that may be missing here.
>> 
>> RFC 3530, section 8.14.3, lists OPEN, CLOSE, READ, WRITE, RENEW, LOCK, LOCKU, and LOCKT as the only procedures that return NFS4ERR_LEASE_MOVED.  A code audit suggests that handling NFS4ERR_LEASE_MOVED in the two generic error handlers in nfs4proc.c is sufficient for all of these but RENEW and OPEN.
> 
> 3503bis, section 13.4:
> 
>   | NFS4ERR_LEASE_MOVED      | CLOSE, DELEGPURGE, DELEGRETURN, LOCK,  |
>   |                          | LOCKT, LOCKU, OPEN_CONFIRM,            |
>   |                          | OPEN_DOWNGRADE, READ,                  |
>   |                          | RELEASE_LOCKOWNER, RENEW, SETATTR,     |
>   |                          | WRITE                                  |
> 
> And the equivalent text as to what is in 3530 is section 9.14.3:
> 
>   To accomplish this, all
>   operations which implicitly renew leases for a client (such as OPEN,
>   CLOSE, READ, WRITE, RENEW, LOCK, and others), will return the error
>   NFS4ERR_LEASE_MOVED if responsibility for any of the leases to be
>   renewed has been transferred to a new server.


DELEGPURGE doesn't appear to be implemented.

DELEGRETURN uses nfs4_handle_exception(), so it's covered.

OPEN_CONFIRM is in the same boat as OPEN.  Error handling is ad hoc, both MOVED and LEASE_MOVED are ignored.

OPEN_DOWNGRADE is done only during close processing, and the returned status code is ignored.

RELEASE_LOCKOWNER ignores the returned status code.  It's entirely asynchronous.  This is probably OK to leave alone.

SETATTR uses nfs4_handle_exception(), so it's covered.


So we have OPEN, OPEN_CONFIRM, and OPEN_DOWNGRADE to consider.


>> RENEW is part of the lease_moved recovery logic, so I've left NFS4ERR_LEASE_MOVED handling there pretty sparse.  The caller wants to deal with it.
>> 
>> OPEN, as far as I can tell, won't deal with it at all, at least not directly.  Should we look for it in nfs4_open_done() and invoke nfs4_schedule_lease_moved_recovery()?
>> 
>>> Signed-off-by: Chuck Lever<chuck.lever@oracle.com>
>>> ---
>>> 
>>> fs/nfs/client.c           |    1 +
>>> fs/nfs/nfs4_fs.h          |    2 +
>>> fs/nfs/nfs4proc.c         |   11 ++++++++
>>> fs/nfs/nfs4state.c        |   63 ++++++++++++++++++++++++++++++++++++++++++++-
>>> include/linux/nfs_fs_sb.h |    2 +
>>> 5 files changed, 77 insertions(+), 2 deletions(-)
>>> 
>>> diff --git a/fs/nfs/client.c b/fs/nfs/client.c
>>> index 2f5e29f..b89af4d 100644
>>> --- a/fs/nfs/client.c
>>> +++ b/fs/nfs/client.c
>>> @@ -188,6 +188,7 @@ static struct nfs_client *nfs_alloc_client(const struct nfs_client_initdata *cl_
>>> 	if (cl_init->long_clientid != NULL)
>>> 		clp->cl_cached_clientid = kstrdup(cl_init->long_clientid,
>>> 							GFP_KERNEL);
>>> +	clp->cl_mig_counter = 1;
>>> #endif
>>> 	cred = rpc_lookup_machine_cred();
>>> 	if (!IS_ERR(cred))
>>> diff --git a/fs/nfs/nfs4_fs.h b/fs/nfs/nfs4_fs.h
>>> index c3e8641..2ad6c9b 100644
>>> --- a/fs/nfs/nfs4_fs.h
>>> +++ b/fs/nfs/nfs4_fs.h
>>> @@ -51,6 +51,7 @@ enum nfs4_client_state {
>>> 	NFS4CLNT_UPDATE_CALLBACK,
>>> 	NFS4CLNT_CLONED_CLIENT,
>>> 	NFS4CLNT_MOVED,
>>> +	NFS4CLNT_LEASE_MOVED,
>>> };
>>> 
>>> enum nfs4_session_state {
>>> @@ -351,6 +352,7 @@ extern void nfs4_close_sync(struct path *, struct nfs4_state *, fmode_t);
>>> extern void nfs4_state_set_mode_locked(struct nfs4_state *, fmode_t);
>>> extern void nfs4_schedule_lease_recovery(struct nfs_client *);
>>> extern void nfs4_schedule_migration_recovery(struct nfs_server *);
>>> +extern void nfs4_schedule_lease_moved_recovery(struct nfs_client *);
>>> extern void nfs4_schedule_state_manager(struct nfs_client *);
>>> extern void nfs4_schedule_stateid_recovery(const struct nfs_server *, struct nfs4_state *);
>>> extern void nfs41_handle_sequence_flag_errors(struct nfs_client *clp, u32 flags);
>>> diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
>>> index a545d46..f4e07ba 100644
>>> --- a/fs/nfs/nfs4proc.c
>>> +++ b/fs/nfs/nfs4proc.c
>>> @@ -297,6 +297,9 @@ static int nfs4_handle_exception(struct nfs_server *server, int errorcode,
>>> 		case -NFS4ERR_MOVED:
>>> 			nfs4_schedule_migration_recovery(server);
>>> 			goto wait_on_recovery;
>>> +		case -NFS4ERR_LEASE_MOVED:
>>> +			nfs4_schedule_lease_moved_recovery(clp);
>>> +			goto wait_on_recovery;
>>> 		case -NFS4ERR_FILE_OPEN:
>>> 			if (exception->timeout>  HZ) {
>>> 				/* We have retried a decent amount, time to
>>> @@ -3721,6 +3724,14 @@ static int nfs4_async_handle_error(struct rpc_task *task,
>>> 				rpc_wake_up_queued_task(&clp->cl_rpcwaitq,
>>> 									task);
>>> 			goto restart_call;
>>> +		case -NFS4ERR_LEASE_MOVED:
>>> +			rpc_sleep_on(&clp->cl_rpcwaitq, task, NULL);
>>> +			nfs4_schedule_lease_moved_recovery(clp);
>>> +			if (test_bit(NFS4CLNT_MANAGER_RUNNING,
>>> +							&clp->cl_state) == 0)
>>> +				rpc_wake_up_queued_task(&clp->cl_rpcwaitq,
>>> +									task);
>>> +			goto restart_call;
>>> 		case -NFS4ERR_DELAY:
>>> 			nfs_inc_server_stats(server, NFSIOS_DELAY);
>>> 		case -NFS4ERR_GRACE:
>>> diff --git a/fs/nfs/nfs4state.c b/fs/nfs/nfs4state.c
>>> index c7b414a..8bef9d8 100644
>>> --- a/fs/nfs/nfs4state.c
>>> +++ b/fs/nfs/nfs4state.c
>>> @@ -1071,7 +1071,32 @@ void nfs4_schedule_migration_recovery(struct nfs_server *server)
>>> 	dprintk("<-- %s\n", __func__);
>>> }
>>> 
>>> -static int nfs4_state_mark_reclaim_reboot(struct nfs_client *clp, struct nfs4_state *state)
>>> +/**
>>> + * nfs4_schedule_lease_moved_recovery - start lease moved recovery
>>> + *
>>> + * @clp: nfs_client of server that may have migrated file systems
>>> + *
>>> + */
>>> +void nfs4_schedule_lease_moved_recovery(struct nfs_client *clp)
>>> +{
>>> +	dprintk("-->  %s: \"%s\" (client ID %llx)\n",
>>> +		__func__, clp->cl_hostname, clp->cl_clientid);
>>> +
>>> +	if (test_and_set_bit(NFS4CLNT_LEASE_MOVED,&clp->cl_state) == 0)
>>> +		nfs4_schedule_state_manager(clp);
>>> +
>>> +	dprintk("<-- %s\n", __func__);
>>> +}
>>> +
>>> +/**
>>> + * nfs4_state_mark_reclaim_reboot - Mark nfs_client for reboot recovery
>>> + * @clp: nfs_client of server that may have rebooted
>>> + * @state: state flags to test
>>> + *
>>> + * Returns 1 if reboot recovery is needed.
>>> + */
>>> +int nfs4_state_mark_reclaim_reboot(struct nfs_client *clp,
>>> +				   struct nfs4_state *state)
>>> {
>>> 
>>> 	set_bit(NFS_STATE_RECLAIM_REBOOT,&state->flags);
>>> @@ -1384,7 +1409,6 @@ static int nfs4_recovery_handle_error(struct nfs_client *clp, int error)
>>> 			nfs4_state_end_reclaim_reboot(clp);
>>> 			return 0;
>>> 		case -NFS4ERR_STALE_CLIENTID:
>>> -		case -NFS4ERR_LEASE_MOVED:
>>> 			set_bit(NFS4CLNT_LEASE_EXPIRED,&clp->cl_state);
>>> 			nfs4_state_clear_reclaim_reboot(clp);
>>> 			nfs4_state_start_reclaim_reboot(clp);
>>> @@ -1597,6 +1621,37 @@ out_err:
>>> 	kfree(locations);
>>> }
>>> 
>>> +static void nfs4_handle_lease_moved(struct nfs_client *clp)
>>> +{
>>> +	struct nfs_server *server;
>>> +
>>> +	dprintk("-->  %s: \"%s\" (client ID %llx)\n",
>>> +		__func__, clp->cl_hostname, clp->cl_clientid);
>>> +
>>> +	/*
>>> +	 * rcu_read_lock() must be dropped before trying each individual
>>> +	 * migration.  cl_mig_counter is used to skip servers that have
>>> +	 * already been visited for this lease_moved event when the list
>>> +	 * walk is restarted.
>>> +	 */
>>> +	clp->cl_mig_counter++;
>>> +
>>> +restart:
>>> +	rcu_read_lock();
>>> +	list_for_each_entry_rcu(server,&clp->cl_superblocks, client_link)
>>> +		if (server->mig_counter != clp->cl_mig_counter) {
>>> +			server->mig_counter = clp->cl_mig_counter;
>>> +			rcu_read_unlock();
>>> +			nfs4_try_migration(server);
>>> +			/* Ask the server if there's more work to do */
>>> +			if (nfs4_check_lease(clp) == NFS4ERR_LEASE_MOVED)
>>> +				goto restart;
>>> +			break;
>>> +		}
>>> +	rcu_read_unlock();
>>> +	dprintk("<-- %s\n", __func__);
>>> +}
>>> +
>>> #ifdef CONFIG_NFS_V4_1
>>> void nfs4_schedule_session_recovery(struct nfs4_session *session)
>>> {
>>> @@ -1814,6 +1869,10 @@ static void nfs4_state_manager(struct nfs_client *clp)
>>> 			nfs4_try_migration(clp->cl_moved_server);
>>> 			continue;
>>> 		}
>>> +		if (test_and_clear_bit(NFS4CLNT_LEASE_MOVED,&clp->cl_state)) {
>>> +			nfs4_handle_lease_moved(clp);
>>> +			continue;
>>> +		}
>>> 
>>> 		/* First recover reboot state... */
>>> 		if (test_bit(NFS4CLNT_RECLAIM_REBOOT,&clp->cl_state)) {
>>> diff --git a/include/linux/nfs_fs_sb.h b/include/linux/nfs_fs_sb.h
>>> index 091abf0..58050db 100644
>>> --- a/include/linux/nfs_fs_sb.h
>>> +++ b/include/linux/nfs_fs_sb.h
>>> @@ -60,6 +60,7 @@ struct nfs_client {
>>> 
>>> 	/* accessed only when NFS4CLNT_MOVED bit is set */
>>> 	struct nfs_server *	cl_moved_server;
>>> +	unsigned long		cl_mig_counter;
>>> 
>>> 	/* used for the setclientid verifier */
>>> 	struct timespec		cl_boot_time;
>>> @@ -156,6 +157,7 @@ struct nfs_server {
>>> 	struct list_head	delegations;
>>> 	void (*destroy)(struct nfs_server *);
>>> 	struct nfs_fh		*rootfh;
>>> +	unsigned long		mig_counter;
>>> 
>>> 	atomic_t active; /* Keep trace of any activity to this server */
>>> 
>>> 
>>> --
>>> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
>>> the body of a message to majordomo@vger.kernel.org
>>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com




