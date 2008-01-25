From: "J. Bruce Fields" <bfields@citi.umich.edu>
Subject: [PATCH 085/100] knfsd: Support adding transports by writing portlist file
Date: Fri, 25 Jan 2008 18:17:05 -0500
Message-ID: <1201303040-7779-85-git-send-email-bfields@citi.umich.edu>
References: <20080125231521.GG25141@fieldses.org>
 <1201303040-7779-1-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-2-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-3-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-4-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-5-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-6-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-7-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-8-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-9-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-10-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-11-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-12-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-13-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-14-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-15-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-16-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-17-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-18-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-19-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-20-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-21-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-22-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-23-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-24-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-25-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-26-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-27-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-28-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-29-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-30-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-31-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-32-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-33-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-34-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-35-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-36-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-37-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-38-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-39-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-40-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-41-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-42-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-43-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-44-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-45-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-46-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-47-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-48-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-49-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-50-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-51-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-52-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-53-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-54-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-55-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-56-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-57-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-58-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-59-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-60-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-61-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-62-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-63-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-64-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-65-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-66-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-67-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-68-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-69-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-70-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-71-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-72-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-73-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-74-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-75-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-76-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-77-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-78-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-79-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-80-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-81-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-82-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-83-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-84-git-send-email-bfields@citi.umich.edu>
Cc: Tom Tucker <tom@opengridcomputing.com>,
	"J. Bruce Fields" <bfields@citi.umich.edu>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:47540 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1762184AbYAYXSZ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 25 Jan 2008 18:18:25 -0500
In-Reply-To: <1201303040-7779-84-git-send-email-bfields@citi.umich.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Tom Tucker <tom@opengridcomputing.com>

Update the write handler for the portlist file to allow creating new
listening endpoints on a transport. The general form of the string is:

<transport_name><space><port number>

For example:

echo "tcp 2049" > /proc/fs/nfsd/portlist

This is intended to support the creation of a listening endpoint for
RDMA transports without adding #ifdef code to the nfssvc.c file.

Transports can also be removed as follows:

'-'<transport_name><space><port number>

For example:

echo "-tcp 2049" > /proc/fs/nfsd/portlist

Attempting to add a listener with an invalid transport string results
in EPROTONOSUPPORT and a perror string of "Protocol not supported".

Attempting to remove an non-existent listener (.e.g. bad proto or port)
results in ENOTCONN and a perror string of
"Transport endpoint is not connected"

Signed-off-by: Tom Tucker <tom@opengridcomputing.com>
Acked-by: Neil Brown <neilb@suse.de>
Reviewed-by: Chuck Lever <chuck.lever@oracle.com>
Reviewed-by: Greg Banks <gnb@sgi.com>
Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
---
 fs/lockd/svc.c        |   18 +++++++++++++-----
 fs/nfsd/nfsctl.c      |   49 ++++++++++++++++++++++++++++++++++++++++++++++++-
 net/sunrpc/svc_xprt.c |    2 ++
 3 files changed, 63 insertions(+), 6 deletions(-)

