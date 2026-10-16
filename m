Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id AC4274DE710
	for <linux-nfs@vger.kernel.org>; Fri, 16 Oct 2026 14:16:24 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1792160189; cv=none; b=ul78jVId46wHuOE0kdh5YEBCAhCI+hkdBXVRF/qFRV3bTm2Qlo0JvzCWzn2YGwUImiTds3m7nTXzdXi00P8fxfC6M+i2vjzEutzLxSlVG1MY0pfFlcdkvBKgkf2r6c1q23ouJiU3TyXHlRNQV4gAzhu3LWxgM5buM/7xpByH4rk=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1792160189; c=relaxed/simple;
	bh=GDSh0lZTgwwtanjzcfDZ5+T5kHjGzP5j1SA6C8sXB/I=;
	h=From:Date:Subject:MIME-Version:Content-Type:Message-Id:References:
	 In-Reply-To:To:Cc; b=blKW+Qhp8Ny2lZrEemXSQNqsGlUTO9pcNv7hQ8lgLDGwpPt7fM9GXUNsockHF0qgTunJq724UQrAJ0TwgLdLL2YvXwAXTbzrZtlBxodsefkPqymQOTbNONlvZAIk0haDp1atx78cNdZ1fUN5Xbp9xrluR5O7RdEd4L+0K6az08c=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=OfRzZmb9; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="OfRzZmb9"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 4DC621F000CA;
	Fri, 16 Oct 2026 14:16:21 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1792160181;
	bh=WaZp01kQgXBqu0DsS8l3oGNXqxvGVZ4mrN989kPs25M=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=OfRzZmb9CVpQkOFyA8lPvN68l/aA66qv5Olz+Fvz1e8vdhDVyFgt8GRvzbHjCM65U
	 3yfUT4ibnOPycMHGinYHMsyHx7QXd4jOj3dYt2CFU0YFPTib5eRfhv7Zy78U7FfSLy
	 QhdMGC6kY1fy6HGvUzxZv9mquE0vplcLWFvbfXPOMWo/Mnv+WMXas97Q3Cxi6s30GM
	 ebUfPGWCPv7UDZB4gX13AXRUOn/nLAZaZUIorpc/PWn0yBnsgefJsSXNR0NOxw06ja
	 QKOthI5He18UPKrpW+HbiUuEKKXr5OtP0l1wO+h7Wd+INuWJW+FY/lPM2HE1YakLu0
	 vq6yXKWHPdfrQ==
From: Jeff Layton <jlayton@kernel.org>
Date: Fri, 16 Oct 2026 10:15:41 -0400
Subject: [PATCH nfs-utils 5/7] nfsref: flush the export caches with
 cache_flush()
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <20261016-netlink-noproc-v1-5-42791f4b6eb5@kernel.org>
References: <20261016-netlink-noproc-v1-0-42791f4b6eb5@kernel.org>
In-Reply-To: <20261016-netlink-noproc-v1-0-42791f4b6eb5@kernel.org>
To: Steve Dickson <steved@redhat.com>
Cc: linux-nfs@vger.kernel.org, Jeff Layton <jlayton@kernel.org>
X-Mailer: b4 0.14.3
X-Developer-Signature: v=1; a=openpgp-sha256; l=4327; i=jlayton@kernel.org;
 h=from:subject:message-id; bh=GDSh0lZTgwwtanjzcfDZ5+T5kHjGzP5j1SA6C8sXB/I=;
 b=owEBbQKS/ZANAwAKAQAOaEEZVoIVAcsmYgBq0jGyTnn3ySZSelyjyvoAl04Ilfr7JFlEDIwc+
 tNUy5yrvo+JAjMEAAEKAB0WIQRLwNeyRHGyoYTq9dMADmhBGVaCFQUCatIxsgAKCRAADmhBGVaC
 Fe1qEACAs7Y++SCCjeWfcrdQzf7T7k5DKHnWjS23wpFo5yg0FOOAzhxWtGozSNUfxAdNNEW8Air
 2IqIlLAGPBPUGymHAmJ8Q1AD5hWShI1UWVxy0BV7eZeiqtUHNMjG+3G0ZB/29OCYyLZteVdmZio
 U9qQnF2lA2XBWL2fNVeXuGIpG54YcaHaBlByS0WNHsCqyNzI1goCZL2drC9k096DKrlvnH2Ki6X
 zAqEyY5/RsU/DqpBR2v4wCkYeuYYneBYAhNTlHfj8qZu9SbIuGVMkQTiYmh8Mn5YRHbq3/xv4U4
 zzRDRGeOE7QWefB0RbSAQBdTTc/TdCgAV2bKPVqacbLAPP1OVg13Uk1Mi64TGqHPk3Ib4x4ALxK
 bwZmoN56mJbGR0dbZpwWe65jMMtJEH5Y9sWPdJaL+bVg5iiTqtw0Rd1xHDQxAiI8Oa7w5vw8TZ5
 cVYCy08F1uBuj4sUR3CKFRMldJYOg+FU65iHWeN9IgL+LklIiUu4ZYKwbgN+A/3U0exnGW/RTAz
 OhTKnKTNZXRZi/69+hWn6e0QPHWys6PP+36n03tCYrgVFqHgWcnx1RUUI9UAfY4g+STy8qpeC8u
 TRIbITYIoYL+iZGco1rxng84U5FN0ny6YBfkWLT7pYCZuL4kUx/+rSzHyIPPWtPTvU20yIms/bH
 UXYpCBOFROZE1Kg==
