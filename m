Return-Path: <SRS0=UHwe=23=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 85647C33C8C
	for <linux-nfs@archiver.kernel.org>; Mon,  6 Jan 2020 18:20:29 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 58D872070E
	for <linux-nfs@archiver.kernel.org>; Mon,  6 Jan 2020 18:20:29 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="l5+chSSB"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726699AbgAFSU2 (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 6 Jan 2020 13:20:28 -0500
Received: from mail-yb1-f196.google.com ([209.85.219.196]:47081 "EHLO
        mail-yb1-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726569AbgAFSU2 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 6 Jan 2020 13:20:28 -0500
Received: by mail-yb1-f196.google.com with SMTP id k128so11451691ybc.13
        for <linux-nfs@vger.kernel.org>; Mon, 06 Jan 2020 10:20:27 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=gY3N9AW/BeVLH0xQqk5UEbr4T+5CiQQRmrXEg2SfK5A=;
        b=l5+chSSB8oPQM7hPYJY/+OGdxsCe5IXcFG1SOUtrzxYIdjz8M5Pd6b//LkxDTOoJ7J
         /8X+ZPu+JKxdjmY6WCX8OGDXKdseC0yT4JE81HwDK955Qb/oHCYkwIskbCTbSFBjEQN8
         te2VGh1//gpbWsBsmF/YzgAq19TPVGPKNvf7+YiZ+JMtL122hQtuaOjC9OpvSkWiY5qw
         Z1W6h365q84b9AgXzAnESXs/4OTVWRudis3cD7MpB9hN2qBTgjHjwoVd5VBJgJrqTmh0
         tzWZgGnm6+chKKDICeefpOjAMkf6vqCnzPZOL9ojOX+a0mOAPB+qSri6Y6hwNBR+DSru
         woPw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:cc:subject:date:message-id:in-reply-to
         :references:mime-version:content-transfer-encoding;
        bh=gY3N9AW/BeVLH0xQqk5UEbr4T+5CiQQRmrXEg2SfK5A=;
        b=FN4uO4b/Zp6D5xMKj/MHiKGFUYsu1M6JRILgZhRMOybbRBqaOEVES6ZFuOtZY1hHNM
         zFNgzLp93zf8TWzaLwdlVIuva+esqpX4jJCyMqt3555mpiOBbElgT2qDFP7KWWbFaZDm
         3bfD8p/f2opH1Lpl9hNPt+1BHStpUcT63XY9zYZIxP9ffnfSRTshEYldkqIhI4/t4sRK
         Tb2DBc+yzulQs/PutAXSoB2nFCnjsDoQTH0jMEZEvaOza5PXh1R5gYzvIMS5rvTyCRhH
         ZMRXQdYt1rPMtI3+yjNTw8kPtIX+x8DuW7hDkNQbMK2bC2FbCIV2OX3PavWVkla1Z8ks
         LsEw==
X-Gm-Message-State: APjAAAXEvFBgyPHdB67Se6KA/c0DwEDMSpXxLVT8k0d4MEVCGdkVExw6
        qX3tNyJkXnAhamEtVsAy8mT+trBIxQ==
X-Google-Smtp-Source: APXvYqy6ed+Lq1AQH9dQsCRM3YRHR501Ej/QOUqznojJEXpdjOA7IyDiBkdNVzAJi0ysiAYBckUUHw==
X-Received: by 2002:a25:d903:: with SMTP id q3mr73202584ybg.244.1578334827038;
        Mon, 06 Jan 2020 10:20:27 -0800 (PST)
Received: from localhost.localdomain (c-68-40-189-247.hsd1.mi.comcast.net. [68.40.189.247])
        by smtp.gmail.com with ESMTPSA id r31sm24800524ywa.82.2020.01.06.10.20.25
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Mon, 06 Jan 2020 10:20:26 -0800 (PST)
From:   Trond Myklebust <trondmy@gmail.com>
X-Google-Original-From: Trond Myklebust <trond.myklebust@hammerspace.com>
To:     "J. Bruce Fields" <bfields@redhat.com>
Cc:     linux-nfs@vger.kernel.org
Subject: [PATCH RESEND 4/6] nfsd: Remove unused constant NFSD_FILE_LRU_RESCAN
Date:   Mon,  6 Jan 2020 13:18:06 -0500
Message-Id: <20200106181808.562969-5-trond.myklebust@hammerspace.com>
X-Mailer: git-send-email 2.24.1
In-Reply-To: <20200106181808.562969-4-trond.myklebust@hammerspace.com>
References: <20200106181808.562969-1-trond.myklebust@hammerspace.com>
 <20200106181808.562969-2-trond.myklebust@hammerspace.com>
 <20200106181808.562969-3-trond.myklebust@hammerspace.com>
 <20200106181808.562969-4-trond.myklebust@hammerspace.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Signed-off-by: Trond Myklebust <trond.myklebust@hammerspace.com>
---
 fs/nfsd/filecache.c | 5 +----
 1 file changed, 1 insertion(+), 4 deletions(-)

diff --git a/fs/nfsd/filecache.c b/fs/nfsd/filecache.c
index e71af553c2ed..6b0ab43b0618 100644
--- a/fs/nfsd/filecache.c
+++ b/fs/nfsd/filecache.c
@@ -27,7 +27,6 @@
 #define NFSD_FILE_HASH_SIZE                  (1 << NFSD_FILE_HASH_BITS)
 #define NFSD_LAUNDRETTE_DELAY		     (2 * HZ)
 
-#define NFSD_FILE_LRU_RESCAN		     (0)
 #define NFSD_FILE_SHUTDOWN		     (1)
 #define NFSD_FILE_LRU_THRESHOLD		     (4096UL)
 #define NFSD_FILE_LRU_LIMIT		     (NFSD_FILE_LRU_THRESHOLD << 2)
@@ -440,15 +439,13 @@ nfsd_file_lru_cb(struct list_head *item, struct list_lru_one *lru,
 		goto out_skip;
 
 	if (test_and_clear_bit(NFSD_FILE_REFERENCED, &nf->nf_flags))
-		goto out_rescan;
+		goto out_skip;
 
 	if (!test_and_clear_bit(NFSD_FILE_HASHED, &nf->nf_flags))
 		goto out_skip;
 
 	list_lru_isolate_move(lru, &nf->nf_lru, head);
 	return LRU_REMOVED;
-out_rescan:
-	set_bit(NFSD_FILE_LRU_RESCAN, &nfsd_file_lru_flags);
 out_skip:
 	return LRU_SKIP;
 }
-- 
2.24.1

