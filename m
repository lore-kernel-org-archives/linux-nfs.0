Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qc0-f171.google.com ([209.85.216.171]:50125 "EHLO
	mail-qc0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754473AbaGBULa (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 2 Jul 2014 16:11:30 -0400
Received: by mail-qc0-f171.google.com with SMTP id w7so10620650qcr.30
        for <linux-nfs@vger.kernel.org>; Wed, 02 Jul 2014 13:11:29 -0700 (PDT)
From: Jeff Layton <jlayton@primarydata.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org,
        Trond Myklebust <trond.myklebust@primarydata.com>
Subject: [PATCH] nfsd: add a new /proc/fs/nfsd/max_connections file
Date: Wed,  2 Jul 2014 16:11:22 -0400
Message-Id: <1404331882-8296-1-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Currently, the maximum number of connections that nfsd will allow
is based on the number of threads spawned. While this is fine for a
default, there really isn't a clear relationship between the two.

The number of threads corresponds to the number of concurrent requests
that we want to allow the server to process at any given time. The
connection limit corresponds to the maximum number of clients that we
want to allow the server to handle. These are two entirely different
quantities.

Break the dependency on increasing threads in order to allow for more
connections, by adding a new per-net parameter that can be set to a
non-zero value. The default is still to base it on the number of threads,
so there should be no behavior change for anyone who doesn't use it.

Cc: Trond Myklebust <trond.myklebust@primarydata.com>
Signed-off-by: Jeff Layton <jlayton@primarydata.com>
---
 fs/nfsd/netns.h  |  6 ++++++
 fs/nfsd/nfsctl.c | 42 ++++++++++++++++++++++++++++++++++++++++++
 fs/nfsd/nfssvc.c |  5 +++++
 3 files changed, 53 insertions(+)

diff --git a/fs/nfsd/netns.h b/fs/nfsd/netns.h
index 4daa485a4a1d..46680da55cd7 100644
--- a/fs/nfsd/netns.h
+++ b/fs/nfsd/netns.h
@@ -103,6 +103,12 @@ struct nfsd_net {
 	/* Time of server startup */
 	struct timeval nfssvc_boot;
 
+	/*
+	 * Max number of connections this nfsd container will allow. Defaults
+	 * to '0' which is means that it bases this on the number of threads.
+	 */
+	unsigned int max_connections;
+
 	u32 clientid_counter;
 
 	struct svc_serv *nfsd_serv;
diff --git a/fs/nfsd/nfsctl.c b/fs/nfsd/nfsctl.c
index 6a6f65cc8b34..4e042105fb6e 100644
--- a/fs/nfsd/nfsctl.c
+++ b/fs/nfsd/nfsctl.c
@@ -39,6 +39,7 @@ enum {
 	NFSD_Versions,
 	NFSD_Ports,
 	NFSD_MaxBlkSize,
+	NFSD_MaxConnections,
 	NFSD_SupportedEnctypes,
 	/*
 	 * The below MUST come last.  Otherwise we leave a hole in nfsd_files[]
@@ -62,6 +63,7 @@ static ssize_t write_pool_threads(struct file *file, char *buf, size_t size);
 static ssize_t write_versions(struct file *file, char *buf, size_t size);
 static ssize_t write_ports(struct file *file, char *buf, size_t size);
 static ssize_t write_maxblksize(struct file *file, char *buf, size_t size);
+static ssize_t write_maxconn(struct file *file, char *buf, size_t size);
 #ifdef CONFIG_NFSD_V4
 static ssize_t write_leasetime(struct file *file, char *buf, size_t size);
 static ssize_t write_gracetime(struct file *file, char *buf, size_t size);
@@ -77,6 +79,7 @@ static ssize_t (*write_op[])(struct file *, char *, size_t) = {
 	[NFSD_Versions] = write_versions,
 	[NFSD_Ports] = write_ports,
 	[NFSD_MaxBlkSize] = write_maxblksize,
+	[NFSD_MaxConnections] = write_maxconn,
 #ifdef CONFIG_NFSD_V4
 	[NFSD_Leasetime] = write_leasetime,
 	[NFSD_Gracetime] = write_gracetime,
@@ -886,6 +889,44 @@ static ssize_t write_maxblksize(struct file *file, char *buf, size_t size)
 							nfsd_max_blksize);
 }
 
+/**
+ * write_maxconn - Set or report the current max number of connections
+ *
+ * Input:
+ *			buf:		ignored
+ *			size:		zero
+ * OR
+ *
+ * Input:
+ * 			buf:		C string containing an unsigned
+ * 					integer value representing the new
+ * 					number of max connections
+ *			size:		non-zero length of C string in @buf
+ * Output:
+ *	On success:	passed-in buffer filled with '\n'-terminated C string
+ *			containing numeric value of max_connections setting
+ *			for this net namespace;
+ *			return code is the size in bytes of the string
+ *	On error:	return code is zero or a negative errno value
+ */
+static ssize_t write_maxconn(struct file *file, char *buf, size_t size)
+{
+	char *mesg = buf;
+	struct net *net = file->f_dentry->d_sb->s_fs_info;
+	struct nfsd_net *nn = net_generic(net, nfsd_net_id);
+	unsigned int maxconn = nn->max_connections;
+
+	if (size > 0) {
+		int rv = get_uint(&mesg, &maxconn);
+
+		if (rv)
+			return rv;
+		nn->max_connections = maxconn;
+	}
+
+	return scnprintf(buf, SIMPLE_TRANSACTION_LIMIT, "%u\n", maxconn);
+}
+
 #ifdef CONFIG_NFSD_V4
 static ssize_t __nfsd4_write_time(struct file *file, char *buf, size_t size,
 				  time_t *time, struct nfsd_net *nn)
@@ -1061,6 +1102,7 @@ static int nfsd_fill_super(struct super_block * sb, void * data, int silent)
 		[NFSD_Versions] = {"versions", &transaction_ops, S_IWUSR|S_IRUSR},
 		[NFSD_Ports] = {"portlist", &transaction_ops, S_IWUSR|S_IRUGO},
 		[NFSD_MaxBlkSize] = {"max_block_size", &transaction_ops, S_IWUSR|S_IRUGO},
+		[NFSD_MaxConnections] = {"max_connections", &transaction_ops, S_IWUSR|S_IRUGO},
 #if defined(CONFIG_SUNRPC_GSS) || defined(CONFIG_SUNRPC_GSS_MODULE)
 		[NFSD_SupportedEnctypes] = {"supported_krb5_enctypes", &supported_enctypes_ops, S_IRUGO},
 #endif /* CONFIG_SUNRPC_GSS or CONFIG_SUNRPC_GSS_MODULE */
diff --git a/fs/nfsd/nfssvc.c b/fs/nfsd/nfssvc.c
index 209474174fe4..5d026dca00ca 100644
--- a/fs/nfsd/nfssvc.c
+++ b/fs/nfsd/nfssvc.c
@@ -405,6 +405,7 @@ int nfsd_create_serv(struct net *net)
 	if (nn->nfsd_serv == NULL)
 		return -ENOMEM;
 
+	nn->nfsd_serv->sv_maxconn = nn->max_connections;
 	error = svc_bind(nn->nfsd_serv, net);
 	if (error < 0) {
 		svc_destroy(nn->nfsd_serv);
@@ -563,6 +564,7 @@ nfsd(void *vrqstp)
 	struct svc_rqst *rqstp = (struct svc_rqst *) vrqstp;
 	struct svc_xprt *perm_sock = list_entry(rqstp->rq_server->sv_permsocks.next, typeof(struct svc_xprt), xpt_list);
 	struct net *net = perm_sock->xpt_net;
+	struct nfsd_net *nn = net_generic(net, nfsd_net_id);
 	int err;
 
 	/* Lock module and set up kernel thread */
@@ -596,6 +598,9 @@ nfsd(void *vrqstp)
 	 * The main request loop
 	 */
 	for (;;) {
+		/* Update sv_maxconn if it has changed */
+		rqstp->rq_server->sv_maxconn = nn->max_connections;
+
 		/*
 		 * Find a socket with data available and call its
 		 * recvfrom routine.
-- 
1.9.3

