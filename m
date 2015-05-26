Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qk0-f179.google.com ([209.85.220.179]:36108 "EHLO
	mail-qk0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751620AbbEZRsv (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 26 May 2015 13:48:51 -0400
Received: by qkx62 with SMTP id 62so95557375qkx.3
        for <linux-nfs@vger.kernel.org>; Tue, 26 May 2015 10:48:49 -0700 (PDT)
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH v2 02/10] svcrdma: Add missing access_ok() call in svc_rdma.c
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org
Date: Tue, 26 May 2015 13:48:47 -0400
Message-ID: <20150526174847.7061.52013.stgit@klimt.1015granger.net>
In-Reply-To: <20150526174401.7061.43137.stgit@klimt.1015granger.net>
References: <20150526174401.7061.43137.stgit@klimt.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Ensure a proper memory access check is done by read_reset_stat(),
then fix the following compiler warning.

In file included from linux-2.6/include/net/checksum.h:25,
                 from linux-2.6/include/linux/skbuff.h:31,
                 from linux-2.6/include/linux/icmpv6.h:4,
                 from linux-2.6/include/linux/ipv6.h:64,
                 from linux-2.6/include/net/ipv6.h:16,
                 from linux-2.6/include/linux/sunrpc/clnt.h:27,
                 from linux-2.6/net/sunrpc/xprtrdma/svc_rdma.c:47:
In function ‘copy_to_user’,
    inlined from ‘read_reset_stat’ at
linux-2.6/net/sunrpc/xprtrdma/svc_rdma.c:113:
linux-2.6/arch/x86/include/asm/uaccess.h:735: warning:
call to ‘__copy_to_user_overflow’ declared with attribute warning:
copy_to_user() buffer size is not provably correct

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 net/sunrpc/xprtrdma/svc_rdma.c |    8 ++++++--
 1 files changed, 6 insertions(+), 2 deletions(-)

diff --git a/net/sunrpc/xprtrdma/svc_rdma.c b/net/sunrpc/xprtrdma/svc_rdma.c
index c1b6270..8eedb60 100644
--- a/net/sunrpc/xprtrdma/svc_rdma.c
+++ b/net/sunrpc/xprtrdma/svc_rdma.c
@@ -98,7 +98,11 @@ static int read_reset_stat(struct ctl_table *table, int write,
 	else {
 		char str_buf[32];
 		char *data;
-		int len = snprintf(str_buf, 32, "%d\n", atomic_read(stat));
+		int len;
+
+		if (!access_ok(VERIFY_WRITE, buffer, *lenp))
+			return -EFAULT;
+		len = snprintf(str_buf, 32, "%d\n", atomic_read(stat));
 		if (len >= 32)
 			return -EFAULT;
 		len = strlen(str_buf);
@@ -110,7 +114,7 @@ static int read_reset_stat(struct ctl_table *table, int write,
 		len -= *ppos;
 		if (len > *lenp)
 			len = *lenp;
-		if (len && copy_to_user(buffer, str_buf, len))
+		if (len && __copy_to_user(buffer, str_buf, len))
 			return -EFAULT;
 		*lenp = len;
 		*ppos += len;

