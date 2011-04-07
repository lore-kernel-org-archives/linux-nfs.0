Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from seldrel01.sonyericsson.com ([212.209.106.2]:16967 "EHLO
	seldrel01.sonyericsson.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752210Ab1DGHWq (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 7 Apr 2011 03:22:46 -0400
From: Sean Finney <sean.finney@sonyericsson.com>
To: <linux-nfs@vger.kernel.org>
CC: <bfields@fieldses.org>, Sean Finney <sean.finney@sonyericsson.com>
Subject: [PATCH v2 2/2] nfs-utils: Increase the stdio file buffer size for procfs files
Date: Thu, 7 Apr 2011 09:22:28 +0200
Message-ID: <1302160948-5628-2-git-send-email-sean.finney@sonyericsson.com>
In-Reply-To: <1302160948-5628-1-git-send-email-sean.finney@sonyericsson.com>
References: <20110405233552.GB27961@fieldses.org>
 <1302160948-5628-1-git-send-email-sean.finney@sonyericsson.com>
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Previously, when writing to /proc/net/rpc/*/channel, if a cache line
were larger than the default buffer size (likely 1024 bytes), mountd
and svcgssd would split writes into a number of buffer-sized writes.
Each of these writes would get an EINVAL error back from the kernel
procfs handle (it expects line-oriented input and does not account for
multiple/split writes), and no cache update would occur.

When such behavior occurs, NFS clients depending on mountd to finish
the cache operation would block/hang, or receive EPERM, depending on
the context of the operation.  This is likely to happen if a user is a
member of a large (~100-200) number of groups.

Instead, every fopen() on the procfs files in question is followed by
a call to setvbuf(), using a per-file dedicated buffer of
RPC_CHAN_BUF_SIZE length.

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
index 7deb050..4eded17 100644
--- a/utils/mountd/cache.c
+++ b/utils/mountd/cache.c
@@ -739,6 +739,7 @@ struct {
 	char *cache_name;
 	void (*cache_handle)(FILE *f);
 	FILE *f;
+	char vbuf[RPC_CHAN_BUF_SIZE];
 } cachelist[] = {
 	{ "auth.unix.ip", auth_unix_ip},
 	{ "auth.unix.gid", auth_unix_gid},
@@ -757,6 +758,7 @@ void cache_open(void)
 			continue;
 		sprintf(path, "/proc/net/rpc/%s/channel", cachelist[i].cache_name);
 		cachelist[i].f = fopen(path, "r+");
+		setvbuf(cachelist[i].f, cachelist[i].vbuf, _IOLBF, RPC_CHAN_BUF_SIZE);
 	}
 }
 
-- 
1.7.4.1

