From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 09/10] lockd: IPv6 support for SM_MON / SM_UNMON
Date: Wed, 17 Sep 2008 11:18:19 -0500
Message-ID: <20080917161818.4963.27169.stgit@ellison.1015granger.net>
References: <20080917161337.4963.74674.stgit@ellison.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: bfields@fieldses.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rgminet01.oracle.com ([148.87.113.118]:21595 "EHLO
	rgminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753694AbYIQQYU (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 17 Sep 2008 12:24:20 -0400
In-Reply-To: <20080917161337.4963.74674.stgit-ewv44WTpT0t9HhUboXbp9zCvJB+x5qRC@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Widen the field that stores addresses in the nsm_args structure to handle
non-AF_INET addresses, and adjust NSM XDR routines to handle AF_INET6
family addresses.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/lockd/mon.c                 |   76 +++++++++++++++++++++++++++++++---------
 include/linux/lockd/sm_inter.h |    2 +
 2 files changed, 59 insertions(+), 19 deletions(-)

diff --git a/fs/lockd/mon.c b/fs/lockd/mon.c
index 4e7e958..d49dfe6 100644
--- a/fs/lockd/mon.c
+++ b/fs/lockd/mon.c
@@ -18,7 +18,7 @@
 
 #define NLMDBG_FACILITY		NLMDBG_MONITOR
 
-#define XDR_ADDRBUF_LEN		(20)
+#define XDR_ADDRBUF_LEN		(48)
 
 static struct rpc_clnt *	nsm_create(void);
 
@@ -37,7 +37,12 @@ nsm_mon_unmon(struct nsm_handle *nsm, u32 proc, struct nsm_res *res)
 {
 	struct rpc_clnt	*clnt;
 	int		status;
-	struct nsm_args	args;
+	struct nsm_args	args = {
+		.prog		= NLM_PROGRAM,
+		.vers		= 3,
+		.proc		= NLMPROC_NSM_NOTIFY,
+		.mon_name	= nsm->sm_name,
+	};
 	struct rpc_message msg = {
 		.rpc_argp	= &args,
 		.rpc_resp	= res,
@@ -46,21 +51,18 @@ nsm_mon_unmon(struct nsm_handle *nsm, u32 proc, struct nsm_res *res)
 	clnt = nsm_create();
 	if (IS_ERR(clnt)) {
 		status = PTR_ERR(clnt);
+		printk(KERN_NOTICE "nsm_mon_unmon: failed to create transport, "
+			"status=%d\n", status);
 		goto out;
 	}
 
-	memset(&args, 0, sizeof(args));
-	args.mon_name = nsm->sm_name;
-	args.addr = nsm_addr_in(nsm)->sin_addr.s_addr;
-	args.prog = NLM_PROGRAM;
-	args.vers = 3;
-	args.proc = NLMPROC_NSM_NOTIFY;
+	memcpy(&args.addr, nsm_addr(nsm), nsm->sm_addrlen);
 	memset(res, 0, sizeof(*res));
 
 	msg.rpc_proc = &clnt->cl_procinfo[proc];
 	status = rpc_call_sync(clnt, &msg, 0);
 	if (status < 0)
-		printk(KERN_DEBUG "nsm_mon_unmon: rpc failed, status=%d\n",
+		printk(KERN_NOTICE "nsm_mon_unmon: rpc failed, status=%d\n",
 			status);
 	else
 		status = 0;
@@ -174,14 +176,30 @@ static __be32 *xdr_encode_nsm_string(__be32 *p, char *string)
  */
 static __be32 *xdr_encode_mon_name(__be32 *p, struct nsm_args *argp)
 {
-	char	buffer[XDR_ADDRBUF_LEN + 1];
-	char	*name = argp->mon_name;
+	char	*name, buffer[XDR_ADDRBUF_LEN + 1];
 
 	if (!nsm_use_hostnames) {
-		snprintf(buffer, XDR_ADDRBUF_LEN,
-			 NIPQUAD_FMT, NIPQUAD(argp->addr));
+		const struct sockaddr_storage *ssp = &argp->addr;
+		const struct sockaddr_in *sin = (struct sockaddr_in *)ssp;
+		const struct sockaddr_in6 *sin6 = (struct sockaddr_in6 *)ssp;
+
+		switch (ssp->ss_family) {
+		case AF_INET:
+			snprintf(buffer, XDR_ADDRBUF_LEN, NIPQUAD_FMT,
+						NIPQUAD(sin->sin_addr.s_addr));
+			break;
+		case AF_INET6:
+			snprintf(buffer, XDR_ADDRBUF_LEN, NIP6_FMT,
+						NIP6(sin6->sin6_addr));
+			break;
+		default:
+			printk(KERN_NOTICE "%s: unsupported address family "
+				"(%u)\n", __func__, ssp->ss_family);
+			return ERR_PTR(-EIO);
+		}
 		name = buffer;
-	}
+	} else
+		name = argp->mon_name;
 
 	return xdr_encode_nsm_string(p, name);
 }
@@ -225,13 +243,35 @@ static __be32 *xdr_encode_mon_id(__be32 *p, struct nsm_args *argp)
  *
  * Linux provides the raw IP address of the monitored host,
  * left in network byte order.
+ *
+ * We should send only AF_INET6 addresses in this field if the
+ * underlying transport is IPv6, and only AF_INET addresses if
+ * the underlying transport is IPv4.
  */
 static __be32 *xdr_encode_priv(__be32 *p, struct nsm_args *argp)
 {
-	*p++ = argp->addr;
-	*p++ = 0;
-	*p++ = 0;
-	*p++ = 0;
+	const struct sockaddr_storage *ssp = &argp->addr;
+	const struct sockaddr_in *sin = (struct sockaddr_in *)ssp;
+	const struct sockaddr_in6 *sin6 = (struct sockaddr_in6 *)ssp;
+
+	switch (ssp->ss_family) {
+	case AF_INET:
+		*p++ = sin->sin_addr.s_addr;
+		*p++ = 0;
+		*p++ = 0;
+		*p++ = 0;
+		break;
+	case AF_INET6:
+		*p++ = sin6->sin6_addr.s6_addr32[0];
+		*p++ = sin6->sin6_addr.s6_addr32[1];
+		*p++ = sin6->sin6_addr.s6_addr32[2];
+		*p++ = sin6->sin6_addr.s6_addr32[3];
+		break;
+	default:
+		printk(KERN_NOTICE "%s: unsupported address family (%u)\n",
+			__func__, ssp->ss_family);
+		return ERR_PTR(-EIO);
+	}
 
 	return p;
 }
diff --git a/include/linux/lockd/sm_inter.h b/include/linux/lockd/sm_inter.h
index 5a5448b..0b0a0ae 100644
--- a/include/linux/lockd/sm_inter.h
+++ b/include/linux/lockd/sm_inter.h
@@ -25,7 +25,7 @@
  * Arguments for all calls to statd
  */
 struct nsm_args {
-	__be32		addr;		/* remote address */
+	struct sockaddr_storage addr;	/* remote address */
 	u32		prog;		/* RPC callback info */
 	u32		vers;
 	u32		proc;

