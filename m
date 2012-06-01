Return-Path: linux-nfs-owner@vger.kernel.org
Received: from rcsinet15.oracle.com ([148.87.113.117]:36312 "EHLO
	rcsinet15.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S964937Ab2FAPwa convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 1 Jun 2012 11:52:30 -0400
Received: from acsinet22.oracle.com (acsinet22.oracle.com [141.146.126.238])
	by rcsinet15.oracle.com (Sentrion-MTA-4.2.2/Sentrion-MTA-4.2.2) with ESMTP id q51FqSv6006071
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <linux-nfs@vger.kernel.org>; Fri, 1 Jun 2012 15:52:29 GMT
Received: from acsmt358.oracle.com (acsmt358.oracle.com [141.146.40.158])
	by acsinet22.oracle.com (8.14.4+Sun/8.14.4) with ESMTP id q51FqSPa016044
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <linux-nfs@vger.kernel.org>; Fri, 1 Jun 2012 15:52:28 GMT
Received: from abhmt119.oracle.com (abhmt119.oracle.com [141.146.116.71])
	by acsmt358.oracle.com (8.12.11.20060308/8.12.11) with ESMTP id q51FqSHc019821
	for <linux-nfs@vger.kernel.org>; Fri, 1 Jun 2012 10:52:28 -0500
Content-Type: text/plain; charset=us-ascii
Mime-Version: 1.0 (Apple Message framework v1278)
Subject: Re: [PATCH 2/4] NFS: Properly sort TEST_STATEID results
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <20120601153814.5626.16055.stgit@degas.1015granger.net>
Date: Fri, 1 Jun 2012 11:52:26 -0400
Message-Id: <FB17D5BF-1E45-4EBD-B920-0BCD04368B6B@oracle.com>
References: <20120601153231.5626.89559.stgit@degas.1015granger.net> <20120601153814.5626.16055.stgit@degas.1015granger.net>
To: linux-nfs@vger.kernel.org
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Jun 1, 2012, at 11:38 AM, Chuck Lever wrote:

> The result of a TEST_STATEID operation can indicate a few different
> things.  If NFS_OK is returned, then the client can continue using the
> state ID under test, and skip recovery.  RFC 5661 says that if and
> only if the state ID was revoked, then the client must perform an
> explicit FREE_STATEID before trying to re-open.
> 
> However, if the server doesn't recognize the state ID at all, then the
> client should immediately continue with open recovery.
> 
> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
> ---
> 
> fs/nfs/nfs4proc.c |   38 ++++++++++++++++++++++++++++++++++++--
> 1 files changed, 36 insertions(+), 2 deletions(-)
> 
> diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
> index 4f1e824..39d641a 100644
> --- a/fs/nfs/nfs4proc.c
> +++ b/fs/nfs/nfs4proc.c
> @@ -1733,6 +1733,14 @@ static int nfs4_open_expired(struct nfs4_state_owner *sp, struct nfs4_state *sta
> }
> 
> #if defined(CONFIG_NFS_V4_1)
> +/**
> + * nfs41_check_expired_stateid - does a state ID need recovery?
> + *
> + * @state: NFSv4 open state for a file
> + *
> + * Returns NFS_OK if recovery for this state ID is now finished.
> + * Otherwise a negative NFS4ERR value is returned.
> + */
> static int nfs41_check_expired_stateid(struct nfs4_state *state, nfs4_stateid *stateid, unsigned int flags)
> {
> 	int status = NFS_OK;
> @@ -1740,9 +1748,19 @@ static int nfs41_check_expired_stateid(struct nfs4_state *state, nfs4_stateid *s
> 
> 	if (state->flags & flags) {
> 		status = nfs41_test_stateid(server, stateid);
> -		if (status != NFS_OK) {
> +		switch (status) {
> +		case NFS_OK:
> +			/* server recognizes this one, don't re-open */
> +			break;
> +		case -NFS4ERR_ADMIN_REVOKED:
> +		case -NFS4ERR_DELEG_REVOKED:
> +			/* state was revoked, free then re-open */
> 			nfs41_free_stateid(server, stateid);
> 			state->flags &= ~flags;

Actually, I think we want to clear these flags in any case when status != NFS_OK.

> +			break;
> +		default:
> +			/* anything else: go ahead and re-open it */
> +			break;
> 		}
> 	}
> 	return status;
> @@ -4642,6 +4660,14 @@ out:
> }
> 
> #if defined(CONFIG_NFS_V4_1)
> +/**
> + * nfs41_check_expired_locks - clear lock state IDs
> + *
> + * @state: NFSv4 open state for a file
> + *
> + * Returns NFS_OK if recovery for this state ID is now finished.
> + * Otherwise a negative NFS4ERR value is returned.
> + */
> static int nfs41_check_expired_locks(struct nfs4_state *state)
> {
> 	int status, ret = NFS_OK;
> @@ -4651,9 +4677,17 @@ static int nfs41_check_expired_locks(struct nfs4_state *state)
> 	list_for_each_entry(lsp, &state->lock_states, ls_locks) {
> 		if (lsp->ls_flags & NFS_LOCK_INITIALIZED) {
> 			status = nfs41_test_stateid(server, &lsp->ls_stateid);
> -			if (status != NFS_OK) {
> +			switch (status) {
> +			case NFS_OK:
> +				/* server recognizes this one, don't re-lock */
> +				break;
> +			case -NFS4ERR_ADMIN_REVOKED:
> +			case -NFS4ERR_DELEG_REVOKED:
> +				/* lock was revoked, free then re-lock */
> 				nfs41_free_stateid(server, &lsp->ls_stateid);
> 				lsp->ls_flags &= ~NFS_LOCK_INITIALIZED;
> +				/*FALLTHROUGH*/
> +			default:
> 				ret = status;
> 			}
> 		}
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com




