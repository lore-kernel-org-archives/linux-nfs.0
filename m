Return-Path: <SRS0=G+EE=N3=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 949E9C43441
	for <linux-nfs@archiver.kernel.org>; Fri, 16 Nov 2018 16:26:25 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 5C83D20858
	for <linux-nfs@archiver.kernel.org>; Fri, 16 Nov 2018 16:26:25 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="Z7317XCe"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5C83D20858
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S2390166AbeKQCj0 (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Fri, 16 Nov 2018 21:39:26 -0500
Received: from mail-oi1-f193.google.com ([209.85.167.193]:42600 "EHLO
        mail-oi1-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S2390089AbeKQCjZ (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 16 Nov 2018 21:39:25 -0500
Received: by mail-oi1-f193.google.com with SMTP id w13so7497780oiw.9
        for <linux-nfs@vger.kernel.org>; Fri, 16 Nov 2018 08:26:23 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id;
        bh=P/zL7Jj1RqYWYm+lRscSFr28zSag7ABaK3Xk2OJyFEE=;
        b=Z7317XCe6DFy2XJnGRGZc3YP8/Q7QdHHTfSAokLpcxQdw0wstIH5dC0HyEWBtQvplK
         PY72XMNjmYVtather2iU7epayN2LpXosMQq2v6pWwqHaYECLM24aEO56aiTlwPUcurR3
         ttCMUGhVlYSost++kduLYDzkzA9dc079YNDlcECgTfxNJKK4Oq4DdaWqO2g+CHC1UehL
         ZCzy3qU9eCEPIZzNdrHTtX96FQownltoX32HO92AB+a0ucUgd+8f7dZqiTVhccLfLp/q
         MEi7nqveeLbfSCUAsMCOM3n+/Kc8+VwdUH9ydWRbzd5JSkYEn9uQU63EJ96Ymn2woy+A
         zj+A==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:cc:subject:date:message-id;
        bh=P/zL7Jj1RqYWYm+lRscSFr28zSag7ABaK3Xk2OJyFEE=;
        b=eZWb0JuVKFXvBQx4r3KBE4wP8CYnf4F9t0kE6Vk2NSJmXJoodn5c1EkQ046DG67KT0
         pxD+lHWrCS3XMY9Z1nJvRftByAY/uGyhvYnFByxyN7/Cvt6R54QpIxAL6M2bCAURC9Es
         jOH/dnhz5meYnlJqqfLqv5ONHY14KvI5WelCHbNCF1uH/BZvZV+8U46LAqrhL7n+Al79
         LA2WH7nIhe+8aIJPR9z4es8ORiDdzqqJ9F0EISlf0Qzi0oC0Le6ndpthEDVYgfrOByrE
         8tteZgMJ+8R55NveUkUev0/eY5i4gdp9hlENvFkyS6zG1NSVyRvmdmznw7/4no041qRk
         vJtA==
X-Gm-Message-State: AGRZ1gKkEit9fU4efZkooh6Mf1zic9TZfHwZM1gngdbQJlUyI8vguoet
        ITaozqrI7r+LfjcTxFCy9Qo=
X-Google-Smtp-Source: AJdET5cLU6+VDnZY+bVqp/yF6ZBvAA+5gdEfV5MrsdjrD84JOgO74syxSPNuCyL+5rOC3OPndlhKig==
X-Received: by 2002:aca:4e11:: with SMTP id c17mr1270113oib.254.1542385582305;
        Fri, 16 Nov 2018 08:26:22 -0800 (PST)
Received: from Olgas-MBP-195.attlocal.net (172-10-226-31.lightspeed.livnmi.sbcglobal.net. [172.10.226.31])
        by smtp.gmail.com with ESMTPSA id x127sm5687155oia.20.2018.11.16.08.26.21
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 16 Nov 2018 08:26:21 -0800 (PST)
From:   Olga Kornievskaia <olga.kornievskaia@gmail.com>
To:     trond.myklebust@hammerspace.com, anna.schumaker@netapp.com
Cc:     linux-nfs@vger.kernel.org
Subject: [PATCH 1/1] NFSv4.2 do not allocate memory under the lock
Date:   Fri, 16 Nov 2018 11:26:23 -0500
Message-Id: <20181116162623.50517-1-olga.kornievskaia@gmail.com>
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
 fs/nfs/callback_proc.c | 12 ++++++------
 1 file changed, 6 insertions(+), 6 deletions(-)

diff --git a/fs/nfs/callback_proc.c b/fs/nfs/callback_proc.c
index fa515d5..f67665a 100644
--- a/fs/nfs/callback_proc.c
+++ b/fs/nfs/callback_proc.c
@@ -689,6 +689,10 @@ __be32 nfs4_callback_offload(void *data, void *dummy,
 	struct nfs4_copy_state *copy;
 	bool found = false;
 
+	copy = kzalloc(sizeof(struct nfs4_copy_state), GFP_NOFS);
+	if (!copy)
+		return htonl(NFS4ERR_SERVERFAULT);
+
 	spin_lock(&cps->clp->cl_lock);
 	rcu_read_lock();
 	list_for_each_entry_rcu(server, &cps->clp->cl_superblocks,
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

