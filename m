From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 02/24] sm-notify: Replace RPC code
Date: Thu, 14 Jan 2010 12:29:06 -0500
Message-ID: <20100114172906.26079.54088.stgit@localhost.localdomain>
References: <20100114172457.26079.66627.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: chris.mason@oracle.com, linux-nfs@vger.kernel.org
To: steved@redhat.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from acsinet11.oracle.com ([141.146.126.233]:36049 "EHLO
	acsinet11.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757394Ab0ANRbM (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 14 Jan 2010 12:31:12 -0500
In-Reply-To: <20100114172457.26079.66627.stgit-bi+AKbBUZKY6gyzm1THtWbp2dZbC/Bob@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Replace the open code to construct SM_NOTIFY and PMAP_GETPORT RPC
requests with calls to our new library routines that support
IPv6 and RPCB_GETADDR as well.

This change allows sm-notify to send RPCB_GETADDR, but it won't do
that until the main sm-notify socket supports PF_INET6 and the DNS
resolution logic is updated to return IPv6 addresses.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 utils/statd/sm-notify.c |  188 +++++++++++++++++------------------------------
 1 files changed, 66 insertions(+), 122 deletions(-)

diff --git a/utils/statd/sm-notify.c b/utils/statd/sm-notify.c
index 581234e..e49c722 100644
--- a/utils/statd/sm-notify.c
+++ b/utils/statd/sm-notify.c
@@ -33,24 +33,18 @@
 #include "nsm.h"
 #include "nfsrpc.h"
 
-#define NSM_PROG	100024
-#define NSM_PROGRAM	100024
-#define NSM_VERSION	1
 #define NSM_TIMEOUT	2
-#define NSM_NOTIFY	6
 #define NSM_MAX_TIMEOUT	120	/* don't make this too big */
-#define MAXMSGSIZE	256
 
 struct nsm_host {
 	struct nsm_host *	next;
 	char *			name;
-	struct sockaddr_storage	addr;
 	struct addrinfo		*ai;
 	time_t			last_used;
 	time_t			send_next;
 	unsigned int		timeout;
 	unsigned int		retries;
-	unsigned int		xid;
+	uint32_t		xid;
 };
 
 static char		nsm_hostname[256];
@@ -387,17 +381,8 @@ notify(void)
 static int
 notify_host(int sock, struct nsm_host *host)
 {
-	struct sockaddr_storage address;
-	struct sockaddr *dest = (struct sockaddr *)&address;
-	socklen_t destlen = sizeof(address);
-	static unsigned int	xid = 0;
-	uint32_t		msgbuf[MAXMSGSIZE], *p;
-	unsigned int		len;
-
-	if (!xid)
-		xid = getpid() + time(NULL);
-	if (!host->xid)
-		host->xid = xid++;
+	struct sockaddr *sap;
+	socklen_t salen;
 
 	if (host->ai == NULL) {
 		host->ai = smn_lookup(host->name);
@@ -408,12 +393,6 @@ notify_host(int sock, struct nsm_host *host)
 		}
 	}
 
-	memset(msgbuf, 0, sizeof(msgbuf));
-	p = msgbuf;
-	*p++ = htonl(host->xid);
-	*p++ = 0;
-	*p++ = htonl(2);
-
 	/* If we retransmitted 4 times, reset the port to force
 	 * a new portmap lookup (in case statd was restarted).
 	 * We also rotate through multiple IP addresses at this
@@ -421,10 +400,7 @@ notify_host(int sock, struct nsm_host *host)
 	 */
 	if (host->retries >= 4) {
 		/* don't rotate if there is only one addrinfo */
-		if (host->ai->ai_next == NULL)
-			memcpy(&host->addr, host->ai->ai_addr,
-						host->ai->ai_addrlen);
-		else {
+		if (host->ai->ai_next != NULL) {
 			struct addrinfo *first = host->ai;
 			struct addrinfo **next = &host->ai;
 
@@ -437,58 +413,59 @@ notify_host(int sock, struct nsm_host *host)
 				next = & (*next)->ai_next;
 			/* put first entry at end */
 			*next = first;
-			memcpy(&host->addr, first->ai_addr,
-						first->ai_addrlen);
 		}
 
-		nfs_set_port((struct sockaddr *)&host->addr, 0);
+		nfs_set_port(host->ai->ai_addr, 0);
 		host->retries = 0;
 	}
 
-	memcpy(dest, &host->addr, destlen);
-	if (nfs_get_port(dest) == 0) {
-		/* Build a PMAP packet */
-		xlog(D_GENERAL, "Sending portmap query to %s", host->name);
+	sap = host->ai->ai_addr;
+	salen = host->ai->ai_addrlen;
 
-		nfs_set_port(dest, 111);
-		*p++ = htonl(100000);
-		*p++ = htonl(2);
-		*p++ = htonl(3);
+	if (nfs_get_port(sap) == 0)
+		host->xid = nsm_xmit_rpcbind(sock, sap, SM_PROG, SM_VERS);
+	else
+		host->xid = nsm_xmit_notify(sock, sap, salen,
+				SM_PROG, nsm_hostname, nsm_state);
+	
+	return 0;
+}
 
-		/* Auth and verf */
-		*p++ = 0; *p++ = 0;
-		*p++ = 0; *p++ = 0;
+/*
+ * Extract the returned port number and set up the SM_NOTIFY call.
+ */
+static void
+recv_rpcbind_reply(struct sockaddr *sap, struct nsm_host *host, XDR *xdr)
+{
+	uint16_t port = nsm_recv_rpcbind(sap->sa_family, xdr);
+
+	host->send_next = time(NULL);
+	host->xid = 0;
 
-		*p++ = htonl(NSM_PROGRAM);
-		*p++ = htonl(NSM_VERSION);
-		*p++ = htonl(IPPROTO_UDP);
-		*p++ = 0;
+	if (port == 0) {
+		/* No binding for statd... */
+		xlog(D_GENERAL, "No statd on host %s", host->name);
+		host->timeout = NSM_MAX_TIMEOUT;
+		host->send_next += NSM_MAX_TIMEOUT;
 	} else {
-		/* Build an SM_NOTIFY packet */
-		xlog(D_GENERAL, "Sending SM_NOTIFY to %s", host->name);
-
-		*p++ = htonl(NSM_PROGRAM);
-		*p++ = htonl(NSM_VERSION);
-		*p++ = htonl(NSM_NOTIFY);
-
-		/* Auth and verf */
-		*p++ = 0; *p++ = 0;
-		*p++ = 0; *p++ = 0;
-
-		/* state change */
-		len = strlen(nsm_hostname);
-		*p++ = htonl(len);
-		memcpy(p, nsm_hostname, len);
-		p += (len + 3) >> 2;
-		*p++ = htonl(nsm_state);
+		nfs_set_port(sap, port);
+		if (host->timeout >= NSM_MAX_TIMEOUT / 4)
+			host->timeout = NSM_MAX_TIMEOUT / 4;
 	}
-	len = (p - msgbuf) << 2;
 
-	if (sendto(sock, msgbuf, len, 0, dest, destlen) < 0)
-		xlog_warn("Sending Reboot Notification to "
-			"'%s' failed: errno %d (%m)", host->name, errno);
-	
-	return 0;
+	insert_host(host);
+}
+
+/*
+ * Successful NOTIFY call. Server returns void, so nothing
+ * we need to do here.
+ */
+static void
+recv_notify_reply(struct nsm_host *host)
+{
+	xlog(D_GENERAL, "Host %s notified successfully", host->name);
+
+	smn_forget_host(host);
 }
 
 /*
@@ -499,70 +476,37 @@ recv_reply(int sock)
 {
 	struct nsm_host	*hp;
 	struct sockaddr *sap;
-	uint32_t	msgbuf[MAXMSGSIZE], *p, *end;
+	char msgbuf[NSM_MAXMSGSIZE];
 	uint32_t	xid;
-	int		res;
+	ssize_t		msglen;
+	XDR		xdr;
 
-	res = recv(sock, msgbuf, sizeof(msgbuf), 0);
-	if (res < 0)
+	memset(msgbuf, 0 , sizeof(msgbuf));
+	msglen = recv(sock, msgbuf, sizeof(msgbuf), 0);
+	if (msglen < 0)
 		return;
 
 	xlog(D_GENERAL, "Received packet...");
 
-	p = msgbuf;
-	end = p + (res >> 2);
-
-	xid = ntohl(*p++);
-	if (*p++ != htonl(1)	/* must be REPLY */
-	 || *p++ != htonl(0)	/* must be ACCEPTED */
-	 || *p++ != htonl(0)	/* must be NULL verifier */
-	 || *p++ != htonl(0)
-	 || *p++ != htonl(0))	/* must be SUCCESS */
-		return;
+	memset(&xdr, 0, sizeof(xdr));
+	xdrmem_create(&xdr, msgbuf, (unsigned int)msglen, XDR_DECODE);
+	xid = nsm_parse_reply(&xdr);
+	if (xid == 0)
+		goto out;
 
 	/* Before we look at the data, find the host struct for
 	   this reply */
 	if ((hp = find_host(xid)) == NULL)
-		return;
-	sap = (struct sockaddr *)&hp->addr;
-
-	if (nfs_get_port(sap) == 0) {
-		/* This was a portmap request */
-		unsigned int	port;
-
-		port = ntohl(*p++);
-		if (p > end)
-			goto fail;
-
-		hp->send_next = time(NULL);
-		if (port == 0) {
-			/* No binding for statd. Delay the next
-			 * portmap query for max timeout */
-			xlog(D_GENERAL, "No statd on %s", hp->name);
-			hp->timeout = NSM_MAX_TIMEOUT;
-			hp->send_next += NSM_MAX_TIMEOUT;
-		} else {
-			nfs_set_port(sap, port);
-			if (hp->timeout >= NSM_MAX_TIMEOUT / 4)
-				hp->timeout = NSM_MAX_TIMEOUT / 4;
-		}
-		hp->xid = 0;
-	} else {
-		/* Successful NOTIFY call. Server returns void,
-		 * so nothing we need to do here (except
-		 * check that we didn't read past the end of the
-		 * packet)
-		 */
-		if (p <= end) {
-			xlog(D_GENERAL, "Host %s notified successfully",
-					hp->name);
-			smn_forget_host(hp);
-			return;
-		}
-	}
+		goto out;
+
+	sap = hp->ai->ai_addr;
+	if (nfs_get_port(sap) == 0)
+		recv_rpcbind_reply(sap, hp, &xdr);
+	else
+		recv_notify_reply(hp);
 
-fail:	/* Re-insert the host */
-	insert_host(hp);
+out:
+	xdr_destroy(&xdr);
 }
 
 /*

