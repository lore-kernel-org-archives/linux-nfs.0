Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:41448 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751124AbcIUJ1v (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 21 Sep 2016 05:27:51 -0400
Received: from int-mx11.intmail.prod.int.phx2.redhat.com (int-mx11.intmail.prod.int.phx2.redhat.com [10.5.11.24])
        (using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
        (No client certificate requested)
        by mx1.redhat.com (Postfix) with ESMTPS id A0C2B31B302
        for <linux-nfs@vger.kernel.org>; Wed, 21 Sep 2016 09:27:50 +0000 (UTC)
From: yongcheng.yang@gmail.com
To: linux-nfs@vger.kernel.org
Cc: SteveD@redhat.com, yoyang@redhat.com
Subject: [PATCH] osd_login: argc appears unused after defined
Date: Wed, 21 Sep 2016 17:27:45 +0800
Message-Id: <1474450065-25925-1-git-send-email-yongcheng.yang@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Yongcheng Yang <yoyang@redhat.com>

Signed-off-by: Yongcheng Yang <yoyang@redhat.com>
---

It's maybe nitpicking. But can avoid the "Shell Check Warning".

Thanks,
Yongcheng

 utils/osd_login/osd_login | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/utils/osd_login/osd_login b/utils/osd_login/osd_login
index 08cd2d2..f7f1aa3 100644
--- a/utils/osd_login/osd_login
+++ b/utils/osd_login/osd_login
@@ -48,7 +48,7 @@ usage()
 parse_cmdline()
 {
 	argc=$#
-	if [ $# -lt 3 ]; then
+	if [ $argc -lt 3 ]; then
 		usage
 		exit 1
 	fi
-- 
2.4.11

