Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id C5E3A44E05B
	for <linux-nfs@vger.kernel.org>; Mon, 19 Oct 2026 11:46:41 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1792410402; cv=none; b=kpt0HovZf9WFWFU6fvzixuxaIT/E/BGuzqJUrJMXIfzrj/YzDIdlRVp0YBFh+uIReyQTDCh1Tb9pjZwavTODe+iguONaNqBwSz4UZM2TBSHm6ngPG3/eivmpStdUjmc9Twp6czP9/GfTHQF1oukG8F8YJTTjsvfMvcVVRfs6xZc=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1792410402; c=relaxed/simple;
	bh=RU0cUjiNLVtWClG+UGeAm5YT3uI+4EFpikRmwsk9Nig=;
	h=From:Date:Subject:MIME-Version:Content-Type:Message-Id:References:
	 In-Reply-To:To:Cc; b=kf0lsC5jRdOGV2uWS0pJ7Sx8kibaibhg21LrTq4/h6sb90n2C9fD4woJtIsqIQh8gl9wV/bbX8Vm0ntl0UNXSLLp8VZABgzH04F3NUif0KYvqMH43WTL11+QqnlhW7vijLCujoh5PhM/u/5hKwSthgqRPkkBDcoq3gKRd1AOKZU=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=kvUrjphV; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="kvUrjphV"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 4775A1F000C8;
	Mon, 19 Oct 2026 11:46:41 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1792410401;
	bh=HI6KJhezbow7oCvqqDsCCwqIG2YDsQVQ0XY0Y3TWDVY=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=kvUrjphVPmRzCKOrvcjWK7g2/t4FCa7nW6r3Xb8PYMVuhDxO7fg2XQyFDArTVOlp1
	 yOoennbICAbODPM6DbB0OTOl18pr16YicwkgVnnUn2Sdd7jwiEnc5ggIsWQWKu9lJY
	 3j56l8KhUuVhlMa5aO3Rfjjp5bsxkCAqHuuKQLTJkR/bb7V6aGethxthVlp3eSNvQH
	 Kq7NW+QUb99WmAEkUspXbDfe9wSj2E9/RFRB43zdfy0SD+LrMEcVuZwCUxxM424Rpj
	 eumYS3IptHaDIgPMANzMEQuMH5Id3+t7DrYbtHmJ10+9LwE7p3dNBd/Q4+aHQ/Pv5L
	 oon/J2X0wj0Bw==
From: Jeff Layton <jlayton@kernel.org>
Date: Mon, 19 Oct 2026 07:46:25 -0400
Subject: [PATCH nfs-utils v2 5/7] nfsref: flush the export caches with
 cache_flush()
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <20261019-netlink-noproc-v2-5-7d09a49b574b@kernel.org>
References: <20261019-netlink-noproc-v2-0-7d09a49b574b@kernel.org>
In-Reply-To: <20261019-netlink-noproc-v2-0-7d09a49b574b@kernel.org>
To: Steve Dickson <steved@redhat.com>
Cc: Ben Coddington <bcodding@hammerspace.com>, linux-nfs@vger.kernel.org, 
 Jeff Layton <jlayton@kernel.org>
X-Mailer: b4 0.14.3
X-Developer-Signature: v=1; a=openpgp-sha256; l=4388; i=jlayton@kernel.org;
 h=from:subject:message-id; bh=RU0cUjiNLVtWClG+UGeAm5YT3uI+4EFpikRmwsk9Nig=;
 b=owEBbQKS/ZANAwAKAQAOaEEZVoIVAcsmYgBq1gMdRYjHs8cwSb+Z8JUTPlPJqFS7LUZmlH+X9
 KRx1S0VMqqJAjMEAAEKAB0WIQRLwNeyRHGyoYTq9dMADmhBGVaCFQUCatYDHQAKCRAADmhBGVaC
 Ffx5D/0SZV7N4j3P6M7RkjBqd9b240Hdtz3LjLVbptnbXE17J5NJOjHWCJHBeeOGbwrFEBD5+D4
 jV7TDSd7CEX8rR7luc6UW09FHpDjHQPI7nA7VzZX8c+ccb9SWRmlSEBPuEAbqEgCyhRYk3zNIgN
 rtYThJ/qsHcKWweItgsXUtXeFxk4EzUoO9uJPu+RVGe7rD0BhB4b+YjVERJv1boXGS88bCHeYMT
 7eGUkHGvAPiTW9zRczl7um7+EPQ1H2boj9MKOVJxWG59eEpqthyGwnFXppK8kQLxzyHBDakFCdh
 I9bOgGa2cfs+kXyndvZ+7cO1jYn4xHIX6KeIIZZkEaXwazHKcQX2t/0f76iaplZJ9Psq3bcSy7I
 jlVCyjGfJGQVCNc9Tq8Rr7B2ou39vtBfs4k1P3Pt9dKAoXnhlm+z2uUQ6PdCJ5dDz8BhksrSAT/
 Vj6OKNWkfs+JDy/rzsR0kpaxF+NmKTEY8/xMrAYShBLn9zrR/khJH0YYADQSokKNIpq1uTjaUAA
 +/bpyOTR98tTaCa9txSVGFGlsvruejlRS+8Pxj9WXMmy6+4/YxgqnchkEaBbtft/KRRjTjPvplt
 djpehuf7Bnbm8zYWmNUsTnNOCh2AoaZwe5c+3vzaKXo2Hs4sDjz0IFGZUopXoKsIh8mlANvUfKK
 crvJBn18gIvV24g==
X-Developer-Key: i=jlayton@kernel.org; a=openpgp;
 fpr=4BC0D7B24471B2A184EAF5D3000E684119568215

junction_flush_exports_cache() writes the /proc/net/rpc/*/flush files
itself. Call libexport's cache_flush() instead, which flushes over
netlink and falls back to the same /proc files.

- nfsref now links libexport.a and libnl, and defines no_netlink for
  cache_flush().
- Its callers ignore the FedFsStatus; it now always returns FEDFS_OK.

Reviewed-by: Benjamin Coddington <bcodding@hammerspace.com>
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

