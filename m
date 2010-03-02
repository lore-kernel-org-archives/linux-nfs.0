From: "J. Bruce Fields" <bfields@citi.umich.edu>
Subject: [PATCH 7/7] nfsd4: document lease/grace-period limits
Date: Tue,  2 Mar 2010 18:12:53 -0500
Message-ID: <1267571573-11844-8-git-send-email-bfields@citi.umich.edu>
References: <1267571573-11844-1-git-send-email-bfields@citi.umich.edu>
 <1267571573-11844-2-git-send-email-bfields@citi.umich.edu>
 <1267571573-11844-3-git-send-email-bfields@citi.umich.edu>
 <1267571573-11844-4-git-send-email-bfields@citi.umich.edu>
 <1267571573-11844-5-git-send-email-bfields@citi.umich.edu>
 <1267571573-11844-6-git-send-email-bfields@citi.umich.edu>
 <1267571573-11844-7-git-send-email-bfields@citi.umich.edu>
Cc: "J. Bruce Fields" <bfields@citi.umich.edu>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:54600 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753908Ab0CBXLn (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 2 Mar 2010 18:11:43 -0500
In-Reply-To: <1267571573-11844-7-git-send-email-bfields@citi.umich.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The current documentation here is out of date, and not quite right.

(Future work: some user documentation would be useful.)

Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
---
 fs/nfsd/nfsctl.c |   15 ++++++++++++---
 1 files changed, 12 insertions(+), 3 deletions(-)

diff --git a/fs/nfsd/nfsctl.c b/fs/nfsd/nfsctl.c
index 7bdaf31..8dd212a 100644
--- a/fs/nfsd/nfsctl.c
+++ b/fs/nfsd/nfsctl.c
@@ -1208,9 +1208,6 @@ static ssize_t write_maxblksize(struct file *file, char *buf, size_t size)
 #ifdef CONFIG_NFSD_V4
 static ssize_t __write_time(struct file *file, char *buf, size_t size, time_t *time)
 {
-	/* if size > 10 seconds, call
-	 * nfs4_reset_lease() then write out the new lease (seconds) as reply
-	 */
 	char *mesg = buf;
 	int rv, i;
 
@@ -1220,6 +1217,18 @@ static ssize_t __write_time(struct file *file, char *buf, size_t size, time_t *t
 		rv = get_int(&mesg, &i);
 		if (rv)
 			return rv;
+		/*
+		 * Some sanity checking.  We don't have a reason for
+		 * these particular numbers, but problems with the
+		 * extremes are:
+		 *	- Too short: the briefest network outage may
+		 *	  cause clients to lose all their locks.  Also,
+		 *	  the frequent polling may be wasteful.
+		 *	- Too long: do you really want reboot recovery
+		 *	  to take more than an hour?  Or to make other
+		 *	  clients wait an hour before being able to
+		 *	  revoke a dead client's locks?
+		 */
 		if (i < 10 || i > 3600)
 			return -EINVAL;
 		*time = i;
-- 
1.6.3.3