X-Developer-Key: i=jlayton@kernel.org; a=openpgp;
 fpr=4BC0D7B24471B2A184EAF5D3000E684119568215

junction_flush_exports_cache() writes the /proc/net/rpc/*/flush files
itself. Call libexport's cache_flush() instead, which flushes over
netlink and falls back to the same /proc files.

- nfsref now links libexport.a and libnl, and defines no_netlink for
  cache_flush().
- Its callers ignore the FedFsStatus; it now always returns FEDFS_OK.

Signed-off-by: Jeff Layton <jlayton@kernel.org>
---
 support/junction/export-cache.c | 82 +++--------------------------------------
 utils/nfsref/Makefile.am        |  4 +-
 utils/nfsref/nfsref.c           |  5 +++
 3 files changed, 13 insertions(+), 78 deletions(-)

diff --git a/support/junction/export-cache.c b/support/junction/export-cache.c
index 00187c019d60..09b69743b874 100644
--- a/support/junction/export-cache.c
+++ b/support/junction/export-cache.c
@@ -23,96 +23,24 @@
  *	http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt
  */
 
-#include <sys/types.h>
-#include <sys/stat.h>
-
 #include <stdbool.h>
-#include <stdio.h>
-#include <stdlib.h>
-#include <string.h>
-#include <unistd.h>
-#include <fcntl.h>
-#include <time.h>
-
 
 #include "junction.h"
+#include "nfslib.h"
 #include "xlog.h"
 
-/**
- * Ordered list of proc files to poke when requesting an NFSD cache flush
- */
-static const char *junction_proc_files[] = {
-	"/proc/net/rpc/auth.unix.ip/flush",
-	"/proc/net/rpc/auth.unix.gid/flush",
-	"/proc/net/rpc/nfsd.fh/flush",
-	"/proc/net/rpc/nfsd.export/flush",
-	NULL,
-};
-
-/**
- * Write time into one file
- *
- * @param pathname NUL-terminated C string containing POSIX pathname of file to write
- * @param flushtime NUL-terminated C string containing current time in seconds since the Epoch
- * @return a FedFsStatus code
- */
-static FedFsStatus
-junction_write_time(const char *pathname, const char *flushtime)
-{
-	FedFsStatus retval;
-	ssize_t len;
-	int fd;
-
-	fd = open(pathname, O_RDWR);
-	if (fd == -1) {
-		xlog(D_GENERAL, "%s: Failed to open %s: %m",
-			__func__, pathname);
-		/* If the proc files don't exist, no server
-		 * is running on this system */
-		return FEDFS_ERR_NO_CACHE_UPDATE;
-	}
-
-	len = write(fd, flushtime, strlen(flushtime));
-	if (len != (ssize_t)strlen(flushtime)) {
-		xlog(D_GENERAL, "%s: Failed to write %s: %m",
-			__func__, pathname);
-		/* If the proc files exist but the update failed,
-		 * we don't know the state of the cache */
-		retval = FEDFS_ERR_UNKNOWN_CACHE;
-	} else
-		/* Cache flush succeeded */
-		retval = FEDFS_OK;
-
-	(void)close(fd);
-	return retval;
-}
-
 /**
  * Flush the kernel NFSD's exports cache
  *
+ * cache_flush() uses netlink when the kernel offers it, and falls back
+ * to the /proc flush files otherwise.
+ *
  * @return a FedFsStatus code
  */
 FedFsStatus
 junction_flush_exports_cache(void)
 {
-	FedFsStatus retval;
-	char flushtime[20];
-	unsigned int i;
-	time_t now;
-
 	xlog(D_CALL, "%s: Flushing NFSD caches...", __func__);
-
-	now = time(NULL);
-	if (now == -1) {
-		xlog(D_GENERAL, "%s: time(3) failed", __func__);
-		return FEDFS_ERR_SVRFAULT;
-	}
-	snprintf(flushtime, sizeof(flushtime), "%lld\n", (long long)now);
-
-	for (i = 0; junction_proc_files[i] != NULL; i++) {
-		retval = junction_write_time(junction_proc_files[i], flushtime);
-		if (retval != FEDFS_OK)
-			return retval;
-	}
+	cache_flush();
 	return FEDFS_OK;
 }
diff --git a/utils/nfsref/Makefile.am b/utils/nfsref/Makefile.am
index 2409dd00cfa1..6a602a8e68eb 100644
--- a/utils/nfsref/Makefile.am
+++ b/utils/nfsref/Makefile.am
@@ -29,7 +29,9 @@ sbin_PROGRAMS		= nfsref
 nfsref_SOURCES		= add.c lookup.c nfsref.c remove.c
 LDADD			= ../../support/nfs/libnfs.la \
 			  ../../support/junction/libjunction.la \
-			  $(LIBXML2) $(LIBCAP)
+			  ../../support/export/libexport.a \
+			  $(LIBXML2) $(LIBCAP) \
+			  $(LIBNL3_LIBS) $(LIBNLGENL3_LIBS)
 
 man8_MANS		= nfsref.man
 
diff --git a/utils/nfsref/nfsref.c b/utils/nfsref/nfsref.c
index aa8414b425fb..f66f11a3d4bc 100644
--- a/utils/nfsref/nfsref.c
+++ b/utils/nfsref/nfsref.c
@@ -43,6 +43,11 @@
 #include "xlog.h"
 #include "nfsref.h"
 
+/**
+ * Lets cache_flush() try netlink before the /proc flush files
+ */
+int no_netlink;
+
 /**
  * Short form command line options
  */

-- 
2.56.0

