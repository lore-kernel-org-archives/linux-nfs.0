Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx3-rdu2.redhat.com ([66.187.233.73]:42386 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S934727AbeE3Hjr (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 30 May 2018 03:39:47 -0400
Received: from smtp.corp.redhat.com (int-mx06.intmail.prod.int.rdu2.redhat.com [10.11.54.6])
        (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
        (No client certificate requested)
        by mx1.redhat.com (Postfix) with ESMTPS id 6E56C76F91
        for <linux-nfs@vger.kernel.org>; Wed, 30 May 2018 07:39:47 +0000 (UTC)
From: Rinku Kothiya <rkothiya@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: steved@redhat.com
Subject: [nfs-utils PATCH] Fixed missed read of config file by nolockmgr (bz 1413272)
Date: Wed, 30 May 2018 13:09:43 +0530
Message-Id: <1527665983-17319-1-git-send-email-rkothiya@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Rinku Kothiya <rkothiya@redhat.com>
Resolves: bz1413272
---
 nfs-config.service | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/nfs-config.service b/nfs-config.service
index 7f65305..f16b2ed 100644
--- a/nfs-config.service
+++ b/nfs-config.service
@@ -2,6 +2,8 @@
 Description=Preprocess NFS configuration
 After=local-fs.target
 DefaultDependencies=no
+PartOf=nfs-server.service
+Restart=always
 
 [Service]
 Type=oneshot
-- 
2.7.5

