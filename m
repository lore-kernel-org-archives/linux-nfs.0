Return-Path: <SRS0=9Ter=N7=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7772AC04EBC
	for <linux-nfs@archiver.kernel.org>; Tue, 20 Nov 2018 12:56:33 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 634E420672
	for <linux-nfs@archiver.kernel.org>; Tue, 20 Nov 2018 12:56:32 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="im9L+liS"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 634E420672
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726905AbeKTXZb (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 20 Nov 2018 18:25:31 -0500
Received: from mail-it1-f194.google.com ([209.85.166.194]:40711 "EHLO
        mail-it1-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726708AbeKTXZb (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 20 Nov 2018 18:25:31 -0500
Received: by mail-it1-f194.google.com with SMTP id h193so3286713ita.5
        for <linux-nfs@vger.kernel.org>; Tue, 20 Nov 2018 04:56:30 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:subject:date:message-id:mime-version
         :content-transfer-encoding;
        bh=znC6KuNdYD0l6gnrUlFRwyimdiYAH87h4NIRwGZO/8M=;
        b=im9L+liSp0d9bNeGozkT/9WkUBapls3h+nBZkl+/iOCuN6B3kvcFpGgYEiT2zxKTvw
         /PXD6q8z2xHkpMl5AFuIpPIn8G+NOJs/RDxFb/tpxBudvl4JDDoFQrsyVyfhZSmDEtiX
         eutAo0gtniZ1sWmlwMRnTOmPyJAPgKRkpBXJj3WZmYJTgmYZRTtQqdtCgm81mvNTAq14
         0o5oneeZ7n/iRDqNKEXRZl8pLlFQ47Ce83msbc2yKDBQLoA3bncYcCV9JDPV/fAI2SQ6
         GT0RhClxCainP36rY3n108eVZD/n74j2SZjd4sTODm2KX0AoCQWQiv15KUnmUzz8Cvxa
         V20g==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:subject:date:message-id:mime-version
         :content-transfer-encoding;
        bh=znC6KuNdYD0l6gnrUlFRwyimdiYAH87h4NIRwGZO/8M=;
        b=mrRkPU7hJZG961hRwq9TN9k4vTvLwt6ay7R6q9pXyY15QtgXGGjLwugXaj7l0wNTkE
         wrfujwq7hWMShxyLf3guv3rQ2kqHpLyMmIzo5ftxOa71TaL8EN4HVrkbRB1K5iWs4QOO
         K7YHP93Zh9nzjEdp+YcwcVfxqxAox0zF9yI2PIAp3VVeN80o943Tpi8qGV5AV+FGv0Ed
         rcvr9RasCgwijk8RuWM/mjOUIjCxUawMgGqnRW+7W7d5LcnW/HyOVInEnCxsvxU0r506
         /YTD+Ku/8/ZphS8l/7ANLSPXi7AYaPiWI8xTfcgMvwMT8vofyurGqd6F9F1b2nD6NDO/
         dRKA==
X-Gm-Message-State: AA+aEWYdBOxiySomVtwE9Lzgd7iJ83wUZZ+Suo5Lb29Pp4CeItDl4hi6
        CWFiwjyVdYCf19sQ+Z5xQUGUmjU=
X-Google-Smtp-Source: AFSGD/VuGCWf0S2z8yy8hqyPKrjMv7BuzUPci0Ey5iBHp1zqMCP6OKmJ2qByFX3OWoOnVng7M44vpA==
X-Received: by 2002:a24:6bd3:: with SMTP id v202-v6mr1942330itc.165.1542718589801;
        Tue, 20 Nov 2018 04:56:29 -0800 (PST)
Received: from localhost.localdomain (c-68-40-195-73.hsd1.mi.comcast.net. [68.40.195.73])
        by smtp.gmail.com with ESMTPSA id c2sm4535831ioh.29.2018.11.20.04.56.28
        for <linux-nfs@vger.kernel.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 20 Nov 2018 04:56:29 -0800 (PST)
From:   Trond Myklebust <trondmy@gmail.com>
X-Google-Original-From: Trond Myklebust <trond.myklebust@hammerspace.com>
To:     linux-nfs@vger.kernel.org
Subject: [PATCH] NFSv4: Fix a NFSv4 state manager deadlock
Date:   Tue, 20 Nov 2018 07:55:22 -0500
Message-Id: <20181120125522.56087-1-trond.myklebust@hammerspace.com>
X-Mailer: git-send-email 2.19.1
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Fix a deadlock whereby the NFSv4 state manager can get stuck in the
delegation return code, waiting for a layout return to complete in
another thread. If the server reboots before that other thread
completes, then we need to be able to start a second state
manager thread in order to perform recovery.

Signed-off-by: Trond Myklebust <trond.myklebust@hammerspace.com>
---
 fs/nfs/nfs4_fs.h   |  2 ++
 fs/nfs/nfs4state.c | 16 +++++++++++-----
 2 files changed, 13 insertions(+), 5 deletions(-)

diff --git a/fs/nfs/nfs4_fs.h b/fs/nfs/nfs4_fs.h
index 8d59c9655ec4..1b994b527518 100644
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
index ffea57885394..d8decf2ec48f 100644
--- a/fs/nfs/nfs4state.c
+++ b/fs/nfs/nfs4state.c
@@ -1210,6 +1210,7 @@ void nfs4_schedule_state_manager(struct nfs_client *clp)
 	struct task_struct *task;
 	char buf[INET6_ADDRSTRLEN + sizeof("-manager") + 1];
 
+	set_bit(NFS4CLNT_RUN_MANAGER, &clp->cl_state);
 	if (test_and_set_bit(NFS4CLNT_MANAGER_RUNNING, &clp->cl_state) != 0)
 		return;
 	__module_get(THIS_MODULE);
@@ -2503,6 +2504,7 @@ static void nfs4_state_manager(struct nfs_client *clp)
 
 	/* Ensure exclusive access to NFSv4 state */
 	do {
+		clear_bit(NFS4CLNT_RUN_MANAGER, &clp->cl_state);
 		if (test_bit(NFS4CLNT_PURGE_STATE, &clp->cl_state)) {
 			section = "purge state";
 			status = nfs4_purge_lease(clp);
@@ -2593,14 +2595,18 @@ static void nfs4_state_manager(struct nfs_client *clp)
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
2.19.1

