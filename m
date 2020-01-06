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
	by smtp.lore.kernel.org (Postfix) with ESMTP id C0CEAC33C9B
	for <linux-nfs@archiver.kernel.org>; Mon,  6 Jan 2020 18:20:30 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 91FA42070E
	for <linux-nfs@archiver.kernel.org>; Mon,  6 Jan 2020 18:20:30 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="aAvoZM/5"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726701AbgAFSUa (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 6 Jan 2020 13:20:30 -0500
Received: from mail-yw1-f68.google.com ([209.85.161.68]:36783 "EHLO
        mail-yw1-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726698AbgAFSU3 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 6 Jan 2020 13:20:29 -0500
Received: by mail-yw1-f68.google.com with SMTP id n184so22258758ywc.3
        for <linux-nfs@vger.kernel.org>; Mon, 06 Jan 2020 10:20:28 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=1FuNP4R+SuvQzOLYpKGWQClYNeimIeK+zk75+PZJGI0=;
        b=aAvoZM/5/wI1MyGb6tR5WCworsxK0eZklq65oVpxmayQe2mb9+76hSM49UlnuAWlVf
         oa/PwobEzVWMBZe40qg+Rt7SSbbYgB8W5cV0GI40OzqaAaIkECXIkwe9wVDqDJTlcB6f
         FDzh7Qp6YaITC2N68oHSayMIZXIOfPUP8A0X1UCm4ypHjlZRzJ4WxxWLBab3yrvbpQma
         dWZhEeBxLdE9kzzyzOQvHHJFWVLHHkV7k/XX1h9wVxH9HGQwPG87iTYEPJ9t7zQ0pby8
         V/w7RKCm95yHsSODnqwFyjyvturn4G63AWKOLvTKpGhr7o6qPjHrsuKQ2hM3g7O5XwmK
         cmLQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:cc:subject:date:message-id:in-reply-to
         :references:mime-version:content-transfer-encoding;
        bh=1FuNP4R+SuvQzOLYpKGWQClYNeimIeK+zk75+PZJGI0=;
        b=YJR0QBNfvXkOo4q/UwNku4ykIgRJN9kPCN/9qM4MJE4Udw2VtMAqYqfo6ES3CRHHzX
         cGr3wO5oCYG8CPFgJJgLKz2AP4wSTKR2y/IWOhPZrj3jQbVlX4b+19s5CmF7vCtbMpjs
         LuoNwn0IQF/XLmc1AyM5iRHLquUbIAxJDUV9EfPYWIyMSmI3wfUkTwAqdXyigtLFiZ/g
         7dt3CyywZle2zy3DeXiOuBDgr6k4KQ//6KetCYanYXGuIK1AP2IYZ/Qs8QMVCggVhARh
         JXhh6M/bVjqmxJpQl17IFQbQQaGfVCEFmgrQoJ6UkPS4IA6do4XeSjPahR65xGRJv98M
         P68g==
X-Gm-Message-State: APjAAAXy7rNDB/oeS6obU1JPC1y33OJPYijkXkdWNK6y1wR9fgw958R+
        G8qmkzZwrAAzILRP8VerCA==
X-Google-Smtp-Source: APXvYqx4TcThYfgs7qrONHjvGp5peUCEAGa5UEtZWBQDDUVqeBQuykQsJTWCzF/dHuakVrR//wWdwQ==
X-Received: by 2002:a0d:c444:: with SMTP id g65mr77972588ywd.119.1578334828009;
        Mon, 06 Jan 2020 10:20:28 -0800 (PST)
Received: from localhost.localdomain (c-68-40-189-247.hsd1.mi.comcast.net. [68.40.189.247])
        by smtp.gmail.com with ESMTPSA id r31sm24800524ywa.82.2020.01.06.10.20.27
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Mon, 06 Jan 2020 10:20:27 -0800 (PST)
From:   Trond Myklebust <trondmy@gmail.com>
X-Google-Original-From: Trond Myklebust <trond.myklebust@hammerspace.com>
To:     "J. Bruce Fields" <bfields@redhat.com>
Cc:     linux-nfs@vger.kernel.org
Subject: [PATCH RESEND 5/6] nfsd: Schedule the laundrette regularly irrespective of file errors
Date:   Mon,  6 Jan 2020 13:18:07 -0500
Message-Id: <20200106181808.562969-6-trond.myklebust@hammerspace.com>
X-Mailer: git-send-email 2.24.1
In-Reply-To: <20200106181808.562969-5-trond.myklebust@hammerspace.com>
References: <20200106181808.562969-1-trond.myklebust@hammerspace.com>
 <20200106181808.562969-2-trond.myklebust@hammerspace.com>
 <20200106181808.562969-3-trond.myklebust@hammerspace.com>
 <20200106181808.562969-4-trond.myklebust@hammerspace.com>
 <20200106181808.562969-5-trond.myklebust@hammerspace.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Emsure we schedule the laundrette even if the struct file is carrying
file errors.

Signed-off-by: Trond Myklebust <trond.myklebust@hammerspace.com>
---
 fs/nfsd/filecache.c | 10 +---------
 1 file changed, 1 insertion(+), 9 deletions(-)

diff --git a/fs/nfsd/filecache.c b/fs/nfsd/filecache.c
index 6b0ab43b0618..4cef03a7726c 100644
--- a/fs/nfsd/filecache.c
+++ b/fs/nfsd/filecache.c
@@ -237,13 +237,6 @@ nfsd_file_check_write_error(struct nfsd_file *nf)
 	return filemap_check_wb_err(file->f_mapping, READ_ONCE(file->f_wb_err));
 }
 
-static bool
-nfsd_file_in_use(struct nfsd_file *nf)
-{
-	return nfsd_file_check_writeback(nf) ||
-			nfsd_file_check_write_error(nf);
-}
-
 static void
 nfsd_file_do_unhash(struct nfsd_file *nf)
 {
@@ -307,10 +300,9 @@ void
 nfsd_file_put(struct nfsd_file *nf)
 {
 	bool is_hashed = test_bit(NFSD_FILE_HASHED, &nf->nf_flags) != 0;
-	bool unused = !nfsd_file_in_use(nf);
 
 	set_bit(NFSD_FILE_REFERENCED, &nf->nf_flags);
-	if (nfsd_file_put_noref(nf) == 1 && is_hashed && unused)
+	if (nfsd_file_put_noref(nf) == 1 && is_hashed)
 		nfsd_file_schedule_laundrette();
 	if (atomic_long_read(&nfsd_filecache_count) >= NFSD_FILE_LRU_LIMIT)
 		nfsd_file_gc();
-- 
2.24.1

