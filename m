Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:19492 "EHLO relay.sw.ru"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1756023AbcIUMew (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 21 Sep 2016 08:34:52 -0400
From: Vasily Averin <vvs@virtuozzo.com>
Subject: [PATCH 2/2] notifiers: double register detection
To: linux-kernel@vger.kernel.org, linux-nfs@vger.kernel.org
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
        Jeff Layton <jlayton@poochiereds.net>,
        Scott Mayhew <smayhew@redhat.com>
Message-ID: <105a9bce-5539-73f1-2683-e52dba870c04@virtuozzo.com>
Date: Wed, 21 Sep 2016 15:33:11 +0300
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

WARN_ON should help to detect double register of the same notifiers

Signed-off-by: Vasily Averin <vvs@virtuozzo.com>
---
 kernel/notifier.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/kernel/notifier.c b/kernel/notifier.c
index fd2c9ac..e02b2f0 100644
--- a/kernel/notifier.c
+++ b/kernel/notifier.c
@@ -22,6 +22,7 @@ static int notifier_chain_register(struct notifier_block **nl,
 		struct notifier_block *n)
 {
 	while ((*nl) != NULL) {
+		WARN_ON((*nl) == n);
 		if (n->priority > (*nl)->priority)
 			break;
 		nl = &((*nl)->next);
-- 
1.9.1

