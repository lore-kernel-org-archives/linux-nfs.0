Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pf0-f193.google.com ([209.85.192.193]:36755 "EHLO
        mail-pf0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1761026AbcJ1OhJ (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 28 Oct 2016 10:37:09 -0400
Received: by mail-pf0-f193.google.com with SMTP id n85so1456613pfi.3
        for <linux-nfs@vger.kernel.org>; Fri, 28 Oct 2016 07:37:09 -0700 (PDT)
From: Wei Yongjun <weiyj.lk@gmail.com>
To: Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>
Cc: Wei Yongjun <weiyongjun1@huawei.com>, linux-nfs@vger.kernel.org
Subject: [PATCH] NFS: fix typo in parameter description
Date: Fri, 28 Oct 2016 14:37:02 +0000
Message-Id: <1477665422-32543-1-git-send-email-weiyj.lk@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Wei Yongjun <weiyongjun1@huawei.com>

Fix typo in parameter description.

Fixes: 5405fc44c337 ("NFSv4.x: Add kernel parameter to control the
callback server")
Signed-off-by: Wei Yongjun <weiyongjun1@huawei.com>
---
 fs/nfs/super.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/fs/nfs/super.c b/fs/nfs/super.c
index 001796b..ddce94ce 100644
--- a/fs/nfs/super.c
+++ b/fs/nfs/super.c
@@ -2904,7 +2904,7 @@ module_param(max_session_slots, ushort, 0644);
 MODULE_PARM_DESC(max_session_slots, "Maximum number of outstanding NFSv4.1 "
 		"requests the client will negotiate");
 module_param(max_session_cb_slots, ushort, 0644);
-MODULE_PARM_DESC(max_session_slots, "Maximum number of parallel NFSv4.1 "
+MODULE_PARM_DESC(max_session_cb_slots, "Maximum number of parallel NFSv4.1 "
 		"callbacks the client will process for a given server");
 module_param(send_implementation_id, ushort, 0644);
 MODULE_PARM_DESC(send_implementation_id,

