Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cpsmtpb-ews04.kpnxchange.com ([213.75.39.7]:61590 "EHLO
	cpsmtpb-ews04.kpnxchange.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1758168Ab3DASB5 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 1 Apr 2013 14:01:57 -0400
Message-ID: <1364839315.21627.69.camel@x61.thuisdomein>
Subject: [PATCH 6/8] nfsd4: do not export "u64" to userspace
From: Paul Bolle <pebolle@tiscali.nl>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
Date: Mon, 01 Apr 2013 20:01:55 +0200
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

nfs4.h exports "u64" to userspace. Use "__u64" instead.

Signed-off-by: Paul Bolle <pebolle@tiscali.nl>
---
0) Tested with a kernel build.

1) I'm guessing userspace doesn't actually use NFS4_MAX_UINT64.

 include/uapi/linux/nfs4.h | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/include/uapi/linux/nfs4.h b/include/uapi/linux/nfs4.h
index 788128e..35f5f4c 100644
--- a/include/uapi/linux/nfs4.h
+++ b/include/uapi/linux/nfs4.h
@@ -150,7 +150,7 @@
 #define NFS4_SECINFO_STYLE4_CURRENT_FH	0
 #define NFS4_SECINFO_STYLE4_PARENT	1
 
-#define NFS4_MAX_UINT64	(~(u64)0)
+#define NFS4_MAX_UINT64	(~(__u64)0)
 
 /* An NFS4 sessions server must support at least NFS4_MAX_OPS operations.
  * If a compound requires more operations, adjust NFS4_MAX_OPS accordingly.
-- 
1.7.11.7

