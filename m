Return-Path: <SRS0=m1Ek=5V=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	UNPARSEABLE_RELAY,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8CF2BC2BA15
	for <linux-nfs@archiver.kernel.org>; Sun,  5 Apr 2020 17:38:34 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 5D2B92063A
	for <linux-nfs@archiver.kernel.org>; Sun,  5 Apr 2020 17:38:34 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1727126AbgDERid (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Sun, 5 Apr 2020 13:38:33 -0400
Received: from out30-130.freemail.mail.aliyun.com ([115.124.30.130]:35208 "EHLO
        out30-130.freemail.mail.aliyun.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1726901AbgDERid (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sun, 5 Apr 2020 13:38:33 -0400
X-Alimail-AntiSpam: AC=PASS;BC=-1|-1;BR=01201311R311e4;CH=green;DM=||false|;DS=||;FP=0|-1|-1|-1|0|-1|-1|-1;HT=e01f04428;MF=wuyihao@linux.alibaba.com;NM=1;PH=DS;RN=6;SR=0;TI=SMTPD_---0TugAysl_1586108297;
Received: from localhost(mailfrom:wuyihao@linux.alibaba.com fp:SMTPD_---0TugAysl_1586108297)
          by smtp.aliyun-inc.com(127.0.0.1);
          Mon, 06 Apr 2020 01:38:18 +0800
From:   Yihao Wu <wuyihao@linux.alibaba.com>
To:     "J . Bruce Fields" <bfields@fieldses.org>,
        Chuck Lever <chuck.lever@oracle.com>,
        NeilBrown <neilb@suse.de>, Sasha Levin <sashal@kernel.org>
Cc:     linux-nfs@vger.kernel.org
Subject: [PATCH v2] SUNRPC/cache: Fix unsafe traverse caused double-free in cache_purge
Date:   Mon,  6 Apr 2020 01:38:16 +0800
Message-Id: <4568a7cf87f110b8e59fda6f53fda34c550ab403.1586108200.git.wuyihao@linux.alibaba.com>
X-Mailer: git-send-email 2.20.1.2432.ga663e714
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Deleting list entry within hlist_for_each_entry_safe is not safe unless
next pointer (tmp) is protected too. It's not, because once hash_lock
is released, cache_clean may delete the entry that tmp points to. Then
cache_purge can walk to a deleted entry and tries to double free it.

Fix this bug by holding only the deleted entry's reference.

Signed-off-by: Yihao Wu <wuyihao@linux.alibaba.com>
---
 net/sunrpc/cache.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/net/sunrpc/cache.c b/net/sunrpc/cache.c
index af0ddd28b081..9649c7fcccd2 100644
--- a/net/sunrpc/cache.c
+++ b/net/sunrpc/cache.c
@@ -541,7 +541,8 @@ void cache_purge(struct cache_detail *detail)
 	dprintk("RPC: %d entries in %s cache\n", detail->entries, detail->name);
 	for (i = 0; i < detail->hash_size; i++) {
 		head = &detail->hash_table[i];
-		hlist_for_each_entry_safe(ch, tmp, head, cache_list) {
+		while (!hlist_empty(head)) {
+			ch = hlist_entry(head->first, struct cache_head, cache_list);
 			sunrpc_begin_cache_remove_entry(ch, detail);
 			spin_unlock(&detail->hash_lock);
 			sunrpc_end_cache_remove_entry(ch, detail);
-- 
2.20.1.2432.ga663e714

