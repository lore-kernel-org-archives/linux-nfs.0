Return-Path: <SRS0=g2h7=O3=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9E2E3C43613
	for <linux-nfs@archiver.kernel.org>; Tue, 18 Dec 2018 14:29:29 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 798E521871
	for <linux-nfs@archiver.kernel.org>; Tue, 18 Dec 2018 14:29:29 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1727070AbeLRO32 (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 18 Dec 2018 09:29:28 -0500
Received: from mx1.redhat.com ([209.132.183.28]:50802 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1727074AbeLRO32 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 18 Dec 2018 09:29:28 -0500
Received: from smtp.corp.redhat.com (int-mx06.intmail.prod.int.phx2.redhat.com [10.5.11.16])
        (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
        (No client certificate requested)
        by mx1.redhat.com (Postfix) with ESMTPS id 3FE9958E34;
        Tue, 18 Dec 2018 14:29:27 +0000 (UTC)
Received: from coeurl.usersys.redhat.com (ovpn-125-147.rdu2.redhat.com [10.10.125.147])
        by smtp.corp.redhat.com (Postfix) with ESMTP id C9B3466D5A;
        Tue, 18 Dec 2018 14:29:26 +0000 (UTC)
Received: by coeurl.usersys.redhat.com (Postfix, from userid 1000)
        id 5158320D39; Tue, 18 Dec 2018 09:29:26 -0500 (EST)
From:   Scott Mayhew <smayhew@redhat.com>
To:     bfields@fieldses.org, jlayton@kernel.org
Cc:     linux-nfs@vger.kernel.org
Subject: [PATCH v2 2/3] nfsd: un-deprecate nfsdcld
Date:   Tue, 18 Dec 2018 09:29:25 -0500
Message-Id: <20181218142926.27933-3-smayhew@redhat.com>
In-Reply-To: <20181218142926.27933-1-smayhew@redhat.com>
References: <20181218142926.27933-1-smayhew@redhat.com>
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.16
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.39]); Tue, 18 Dec 2018 14:29:27 +0000 (UTC)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

When nfsdcld was released, it was quickly deprecated in favor of the
nfsdcltrack usermodehelper, so as to not require another running daemon.
That prevents NFSv4 clients from reclaiming locks from nfsd's running in
containers, since neither nfsdcltrack nor the legacy client tracking
code work in containers.

This commit un-deprecates the use of nfsdcld, with one twist: we will
populate the reclaim_str_hashtbl on startup.

During client tracking initialization, do an upcall ("GraceStart") to
nfsdcld to get a list of clients from the database.  nfsdcld will do
one downcall with a status of -EINPROGRESS for each client record in
the database, which in turn will cause an nfs4_client_reclaim to be
added to the reclaim_str_hashtbl.  When complete, nfsdcld will do a
final downcall with a status of 0.

This will save nfsd from having to do an upcall to the daemon during
nfs4_check_open_reclaim() processing.

Even though nfsdcld was quickly deprecated, there is a very small chance
of old nfsdcld daemons running in the wild.  These will respond to the
new "GraceStart" upcall with -EOPNOTSUPP, in which case we will log a
message and fall back to the original nfsdcld tracking ops (now called
nfsd4_cld_tracking_ops_v0).

Signed-off-by: Scott Mayhew <smayhew@redhat.com>
---
 fs/nfsd/nfs4recover.c         | 225 ++++++++++++++++++++++++++++++++--
 include/uapi/linux/nfsd/cld.h |   1 +
 2 files changed, 218 insertions(+), 8 deletions(-)

diff --git a/fs/nfsd/nfs4recover.c b/fs/nfsd/nfs4recover.c
index 2243b909b407..89c2a27956d0 100644
--- a/fs/nfsd/nfs4recover.c
+++ b/fs/nfsd/nfs4recover.c
@@ -779,6 +779,34 @@ cld_pipe_upcall(struct rpc_pipe *pipe, struct cld_msg *cmsg)
 	return ret;
 }
 
