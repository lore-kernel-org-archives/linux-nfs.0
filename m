From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 10/29] statd: Support sending SM_NOTIFY requests to IPv6
	remotes
Date: Tue, 10 Nov 2009 16:57:57 -0500
Message-ID: <20091110215757.23822.85641.stgit@matisse.1015granger.net>
References: <20091110215447.23822.15275.stgit@matisse.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org, Chris.Mason@oracle.com
To: steved@redhat.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet11.oracle.com ([148.87.113.123]:50813 "EHLO
	rgminet11.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757305AbZKJV6g (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 10 Nov 2009 16:58:36 -0500
In-Reply-To: <20091110215447.23822.15275.stgit-RytpoXr2tKZ9HhUboXbp9zCvJB+x5qRC@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Replace the open code to construct SM_NOTIFY and PMAP_GETPORT RPC
requests with calls to our new library routines that support
IPv6 and RPCB_GETADDR as well.

This change allows sm-notify to send RPCB_GETADDR, but it won't do
that until the main sm-notify socket supports PF_INET6, and the DNS
resolution logic is updated to return IPv6 addresses.

I would prefer to use high level RPC client library calls to send
these requests instead of this open coded solution.  That would give
us a number of benefits, including support for sending SM_NOTIFY via
TCP so we can penetrate firewalls that block UDP.

However, that would also involve replacing the scheduler logic in
sm-notify with something like fork(3) or pthreads, to deal with the
synchronous RPC client library calls.  That's probably too much for
folks to swallow right now.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 utils/statd/sm-notify.c |  110 +++++++++++------------------------------------
 1 files changed, 26 insertions(+), 84 deletions(-)

diff --git a/utils/statd/sm-notify.c b/utils/statd/sm-notify.c
index 6466d8a..9ed5df1 100644
--- a/utils/statd/sm-notify.c
+++ b/utils/statd/sm-notify.c
@@ -38,7 +38,6 @@
 #define NSM_TIMEOUT	2
 #define NSM_NOTIFY	6
 #define NSM_MAX_TIMEOUT	120	/* don't make this too big */
-#define MAXMSGSIZE	256
 
 struct nsm_host {
 	struct nsm_host *	next;
@@ -388,14 +387,6 @@ notify_host(int sock, struct nsm_host *host)
 {
 	struct sockaddr_storage address;
 	struct sockaddr *dest = (struct sockaddr *)&address;
-	static unsigned int	xid = 0;
-	uint32_t		msgbuf[MAXMSGSIZE], *p;
-	unsigned int		len;
-
-	if (!xid)
-		xid = getpid() + time(NULL);
-	if (!host->xid)
-		host->xid = xid++;
 
 	if (host->ai == NULL) {
 		host->ai = smn_lookup(host->name);
@@ -406,12 +397,6 @@ notify_host(int sock, struct nsm_host *host)
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
@@ -446,48 +431,13 @@ notify_host(int sock, struct nsm_host *host)
 	}
 
 	memcpy(dest, &host->addr, host->addrlen);
-	if (nfs_get_port(dest) == 0) {
-		/* Build a PMAP packet */
-		xlog(D_GENERAL, "Sending portmap query to %s", host->name);
-
-		nfs_set_port(dest, 111);
-		*p++ = htonl(100000);
-		*p++ = htonl(2);
-		*p++ = htonl(3);
-
-		/* Auth and verf */
-		*p++ = 0; *p++ = 0;
-		*p++ = 0; *p++ = 0;
-
-		*p++ = htonl(NSM_PROGRAM);
-		*p++ = htonl(NSM_VERSION);
-		*p++ = htonl(IPPROTO_UDP);
-		*p++ = 0;
-	} else {
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
-	}
-	len = (p - msgbuf) << 2;
-
-	if (sendto(sock, msgbuf, len, 0, dest, host->addrlen) < 0)
-		xlog_warn("Sending Reboot Notification to "
-			"'%s' failed: errno %d (%m)", host->name, errno);
-
+	if (nfs_get_port(dest) == 0)
+		host->xid = nsm_xmit_rpcbind(sock, dest,
+				NSM_PROGRAM, NSM_VERSION);
+	else
+		host->xid = nsm_xmit_notify(sock, dest, host->addrlen,
+				NSM_PROGRAM, nsm_hostname, nsm_state);
+	
 	return 0;
 }
 
@@ -499,40 +449,32 @@ recv_reply(int sock)
 {
 	struct nsm_host	*hp;
 	struct sockaddr *sap;
-	uint32_t	msgbuf[MAXMSGSIZE], *p, *end;
+	uint32_t	msgbuf[NSM_MAXMSGSIZE];
 	uint32_t	xid;
-	int		res;
+	ssize_t		msglen;
+	XDR		xdr, *xdrs = &xdr;
 
-	res = recv(sock, msgbuf, sizeof(msgbuf), 0);
-	if (res < 0)
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
+	xdrmem_create(xdrs, (caddr_t)msgbuf, msglen, XDR_DECODE);
+	xid = nsm_parse_reply(xdrs);
+	if (xid == 0)
+		goto out;
 
 	/* Before we look at the data, find the host struct for
 	   this reply */
 	if ((hp = find_host(xid)) == NULL)
-		return;
+		goto out;
 	sap = (struct sockaddr *)&hp->addr;
 
 	if (nfs_get_port(sap) == 0) {
-		/* This was a portmap request */
-		unsigned int	port;
+		uint16_t port;
 
-		port = ntohl(*p++);
-		if (p > end)
-			goto fail;
+		port = nsm_recv_rpcbind(sap->sa_family, xdrs);
 
 		hp->send_next = time(NULL);
 		if (port == 0) {
@@ -553,16 +495,16 @@ recv_reply(int sock)
 		 * check that we didn't read past the end of the
 		 * packet)
 		 */
-		if (p <= end) {
-			xlog(D_GENERAL, "Host %s notified successfully",
-					hp->name);
-			smn_forget_host(hp);
-			return;
-		}
+		xlog(D_GENERAL, "Host %s notified successfully",
+				hp->name);
+		smn_forget_host(hp);
+		goto out;
 	}
 
-fail:	/* Re-insert the host */
 	insert_host(hp);
+
+out:
+	xdr_destroy(xdrs);
 }
 
 /*

