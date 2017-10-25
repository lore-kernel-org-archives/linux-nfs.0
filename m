Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:26951 "EHLO
        userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751719AbdJYQN6 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 25 Oct 2017 12:13:58 -0400
Content-Type: text/plain; charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 9.3 \(3124\))
Subject: Re: [PATCH] sunrpc: use supplimental groups in auth hash.
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <87h8upe6bp.fsf@notabene.neil.brown.name>
Date: Wed, 25 Oct 2017 12:13:19 -0400
Cc: Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-Id: <CF1E0D4B-4EB3-4951-B152-39646ECF19DA@oracle.com>
References: <87h8upe6bp.fsf@notabene.neil.brown.name>
To: NeilBrown <neilb@suse.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


> On Oct 23, 2017, at 8:29 PM, NeilBrown <neilb@suse.com> wrote:
> 
> 
> Some sites vary some supplimental groups a lot.
> To avoid unduely long hash chains, include all of these
> in the hash calculation.
> 
> Signed-off-by: NeilBrown <neilb@suse.com>
> ---
> 
> Hi,
> I have a customer who had thousands of auth entries with the same
> uid and gid, so the hashtable was unbalanced and some lookups were
> noticeably slow.  This fix helped.
> 
> Relatedly, I wonder if we should set a default auth_max_cred_cachesize,
> and nfs_access_max_cachesize - smaller than ULONG_MAX.
> 
> For auth_max_cred_cachesize, a default of e.g. 256*(1<<auth_hashbits)
> is appropriate I think.  If there are more auth entries than that,
> you'll start to notice lookups taking a long time.
> 
> For nfs_access_max_cachesize we want a similar limit as each access
> entry pins an auth entry and so keeps a hash chain long.
> 
> Or maybe we could change the auth lookup to use an rbtree (or
> hash-table of rbtrees?) so that time scales with log of size.
> 
> One option is to restore the 'jiffies' field to the access cache, and
> discard entries older than (say) 10 minutes.
> 
> Thoughts?

Seems like we are always revisiting the hash function, and
there are always workloads where long chains occur. Since
the lookup-to-insertion ratio is very high, maybe it's time
to consider a data structure that self-balances on insertion,
like an rb-tree.

Would it make sense to protect the cache with a rwlock
instead of spin lock to allow concurrent readers?

Is there any sane way to make the cred cache into a set of
per CPU caches instead, to reduce the need for locking?


> Thanks,
> NeilBrown
> 
> 
> net/sunrpc/auth_generic.c | 15 ++++++++++++---
> net/sunrpc/auth_unix.c    | 12 +++++++++---
> 2 files changed, 21 insertions(+), 6 deletions(-)
> 
> diff --git a/net/sunrpc/auth_generic.c b/net/sunrpc/auth_generic.c
> index f1df9837f1ac..035f7c5f184f 100644
> --- a/net/sunrpc/auth_generic.c
> +++ b/net/sunrpc/auth_generic.c
> @@ -81,9 +81,18 @@ static struct rpc_cred *generic_bind_cred(struct rpc_task *task,
> static int
> generic_hash_cred(struct auth_cred *acred, unsigned int hashbits)
> {
> -	return hash_64(from_kgid(&init_user_ns, acred->gid) |
> -		((u64)from_kuid(&init_user_ns, acred->uid) <<
> -			(sizeof(gid_t) * 8)), hashbits);
> +	int ret = hash_32(from_kuid(&init_user_ns, acred->uid), 32);
> +
> +	if (acred->group_info) {
> +		int g;
> +
> +		for (g = 0; g < acred->group_info->ngroups; g++)
> +			ret = hash_32(ret ^
> +				      from_kgid(&init_user_ns,
> +						acred->group_info->gid[g]),
> +				      32);
> +	}
> +	return hash_32(ret ^ from_kgid(&init_user_ns, acred->gid), hashbits);
> }
> 
> /*
> diff --git a/net/sunrpc/auth_unix.c b/net/sunrpc/auth_unix.c
> index 82337e1ec9cd..20cd4ab3b339 100644
> --- a/net/sunrpc/auth_unix.c
> +++ b/net/sunrpc/auth_unix.c
> @@ -47,9 +47,15 @@ unx_destroy(struct rpc_auth *auth)
> static int
> unx_hash_cred(struct auth_cred *acred, unsigned int hashbits)
> {
> -	return hash_64(from_kgid(&init_user_ns, acred->gid) |
> -		((u64)from_kuid(&init_user_ns, acred->uid) <<
> -			(sizeof(gid_t) * 8)), hashbits);
> +	int ret = hash_32(from_kuid(&init_user_ns, acred->uid), 32);
> +	if (acred->group_info) {
> +		int g;
> +
> +		for (g = 0; g < acred->group_info->ngroups && g < UNX_NGROUPS; g++)
> +			ret = hash_32(ret ^ from_kgid(&init_user_ns,
> +						      acred->group_info->gid[g]), 32);
> +	}
> +	return hash_32(ret ^ from_kgid(&init_user_ns, acred->gid), hashbits);
> }
> 
> /*
> -- 
> 2.14.0.rc0.dirty
> 

--
Chuck Lever



