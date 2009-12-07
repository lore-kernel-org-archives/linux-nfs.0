From: Benny Halevy <bhalevy@panasas.com>
Subject: [PATCH v2 31/35] posix_acl: resolve compile dependency in posix_acl.h
Date: Mon,  7 Dec 2009 11:36:39 +0200
Message-ID: <1260178599-16019-1-git-send-email-bhalevy@panasas.com>
References: <4B1CCA52.8020900@panasas.com>
Cc: linux-nfs@vger.kernel.org, pnfs@linux-nfs.org,
	linux-fsdevel@vger.kernel.org, Benny Halevy <bhalevy@panasas.com>,
	Alexander Viro <viro@zeniv.linux.org.uk>,
	"J. Bruce Fields" <bfields@fieldses.org>,
	Trond Myklebust <Trond.Myklebust@netapp.com>
To: " J. Bruce Fields" <bfields@citi.umich.edu>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:12160 "EHLO
	daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S934923AbZLGJfn (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 7 Dec 2009 04:35:43 -0500
In-Reply-To: <4B1CCA52.8020900@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

get_cached_acl is defined as inline in posix_acl.h
requiring the full definition of struct inode as it
dereferences its struct inode * parameter.

Cc: Alexander Viro <viro@zeniv.linux.org.uk>
Cc: linux-fsdevel@vger.kernel.org
Cc: J. Bruce Fields <bfields@fieldses.org>
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 include/linux/posix_acl.h |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/include/linux/posix_acl.h b/include/linux/posix_acl.h
index 065a365..f422bbe 100644
--- a/include/linux/posix_acl.h
+++ b/include/linux/posix_acl.h
@@ -8,6 +8,7 @@
 #ifndef __LINUX_POSIX_ACL_H
 #define __LINUX_POSIX_ACL_H
 
+#include <linux/fs.h>
 #include <linux/slab.h>
 
 #define ACL_UNDEFINED_ID	(-1)
-- 
1.6.5.1

