Return-Path: <Anna.Schumaker@netapp.com>
Subject: Re: [PATCH] NFSv4.1: Keep a reference on lock states while checking
To: Benjamin Coddington <bcodding@redhat.com>,
        Trond Myklebust
	<trond.myklebust@primarydata.com>
References: <6a50c9ed9077e43de5da454a2413769a0b383d58.1479427989.git.bcodding@redhat.com>
CC: <linux-nfs@vger.kernel.org>
From: Anna Schumaker <Anna.Schumaker@netapp.com>
Message-ID: <1bd7c0f1-28d7-e4e2-2799-c7f0b3e6d454@Netapp.com>
Date: Fri, 18 Nov 2016 16:55:46 -0500
MIME-Version: 1.0
In-Reply-To: <6a50c9ed9077e43de5da454a2413769a0b383d58.1479427989.git.bcodding@redhat.com>
Content-Type: text/plain; charset="utf-8"; format=flowed
List-ID: <linux-nfs.vger.kernel.org>

Hi Ben,

On 11/18/2016 05:03 AM, Benjamin Coddington wrote:
> While walking the list of lock_states, keep a reference on each
> nfs4_lock_state to be checked, otherwise the lock state could be removed
> while the check performs TEST_STATEID and possible FREE_STATEID.
>
> Signed-off-by: Benjamin Coddington <bcodding@redhat.com>
> ---
>  fs/nfs/nfs4proc.c | 15 +++++++++++++--
>  1 file changed, 13 insertions(+), 2 deletions(-)
>
> diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
> index 7897826d7c51..57d102d0f075 100644
> --- a/fs/nfs/nfs4proc.c
> +++ b/fs/nfs/nfs4proc.c
> @@ -2564,15 +2564,23 @@ static void nfs41_check_delegation_stateid(struct nfs4_state *state)
>  static int nfs41_check_expired_locks(struct nfs4_state *state)
>  {
>  	int status, ret = NFS_OK;
> -	struct nfs4_lock_state *lsp;
> +	struct nfs4_lock_state *lsp, *prev = NULL;
>  	struct nfs_server *server = NFS_SERVER(state->inode);
>
>  	if (!test_bit(LK_STATE_IN_USE, &state->flags))
>  		goto out;
> +
> +	spin_lock(&state->state_lock);
>  	list_for_each_entry(lsp, &state->lock_states, ls_locks) {
>  		if (test_bit(NFS_LOCK_INITIALIZED, &lsp->ls_flags)) {
>  			struct rpc_cred *cred = lsp->ls_state->owner->so_cred;
>
> +			atomic_inc(&lsp->ls_count);
> +			spin_unlock(&state->state_lock);
> +
> +			nfs4_put_lock_state(prev);
> +			prev = lsp;
> +
>  			status = nfs41_test_and_free_expired_stateid(server,
>  					&lsp->ls_stateid,
>  					cred);
> @@ -2587,8 +2595,11 @@ static int nfs41_check_expired_locks(struct nfs4_state *state)
>  				ret = status;
>  				break;

Should this "break" be replaced with a "goto out" since we're no longer holding the lock at this point?

Thanks,
Anna

>  			}
> +			spin_lock(&state->state_lock);
>  		}
> -	};
> +	}
> +	spin_unlock(&state->state_lock);
> +	nfs4_put_lock_state(prev);
>  out:
>  	return ret;
>  }
>
