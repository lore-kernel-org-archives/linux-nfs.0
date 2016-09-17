Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:37658 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754733AbcIQWRo (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Sat, 17 Sep 2016 18:17:44 -0400
From: Jeff Layton <jlayton@redhat.com>
To: trond.myklebust@primarydata.com, anna.schumaker@netapp.com
Cc: linux-nfs@vger.kernel.org, bfields@fieldses.org
Subject: [PATCH v4 4/9] nfs: add a new NFS4_OPEN_RESULT_MAY_NOTIFY_LOCK constant
Date: Sat, 17 Sep 2016 18:17:34 -0400
Message-Id: <1474150659-23894-5-git-send-email-jlayton@redhat.com>
In-Reply-To: <1474150659-23894-1-git-send-email-jlayton@redhat.com>
References: <1474150659-23894-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

As defined in RFC 5661, section 18.16.

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 include/uapi/linux/nfs4.h | 5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/include/uapi/linux/nfs4.h b/include/uapi/linux/nfs4.h
index 2b871e0858d9..4ae62796bfde 100644
--- a/include/uapi/linux/nfs4.h
+++ b/include/uapi/linux/nfs4.h
@@ -39,8 +39,9 @@
 #define NFS4_FH_VOL_MIGRATION		0x0004
 #define NFS4_FH_VOL_RENAME		0x0008
 
-#define NFS4_OPEN_RESULT_CONFIRM 0x0002
-#define NFS4_OPEN_RESULT_LOCKTYPE_POSIX 0x0004
+#define NFS4_OPEN_RESULT_CONFIRM		0x0002
+#define NFS4_OPEN_RESULT_LOCKTYPE_POSIX		0x0004
+#define NFS4_OPEN_RESULT_MAY_NOTIFY_LOCK	0x0020
 
 #define NFS4_SHARE_ACCESS_MASK	0x000F
 #define NFS4_SHARE_ACCESS_READ	0x0001
-- 
2.7.4

