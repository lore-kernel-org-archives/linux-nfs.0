Return-Path: <SRS0=erep=QP=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8C640C282CB
	for <linux-nfs@archiver.kernel.org>; Fri,  8 Feb 2019 20:11:14 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 4B9572177B
	for <linux-nfs@archiver.kernel.org>; Fri,  8 Feb 2019 20:11:14 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1727134AbfBHULF (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Fri, 8 Feb 2019 15:11:05 -0500
Received: from fieldses.org ([173.255.197.46]:57082 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1727505AbfBHUKu (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 8 Feb 2019 15:10:50 -0500
Received: by fieldses.org (Postfix, from userid 2815)
        id F36742014; Fri,  8 Feb 2019 15:10:48 -0500 (EST)
From:   "J. Bruce Fields" <bfields@redhat.com>
To:     linux-nfs@vger.kernel.org
Cc:     linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org,
        Trond Myklebust <trondmy@hammerspace.com>,
        Jeff Layton <jlayton@redhat.com>,
        David Howells <dhowells@redhat.com>, Tejun Heo <tj@kernel.org>,
        Peter Zijlstra <peterz@infradead.org>,
        Shaohua Li <shli@fb.com>, Oleg Nesterov <oleg@redhat.com>,
        "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 7/7] nfsd: ignore delegation self-conflicts
Date:   Fri,  8 Feb 2019 15:10:47 -0500
Message-Id: <1549656647-25115-8-git-send-email-bfields@redhat.com>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1549656647-25115-1-git-send-email-bfields@redhat.com>
References: <1549656647-25115-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

From: "J. Bruce Fields" <bfields@redhat.com>

A client's actions shouldn't revoke its own delegations, even if those
same actions (rename, link, etc.) would conflict if they came from a
different client.

Since nfsd has the necessary information to determine both who is
performing the action and who holds the relevant delegation, let nfsd
handle the revocation of delegations caused by nfs clients.

At the same time, modify the lease code to ignore conflicts between
delegations held by threads in the same tgid as the caller, assuming the
caller has taken care of any such conflicts itself.

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/locks.c          | 39 +++++++++++++++++++++++++++++
 fs/nfsd/nfs4state.c | 61 +++++++++++++++++++++++++++++++++++++++++++++
 fs/nfsd/state.h     |  2 ++
 fs/nfsd/vfs.c       | 32 +++++++++++++++++++-----
 include/linux/fs.h  |  2 ++
 5 files changed, 130 insertions(+), 6 deletions(-)

diff --git a/fs/locks.c b/fs/locks.c
index ff6af2c32601..a1275e7fdfb4 100644
--- a/fs/locks.c
+++ b/fs/locks.c
@@ -1528,6 +1528,16 @@ static void time_out_leases(struct inode *inode, struct list_head *dispose)
 
 static bool leases_conflict(struct file_lock *lease, struct file_lock *breaker)
 {
+	/*
+	 * We assume that threads in the same thread group are
+	 * responsible for resolving conflicts among themselves.
+	 * To avoid exposing this change in behavior to existing users,
+	 * we only do this for delegations, which have not yet been
+	 * exposed to userspace:
+	 */
+	if ((lease->fl_flags & FL_DELEG) &&
+				(lease->fl_pid == current->tgid))
+		return false;
 	if ((breaker->fl_flags & FL_LAYOUT) != (lease->fl_flags & FL_LAYOUT))
 		return false;
 	if ((breaker->fl_flags & FL_DELEG) && (lease->fl_flags & FL_LEASE))
@@ -1666,6 +1676,35 @@ int __break_lease(struct inode *inode, unsigned int mode, unsigned int type)
 }
 EXPORT_SYMBOL(__break_lease);
 
+/*
+ * This is just a convenient way for knfsd to iterate over its
+ * delegations.  We could possibly modify break_lease to work for
+ * this as well, or let nfsd find its delegations itself, with some
+ * changes to its data structures.
+ */
+bool foreach_delegation(struct inode *inode, bool cb(struct file_lock *, void *), void *arg)
+{
+	struct file_lock_context *ctx;
+	struct file_lock *fl;
+	bool delegs_broken = false;
+
+	if (!inode)
+		return false;
+	ctx = smp_load_acquire(&inode->i_flctx);
+	if (!ctx)
+		return false;
+	percpu_down_read_preempt_disable(&file_rwsem);
+	spin_lock(&ctx->flc_lock);
+	list_for_each_entry(fl, &ctx->flc_lease, fl_list) {
+		if (fl->fl_flags & FL_DELEG)
+			delegs_broken |= cb(fl, arg);
+	};
+	spin_unlock(&ctx->flc_lock);
+	percpu_up_read_preempt_enable(&file_rwsem);
+	return delegs_broken;
+}
+EXPORT_SYMBOL_GPL(foreach_delegation);
+
 /**
  *	lease_get_mtime - update modified time of an inode with exclusive lease
  *	@inode: the inode
diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index fb3c9844c82a..800c1625840e 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -4012,6 +4012,67 @@ nfsd_break_deleg_cb(struct file_lock *fl)
 	return ret;
 }
 
+bool nfs4_client_owns_lease(struct file_lock *lease, void *arg)
+{
+	struct nfs4_client *clp = arg;
+	struct nfs4_delegation *dl = lease->fl_owner;
+
+	return dl->dl_stid.sc_client == clp;
+}
+
+bool break_nfsd_deleg(struct file_lock *fl, void *arg)
+{
+	struct nfs4_client *clp = arg;
+
+	/*
+	 * XXX: may eventually also have to check whether this
+	 * delegation is knfsd's; but, for now, we know all delegations
+	 * are knfsd's.
+	 */
+	if (!nfs4_client_owns_lease(fl, clp)) {
+		nfsd_break_deleg_cb(fl);
+		return true;
+	}
+	return false;
+}
+
+/*
+ * Break all delegations on ths file that are held by one of our clients
+ * and that conflict with write access by the given client.
+ */
+static int nfsd_break_delegations(struct inode *inode,
+				  struct nfs4_client *clp)
+{
+	bool delegs_broken;
+
+	delegs_broken = foreach_delegation(inode, break_nfsd_deleg, clp);
+	return delegs_broken ? -EWOULDBLOCK : 0;
+}
+
+static struct nfs4_client *nfsd4_client_from_rqst(struct svc_rqst *rqst)
+{
+	struct nfsd4_compoundres *resp;
+
+	/*
+	 * In case it's possible we could be called from NLM or ACL
+	 * code?:
+	 */
+	if (rqst->rq_prog != NFS_PROGRAM)
+		return NULL;
+	if (rqst->rq_vers != 4)
+		return NULL;
+	resp = rqst->rq_resp;
+	return resp->cstate.clp;
+}
+
+int nfsd_break_delegations_by_rqst(struct inode *inode,
+					  struct svc_rqst *rqstp)
+{
+	struct nfs4_client *clp = nfsd4_client_from_rqst(rqstp);
+
+	return nfsd_break_delegations(inode, clp);
+}
+
 static int
 nfsd_change_deleg_cb(struct file_lock *onlist, int arg,
 		     struct list_head *dispose)
diff --git a/fs/nfsd/state.h b/fs/nfsd/state.h
index 396c76755b03..3a7f6fdc92b4 100644
--- a/fs/nfsd/state.h
+++ b/fs/nfsd/state.h
@@ -649,6 +649,8 @@ static inline void get_nfs4_file(struct nfs4_file *fi)
 }
 struct file *find_any_file(struct nfs4_file *f);
 
+int nfsd_break_delegations_by_rqst(struct inode *, struct svc_rqst *);
+
 /* grace period management */
 void nfsd4_end_grace(struct nfsd_net *nn);
 
diff --git a/fs/nfsd/vfs.c b/fs/nfsd/vfs.c
index 9824e32b2f23..fb87d9f23ba8 100644
--- a/fs/nfsd/vfs.c
+++ b/fs/nfsd/vfs.c
@@ -456,6 +456,9 @@ nfsd_setattr(struct svc_rqst *rqstp, struct svc_fh *fhp, struct iattr *iap,
 	}
 
 	fh_lock(fhp);
+	host_err = nfsd_break_delegations_by_rqst(d_inode(dentry), rqstp);
+	if (host_err)
+		goto out_unlock;
 	if (size_change) {
 		/*
 		 * RFC5661, Section 18.30.4:
@@ -697,14 +700,15 @@ nfsd_access(struct svc_rqst *rqstp, struct svc_fh *fhp, u32 *access, u32 *suppor
 }
 #endif /* CONFIG_NFSD_V3 */
 
-static int nfsd_open_break_lease(struct inode *inode, int access)
+static int nfsd_open_break_lease(struct inode *inode, int access,
+				 struct svc_rqst *rqst)
 {
-	unsigned int mode;
-
 	if (access & NFSD_MAY_NOT_BREAK_LEASE)
 		return 0;
-	mode = (access & NFSD_MAY_WRITE) ? O_WRONLY : O_RDONLY;
-	return break_lease(inode, mode | O_NONBLOCK);
+	/* We don't implement write delegations yet: */
+	if (!(access & NFSD_MAY_WRITE))
+		return 0;
+	return nfsd_break_delegations_by_rqst(inode, rqst);
 }
 
 /*
@@ -764,7 +768,7 @@ nfsd_open(struct svc_rqst *rqstp, struct svc_fh *fhp, umode_t type,
 	if (!inode->i_fop)
 		goto out;
 
-	host_err = nfsd_open_break_lease(inode, may_flags);
+	host_err = nfsd_open_break_lease(inode, may_flags, rqstp);
 	if (host_err) /* NOMEM or WOULDBLOCK */
 		goto out_nfserr;
 
@@ -1633,6 +1637,11 @@ nfsd_link(struct svc_rqst *rqstp, struct svc_fh *ffhp,
 	err = nfserr_noent;
 	if (d_really_is_negative(dold))
 		goto out_dput;
+
+	host_err = nfsd_break_delegations_by_rqst(d_inode(dold), rqstp);
+	if (host_err)
+		goto out_dput;
+
 	host_err = vfs_link(dold, dirp, dnew, NULL);
 	if (!host_err) {
 		err = nfserrno(commit_metadata(ffhp));
@@ -1726,6 +1735,13 @@ nfsd_rename(struct svc_rqst *rqstp, struct svc_fh *ffhp, char *fname, int flen,
 	if (ffhp->fh_export->ex_path.dentry != tfhp->fh_export->ex_path.dentry)
 		goto out_dput_new;
 
+	host_err = nfsd_break_delegations_by_rqst(d_inode(odentry), rqstp);
+	if (host_err)
+		goto out_dput_new;
+	host_err = nfsd_break_delegations_by_rqst(d_inode(ndentry), rqstp);
+	if (host_err)
+		goto out_dput_new;
+
 	host_err = vfs_rename(fdir, odentry, tdir, ndentry, NULL, 0);
 	if (!host_err) {
 		host_err = commit_metadata(tfhp);
@@ -1795,6 +1811,10 @@ nfsd_unlink(struct svc_rqst *rqstp, struct svc_fh *fhp, int type,
 	if (!type)
 		type = d_inode(rdentry)->i_mode & S_IFMT;
 
+	host_err = nfsd_break_delegations_by_rqst(d_inode(rdentry), rqstp);
+	if (host_err)
+		goto out_nfserr;
+
 	if (type != S_IFDIR)
 		host_err = vfs_unlink(dirp, rdentry, NULL);
 	else
diff --git a/include/linux/fs.h b/include/linux/fs.h
index 29d8e2cfed0e..467981b5fd9d 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -2439,6 +2439,8 @@ static inline int break_deleg_wait(struct inode **delegated_inode)
 	return ret;
 }
 
+bool foreach_delegation(struct inode *inode, bool cb(struct file_lock *, void   *), void *arg);
+
 static inline int break_layout(struct inode *inode, bool wait)
 {
 	smp_mb();
-- 
2.20.1

