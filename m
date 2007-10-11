From: Tom Tucker <tom@opengridcomputing.com>
Subject: [RFC,
	PATCH 3/3] knfsd: Modify write_ports to use svc_find_xprt service
Date: Wed, 10 Oct 2007 21:29:01 -0500
Message-ID: <20071011022901.3501.5244.stgit@dell3.ogc.int>
References: <20071011022356.3501.63859.stgit@dell3.ogc.int>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: bfields@fieldses.org, neilb@suse.de, gnb@sgi.com
To: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IfnnK-0007A2-Ev
	for nfs@lists.sourceforge.net; Wed, 10 Oct 2007 19:29:02 -0700
Received: from 209-198-142-2-host.prismnet.net ([209.198.142.2]
	helo=smtp.opengridcomputing.com)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IfnnP-0001Oq-Fx
	for nfs@lists.sourceforge.net; Wed, 10 Oct 2007 19:29:07 -0700
In-Reply-To: <20071011022356.3501.63859.stgit@dell3.ogc.int>
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


This patch enhances the write_ports function as follows:

- Check if a server transport instance already exists before attempting to 
  create a new one, and 

- Implement the ability to remove a previously created server transport
  instance. 

Signed-off-by: Tom Tucker <tom@opengridcomputing.com>
---

 fs/nfsd/nfsctl.c      |   36 +++++++++++++++++++++++++++++++++---
 net/sunrpc/svc_xprt.c |    1 +
 2 files changed, 34 insertions(+), 3 deletions(-)

diff --git a/fs/nfsd/nfsctl.c b/fs/nfsd/nfsctl.c
index 923b817..0dfc130 100644
--- a/fs/nfsd/nfsctl.c
+++ b/fs/nfsd/nfsctl.c
@@ -540,7 +540,7 @@ static ssize_t write_ports(struct file *
 		}
 		return err < 0 ? err : 0;
 	}
-	if (buf[0] == '-') {
+	if (buf[0] == '-' && isdigit(buf[1])) {
 		char *toclose = kstrdup(buf+1, GFP_KERNEL);
 		int len = 0;
 		if (!toclose)
@@ -557,16 +557,46 @@ static ssize_t write_ports(struct file *
 	/*
 	 * Add a transport listener by writing it's transport name
 	 */
-	if (isalnum(buf[0])) {
+	if (isalpha(buf[0])) {
 		int err;
 		char transport[16];
 		int port;
 		if (sscanf(buf, "%15s %4d", transport, &port) == 2) {
 			err = nfsd_create_serv();
-			if (!err)
+			if (!err) {
+				if (svc_find_xprt(nfsd_serv, transport,
+						  AF_UNSPEC, port))
+					return -EADDRINUSE;
+
 				err = svc_create_xprt(nfsd_serv,
 						      transport, port,
 						      SVC_SOCK_ANONYMOUS);
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
+					err = 0;
+				} else
+					err = -ENOENT;
+			}
+			unlock_kernel();
 			return err < 0 ? err : 0;
 		}
 	}
diff --git a/net/sunrpc/svc_xprt.c b/net/sunrpc/svc_xprt.c
index 5fc8d41..cbf80b0 100644
--- a/net/sunrpc/svc_xprt.c
+++ b/net/sunrpc/svc_xprt.c
@@ -809,6 +809,7 @@ void svc_close_xprt(struct svc_xprt *xpr
 	clear_bit(XPT_BUSY, &xprt->xpt_flags);
 	svc_xprt_put(xprt);
 }
+EXPORT_SYMBOL_GPL(svc_close_xprt);
 
 void svc_close_all(struct list_head *xprt_list)
 {

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >> http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
