Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qc0-f174.google.com ([209.85.216.174]:33502 "EHLO
	mail-qc0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750820AbbEDQSy (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 4 May 2015 12:18:54 -0400
Received: by qcvz3 with SMTP id z3so25067762qcv.0
        for <linux-nfs@vger.kernel.org>; Mon, 04 May 2015 09:18:53 -0700 (PDT)
Received: from klimt.1015granger.net ([2604:8800:100:81fc:be5f:f4ff:fed6:c3ba])
        by mx.google.com with ESMTPSA id i14sm10054107qkh.5.2015.05.04.09.18.52
        for <linux-nfs@vger.kernel.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 04 May 2015 09:18:52 -0700 (PDT)
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH v1 2/8] svcrdma: Add missing access_ok() call in svc_rdma.c
To: linux-nfs@vger.kernel.org
Date: Mon, 04 May 2015 12:18:51 -0400
Message-ID: <20150504161851.16870.87838.stgit@klimt.1015granger.net>
In-Reply-To: <20150504160738.16870.19295.stgit@klimt.1015granger.net>
References: <20150504160738.16870.19295.stgit@klimt.1015granger.net>
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

