From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 21/24] statd: Remove NL_ADDR() macro
Date: Thu, 14 Jan 2010 12:31:54 -0500
Message-ID: <20100114173154.26079.48305.stgit@localhost.localdomain>
References: <20100114172457.26079.66627.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: chris.mason@oracle.com, linux-nfs@vger.kernel.org
To: steved@redhat.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet11.oracle.com ([148.87.113.123]:44619 "EHLO
	rcsinet11.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757372Ab0ANRca (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 14 Jan 2010 12:32:30 -0500
In-Reply-To: <20100114172457.26079.66627.stgit-bi+AKbBUZKY6gyzm1THtWbp2dZbC/Bob@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Clean up: The contents of NL_ADDR are fixed: they are always the IPv4
loopback address.  Some time ago, the use of NL_ADDR() was stubbed out
of the NLM downcall forward path, replaced with a constant IPv4
loopback address.

Stub it out of the reply path as well, and then remove NL_ADDR
entirely.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 utils/statd/monitor.c |    6 ++----
 utils/statd/notlist.c |    1 -
 utils/statd/notlist.h |    2 --
 utils/statd/rmtcall.c |   26 +++++++++++++-------------
 4 files changed, 15 insertions(+), 20 deletions(-)

diff --git a/utils/statd/monitor.c b/utils/statd/monitor.c
index 11afe08..325dfd3 100644
--- a/utils/statd/monitor.c
+++ b/utils/statd/monitor.c
@@ -173,7 +173,6 @@ sm_mon_1_svc(struct mon *argp, struct svc_req *rqstp)
 		goto failure;
 	}
 
-	NL_ADDR(clnt) = my_addr.sin_addr;
 	NL_MY_PROG(clnt) = id->my_prog;
 	NL_MY_VERS(clnt) = id->my_vers;
 	NL_MY_PROC(clnt) = id->my_proc;
@@ -214,11 +213,11 @@ failure:
 }
 
 static unsigned int
-load_one_host(const char *hostname, const struct sockaddr *sap,
+load_one_host(const char *hostname,
+		__attribute__ ((unused)) const struct sockaddr *sap,
 		const struct mon *m,
 		__attribute__ ((unused)) const time_t timestamp)
 {
-	const struct sockaddr_in *sin = (const struct sockaddr_in *)sap;
 	notify_list *clnt;
 
 	clnt = nlist_new(m->mon_id.my_id.my_name,
@@ -235,7 +234,6 @@ load_one_host(const char *hostname, const struct sockaddr *sap,
 	xlog(D_GENERAL, "Adding record for %s to the monitor list...",
 			hostname);
 
-	NL_ADDR(clnt) = sin->sin_addr;
 	NL_MY_PROG(clnt) = m->mon_id.my_id.my_prog;
 	NL_MY_VERS(clnt) = m->mon_id.my_id.my_vers;
 	NL_MY_PROC(clnt) = m->mon_id.my_id.my_proc;
diff --git a/utils/statd/notlist.c b/utils/statd/notlist.c
index de7d046..0341c15 100644
--- a/utils/statd/notlist.c
+++ b/utils/statd/notlist.c
@@ -189,7 +189,6 @@ nlist_clone(notify_list *entry)
 	NL_MY_PROG(new) = NL_MY_PROG(entry);
 	NL_MY_VERS(new) = NL_MY_VERS(entry);
 	NL_MY_PROC(new) = NL_MY_PROC(entry);
-	NL_ADDR(new)    = NL_ADDR(entry);
 	memcpy(NL_PRIV(new), NL_PRIV(entry), SM_PRIV_SIZE);
 
 	return new;
diff --git a/utils/statd/notlist.h b/utils/statd/notlist.h
index f915ae1..6ed0da8 100644
--- a/utils/statd/notlist.h
+++ b/utils/statd/notlist.h
@@ -12,7 +12,6 @@
  */
 struct notify_list {
   mon			mon;	/* Big honkin' NSM structure. */
-  struct in_addr	addr;	/* IP address for callback. */
   in_port_t		port;	/* port number for callback */
   short int		times;	/* Counter used for various things. */
   int			state;	/* For storing notified state for callbacks. */
@@ -53,7 +52,6 @@ extern notify_list *	nlist_gethost(notify_list *, char *, int);
 #define NL_FIRST	NL_NEXT
 #define NL_PREV(L)	((L)->prev)
 #define NL_DATA(L)	((L)->mon)
-#define NL_ADDR(L)	((L)->addr)
 #define NL_STATE(L)	((L)->state)
 #define NL_TIMES(L)	((L)->times)
 #define NL_MON_ID(L)	(NL_DATA((L)).mon_id)
diff --git a/utils/statd/rmtcall.c b/utils/statd/rmtcall.c
index 1a97684..0e52fe2 100644
--- a/utils/statd/rmtcall.c
+++ b/utils/statd/rmtcall.c
@@ -125,6 +125,15 @@ recv_rply(u_long *portp)
 	xid = nsm_parse_reply(&xdr);
 	if (xid == 0)
 		goto done;
+	if (sin.sin_addr.s_addr != htonl(INADDR_LOOPBACK)) {
+		struct in_addr addr = sin.sin_addr;
+		char buf[INET_ADDRSTRLEN];
+
+		xlog_warn("%s: Unrecognized reply from %s", __func__,
+				inet_ntop(AF_INET, &addr, buf,
+						(socklen_t)sizeof(buf)));
+		goto done;
+	}
 
 	for (lp = notify; lp != NULL; lp = lp->next) {
 		/* LH - this was a bug... it should have been checking
@@ -132,15 +141,6 @@ recv_rply(u_long *portp)
 		 * not the static, internal xid */
 		if (lp->xid != xid)
 			continue;
-		if (lp->addr.s_addr != sin.sin_addr.s_addr) {
-			char addr [18];
-			strncpy (addr, inet_ntoa(lp->addr),
-				 sizeof (addr) - 1);
-			addr [sizeof (addr) - 1] = '\0';
-			xlog_warn("%s: address mismatch: "
-				"expected %s, got %s", __func__,
-				addr, inet_ntoa(sin.sin_addr));
-		}
 		if (lp->port == 0)
 			*portp = nsm_recv_getport(&xdr);
 		break;
@@ -160,8 +160,8 @@ process_entry(notify_list *lp)
 	struct sockaddr_in	sin;
 
 	if (NL_TIMES(lp) == 0) {
-		xlog(D_GENERAL, "%s: Cannot notify %s, giving up",
-				__func__, inet_ntoa(NL_ADDR(lp)));
+		xlog(D_GENERAL, "%s: Cannot notify localhost, giving up",
+				__func__);
 		return 0;
 	}
 
@@ -226,8 +226,8 @@ process_reply(FD_SET_TYPE *rfds)
 			nlist_insert_timer(&notify, lp);
 			return 1;
 		}
-		xlog_warn("%s: [%s] service %d not registered",
-			__func__, inet_ntoa(lp->addr), NL_MY_PROG(lp));
+		xlog_warn("%s: service %d not registered on localhost",
+			__func__, NL_MY_PROG(lp));
 	} else {
 		xlog(D_GENERAL, "%s: Callback to %s (for %d) succeeded",
 			__func__, NL_MY_NAME(lp), NL_MON_NAME(lp));

