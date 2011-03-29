Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from seldrel01.sonyericsson.com ([212.209.106.2]:11432 "EHLO
	seldrel01.sonyericsson.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S933435Ab1CaJhI (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 31 Mar 2011 05:37:08 -0400
Message-ID: <E1Q5EJO-0001R9-3m@seldlx2151.corpusers.net>
From: Sean Finney <Sean.Finney@sonyericsson.com>
Date: Tue, 29 Mar 2011 09:54:03 +0200
Subject: [PATCH] Increase the default buffer size for cachelist channel files.
To: linux-nfs@vger.kernel.org
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Previously, if a cache line were larger than the default buffer size
(likely 1024 bytes), mountd and svcgssd would split writes into a number
of buffer-sized writes, each of which would get an EINVAL error back from
the kernel procfs handler, and no cache update would occur.  NFS clients
depending on mountd to finish the cache operation would block/hang, or
receive EPERM, depending on the context.  This is likely to happen if
a user is a member of a large (~100-200) number of groups.

Really, mountd should not be using stdio-style buffered file operations
on files in /proc to begin with.  A better solution would be to use
internally managed buffers and calls to write() instead of these stdio
calls, but that would be a more extensive change; so this is proposed
as a quick and not-so-dirty fix in the meantime.

Signed-off-by: Sean Finney <sean.finney@sonyericsson.com>
---
 support/include/misc.h    |    3 +++
 utils/gssd/svcgssd_proc.c |    3 +++
 utils/mountd/cache.c      |    2 ++
 3 files changed, 8 insertions(+), 0 deletions(-)

diff --git a/support/include/misc.h b/support/include/misc.h
index 9a1b25d..7e3874e 100644
--- a/support/include/misc.h
+++ b/support/include/misc.h
@@ -24,4 +24,7 @@ struct hostent *get_reliable_hostbyaddr(const char *addr, int len, int type);
 
 extern int is_mountpoint(char *path);
 
+/* size of the file pointer buffers for rpc procfs files */
+#define RPC_CHAN_BUF_SIZE 32768
+
 #endif /* MISC_H */
diff --git a/utils/gssd/svcgssd_proc.c b/utils/gssd/svcgssd_proc.c
index 6f2ba61..8f6548e 100644
--- a/utils/gssd/svcgssd_proc.c
+++ b/utils/gssd/svcgssd_proc.c
@@ -56,6 +56,7 @@
 #include "gss_util.h"
 #include "err_util.h"
 #include "context.h"
+#include "misc.h"
 
 extern char * mech2file(gss_OID mech);
 #define SVCGSSD_CONTEXT_CHANNEL "/proc/net/rpc/auth.rpcsec.context/channel"
@@ -78,6 +79,7 @@ do_svc_downcall(gss_buffer_desc *out_handle, struct svc_cred *cred,
 	FILE *f;
 	int i;
 	char *fname = NULL;
+	char vbuf[RPC_CHAN_BUF_SIZE];
 	int err;
 
 	printerr(1, "doing downcall\n");
@@ -90,6 +92,7 @@ do_svc_downcall(gss_buffer_desc *out_handle, struct svc_cred *cred,
 			     SVCGSSD_CONTEXT_CHANNEL, strerror(errno));
 		goto out_err;
 	}
+	setvbuf(f, vbuf, _IOLBF, RPC_CHAN_BUF_SIZE);
 	qword_printhex(f, out_handle->value, out_handle->length);
 	/* XXX are types OK for the rest of this? */
 	/* For context cache, use the actual context endtime */
diff --git a/utils/mountd/cache.c b/utils/mountd/cache.c
index 75a1052..b4bd6cf 100644
--- a/utils/mountd/cache.c
+++ b/utils/mountd/cache.c
@@ -729,6 +729,7 @@ struct {
 	char *cache_name;
 	void (*cache_handle)(FILE *f);
 	FILE *f;
+	char vbuf[RPC_CHAN_BUF_SIZE];
 } cachelist[] = {
 	{ "auth.unix.ip", auth_unix_ip},
 	{ "auth.unix.gid", auth_unix_gid},
@@ -747,6 +748,7 @@ void cache_open(void)
 			continue;
 		sprintf(path, "/proc/net/rpc/%s/channel", cachelist[i].cache_name);
 		cachelist[i].f = fopen(path, "r+");
+		setvbuf(cachelist[i].f, cachelist[i].vbuf, _IOLBF, RPC_CHAN_BUF_SIZE);
 	}
 }
 
-- 
1.7.2.3