diff --git a/fs/lockd/svc.c b/fs/lockd/svc.c
index 470af01..0822646 100644
--- a/fs/lockd/svc.c
+++ b/fs/lockd/svc.c
@@ -227,17 +227,25 @@ lockd(struct svc_rqst *rqstp)
 static int make_socks(struct svc_serv *serv, int proto)
 {
 	static int warned;
+	struct svc_xprt *xprt;
 	int err = 0;
 
-	if (proto == IPPROTO_UDP || nlm_udpport)
-		if (!svc_find_xprt(serv, "udp", 0, 0))
+	if (proto == IPPROTO_UDP || nlm_udpport) {
+		xprt = svc_find_xprt(serv, "udp", 0, 0);
+		if (!xprt)
 			err = svc_create_xprt(serv, "udp", nlm_udpport,
 					      SVC_SOCK_DEFAULTS);
-	if (err >= 0 && (proto == IPPROTO_TCP || nlm_tcpport))
-		if (!svc_find_xprt(serv, "tcp", 0, 0))
+		else
+			svc_xprt_put(xprt);
+	}
+	if (err >= 0 && (proto == IPPROTO_TCP || nlm_tcpport)) {
+		xprt = svc_find_xprt(serv, "tcp", 0, 0);
+		if (!xprt)
 			err = svc_create_xprt(serv, "tcp", nlm_tcpport,
 					      SVC_SOCK_DEFAULTS);
-
+		else
+			svc_xprt_put(xprt);
+	}
 	if (err >= 0) {
 		warned = 0;
 		err = 0;
diff --git a/fs/nfsd/nfsctl.c b/fs/nfsd/nfsctl.c
index e307972..02c94b9 100644
--- a/fs/nfsd/nfsctl.c
+++ b/fs/nfsd/nfsctl.c
@@ -540,7 +540,7 @@ static ssize_t write_ports(struct file *file, char *buf, size_t size)
 		}
 		return err < 0 ? err : 0;
 	}
-	if (buf[0] == '-') {
+	if (buf[0] == '-' && isdigit(buf[1])) {
 		char *toclose = kstrdup(buf+1, GFP_KERNEL);
 		int len = 0;
 		if (!toclose)
@@ -554,6 +554,53 @@ static ssize_t write_ports(struct file *file, char *buf, size_t size)
 		kfree(toclose);
 		return len;
 	}
+	/*
+	 * Add a transport listener by writing it's transport name
+	 */
+	if (isalpha(buf[0])) {
+		int err;
+		char transport[16];
+		int port;
+		if (sscanf(buf, "%15s %4d", transport, &port) == 2) {
+			err = nfsd_create_serv();
+			if (!err) {
+				err = svc_create_xprt(nfsd_serv,
+						      transport, port,
+						      SVC_SOCK_ANONYMOUS);
+				if (err == -ENOENT)
+					/* Give a reasonable perror msg for
+					 * bad transport string */
+					err = -EPROTONOSUPPORT;
+			}
+			return err < 0 ? err : 0;
+		}
+	}
+	/*
+	 * Remove a transport by writing it's transport name and port number
+	 */
+	if (buf[0] == '-' && isalpha(buf[1])) {
+		struct svc_xprt *xprt;
+		int err = -EINVAL;
+		char transport[16];
+		int port;
+		if (sscanf(&buf[1], "%15s %4d", transport, &port) == 2) {
+			if (port == 0)
+				return -EINVAL;
+			lock_kernel();
+			if (nfsd_serv) {
+				xprt = svc_find_xprt(nfsd_serv, transport,
+						     AF_UNSPEC, port);
+				if (xprt) {
+					svc_close_xprt(xprt);
+					svc_xprt_put(xprt);
+					err = 0;
+				} else
+					err = -ENOTCONN;
+			}
+			unlock_kernel();
+			return err < 0 ? err : 0;
+		}
+	}
 	return -EINVAL;
 }
 
diff --git a/net/sunrpc/svc_xprt.c b/net/sunrpc/svc_xprt.c
index 512c10f..7835973 100644
--- a/net/sunrpc/svc_xprt.c
+++ b/net/sunrpc/svc_xprt.c
@@ -842,6 +842,7 @@ void svc_close_xprt(struct svc_xprt *xprt)
 	clear_bit(XPT_BUSY, &xprt->xpt_flags);
 	svc_xprt_put(xprt);
 }
+EXPORT_SYMBOL_GPL(svc_close_xprt);
 
 void svc_close_all(struct list_head *xprt_list)
 {
@@ -1006,6 +1007,7 @@ struct svc_xprt *svc_find_xprt(struct svc_serv *serv, char *xcl_name,
 		if (port && port != svc_xprt_local_port(xprt))
 			continue;
 		found = xprt;
+		svc_xprt_get(xprt);
 		break;
 	}
 	spin_unlock_bh(&serv->sv_lock);
-- 
1.5.4.rc2.60.gb2e62

