From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 29/29] statd: Send unqualified and fully qualified mon_name in
	SM_NOTIFY
Date: Tue, 10 Nov 2009 17:01:15 -0500
Message-ID: <20091110220115.23822.96182.stgit@matisse.1015granger.net>
References: <20091110215447.23822.15275.stgit@matisse.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org, Chris.Mason@oracle.com
To: steved@redhat.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from acsinet12.oracle.com ([141.146.126.234]:30707 "EHLO
	acsinet12.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757278AbZKJWBc (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 10 Nov 2009 17:01:32 -0500
In-Reply-To: <20091110215447.23822.15275.stgit-RytpoXr2tKZ9HhUboXbp9zCvJB+x5qRC@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

During any file locking interaction between an NFS client and server,
the client tells the server what hostname to use as the mon_name
argument of an SM_NOTIFY request.

The server, however, never tells the client what mon_name argument
it will use when sending an SM_NOTIFY request.  In order to recognize
the server, clients usually guess what mon_name the server might send
by using the server hostname provided by the user on the mount
command line.

Sometimes, however, the user provides an unqualified server name.  The
server might then call the client back with a fully qualified domain
name, which might not match.

Solaris, and perhaps other implementations, attempt to mitigate this
problem by sending two SM_NOTIFY requests: one with an unqualified
mon_name argument, and one with a fully qualified mon_name.

Implement such a scheme for sm-notify.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 utils/statd/sm-notify.c |   19 ++++++++++++++++---
 1 files changed, 16 insertions(+), 3 deletions(-)

diff --git a/utils/statd/sm-notify.c b/utils/statd/sm-notify.c
index e883ae9..5c4d38f 100644
--- a/utils/statd/sm-notify.c
+++ b/utils/statd/sm-notify.c
@@ -149,13 +149,13 @@ smn_get_host(const char *hostname,
 		__attribute__((unused)) const struct sockaddr *sap,
 		const struct mon *mon, const time_t timestamp)
 {
+	char *c, my_name[SM_MAXSTRLEN + 1];
 	struct nsm_host	*host;
-	char *my_name;
 
 	if (opt_srcaddr)
-		my_name = nsm_hostname;
+		strncpy(my_name, nsm_hostname, sizeof(my_name) - 1);
 	else
-		my_name = mon->mon_id.my_id.my_name;
+		strncpy(my_name, mon->mon_id.my_id.my_name, sizeof(my_name) - 1);
 
 	host = smn_alloc_host(hostname, my_name, timestamp);
 	if (host == NULL)
@@ -163,6 +163,19 @@ smn_get_host(const char *hostname,
 
 	insert_host(host);
 	xlog(D_GENERAL, "Added host %s to notify list", hostname);
+
+	/* See if we should send an unqualified copy of my_name as well */
+	c = strchr(my_name, '.');
+	if (c) {
+		*c = '\0';
+		host = smn_alloc_host(hostname, my_name, timestamp);
+		if (host != NULL) {
+			insert_host(host);
+			xlog(D_GENERAL, "Added unqualified copy of %s "
+					"to notify list", hostname);
+		}
+	}
+
 	return 1;
 }
 

