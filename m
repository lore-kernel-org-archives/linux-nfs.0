From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 08/10] lockd: struct nlm_reboot should contain a full socket
	address
Date: Wed, 17 Sep 2008 11:18:11 -0500
Message-ID: <20080917161811.4963.60224.stgit@ellison.1015granger.net>
References: <20080917161337.4963.74674.stgit@ellison.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: bfields@fieldses.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from agminet01.oracle.com ([141.146.126.228]:19431 "EHLO
	agminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754005AbYIQQXl (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 17 Sep 2008 12:23:41 -0400
In-Reply-To: <20080917161337.4963.74674.stgit-ewv44WTpT0t9HhUboXbp9zCvJB+x5qRC@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The XDR decoders for the NSM NOTIFY procedure should construct a full
socket address and store it in the nlm_reboot structure.  In addition
to being able to store larger addresses, this means upper layer
routines get an address family tag so they can distinguish between
AF_INET and AF_INET6 addresses.

This also keeps potentially large socket addresses off the stack and
instead in dynamically allocated storage.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/lockd/svc4proc.c       |   10 +---------
 fs/lockd/svcproc.c        |   10 +---------
 fs/lockd/xdr.c            |   28 ++++++++++++++++++++++++++--
 fs/lockd/xdr4.c           |   27 +++++++++++++++++++++++++--
 include/linux/lockd/xdr.h |    3 ++-
 5 files changed, 55 insertions(+), 23 deletions(-)

diff --git a/fs/lockd/svc4proc.c b/fs/lockd/svc4proc.c
index 6a5ef9f..e61c05f 100644
--- a/fs/lockd/svc4proc.c
+++ b/fs/lockd/svc4proc.c
@@ -430,8 +430,6 @@ static __be32
 nlm4svc_proc_sm_notify(struct svc_rqst *rqstp, struct nlm_reboot *argp,
 					      void	        *resp)
 {
-	struct sockaddr_in	saddr;
-
 	dprintk("lockd: SM_NOTIFY     called\n");
 
 	if (!nlm_privileged_requester(rqstp)) {
@@ -441,13 +439,7 @@ nlm4svc_proc_sm_notify(struct svc_rqst *rqstp, struct nlm_reboot *argp,
 		return rpc_system_err;
 	}
 
-	/* Obtain the host pointer for this NFS server and try to
-	 * reclaim all locks we hold on this server.
-	 */
-	memset(&saddr, 0, sizeof(saddr));
-	saddr.sin_family = AF_INET;
-	saddr.sin_addr.s_addr = argp->addr;
-	nlm_host_rebooted((struct sockaddr *)&saddr, sizeof(saddr),
+	nlm_host_rebooted((struct sockaddr *)&argp->addr, argp->addrlen,
 			  argp->mon, argp->len, argp->state);
 
 	return rpc_success;
diff --git a/fs/lockd/svcproc.c b/fs/lockd/svcproc.c
index 62fcfdb..86a487a 100644
--- a/fs/lockd/svcproc.c
+++ b/fs/lockd/svcproc.c
@@ -462,8 +462,6 @@ static __be32
 nlmsvc_proc_sm_notify(struct svc_rqst *rqstp, struct nlm_reboot *argp,
 					      void	        *resp)
 {
-	struct sockaddr_in	saddr;
-
 	dprintk("lockd: SM_NOTIFY     called\n");
 
 	if (!nlm_privileged_requester(rqstp)) {
@@ -473,13 +471,7 @@ nlmsvc_proc_sm_notify(struct svc_rqst *rqstp, struct nlm_reboot *argp,
 		return rpc_system_err;
 	}
 
-	/* Obtain the host pointer for this NFS server and try to
-	 * reclaim all locks we hold on this server.
-	 */
-	memset(&saddr, 0, sizeof(saddr));
-	saddr.sin_family = AF_INET;
-	saddr.sin_addr.s_addr = argp->addr;
-	nlm_host_rebooted((struct sockaddr *)&saddr, sizeof(saddr),
+	nlm_host_rebooted((struct sockaddr *)&argp->addr, argp->addrlen,
 			  argp->mon, argp->len, argp->state);
 
 	return rpc_success;
diff --git a/fs/lockd/xdr.c b/fs/lockd/xdr.c
index 1f22629..92c5695 100644
--- a/fs/lockd/xdr.c
+++ b/fs/lockd/xdr.c
@@ -9,6 +9,7 @@
 #include <linux/types.h>
 #include <linux/sched.h>
 #include <linux/utsname.h>
+#include <linux/in.h>
 #include <linux/nfs.h>
 
 #include <linux/sunrpc/xdr.h>
@@ -346,11 +347,34 @@ nlmsvc_decode_notify(struct svc_rqst *rqstp, __be32 *p, struct nlm_args *argp)
 int
 nlmsvc_decode_reboot(struct svc_rqst *rqstp, __be32 *p, struct nlm_reboot *argp)
 {
+	struct sockaddr_in *sin = (struct sockaddr_in *)&argp->addr;
+	struct sockaddr_in6 *sin6 = (struct sockaddr_in6 *)&argp->addr;
+
 	if (!(p = xdr_decode_string_inplace(p, &argp->mon, &argp->len, SM_MAXSTRLEN)))
 		return 0;
 	argp->state = ntohl(*p++);
-	/* Preserve the address in network byte order */
-	argp->addr = *p++;
+
+	/* Decode the 16-byte private field */
+	memset(&argp->addr, 0, sizeof(argp->addr));
+	switch (svc_addr(rqstp)->sa_family) {
+	case AF_INET:
+		/* data in recv buffer is already in network byte order */
+		sin->sin_family = AF_INET;
+		sin->sin_addr.s_addr = *p++;
+		argp->addrlen = sizeof(*sin);
+		break;
+	case AF_INET6:
+		sin6->sin6_family = AF_INET6;
+		sin6->sin6_addr.s6_addr32[0] = *p++;
+		sin6->sin6_addr.s6_addr32[1] = *p++;
+		sin6->sin6_addr.s6_addr32[2] = *p++;
+		sin6->sin6_addr.s6_addr32[3] = *p++;
+		argp->addrlen = sizeof(*sin6);
+		break;
+	default:
+		return -EIO;
+	}
+
 	return xdr_argsize_check(rqstp, p);
 }
 
diff --git a/fs/lockd/xdr4.c b/fs/lockd/xdr4.c
index 50c493a..2009020 100644
--- a/fs/lockd/xdr4.c
+++ b/fs/lockd/xdr4.c
@@ -353,11 +353,34 @@ nlm4svc_decode_notify(struct svc_rqst *rqstp, __be32 *p, struct nlm_args *argp)
 int
 nlm4svc_decode_reboot(struct svc_rqst *rqstp, __be32 *p, struct nlm_reboot *argp)
 {
+	struct sockaddr_in *sin = (struct sockaddr_in *)&argp->addr;
+	struct sockaddr_in6 *sin6 = (struct sockaddr_in6 *)&argp->addr;
+
 	if (!(p = xdr_decode_string_inplace(p, &argp->mon, &argp->len, SM_MAXSTRLEN)))
 		return 0;
 	argp->state = ntohl(*p++);
-	/* Preserve the address in network byte order */
-	argp->addr  = *p++;
+
+	/* Decode the 16-byte private field */
+	memset(&argp->addr, 0, sizeof(argp->addr));
+	switch (svc_addr(rqstp)->sa_family) {
+	case AF_INET:
+		/* address in recv buffer is already in network byte order */
+		sin->sin_family = AF_INET;
+		sin->sin_addr.s_addr = *p++;
+		argp->addrlen = sizeof(*sin);
+		break;
+	case AF_INET6:
+		sin6->sin6_family = AF_INET6;
+		sin6->sin6_addr.s6_addr32[0] = *p++;
+		sin6->sin6_addr.s6_addr32[1] = *p++;
+		sin6->sin6_addr.s6_addr32[2] = *p++;
+		sin6->sin6_addr.s6_addr32[3] = *p++;
+		argp->addrlen = sizeof(*sin6);
+		break;
+	default:
+		return -EIO;
+	}
+
 	return xdr_argsize_check(rqstp, p);
 }
 
diff --git a/include/linux/lockd/xdr.h b/include/linux/lockd/xdr.h
index d6b3a80..6057b7e 100644
--- a/include/linux/lockd/xdr.h
+++ b/include/linux/lockd/xdr.h
@@ -80,7 +80,8 @@ struct nlm_reboot {
 	char *		mon;
 	unsigned int	len;
 	u32		state;
-	__be32		addr;
+	struct sockaddr_storage	addr;
+	size_t		addrlen;
 };
 
 /*

