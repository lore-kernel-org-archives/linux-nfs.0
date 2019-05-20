Return-Path: <SRS0=7+z+=TU=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.8 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0E2B0C04AAF
	for <linux-nfs@archiver.kernel.org>; Mon, 20 May 2019 05:58:41 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id D752320815
	for <linux-nfs@archiver.kernel.org>; Mon, 20 May 2019 05:58:40 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="TjdrOaCy"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1730526AbfETF6k (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 20 May 2019 01:58:40 -0400
Received: from bombadil.infradead.org ([198.137.202.133]:38932 "EHLO
        bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1730511AbfETF6j (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 20 May 2019 01:58:39 -0400
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
        d=infradead.org; s=bombadil.20170209; h=Content-Transfer-Encoding:
        MIME-Version:References:In-Reply-To:Message-Id:Date:Subject:Cc:To:From:Sender
        :Reply-To:Content-Type:Content-ID:Content-Description:Resent-Date:Resent-From
        :Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:List-Help:
        List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
        bh=s0uOtVt2IyE4cfR/Y0SEBdScE54aOmbj3l250cgaAfI=; b=TjdrOaCygaa/v3jG/wHnMz3jBW
        n24bEiQWWQaZjA+YPHfrxSijLYaBE8PmAGLyk+L0ae7WI+QX+gWOG+vRGMllV8nU/BakVdpXQuN3f
        d7vkmkFg1o0zgdfvGXmGVHk9PdY9RyTPk1qJ4jKCNShwL1s1SbM+ojVnVPyNQ7CxDJuDeXaGrA3IE
        2BqmX/79Rxk8tY/OI3mMEIH5wfsc81P6NnVKbBCmNBswsu9SZ/6Jd7XjzZ9dvpaAZigb54nKDwvmF
        QmUm+6sft6TWtT6DiMAJysavX4ZHQxyQrp7AB38L4VAl85fWA3casXlj+6TBedfIqOCXX7QmriJhj
        Nrz0y9Zg==;
Received: from 089144206147.atnat0015.highway.bob.at ([89.144.206.147] helo=localhost)
        by bombadil.infradead.org with esmtpsa (Exim 4.90_1 #2 (Red Hat Linux))
        id 1hSbJh-0006Js-Q9; Mon, 20 May 2019 05:58:34 +0000
From:   Christoph Hellwig <hch@lst.de>
To:     Andrew Morton <akpm@linux-foundation.org>
Cc:     Sami Tolvanen <samitolvanen@google.com>,
        Kees Cook <keescook@chromium.org>,
        Nick Desaulniers <ndesaulniers@google.com>,
        linux-mtd@lists.infradead.org, linux-nfs@vger.kernel.org,
        linux-mm@kvack.org, linux-kernel@vger.kernel.org
Subject: [PATCH 3/4] jffs2: pass the correct prototype to read_cache_page
Date:   Mon, 20 May 2019 07:57:30 +0200
Message-Id: <20190520055731.24538-4-hch@lst.de>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190520055731.24538-1-hch@lst.de>
References: <20190520055731.24538-1-hch@lst.de>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-SRS-Rewrite: SMTP reverse-path rewritten from <hch@infradead.org> by bombadil.infradead.org. See http://www.infradead.org/rpr.html
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Fix the callback jffs2 passes to read_cache_page to actually have the
proper type expected.  Casting around function pointers can easily
hide typing bugs, and defeats control flow protection.

Signed-off-by: Christoph Hellwig <hch@lst.de>
Reviewed-by: Kees Cook <keescook@chromium.org>
---
 fs/jffs2/file.c     | 4 ++--
 fs/jffs2/fs.c       | 2 +-
 fs/jffs2/os-linux.h | 2 +-
 3 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/fs/jffs2/file.c b/fs/jffs2/file.c
index 7d8654a1472e..f8fb89b10227 100644
--- a/fs/jffs2/file.c
+++ b/fs/jffs2/file.c
@@ -109,9 +109,9 @@ static int jffs2_do_readpage_nolock (struct inode *inode, struct page *pg)
 	return ret;
 }
 
-int jffs2_do_readpage_unlock(struct inode *inode, struct page *pg)
+int jffs2_do_readpage_unlock(void *data, struct page *pg)
 {
-	int ret = jffs2_do_readpage_nolock(inode, pg);
+	int ret = jffs2_do_readpage_nolock(data, pg);
 	unlock_page(pg);
 	return ret;
 }
diff --git a/fs/jffs2/fs.c b/fs/jffs2/fs.c
index 112d85849db1..8a20ddd25f2d 100644
--- a/fs/jffs2/fs.c
+++ b/fs/jffs2/fs.c
@@ -687,7 +687,7 @@ unsigned char *jffs2_gc_fetch_page(struct jffs2_sb_info *c,
 	struct page *pg;
 
 	pg = read_cache_page(inode->i_mapping, offset >> PAGE_SHIFT,
-			     (void *)jffs2_do_readpage_unlock, inode);
+			     jffs2_do_readpage_unlock, inode);
 	if (IS_ERR(pg))
 		return (void *)pg;
 
diff --git a/fs/jffs2/os-linux.h b/fs/jffs2/os-linux.h
index a2dbbb3f4c74..bd3d5f0ddc34 100644
--- a/fs/jffs2/os-linux.h
+++ b/fs/jffs2/os-linux.h
@@ -155,7 +155,7 @@ extern const struct file_operations jffs2_file_operations;
 extern const struct inode_operations jffs2_file_inode_operations;
 extern const struct address_space_operations jffs2_file_address_operations;
 int jffs2_fsync(struct file *, loff_t, loff_t, int);
-int jffs2_do_readpage_unlock (struct inode *inode, struct page *pg);
+int jffs2_do_readpage_unlock(void *data, struct page *pg);
 
 /* ioctl.c */
 long jffs2_ioctl(struct file *, unsigned int, unsigned long);
-- 
2.20.1

