Return-Path: <SRS0=+NMN=PZ=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 04C96C43387
	for <linux-nfs@archiver.kernel.org>; Thu, 17 Jan 2019 06:12:23 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id C302320851
	for <linux-nfs@archiver.kernel.org>; Thu, 17 Jan 2019 06:12:22 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1729564AbfAQGMW (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Thu, 17 Jan 2019 01:12:22 -0500
Received: from szxga06-in.huawei.com ([45.249.212.32]:48536 "EHLO huawei.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1725320AbfAQGMW (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 17 Jan 2019 01:12:22 -0500
Received: from DGGEMS414-HUB.china.huawei.com (unknown [172.30.72.58])
        by Forcepoint Email with ESMTP id 14F3EB15315E2FC27DBB;
        Thu, 17 Jan 2019 14:12:19 +0800 (CST)
Received: from RH5885H-V3.huawei.com (10.90.53.225) by
 DGGEMS414-HUB.china.huawei.com (10.3.19.214) with Microsoft SMTP Server id
 14.3.408.0; Thu, 17 Jan 2019 14:12:08 +0800
From:   ZhangXiaoxu <zhangxiaoxu5@huawei.com>
To:     <zhangxiaoxu5@huawei.com>, <bfields@fieldses.org>,
        <jlayton@kernel.org>, <trond.myklebust@hammerspace.com>,
        <anna.schumaker@netapp.com>, <linux-nfs@vger.kernel.org>
Subject: [PATCH] lockd: NSMPROC_MON should be send only once even if in multithread
Date:   Thu, 17 Jan 2019 14:15:46 +0800
Message-ID: <1547705746-69554-1-git-send-email-zhangxiaoxu5@huawei.com>
X-Mailer: git-send-email 2.7.4
MIME-Version: 1.0
Content-Type: text/plain
X-Originating-IP: [10.90.53.225]
X-CFilter-Loop: Reflected
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

If multiple processes are locking the same file, the NSMPROC_MON
message would be send more than one times when the host is not
monitored by the peer.

Add a mutex to ensure that we just send once. If some one has send
the msg, Just waiting for the result or try again if failed.

Signed-off-by: ZhangXiaoxu <zhangxiaoxu5@huawei.com>
---
 fs/lockd/mon.c              | 10 ++++++++++
 include/linux/lockd/lockd.h |  1 +
 2 files changed, 11 insertions(+)

diff --git a/fs/lockd/mon.c b/fs/lockd/mon.c
index 654594e..4ba2658 100644
--- a/fs/lockd/mon.c
+++ b/fs/lockd/mon.c
@@ -155,6 +155,12 @@ int nsm_monitor(const struct nlm_host *host)
 	if (nsm->sm_monitored)
 		return 0;
 
+	mutex_lock(&nsm->mutex);
+	if (nsm->sm_monitored) {
+		mutex_unlock(&nsm->mutex);
+		return 0;
+	}
+
 	/*
 	 * Choose whether to record the caller_name or IP address of
 	 * this peer in the local rpc.statd's database.
@@ -165,6 +171,7 @@ int nsm_monitor(const struct nlm_host *host)
 	if (unlikely(res.status != 0))
 		status = -EIO;
 	if (unlikely(status < 0)) {
+		mutex_unlock(&nsm->mutex);
 		pr_notice_ratelimited("lockd: cannot monitor %s\n", nsm->sm_name);
 		return status;
 	}
@@ -174,6 +181,8 @@ int nsm_monitor(const struct nlm_host *host)
 		nsm_local_state = res.state;
 		dprintk("lockd: NSM state changed to %d\n", nsm_local_state);
 	}
+
+	mutex_unlock(&nsm->mutex);
 	return 0;
 }
 
@@ -284,6 +293,7 @@ static struct nsm_handle *nsm_create_handle(const struct sockaddr *sap,
 	memcpy(nsm_addr(new), sap, salen);
 	new->sm_addrlen = salen;
 	nsm_init_private(new);
+	mutex_init(&new->mutex);
 
 	if (rpc_ntop(nsm_addr(new), new->sm_addrbuf,
 					sizeof(new->sm_addrbuf)) == 0)
diff --git a/include/linux/lockd/lockd.h b/include/linux/lockd/lockd.h
index b065ef4..c56069c 100644
--- a/include/linux/lockd/lockd.h
+++ b/include/linux/lockd/lockd.h
@@ -89,6 +89,7 @@ struct nsm_handle {
 	char			*sm_name;
 	struct sockaddr_storage	sm_addr;
 	size_t			sm_addrlen;
+	struct mutex		mutex;  /* should be send only once even more threads */
 	unsigned int		sm_monitored : 1,
 				sm_sticky : 1;	/* don't unmonitor */
 	struct nsm_private	sm_priv;
-- 
2.7.4

