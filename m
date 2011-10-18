Return-Path: linux-nfs-owner@vger.kernel.org
Received: from e23smtp08.au.ibm.com ([202.81.31.141]:55029 "EHLO
	e23smtp08.au.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932666Ab1JRPeP (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 18 Oct 2011 11:34:15 -0400
Received: from /spool/local
	by au.ibm.com with XMail ESMTP
	for <linux-nfs@vger.kernel.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Tue, 18 Oct 2011 15:32:58 +1000
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
To: agruen@kernel.org, bfields@fieldses.org, akpm@linux-foundation.org,
        viro@zeniv.linux.org.uk, dhowells@redhat.com
Cc: aneesh.kumar@linux.vnet.ibm.com, linux-fsdevel@vger.kernel.org,
        linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
Subject: [PATCH -V7 02/26] vfs: Add hex format for MAY_* flag values
Date: Tue, 18 Oct 2011 21:02:37 +0530
Message-Id: <1318951981-5508-3-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
In-Reply-To: <1318951981-5508-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
References: <1318951981-5508-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>

We are going to add more flags and having them in hex format
make it simpler

Acked-by: David Howells <dhowells@redhat.com>
Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
---
 include/linux/fs.h |   17 +++++++++--------
 1 files changed, 9 insertions(+), 8 deletions(-)

diff --git a/include/linux/fs.h b/include/linux/fs.h
index 277f497..c1884e9 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -58,14 +58,15 @@ struct inodes_stat_t {
 
 #define NR_FILE  8192	/* this can well be larger on a larger system */
 
-#define MAY_EXEC 1
-#define MAY_WRITE 2
-#define MAY_READ 4
-#define MAY_APPEND 8
-#define MAY_ACCESS 16
-#define MAY_OPEN 32
-#define MAY_CHDIR 64
-#define MAY_NOT_BLOCK 128	/* called from RCU mode, don't block */
+#define MAY_EXEC		0x00000001
+#define MAY_WRITE		0x00000002
+#define MAY_READ		0x00000004
+#define MAY_APPEND		0x00000008
+#define MAY_ACCESS		0x00000010
+#define MAY_OPEN		0x00000020
+#define MAY_CHDIR		0x00000040
+/* called from RCU mode, don't block */
+#define MAY_NOT_BLOCK		0x00000080
 
 /*
  * flags in file.f_mode.  Note that FMODE_READ and FMODE_WRITE must correspond
-- 
1.7.5.4

