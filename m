Return-Path: <SRS0=26It=SA=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id AB803C4360F
	for <linux-nfs@archiver.kernel.org>; Fri, 29 Mar 2019 22:02:15 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 793D92184D
	for <linux-nfs@archiver.kernel.org>; Fri, 29 Mar 2019 22:02:15 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="Bj+MdKN4"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1730345AbfC2WCO (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Fri, 29 Mar 2019 18:02:14 -0400
Received: from mail-it1-f195.google.com ([209.85.166.195]:36186 "EHLO
        mail-it1-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1730357AbfC2WCO (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 29 Mar 2019 18:02:14 -0400
Received: by mail-it1-f195.google.com with SMTP id y10so4316143itc.1
        for <linux-nfs@vger.kernel.org>; Fri, 29 Mar 2019 15:02:14 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=q8TSoPO9kXJFJoeGK9oXZX+ELAH+5w6/Bv+37JBTH1s=;
        b=Bj+MdKN4e2p1q6OXR4ez01ET+4A2BRmYi5rZiynpWsJBKqF1y5RiIdG/38TKPZB0VE
         /BvjXeg0LJecN3m5I4todFhpmtvbOi5B/KpIx4FMsvZdFKAsbzVfJDk/t1XAEGbYTqd7
         AvhHYXP/Nm66CqsJWUTZS9SyaBPu0rp1wjXqChlOW3yLJVrM6YiSEI6TYXZX2IzvYQhm
         3It/Zi4HE0CvRlUvE2nORT8142bOSXgxbi+dZdeXS1eASrYoD+eAB9PXQ67Brg8Byhng
         EEBjMyqWXqGvuW9/wG7NkfrNSLx+QD5lhg0YZhMUrtrpnJWjU8rPkRUa5AtvMCs5YKFD
         Atxw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:subject:date:message-id:in-reply-to
         :references:mime-version:content-transfer-encoding;
        bh=q8TSoPO9kXJFJoeGK9oXZX+ELAH+5w6/Bv+37JBTH1s=;
        b=TnXYTuLfi6mQOGFCkNvdM9aAP5zFmGPXqL1qfLqvAEdMG5o/JkZkk9Cx796mEU68AA
         I1qtWG0sDcBZ/4AdiFpm4267nZdVJdhnjDxjFLCPdbFzB3Pnuj3w+KhM3aWose3/WL7k
         YFJXIGm9aC7xZBCN4Haghfwp6DVrfk59onrskn9reLKEwkx4OsZ9KdvVSnd1i/7QEIYu
         FKZ7E0FFOMDINgwRJ77ySAAxun7rmVnymVKOg/fCbUZzJmZ5lvK2z6WZ+k9y2tcZgrmj
         u9Fg8YTyiaXyDyqcg5fuE0I6bbSyIpjCykL0NpwBbqaNMDa8SoULGwF0cWsObXZfDYor
         Jgxw==
X-Gm-Message-State: APjAAAVmdf3X/sVsSA4AE3DV8EtKCiTtrOxzXOio0X1tUJgRE4unwHjT
        ZzoqwQ2JcLR2aaUgRpK1r6Fe4DA=
X-Google-Smtp-Source: APXvYqyK/Zl4qKU0YLAgJ1Hn5skPFQwZqYmzZYzn83ZwURoiUMEu8xAFKI+YqV5shvPm1wHPMYSExw==
X-Received: by 2002:a24:9482:: with SMTP id j124mr6497049ite.176.1553896933232;
        Fri, 29 Mar 2019 15:02:13 -0700 (PDT)
Received: from localhost.localdomain (c-68-40-189-247.hsd1.mi.comcast.net. [68.40.189.247])
        by smtp.gmail.com with ESMTPSA id v20sm1376796ioh.17.2019.03.29.15.02.12
        for <linux-nfs@vger.kernel.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 29 Mar 2019 15:02:12 -0700 (PDT)
From:   Trond Myklebust <trondmy@gmail.com>
X-Google-Original-From: Trond Myklebust <trond.myklebust@hammerspace.com>
To:     linux-nfs@vger.kernel.org
Subject: [PATCH v2 20/28] NFS: Don't call generic_error_remove_page() while holding locks
Date:   Fri, 29 Mar 2019 17:59:40 -0400
Message-Id: <20190329215948.107328-21-trond.myklebust@hammerspace.com>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190329215948.107328-20-trond.myklebust@hammerspace.com>
References: <20190329215948.107328-1-trond.myklebust@hammerspace.com>
 <20190329215948.107328-2-trond.myklebust@hammerspace.com>
 <20190329215948.107328-3-trond.myklebust@hammerspace.com>
 <20190329215948.107328-4-trond.myklebust@hammerspace.com>
 <20190329215948.107328-5-trond.myklebust@hammerspace.com>
 <20190329215948.107328-6-trond.myklebust@hammerspace.com>
 <20190329215948.107328-7-trond.myklebust@hammerspace.com>
 <20190329215948.107328-8-trond.myklebust@hammerspace.com>
 <20190329215948.107328-9-trond.myklebust@hammerspace.com>
 <20190329215948.107328-10-trond.myklebust@hammerspace.com>
 <20190329215948.107328-11-trond.myklebust@hammerspace.com>
 <20190329215948.107328-12-trond.myklebust@hammerspace.com>
 <20190329215948.107328-13-trond.myklebust@hammerspace.com>
 <20190329215948.107328-14-trond.myklebust@hammerspace.com>
 <20190329215948.107328-15-trond.myklebust@hammerspace.com>
 <20190329215948.107328-16-trond.myklebust@hammerspace.com>
 <20190329215948.107328-17-trond.myklebust@hammerspace.com>
 <20190329215948.107328-18-trond.myklebust@hammerspace.com>
 <20190329215948.107328-19-trond.myklebust@hammerspace.com>
 <20190329215948.107328-20-trond.myklebust@hammerspace.com>
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

