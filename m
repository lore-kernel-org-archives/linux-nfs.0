Return-Path: <SRS0=cCtV=Q2=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D73A9C43381
	for <linux-nfs@archiver.kernel.org>; Tue, 19 Feb 2019 13:55:21 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id A7DD82147A
	for <linux-nfs@archiver.kernel.org>; Tue, 19 Feb 2019 13:55:21 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="uAiMza9P"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1728747AbfBSNzV (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 19 Feb 2019 08:55:21 -0500
Received: from mail-it1-f193.google.com ([209.85.166.193]:38224 "EHLO
        mail-it1-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1725767AbfBSNzU (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 19 Feb 2019 08:55:20 -0500
Received: by mail-it1-f193.google.com with SMTP id l66so6278822itg.3
        for <linux-nfs@vger.kernel.org>; Tue, 19 Feb 2019 05:55:20 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=S9TeiVgJ4B+Hml1DYTi2onMTx8ja6DrHTQtFR1E2UE4=;
        b=uAiMza9PcxQjtlkfMkQ/J4c2AAK+kZYg7iFzc3qJfQZuZfzkbejlc9lFuqh8/pSvoQ
         Zz7y00awQ338JNy1QiSjExvspNOr58z4BuR7jx9IENsctuzSfiZs30Kxsugq9HFSHwwy
         VWAewZR7mRocOSL6k8VoAODBw/3S4ztjsrxR8KRpccSeziJirnf1Rt1X3HRtsyC114e2
         sI+F2hDtP08JvdGHPCH2MOWH7tuGTDBdIM2qEwDUG5pZMQKMu5lX8rT6MeRwm4aM4gis
         Ttq2a3ITRCZPkqmE44AcB0YTSR5i6HFU41EbWAtxfksyIaEUZzOq40MU/cC7MIwgGkNN
         kWbw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:subject:date:message-id:in-reply-to
         :references:mime-version:content-transfer-encoding;
        bh=S9TeiVgJ4B+Hml1DYTi2onMTx8ja6DrHTQtFR1E2UE4=;
        b=X/aTrH9HMdY+MtjMwEK2lF7JvNOibl4NpSnoNr/gECM0W8m2jPPcBYkt4WlSFSngMY
         00bvGwRwuuSgAWsvzLtWIZhWoF7SCCzU3yZohX7L+w3WH+Y5cPMgAY/510n0jONd2Lkk
         qDy/e3cI8KkKWd6hSGpuk6XsOCEpeG3H3Z6TXikrvYBIvfvtSwHAQYhjmeFL9+eKtOwr
         y/+yBTgq57br2bbRjfQEWijvXxQCOv/Sj5fWiara70XzwAds6uGXivyLRZ8ddeOjQ1M/
         5okH56fN4HYl7yVzWSnIBOO5lkvWPjVU18Kkt1Z75p4pUQDWsyukadJJ0j9K5iyS07lh
         onNA==
X-Gm-Message-State: AHQUAubqxYPh0jlpBShVzPG4c0sMSFz3wA7BXua/ui8OX9oLmZKHpgxR
        HglVyJWj+8PTnRxHpIuwDmHRls0=
X-Google-Smtp-Source: AHgI3IZ95xuJsyzjsQPqc9x0lyj4IDqJI7GoV66/3zgBjUjgN4mbP1zk2/IsxdmBc+ke4/r14VNXow==
X-Received: by 2002:a6b:641a:: with SMTP id t26mr15421133iog.204.1550584519259;
        Tue, 19 Feb 2019 05:55:19 -0800 (PST)
Received: from localhost.localdomain (c-68-40-189-247.hsd1.mi.comcast.net. [68.40.189.247])
        by smtp.gmail.com with ESMTPSA id c133sm1196313itc.24.2019.02.19.05.55.18
        for <linux-nfs@vger.kernel.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 19 Feb 2019 05:55:18 -0800 (PST)
From:   Trond Myklebust <trondmy@gmail.com>
X-Google-Original-From: Trond Myklebust <trond.myklebust@hammerspace.com>
To:     linux-nfs@vger.kernel.org
Subject: [PATCH v3 6/8] NFS: Ensure NFS writeback allocations don't recurse back into NFS.
Date:   Tue, 19 Feb 2019 08:53:09 -0500
Message-Id: <20190219135311.119300-7-trond.myklebust@hammerspace.com>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190219135311.119300-6-trond.myklebust@hammerspace.com>
References: <20190219135311.119300-1-trond.myklebust@hammerspace.com>
 <20190219135311.119300-2-trond.myklebust@hammerspace.com>
 <20190219135311.119300-3-trond.myklebust@hammerspace.com>
 <20190219135311.119300-4-trond.myklebust@hammerspace.com>
 <20190219135311.119300-5-trond.myklebust@hammerspace.com>
 <20190219135311.119300-6-trond.myklebust@hammerspace.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

All the allocations that we can hit in the NFS layer and sunrpc layers
themselves are already marked as GFP_NOFS, but we need to ensure that
any calls to generic kernel functionality do the right thing as well.

Signed-off-by: Trond Myklebust <trond.myklebust@hammerspace.com>
---
 fs/nfs/write.c | 7 ++++++-
 1 file changed, 6 insertions(+), 1 deletion(-)

diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index 11df9f03245f..d1bc0384ac95 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -26,6 +26,7 @@
 #include <linux/iversion.h>
 
 #include <linux/uaccess.h>
+#include <linux/sched/mm.h>
 
 #include "delegation.h"
 #include "internal.h"
@@ -712,11 +713,13 @@ int nfs_writepages(struct address_space *mapping, struct writeback_control *wbc)
 {
 	struct inode *inode = mapping->host;
 	struct nfs_pageio_descriptor pgio;
-	struct nfs_io_completion *ioc = nfs_io_completion_alloc(GFP_NOFS);
+	struct nfs_io_completion *ioc;
+	unsigned int pflags = memalloc_nofs_save();
 	int err;
 
 	nfs_inc_stats(inode, NFSIOS_VFSWRITEPAGES);
 
+	ioc = nfs_io_completion_alloc(GFP_NOFS);
 	if (ioc)
 		nfs_io_completion_init(ioc, nfs_io_completion_commit, inode);
 
@@ -727,6 +730,8 @@ int nfs_writepages(struct address_space *mapping, struct writeback_control *wbc)
 	nfs_pageio_complete(&pgio);
 	nfs_io_completion_put(ioc);
 
+	memalloc_nofs_restore(pflags);
+
 	if (err < 0)
 		goto out_err;
 	err = pgio.pg_error;
-- 
2.20.1

