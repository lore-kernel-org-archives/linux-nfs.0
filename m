Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:59876 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751374AbcBOT2n (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 15 Feb 2016 14:28:43 -0500
From: Scott Mayhew <smayhew@redhat.com>
To: trond.myklebust@primarydata.com
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH] auth_gss: fix panic in gss_pipe_downcall() in fips mode
Date: Mon, 15 Feb 2016 14:28:41 -0500
Message-Id: <1455564521-21927-1-git-send-email-smayhew@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

md5 is disabled in fips mode, and attempting to import a gss context
using md5 while in fips mode will result in crypto_alg_mod_lookup()
returning -ENOENT, which will make its way back up to
gss_pipe_downcall(), where the BUG() is triggered.  Handling the -ENOENT
allows for a more graceful failure.

Signed-off-by: Scott Mayhew <smayhew@redhat.com>
---
 net/sunrpc/auth_gss/auth_gss.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/net/sunrpc/auth_gss/auth_gss.c b/net/sunrpc/auth_gss/auth_gss.c
index 799e65b..c30fc3b 100644
--- a/net/sunrpc/auth_gss/auth_gss.c
+++ b/net/sunrpc/auth_gss/auth_gss.c
@@ -737,6 +737,9 @@ gss_pipe_downcall(struct file *filp, const char __user *src, size_t mlen)
 		case -ENOSYS:
 			gss_msg->msg.errno = -EAGAIN;
 			break;
+		case -ENOENT:
+			gss_msg->msg.errno = -EPROTONOSUPPORT;
+			break;
 		default:
 			printk(KERN_CRIT "%s: bad return from "
 				"gss_fill_context: %zd\n", __func__, err);
-- 
2.4.3

