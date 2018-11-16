Return-Path: <SRS0=G+EE=N3=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 71378C43441
	for <linux-nfs@archiver.kernel.org>; Fri, 16 Nov 2018 19:01:52 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 348CE20854
	for <linux-nfs@archiver.kernel.org>; Fri, 16 Nov 2018 19:01:52 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="ex+GnK0L"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 348CE20854
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1725763AbeKQFP0 (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Sat, 17 Nov 2018 00:15:26 -0500
Received: from mail-oi1-f194.google.com ([209.85.167.194]:32903 "EHLO
        mail-oi1-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1725729AbeKQFP0 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sat, 17 Nov 2018 00:15:26 -0500
Received: by mail-oi1-f194.google.com with SMTP id c206so14953972oib.0
        for <linux-nfs@vger.kernel.org>; Fri, 16 Nov 2018 11:01:50 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id;
        bh=1ntAgzpY8U0isj0TMIULGtlBvDsXUKhuUqU3yIlu7RA=;
        b=ex+GnK0L4C7jSdTbD3nYWC+T9rPMJ0Domti+MLMJxMdiW3gNzzvjmPacaaKLPaV8O8
         5J+Np7dWHgJTHH0ONqQdcbiOukP3MiiPGNt+TWTH7nDwW8cReeG20wDrJRE9gdJze8sk
         +BLjUJribL6vBZ5kQrQviF8t5o2+w8Ov5RHWX3TMvxOqPgPILGzkLmGQ5YnnHX3wNGp8
         GfqFr6mEtTBmWDyq3kjZT8v8ilN6cQ/gyxhL4hmhRKCqfy6Zx3qcJxLQmU/5ApiLbWk2
         PIc7DAi8Nl9rvIVLpEWrPLRmTo9C5BLCxcXwI4AagLEwhs5nEVyhG0IRYIALCp0dHNsO
         usCQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:cc:subject:date:message-id;
        bh=1ntAgzpY8U0isj0TMIULGtlBvDsXUKhuUqU3yIlu7RA=;
        b=gAmGZJ13vTunHUL4bre2fv9PJ40xIrX9+08THkgI6jZd1gBT5avTEr5UQxVbnro4eh
         /Ego/HTziOuKfoRulRBAbT3yF/+Ddbi6wJrJEAnaiSr1Xpk/wytB5oW2oVnR3ZaOslYA
         pRJOfmnD3k3bu3SjidBJ1AUBcyikIh4PFxq8aELAFcXdAN1lLSlPAElTwbH3cE80WNeS
         h9rBNTce77yy+77gLzsDfq3uHIl1Wk/teYu7u2hHzMBgmEuT+UnO+KvF5RSbJ+pddS+f
         lHnnW/7m7WweiJ4qBDHmRijZmpEq8JNEOKU5J/1qeRkYzVKNmAsjIehZcP3MW8lL3fgf
         A+yg==
X-Gm-Message-State: AGRZ1gJS5Uriotyj4UQzFIG4PSPCASRNCrX8brxtcEmG4QWzgBxXrOp8
        PEJjub8F54lGHC1l2fw9YQsAwDyM
X-Google-Smtp-Source: AJdET5c0S5TNZObe0eYyw3yOz99X7nX1KZ7kKM1oEAE1a7ud1NHAh355kN2NLxV3swzwI2Brd9PGSw==
X-Received: by 2002:aca:ea57:: with SMTP id i84-v6mr1548091oih.133.1542394910153;
        Fri, 16 Nov 2018 11:01:50 -0800 (PST)
Received: from Olgas-MBP-195.attlocal.net (172-10-226-31.lightspeed.livnmi.sbcglobal.net. [172.10.226.31])
        by smtp.gmail.com with ESMTPSA id r1sm1005430oie.44.2018.11.16.11.01.48
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 16 Nov 2018 11:01:49 -0800 (PST)
From:   Olga Kornievskaia <olga.kornievskaia@gmail.com>
To:     trond.myklebust@hammerspace.com, anna.schumaker@netapp.com
Cc:     linux-nfs@vger.kernel.org
Subject: [PATCH v3 1/1] NFSv4.2 COPY do not allocate memory under the lock
Date:   Fri, 16 Nov 2018 14:01:51 -0500
Message-Id: <20181116190151.50707-1-olga.kornievskaia@gmail.com>
X-Mailer: git-send-email 2.10.1 (Apple Git-78)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

From: Olga Kornievskaia <kolga@netapp.com>

Bruce pointed out that we shouldn't allocate memory while holding
a lock in the nfs4_callback_offload() and handle_async_copy()
that deal with a racing CB_OFFLOAD and reply to COPY case.

Signed-off-by: Olga Kornievskaia <kolga@netapp.com>
---
 fs/nfs/callback_proc.c | 22 +++++++++++-----------
 fs/nfs/nfs42proc.c     | 21 ++++++++++++---------
 2 files changed, 23 insertions(+), 20 deletions(-)

diff --git a/fs/nfs/callback_proc.c b/fs/nfs/callback_proc.c
index fa515d5..48b2e90 100644
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
index c7c2ffa..7f2b716 100644
--- a/fs/nfs/nfs42proc.c
+++ b/fs/nfs/nfs42proc.c
@@ -158,31 +158,34 @@ static int handle_async_copy(struct nfs42_copy_res *res,
 			     struct file *dst,
 			     nfs4_stateid *src_stateid)
 {
-	struct nfs4_copy_state *copy;
+	struct nfs4_copy_state *copy, *tmp_copy;
 	int status = NFS4_OK;
 	bool found_pending = false;
 	struct nfs_open_context *ctx = nfs_file_open_context(dst);
 
+	copy = kzalloc(sizeof(struct nfs4_copy_state), GFP_NOFS);
+	if (!copy) {
+		spin_unlock(&server->nfs_client->cl_lock);
+		return -ENOMEM;
+	}
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
1.8.3.1

