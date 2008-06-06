From: Jeff Layton <jlayton@redhat.com>
Subject: [PATCH 2/5] knfsd: clean up nfsd filesystem interfaces
Date: Fri,  6 Jun 2008 11:12:48 -0400
Message-ID: <1212765171-26042-3-git-send-email-jlayton@redhat.com>
References: <1212765171-26042-1-git-send-email-jlayton@redhat.com>
 <1212765171-26042-2-git-send-email-jlayton@redhat.com>
Cc: linux-nfs@vger.kernel.org, nfsv4@linux-nfs.org, neilb@suse.de,
	gnb-cP1dWloDopni96+mSzHFpQC/G2K4zDHf@public.gmane.org
To: bfields@fieldses.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:49157 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757542AbYFFPM5 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 6 Jun 2008 11:12:57 -0400
In-Reply-To: <1212765171-26042-2-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Several of the nfsd filesystem interfaces allow changes to parameters
that don't have any effect on a running nfsd service. They are only ever
checked when nfsd is started. This patch fixes it so that changes to
those procfiles return -EBUSY if nfsd is already running to make it
clear that changes on the fly don't work.

The patch should also close some relatively harmless races between
changing the info in those interfaces and starting nfsd, since these
variables are being moved under the protection of the nfsd_mutex.

Finally, the nfsv4recoverydir file always returns -EINVAL if read. This
patch fixes it to return the recoverydir path as expected.

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 fs/nfsd/nfs4state.c |   17 ++++++++++---
 fs/nfsd/nfsctl.c    |   66 +++++++++++++++++++++++++++++++++++++++++----------
 fs/nfsd/nfssvc.c    |    8 ++++++
 3 files changed, 74 insertions(+), 17 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 8799b87..c602aba 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -3249,12 +3249,14 @@ nfs4_state_shutdown(void)
 	nfs4_unlock_state();
 }
 
+/*
+ * user_recovery_dirname is protected by the nfsd_mutex since it's only
+ * accessed when nfsd is starting.
+ */
 static void
 nfs4_set_recdir(char *recdir)
 {
-	nfs4_lock_state();
 	strcpy(user_recovery_dirname, recdir);
-	nfs4_unlock_state();
 }
 
 /*
@@ -3278,6 +3280,12 @@ nfs4_reset_recoverydir(char *recdir)
 	return status;
 }
 
+char *
+nfs4_recoverydir(void)
+{
+	return user_recovery_dirname;
+}
+
 /*
  * Called when leasetime is changed.
  *
@@ -3286,11 +3294,12 @@ nfs4_reset_recoverydir(char *recdir)
  * we start to register any changes in lease time.  If the administrator
  * really wants to change the lease time *now*, they can go ahead and bring
  * nfsd down and then back up again after changing the lease time.
+ *
+ * user_lease_time is protected by nfsd_mutex since it's only really accessed
+ * when nfsd is starting
  */
 void
 nfs4_reset_lease(time_t leasetime)
 {
-	lock_kernel();
 	user_lease_time = leasetime;
-	unlock_kernel();
 }
diff --git a/fs/nfsd/nfsctl.c b/fs/nfsd/nfsctl.c
index 049d2a9..2c2eb87 100644
--- a/fs/nfsd/nfsctl.c
+++ b/fs/nfsd/nfsctl.c
@@ -509,7 +509,7 @@ out_free:
 	return rv;
 }
 