+static ssize_t
+__cld_pipe_inprogress_downcall(const struct cld_msg __user *cmsg,
+		struct nfsd_net *nn)
+{
+	uint8_t cmd;
+	struct xdr_netobj name;
+	uint16_t namelen;
+
+	if (get_user(cmd, &cmsg->cm_cmd)) {
+		dprintk("%s: error when copying cmd from userspace", __func__);
+		return -EFAULT;
+	}
+	if (cmd == Cld_GraceStart) {
+		if (get_user(namelen, &cmsg->cm_u.cm_name.cn_len))
+			return -EFAULT;
+		name.data = memdup_user(&cmsg->cm_u.cm_name.cn_id, namelen);
+		if (IS_ERR_OR_NULL(name.data))
+			return -EFAULT;
+		name.len = namelen;
+		if (!nfs4_client_to_reclaim(name, nn)) {
+			kfree(name.data);
+			return -EFAULT;
+		}
+		return sizeof(*cmsg);
+	}
+	return -EFAULT;
+}
+
 static ssize_t
 cld_pipe_downcall(struct file *filp, const char __user *src, size_t mlen)
 {
@@ -788,6 +816,7 @@ cld_pipe_downcall(struct file *filp, const char __user *src, size_t mlen)
 	struct nfsd_net *nn = net_generic(file_inode(filp)->i_sb->s_fs_info,
 						nfsd_net_id);
 	struct cld_net *cn = nn->cld_net;
+	int16_t status;
 
 	if (mlen != sizeof(*cmsg)) {
 		dprintk("%s: got %zu bytes, expected %zu\n", __func__, mlen,
@@ -801,13 +830,24 @@ cld_pipe_downcall(struct file *filp, const char __user *src, size_t mlen)
 		return -EFAULT;
 	}
 
+	/*
+	 * copy the status so we know whether to remove the upcall from the
+	 * list (for -EINPROGRESS, we just want to make sure the xid is
+	 * valid, not remove the upcall from the list)
+	 */
+	if (get_user(status, &cmsg->cm_status)) {
+		dprintk("%s: error when copying status from userspace", __func__);
+		return -EFAULT;
+	}
+
 	/* walk the list and find corresponding xid */
 	cup = NULL;
 	spin_lock(&cn->cn_lock);
 	list_for_each_entry(tmp, &cn->cn_list, cu_list) {
 		if (get_unaligned(&tmp->cu_msg.cm_xid) == xid) {
 			cup = tmp;
-			list_del_init(&cup->cu_list);
+			if (status != -EINPROGRESS)
+				list_del_init(&cup->cu_list);
 			break;
 		}
 	}
@@ -819,6 +859,9 @@ cld_pipe_downcall(struct file *filp, const char __user *src, size_t mlen)
 		return -EINVAL;
 	}
 
+	if (status == -EINPROGRESS)
+		return __cld_pipe_inprogress_downcall(cmsg, nn);
+
 	if (copy_from_user(&cup->cu_msg, src, mlen) != 0)
 		return -EFAULT;
 
@@ -1065,9 +1108,14 @@ nfsd4_cld_remove(struct nfs4_client *clp)
 				"record from stable storage: %d\n", ret);
 }
 
-/* Check for presence of a record, and update its timestamp */
+/*
+ * For older nfsdcld's that do not allow us to "slurp" the clients
+ * from the tracking database during startup.
+ *
+ * Check for presence of a record, and update its timestamp
+ */
 static int
-nfsd4_cld_check(struct nfs4_client *clp)
+nfsd4_cld_check_v0(struct nfs4_client *clp)
 {
 	int ret;
 	struct cld_upcall *cup;
@@ -1100,8 +1148,61 @@ nfsd4_cld_check(struct nfs4_client *clp)
 	return ret;
 }
 
+/*
+ * For newer nfsdcld's that allow us to "slurp" the clients
+ * from the tracking database during startup.
+ *
+ * Check for presence of a record in the reclaim_str_hashtbl
+ */
+static int
+nfsd4_cld_check(struct nfs4_client *clp)
+{
+	struct nfs4_client_reclaim *crp;
+	struct nfsd_net *nn = net_generic(clp->net, nfsd_net_id);
+
+	/* did we already find that this client is stable? */
+	if (test_bit(NFSD4_CLIENT_STABLE, &clp->cl_flags))
+		return 0;
+
+	/* look for it in the reclaim hashtable otherwise */
+	crp = nfsd4_find_reclaim_client(clp->cl_name, nn);
+	if (crp) {
+		crp->cr_clp = clp;
+		return 0;
+	}
+
+	return -ENOENT;
+}
+
+static int
+nfsd4_cld_grace_start(struct nfsd_net *nn)
+{
+	int ret;
+	struct cld_upcall *cup;
+	struct cld_net *cn = nn->cld_net;
+
+	cup = alloc_cld_upcall(cn);
+	if (!cup) {
+		ret = -ENOMEM;
+		goto out_err;
+	}
+
+	cup->cu_msg.cm_cmd = Cld_GraceStart;
+	ret = cld_pipe_upcall(cn->cn_pipe, &cup->cu_msg);
+	if (!ret)
+		ret = cup->cu_msg.cm_status;
+
+	free_cld_upcall(cup);
+out_err:
+	if (ret)
+		dprintk("%s: Unable to get clients from userspace: %d\n",
+			__func__, ret);
+	return ret;
+}
+
+/* For older nfsdcld's that need cm_gracetime */
 static void
-nfsd4_cld_grace_done(struct nfsd_net *nn)
+nfsd4_cld_grace_done_v0(struct nfsd_net *nn)
 {
 	int ret;
 	struct cld_upcall *cup;
@@ -1125,11 +1226,118 @@ nfsd4_cld_grace_done(struct nfsd_net *nn)
 		printk(KERN_ERR "NFSD: Unable to end grace period: %d\n", ret);
 }
 
