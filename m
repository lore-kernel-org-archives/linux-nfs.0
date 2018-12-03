Return-Path: <SRS0=4jnv=OM=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B435AC65BAE
	for <linux-nfs@archiver.kernel.org>; Mon,  3 Dec 2018 00:33:16 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 7BBDE20659
	for <linux-nfs@archiver.kernel.org>; Mon,  3 Dec 2018 00:33:16 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7BBDE20659
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726030AbeLCAdJ (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Sun, 2 Dec 2018 19:33:09 -0500
Received: from mx2.suse.de ([195.135.220.15]:41142 "EHLO mx1.suse.de"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1725785AbeLCAdJ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Sun, 2 Dec 2018 19:33:09 -0500
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
        by mx1.suse.de (Postfix) with ESMTP id CC94DAD90;
        Mon,  3 Dec 2018 00:33:00 +0000 (UTC)
From:   NeilBrown <neilb@suse.com>
To:     "J. Bruce Fields" <bfields@fieldses.org>,
        Chuck Lever <chuck.lever@oracle.com>,
        Jeff Layton <jlayton@kernel.org>,
        Trond Myklebust <trond.myklebust@hammerspace.com>,
        Anna Schumaker <anna.schumaker@netapp.com>
Date:   Mon, 03 Dec 2018 11:30:30 +1100
Subject: [PATCH 10/23] NFSv4: don't require lock for get_renew_cred or
 get_machine_cred
Cc:     Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        linux-kernel@vger.kernel.org
Message-ID: <154379703049.28598.7812955137326487193.stgit@noble>
In-Reply-To: <154379689752.28598.6750646657534626618.stgit@noble>
References: <154379689752.28598.6750646657534626618.stgit@noble>
User-Agent: StGit/0.17.1-dirty
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

This lock is no longer necessary.

If nfs4_get_renew_cred() needs to hunt through the open-state
creds for a user cred, it still takes the lock to stablize
the rbtree, but otherwise there are no races.

Note that this completely removes the lock from nfs4_renew_state().
It appears that the original need for the locking here was removed
long ago, and there is no longer anything to protect.

Signed-off-by: NeilBrown <neilb@suse.com>
---
 fs/nfs/nfs4_fs.h    |    6 +++---
 fs/nfs/nfs4proc.c   |    4 ++--
 fs/nfs/nfs4renewd.c |    5 +----
 fs/nfs/nfs4state.c  |   26 ++++++++++----------------
 4 files changed, 16 insertions(+), 25 deletions(-)

diff --git a/fs/nfs/nfs4_fs.h b/fs/nfs/nfs4_fs.h
index 1b994b527518..ad649a49822f 100644
--- a/fs/nfs/nfs4_fs.h
+++ b/fs/nfs/nfs4_fs.h
@@ -250,7 +250,7 @@ struct nfs4_add_xprt_data {
 
 struct nfs4_state_maintenance_ops {
 	int (*sched_state_renewal)(struct nfs_client *, struct rpc_cred *, unsigned);
-	struct rpc_cred * (*get_state_renewal_cred_locked)(struct nfs_client *);
+	struct rpc_cred * (*get_state_renewal_cred)(struct nfs_client *);
 	int (*renew_lease)(struct nfs_client *, struct rpc_cred *);
 };
 
@@ -451,8 +451,8 @@ extern void nfs4_set_lease_period(struct nfs_client *clp,
 
 /* nfs4state.c */
 struct rpc_cred *nfs4_get_clid_cred(struct nfs_client *clp);
-struct rpc_cred *nfs4_get_machine_cred_locked(struct nfs_client *clp);
-struct rpc_cred *nfs4_get_renew_cred_locked(struct nfs_client *clp);
+struct rpc_cred *nfs4_get_machine_cred(struct nfs_client *clp);
+struct rpc_cred *nfs4_get_renew_cred(struct nfs_client *clp);
 int nfs4_discover_server_trunking(struct nfs_client *clp,
 			struct nfs_client **);
 int nfs40_discover_server_trunking(struct nfs_client *clp,
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 867457d6dfbe..cafa155a053e 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -9606,14 +9606,14 @@ static const struct nfs4_state_recovery_ops nfs41_nograce_recovery_ops = {
 
 static const struct nfs4_state_maintenance_ops nfs40_state_renewal_ops = {
 	.sched_state_renewal = nfs4_proc_async_renew,
-	.get_state_renewal_cred_locked = nfs4_get_renew_cred_locked,
+	.get_state_renewal_cred = nfs4_get_renew_cred,
 	.renew_lease = nfs4_proc_renew,
 };
 
 #if defined(CONFIG_NFS_V4_1)
 static const struct nfs4_state_maintenance_ops nfs41_state_renewal_ops = {
 	.sched_state_renewal = nfs41_proc_async_sequence,
-	.get_state_renewal_cred_locked = nfs4_get_machine_cred_locked,
+	.get_state_renewal_cred = nfs4_get_machine_cred,
 	.renew_lease = nfs4_proc_sequence,
 };
 #endif
diff --git a/fs/nfs/nfs4renewd.c b/fs/nfs/nfs4renewd.c
index 1f8c2ae43a8d..8880cd958210 100644
--- a/fs/nfs/nfs4renewd.c
+++ b/fs/nfs/nfs4renewd.c
@@ -68,7 +68,6 @@ nfs4_renew_state(struct work_struct *work)
 	if (test_bit(NFS_CS_STOP_RENEW, &clp->cl_res_state))
 		goto out;
 
-	spin_lock(&clp->cl_lock);
 	lease = clp->cl_lease_time;
 	last = clp->cl_last_renewal;
 	now = jiffies;
@@ -79,8 +78,7 @@ nfs4_renew_state(struct work_struct *work)
 		renew_flags |= NFS4_RENEW_DELEGATION_CB;
 
 	if (renew_flags != 0) {
-		cred = ops->get_state_renewal_cred_locked(clp);
-		spin_unlock(&clp->cl_lock);
+		cred = ops->get_state_renewal_cred(clp);
 		if (cred == NULL) {
 			if (!(renew_flags & NFS4_RENEW_DELEGATION_CB)) {
 				set_bit(NFS4CLNT_LEASE_EXPIRED, &clp->cl_state);
@@ -104,7 +102,6 @@ nfs4_renew_state(struct work_struct *work)
 	} else {
 		dprintk("%s: failed to call renewd. Reason: lease not expired \n",
 				__func__);
-		spin_unlock(&clp->cl_lock);
 	}
 	nfs4_schedule_state_renewal(clp);
 out_exp:
diff --git a/fs/nfs/nfs4state.c b/fs/nfs/nfs4state.c
index 511bcdee98f5..f142fca6995b 100644
--- a/fs/nfs/nfs4state.c
+++ b/fs/nfs/nfs4state.c
@@ -164,7 +164,7 @@ int nfs40_discover_server_trunking(struct nfs_client *clp,
 	return status;
 }
 
-struct rpc_cred *nfs4_get_machine_cred_locked(struct nfs_client *clp)
+struct rpc_cred *nfs4_get_machine_cred(struct nfs_client *clp)
 {
 	struct rpc_cred *cred = clp->cl_root_cred;
 
@@ -210,22 +210,23 @@ nfs4_get_renew_cred_server_locked(struct nfs_server *server)
 }
 
 /**
- * nfs4_get_renew_cred_locked - Acquire credential for a renew operation
+ * nfs4_get_renew_cred - Acquire credential for a renew operation
  * @clp: client state handle
  *
  * Returns an rpc_cred with reference count bumped, or NULL.
  * Caller must hold clp->cl_lock.
  */
-struct rpc_cred *nfs4_get_renew_cred_locked(struct nfs_client *clp)
+struct rpc_cred *nfs4_get_renew_cred(struct nfs_client *clp)
 {
 	struct rpc_cred *cred = NULL;
 	struct nfs_server *server;
 
 	/* Use machine credentials if available */
-	cred = nfs4_get_machine_cred_locked(clp);
+	cred = nfs4_get_machine_cred(clp);
 	if (cred != NULL)
 		goto out;
 
+	spin_lock(&clp->cl_lock);
 	rcu_read_lock();
 	list_for_each_entry_rcu(server, &clp->cl_superblocks, client_link) {
 		cred = nfs4_get_renew_cred_server_locked(server);
@@ -233,6 +234,7 @@ struct rpc_cred *nfs4_get_renew_cred_locked(struct nfs_client *clp)
 			break;
 	}
 	rcu_read_unlock();
+	spin_unlock(&clp->cl_lock);
 
 out:
 	return cred;
@@ -402,9 +404,7 @@ struct rpc_cred *nfs4_get_clid_cred(struct nfs_client *clp)
 {
 	struct rpc_cred *cred;
 
-	spin_lock(&clp->cl_lock);
-	cred = nfs4_get_machine_cred_locked(clp);
-	spin_unlock(&clp->cl_lock);
+	cred = nfs4_get_machine_cred(clp);
 	return cred;
 }
 
@@ -1908,9 +1908,7 @@ static int nfs4_check_lease(struct nfs_client *clp)
 	/* Is the client already known to have an expired lease? */
 	if (test_bit(NFS4CLNT_LEASE_EXPIRED, &clp->cl_state))
 		return 0;
-	spin_lock(&clp->cl_lock);
-	cred = ops->get_state_renewal_cred_locked(clp);
-	spin_unlock(&clp->cl_lock);
+	cred = ops->get_state_renewal_cred(clp);
 	if (cred == NULL) {
 		cred = nfs4_get_clid_cred(clp);
 		status = -ENOKEY;
@@ -2112,9 +2110,7 @@ static int nfs4_handle_migration(struct nfs_client *clp)
 	dprintk("%s: migration reported on \"%s\"\n", __func__,
 			clp->cl_hostname);
 
-	spin_lock(&clp->cl_lock);
-	cred = ops->get_state_renewal_cred_locked(clp);
-	spin_unlock(&clp->cl_lock);
+	cred = ops->get_state_renewal_cred(clp);
 	if (cred == NULL)
 		return -NFS4ERR_NOENT;
 
@@ -2160,9 +2156,7 @@ static int nfs4_handle_lease_moved(struct nfs_client *clp)
 	dprintk("%s: lease moved reported on \"%s\"\n", __func__,
 			clp->cl_hostname);
 
-	spin_lock(&clp->cl_lock);
-	cred = ops->get_state_renewal_cred_locked(clp);
-	spin_unlock(&clp->cl_lock);
+	cred = ops->get_state_renewal_cred(clp);
 	if (cred == NULL)
 		return -NFS4ERR_NOENT;
 


