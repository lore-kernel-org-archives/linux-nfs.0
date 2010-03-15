From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 2/2] sm-notify: Send fully-qualified and unqualified mon_names
Date: Mon, 15 Mar 2010 13:51:45 -0400
Message-ID: <20100315175145.2586.1215.stgit@localhost.localdomain>
References: <20100315174453.2586.40876.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: steved@redhat.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from qw-out-2122.google.com ([74.125.92.25]:37534 "EHLO
	qw-out-2122.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752707Ab0CORvw (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 15 Mar 2010 13:51:52 -0400
Received: by qw-out-2122.google.com with SMTP id 9so784198qwb.37
        for <linux-nfs@vger.kernel.org>; Mon, 15 Mar 2010 10:51:52 -0700 (PDT)
In-Reply-To: <20100315174453.2586.40876.stgit-bi+AKbBUZKY6gyzm1THtWbp2dZbC/Bob@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

During any file locking interaction between an NFS client and server,
the client tells the server what hostname it will use as the mon_name
argument of the SM_NOTIFY request sent by the client when it reboots.
This is the "caller_name" argument of an NLMPROC_LOCK request.

The server, however, never tells the client what mon_name argument
it will use when sending an SM_NOTIFY request.  In order to recognize
the server, clients usually guess what mon_name the server might
send, by using the server hostname provided by the user on the mount
command line.

Frequently, the user provides an unqualified server name on the mount
command.  The server might then call the client back with a fully
qualified domain name, which might not match in some cases.

Solaris, and perhaps other implementations, attempt to mitigate this
problem by sending two SM_NOTIFY requests to each peer: one with an
unqualified mon_name argument, and one with a fully qualified mon_name.

Implement such a scheme for sm-notify.

Since my_name is almost always the fully-qualified hostname associated
with the local system, just wiping the left-most '.' in the my_name
argument and sending another SM_NOTIFY is nearly always sufficient.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 utils/statd/sm-notify.c |   21 +++++++++++++++++----
 1 files changed, 17 insertions(+), 4 deletions(-)

diff --git a/utils/statd/sm-notify.c b/utils/statd/sm-notify.c
index 2d14668..437e37a 100644
--- a/utils/statd/sm-notify.c
+++ b/utils/statd/sm-notify.c
@@ -634,15 +634,28 @@ recv_rpcbind_reply(struct sockaddr *sap, struct nsm_host *host, XDR *xdr)
 }
 
 /*
- * Successful NOTIFY call. Server returns void, so nothing
- * we need to do here.
+ * Successful NOTIFY call. Server returns void.
+ *
+ * Try sending another SM_NOTIFY with an unqualified "my_name"
+ * argument.  Reuse the port number.  If "my_name" is already
+ * unqualified, we're done.
  */
 static void
 recv_notify_reply(struct nsm_host *host)
 {
-	xlog(D_GENERAL, "Host %s notified successfully", host->name);
+	char *dot = strchr(host->my_name, '.');
 
-	smn_forget_host(host);
+	if (dot != NULL) {
+		*dot = '\0';
+		host->send_next = time(NULL);
+		host->xid = 0;
+		if (host->timeout >= NSM_MAX_TIMEOUT / 4)
+			host->timeout = NSM_MAX_TIMEOUT / 4;
+		insert_host(host);
+	} else {
+		xlog(D_GENERAL, "Host %s notified successfully", host->name);
+		smn_forget_host(host);
+	}
 }
 
 /*

