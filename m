From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 19/19] rpc.statd: Stop overloading sockfd in
	utils/statd/rmtcall.c
Date: Fri, 05 Sep 2008 17:08:44 -0400
Message-ID: <20080905210844.10001.64002.stgit@manray.1015granger.net>
References: <20080905210054.10001.8518.stgit@manray.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: neilb@suse.de, linux-nfs@vger.kernel.org
To: steved@redhat.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from agminet01.oracle.com ([141.146.126.228]:41645 "EHLO
	agminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752241AbYIEVJG (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 5 Sep 2008 17:09:06 -0400
In-Reply-To: <20080905210054.10001.8518.stgit-meopP2rzCrTwdl/1UfZZQIVfYA8g3rJ/@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The Linux kernel's lockd requires that rpc.statd perform notification
callbacks from a privileged source port.  To guarantee rpc.statd gets a
privileged source port but runs unprivileged, it calls
statd_get_socket() then drops root privileges before starting it's svc
request processing loop.

Statd's svc request loop is the only caller of the process_foo()
functions in utils/statd/rmtcall.c, but one of them,
process_notify_list() attempts to invoke statd_get_socket() again.

In today's code, this is unneeded because statd_get_socket() is always
invoked before my_svc_run().  However, if it ever succeeded, it would
get an unprivileged source port anyway, causing the kernel to reject
all subsequent requests from statd.

Thus the process_notify_list() function should not ever call
statd_get_socket() because root privileges have been dropped by this
point, and statd_get_socket() wouldn't get a privileged source port,
causing the kernel to reject all subsequent SM_NOTIFY requests.

So all of the process_foo functions in utils/statd/rmtcall.c should use
the global sockfd instead of a local copy, as it already has a
privileged source port.

I've seen some unexplained behavior where statd starts making calls to
the kernel via an unprivileged port.  This could be one way that might
occur.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 utils/statd/rmtcall.c |   28 ++++++++++++++++------------
 utils/statd/statd.c   |    4 ++--
 utils/statd/statd.h   |    1 +
 3 files changed, 19 insertions(+), 14 deletions(-)

diff --git a/utils/statd/rmtcall.c b/utils/statd/rmtcall.c
index 8240529..cc1a4a4 100644
--- a/utils/statd/rmtcall.c
+++ b/utils/statd/rmtcall.c
@@ -56,7 +56,15 @@ static unsigned long	xid = 0;	/* RPC XID counter */
 static int		sockfd = -1;	/* notify socket */
 
 /*
- * Initialize callback socket
+ * Initialize socket used to notify lockd of peer reboots.
+ *
+ * Returns the file descriptor of the new socket if successful;
+ * otherwise returns -1 and logs an error.
+ *
+ * Lockd rejects such requests if the source port is not privileged.
+ * statd_get_socket() must be invoked while statd still holds root
+ * privileges in order for the socket to acquire a privileged source
+ * port.
  */
 int
 statd_get_socket(void)
@@ -97,7 +105,7 @@ statd_get_socket(void)
 }
 
 static unsigned long
-xmit_call(int sockfd, struct sockaddr_in *sin,
+xmit_call(struct sockaddr_in *sin,
 	  u_int32_t prog, u_int32_t vers, u_int32_t proc,
 	  xdrproc_t func, void *obj)
 /* 		__u32 prog, __u32 vers, __u32 proc, xdrproc_t func, void *obj) */
@@ -163,7 +171,7 @@ xmit_call(int sockfd, struct sockaddr_in *sin,
 }
 
 static notify_list *
-recv_rply(int sockfd, struct sockaddr_in *sin, u_long *portp)
+recv_rply(struct sockaddr_in *sin, u_long *portp)
 {
 	unsigned int		msgbuf[MAXMSGSIZE], msglen;
 	struct rpc_msg		mesg;
@@ -242,7 +250,7 @@ done:
  * Notify operation for a single list entry
  */
 static int
-process_entry(int sockfd, notify_list *lp)
+process_entry(notify_list *lp)
 {
 	struct sockaddr_in	sin;
 	struct status		new_status;
@@ -276,7 +284,7 @@ process_entry(int sockfd, notify_list *lp)
 	new_status.state    = NL_STATE(lp);
 	memcpy(new_status.priv, NL_PRIV(lp), SM_PRIV_SIZE);
 
-	lp->xid = xmit_call(sockfd, &sin, prog, vers, proc, func, objp);
+	lp->xid = xmit_call(&sin, prog, vers, proc, func, objp);
 	if (!lp->xid) {
 		note(N_WARNING, "%s: failed to notify port %d",
 				__func__, ntohs(lp->port));
@@ -299,13 +307,13 @@ process_reply(FD_SET_TYPE *rfds)
 	if (sockfd == -1 || !FD_ISSET(sockfd, rfds))
 		return 0;
 
-	if (!(lp = recv_rply(sockfd, &sin, &port)))
+	if (!(lp = recv_rply(&sin, &port)))
 		return 1;
 
 	if (lp->port == 0) {
 		if (port != 0) {
 			lp->port = htons((unsigned short) port);
-			process_entry(sockfd, lp);
+			process_entry(lp);
 			NL_WHEN(lp) = time(NULL) + NOTIFY_TIMEOUT;
 			nlist_remove(&notify, lp);
 			nlist_insert_timer(&notify, lp);
@@ -331,13 +339,9 @@ process_notify_list(void)
 {
 	notify_list	*entry;
 	time_t		now;
-	int		fd;
-
-	if ((fd = statd_get_socket()) < 0)
-		return 0;
 
 	while ((entry = notify) != NULL && NL_WHEN(entry) < time(&now)) {
-		if (process_entry(fd, entry)) {
+		if (process_entry(entry)) {
 			NL_WHEN(entry) = time(NULL) + NOTIFY_TIMEOUT;
 			nlist_remove(&notify, entry);
 			nlist_insert_timer(&notify, entry);
diff --git a/utils/statd/statd.c b/utils/statd/statd.c
index ea985e6..321f7a9 100644
--- a/utils/statd/statd.c
+++ b/utils/statd/statd.c
@@ -75,7 +75,6 @@ static struct option longopts[] =
 };
 
 extern void sm_prog_1 (struct svc_req *, register SVCXPRT *);
-extern int statd_get_socket(void);
 static void load_state_number(void);
 
 #ifdef SIMULATIONS
@@ -477,7 +476,8 @@ int main (int argc, char **argv)
 		}
 
 	/* Make sure we have a privilege port for calling into the kernel */
-	statd_get_socket();
+	if (statd_get_socket() < 0)
+		exit(1);
 
 	/* If sm-notify didn't take all the state files, load
 	 * state information into our notify-list so we can
diff --git a/utils/statd/statd.h b/utils/statd/statd.h
index 5d06d88..5a6e289 100644
--- a/utils/statd/statd.h
+++ b/utils/statd/statd.h
@@ -48,6 +48,7 @@ extern void	change_state(void);
 extern void	my_svc_run(void);
 extern void	notify_hosts(void);
 extern void	shuffle_dirs(void);
+extern int	statd_get_socket(void);
 extern int	process_notify_list(void);
 extern int	process_reply(FD_SET_TYPE *);
 extern char *	xstrdup(const char *);

