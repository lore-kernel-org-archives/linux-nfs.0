Return-Path: <SRS0=1UK0=RC=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C0163C4360F
	for <linux-nfs@archiver.kernel.org>; Wed, 27 Feb 2019 14:52:04 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 9078320863
	for <linux-nfs@archiver.kernel.org>; Wed, 27 Feb 2019 14:52:04 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1730592AbfB0OwE (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Wed, 27 Feb 2019 09:52:04 -0500
Received: from mx3.molgen.mpg.de ([141.14.17.11]:44335 "EHLO mx1.molgen.mpg.de"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1726590AbfB0OwD (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 27 Feb 2019 09:52:03 -0500
Received: from theinternet.molgen.mpg.de (theinternet.molgen.mpg.de [141.14.31.7])
        by mx.molgen.mpg.de (Postfix) with ESMTP id 228C7604E3BC6;
        Wed, 27 Feb 2019 15:52:02 +0100 (CET)
From:   Donald Buczek <buczek@molgen.mpg.de>
To:     linux-nfs@vger.kernel.org, trond.myklebust@hammerspace.com,
        anna.schumaker@netapp.com
Cc:     Donald Buczek <buczek@molgen.mpg.de>
Subject: [PATCH 3/4] nfs4: Move nfs4_setup_state_renewal
Date:   Wed, 27 Feb 2019 15:51:29 +0100
Message-Id: <20190227145130.22323-4-buczek@molgen.mpg.de>
X-Mailer: git-send-email 2.21.0
In-Reply-To: <20190227145130.22323-1-buczek@molgen.mpg.de>
References: <20190227145130.22323-1-buczek@molgen.mpg.de>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

The function nfs4_setup_state_renewal is to be used by
nfs4_init_clientid. Move it further to the top of the source file to
include it regardles of CONFIG_NFS_V4_1 and to save a forward
declaration. No code changed.

Signed-off-by: Donald Buczek <buczek@molgen.mpg.de>
---
 fs/nfs/nfs4state.c | 42 +++++++++++++++++++++---------------------
 1 file changed, 21 insertions(+), 21 deletions(-)

diff --git a/fs/nfs/nfs4state.c b/fs/nfs/nfs4state.c
index 28863a9b705d..ba6889dcf3d6 100644
--- a/fs/nfs/nfs4state.c
+++ b/fs/nfs/nfs4state.c
@@ -87,6 +87,27 @@ const nfs4_stateid current_stateid = {
 
 static DEFINE_MUTEX(nfs_clid_init_mutex);
 
+static int nfs4_setup_state_renewal(struct nfs_client *clp)
+{
+	int status;
+	struct nfs_fsinfo fsinfo;
+	unsigned long now;
+
+	if (!test_bit(NFS_CS_CHECK_LEASE_TIME, &clp->cl_res_state)) {
+		nfs4_schedule_state_renewal(clp);
+		return 0;
+	}
+
+	now = jiffies;
+	status = nfs4_proc_get_lease_time(clp, &fsinfo);
+	if (status == 0) {
+		nfs4_set_lease_period(clp, fsinfo.lease_time * HZ, now);
+		nfs4_schedule_state_renewal(clp);
+	}
+
+	return status;
+}
+
 int nfs4_init_clientid(struct nfs_client *clp, const struct cred *cred)
 {
 	struct nfs4_setclientid_res clid = {
@@ -282,27 +303,6 @@ static int nfs4_begin_drain_session(struct nfs_client *clp)
 
 #if defined(CONFIG_NFS_V4_1)
 
-static int nfs4_setup_state_renewal(struct nfs_client *clp)
-{
-	int status;
-	struct nfs_fsinfo fsinfo;
-	unsigned long now;
-
-	if (!test_bit(NFS_CS_CHECK_LEASE_TIME, &clp->cl_res_state)) {
-		nfs4_schedule_state_renewal(clp);
-		return 0;
-	}
-
-	now = jiffies;
-	status = nfs4_proc_get_lease_time(clp, &fsinfo);
-	if (status == 0) {
-		nfs4_set_lease_period(clp, fsinfo.lease_time * HZ, now);
-		nfs4_schedule_state_renewal(clp);
-	}
-
-	return status;
-}
-
 static void nfs41_finish_session_reset(struct nfs_client *clp)
 {
 	clear_bit(NFS4CLNT_LEASE_CONFIRM, &clp->cl_state);
-- 
2.21.0

