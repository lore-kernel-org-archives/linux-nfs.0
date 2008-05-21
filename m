From: Theodore Tso <tytso@mit.edu>
Subject: [PATCH, E2FSPROGS] blkid: If the device mtime is newer that the
	cache time, force a revalidation
Date: Wed, 21 May 2008 11:58:20 -0400
Message-ID: <20080521155820.GJ8581@mit.edu>
References: <20080519190356.GH15035@mit.edu> <200805202232.m4KMWD11020355@agora.fsl.cs.sunysb.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
	Trond Myklebust <Trond.Myklebust@netapp.com>,
	Kevin Coffman <kwc@umich.edu>, nfs@lists.sourceforge.net,
	linux-nfs@vger.kernel.org, Himanshu Kanda <hkanda-EX0cT3Az47bauI2f2gSDlQ@public.gmane.org>
To: Erez Zadok <ezk-EX0cT3Az47bauI2f2gSDlQ@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from www.church-of-our-saviour.ORG ([69.25.196.31]:40477 "EHLO
	thunker.thunk.org" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1755213AbYEUP7V (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 21 May 2008 11:59:21 -0400
In-Reply-To: <200805202232.m4KMWD11020355-zop+azHP2WsZjdeEBZXbMidm6ipF23ct@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This fixes problems turned up by a test case written by Erez Zadok's
group which constantly reformats filesystems.

Signed-off-by: "Theodore Ts'o" <tytso@mit.edu>
---
 lib/blkid/probe.c |   48 +++++++++++++++++++++++++++---------------------
 1 files changed, 27 insertions(+), 21 deletions(-)

diff --git a/lib/blkid/probe.c b/lib/blkid/probe.c
index 4964209..62ab392 100644
--- a/lib/blkid/probe.c
+++ b/lib/blkid/probe.c
@@ -1214,33 +1214,39 @@ blkid_dev blkid_verify(blkid_cache cache, blkid_dev dev)
 	now = time(0);
 	diff = now - dev->bid_time;
 
-	if ((now > dev->bid_time) && (diff > 0) && 
+	if (stat(dev->bid_name, &st) < 0) {
+		DBG(DEBUG_PROBE,
+		    printf("blkid_verify: error %s (%d) while "
+			   "trying to stat %s\n", strerror(errno), errno,
+			   dev->bid_name));
+	open_err:
+		if ((errno == EPERM) || (errno == EACCES) || (errno == ENOENT)) {
+			/* We don't have read permission, just return cache data. */
+			DBG(DEBUG_PROBE, printf("returning unverified data for %s\n",
+						dev->bid_name));
+			return dev;
+		}
+		blkid_free_dev(dev);
+		return NULL;
+	}
+
+	if ((now >= dev->bid_time) &&
+	    (st.st_mtime <= dev->bid_time) &&
 	    ((diff < BLKID_PROBE_MIN) || 
 	     (dev->bid_flags & BLKID_BID_FL_VERIFIED &&
 	      diff < BLKID_PROBE_INTERVAL)))
 		return dev;
 
 	DBG(DEBUG_PROBE,
-	    printf("need to revalidate %s (time since last check %llu)\n", 
-		   dev->bid_name, (unsigned long long)diff));
-
-	if (((probe.fd = open(dev->bid_name, O_RDONLY)) < 0) ||
-	    (fstat(probe.fd, &st) < 0)) {
-		if (probe.fd >= 0) close(probe.fd);
-		if ((errno != EPERM) && (errno != EACCES) &&
-		    (errno != ENOENT)) {
-			DBG(DEBUG_PROBE, 
-			    printf("blkid_verify: error %s (%d) while "
-				   "opening %s\n", strerror(errno), errno, 
-				   dev->bid_name));
-			blkid_free_dev(dev);
-			return NULL;
-		}
-		/* We don't have read permission, just return cache data. */
-		DBG(DEBUG_PROBE,
-		    printf("returning unverified data for %s\n",
-			   dev->bid_name));
-		return dev;
+	    printf("need to revalidate %s (cache time %d, stat time %d,\n\t"
+		   "time since last check %lu)\n",
+		   dev->bid_name, dev->bid_time, st.st_mtime, (unsigned long)diff));
+
+	if ((probe.fd = open(dev->bid_name, O_RDONLY)) < 0) {
+		DBG(DEBUG_PROBE, printf("blkid_verify: error %s (%d) while "
+					"opening %s\n", strerror(errno), errno, 
+					dev->bid_name));
+		goto open_err;
 	}
 
 	probe.cache = cache;
-- 
1.5.4.1.144.gdfee-dirty

