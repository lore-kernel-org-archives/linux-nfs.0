Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qe0-f45.google.com ([209.85.128.45]:39594 "EHLO
	mail-qe0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753005Ab3IZSm7 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 26 Sep 2013 14:42:59 -0400
Received: by mail-qe0-f45.google.com with SMTP id 6so1089336qea.18
        for <linux-nfs@vger.kernel.org>; Thu, 26 Sep 2013 11:42:58 -0700 (PDT)
From: Benny Halevy <bhalevy@primarydata.com>
To: " J. Bruce Fields" <bfields@redhat.com>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH RFC v0 44/49] posix_acl: resolve compile dependency in posix_acl.h
Date: Thu, 26 Sep 2013 14:42:54 -0400
Message-Id: <1380220974-14716-1-git-send-email-bhalevy@primarydata.com>
In-Reply-To: <52447EA0.7070004@primarydata.com>
References: <52447EA0.7070004@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Benny Halevy <bhalevy@panasas.com>

get_cached_acl is defined as inline in posix_acl.h
requiring the full definition of struct inode as it
dereferences its struct inode * parameter.

Cc: Alexander Viro <viro@zeniv.linux.org.uk>
Cc: linux-fsdevel@vger.kernel.org
Cc: J. Bruce Fields <bfields@fieldses.org>
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
Signed-off-by: Benny Halevy <bhalevy@primarydata.com>
---
 include/linux/posix_acl.h | 1 +
 1 file changed, 1 insertion(+)

diff --git a/include/linux/posix_acl.h b/include/linux/posix_acl.h
index 7931efe..a7d8b04 100644
--- a/include/linux/posix_acl.h
+++ b/include/linux/posix_acl.h
@@ -9,6 +9,7 @@
 #define __LINUX_POSIX_ACL_H
 
 #include <linux/bug.h>
+#include <linux/fs.h>
 #include <linux/slab.h>
 #include <linux/rcupdate.h>
 
-- 
1.8.3.1

