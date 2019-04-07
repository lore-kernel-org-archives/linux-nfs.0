Return-Path: <SRS0=hGI+=SJ=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 460FAC10F0E
	for <linux-nfs@archiver.kernel.org>; Sun,  7 Apr 2019 18:01:43 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 194EF20896
	for <linux-nfs@archiver.kernel.org>; Sun,  7 Apr 2019 18:01:43 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="QknhAW1j"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726471AbfDGSBm (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Sun, 7 Apr 2019 14:01:42 -0400
Received: from mail-it1-f195.google.com ([209.85.166.195]:38984 "EHLO
        mail-it1-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726466AbfDGSBm (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sun, 7 Apr 2019 14:01:42 -0400
Received: by mail-it1-f195.google.com with SMTP id 139so17333775ita.4
        for <linux-nfs@vger.kernel.org>; Sun, 07 Apr 2019 11:01:41 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=q8TSoPO9kXJFJoeGK9oXZX+ELAH+5w6/Bv+37JBTH1s=;
        b=QknhAW1jvgXp+37wkZfD9DefY6yjJS7YkqSRLEjFGtf+qa/J4Oo8r4D4qm4IWtcV2m
         +5kM2/Dgdd/KMvRHOnD61UhXyX7H9eR4v+fwjzbs/88G5rImV9xo56aOsF/y3iPOJSaJ
         8JDTStWX8CSIjbVd5f2BqsjnAcib36sqRyfs6cXOnV/hDv04zm/rxoWe2Pg6MIsqUn85
         mK2ZNQxWQXXUTITzCR3bzbJL+rQLb88wA9yuyZsOcDTewKv1FIBh0DIPBsgVDfRBIkHd
         pz3/ilvP/4q3nq7dqMwGT4wbG/GUQYTl0pJP/szsIaZqtrBD48mlj9/fi/GUsjCRY8iq
         6Jow==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:cc:subject:date:message-id:in-reply-to
         :references:mime-version:content-transfer-encoding;
        bh=q8TSoPO9kXJFJoeGK9oXZX+ELAH+5w6/Bv+37JBTH1s=;
        b=dfVA7BqUUZ+ukazmTKjEOOlPAGg9iLj3Vb2v6X0DhsAONPaR1gsOrOlm2z4mWCBv2q
         5KOEiLbBfGDCdR+b0IOOiZnwvtHKvtpse93MUDp/1qfUNuGVyEc6GW7xIY4eqnFs5q3M
         GQs5mWw/f9FfiA8/gIlBaZmmBHLXLrltULnSHq+7OT9deluO7ze7gaeqV7LVsoXCIfrJ
         K2jrXGYmQjsaIDFuqrRkPajFRNd9hYUSR3u9mcMpkEGvF61KvqwgE9vsNGBfhvM5J447
         Uv6jczNMX16bzjPTYaWZ3NDXb7Wj4GtQR9xd+PKNVovOx7lj4y2g42VZ2xV1uLdA1GhY
         LH/g==
X-Gm-Message-State: APjAAAUOzLbZYRlMsBLQGPeSTz/RAD/3Xm2CkULILjAQ7xVBx8arbNol
        G3JP0X43htbjnfwKnEFWxFecq4Q=
X-Google-Smtp-Source: APXvYqxdkdmMsTFk0NTevMVp3QRuXv95Yp69vC9EJYvVl5doecqEyrJvbO2zwXKGb3lvsMbPnr+eCw==
X-Received: by 2002:a24:454e:: with SMTP id y75mr17434055ita.5.1554660101180;
        Sun, 07 Apr 2019 11:01:41 -0700 (PDT)
Received: from localhost.localdomain (c-68-40-189-247.hsd1.mi.comcast.net. [68.40.189.247])
        by smtp.gmail.com with ESMTPSA id m6sm10807362ioj.36.2019.04.07.11.01.40
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Sun, 07 Apr 2019 11:01:40 -0700 (PDT)
From:   Trond Myklebust <trondmy@gmail.com>
X-Google-Original-From: Trond Myklebust <trond.myklebust@hammerspace.com>
To:     Anna Schumaker <Anna.Schumaker@netapp.com>
Cc:     linux-nfs@vger.kernel.org
Subject: [PATCH v3 20/29] NFS: Don't call generic_error_remove_page() while holding locks
Date:   Sun,  7 Apr 2019 13:59:03 -0400
Message-Id: <20190407175912.23528-21-trond.myklebust@hammerspace.com>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190407175912.23528-20-trond.myklebust@hammerspace.com>
References: <20190407175912.23528-1-trond.myklebust@hammerspace.com>
 <20190407175912.23528-2-trond.myklebust@hammerspace.com>
 <20190407175912.23528-3-trond.myklebust@hammerspace.com>
 <20190407175912.23528-4-trond.myklebust@hammerspace.com>
 <20190407175912.23528-5-trond.myklebust@hammerspace.com>
 <20190407175912.23528-6-trond.myklebust@hammerspace.com>
 <20190407175912.23528-7-trond.myklebust@hammerspace.com>
 <20190407175912.23528-8-trond.myklebust@hammerspace.com>
 <20190407175912.23528-9-trond.myklebust@hammerspace.com>
 <20190407175912.23528-10-trond.myklebust@hammerspace.com>
 <20190407175912.23528-11-trond.myklebust@hammerspace.com>
 <20190407175912.23528-12-trond.myklebust@hammerspace.com>
 <20190407175912.23528-13-trond.myklebust@hammerspace.com>
 <20190407175912.23528-14-trond.myklebust@hammerspace.com>
 <20190407175912.23528-15-trond.myklebust@hammerspace.com>
 <20190407175912.23528-16-trond.myklebust@hammerspace.com>
 <20190407175912.23528-17-trond.myklebust@hammerspace.com>
 <20190407175912.23528-18-trond.myklebust@hammerspace.com>
 <20190407175912.23528-19-trond.myklebust@hammerspace.com>
 <20190407175912.23528-20-trond.myklebust@hammerspace.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

The NFS read code can trigger writeback while holding the page lock.
If an error then triggers a call to nfs_write_error_remove_page(),
we can deadlock.

Signed-off-by: Trond Myklebust <trond.myklebust@hammerspace.com>
---
 fs/nfs/write.c | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index 9198a23bb58b..64cf6a340ba6 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -584,9 +584,8 @@ nfs_lock_and_join_requests(struct page *page)
 
 static void nfs_write_error_remove_page(struct nfs_page *req)
 {
+	SetPageError(req->wb_page);
 	nfs_end_page_writeback(req);
-	generic_error_remove_page(page_file_mapping(req->wb_page),
-				  req->wb_page);
 	nfs_release_request(req);
 }
 
-- 
2.20.1

