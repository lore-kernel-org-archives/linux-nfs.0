Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-yh0-f46.google.com ([209.85.213.46]:39896 "EHLO
	mail-yh0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754704Ab2JCMkn (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 3 Oct 2012 08:40:43 -0400
Received: by yhmm54 with SMTP id m54so629161yhm.19
        for <linux-nfs@vger.kernel.org>; Wed, 03 Oct 2012 05:40:42 -0700 (PDT)
From: Jeff Layton <jlayton@redhat.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH v2 3/3] nfsd: pass info about the legacy recoverydir in environment variables
Date: Wed,  3 Oct 2012 08:40:31 -0400
Message-Id: <1349268031-16498-4-git-send-email-jlayton@redhat.com>
In-Reply-To: <1349268031-16498-1-git-send-email-jlayton@redhat.com>
References: <1349268031-16498-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The usermodehelper upcall program can then decide to use this info as
a (one-way) transition mechanism to the new scheme. When a "check"
upcall occurs and the client doesn't exist in the database, we can
look to see whether the directory exists. If it does, then we'd add
the client to the database, remove the legacy recdir, and return
success to the kernel to allow the recovery to proceed.

For gracedone, we simply pass the v4recovery "topdir" so that the
upcall can clean it out prior to returning to the kernel.

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 fs/nfsd/nfs4recover.c | 99 ++++++++++++++++++++++++++++++++++++++++++++-------
 1 file changed, 87 insertions(+), 12 deletions(-)

diff --git a/fs/nfsd/nfs4recover.c b/fs/nfsd/nfs4recover.c
index 5a74037..e1d9e2e 100644
--- a/fs/nfsd/nfs4recover.c
+++ b/fs/nfsd/nfs4recover.c
@@ -932,14 +932,77 @@ module_param_string(cltrack_prog, cltrack_prog, sizeof(cltrack_prog),
 			S_IRUGO|S_IWUSR);
 MODULE_PARM_DESC(cltrack_prog, "Path to the nfsdcltrack upcall program");
 
+static bool cltrack_legacy_disable;
+module_param(cltrack_legacy_disable, bool, S_IRUGO|S_IWUSR);
+MODULE_PARM_DESC(cltrack_legacy_disable,
+		 "Disable legacy recoverydir conversion. Default: false");
+
+#define LEGACY_TOPDIR_ENV_PREFIX "NFSDCLTRACK_LEGACY_TOPDIR="
+#define LEGACY_RECDIR_ENV_PREFIX "NFSDCLTRACK_LEGACY_RECDIR="
+
+static char *
+nfsd4_cltrack_legacy_topdir(void)
+{
+	int copied;
+	size_t len;
+	char *result;
+
+	/* don't build the string if legacy conversion is disabled */
+	if (cltrack_legacy_disable)
+		return NULL;
+
+	len = strlen(LEGACY_TOPDIR_ENV_PREFIX) +
+		strlen(nfs4_recoverydir()) + 1;
+
+	result = kmalloc(len, GFP_KERNEL);
+	if (!result)
+		return result;
+
+	copied = snprintf(result, len, LEGACY_TOPDIR_ENV_PREFIX "%s",
+				nfs4_recoverydir());
+	if (copied >= len) {
+		/* just return nothing if output was truncated */
+		kfree(result);
+		return NULL;
+	}
+
+	return result;
+}
+
+static char *
+nfsd4_cltrack_legacy_recdir(const char *recdir)
+{
+	int copied;
+	size_t len;
+	char *result;
+
+	/* don't build the string if legacy conversion is disabled */
+	if (cltrack_legacy_disable)
+		return NULL;
+
+	/* +1 is for '/' between "topdir" and "recdir" */
+	len = strlen(LEGACY_RECDIR_ENV_PREFIX) +
+		strlen(nfs4_recoverydir()) + 1 + HEXDIR_LEN;
+
+	result = kmalloc(len, GFP_KERNEL);
+	if (!result)
+		return result;
+
+	copied = snprintf(result, len, LEGACY_RECDIR_ENV_PREFIX "%s/%s",
+				nfs4_recoverydir(), recdir);
+	if (copied >= len) {
+		/* just return nothing if output was truncated */
+		kfree(result);
+		return NULL;
+	}
+
+	return result;
+}
+
 static int
-nfsd4_cltrack_upcall(char *cmd, char *arg)
+nfsd4_cltrack_upcall(char *cmd, char *arg, char *legacy)
 {
-	char *envp[] = { "HOME=/",
-			"TERM=linux",
-			"PATH=/sbin:/usr/sbin:/bin:/usr/bin",
-			NULL
-	};
+	char *envp[5];
 	char *argv[4];
 	int ret;
 
@@ -950,6 +1013,13 @@ nfsd4_cltrack_upcall(char *cmd, char *arg)
 
 	dprintk("%s: cmd: %s\n", __func__, cmd);
 	dprintk("%s: arg: %s\n", __func__, arg ? arg : "(null)");
+	dprintk("%s: legacy: %s\n", __func__, legacy ? legacy : "(null)");
+
+	envp[0] = "HOME=/";
+	envp[1] = "TERM=linux";
+	envp[2] = "PATH=/sbin:/usr/sbin:/bin:/usr/bin";
+	envp[3] = legacy;
+	envp[4] = NULL;
 
 	argv[0] = (char *)cltrack_prog;
 	argv[1] = cmd;
@@ -996,7 +1066,7 @@ bin_to_hex_dup(const unsigned char *src, int srclen)
 static int
 nfsd4_umh_cltrack_init(struct net __attribute__((unused)) *net)
 {
-	return nfsd4_cltrack_upcall("init", NULL);
+	return nfsd4_cltrack_upcall("init", NULL, NULL);
 }
 
 static void
@@ -1009,7 +1079,7 @@ nfsd4_umh_cltrack_create(struct nfs4_client *clp)
 		dprintk("%s: can't allocate memory for upcall!\n", __func__);
 		return;
 	}
-	nfsd4_cltrack_upcall("create", hexid);
+	nfsd4_cltrack_upcall("create", hexid, NULL);
 	kfree(hexid);
 }
 
