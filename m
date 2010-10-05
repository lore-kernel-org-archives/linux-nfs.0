Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:11595 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751024Ab0JENhm convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 5 Oct 2010 09:37:42 -0400
Subject: Re: NFS4 clients cannot reclaim locks
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: Sachin Prabhu <sprabhu@redhat.com>
Cc: linux-nfs <linux-nfs@vger.kernel.org>
In-Reply-To: <14582176.106.1286186603313.JavaMail.sprabhu@dhcp-1-233.fab.redhat.com>
References: <14582176.106.1286186603313.JavaMail.sprabhu@dhcp-1-233.fab.redhat.com>
Content-Type: text/plain; charset="UTF-8"
Date: Tue, 05 Oct 2010 09:37:18 -0400
Message-ID: <1286285838.3338.1.camel@heimdal.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Mon, 2010-10-04 at 06:03 -0400, Sachin Prabhu wrote:
> From instrumentation, the problem appears to happen at nfs4_open_prepare
> 
> static void nfs4_open_prepare(struct rpc_task *task, void *calldata)
> {
> ..
>         /*
>          * Check if we still need to send an OPEN call, or if we can use
>          * a delegation instead.
>          */
> 
>         if (data->state != NULL) {
>                 struct nfs_delegation *delegation;
> 
>                 if (can_open_cached(data->state, data->o_arg.fmode, data->o_arg.open_flags))
>                         goto out_no_action;
> ..
> out_no_action:
>         task->tk_action = NULL;
> 
> }
> 
> Here, can_open_cached returns true. The open call is never made and the old state is used.
> static int nfs4_reclaim_open_state(struct nfs4_state_owner *sp, const struct nfs4_state_recovery_ops *ops)
> {
> ..
> restart:
> ..
>                 status = ops->recover_open(sp, state); <-- This call attempts to use cached state and status is set to 0
>                 if (status >= 0) {
>                         status = nfs4_reclaim_locks(state, ops); <-- Attempts to reclaim locks using old stateid
>         -- Here status is set to -NFS4ERR_BAD_STATEID --
>                  ..
>                 }
>                 switch (status) {
> ..
>                         case -NFS4ERR_BAD_STATEID:
>                         case -NFS4ERR_RECLAIM_BAD:
>                         case -NFS4ERR_RECLAIM_CONFLICT:
>                                 nfs4_state_mark_reclaim_nograce(sp->so_client, state);
>                                 break;
> ..
>                 }
>                 nfs4_put_open_state(state);
>                 goto restart;
> ..
> }
> 
> The call to ops->recover_open() calls nfs4_open_expired(). While preparing the RPC call to OPEN, in nfs4_open_prepare(), it decides that the caches copy is valid and it attempts to use it. So nfs4_open_expired() returns 0. The subsequent call to reclaim locks using nfs4_reclaim_locks() fails with with a -NFS4ERR_BAD_STATEID. A goto statement in nfs4_reclaim_open_state() results in it looping with the same results as before.

Yup. That makes sense. Does the following patch help?

Cheers
  Trond
--------------------------------------------------------------------------------------------------------
NFSv4: Fix open recovery

From: Trond Myklebust <Trond.Myklebust@netapp.com>

NFSv4 open recovery is currently broken: since we do not clear the
state->flags states before attempting recovery, we end up with the
'can_open_cached()' function triggering. This again leads to no OPEN call
being put on the wire.

Reported-by: Sachin Prabhu <sprabhu@redhat.com>
Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---

 fs/nfs/nfs4proc.c |    3 +++
 1 files changed, 3 insertions(+), 0 deletions(-)


diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 089da5b..01b4817 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -1120,6 +1120,7 @@ static int nfs4_open_recover(struct nfs4_opendata *opendata, struct nfs4_state *
 	clear_bit(NFS_DELEGATED_STATE, &state->flags);
 	smp_rmb();
 	if (state->n_rdwr != 0) {
+		clear_bit(NFS_O_RDWR_STATE, &state->flags);
 		ret = nfs4_open_recover_helper(opendata, FMODE_READ|FMODE_WRITE, &newstate);
 		if (ret != 0)
 			return ret;
@@ -1127,6 +1128,7 @@ static int nfs4_open_recover(struct nfs4_opendata *opendata, struct nfs4_state *
 			return -ESTALE;
 	}
 	if (state->n_wronly != 0) {
+		clear_bit(NFS_O_WRONLY_STATE, &state->flags);
 		ret = nfs4_open_recover_helper(opendata, FMODE_WRITE, &newstate);
 		if (ret != 0)
 			return ret;
@@ -1134,6 +1136,7 @@ static int nfs4_open_recover(struct nfs4_opendata *opendata, struct nfs4_state *
 			return -ESTALE;
 	}
 	if (state->n_rdonly != 0) {
+		clear_bit(NFS_O_RDONLY_STATE, &state->flags);
 		ret = nfs4_open_recover_helper(opendata, FMODE_READ, &newstate);
 		if (ret != 0)
 			return ret;

