From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 04/29] statd: fix address copy in sm-notify.c
Date: Tue, 10 Nov 2009 16:56:48 -0500
Message-ID: <20091110215648.23822.87959.stgit@matisse.1015granger.net>
References: <20091110215447.23822.15275.stgit@matisse.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org, Chris.Mason@oracle.com
To: steved@redhat.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from acsinet12.oracle.com ([141.146.126.234]:25503 "EHLO
	acsinet12.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758377AbZKJV5O (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 10 Nov 2009 16:57:14 -0500
In-Reply-To: <20091110215447.23822.15275.stgit-RytpoXr2tKZ9HhUboXbp9zCvJB+x5qRC@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

One of the memcpy(3) callsites in notify_host() uses the size of the
copy target to prevent an overrun of the target buffer.  However, the
target is a sockaddr_storage, while the source is never larger than
a sockaddr_in6.

Copying off the end of a sockaddr_in6 returned by getaddrinfo(3) could
potentially cause a segfault if the allocated memory containing the
socket address is near the end of a page, and the next page is
protected.

Introduced by commit 93e355bf.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 utils/statd/sm-notify.c |   14 ++++++++------
 1 files changed, 8 insertions(+), 6 deletions(-)

diff --git a/utils/statd/sm-notify.c b/utils/statd/sm-notify.c
index ea4ce23..1983ef6 100644
--- a/utils/statd/sm-notify.c
+++ b/utils/statd/sm-notify.c
@@ -61,6 +61,7 @@ struct nsm_host {
 	char *			name;
 	char *			path;
 	struct sockaddr_storage	addr;
+	socklen_t		addrlen;
 	struct addrinfo		*ai;
 	time_t			last_used;
 	time_t			send_next;
@@ -377,7 +378,6 @@ notify_host(int sock, struct nsm_host *host)
 {
 	struct sockaddr_storage address;
 	struct sockaddr *dest = (struct sockaddr *)&address;
-	socklen_t destlen = sizeof(address);
 	static unsigned int	xid = 0;
 	uint32_t		msgbuf[MAXMSGSIZE], *p;
 	unsigned int		len;
@@ -409,10 +409,11 @@ notify_host(int sock, struct nsm_host *host)
 	 */
 	if (host->retries >= 4) {
 		/* don't rotate if there is only one addrinfo */
-		if (host->ai->ai_next == NULL)
+		if (host->ai->ai_next == NULL) {
 			memcpy(&host->addr, host->ai->ai_addr,
 						host->ai->ai_addrlen);
-		else {
+			host->addrlen = host->ai->ai_addrlen;
+		} else {
 			struct addrinfo *first = host->ai;
 			struct addrinfo **next = &host->ai;
 
@@ -427,13 +428,14 @@ notify_host(int sock, struct nsm_host *host)
 			*next = first;
 			memcpy(&host->addr, first->ai_addr,
 						first->ai_addrlen);
+			host->addrlen = host->ai->ai_addrlen;
 		}
 
 		nfs_set_port((struct sockaddr *)&host->addr, 0);
 		host->retries = 0;
 	}
 
-	memcpy(dest, &host->addr, destlen);
+	memcpy(dest, &host->addr, host->addrlen);
 	if (nfs_get_port(dest) == 0) {
 		/* Build a PMAP packet */
 		xlog(D_GENERAL, "Sending portmap query to %s", host->name);
@@ -472,10 +474,10 @@ notify_host(int sock, struct nsm_host *host)
 	}
 	len = (p - msgbuf) << 2;
 
-	if (sendto(sock, msgbuf, len, 0, dest, destlen) < 0)
+	if (sendto(sock, msgbuf, len, 0, dest, host->addrlen) < 0)
 		xlog_warn("Sending Reboot Notification to "
 			"'%s' failed: errno %d (%m)", host->name, errno);
-	
+
 	return 0;
 }
 

