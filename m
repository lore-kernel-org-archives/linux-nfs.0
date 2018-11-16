Return-Path: <SRS0=G+EE=N3=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E39DDC43441
	for <linux-nfs@archiver.kernel.org>; Fri, 16 Nov 2018 16:47:18 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id AB23D2086A
	for <linux-nfs@archiver.kernel.org>; Fri, 16 Nov 2018 16:47:18 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="l6LBhH5Q"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org AB23D2086A
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1729036AbeKQDAY (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Fri, 16 Nov 2018 22:00:24 -0500
Received: from mail-oi1-f196.google.com ([209.85.167.196]:46681 "EHLO
        mail-oi1-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1728684AbeKQDAY (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 16 Nov 2018 22:00:24 -0500
Received: by mail-oi1-f196.google.com with SMTP id x202so8743739oif.13
        for <linux-nfs@vger.kernel.org>; Fri, 16 Nov 2018 08:47:17 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id;
        bh=TlfQf5F5tIj+4OFCYOTCzYvSv6sQaVjis+B3G7oFlWs=;
        b=l6LBhH5Qyi/urPryckf+vxzdWC1a+z7R7jAHeYY3nuAHE8RZBjThs4mWqV2kS1f3fv
         v0Daj0K5+O01U9oV9S6NR80vDuXHXa9RTYOOml57MuqqQslkk6gIiTZ7jSWmvLer6W/W
         Ct7ULT/rgZb9QdMRPpVEtiges0O3coeH4nc/hS4XKZGLOhZlrRbmcjsbeSmCuY0xn1p0
         IRaKXRat5BXblNsYxNNdUB16x4MUgPYM3ZZXXe1P2p8xiTSSEJVthsuykwdNl7VbcwXp
         XpA1Rli8f6ozFDSp6dG5Trx4KBIHMglMiDf7ePz86qO926mUoMgSyezszvwmAsBRjU6X
         8UzA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:cc:subject:date:message-id;
        bh=TlfQf5F5tIj+4OFCYOTCzYvSv6sQaVjis+B3G7oFlWs=;
        b=c4hZHm/fYO07hn7h5n1Y99VVVkKucrdahGLY/P2dI0bHHLDKQL71ctoi5az0J2Ej4s
         5tNgie0emcCB0ZvB9i+I9zWE3W+Na4GlJ/3cpnVQqQOOFDlzaf+Bzg9Z6/rGcfknQhTd
         gWTkqaDHGqtOaxAACXca9J4rMaYMDjxpqh8D7JiCIC/MXo4hMY2YtIjTgwtCNoxjTcZn
         Frr2vWq2jqp+P7Vz4mCDshk+mAeRwAjT7W+8fzZAj1b0qF9l47jyZSLzXItm9swzX0tq
         Ya5BldLJ3b5dedL5fG+7gcRakx36H7dylPDd/LW+TorSochk26+cRYVivUo3zZW8hTem
         F4xw==
X-Gm-Message-State: AGRZ1gIDoxUD+9DxRGszlS9xmGu7mZjz+ycaMlpZGLgYEi+tVQ/HqCkJ
        PjOyHJdwVXDkomMlKNf/DwLHlSRb
X-Google-Smtp-Source: AJdET5cWmkoCF4aysDwT4B0KASScmbFFCC9yUb+7o8If2BGS6Sy0UP8szfzgnfGT8bSYXpvuFO4NuQ==
X-Received: by 2002:a54:418a:: with SMTP id 10mr1476832oiy.128.1542386836597;
        Fri, 16 Nov 2018 08:47:16 -0800 (PST)
Received: from Olgas-MBP-195.attlocal.net (172-10-226-31.lightspeed.livnmi.sbcglobal.net. [172.10.226.31])
        by smtp.gmail.com with ESMTPSA id e24sm13101402otd.63.2018.11.16.08.47.15
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 16 Nov 2018 08:47:15 -0800 (PST)
From:   Olga Kornievskaia <olga.kornievskaia@gmail.com>
To:     trond.myklebust@hammerspace.com, anna.schumaker@netapp.com
Cc:     linux-nfs@vger.kernel.org
Subject: [PATCH v2 1/1] NFSv4.2 do not allocate memory under the lock
Date:   Fri, 16 Nov 2018 11:47:17 -0500
Message-Id: <20181116164717.50576-1-olga.kornievskaia@gmail.com>
X-Mailer: git-send-email 2.10.1 (Apple Git-78)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

From: Olga Kornievskaia <kolga@netapp.com>

Bruce pointed out that we shouldn't allocate memory while holding
a lock.

Signed-off-by: Olga Kornievskaia <kolga@netapp.com>
---
 fs/nfs/callback_proc.c | 22 +++++++++++-----------
 1 file changed, 11 insertions(+), 11 deletions(-)

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
-- 
1.8.3.1

