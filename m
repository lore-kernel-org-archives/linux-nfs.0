Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-yk0-f173.google.com ([209.85.160.173]:36277 "EHLO
	mail-yk0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752488AbbHCLpC (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 3 Aug 2015 07:45:02 -0400
Received: by ykeo23 with SMTP id o23so10837124yke.3
        for <linux-nfs@vger.kernel.org>; Mon, 03 Aug 2015 04:45:02 -0700 (PDT)
From: Jeff Layton <jlayton@poochiereds.net>
To: trond.myklebust@primarydata.com
Cc: Anna Schumaker <Anna.Schumaker@netapp.com>,
        "J. Bruce Fields" <bfields@fieldses.org>, linux-nfs@vger.kernel.org
Subject: [PATCH] sunrpc: increase UNX_MAXNODENAME from 32 to __NEW_UTS_LEN bytes
Date: Mon,  3 Aug 2015 07:44:53 -0400
Message-Id: <1438602293-11730-1-git-send-email-jeff.layton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The current limit of 32 bytes artificially limits the name string that
we end up stuffing into NFSv4.x client ID blobs. If you have multiple
hosts with long hostnames that only differ near the end, then this can
cause NFSv4 client ID collisions.

Linux nodenames are actually limited to __NEW_UTS_LEN bytes (64), so use
that as the limit instead. Also, use XDR_QUADLEN to specify the slack
length, just for clarity and in case someone in the future changes this
to something not evenly divisible by 4.

Reported-by: Michael Skralivetsky <michael.skralivetsky@primarydata.com>
Signed-off-by: Jeff Layton <jeff.layton@primarydata.com>
---
 include/linux/sunrpc/auth.h | 8 ++++++--
 net/sunrpc/auth_unix.c      | 2 +-
 2 files changed, 7 insertions(+), 3 deletions(-)

diff --git a/include/linux/sunrpc/auth.h b/include/linux/sunrpc/auth.h
index a7cbb570cc5c..1ecf13e148b8 100644
--- a/include/linux/sunrpc/auth.h
+++ b/include/linux/sunrpc/auth.h
@@ -18,9 +18,13 @@
 #include <linux/atomic.h>
 #include <linux/rcupdate.h>
 #include <linux/uidgid.h>
+#include <linux/utsname.h>
 
-/* size of the nodename buffer */
-#define UNX_MAXNODENAME	32
+/*
+ * Size of the nodename buffer. RFC1831 specifies a hard limit of 255 bytes,
+ * but Linux hostnames are actually limited to __NEW_UTS_LEN bytes.
+ */
+#define UNX_MAXNODENAME	__NEW_UTS_LEN
 
 struct rpcsec_gss_info;
 
diff --git a/net/sunrpc/auth_unix.c b/net/sunrpc/auth_unix.c
index 4feda2d0a833..548240dd15fc 100644
--- a/net/sunrpc/auth_unix.c
+++ b/net/sunrpc/auth_unix.c
@@ -23,7 +23,7 @@ struct unx_cred {
 };
 #define uc_uid			uc_base.cr_uid
 
-#define UNX_WRITESLACK		(21 + (UNX_MAXNODENAME >> 2))
+#define UNX_WRITESLACK		(21 + XDR_QUADLEN(UNX_MAXNODENAME))
 
 #if IS_ENABLED(CONFIG_SUNRPC_DEBUG)
 # define RPCDBG_FACILITY	RPCDBG_AUTH
-- 
2.4.3

