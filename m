Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:59897 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1752264Ab1CWJ4D (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 23 Mar 2011 05:56:03 -0400
Message-ID: <4D89C3F3.9020505@cn.fujitsu.com>
Date: Wed, 23 Mar 2011 17:57:07 +0800
From: Mi Jinlong <mijinlong@cn.fujitsu.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: NFS <linux-nfs@vger.kernel.org>
Subject: nfsd41: add flag checking for create_session
Content-Type: text/plain; charset=ISO-2022-JP
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

At the latest kernel, NFS server doesn't check create_session 
operation's falg.

This patch add flag mask and check flag for create_session
 as exchang_id. Also, make some adjustment for align.

Signed-off-by: Mi Jinlong <mijinlong@cn.fujitsu.com>
---
 fs/nfsd/nfs4state.c  |    3 +++
 include/linux/nfs4.h |    8 +++++---
 2 files changed, 8 insertions(+), 3 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 7b566ec..1f66370 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -1514,6 +1514,9 @@ nfsd4_create_session(struct svc_rqst *rqstp,
 	bool confirm_me = false;
 	int status = 0;
 
+	if (cr_ses->flags & ~SESSION4_FLAG_MASK_A)
+		return nfserr_inval;
+
 	nfs4_lock_state();
 	unconf = find_unconfirmed_client(&cr_ses->clientid);
 	conf = find_confirmed_client(&cr_ses->clientid);
diff --git a/include/linux/nfs4.h b/include/linux/nfs4.h
index 134716e..e064895 100644
--- a/include/linux/nfs4.h
+++ b/include/linux/nfs4.h
@@ -568,9 +568,11 @@ struct nfs4_sessionid {
 };
 
 /* Create Session Flags */
-#define SESSION4_PERSIST	 0x001
-#define SESSION4_BACK_CHAN 	 0x002
-#define SESSION4_RDMA		 0x004
+#define SESSION4_PERSIST	0x001
+#define SESSION4_BACK_CHAN	0x002
+#define SESSION4_RDMA		0x004
+
+#define SESSION4_FLAG_MASK_A	0x007
 
 enum state_protect_how4 {
 	SP4_NONE	= 0,
-- 
1.7.4.1


