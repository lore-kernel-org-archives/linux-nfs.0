Return-Path: <SRS0=6Ngb=3K=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.7 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	UNPARSEABLE_RELAY,USER_AGENT_GIT autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 07C7AC33CAA
	for <linux-nfs@archiver.kernel.org>; Tue, 21 Jan 2020 08:50:19 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id DE0CA24125
	for <linux-nfs@archiver.kernel.org>; Tue, 21 Jan 2020 08:50:18 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1728811AbgAUIuC (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 21 Jan 2020 03:50:02 -0500
Received: from out30-131.freemail.mail.aliyun.com ([115.124.30.131]:50184 "EHLO
        out30-131.freemail.mail.aliyun.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1727962AbgAUIuB (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 21 Jan 2020 03:50:01 -0500
X-Alimail-AntiSpam: AC=PASS;BC=-1|-1;BR=01201311R701e4;CH=green;DM=||false|;DS=||;FP=0|-1|-1|-1|0|-1|-1|-1;HT=e01f04446;MF=alex.shi@linux.alibaba.com;NM=1;PH=DS;RN=4;SR=0;TI=SMTPD_---0ToHXcih_1579596597;
Received: from localhost(mailfrom:alex.shi@linux.alibaba.com fp:SMTPD_---0ToHXcih_1579596597)
          by smtp.aliyun-inc.com(127.0.0.1);
          Tue, 21 Jan 2020 16:49:58 +0800
From:   Alex Shi <alex.shi@linux.alibaba.com>
Cc:     Trond Myklebust <trond.myklebust@hammerspace.com>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
Subject: [PATCH] NFS: remove unused macros
Date:   Tue, 21 Jan 2020 16:49:56 +0800
Message-Id: <1579596596-258247-1-git-send-email-alex.shi@linux.alibaba.com>
X-Mailer: git-send-email 1.8.3.1
To:     unlisted-recipients:; (no To-header on input)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

MNT_fhs_status_sz/MNT_fhandle3_sz are never used after they were
introduced. So better to remove them.

Signed-off-by: Alex Shi <alex.shi@linux.alibaba.com>
Cc: Trond Myklebust <trond.myklebust@hammerspace.com> 
Cc: Anna Schumaker <anna.schumaker@netapp.com> 
Cc: linux-nfs@vger.kernel.org 
Cc: linux-kernel@vger.kernel.org 
---
 fs/nfs/mount_clnt.c | 2 --
 1 file changed, 2 deletions(-)

diff --git a/fs/nfs/mount_clnt.c b/fs/nfs/mount_clnt.c
index cb7c10e9721e..35c8cb2d7637 100644
--- a/fs/nfs/mount_clnt.c
+++ b/fs/nfs/mount_clnt.c
@@ -29,9 +29,7 @@
  */
 #define encode_dirpath_sz	(1 + XDR_QUADLEN(MNTPATHLEN))
 #define MNT_status_sz		(1)
-#define MNT_fhs_status_sz	(1)
 #define MNT_fhandle_sz		XDR_QUADLEN(NFS2_FHSIZE)
-#define MNT_fhandle3_sz		(1 + XDR_QUADLEN(NFS3_FHSIZE))
 #define MNT_authflav3_sz	(1 + NFS_MAX_SECFLAVORS)
 
 /*
-- 
1.8.3.1

