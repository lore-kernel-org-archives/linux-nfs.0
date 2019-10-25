Return-Path: <SRS0=xsWA=YS=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.7 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id ED752CA9EA0
	for <linux-nfs@archiver.kernel.org>; Fri, 25 Oct 2019 13:41:38 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id C8A8E2054F
	for <linux-nfs@archiver.kernel.org>; Fri, 25 Oct 2019 13:41:38 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1730784AbfJYNli (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Fri, 25 Oct 2019 09:41:38 -0400
Received: from szxga07-in.huawei.com ([45.249.212.35]:58034 "EHLO huawei.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1726285AbfJYNli (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 25 Oct 2019 09:41:38 -0400
Received: from DGGEMS413-HUB.china.huawei.com (unknown [172.30.72.59])
        by Forcepoint Email with ESMTP id 3B463979F537251B7E3F;
        Fri, 25 Oct 2019 21:41:34 +0800 (CST)
Received: from localhost (10.133.213.239) by DGGEMS413-HUB.china.huawei.com
 (10.3.19.213) with Microsoft SMTP Server id 14.3.439.0; Fri, 25 Oct 2019
 21:41:24 +0800
From:   YueHaibing <yuehaibing@huawei.com>
To:     <trond.myklebust@hammerspace.com>, <anna.schumaker@netapp.com>
CC:     <linux-nfs@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
        YueHaibing <yuehaibing@huawei.com>
Subject: [PATCH -next] NFS: remove unneeded semicolon
Date:   Fri, 25 Oct 2019 21:41:19 +0800
Message-ID: <20191025134119.26036-1-yuehaibing@huawei.com>
X-Mailer: git-send-email 2.10.2.windows.1
MIME-Version: 1.0
Content-Type: text/plain
X-Originating-IP: [10.133.213.239]
X-CFilter-Loop: Reflected
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

remove unneeded semicolon.

Signed-off-by: YueHaibing <yuehaibing@huawei.com>
---
 fs/nfs/super.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/fs/nfs/super.c b/fs/nfs/super.c
index a84df7d6..8d8d04b 100644
--- a/fs/nfs/super.c
+++ b/fs/nfs/super.c
@@ -1592,7 +1592,7 @@ static int nfs_parse_mount_options(char *raw,
 					dfprintk(MOUNT, "NFS:   invalid "
 							"lookupcache argument\n");
 					return 0;
-			};
+			}
 			break;
 		case Opt_fscache_uniq:
 			if (nfs_get_option_str(args, &mnt->fscache_uniq))
@@ -1625,7 +1625,7 @@ static int nfs_parse_mount_options(char *raw,
 				dfprintk(MOUNT, "NFS:	invalid	"
 						"local_lock argument\n");
 				return 0;
-			};
+			}
 			break;
 
 		/*
@@ -2585,7 +2585,7 @@ static void nfs_get_cache_cookie(struct super_block *sb,
 		if (mnt_s->fscache_key) {
 			uniq = mnt_s->fscache_key->key.uniquifier;
 			ulen = mnt_s->fscache_key->key.uniq_len;
-		};
+		}
 	} else
 		return;
 
-- 
2.7.4


