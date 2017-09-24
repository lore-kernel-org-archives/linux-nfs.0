Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.gtisc.gatech.edu ([143.215.130.81]:54139 "EHLO
        mx1.gtisc.gatech.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752416AbdIXRHa (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sun, 24 Sep 2017 13:07:30 -0400
From: Meng Xu <mengxu.gatech@gmail.com>
To: bfields@fieldses.org, jlayton@poochiereds.net,
        linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
Cc: meng.xu@gatech.edu, sanidhya@gatech.edu, taesoo@gatech.edu,
        Meng Xu <mengxu.gatech@gmail.com>
Subject: [PATCH] nfsd4: ensure cm_xid does not change across userspace fetches
Date: Sun, 24 Sep 2017 12:59:40 -0400
Message-Id: <1506272380-17769-1-git-send-email-mengxu.gatech@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

cld_pipe_downcall() has two fetches from an overapped userspace memory.
The first fetch copy_from_user(&xid, &cmsg->cm_xid, sizeof(xid)) get
the xid and use xid to lookup the parent struct cld_upcall *cup.
The second fetch copy_from_user(&cup->cu_msg, src, mlen) place the whole
message into &cup->cu_msg.

Since the userspace thread has full control over this &cmsg->cm_xid,
it can race condition to change the cm_xid value across the two fetches,
(say, change from 1 to 2), therefore, de-listing the cup with
cu_msg.cm_xid == 1 but later put cu_msg.cm_xid = 2.

Whether this double-fetch situation is a security critical bug depends
on how cup->cu_msg is used later. However, given that it is hard to
enumerate all the possible use cases, a safer way might be to ensure
that the xid does not change across the fetches, which is what this
patch is for.

Signed-off-by: Meng Xu <mengxu.gatech@gmail.com>
---
 fs/nfsd/nfs4recover.c | 5 +++++
 1 file changed, 5 insertions(+)

diff --git a/fs/nfsd/nfs4recover.c b/fs/nfsd/nfs4recover.c
index 66eaeb1..1abe9ed 100644
--- a/fs/nfsd/nfs4recover.c
+++ b/fs/nfsd/nfs4recover.c
@@ -753,6 +753,11 @@ cld_pipe_downcall(struct file *filp, const char __user *src, size_t mlen)
 	if (copy_from_user(&cup->cu_msg, src, mlen) != 0)
 		return -EFAULT;
 
+	/* ensure that the xid has not been changed */
+	if (cup->cu_msg.cm_xid != xid) {
+		return -EFAULT;
+	}
+
 	wake_up_process(cup->cu_task);
 	return mlen;
 }
-- 
2.7.4

