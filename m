Return-Path: <SRS0=7+z+=TU=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.8 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BEEADC04E87
	for <linux-nfs@archiver.kernel.org>; Mon, 20 May 2019 05:58:47 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 9001920815
	for <linux-nfs@archiver.kernel.org>; Mon, 20 May 2019 05:58:47 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="Re+W8BLv"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1730511AbfETF6l (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 20 May 2019 01:58:41 -0400
Received: from bombadil.infradead.org ([198.137.202.133]:39050 "EHLO
        bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1730532AbfETF6k (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 20 May 2019 01:58:40 -0400
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
        d=infradead.org; s=bombadil.20170209; h=Content-Transfer-Encoding:
        MIME-Version:References:In-Reply-To:Message-Id:Date:Subject:Cc:To:From:Sender
        :Reply-To:Content-Type:Content-ID:Content-Description:Resent-Date:Resent-From
        :Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:List-Help:
        List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
        bh=/SFfD7/IVWCGE96J1VVwYbb2NenGrtf57wS4zCUzGX8=; b=Re+W8BLvyS1MgoCaapd/OQ+Qwp
        32OBEnKBUJVLUs79jLWSzcz1kHXXyHyqcMTdwGtaPVC5xmto+sVBQqgTMzAmuURhrbIYp8FMJ3gfE
        l3oWMhBHjJ1yeMW3XRT+kjUL9TCBoASPc1/DwkGws7eiwnp5uHSqneVFr2IX7JFO6do7L/tWTt1Q+
        +1pQd6hkn/MqT1RLnUTMwmXA4zOT9ItdA7hEcyB2tI29txo7KqHzqzpwDpAxhlqolJNjYlR1BOTTP
        Rkr/aD1nXh8ArmcikMSKICnWHj9XOcYz83RSs2HQrN6nrBvWm4RnQPggas+3xP5hz8S/E4U4lAclU
        hLiQL/ZA==;
Received: from 089144206147.atnat0015.highway.bob.at ([89.144.206.147] helo=localhost)
        by bombadil.infradead.org with esmtpsa (Exim 4.90_1 #2 (Red Hat Linux))
        id 1hSbJk-0006OG-Cl; Mon, 20 May 2019 05:58:36 +0000
From:   Christoph Hellwig <hch@lst.de>
To:     Andrew Morton <akpm@linux-foundation.org>
Cc:     Sami Tolvanen <samitolvanen@google.com>,
        Kees Cook <keescook@chromium.org>,
        Nick Desaulniers <ndesaulniers@google.com>,
        linux-mtd@lists.infradead.org, linux-nfs@vger.kernel.org,
        linux-mm@kvack.org, linux-kernel@vger.kernel.org
Subject: [PATCH 4/4] 9p: pass the correct prototype to read_cache_page
Date:   Mon, 20 May 2019 07:57:31 +0200
Message-Id: <20190520055731.24538-5-hch@lst.de>
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

Fix the callback 9p passes to read_cache_page to actually have the
proper type expected.  Casting around function pointers can easily
hide typing bugs, and defeats control flow protection.

Signed-off-by: Christoph Hellwig <hch@lst.de>
Reviewed-by: Kees Cook <keescook@chromium.org>
---
 fs/9p/vfs_addr.c | 6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff --git a/fs/9p/vfs_addr.c b/fs/9p/vfs_addr.c
index 0bcbcc20f769..02e0fc51401e 100644
--- a/fs/9p/vfs_addr.c
+++ b/fs/9p/vfs_addr.c
@@ -50,8 +50,9 @@
  * @page: structure to page
  *
  */
-static int v9fs_fid_readpage(struct p9_fid *fid, struct page *page)
+static int v9fs_fid_readpage(void *data, struct page *page)
 {
+	struct p9_fid *fid = data;
 	struct inode *inode = page->mapping->host;
 	struct bio_vec bvec = {.bv_page = page, .bv_len = PAGE_SIZE};
 	struct iov_iter to;
@@ -122,7 +123,8 @@ static int v9fs_vfs_readpages(struct file *filp, struct address_space *mapping,
 	if (ret == 0)
 		return ret;
 
-	ret = read_cache_pages(mapping, pages, (void *)v9fs_vfs_readpage, filp);
+	ret = read_cache_pages(mapping, pages, v9fs_fid_readpage,
+			filp->private_data);
 	p9_debug(P9_DEBUG_VFS, "  = %d\n", ret);
 	return ret;
 }
-- 
2.20.1

