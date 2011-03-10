Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet10.oracle.com ([148.87.113.121]:41849 "EHLO
	rcsinet10.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752707Ab1CJUlm convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 10 Mar 2011 15:41:42 -0500
Subject: Re: [PATCH 5/8] NFS: Add basic migration support to state manager thread
Content-Type: text/plain; charset=us-ascii
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <1299789301.3075.40.camel@heimdal.trondhjem.org>
Date: Thu, 10 Mar 2011 15:40:01 -0500
Cc: linux-nfs@vger.kernel.org
Message-Id: <EE42594F-A914-4007-8CA2-4C07632DC602@oracle.com>
References: <20110310171345.8878.25548.stgit@matisse.1015granger.net> <20110310173018.8878.71092.stgit@matisse.1015granger.net> <1299789301.3075.40.camel@heimdal.trondhjem.org>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0


On Mar 10, 2011, at 3:35 PM, Trond Myklebust wrote:

> On Thu, 2011-03-10 at 12:30 -0500, Chuck Lever wrote:
> 
>> diff --git a/fs/nfs/nfs4state.c b/fs/nfs/nfs4state.c
>> index e6742b5..a788ec9 100644
>> --- a/fs/nfs/nfs4state.c
>> +++ b/fs/nfs/nfs4state.c
>> @@ -56,6 +56,8 @@
>> #include "internal.h"
>> #include "pnfs.h"
>> 
>> +#define NFSDBG_FACILITY		NFSDBG_CLIENT
>> +
>> #define OPENOWNER_POOL_SIZE	8
>> 
>> const nfs4_stateid zero_stateid;
>> @@ -1013,9 +1015,33 @@ void nfs4_schedule_state_recovery(struct nfs_client *clp)
>> {
>> 	if (!clp)
>> 		return;
>> +	dprintk("--> %s: \"%s\" (client ID %llx)\n",
>> +		__func__, clp->cl_hostname, clp->cl_clientid);
>> 	if (!test_bit(NFS4CLNT_LEASE_EXPIRED, &clp->cl_state))
>> 		set_bit(NFS4CLNT_CHECK_LEASE, &clp->cl_state);
>> 	nfs4_schedule_state_manager(clp);
>> +	dprintk("<-- %s\n", __func__);
>> +}
>> +
>> +/**
>> + * nfs4_schedule_migration_recovery - start background migration recovery
>> + *
>> + * @server: nfs_server representing remote file system that is migrating
>> + *
>> + */
>> +void nfs4_schedule_migration_recovery(struct nfs_server *server)
>> +{
>> +	struct nfs_client *clp = server->nfs_client;
>> +
>> +	dprintk("--> %s(%llx:%llx)\n", __func__,
>> +			(unsigned long long)server->fsid.major,
>> +			(unsigned long long)server->fsid.minor);
>> +	if (test_and_set_bit(NFS4CLNT_MOVED, &clp->cl_state) == 0) {
>> +		set_bit(NFS4CLNT_SESSION_RESET, &clp->cl_state);
> 
> Hmm... Why do we need to reset the NFSv4.1 session here?

That's an assumption on my part.  It's not really clear yet what kind of changes will be needed for minor version 1.  I can pull this out for now.

>> +		clp->cl_moved_server = server;
>> +		nfs4_schedule_state_manager(clp);
>> +	}
>> +	dprintk("<-- %s\n", __func__);
>> }
>> 
>> int nfs4_state_mark_reclaim_reboot(struct nfs_client *clp, struct nfs4_state *state)
>> @@ -1435,6 +1461,64 @@ static int nfs4_reclaim_lease(struct nfs_client *clp)
>> 	return status;
>> }
>> 
>> +/*
>> + * Try remote migration of one FSID from a source server to a
>> + * destination server.  The source server provides a list of
>> + * potential destinations.
>> + */
>> +static void nfs4_try_migration(struct nfs_server *server)
>> +{
>> +	struct nfs_client *clp = server->nfs_client;
>> +	struct nfs4_fs_locations *locations = NULL;
>> +	struct page *page;
>> +	int status;
>> +
>> +	dprintk("--> %s: FSID %llx:%llx on \"%s\"\n", __func__,
>> +			(unsigned long long)server->fsid.major,
>> +			(unsigned long long)server->fsid.minor,
>> +			clp->cl_hostname);
>> +
>> +	status = -ENOMEM;
>> +	page = alloc_page(GFP_KERNEL);
>> +	locations = kmalloc(sizeof(struct nfs4_fs_locations), GFP_KERNEL);
>> +	if (page == NULL || locations == NULL) {
>> +		dprintk("<-- %s: no memory\n", __func__);
>> +		goto out;
>> +	}
>> +
>> +	status = nfs4_proc_get_mig_status(server, locations, page);
>> +	if (status != 0) {
>> +		dprintk("<-- %s: get migration status: %d\n",
>> +			__func__, status);
>> +		goto out;
>> +	}
>> +	if (!(locations->fattr.valid & NFS_ATTR_FATTR_V4_LOCATIONS)) {
>> +		dprintk("<-- %s: No fs_locations data available, "
>> +			"migration skipped\n", __func__);
>> +		goto out;
>> +	}
>> +
>> +	status = nfs4_replace_transport(server, locations);
>> +	if (status != 0) {
>> +		dprintk("<-- %s: failed to replace transport: %d\n",
>> +			__func__, status);
>> +		goto out;
>> +	}
>> +
>> +	/* Force an update of our callback info on the destination server */
>> +	set_bit(NFS4CLNT_LEASE_EXPIRED, &clp->cl_state);
> 
> I wonder if this should be made into a separate flag. That would enable
> us to reuse it for the NFS4ERR_CB_PATH_DOWN handling...

Instead, I think we will need a function call here to perform a fresh SETCLIENTID, rather than looping through the state manager's FSM again.  For one thing, we need to construct a new long-form client ID for this nfs_server: the callback endpoint information will have changed.

I just wonder, though, if that is enough.  Where will nfs4_init_clientid() send the SETCLIENTID request?  To the source server or the destination server?

</speculation>

> 
>> +
>> +	/* XXX: would like to update /proc/mounts, but that's entirely
>> +	 *      optional. */
>> +
>> +	dprintk("<-- %s: migration succeeded\n", __func__);
>> +
>> +out:
>> +	if (page != NULL)
>> +		__free_page(page);
>> +	kfree(locations);
>> +}
>> +
>> #ifdef CONFIG_NFS_V4_1
>> void nfs41_handle_recall_slot(struct nfs_client *clp)
>> {
>> @@ -1664,6 +1748,10 @@ static void nfs4_state_manager(struct nfs_client *clp)
> 
> -- 
> Trond Myklebust
> Linux NFS client maintainer
> 
> NetApp
> Trond.Myklebust@netapp.com
> www.netapp.com
> 

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com