-static const struct nfsd4_client_tracking_ops nfsd4_cld_tracking_ops = {
+/*
+ * For newer nfsdcld's that do not need cm_gracetime.  We also need to call
+ * nfs4_release_reclaim() to clear out the reclaim_str_hashtbl.
+ */
+static void
+nfsd4_cld_grace_done(struct nfsd_net *nn)
+{
+	int ret;
+	struct cld_upcall *cup;
+	struct cld_net *cn = nn->cld_net;
+
+	cup = alloc_cld_upcall(cn);
+	if (!cup) {
+		ret = -ENOMEM;
+		goto out_err;
+	}
+
+	cup->cu_msg.cm_cmd = Cld_GraceDone;
+	ret = cld_pipe_upcall(cn->cn_pipe, &cup->cu_msg);
+	if (!ret)
+		ret = cup->cu_msg.cm_status;
+
+	free_cld_upcall(cup);
+out_err:
+	nfs4_release_reclaim(nn);
+	if (ret)
+		printk(KERN_ERR "NFSD: Unable to end grace period: %d\n", ret);
+}
+
+static int
+nfs4_cld_state_init(struct net *net)
+{
+	struct nfsd_net *nn = net_generic(net, nfsd_net_id);
+	int i;
+
+	nn->reclaim_str_hashtbl = kmalloc_array(CLIENT_HASH_SIZE,
+						sizeof(struct list_head),
+						GFP_KERNEL);
+	if (!nn->reclaim_str_hashtbl)
+		return -ENOMEM;
+
+	for (i = 0; i < CLIENT_HASH_SIZE; i++)
+		INIT_LIST_HEAD(&nn->reclaim_str_hashtbl[i]);
+	nn->reclaim_str_hashtbl_size = 0;
+
+	return 0;
+}
+
+static void
+nfs4_cld_state_shutdown(struct net *net)
+{
+	struct nfsd_net *nn = net_generic(net, nfsd_net_id);
+
+	kfree(nn->reclaim_str_hashtbl);
+}
+
+static int
+nfsd4_cld_tracking_init(struct net *net)
+{
+	int status;
+	struct nfsd_net *nn = net_generic(net, nfsd_net_id);
+
+	status = nfs4_cld_state_init(net);
+	if (status)
+		return status;
+
+	status = nfsd4_init_cld_pipe(net);
+	if (status)
+		goto err_shutdown;
+
+	status = nfsd4_cld_grace_start(nn);
+	if (status) {
+		if (status == -EOPNOTSUPP)
+			printk(KERN_WARNING "NFSD: Please upgrade nfsdcld.\n");
+		nfs4_release_reclaim(nn);
+		goto err_remove;
+	}
+	return 0;
+
+err_remove:
+	nfsd4_remove_cld_pipe(net);
+err_shutdown:
+	nfs4_cld_state_shutdown(net);
+	return status;
+}
+
+static void
+nfsd4_cld_tracking_exit(struct net *net)
+{
+	struct nfsd_net *nn = net_generic(net, nfsd_net_id);
+
+	nfs4_release_reclaim(nn);
+	nfsd4_remove_cld_pipe(net);
+	nfs4_cld_state_shutdown(net);
+}
+
+/* For older nfsdcld's */
+static const struct nfsd4_client_tracking_ops nfsd4_cld_tracking_ops_v0 = {
 	.init		= nfsd4_init_cld_pipe,
 	.exit		= nfsd4_remove_cld_pipe,
 	.create		= nfsd4_cld_create,
 	.remove		= nfsd4_cld_remove,
+	.check		= nfsd4_cld_check_v0,
+	.grace_done	= nfsd4_cld_grace_done_v0,
+};
+
+/* For newer nfsdcld's */
+static const struct nfsd4_client_tracking_ops nfsd4_cld_tracking_ops = {
+	.init		= nfsd4_cld_tracking_init,
+	.exit		= nfsd4_cld_tracking_exit,
+	.create		= nfsd4_cld_create,
+	.remove		= nfsd4_cld_remove,
 	.check		= nfsd4_cld_check,
 	.grace_done	= nfsd4_cld_grace_done,
 };
@@ -1514,9 +1722,10 @@ nfsd4_client_tracking_init(struct net *net)
 
 	/* Finally, try to use nfsdcld */
 	nn->client_tracking_ops = &nfsd4_cld_tracking_ops;
-	printk(KERN_WARNING "NFSD: the nfsdcld client tracking upcall will be "
-			"removed in 3.10. Please transition to using "
-			"nfsdcltrack.\n");
+	status = nn->client_tracking_ops->init(net);
+	if (!status)
+		return status;
+	nn->client_tracking_ops = &nfsd4_cld_tracking_ops_v0;
 do_init:
 	status = nn->client_tracking_ops->init(net);
 	if (status) {
diff --git a/include/uapi/linux/nfsd/cld.h b/include/uapi/linux/nfsd/cld.h
index f8f5cccad749..b1e9de4f07d5 100644
--- a/include/uapi/linux/nfsd/cld.h
+++ b/include/uapi/linux/nfsd/cld.h
@@ -36,6 +36,7 @@ enum cld_command {
 	Cld_Remove,		/* remove record of this cm_id */
 	Cld_Check,		/* is this cm_id allowed? */
 	Cld_GraceDone,		/* grace period is complete */
+	Cld_GraceStart,
 };
 
 /* representation of long-form NFSv4 client ID */
-- 
2.17.1