-static ssize_t write_versions(struct file *file, char *buf, size_t size)
+static ssize_t __write_versions(struct file *file, char *buf, size_t size)
 {
 	/*
 	 * Format:
@@ -572,6 +572,16 @@ static ssize_t write_versions(struct file *file, char *buf, size_t size)
 	return len;
 }
 
+static ssize_t write_versions(struct file *file, char *buf, size_t size)
+{
+	ssize_t rv;
+
+	mutex_lock(&nfsd_mutex);
+	rv = __write_versions(file, buf, size);
+	mutex_unlock(&nfsd_mutex);
+	return rv;
+}
+
 static ssize_t __write_ports(struct file *file, char *buf, size_t size)
 {
 	if (size == 0) {
@@ -675,6 +685,7 @@ static ssize_t __write_ports(struct file *file, char *buf, size_t size)
 static ssize_t write_ports(struct file *file, char *buf, size_t size)
 {
 	ssize_t rv;
+
 	mutex_lock(&nfsd_mutex);
 	rv = __write_ports(file, buf, size);
 	mutex_unlock(&nfsd_mutex);
@@ -714,16 +725,17 @@ static ssize_t write_maxblksize(struct file *file, char *buf, size_t size)
 #ifdef CONFIG_NFSD_V4
 extern time_t nfs4_leasetime(void);
 
-static ssize_t write_leasetime(struct file *file, char *buf, size_t size)
+static ssize_t __write_leasetime(struct file *file, char *buf, size_t size)
 {
 	/* if size > 10 seconds, call
 	 * nfs4_reset_lease() then write out the new lease (seconds) as reply
 	 */
 	char *mesg = buf;
-	int rv;
+	int rv, lease;
 
 	if (size > 0) {
-		int lease;
+		if (nfsd_serv)
+			return -EBUSY;
 		rv = get_int(&mesg, &lease);
 		if (rv)
 			return rv;
@@ -735,24 +747,52 @@ static ssize_t write_leasetime(struct file *file, char *buf, size_t size)
 	return strlen(buf);
 }
 
-static ssize_t write_recoverydir(struct file *file, char *buf, size_t size)
+static ssize_t write_leasetime(struct file *file, char *buf, size_t size)
+{
+	ssize_t rv;
+
+	mutex_lock(&nfsd_mutex);
+	rv = __write_leasetime(file, buf, size);
+	mutex_unlock(&nfsd_mutex);
+	return rv;
+}
+
+extern char *nfs4_recoverydir(void);
+
+static ssize_t __write_recoverydir(struct file *file, char *buf, size_t size)
 {
 	char *mesg = buf;
 	char *recdir;
 	int len, status;
 
-	if (size == 0 || size > PATH_MAX || buf[size-1] != '\n')
-		return -EINVAL;
-	buf[size-1] = 0;
+	if (size > 0) {
+		if (nfsd_serv)
+			return -EBUSY;
+		if (size > PATH_MAX || buf[size-1] != '\n')
+			return -EINVAL;
+		buf[size-1] = 0;
 
-	recdir = mesg;
-	len = qword_get(&mesg, recdir, size);
-	if (len <= 0)
-		return -EINVAL;
+		recdir = mesg;
+		len = qword_get(&mesg, recdir, size);
+		if (len <= 0)
+			return -EINVAL;
 
-	status = nfs4_reset_recoverydir(recdir);
+		status = nfs4_reset_recoverydir(recdir);
+	}
+	sprintf(buf, "%s\n", nfs4_recoverydir());
 	return strlen(buf);
 }
+
+static ssize_t write_recoverydir(struct file *file, char *buf, size_t size)
+{
+	ssize_t rv;
+
+	mutex_lock(&nfsd_mutex);
+	rv = __write_recoverydir(file, buf, size);
+	mutex_unlock(&nfsd_mutex);
+	return rv;
+}
+
 #endif
 
 /*----------------------------------------------------------------------------*/
diff --git a/fs/nfsd/nfssvc.c b/fs/nfsd/nfssvc.c
index 512bd04..929af23 100644
--- a/fs/nfsd/nfssvc.c
+++ b/fs/nfsd/nfssvc.c
@@ -70,6 +70,14 @@ static DEFINE_SPINLOCK(nfsd_call_lock);
  * Transitions of the thread count between zero and non-zero are of particular
  * interest since the svc_serv needs to be created and initialized at that
  * point, or freed.
+ *
+ * Finally, the nfsd_mutex also protects some of the global variables that are
+ * accessed when nfsd starts and that are settable via the write_* routines in
+ * nfsctl.c. In particular:
+ *
+ *	user_recovery_dirname
+ *	user_lease_time
+ *	nfsd_versions
  */
 DEFINE_MUTEX(nfsd_mutex);
 struct svc_serv 		*nfsd_serv;
-- 
1.5.3.6

