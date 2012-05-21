Return-Path: linux-nfs-owner@vger.kernel.org
Received: from rcsinet15.oracle.com ([148.87.113.117]:49742 "EHLO
	rcsinet15.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754862Ab2EUQL7 convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 21 May 2012 12:11:59 -0400
Subject: Re: [PATCH 09/14] NFS: Force server to drop NFSv4 state
Mime-Version: 1.0 (Apple Message framework v1278)
Content-Type: text/plain; charset=us-ascii
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <20120521160844.GH24299@fieldses.org>
Date: Mon, 21 May 2012 12:11:48 -0400
Cc: trond.myklebust@netapp.com, linux-nfs@vger.kernel.org
Message-Id: <F7B056E4-D6FC-450B-98E2-129C051CFAE7@oracle.com>
References: <20120518220145.774.53741.stgit@degas.1015granger.net> <20120518220632.774.79191.stgit@degas.1015granger.net> <20120521160844.GH24299@fieldses.org>
To: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On May 21, 2012, at 12:08 PM, J. Bruce Fields wrote:

> On Fri, May 18, 2012 at 06:06:33PM -0400, Chuck Lever wrote:
>> A SETCLIENTID boot verifier is nothing more than the client's boot
>> timestamp.  An NFSv4 server is obligated to wipe all NFSv4 state for
>> an NFS client when the client presents an updated SETCLIENTID boot
>> verifier.  This is how servers detect client reboots.
>> 
>> nfs4_reset_all_state() refreshes our client's boot verifier to trigger
>> a server to wipe this client's state.  This function is invoked when
>> an NFSv4.1 server reports that it has revoked some or all of a
>> client's NFSv4 state.
>> 
>> Soon we want to get rid of the per-nfs_client cl_boot_time field,
> 
> OK, I guess you don't need it if you never intend to send a callback
> update or anything?

"Get rid of" is perhaps too strong.  I'm moving it to nfs_net.

>> however.  Without cl_boot_time, our NFS client will need to find a
>> different way to force the server to purge the client's NFSv4 state.
>> 
>> Because these verifiers are opaque (ie, the server doesn't know or
>> care that they happen to be timestamps), we can do force the server
>> to wipe NFSv4 state by using the same trick we use now, but then
>> immediately afterwards establish a fresh client ID using the old boot
>> verifier again.
>> 
>> Hopefully there are no extra paranoid server implementations that keep
>> track of the client's boot verifiers and prevent clients from reusing
>> a previous one.
>> 
>> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
>> ---
>> 
>> fs/nfs/nfs4_fs.h   |    1 +
>> fs/nfs/nfs4proc.c  |    9 +++++++--
>> fs/nfs/nfs4state.c |   13 +++++++++++--
>> 3 files changed, 19 insertions(+), 4 deletions(-)
>> 
>> diff --git a/fs/nfs/nfs4_fs.h b/fs/nfs/nfs4_fs.h
>> index 03d3ff0..f164c73 100644
>> --- a/fs/nfs/nfs4_fs.h
>> +++ b/fs/nfs/nfs4_fs.h
>> @@ -24,6 +24,7 @@ enum nfs4_client_state {
>> 	NFS4CLNT_RECALL_SLOT,
>> 	NFS4CLNT_LEASE_CONFIRM,
>> 	NFS4CLNT_SERVER_SCOPE_MISMATCH,
>> +	NFS4CLNT_PURGE_STATE,
>> };
>> 
>> enum nfs4_session_state {
>> diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
>> index 73cfd9e..c56d547 100644
>> --- a/fs/nfs/nfs4proc.c
>> +++ b/fs/nfs/nfs4proc.c
>> @@ -3937,8 +3937,13 @@ static void nfs4_construct_boot_verifier(struct nfs_client *clp,
>> {
>> 	__be32 verf[2];
>> 
>> -	verf[0] = (__be32)clp->cl_boot_time.tv_sec;
>> -	verf[1] = (__be32)clp->cl_boot_time.tv_nsec;
>> +	if (test_bit(NFS4CLNT_PURGE_STATE, &clp->cl_state)) {
>> +		verf[0] = (__be32)CURRENT_TIME.tv_sec;
>> +		verf[1] = (__be32)CURRENT_TIME.tv_nsec;
> 
> I suppose it's pretty unlikely this could happen within a jiffy of
> setting cl_boot_time?

Boot time has nanosecond resolution.  I'm pretty sure we are safe here.

> Would it be simpler to use some special value (all-zeros?) instead?

We'd have to pick a value that was guaranteed never to be a valid time stamp.

> 
> --b.
> 
>> +	} else {
>> +		verf[0] = (__be32)clp->cl_boot_time.tv_sec;
>> +		verf[1] = (__be32)clp->cl_boot_time.tv_nsec;
>> +	}
>> 	memcpy(bootverf->data, verf, sizeof(bootverf->data));
>> }
>> 
>> diff --git a/fs/nfs/nfs4state.c b/fs/nfs/nfs4state.c
>> index f8c06de..32cce4a 100644
>> --- a/fs/nfs/nfs4state.c
>> +++ b/fs/nfs/nfs4state.c
>> @@ -1615,7 +1615,7 @@ void nfs41_handle_recall_slot(struct nfs_client *clp)
>> static void nfs4_reset_all_state(struct nfs_client *clp)
>> {
>> 	if (test_and_set_bit(NFS4CLNT_LEASE_EXPIRED, &clp->cl_state) == 0) {
>> -		clp->cl_boot_time = CURRENT_TIME;
>> +		set_bit(NFS4CLNT_PURGE_STATE, &clp->cl_state);
>> 		nfs4_state_start_reclaim_nograce(clp);
>> 		nfs4_schedule_state_manager(clp);
>> 	}
>> @@ -1631,7 +1631,6 @@ static void nfs41_handle_server_reboot(struct nfs_client *clp)
>> 
>> static void nfs41_handle_state_revoked(struct nfs_client *clp)
>> {
>> -	/* Temporary */
>> 	nfs4_reset_all_state(clp);
>> }
>> 
>> @@ -1652,6 +1651,10 @@ void nfs41_handle_sequence_flag_errors(struct nfs_client *clp, u32 flags)
>> {
>> 	if (!flags)
>> 		return;
>> +
>> +	dprintk("%s: \"%s\" (client ID %llx) flags=0x%08x\n",
>> +		__func__, clp->cl_hostname, clp->cl_clientid, flags);
>> +
>> 	if (flags & SEQ4_STATUS_RESTART_RECLAIM_NEEDED)
>> 		nfs41_handle_server_reboot(clp);
>> 	if (flags & (SEQ4_STATUS_EXPIRED_ALL_STATE_REVOKED |
>> @@ -1762,6 +1765,12 @@ static void nfs4_state_manager(struct nfs_client *clp)
>> 
>> 	/* Ensure exclusive access to NFSv4 state */
>> 	do {
>> +		if (test_bit(NFS4CLNT_PURGE_STATE, &clp->cl_state)) {
>> +			nfs4_reclaim_lease(clp);
>> +			clear_bit(NFS4CLNT_PURGE_STATE, &clp->cl_state);
>> +			set_bit(NFS4CLNT_LEASE_EXPIRED, &clp->cl_state);
>> +		}
>> +
>> 		if (test_and_clear_bit(NFS4CLNT_LEASE_EXPIRED, &clp->cl_state)) {
>> 			/* We're going to have to re-establish a clientid */
>> 			status = nfs4_reclaim_lease(clp);
>> 
>> --
>> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com




