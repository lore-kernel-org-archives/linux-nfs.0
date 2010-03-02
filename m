From: "J. Bruce Fields" <bfields@citi.umich.edu>
Subject: [PATCH 5/7] nfsd4: reshuffle lease-setting code to allow reuse
Date: Tue,  2 Mar 2010 18:12:51 -0500
Message-ID: <1267571573-11844-6-git-send-email-bfields@citi.umich.edu>
References: <1267571573-11844-1-git-send-email-bfields@citi.umich.edu>
 <1267571573-11844-2-git-send-email-bfields@citi.umich.edu>
 <1267571573-11844-3-git-send-email-bfields@citi.umich.edu>
 <1267571573-11844-4-git-send-email-bfields@citi.umich.edu>
 <1267571573-11844-5-git-send-email-bfields@citi.umich.edu>
Cc: "J. Bruce Fields" <bfields@citi.umich.edu>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:54596 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753858Ab0CBXLn (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 2 Mar 2010 18:11:43 -0500
In-Reply-To: <1267571573-11844-5-git-send-email-bfields@citi.umich.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

We'll soon allow setting the grace period, so we'll want to share this
code.

Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
---
 fs/nfsd/nfsctl.c |   29 +++++++++++++++++------------
 1 files changed, 17 insertions(+), 12 deletions(-)

diff --git a/fs/nfsd/nfsctl.c b/fs/nfsd/nfsctl.c
index 7f70704..1db8010 100644
--- a/fs/nfsd/nfsctl.c
+++ b/fs/nfsd/nfsctl.c
@@ -1203,26 +1203,36 @@ static ssize_t write_maxblksize(struct file *file, char *buf, size_t size)
 }
 
 #ifdef CONFIG_NFSD_V4
-static ssize_t __write_leasetime(struct file *file, char *buf, size_t size)
+static ssize_t __write_time(struct file *file, char *buf, size_t size, time_t *time)
 {
 	/* if size > 10 seconds, call
 	 * nfs4_reset_lease() then write out the new lease (seconds) as reply
 	 */
 	char *mesg = buf;
-	int rv, lease;
+	int rv, i;
 
 	if (size > 0) {
 		if (nfsd_serv)
 			return -EBUSY;
-		rv = get_int(&mesg, &lease);
+		rv = get_int(&mesg, &i);
 		if (rv)
 			return rv;
-		if (lease < 10 || lease > 3600)
+		if (i < 10 || i > 3600)
 			return -EINVAL;
-		nfsd4_lease = lease;
+		*time = i;
 	}
 
-	return scnprintf(buf, SIMPLE_TRANSACTION_LIMIT, "%ld\n", nfsd4_lease);
+	return scnprintf(buf, SIMPLE_TRANSACTION_LIMIT, "%ld\n", *time);
+}
+
+static ssize_t write_time(struct file *file, char *buf, size_t size, time_t *time)
+{
+	ssize_t rv;
+
+	mutex_lock(&nfsd_mutex);
+	rv = __write_time(file, buf, size, time);
+	mutex_unlock(&nfsd_mutex);
+	return rv;
 }
 
 /**
@@ -1239,12 +1249,7 @@ static ssize_t __write_leasetime(struct file *file, char *buf, size_t size)
  */
 static ssize_t write_leasetime(struct file *file, char *buf, size_t size)
 {
-	ssize_t rv;
-
-	mutex_lock(&nfsd_mutex);
-	rv = __write_leasetime(file, buf, size);
-	mutex_unlock(&nfsd_mutex);
-	return rv;
+	return write_time(file, buf, size, &nfsd4_lease);
 }
 
 extern char *nfs4_recoverydir(void);
-- 
1.6.3.3

