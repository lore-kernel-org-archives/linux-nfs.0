Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:26570 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756558Ab2CFQYo convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 6 Mar 2012 11:24:44 -0500
Received: from vmwexceht03-prd.hq.netapp.com ([10.106.76.241])
	by smtp2.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id q26GOhbF005587
	for <linux-nfs@vger.kernel.org>; Tue, 6 Mar 2012 08:24:43 -0800 (PST)
From: "Adamson, Andy" <William.Adamson@netapp.com>
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
CC: "<linux-nfs@vger.kernel.org>" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH v2] NFS: Properly handle the case where the delegation
 is revoked
Date: Tue, 6 Mar 2012 16:24:42 +0000
Message-ID: <E67CE84F-776D-42C2-8939-8FABEA44D360@netapp.com>
References: <1331046186-5638-1-git-send-email-Trond.Myklebust@netapp.com>
In-Reply-To: <1331046186-5638-1-git-send-email-Trond.Myklebust@netapp.com>
Content-Type: text/plain; charset="Windows-1252"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

With  "NFS: Properly handle the case where the delegation is revoked" patch added to Trond's origin/testign branch,  my python test that removes the (delegation) stateid on a READ, and returns NFS4ERR_BAD_STATEID passes as the client recovers by testing and freeing the stateid, and then sending an OPEN with a CLAIM_NULL.

-->Andy


BTW: this patch cleans up some stateid compares and the second chunk is needed for the origin/testing branch to compile.  You've probably already found this…..
8-------------------------------------------------------
>From 5898e8c4ca19f0c22407186b305d982d30ffd653 Mon Sep 17 00:00:00 2001
From: Andy Adamson <andros@netapp.com>
Date: Tue, 6 Mar 2012 10:57:41 -0500
Subject: [PATCH 1/1] NFSv4.1 use stateid helpers

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 fs/nfs/delegation.c |    4 ++--
 fs/nfs/nfs4state.c  |    2 +-
 2 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/fs/nfs/delegation.c b/fs/nfs/delegation.c
