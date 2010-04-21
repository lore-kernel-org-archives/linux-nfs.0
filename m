From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 8/9] ktime: introduce ktime_to_ms()
Date: Wed, 21 Apr 2010 13:44:11 -0400
Message-ID: <20100421174410.2037.86045.stgit@localhost.localdomain>
References: <20100421173628.2037.54635.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pw0-f46.google.com ([209.85.160.46]:62429 "EHLO
	mail-pw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756027Ab0DURoN (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 21 Apr 2010 13:44:13 -0400
Received: by pwj9 with SMTP id 9so5323510pwj.19
        for <linux-nfs@vger.kernel.org>; Wed, 21 Apr 2010 10:44:13 -0700 (PDT)
In-Reply-To: <20100421173628.2037.54635.stgit-bi+AKbBUZKY6gyzm1THtWbp2dZbC/Bob@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

To report ktime statistics to user space in milliseconds, a new helper
is required.

When considering how to do this conversion, I didn't immediately see
why the extra step of converting ktime to a timeval was needed.  To
make that more clear, introduce a couple of large comments.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 include/linux/ktime.h |   10 ++++++++--
 1 files changed, 8 insertions(+), 2 deletions(-)

diff --git a/include/linux/ktime.h b/include/linux/ktime.h
index ce59832..e1ceaa9 100644
--- a/include/linux/ktime.h
+++ b/include/linux/ktime.h
@@ -130,7 +130,7 @@ static inline ktime_t timeval_to_ktime(struct timeval tv)
 /* Convert ktime_t to nanoseconds - NOP in the scalar storage format: */
 #define ktime_to_ns(kt)			((kt).tv64)
 
-#else
+#else	/* !((BITS_PER_LONG == 64) || defined(CONFIG_KTIME_SCALAR)) */
 
 /*
  * Helper macros/inlines to get the ktime_t math right in the timespec
@@ -275,7 +275,7 @@ static inline s64 ktime_to_ns(const ktime_t kt)
 	return (s64) kt.tv.sec * NSEC_PER_SEC + kt.tv.nsec;
 }
 
-#endif
+#endif	/* !((BITS_PER_LONG == 64) || defined(CONFIG_KTIME_SCALAR)) */
 
 /**
  * ktime_equal - Compares two ktime_t variables to see if they are equal
@@ -295,6 +295,12 @@ static inline s64 ktime_to_us(const ktime_t kt)
 	return (s64) tv.tv_sec * USEC_PER_SEC + tv.tv_usec;
 }
 
+static inline s64 ktime_to_ms(const ktime_t kt)
+{
+	struct timeval tv = ktime_to_timeval(kt);
+	return (s64) tv.tv_sec * MSEC_PER_SEC + tv.tv_usec / USEC_PER_MSEC;
+}
+
 static inline s64 ktime_us_delta(const ktime_t later, const ktime_t earlier)
 {
        return ktime_to_us(ktime_sub(later, earlier));