@@ -1023,7 +1093,7 @@ nfsd4_umh_cltrack_remove(struct nfs4_client *clp)
 		dprintk("%s: can't allocate memory for upcall!\n", __func__);
 		return;
 	}
-	nfsd4_cltrack_upcall("remove", hexid);
+	nfsd4_cltrack_upcall("remove", hexid, NULL);
 	kfree(hexid);
 }
 
@@ -1031,14 +1101,16 @@ static int
 nfsd4_umh_cltrack_check(struct nfs4_client *clp)
 {
 	int ret;
-	char *hexid;
+	char *hexid, *legacy;
 
 	hexid = bin_to_hex_dup(clp->cl_name.data, clp->cl_name.len);
 	if (!hexid) {
 		dprintk("%s: can't allocate memory for upcall!\n", __func__);
 		return -ENOMEM;
 	}
-	ret = nfsd4_cltrack_upcall("check", hexid);
+	legacy = nfsd4_cltrack_legacy_recdir(clp->cl_recdir);
+	ret = nfsd4_cltrack_upcall("check", hexid, legacy);
+	kfree(legacy);
 	kfree(hexid);
 	return ret;
 }
@@ -1047,10 +1119,13 @@ static void
 nfsd4_umh_cltrack_grace_done(struct net __attribute__((unused)) *net,
 				time_t boot_time)
 {
+	char *legacy;
 	char timestr[22]; /* FIXME: better way to determine max size? */
 
 	sprintf(timestr, "%ld", boot_time);
-	nfsd4_cltrack_upcall("gracedone", timestr);
+	legacy = nfsd4_cltrack_legacy_topdir();
+	nfsd4_cltrack_upcall("gracedone", timestr, legacy);
+	kfree(legacy);
 }
 
 static struct nfsd4_client_tracking_ops nfsd4_umh_tracking_ops = {
-- 
1.7.11.4

