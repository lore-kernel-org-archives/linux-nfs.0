Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-we0-f170.google.com ([74.125.82.170]:36611 "EHLO
	mail-we0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753714Ab3JBOge (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 2 Oct 2013 10:36:34 -0400
Received: by mail-we0-f170.google.com with SMTP id u57so198806wes.29
        for <linux-nfs@vger.kernel.org>; Wed, 02 Oct 2013 07:36:33 -0700 (PDT)
Message-ID: <524C2F6D.1060703@primarydata.com>
Date: Wed, 02 Oct 2013 17:36:29 +0300
From: Benny Halevy <bhalevy@primarydata.com>
MIME-Version: 1.0
To: Alexander Viro <viro@zeniv.linux.org.uk>
CC: linux-fsdevel@vger.kernel.org, NFS list <linux-nfs@vger.kernel.org>,
        Christoph Hellwig <hch@infradead.org>
Subject: [PATCH] posix_acl: resolve compile dependency in posix_acl.h
References: <1380220974-14716-1-git-send-email-bhalevy@primarydata.com>
In-Reply-To: <1380220974-14716-1-git-send-email-bhalevy@primarydata.com>
Content-Type: multipart/mixed;
 boundary="------------050608090404020108080607"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This is a multi-part message in MIME format.
--------------050608090404020108080607
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit

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




--------------050608090404020108080607
Content-Type: text/plain; charset=UTF-8;
 name="Attached Message Part"
Content-Transfer-Encoding: base64
Content-Disposition: attachment;
 filename="Attached Message Part"


--------------050608090404020108080607--
