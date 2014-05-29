Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-yh0-f52.google.com ([209.85.213.52]:62548 "EHLO
	mail-yh0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932228AbaE2CzK (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 28 May 2014 22:55:10 -0400
Received: by mail-yh0-f52.google.com with SMTP id z6so9532759yhz.11
        for <linux-nfs@vger.kernel.org>; Wed, 28 May 2014 19:55:09 -0700 (PDT)
Message-ID: <5386A183.5030405@gmail.com>
Date: Thu, 29 May 2014 10:54:59 +0800
From: Kinglong Mee <kinglongmee@gmail.com>
MIME-Version: 1.0
To: "J. Bruce Fields" <bfields@fieldses.org>,
        Trond Myklebust <trond.myklebust@primarydata.com>
CC: Linux NFS Mailing List <linux-nfs@vger.kernel.org>, kinglongmee@gmail.com
Subject: [PATCH] SUNRPC: remove KERN_DEFAULT kernel loglevel from dfprintk
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

When debugging, rpc prints messages for dprintk(KERN_WARNING ...) as,

[ 2780.339988] ^A4nfsd: connect from unprivileged port: 0000:0000:0000:0000:0000:0000:0000:0001, port=35316

Because, it expends as printk(KERN_DEFAULT KERN_WARNING ...).

Signed-off-by: Kinglong Mee <kinglongmee@gmail.com>
---
 include/linux/sunrpc/debug.h | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/include/linux/sunrpc/debug.h b/include/linux/sunrpc/debug.h
index 9385bd7..742e2ac 100644
--- a/include/linux/sunrpc/debug.h
+++ b/include/linux/sunrpc/debug.h
@@ -42,14 +42,14 @@ extern unsigned int		nlm_debug;
 # define dfprintk(fac, args...)	\
 	do { \
 		ifdebug(fac) \
-			printk(KERN_DEFAULT args); \
+			printk(args); \
 	} while (0)
 
 # define dfprintk_rcu(fac, args...)	\
 	do { \
 		ifdebug(fac) { \
 			rcu_read_lock(); \
-			printk(KERN_DEFAULT args); \
+			printk(args); \
 			rcu_read_unlock(); \
 		} \
 	} while (0)
-- 
1.9.3

