Return-Path: <SRS0=vLkQ=VH=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_GIT autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4B554C73C66
	for <linux-nfs@archiver.kernel.org>; Wed, 10 Jul 2019 03:09:47 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 2E53320656
	for <linux-nfs@archiver.kernel.org>; Wed, 10 Jul 2019 03:09:47 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726105AbfGJDJY (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 9 Jul 2019 23:09:24 -0400
Received: from szxga05-in.huawei.com ([45.249.212.191]:2248 "EHLO huawei.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1725941AbfGJDJY (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 9 Jul 2019 23:09:24 -0400
Received: from DGGEMS414-HUB.china.huawei.com (unknown [172.30.72.60])
        by Forcepoint Email with ESMTP id 942637021D84FE204553;
        Wed, 10 Jul 2019 11:09:18 +0800 (CST)
Received: from use12-sp2.huawei.com (10.67.189.174) by
 DGGEMS414-HUB.china.huawei.com (10.3.19.214) with Microsoft SMTP Server id
 14.3.439.0; Wed, 10 Jul 2019 11:09:12 +0800
From:   Xiaoming Ni <nixiaoming@huawei.com>
To:     <adobriyan@gmail.com>, <akpm@linux-foundation.org>,
        <anna.schumaker@netapp.com>, <arjan@linux.intel.com>,
        <bfields@fieldses.org>, <chuck.lever@oracle.com>,
        <davem@davemloft.net>, <gregkh@linuxfoundation.org>,
        <jlayton@kernel.org>, <luto@kernel.org>, <mingo@kernel.org>,
        <Nadia.Derbey@bull.net>, <paulmck@linux.vnet.ibm.com>,
        <semen.protsenko@linaro.org>, <stable@kernel.org>,
        <stern@rowland.harvard.edu>, <tglx@linutronix.de>,
        <torvalds@linux-foundation.org>, <trond.myklebust@hammerspace.com>,
        <viresh.kumar@linaro.org>, <vvs@virtuozzo.com>
CC:     <alex.huangjianhui@huawei.com>, <dylix.dailei@huawei.com>,
        <nixiaoming@huawei.com>, <linux-kernel@vger.kernel.org>,
        <linux-nfs@vger.kernel.org>, <netdev@vger.kernel.org>
Subject: [PATCH v3 1/3] kernel/notifier.c: avoid duplicate registration
Date:   Wed, 10 Jul 2019 11:09:10 +0800
Message-ID: <1562728150-30301-1-git-send-email-nixiaoming@huawei.com>
X-Mailer: git-send-email 1.8.5.6
MIME-Version: 1.0
Content-Type: text/plain
X-Originating-IP: [10.67.189.174]
X-CFilter-Loop: Reflected
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Registering the same notifier to a hook repeatedly can cause the hook
list to form a ring or lose other members of the list.

case1: An infinite loop in notifier_chain_register() can cause soft lockup
        atomic_notifier_chain_register(&test_notifier_list, &test1);
        atomic_notifier_chain_register(&test_notifier_list, &test1);
        atomic_notifier_chain_register(&test_notifier_list, &test2);

case2: An infinite loop in notifier_chain_register() can cause soft lockup
        atomic_notifier_chain_register(&test_notifier_list, &test1);
        atomic_notifier_chain_register(&test_notifier_list, &test1);
        atomic_notifier_call_chain(&test_notifier_list, 0, NULL);

case3: lose other hook test2
        atomic_notifier_chain_register(&test_notifier_list, &test1);
        atomic_notifier_chain_register(&test_notifier_list, &test2);
        atomic_notifier_chain_register(&test_notifier_list, &test1);

case4: Unregister returns 0, but the hook is still in the linked list,
        and it is not really registered. If you call notifier_call_chain
        after ko is unloaded, it will trigger oops.

If the system is configured with softlockup_panic and the same
hook is repeatedly registered on the panic_notifier_list, it
will cause a loop panic.

Add a check in notifier_chain_register() to avoid duplicate registration

Signed-off-by: Xiaoming Ni <nixiaoming@huawei.com>
---
 kernel/notifier.c | 5 ++++-
 1 file changed, 4 insertions(+), 1 deletion(-)

diff --git a/kernel/notifier.c b/kernel/notifier.c
index d9f5081..30bedb8 100644
--- a/kernel/notifier.c
+++ b/kernel/notifier.c
@@ -23,7 +23,10 @@ static int notifier_chain_register(struct notifier_block **nl,
 		struct notifier_block *n)
 {
 	while ((*nl) != NULL) {
-		WARN_ONCE(((*nl) == n), "double register detected");
+		if (unlikely((*nl) == n)) {
+			WARN(1, "double register detected");
+			return 0;
+		}
 		if (n->priority > (*nl)->priority)
 			break;
 		nl = &((*nl)->next);
-- 
1.8.5.6

