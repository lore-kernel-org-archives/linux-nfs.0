From: Tom Tucker <tom@opengridcomputing.com>
Subject: [RFC,PATCH 15/20] svc: transport file implementation
Date: Mon, 20 Aug 2007 11:23:53 -0500
Message-ID: <20070820162353.15224.58198.stgit@dell3.ogc.int>
References: <20070820162000.15224.65524.stgit@dell3.ogc.int>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1INA2m-0006PR-6H
	for nfs@lists.sourceforge.net; Mon, 20 Aug 2007 09:23:59 -0700
Received: from smtp.opengridcomputing.com ([71.42.183.126])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1INA2p-00044n-60
	for nfs@lists.sourceforge.net; Mon, 20 Aug 2007 09:24:00 -0700
Received: from dell3.ogc.int (localhost [127.0.0.1])
	by smtp.opengridcomputing.com (Postfix) with ESMTP id 6EE227C79D
	for <nfs@lists.sourceforge.net>; Mon, 20 Aug 2007 11:23:53 -0500 (CDT)
In-Reply-To: <20070820162000.15224.65524.stgit@dell3.ogc.int>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net


Create a proc/sys/sunrpc/transport file that contains information 
about the currently registered transports.

Signed-off-by: Tom Tucker <tom@opengridcomputing.com>
---

 include/linux/sunrpc/debug.h |    1 +
 net/sunrpc/svcsock.c         |   28 ++++++++++++++++++++++++++++
 net/sunrpc/sysctl.c          |   40 +++++++++++++++++++++++++++++++++++++++-
 3 files changed, 68 insertions(+), 1 deletions(-)

diff --git a/include/linux/sunrpc/debug.h b/include/linux/sunrpc/debug.h
index 10709cb..89458df 100644
--- a/include/linux/sunrpc/debug.h
+++ b/include/linux/sunrpc/debug.h
@@ -88,6 +88,7 @@ enum {
 	CTL_SLOTTABLE_TCP,
 	CTL_MIN_RESVPORT,
 	CTL_MAX_RESVPORT,
+	CTL_TRANSPORTS,
 };
 
 #endif /* _LINUX_SUNRPC_DEBUG_H_ */
diff --git a/net/sunrpc/svcsock.c b/net/sunrpc/svcsock.c
index d6443e8..276737e 100644
--- a/net/sunrpc/svcsock.c
+++ b/net/sunrpc/svcsock.c
@@ -139,6 +139,34 @@ int svc_unregister_transport(struct svc_
 }
 EXPORT_SYMBOL_GPL(svc_unregister_transport);
 
+/*
+ * Format the transport list for printing
+ */
+int svc_print_transports(char *buf, int maxlen)
+{
+	struct list_head *le;
+	char tmpstr[80];
+	int len = 0;
+	buf[0] = '\0';
+
+	spin_lock(&svc_transport_lock);
+	list_for_each(le, &svc_transport_list) {
+		int slen;
+		struct svc_xprt *xprt =
+			list_entry(le, struct svc_xprt, xpt_list);
+
+		sprintf(tmpstr, "%s %d\n", xprt->xpt_name, xprt->xpt_max_payload);
+		slen = strlen(tmpstr);
+		if (len + slen > maxlen)
+			break;
+		len += slen;
+		strcat(buf, tmpstr);
+	}
+	spin_unlock(&svc_transport_lock);
+
+	return len;
+}
+
 /* apparently the "standard" is that clients close
  * idle connections after 5 minutes, servers after
  * 6 minutes
diff --git a/net/sunrpc/sysctl.c b/net/sunrpc/sysctl.c
index 738db32..683cf90 100644
--- a/net/sunrpc/sysctl.c
+++ b/net/sunrpc/sysctl.c
@@ -27,6 +27,9 @@ unsigned int	nfs_debug;
 unsigned int	nfsd_debug;
 unsigned int	nlm_debug;
 
+/* Transport string */
+char 		xprt_buf[128];
+
 #ifdef RPC_DEBUG
 
 static struct ctl_table_header *sunrpc_table_header;
@@ -48,6 +51,34 @@ rpc_unregister_sysctl(void)
 	}
 }
 
+int svc_print_transports(char *buf, int maxlen);
+static int proc_do_xprt(ctl_table *table, int write, struct file *file,
+			void __user *buffer, size_t *lenp, loff_t *ppos)
+{
+	char tmpbuf[128];
+	int len;
+	if ((*ppos && !write) || !*lenp) {
+		*lenp = 0;
+		return 0;
+	}
+
+	if (write) 
+		return -EINVAL;
+	else {
+
+		len = svc_print_transports(tmpbuf, 128);
+		if (!access_ok(VERIFY_WRITE, buffer, len))
+			return -EFAULT;
+
+		if (__copy_to_user(buffer, tmpbuf, len))
+			return -EFAULT;
+	}
+
+	*lenp -= len;
+	*ppos += len;
+	return 0;
+}
+
 static int
 proc_dodebug(ctl_table *table, int write, struct file *file,
 				void __user *buffer, size_t *lenp, loff_t *ppos)
@@ -111,7 +142,6 @@ done:
 	return 0;
 }
 
-
 static ctl_table debug_table[] = {
 	{
 		.ctl_name	= CTL_RPCDEBUG,
@@ -145,6 +175,14 @@ static ctl_table debug_table[] = {
 		.mode		= 0644,
 		.proc_handler	= &proc_dodebug
 	},
+	{
+		.ctl_name	= CTL_TRANSPORTS,
+		.procname	= "transports",
+		.data		= xprt_buf,
+		.maxlen		= sizeof(xprt_buf),
+		.mode		= 0444,
+		.proc_handler	= &proc_do_xprt,
+	},
 	{ .ctl_name = 0 }
 };
 

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >>  http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
