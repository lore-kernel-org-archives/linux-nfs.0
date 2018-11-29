Return-Path: <SRS0=NEh4=OI=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-10.6 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id AFB96C43441
	for <linux-nfs@archiver.kernel.org>; Thu, 29 Nov 2018 06:00:25 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 76B7D21019
	for <linux-nfs@archiver.kernel.org>; Thu, 29 Nov 2018 06:00:25 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="nkTA1MbK"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 76B7D21019
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1729153AbeK2REe (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Thu, 29 Nov 2018 12:04:34 -0500
Received: from mail.kernel.org ([198.145.29.99]:39352 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1727570AbeK2REe (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 29 Nov 2018 12:04:34 -0500
Received: from sasha-vm.mshome.net (unknown [37.142.5.207])
        (using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
        (No client certificate requested)
        by mail.kernel.org (Postfix) with ESMTPSA id 0D93521019;
        Thu, 29 Nov 2018 06:00:20 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
        s=default; t=1543471222;
        bh=jShrKi/vfZk7+GEJ3ieV2aPWemz8lwSxKzFX/4eulcU=;
        h=From:To:Cc:Subject:Date:In-Reply-To:References:From;
        b=nkTA1MbKhcVILII5ylCIox1KS2AFF9WYsEQMZhSm6xPLKmYXuZ12IpFiWscHybO/K
         4tQNmss4b1wfwrPEfj4CiVgzIjLFKqLKoQUdHJEXTroUzXMqCs78vRExKswNZBzeJ5
         ZRnOqqHZyWDUENtZMBdpln4ypDZf7rZv7gVY0jUk=
From:   Sasha Levin <sashal@kernel.org>
To:     stable@vger.kernel.org, linux-kernel@vger.kernel.org
Cc:     Olga Kornievskaia <kolga@netapp.com>,
        Trond Myklebust <trond.myklebust@hammerspace.com>,
        Sasha Levin <sashal@kernel.org>, linux-nfs@vger.kernel.org
Subject: [PATCH AUTOSEL 4.19 57/68] NFSv4.2 copy do not allocate memory under the lock
Date:   Thu, 29 Nov 2018 00:55:48 -0500
Message-Id: <20181129055559.159228-57-sashal@kernel.org>
X-Mailer: git-send-email 2.17.1
In-Reply-To: <20181129055559.159228-1-sashal@kernel.org>
References: <20181129055559.159228-1-sashal@kernel.org>
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

From: Olga Kornievskaia <kolga@netapp.com>

[ Upstream commit 99f2c55591fb5c1b536263970d98c2ebc2089906 ]

Bruce pointed out that we shouldn't allocate memory while holding
a lock in the nfs4_callback_offload() and handle_async_copy()
that deal with a racing CB_OFFLOAD and reply to COPY case.

Signed-off-by: Olga Kornievskaia <kolga@netapp.com>
Signed-off-by: Trond Myklebust <trond.myklebust@hammerspace.com>
Signed-off-by: Sasha Levin <sashal@kernel.org>
---
 fs/nfs/callback_proc.c | 22 +++++++++++-----------
 fs/nfs/nfs42proc.c     | 19 ++++++++++---------
 2 files changed, 21 insertions(+), 20 deletions(-)

diff --git a/fs/nfs/callback_proc.c b/fs/nfs/callback_proc.c
index fa515d5ea5ba..48b2e9063b0a 100644
--- a/fs/nfs/callback_proc.c
+++ b/fs/nfs/callback_proc.c
@@ -686,20 +686,24 @@ __be32 nfs4_callback_offload(void *data, void *dummy,
 {
 	struct cb_offloadargs *args = data;
 	struct nfs_server *server;
-	struct nfs4_copy_state *copy;
+	struct nfs4_copy_state *copy, *tmp_copy;
 	bool found = false;
 
+	copy = kzalloc(sizeof(struct nfs4_copy_state), GFP_NOFS);
+	if (!copy)
+		return htonl(NFS4ERR_SERVERFAULT);
+
 	spin_lock(&cps->clp->cl_lock);
 	rcu_read_lock();
 	list_for_each_entry_rcu(server, &cps->clp->cl_superblocks,
 				client_link) {
-		list_for_each_entry(copy, &server->ss_copies, copies) {
+		list_for_each_entry(tmp_copy, &server->ss_copies, copies) {
 			if (memcmp(args->coa_stateid.other,
-					copy->stateid.other,
+					tmp_copy->stateid.other,
 					sizeof(args->coa_stateid.other)))
 				continue;
-			nfs4_copy_cb_args(copy, args);
-			complete(&copy->completion);
+			nfs4_copy_cb_args(tmp_copy, args);
+			complete(&tmp_copy->completion);
 			found = true;
 			goto out;
 		}
@@ -707,15 +711,11 @@ __be32 nfs4_callback_offload(void *data, void *dummy,
 out:
 	rcu_read_unlock();
 	if (!found) {
-		copy = kzalloc(sizeof(struct nfs4_copy_state), GFP_NOFS);
-		if (!copy) {
-			spin_unlock(&cps->clp->cl_lock);
-			return htonl(NFS4ERR_SERVERFAULT);
-		}
 		memcpy(&copy->stateid, &args->coa_stateid, NFS4_STATEID_SIZE);
 		nfs4_copy_cb_args(copy, args);
 		list_add_tail(&copy->copies, &cps->clp->pending_cb_stateids);
-	}
+	} else
+		kfree(copy);
 	spin_unlock(&cps->clp->cl_lock);
 
 	return 0;
diff --git a/fs/nfs/nfs42proc.c b/fs/nfs/nfs42proc.c
index ac5b784a1de0..fed06fd9998d 100644
--- a/fs/nfs/nfs42proc.c
+++ b/fs/nfs/nfs42proc.c
@@ -137,31 +137,32 @@ static int handle_async_copy(struct nfs42_copy_res *res,
 			     struct file *dst,
 			     nfs4_stateid *src_stateid)
 {
-	struct nfs4_copy_state *copy;
+	struct nfs4_copy_state *copy, *tmp_copy;
 	int status = NFS4_OK;
 	bool found_pending = false;
 	struct nfs_open_context *ctx = nfs_file_open_context(dst);
 
+	copy = kzalloc(sizeof(struct nfs4_copy_state), GFP_NOFS);
+	if (!copy)
+		return -ENOMEM;
+
 	spin_lock(&server->nfs_client->cl_lock);
-	list_for_each_entry(copy, &server->nfs_client->pending_cb_stateids,
+	list_for_each_entry(tmp_copy, &server->nfs_client->pending_cb_stateids,
 				copies) {
-		if (memcmp(&res->write_res.stateid, &copy->stateid,
+		if (memcmp(&res->write_res.stateid, &tmp_copy->stateid,
 				NFS4_STATEID_SIZE))
 			continue;
 		found_pending = true;
-		list_del(&copy->copies);
+		list_del(&tmp_copy->copies);
 		break;
 	}
 	if (found_pending) {
 		spin_unlock(&server->nfs_client->cl_lock);
+		kfree(copy);
+		copy = tmp_copy;
 		goto out;
 	}
 
-	copy = kzalloc(sizeof(struct nfs4_copy_state), GFP_NOFS);
-	if (!copy) {
-		spin_unlock(&server->nfs_client->cl_lock);
-		return -ENOMEM;
-	}
 	memcpy(&copy->stateid, &res->write_res.stateid, NFS4_STATEID_SIZE);
 	init_completion(&copy->completion);
 	copy->parent_state = ctx->state;
-- 
2.17.1

