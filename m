Return-Path: <SRS0=NEh4=OI=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-10.6 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,USER_AGENT_GIT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id EACCDC43441
	for <linux-nfs@archiver.kernel.org>; Thu, 29 Nov 2018 06:12:16 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id AF2C02081C
	for <linux-nfs@archiver.kernel.org>; Thu, 29 Nov 2018 06:12:16 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="HrYHqPnv"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org AF2C02081C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1727535AbeK2RDw (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Thu, 29 Nov 2018 12:03:52 -0500
Received: from mail.kernel.org ([198.145.29.99]:38210 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1728107AbeK2RDw (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 29 Nov 2018 12:03:52 -0500
Received: from sasha-vm.mshome.net (unknown [37.142.5.207])
        (using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
        (No client certificate requested)
        by mail.kernel.org (Postfix) with ESMTPSA id 05708208E7;
        Thu, 29 Nov 2018 05:59:38 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
        s=default; t=1543471181;
        bh=XZIMpldLM58zbtDq4L6xLhMKLPBlcBIuG/V0QQiwxFY=;
        h=From:To:Cc:Subject:Date:In-Reply-To:References:From;
        b=HrYHqPnvgZjDTqMkWU2e7SYBevvDgvipGP/lz6Ue+rrM3fiRFOOxbI53xc21em+ug
         pyTzb5wUKcCU0LwnRtjKPyV+mj1ELkrl53SNctb+pG4b6ZEPiOYqrjhahBhkTq+2Mt
         a2QzYbuoTJ/d328JonSpunUIGfINvs8y3jWoIj1c=
From:   Sasha Levin <sashal@kernel.org>
To:     stable@vger.kernel.org, linux-kernel@vger.kernel.org
Cc:     Trond Myklebust <trond.myklebust@hammerspace.com>,
        Sasha Levin <sashal@kernel.org>, linux-nfs@vger.kernel.org
Subject: [PATCH AUTOSEL 4.19 46/68] NFSv4: Fix a NFSv4 state manager deadlock
Date:   Thu, 29 Nov 2018 00:55:37 -0500
Message-Id: <20181129055559.159228-46-sashal@kernel.org>
X-Mailer: git-send-email 2.17.1
In-Reply-To: <20181129055559.159228-1-sashal@kernel.org>
References: <20181129055559.159228-1-sashal@kernel.org>
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

From: Trond Myklebust <trond.myklebust@hammerspace.com>

[ Upstream commit aeabb3c96186a0f944fc2b1f25c84d5eb3a93fa9 ]

Fix a deadlock whereby the NFSv4 state manager can get stuck in the
delegation return code, waiting for a layout return to complete in
another thread. If the server reboots before that other thread
completes, then we need to be able to start a second state
manager thread in order to perform recovery.

Signed-off-by: Trond Myklebust <trond.myklebust@hammerspace.com>
Signed-off-by: Sasha Levin <sashal@kernel.org>
---
 fs/nfs/nfs4_fs.h   |  2 ++
 fs/nfs/nfs4state.c | 16 +++++++++++-----
 2 files changed, 13 insertions(+), 5 deletions(-)

diff --git a/fs/nfs/nfs4_fs.h b/fs/nfs/nfs4_fs.h
index 3a6904173214..63287d911c08 100644
--- a/fs/nfs/nfs4_fs.h
+++ b/fs/nfs/nfs4_fs.h
@@ -41,6 +41,8 @@ enum nfs4_client_state {
 	NFS4CLNT_MOVED,
 	NFS4CLNT_LEASE_MOVED,
 	NFS4CLNT_DELEGATION_EXPIRED,
+	NFS4CLNT_RUN_MANAGER,
+	NFS4CLNT_DELEGRETURN_RUNNING,
 };
 
 #define NFS4_RENEW_TIMEOUT		0x01
diff --git a/fs/nfs/nfs4state.c b/fs/nfs/nfs4state.c
index 18920152da14..d2f645d34eb1 100644
--- a/fs/nfs/nfs4state.c
+++ b/fs/nfs/nfs4state.c
@@ -1210,6 +1210,7 @@ void nfs4_schedule_state_manager(struct nfs_client *clp)
 	struct task_struct *task;
 	char buf[INET6_ADDRSTRLEN + sizeof("-manager") + 1];
 
+	set_bit(NFS4CLNT_RUN_MANAGER, &clp->cl_state);
 	if (test_and_set_bit(NFS4CLNT_MANAGER_RUNNING, &clp->cl_state) != 0)
 		return;
 	__module_get(THIS_MODULE);
@@ -2485,6 +2486,7 @@ static void nfs4_state_manager(struct nfs_client *clp)
 
 	/* Ensure exclusive access to NFSv4 state */
 	do {
+		clear_bit(NFS4CLNT_RUN_MANAGER, &clp->cl_state);
 		if (test_bit(NFS4CLNT_PURGE_STATE, &clp->cl_state)) {
 			section = "purge state";
 			status = nfs4_purge_lease(clp);
@@ -2575,14 +2577,18 @@ static void nfs4_state_manager(struct nfs_client *clp)
 		}
 
 		nfs4_end_drain_session(clp);
-		if (test_and_clear_bit(NFS4CLNT_DELEGRETURN, &clp->cl_state)) {
-			nfs_client_return_marked_delegations(clp);
-			continue;
+		nfs4_clear_state_manager_bit(clp);
+
+		if (!test_and_set_bit(NFS4CLNT_DELEGRETURN_RUNNING, &clp->cl_state)) {
+			if (test_and_clear_bit(NFS4CLNT_DELEGRETURN, &clp->cl_state)) {
+				nfs_client_return_marked_delegations(clp);
+				set_bit(NFS4CLNT_RUN_MANAGER, &clp->cl_state);
+			}
+			clear_bit(NFS4CLNT_DELEGRETURN_RUNNING, &clp->cl_state);
 		}
 
-		nfs4_clear_state_manager_bit(clp);
 		/* Did we race with an attempt to give us more work? */
-		if (clp->cl_state == 0)
+		if (!test_bit(NFS4CLNT_RUN_MANAGER, &clp->cl_state))
 			return;
 		if (test_and_set_bit(NFS4CLNT_MANAGER_RUNNING, &clp->cl_state) != 0)
 			return;
-- 
2.17.1

