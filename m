From: "J. Bruce Fields" <bfields@citi.umich.edu>
Subject: [PATCH] sunrpc: fix possible overrun on read of /proc/sys/sunrpc/transports
Date: Mon,  1 Sep 2008 14:51:01 -0400
Message-ID: <1220295062-10957-1-git-send-email-bfields@citi.umich.edu>
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org,
	Cyrill Gorcunov <gorcunov@gmail.com>,
	Ingo Oeser <ioe-lkml-MFZNYGWX9eyELgA04lAiVw@public.gmane.org>, Neil Brown <neilb@suse.de>,
	Chuck Lever <chuck.lever@oracle.com>, Greg Banks <gnb@sgi.com>,
	Tom Tucker <tom@opengridcomputing.com>,
	"J. Bruce Fields" <bfields@citi.umich.edu>
To: stable@kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:57159 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752034AbYIASvN (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 1 Sep 2008 14:51:13 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Cyrill Gorcunov <gorcunov@gmail.com>

Vegard Nossum reported
----------------------
> I noticed that something weird is going on with /proc/sys/sunrpc/transports.
> This file is generated in net/sunrpc/sysctl.c, function proc_do_xprt(). When
> I "cat" this file, I get the expected output:
>    $ cat /proc/sys/sunrpc/transports
>    tcp 1048576
>    udp 32768

> But I think that it does not check the length of the buffer supplied by
> userspace to read(). With my original program, I found that the stack was
> being overwritten by the characters above, even when the length given to
> read() was just 1.

David Wagner added (among other things) that copy_to_user could be
probably used here.

Ingo Oeser suggested to use simple_read_from_buffer() here.

The conclusion is that proc_do_xprt doesn't check for userside buffer
size indeed so fix this by using Ingo's suggestion.

Reported-by: Vegard Nossum <vegard.nossum@gmail.com>
Signed-off-by: Cyrill Gorcunov <gorcunov@gmail.com>
CC: Ingo Oeser <ioe-lkml-MFZNYGWX9eyELgA04lAiVw@public.gmane.org>
Cc: Neil Brown <neilb@suse.de>
Cc: Chuck Lever <chuck.lever@oracle.com>
Cc: Greg Banks <gnb@sgi.com>
Cc: Tom Tucker <tom@opengridcomputing.com>
Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
---
 net/sunrpc/sysctl.c |   18 ++++--------------
 1 files changed, 4 insertions(+), 14 deletions(-)

diff --git a/net/sunrpc/sysctl.c b/net/sunrpc/sysctl.c
index 0f8c439..5231f7a 100644
--- a/net/sunrpc/sysctl.c
+++ b/net/sunrpc/sysctl.c
@@ -60,24 +60,14 @@ static int proc_do_xprt(ctl_table *table, int write, struct file *file,
 			void __user *buffer, size_t *lenp, loff_t *ppos)
 {
 	char tmpbuf[256];
-	int len;
+	size_t len;
+
 	if ((*ppos && !write) || !*lenp) {
 		*lenp = 0;
 		return 0;
 	}
-	if (write)
-		return -EINVAL;
-	else {
-		len = svc_print_xprts(tmpbuf, sizeof(tmpbuf));
-		if (!access_ok(VERIFY_WRITE, buffer, len))
-			return -EFAULT;
-
-		if (__copy_to_user(buffer, tmpbuf, len))
-			return -EFAULT;
-	}
-	*lenp -= len;
-	*ppos += len;
-	return 0;
+	len = svc_print_xprts(tmpbuf, sizeof(tmpbuf));
+	return simple_read_from_buffer(buffer, *lenp, ppos, tmpbuf, len);
 }
 
 static int
-- 
1.5.5.rc1

