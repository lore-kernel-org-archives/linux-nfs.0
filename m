Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx143.netapp.com ([216.240.21.24]:7716 "EHLO mx143.netapp.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S932540AbcIUQFo (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 21 Sep 2016 12:05:44 -0400
Subject: Re: [PATCH v6 12/29] NFSv4.1: Allow revoked stateids to skip the call
 to TEST_STATEID
To: Trond Myklebust <trond.myklebust@primarydata.com>,
        <anna.schumaker@netapp.com>
References: <1474390571-17106-1-git-send-email-trond.myklebust@primarydata.com>
 <1474390571-17106-2-git-send-email-trond.myklebust@primarydata.com>
 <1474390571-17106-3-git-send-email-trond.myklebust@primarydata.com>
 <1474390571-17106-4-git-send-email-trond.myklebust@primarydata.com>
 <1474390571-17106-5-git-send-email-trond.myklebust@primarydata.com>
 <1474390571-17106-6-git-send-email-trond.myklebust@primarydata.com>
 <1474390571-17106-7-git-send-email-trond.myklebust@primarydata.com>
 <1474390571-17106-8-git-send-email-trond.myklebust@primarydata.com>
 <1474390571-17106-9-git-send-email-trond.myklebust@primarydata.com>
 <1474390571-17106-10-git-send-email-trond.myklebust@primarydata.com>
 <1474390571-17106-11-git-send-email-trond.myklebust@primarydata.com>
 <1474390571-17106-12-git-send-email-trond.myklebust@primarydata.com>
 <1474390571-17106-13-git-send-email-trond.myklebust@primarydata.com>
CC: <linux-nfs@vger.kernel.org>, Oleg Drokin <green@linuxhacker.ru>
From: Anna Schumaker <Anna.Schumaker@netapp.com>
Message-ID: <ad05aaa3-ac5d-eda2-9218-942423d43a0b@Netapp.com>
Date: Wed, 21 Sep 2016 12:03:48 -0400
MIME-Version: 1.0
In-Reply-To: <1474390571-17106-13-git-send-email-trond.myklebust@primarydata.com>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Trond,

On 09/20/2016 12:55 PM, Trond Myklebust wrote:
> In some cases (e.g. when the SEQ4_STATUS_EXPIRED_ALL_STATE_REVOKED sequence
> flag is set) we may already know that the stateid was revoked and that the
> only valid operation we can call is FREE_STATEID. In those cases, allow
> the stateid to carry the information in the type field, so that we skip
> the redundant call to TEST_STATEID.

Would you like to add a Signed-off-by to this patch? :)

Thanks,
Anna

> ---
>  fs/nfs/nfs4proc.c    | 32 +++++++++++++++++++++++---------
>  include/linux/nfs4.h |  1 +
>  2 files changed, 24 insertions(+), 9 deletions(-)
> 
> diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
> index 97a614370604..3c1b8cb7dd95 100644
> --- a/fs/nfs/nfs4proc.c
> +++ b/fs/nfs/nfs4proc.c
> @@ -2422,18 +2422,29 @@ static int nfs41_test_and_free_expired_stateid(struct nfs_server *server,
>  {
>  	int status;
>  
> -	status = nfs41_test_stateid(server, stateid, cred);
> +	switch (stateid->type) {
> +	default:
> +		break;
> +	case NFS4_INVALID_STATEID_TYPE:
> +	case NFS4_SPECIAL_STATEID_TYPE:
> +		return -NFS4ERR_BAD_STATEID;
> +	case NFS4_REVOKED_STATEID_TYPE:
> +		goto out_free;
> +	}
>  
> +	status = nfs41_test_stateid(server, stateid, cred);
>  	switch (status) {
>  	case -NFS4ERR_EXPIRED:
>  	case -NFS4ERR_ADMIN_REVOKED:
>  	case -NFS4ERR_DELEG_REVOKED:
> -		/* Ack the revoked state to the server */
> -		nfs41_free_stateid(server, stateid, cred);
> -	case -NFS4ERR_BAD_STATEID:
> +		break;
> +	default:
>  		return status;
>  	}
> -	return NFS_OK;
> +out_free:
> +	/* Ack the revoked state to the server */
> +	nfs41_free_stateid(server, stateid, cred);
> +	return -NFS4ERR_EXPIRED;
>  }
>  
>  static void nfs41_check_delegation_stateid(struct nfs4_state *state)
> @@ -2468,7 +2479,7 @@ static void nfs41_check_delegation_stateid(struct nfs4_state *state)
>  	rcu_read_unlock();
>  	status = nfs41_test_and_free_expired_stateid(server, &stateid, cred);
>  	trace_nfs4_test_delegation_stateid(state, NULL, status);
> -	if (status != NFS_OK)
> +	if (status == -NFS4ERR_EXPIRED || status == -NFS4ERR_BAD_STATEID)
>  		nfs_finish_clear_delegation_stateid(state, &stateid);
>  
>  	put_rpccred(cred);
> @@ -2497,7 +2508,7 @@ static int nfs41_check_open_stateid(struct nfs4_state *state)
>  
>  	status = nfs41_test_and_free_expired_stateid(server, stateid, cred);
>  	trace_nfs4_test_open_stateid(state, NULL, status);
> -	if (status != NFS_OK) {
> +	if (status == -NFS4ERR_EXPIRED || status == -NFS4ERR_BAD_STATEID) {
>  		clear_bit(NFS_O_RDONLY_STATE, &state->flags);
>  		clear_bit(NFS_O_WRONLY_STATE, &state->flags);
>  		clear_bit(NFS_O_RDWR_STATE, &state->flags);
> @@ -6124,7 +6135,7 @@ out:
>   */
>  static int nfs41_check_expired_locks(struct nfs4_state *state)
>  {
> -	int status, ret = -NFS4ERR_BAD_STATEID;
> +	int status, ret = NFS_OK;
>  	struct nfs4_lock_state *lsp;
>  	struct nfs_server *server = NFS_SERVER(state->inode);
>  
> @@ -6136,9 +6147,12 @@ static int nfs41_check_expired_locks(struct nfs4_state *state)
>  					&lsp->ls_stateid,
>  					cred);
>  			trace_nfs4_test_lock_stateid(state, lsp, status);
> -			if (status != NFS_OK) {
> +			if (status == -NFS4ERR_EXPIRED ||
> +			    status == -NFS4ERR_BAD_STATEID)
>  				clear_bit(NFS_LOCK_INITIALIZED, &lsp->ls_flags);
> +			else if (status != NFS_OK) {
>  				ret = status;
> +				break;
>  			}
>  		}
>  	};
> diff --git a/include/linux/nfs4.h b/include/linux/nfs4.h
> index c6564ada9beb..9094faf0699d 100644
> --- a/include/linux/nfs4.h
> +++ b/include/linux/nfs4.h
> @@ -67,6 +67,7 @@ struct nfs4_stateid_struct {
>  		NFS4_DELEGATION_STATEID_TYPE,
>  		NFS4_LAYOUT_STATEID_TYPE,
>  		NFS4_PNFS_DS_STATEID_TYPE,
> +		NFS4_REVOKED_STATEID_TYPE,
>  	} type;
>  };
>  
> 

