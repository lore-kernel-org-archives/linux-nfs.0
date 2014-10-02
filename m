Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-lb0-f174.google.com ([209.85.217.174]:48755 "EHLO
	mail-lb0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752166AbaJBNmi (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 2 Oct 2014 09:42:38 -0400
Received: by mail-lb0-f174.google.com with SMTP id p9so2246186lbv.19
        for <linux-nfs@vger.kernel.org>; Thu, 02 Oct 2014 06:42:36 -0700 (PDT)
From: =?UTF-8?q?Timo=20Ter=C3=A4s?= <timo.teras@iki.fi>
To: Steve Dickson <SteveD@redhat.com>, linux-nfs@vger.kernel.org,
        ncopa@alpinelinux.org
Cc: =?UTF-8?q?Timo=20Ter=C3=A4s?= <timo.teras@iki.fi>
Subject: [PATCH v2 1/5] Add string.h to source files that need it
Date: Thu,  2 Oct 2014 16:41:57 +0300
Message-Id: <1412257321-5855-2-git-send-email-timo.teras@iki.fi>
In-Reply-To: <1412257321-5855-1-git-send-email-timo.teras@iki.fi>
References: <1412257321-5855-1-git-send-email-timo.teras@iki.fi>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Timo Teräs <timo.teras@iki.fi>
---
 support/include/exportfs.h | 1 +
 support/include/nfsrpc.h   | 1 +
 support/nfs/cacheio.c      | 1 +
 utils/gssd/write_bytes.h   | 1 +
 utils/nfsd/nfssvc.c        | 1 +
 5 files changed, 5 insertions(+)

diff --git a/support/include/exportfs.h b/support/include/exportfs.h
index 9021fae..32711e4 100644
--- a/support/include/exportfs.h
+++ b/support/include/exportfs.h
@@ -10,6 +10,7 @@
 #define EXPORTFS_H
 
 #include <netdb.h>
+#include <string.h>
 
 #include "sockaddr.h"
 #include "nfslib.h"
diff --git a/support/include/nfsrpc.h b/support/include/nfsrpc.h
index 1bfae7a..fbbdb6a 100644
--- a/support/include/nfsrpc.h
+++ b/support/include/nfsrpc.h
@@ -23,6 +23,7 @@
 #ifndef __NFS_UTILS_NFSRPC_H
 #define __NFS_UTILS_NFSRPC_H
 
+#include <string.h>
 #include <rpc/types.h>
 #include <rpc/clnt.h>
 
diff --git a/support/nfs/cacheio.c b/support/nfs/cacheio.c
index 61e07a8..2726d8f 100644
--- a/support/nfs/cacheio.c
+++ b/support/nfs/cacheio.c
@@ -18,6 +18,7 @@
 #include <nfslib.h>
 #include <stdio.h>
 #include <stdio_ext.h>
+#include <string.h>
 #include <ctype.h>
 #include <unistd.h>
 #include <sys/types.h>
diff --git a/utils/gssd/write_bytes.h b/utils/gssd/write_bytes.h
index 4fc72cc..b3f342b 100644
--- a/utils/gssd/write_bytes.h
+++ b/utils/gssd/write_bytes.h
@@ -32,6 +32,7 @@
 #define _WRITE_BYTES_H_
 
 #include <stdlib.h>
+#include <string.h>
 #include <sys/types.h>
 #include <netinet/in.h>		/* for ntohl */
 
diff --git a/utils/nfsd/nfssvc.c b/utils/nfsd/nfssvc.c
index 0675b6a..027e5ac 100644
--- a/utils/nfsd/nfssvc.c
+++ b/utils/nfsd/nfssvc.c
@@ -20,6 +20,7 @@
 #include <fcntl.h>
 #include <errno.h>
 #include <stdlib.h>
+#include <string.h>
 
 #include "nfslib.h"
 #include "xlog.h"
-- 
2.1.2

