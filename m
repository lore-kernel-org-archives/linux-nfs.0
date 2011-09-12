Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-gw0-f46.google.com ([74.125.83.46]:35403 "EHLO
	mail-gw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754945Ab1ILWGn (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 12 Sep 2011 18:06:43 -0400
Received: by gwb15 with SMTP id 15so442001gwb.19
        for <linux-nfs@vger.kernel.org>; Mon, 12 Sep 2011 15:06:43 -0700 (PDT)
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 5/8] sm-notify: Refactor insert_host() and recv_rpcbind_reply()
To: linux-nfs@vger.kernel.org
Date: Mon, 12 Sep 2011 18:06:41 -0400
Message-ID: <20110912220641.10854.80600.stgit@matisse.1015granger.net>
In-Reply-To: <20110912220304.10854.20972.stgit@matisse.1015granger.net>
References: <20110912220304.10854.20972.stgit@matisse.1015granger.net>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Clean up: refactor the logic in recv_rpcbind_reply() that re-schedules
an nsm_host into a separate helper function

Adjust debugging messages so it's always apparent when an nsm_host is
rescheduled.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 utils/statd/sm-notify.c |   42 ++++++++++++++++++++++++++----------------
 1 files changed, 26 insertions(+), 16 deletions(-)

diff --git a/utils/statd/sm-notify.c b/utils/statd/sm-notify.c
index 2421f8b..46447e8 100644
--- a/utils/statd/sm-notify.c
+++ b/utils/statd/sm-notify.c
@@ -252,7 +252,6 @@ smn_get_host(const char *hostname,
 		return 0;
 
 	insert_host(host);
-	xlog(D_GENERAL, "Added host %s to notify list", hostname);
 	return 1;
 }
 
@@ -688,6 +687,25 @@ notify_host(int sock, struct nsm_host *host)
 	return 0;
 }
 
+static void
+smn_defer(struct nsm_host *host)
+{
+	host->xid = 0;
+	host->send_next = time(NULL) + NSM_MAX_TIMEOUT;
+	host->timeout = NSM_MAX_TIMEOUT;
+	insert_host(host);
+}
+
+static void
+smn_schedule(struct nsm_host *host)
+{
+	host->xid = 0;
+	host->send_next = time(NULL);
+	if (host->timeout >= NSM_MAX_TIMEOUT / 4)
+		host->timeout = NSM_MAX_TIMEOUT / 4;
+	insert_host(host);
+}
+
 /*
  * Extract the returned port number and set up the SM_NOTIFY call.
  */
@@ -696,21 +714,16 @@ recv_rpcbind_reply(struct sockaddr *sap, struct nsm_host *host, XDR *xdr)
 {
 	uint16_t port = nsm_recv_rpcbind(sap->sa_family, xdr);
 
-	host->send_next = time(NULL);
-	host->xid = 0;
-
 	if (port == 0) {
 		/* No binding for statd... */
 		xlog(D_GENERAL, "No statd on host %s", host->name);
-		host->timeout = NSM_MAX_TIMEOUT;
-		host->send_next += NSM_MAX_TIMEOUT;
+		smn_defer(host);
 	} else {
+		xlog(D_GENERAL, "Processing rpcbind reply for %s (port %u)",
+			host->name, port);
 		nfs_set_port(sap, port);
-		if (host->timeout >= NSM_MAX_TIMEOUT / 4)
-			host->timeout = NSM_MAX_TIMEOUT / 4;
+		smn_schedule(host);
 	}
-
-	insert_host(host);
 }
 
 /*
@@ -727,11 +740,7 @@ recv_notify_reply(struct nsm_host *host)
 
 	if (dot != NULL) {
 		*dot = '\0';
-		host->send_next = time(NULL);
-		host->xid = 0;
-		if (host->timeout >= NSM_MAX_TIMEOUT / 4)
-			host->timeout = NSM_MAX_TIMEOUT / 4;
-		insert_host(host);
+		smn_schedule(host);
 	} else {
 		xlog(D_GENERAL, "Host %s notified successfully", host->name);
 		smn_forget_host(host);
@@ -780,7 +789,7 @@ out:
 }
 
 /*
- * Insert host into sorted list
+ * Insert host into notification list, sorted by next send time
  */
 static void
 insert_host(struct nsm_host *host)
@@ -805,6 +814,7 @@ insert_host(struct nsm_host *host)
 
 	host->next = *where;
 	*where = host;
+	xlog(D_GENERAL, "Added host %s to notify list", host->name);
 }
 
 /*

