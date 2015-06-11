Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qg0-f68.google.com ([209.85.192.68]:35976 "EHLO
	mail-qg0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752928AbbFKSxP (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 11 Jun 2015 14:53:15 -0400
Received: by qgdq107 with SMTP id q107so1787553qgd.3
        for <linux-nfs@vger.kernel.org>; Thu, 11 Jun 2015 11:53:13 -0700 (PDT)
Subject: [PATCH] SUNRPC: Address kbuild warning in net/sunrpc/debugfs.c
From: Chuck Lever <chuck.lever@oracle.com>
To: trond.myklebust@primarydata.com
Cc: linux-nfs@vger.kernel.org
Date: Thu, 11 Jun 2015 13:47:10 -0400
Message-ID: <20150611173818.9447.36961.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Cross-compile test on ARCH=mn10300:

In file included from include/linux/list.h:8:0,
                 from include/linux/wait.h:6,
                 from include/linux/fs.h:6,
                 from include/linux/debugfs.h:18,
                 from net/sunrpc/debugfs.c:7:
net/sunrpc/debugfs.c: In function 'fault_disconnect_write':
include/linux/kernel.h:723:17: warning: comparison of distinct pointer
types lacks a cast
    (void) (&_min1 == &_min2);  \
                   ^
>> net/sunrpc/debugfs.c:307:8: note: in expansion of macro 'min'
    len = min(len, sizeof(buffer) - 1);

Fixes: ('SUNRPC: Transport fault injection')
Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

This gets rid of the pointer magic hidden inside min(). But I've
never had this warning pop with my x86 gcc, so I can't confirm
whether this patch addresses the issue.

 net/sunrpc/debugfs.c |    3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/net/sunrpc/debugfs.c b/net/sunrpc/debugfs.c
index 7cc1b8a..e7b4d93 100644
--- a/net/sunrpc/debugfs.c
+++ b/net/sunrpc/debugfs.c
@@ -304,7 +304,8 @@ fault_disconnect_write(struct file *filp, const char __user *user_buf,
 {
 	char buffer[16];
 
-	len = min(len, sizeof(buffer) - 1);
+	if (len >= sizeof(buffer))
+		len = sizeof(buffer) - 1;
 	if (copy_from_user(buffer, user_buf, len))
 		return -EFAULT;
 	buffer[len] = '\0';

