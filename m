Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from szxga03-in.huawei.com ([45.249.212.189]:3962 "EHLO
        dggrg03-dlp.huawei.com" rhost-flags-OK-FAIL-OK-FAIL)
        by vger.kernel.org with ESMTP id S1753729AbdCJCrS (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 9 Mar 2017 21:47:18 -0500
From: Jason Yan <yanaijie@huawei.com>
To: <anna.schumaker@netapp.com>, <trond.myklebust@primarydata.com>,
        <linux-nfs@vger.kernel.org>
CC: <zhaohongjiang@huawei.com>, Jason Yan <yanaijie@huawei.com>
Subject: [PATCH] nfs: make nfs4_cb_sv_ops static
Date: Fri, 10 Mar 2017 10:48:13 +0800
Message-ID: <1489114093-12631-1-git-send-email-yanaijie@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Fixes the following sparse warning:

fs/nfs/callback.c:235:21: warning: symbol 'nfs4_cb_sv_ops' was not
declared. Should it be static?

Signed-off-by: Jason Yan <yanaijie@huawei.com>
---
 fs/nfs/callback.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/callback.c b/fs/nfs/callback.c
index bb79972..7737745 100644
--- a/fs/nfs/callback.c
+++ b/fs/nfs/callback.c
@@ -232,12 +232,12 @@ static struct svc_serv_ops nfs41_cb_sv_ops = {
 	.svo_module		= THIS_MODULE,
 };
 
-struct svc_serv_ops *nfs4_cb_sv_ops[] = {
+static struct svc_serv_ops *nfs4_cb_sv_ops[] = {
 	[0] = &nfs40_cb_sv_ops,
 	[1] = &nfs41_cb_sv_ops,
 };
 #else
-struct svc_serv_ops *nfs4_cb_sv_ops[] = {
+static struct svc_serv_ops *nfs4_cb_sv_ops[] = {
 	[0] = &nfs40_cb_sv_ops,
 	[1] = NULL,
 };
-- 
2.5.0