index 15a4e8e..b93b996 100644
--- a/fs/nfs/delegation.c
+++ b/fs/nfs/delegation.c
@@ -248,8 +248,8 @@ int nfs_inode_set_delegation(struct inode *inode, struct rpc_cred *cred, struct
 	old_delegation = rcu_dereference_protected(nfsi->delegation,
 					lockdep_is_held(&clp->cl_lock));
 	if (old_delegation != NULL) {
-		if (memcmp(&delegation->stateid, &old_delegation->stateid,
-					sizeof(old_delegation->stateid)) == 0 &&
+		if (nfs4_stateid_match(&delegation->stateid,
+				&old_delegation->stateid) &&
 				delegation->type == old_delegation->type) {
 			goto out;
 		}
diff --git a/fs/nfs/nfs4state.c b/fs/nfs/nfs4state.c
index e98b8c0..079c0aa 100644
--- a/fs/nfs/nfs4state.c
+++ b/fs/nfs/nfs4state.c
@@ -1126,7 +1126,7 @@ void nfs_inode_find_state_and_recover(struct inode *inode,
 			continue;
 		if (!test_bit(NFS_DELEGATED_STATE, &state->flags))
 			continue;
-		if (memcmp(state->stateid.data, stateid->data, sizeof(state->stateid.data)) != 0)
+		if (!nfs4_stateid_match(state->stateid, stateid))
 			continue;
 		nfs4_state_mark_reclaim_nograce(clp, state);
 		found = true;
-- 
1.7.6.4






On Mar 6, 2012, at 10:03 AM, Trond Myklebust wrote:

> If we know that the delegation stateid is bad or revoked, we need to
> remove that delegation as soon as possible, and then mark all the
> stateids that relied on that delegation for recovery. We cannot use
> the delegation as part of the recovery process.
> 
> Also note that NFSv4.1 uses a different error code (NFS4ERR_DELEG_REVOKED)
> to indicate that the delegation was revoked.
> 
> Finally, ensure that setlk() and setattr() can both recover safely from
> a revoked delegation.
> 
> Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
> Cc: stable@vger.kernel.org
> ---
> v2: - Add handling of BAD_STATEID/DELEG_REVOKED/... in
>      nfs4_open_delegation_recall
>    - Remove redundant nfs_async_inode_return_delegation from
>      nfs4_schedule_stateid_recovery
> 
> 
> fs/nfs/delegation.c |   11 +++++++++++
> fs/nfs/delegation.h |    1 +
> fs/nfs/nfs4_fs.h    |    2 ++
> fs/nfs/nfs4proc.c   |   18 ++++++++++++++++--
> fs/nfs/nfs4state.c  |   29 +++++++++++++++++++++++++++--
> 5 files changed, 57 insertions(+), 4 deletions(-)
> 
> diff --git a/fs/nfs/delegation.c b/fs/nfs/delegation.c
> index 2d06080..5eb3981 100644
> --- a/fs/nfs/delegation.c
> +++ b/fs/nfs/delegation.c
> @@ -467,6 +467,17 @@ static void nfs_delegation_run_state_manager(struct nfs_client *clp)
> 		nfs4_schedule_state_manager(clp);
> }
> 
> +void nfs_remove_bad_delegation(struct inode *inode)
> +{
> +	struct nfs_delegation *delegation;
> +
> +	delegation = nfs_detach_delegation(NFS_I(inode), NFS_SERVER(inode));
> +	if (delegation) {
> +		nfs_inode_find_state_and_recover(inode, &delegation->stateid);
> +		nfs_free_delegation(delegation);
> +	}
> +}
> +
> /**
>  * nfs_expire_all_delegation_types
>  * @clp: client to process
> diff --git a/fs/nfs/delegation.h b/fs/nfs/delegation.h
> index d9322e4..691a796 100644
> --- a/fs/nfs/delegation.h
> +++ b/fs/nfs/delegation.h
> @@ -45,6 +45,7 @@ void nfs_expire_unreferenced_delegations(struct nfs_client *clp);
> void nfs_handle_cb_pathdown(struct nfs_client *clp);
> int nfs_client_return_marked_delegations(struct nfs_client *clp);
> int nfs_delegations_present(struct nfs_client *clp);
> +void nfs_remove_bad_delegation(struct inode *inode);
> 
> void nfs_delegation_mark_reclaim(struct nfs_client *clp);
> void nfs_delegation_reap_unclaimed(struct nfs_client *clp);
> diff --git a/fs/nfs/nfs4_fs.h b/fs/nfs/nfs4_fs.h
> index 4d7d0ae..5c9b20b 100644
> --- a/fs/nfs/nfs4_fs.h
> +++ b/fs/nfs/nfs4_fs.h
> @@ -327,6 +327,8 @@ extern void nfs4_put_open_state(struct nfs4_state *);
> extern void nfs4_close_state(struct nfs4_state *, fmode_t);
> extern void nfs4_close_sync(struct nfs4_state *, fmode_t);
> extern void nfs4_state_set_mode_locked(struct nfs4_state *, fmode_t);
> +extern void nfs_inode_find_state_and_recover(struct inode *inode,
> +		const nfs4_stateid *stateid);
> extern void nfs4_schedule_lease_recovery(struct nfs_client *);
> extern void nfs4_schedule_state_manager(struct nfs_client *);
> extern void nfs4_schedule_path_down_recovery(struct nfs_client *clp);
> diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
> index ec9f6ef..3d26bab 100644
> --- a/fs/nfs/nfs4proc.c
> +++ b/fs/nfs/nfs4proc.c
> @@ -265,8 +265,11 @@ static int nfs4_handle_exception(struct nfs_server *server, int errorcode, struc
> 	switch(errorcode) {
> 		case 0:
> 			return 0;
> +		case -NFS4ERR_DELEG_REVOKED:
> 		case -NFS4ERR_ADMIN_REVOKED:
> 		case -NFS4ERR_BAD_STATEID:
> +			if (state != NULL)
> +				nfs_remove_bad_delegation(state->inode);
> 		case -NFS4ERR_OPENMODE:
> 			if (state == NULL)
> 				break;
> @@ -1319,8 +1322,11 @@ int nfs4_open_delegation_recall(struct nfs_open_context *ctx, struct nfs4_state
> 				 * The show must go on: exit, but mark the
> 				 * stateid as needing recovery.
> 				 */
> +			case -NFS4ERR_DELEG_REVOKED:
> 			case -NFS4ERR_ADMIN_REVOKED:
> 			case -NFS4ERR_BAD_STATEID:
> +				nfs_inode_find_state_and_recover(state->inode,
> +						stateid);
> 				nfs4_schedule_stateid_recovery(server, state);
> 			case -EKEYEXPIRED:
> 				/*
> @@ -1900,7 +1906,9 @@ static int nfs4_do_setattr(struct inode *inode, struct rpc_cred *cred,
> 			   struct nfs4_state *state)
> {
> 	struct nfs_server *server = NFS_SERVER(inode);
> -	struct nfs4_exception exception = { };
> +	struct nfs4_exception exception = {
> +		.state = state,
> +	};
> 	int err;
> 	do {
> 		err = nfs4_handle_exception(server,
> @@ -3714,8 +3722,11 @@ nfs4_async_handle_error(struct rpc_task *task, const struct nfs_server *server,
> 	if (task->tk_status >= 0)
> 		return 0;
> 	switch(task->tk_status) {
> +		case -NFS4ERR_DELEG_REVOKED:
> 		case -NFS4ERR_ADMIN_REVOKED:
> 		case -NFS4ERR_BAD_STATEID:
> +			if (state != NULL)
> +				nfs_remove_bad_delegation(state->inode);
> 		case -NFS4ERR_OPENMODE:
> 			if (state == NULL)
> 				break;
> @@ -4533,7 +4544,9 @@ out:
> 
> static int nfs4_proc_setlk(struct nfs4_state *state, int cmd, struct file_lock *request)
> {
> -	struct nfs4_exception exception = { };
> +	struct nfs4_exception exception = {
> +		.state = state,
> +	};
> 	int err;
> 
> 	do {
> @@ -4626,6 +4639,7 @@ int nfs4_lock_delegation_recall(struct nfs4_state *state, struct file_lock *fl)
> 				 * The show must go on: exit, but mark the
> 				 * stateid as needing recovery.
> 				 */
> +			case -NFS4ERR_DELEG_REVOKED:
> 			case -NFS4ERR_ADMIN_REVOKED:
> 			case -NFS4ERR_BAD_STATEID:
> 			case -NFS4ERR_OPENMODE:
> diff --git a/fs/nfs/nfs4state.c b/fs/nfs/nfs4state.c
> index 4539203..0e60df1 100644
> --- a/fs/nfs/nfs4state.c
> +++ b/fs/nfs/nfs4state.c
> @@ -1132,12 +1132,37 @@ void nfs4_schedule_stateid_recovery(const struct nfs_server *server, struct nfs4
> {
> 	struct nfs_client *clp = server->nfs_client;
> 
> -	if (test_and_clear_bit(NFS_DELEGATED_STATE, &state->flags))
> -		nfs_async_inode_return_delegation(state->inode, &state->stateid);
> 	nfs4_state_mark_reclaim_nograce(clp, state);
> 	nfs4_schedule_state_manager(clp);
> }
> 
> +void nfs_inode_find_state_and_recover(struct inode *inode,
> +		const nfs4_stateid *stateid)
> +{
> +	struct nfs_client *clp = NFS_SERVER(inode)->nfs_client;
> +	struct nfs_inode *nfsi = NFS_I(inode);
> +	struct nfs_open_context *ctx;
> +	struct nfs4_state *state;
> +	bool found = false;
> +
> +	spin_lock(&inode->i_lock);
> +	list_for_each_entry(ctx, &nfsi->open_files, list) {
> +		state = ctx->state;
> +		if (state == NULL)
> +			continue;
> +		if (!test_bit(NFS_DELEGATED_STATE, &state->flags))
> +			continue;
> +		if (memcmp(state->stateid.data, stateid->data, sizeof(state->stateid.data)) != 0)
> +			continue;
> +		nfs4_state_mark_reclaim_nograce(clp, state);
> +		found = true;
> +	}
> +	spin_unlock(&inode->i_lock);
> +	if (found)
> +		nfs4_schedule_state_manager(clp);
> +}
> +
> +
> static int nfs4_reclaim_locks(struct nfs4_state *state, const struct nfs4_state_recovery_ops *ops)
> {
> 	struct inode *inode = state->inode;
> -- 
> 1.7.7.6
> 

