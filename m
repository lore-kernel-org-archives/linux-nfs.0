Return-Path: <SRS0=mSH2=NZ=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DAD91C43441
	for <linux-nfs@archiver.kernel.org>; Wed, 14 Nov 2018 08:12:35 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id A9DCA214F1
	for <linux-nfs@archiver.kernel.org>; Wed, 14 Nov 2018 08:12:35 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A9DCA214F1
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=virtuozzo.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1728823AbeKNSOo (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Wed, 14 Nov 2018 13:14:44 -0500
Received: from relay.sw.ru ([185.231.240.75]:43540 "EHLO relay.sw.ru"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1728462AbeKNSOn (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 14 Nov 2018 13:14:43 -0500
Received: from [172.16.24.163] (helo=snorch.sw.ru)
        by relay.sw.ru with esmtp (Exim 4.90_1)
        (envelope-from <ptikhomirov@virtuozzo.com>)
        id 1gMqHh-00089v-3k; Wed, 14 Nov 2018 11:12:25 +0300
From:   Pavel Tikhomirov <ptikhomirov@virtuozzo.com>
To:     Trond Myklebust <trond.myklebust@hammerspace.com>
Cc:     Pavel Tikhomirov <ptikhomirov@virtuozzo.com>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
Subject: [PATCH] nfs: fix comment to nfs_generic_pg_test which does the opposite
Date:   Wed, 14 Nov 2018 11:12:05 +0300
Message-Id: <20181114081205.14821-1-ptikhomirov@virtuozzo.com>
X-Mailer: git-send-email 2.17.1
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Please see comment to filelayout_pg_test for reference.

To: Trond Myklebust <trond.myklebust@hammerspace.com>
Cc: Anna Schumaker <anna.schumaker@netapp.com>
Cc: linux-nfs@vger.kernel.org
Cc: linux-kernel@vger.kernel.org
Signed-off-by: Pavel Tikhomirov <ptikhomirov@virtuozzo.com>
---
 fs/nfs/pagelist.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/fs/nfs/pagelist.c b/fs/nfs/pagelist.c
index 5c4568a0804b..87f3da1fd850 100644
--- a/fs/nfs/pagelist.c
+++ b/fs/nfs/pagelist.c
@@ -461,7 +461,7 @@ EXPORT_SYMBOL_GPL(nfs_wait_on_request);
  * @prev: previous request in desc, or NULL
  * @req: this request
  *
- * Returns zero if @req can be coalesced into @desc, otherwise it returns
+ * Returns zero if @req cannot be coalesced into @desc, otherwise it returns
  * the size of the request.
  */
 size_t nfs_generic_pg_test(struct nfs_pageio_descriptor *desc,
-- 
2.17.1

