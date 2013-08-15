Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:44674 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759352Ab3HORqq (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 15 Aug 2013 13:46:46 -0400
Message-ID: <1376588800.17754.14.camel@serendib>
Subject: [PATCH] sunrpc: prepare NFS for 2038
From: Harshula Jayasuriya <harshula@redhat.com>
To: "J.Bruce Fields" <bfields@citi.umich.edu>
Cc: linux-nfs@vger.kernel.org, NeilBrown <neilb@suse.de>,
        Jeff Layton <jlayton@redhat.com>
Date: Fri, 16 Aug 2013 03:46:40 +1000
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

1) The kernel sunrpc code needs to handle seconds since epoch
greater than 2147483647. This means functions that parse time
as an int need to handle it as time_t.

2) The kernel changes must be accompanied by userspace changes
in nfs-utils.

Signed-off-by: Harshula Jayasuriya <harshula@redhat.com>
---
 include/linux/sunrpc/cache.h | 22 ++++++++++++++++++++--
 1 file changed, 20 insertions(+), 2 deletions(-)

diff --git a/include/linux/sunrpc/cache.h b/include/linux/sunrpc/cache.h
index 6ce690d..437ddb6 100644
--- a/include/linux/sunrpc/cache.h
+++ b/include/linux/sunrpc/cache.h
@@ -264,12 +264,30 @@ static inline int get_uint(char **bpp, unsigned int *anint)
 	return 0;
 }
 
+static inline int get_time(char **bpp, time_t *time)
+{
+	char buf[50];
+	long long ll;
+	int len = qword_get(bpp, buf, sizeof(buf));
+
+	if (len < 0)
+		return -EINVAL;
+	if (len == 0)
+		return -ENOENT;
+
+	if (kstrtoll(buf, 0, &ll))
+		return -EINVAL;
+
+	*time = (time_t)ll;
+	return 0;
+}
+
 static inline time_t get_expiry(char **bpp)
 {
-	int rv;
+	time_t rv;
 	struct timespec boot;
 
-	if (get_int(bpp, &rv))
+	if (get_time(bpp, &rv))
 		return 0;
 	if (rv < 0)
 		return 0;
-- 
1.8.3.1

