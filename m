Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-vb0-f46.google.com ([209.85.212.46]:44401 "EHLO
	mail-vb0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934933Ab2JXOa2 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 24 Oct 2012 10:30:28 -0400
Received: by mail-vb0-f46.google.com with SMTP id ff1so593358vbb.19
        for <linux-nfs@vger.kernel.org>; Wed, 24 Oct 2012 07:30:28 -0700 (PDT)
From: Jeff Layton <jlayton@redhat.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH v3 1/4] nfsd: add a usermodehelper upcall for NFSv4 client ID tracking
Date: Wed, 24 Oct 2012 10:30:15 -0400
Message-Id: <1351089018-24551-2-git-send-email-jlayton@redhat.com>
In-Reply-To: <1351089018-24551-1-git-send-email-jlayton@redhat.com>
References: <1351089018-24551-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Add a new client tracker upcall type that uses call_usermodehelper to
call out to a program. This seems to be the preferred method of
calling out to usermode these days for seldom-called upcalls. It's
simple and doesn't require a running daemon, so it should "just work"
as long as the binary is installed.

The client tracking exit operation is also changed to check for a
NULL pointer before running. The UMH upcall doesn't need to do anything
at module teardown time.

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 fs/nfsd/nfs4recover.c | 134 +++++++++++++++++++++++++++++++++++++++++++++++++-
 1 file changed, 133 insertions(+), 1 deletion(-)

diff --git a/fs/nfsd/nfs4recover.c b/fs/nfsd/nfs4recover.c
index 43295d4..46e4081 100644
--- a/fs/nfsd/nfs4recover.c
+++ b/fs/nfsd/nfs4recover.c
@@ -926,6 +926,137 @@ static struct nfsd4_client_tracking_ops nfsd4_cld_tracking_ops = {
 	.grace_done	= nfsd4_cld_grace_done,
 };
 
+/* upcall via usermodehelper */
+static char cltrack_prog[PATH_MAX] = "/sbin/nfsdcltrack";
+module_param_string(cltrack_prog, cltrack_prog, sizeof(cltrack_prog),
+			S_IRUGO|S_IWUSR);
+MODULE_PARM_DESC(cltrack_prog, "Path to the nfsdcltrack upcall program");
+
+static int
+nfsd4_umh_cltrack_upcall(char *cmd, char *arg)
+{
+	char *envp[] = { NULL };
+	char *argv[4];
+	int ret;
+
+	if (unlikely(!cltrack_prog[0])) {
+		dprintk("%s: cltrack_prog is disabled\n", __func__);
+		return -EACCES;
+	}
+
+	dprintk("%s: cmd: %s\n", __func__, cmd);
+	dprintk("%s: arg: %s\n", __func__, arg ? arg : "(null)");
+
+	argv[0] = (char *)cltrack_prog;
+	argv[1] = cmd;
+	argv[2] = arg;
+	argv[3] = NULL;
+
+	ret = call_usermodehelper(argv[0], argv, envp, UMH_WAIT_PROC);
+	/*
+	 * Disable the upcall mechanism if we're getting an ENOENT or EACCES
+	 * error. The admin can re-enable it on the fly by using sysfs
+	 * once the problem has been fixed.
+	 */
+	if (ret == -ENOENT || ret == -EACCES) {
+		dprintk("NFSD: %s was not found or isn't executable (%d). "
+			"Setting cltrack_prog to blank string!",
+			cltrack_prog, ret);
+		cltrack_prog[0] = '\0';
+	}
+	dprintk("%s: %s return value: %d\n", __func__, cltrack_prog, ret);
+
+	return ret;
+}
+
+static char *
+bin_to_hex_dup(const unsigned char *src, int srclen)
+{
+	int i;
+	char *buf, *hex;
+
+	/* +1 for terminating NULL */
+	buf = kmalloc((srclen * 2) + 1, GFP_KERNEL);
+	if (!buf)
+		return buf;
+
+	hex = buf;
+	for (i = 0; i < srclen; i++) {
+		sprintf(hex, "%2.2x", *src++);
+		hex += 2;
+	}
+	return buf;
+}
+
+static int
+nfsd4_umh_cltrack_init(struct net __attribute__((unused)) *net)
+{
+	return nfsd4_umh_cltrack_upcall("init", NULL);
+}
+
+static void
+nfsd4_umh_cltrack_create(struct nfs4_client *clp)
+{
+	char *hexid;
+
+	hexid = bin_to_hex_dup(clp->cl_name.data, clp->cl_name.len);
+	if (!hexid) {
+		dprintk("%s: can't allocate memory for upcall!\n", __func__);
+		return;
+	}
+	nfsd4_umh_cltrack_upcall("create", hexid);
+	kfree(hexid);
+}
+
+static void
+nfsd4_umh_cltrack_remove(struct nfs4_client *clp)
+{
+	char *hexid;
+
+	hexid = bin_to_hex_dup(clp->cl_name.data, clp->cl_name.len);
+	if (!hexid) {
+		dprintk("%s: can't allocate memory for upcall!\n", __func__);
+		return;
+	}
+	nfsd4_umh_cltrack_upcall("remove", hexid);
+	kfree(hexid);
+}
+
+static int
+nfsd4_umh_cltrack_check(struct nfs4_client *clp)
+{
+	int ret;
+	char *hexid;
+
+	hexid = bin_to_hex_dup(clp->cl_name.data, clp->cl_name.len);
+	if (!hexid) {
+		dprintk("%s: can't allocate memory for upcall!\n", __func__);
+		return -ENOMEM;
+	}
+	ret = nfsd4_umh_cltrack_upcall("check", hexid);
+	kfree(hexid);
+	return ret;
+}
+
+static void
+nfsd4_umh_cltrack_grace_done(struct net __attribute__((unused)) *net,
+				time_t boot_time)
+{
+	char timestr[22]; /* FIXME: better way to determine max size? */
+
+	sprintf(timestr, "%ld", boot_time);
+	nfsd4_umh_cltrack_upcall("gracedone", timestr);
+}
+
+static struct nfsd4_client_tracking_ops nfsd4_umh_tracking_ops = {
+	.init		= nfsd4_umh_cltrack_init,
+	.exit		= NULL,
+	.create		= nfsd4_umh_cltrack_create,
+	.remove		= nfsd4_umh_cltrack_remove,
+	.check		= nfsd4_umh_cltrack_check,
+	.grace_done	= nfsd4_umh_cltrack_grace_done,
+};
+
 int
 nfsd4_client_tracking_init(struct net *net)
 {
@@ -956,7 +1087,8 @@ void
 nfsd4_client_tracking_exit(struct net *net)
 {
 	if (client_tracking_ops) {
-		client_tracking_ops->exit(net);
+		if (client_tracking_ops->exit)
+			client_tracking_ops->exit(net);
 		client_tracking_ops = NULL;
 	}
 }
-- 
1.7.11.7

