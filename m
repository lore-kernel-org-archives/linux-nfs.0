Return-Path: linux-nfs-owner@vger.kernel.org
Received: from acsinet15.oracle.com ([141.146.126.227]:38257 "EHLO
	acsinet15.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752460Ab2GITrP convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 9 Jul 2012 15:47:15 -0400
Subject: Re: [PATCH 02/14] NFS: Properly sort TEST_STATEID results
Mime-Version: 1.0 (Apple Message framework v1278)
Content-Type: text/plain; charset=us-ascii
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <1341862469.15267.1.camel@lade.trondhjem.org>
Date: Mon, 9 Jul 2012 15:47:10 -0400
Cc: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Message-Id: <B803FBBF-8ACA-4C7A-9563-2083A7DE64C2@oracle.com>
References: <20120709153355.1604.14102.stgit@degas.1015granger.net> <20120709154400.1604.10590.stgit@degas.1015granger.net> <1341862469.15267.1.camel@lade.trondhjem.org>
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Jul 9, 2012, at 3:34 PM, Myklebust, Trond wrote:

> On Mon, 2012-07-09 at 11:44 -0400, Chuck Lever wrote:
>> The result of a TEST_STATEID operation can indicate a few different
>> things:
>> 
>>  o If NFS_OK is returned, then the client can continue using the
>>    state ID under test, and skip recovery.
>> 
>>  o RFC 5661 says that if and only if the state ID was revoked, then
>>    the client must perform an explicit FREE_STATEID before trying to
>>    re-open.
>> 
>>  o If the server doesn't recognize the state ID at all, then no
>>    FREE_STATEID is needed, and the client can immediately continue
>>    with open recovery.
>> 
>> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
>> ---
>> 
>> fs/nfs/nfs4proc.c |   36 ++++++++++++++++++++++++++++++++++--
>> 1 files changed, 34 insertions(+), 2 deletions(-)
>> 
>> diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
>> index 971ec8c..60a320c 100644
>> --- a/fs/nfs/nfs4proc.c
>> +++ b/fs/nfs/nfs4proc.c
>> @@ -1756,6 +1756,14 @@ static int nfs4_open_expired(struct nfs4_state_owner *sp, struct nfs4_state *sta
>> }
>> 
>> #if defined(CONFIG_NFS_V4_1)
>> +/**
>> + * nfs41_check_expired_stateid - does a state ID need recovery?
>> + *
>> + * @state: NFSv4 open state for an inode
>> + *
>> + * Returns NFS_OK if recovery for this state ID is now finished.
>> + * Otherwise a negative NFS4ERR value is returned.
>> + */
>> static int nfs41_check_expired_stateid(struct nfs4_state *state, nfs4_stateid *stateid, unsigned int flags)
>> {
>> 	int status = NFS_OK;
>> @@ -1763,8 +1771,16 @@ static int nfs41_check_expired_stateid(struct nfs4_state *state, nfs4_stateid *s
>> 
>> 	if (state->flags & flags) {
>> 		status = nfs41_test_stateid(server, stateid);
>> -		if (status != NFS_OK) {
>> +		switch (status) {
>> +		case NFS_OK:
>> +			/* server recognizes this one, don't recover */
>> +			break;
>> +		case -NFS4ERR_ADMIN_REVOKED:
>> +		case -NFS4ERR_DELEG_REVOKED:
> 
> What about -NFS4ERR_BAD_STATEID and/or -NFS4ERR_EXPIRED?

My impression from RFC 5661 was that no FREE_STATEID was needed in those cases.  Those errors would be handled by the default arm.

I don't pretend to be an expert on this, though.  What is your thought?

> 
>> +			/* state was revoked, free then re-open */
>> 			nfs41_free_stateid(server, stateid);
>> +		default:
>> +			/* anything else: just re-open it */
>> 			state->flags &= ~flags;
>> 		}
>> 	}
>> @@ -4698,6 +4714,14 @@ out:
>> }
>> 
>> #if defined(CONFIG_NFS_V4_1)
>> +/**
>> + * nfs41_check_expired_locks - clear lock state IDs
>> + *
>> + * @state: NFSv4 open state for a file
>> + *
>> + * Returns NFS_OK if recovery for this state ID is now finished.
>> + * Otherwise a negative NFS4ERR value is returned.
>> + */
>> static int nfs41_check_expired_locks(struct nfs4_state *state)
>> {
>> 	int status, ret = NFS_OK;
>> @@ -4707,8 +4731,16 @@ static int nfs41_check_expired_locks(struct nfs4_state *state)
>> 	list_for_each_entry(lsp, &state->lock_states, ls_locks) {
>> 		if (lsp->ls_flags & NFS_LOCK_INITIALIZED) {
>> 			status = nfs41_test_stateid(server, &lsp->ls_stateid);
>> -			if (status != NFS_OK) {
>> +			switch (status) {
>> +			case NFS_OK:
>> +				/* server recognizes this one, don't re-lock */
>> +				break;
>> +			case -NFS4ERR_ADMIN_REVOKED:
>> +			case -NFS4ERR_DELEG_REVOKED:
> 
> Ditto
> 
>> +				/* lock was revoked, free then re-lock */
>> 				nfs41_free_stateid(server, &lsp->ls_stateid);
>> +			default:
>> +				/* anything else: just re-lock it */
>> 				lsp->ls_flags &= ~NFS_LOCK_INITIALIZED;
>> 				ret = status;
>> 			}
>> 
> 
> -- 
> Trond Myklebust
> Linux NFS client maintainer
> 
> NetApp
> Trond.Myklebust@netapp.com
> www.netapp.com
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com




