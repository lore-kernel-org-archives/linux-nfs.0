Return-Path: <SRS0=L7au=UT=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 29CF7C43613
	for <linux-nfs@archiver.kernel.org>; Thu, 20 Jun 2019 14:51:22 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id F21672083B
	for <linux-nfs@archiver.kernel.org>; Thu, 20 Jun 2019 14:51:21 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726760AbfFTOvV (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Thu, 20 Jun 2019 10:51:21 -0400
Received: from fieldses.org ([173.255.197.46]:43434 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1726661AbfFTOvV (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 20 Jun 2019 10:51:21 -0400
Received: by fieldses.org (Postfix, from userid 2815)
        id EAF371E3B; Thu, 20 Jun 2019 10:51:20 -0400 (EDT)
From:   "J. Bruce Fields" <bfields@redhat.com>
To:     linux-nfs@vger.kernel.org
Cc:     "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 01/16] nfsd: persist nfsd filesystem across mounts
Date:   Thu, 20 Jun 2019 10:51:00 -0400
Message-Id: <1561042275-12723-2-git-send-email-bfields@redhat.com>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1561042275-12723-1-git-send-email-bfields@redhat.com>
References: <1561042275-12723-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

From: "J. Bruce Fields" <bfields@redhat.com>

Keep around one internal mount of the nfsd filesystem so that we can add
stuff to it when clients come and go, regardless of whether anyone has
it mounted.

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/nfsd/netns.h  |  3 +++
 fs/nfsd/nfsctl.c | 13 +++++++++++++
 2 files changed, 16 insertions(+)

diff --git a/fs/nfsd/netns.h b/fs/nfsd/netns.h
index 789abc4dd1d2..e7890e87d30b 100644
--- a/fs/nfsd/netns.h
+++ b/fs/nfsd/netns.h
@@ -55,6 +55,9 @@ struct nfsd_net {
 	bool grace_ended;
 	time_t boot_time;
 
+	/* internal mount of the "nfsd" pseudofilesystem: */
+	struct vfsmount *nfsd_mnt;
+
 	/*
 	 * reclaim_str_hashtbl[] holds known client info from previous reset/reboot
 	 * used in reboot/reset lease grace period processing
diff --git a/fs/nfsd/nfsctl.c b/fs/nfsd/nfsctl.c
index 90972e1fd785..ab1fb81b7f5e 100644
--- a/fs/nfsd/nfsctl.c
+++ b/fs/nfsd/nfsctl.c
@@ -1231,6 +1231,7 @@ unsigned int nfsd_net_id;
 static __net_init int nfsd_init_net(struct net *net)
 {
 	int retval;
+	struct vfsmount *mnt;
 	struct nfsd_net *nn = net_generic(net, nfsd_net_id);
 
 	retval = nfsd_export_init(net);
@@ -1251,8 +1252,17 @@ static __net_init int nfsd_init_net(struct net *net)
 
 	atomic_set(&nn->ntf_refcnt, 0);
 	init_waitqueue_head(&nn->ntf_wq);
+
+	mnt =  vfs_kern_mount(&nfsd_fs_type, SB_KERNMOUNT, "nfsd", NULL);
+	if (IS_ERR(mnt)) {
+		retval = PTR_ERR(mnt);
+		goto out_mount_err;
+	}
+	nn->nfsd_mnt = mnt;
 	return 0;
 
+out_mount_err:
+	nfsd_idmap_shutdown(net);
 out_idmap_error:
 	nfsd_export_shutdown(net);
 out_export_error:
@@ -1261,6 +1271,9 @@ static __net_init int nfsd_init_net(struct net *net)
 
 static __net_exit void nfsd_exit_net(struct net *net)
 {
+	struct nfsd_net *nn = net_generic(net, nfsd_net_id);
+
+	mntput(nn->nfsd_mnt);
 	nfsd_idmap_shutdown(net);
 	nfsd_export_shutdown(net);
 	nfsd_netns_free_versions(net_generic(net, nfsd_net_id));
-- 
2.21.0

