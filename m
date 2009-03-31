From: Greg Banks <gnb@sgi.com>
Subject: [patch 23/29] knfsd: introduce SVC_INC_STAT
Date: Wed, 01 Apr 2009 07:28:23 +1100
Message-ID: <20090331202946.527917000@sgi.com>
References: <20090331202800.739621000@sgi.com>
Cc: Linux NFS ML <linux-nfs@vger.kernel.org>
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from [218.185.19.242] ([218.185.19.242]:22590 "EHLO inara.melbourne"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1761518AbZCaVCr (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 31 Mar 2009 17:02:47 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Replace direct increments of counters in the svc_stat structure
attached to each svc_serv, with the macro SVC_INC_STAT().  This doesn't
change any functionality but prepares for a subsequent patch which
changes the definitions of those macros to make the sv_stat counters
per-cpu for performance.

Signed-off-by: Greg Banks <gnb@sgi.com>
Reviewed-by: David Chinner <dgc@sgi.com>
Reviewed-by: Peter Leckie <pleckie-cP1dWloDopni96+mSzHFpQC/G2K4zDHf@public.gmane.org>
---

 include/linux/sunrpc/svc.h |    3 +++
 net/sunrpc/svc.c           |   18 +++++++++---------
 net/sunrpc/svcsock.c       |   12 ++++--------
 3 files changed, 16 insertions(+), 17 deletions(-)

Index: bfields/include/linux/sunrpc/svc.h
===================================================================
--- bfields.orig/include/linux/sunrpc/svc.h
+++ bfields/include/linux/sunrpc/svc.h
@@ -109,6 +109,9 @@ struct svc_serv {
 	unsigned int		sv_drc_pages_used;/* DRC pages used */
 #endif /* CONFIG_NFSD_V4_1 */
 };
+#define SVC_INC_STAT(serv, field) \
+	((serv)->sv_stats ? \
+		++((serv)->sv_stats->field) : 0)
 
 /*
  * We use sv_nrthreads as a reference count.  svc_destroy() drops
Index: bfields/net/sunrpc/svc.c
===================================================================
--- bfields.orig/net/sunrpc/svc.c
+++ bfields/net/sunrpc/svc.c
@@ -1084,7 +1084,7 @@ svc_process(struct svc_rqst *rqstp)
 	rqstp->rq_procinfo = procp;
 
 	/* Syntactic check complete */
-	serv->sv_stats->rpccnt++;
+	SVC_INC_STAT(serv, rpccnt);
 
 	/* Build the reply header. */
 	statp = resv->iov_base +resv->iov_len;
@@ -1121,7 +1121,7 @@ svc_process(struct svc_rqst *rqstp)
 		if (*statp == rpc_success && (xdr = procp->pc_encode)
 		 && !xdr(rqstp, resv->iov_base+resv->iov_len, rqstp->rq_resp)) {
 			dprintk("svc: failed to encode reply\n");
-			/* serv->sv_stats->rpcsystemerr++; */
+			/* SVC_INC_STAT(serv, rpcsystemerr); */
 			*statp = rpc_system_err;
 		}
 	} else {
@@ -1165,11 +1165,11 @@ err_short_len:
 err_bad_dir:
 	svc_printk(rqstp, "bad direction %d, dropping request\n", dir);
 
-	serv->sv_stats->rpcbadfmt++;
+	SVC_INC_STAT(serv, rpcbadfmt);
 	goto dropit;			/* drop request */
 
 err_bad_rpc:
-	serv->sv_stats->rpcbadfmt++;
+	SVC_INC_STAT(serv, rpcbadfmt);
 	svc_putnl(resv, 1);	/* REJECT */
 	svc_putnl(resv, 0);	/* RPC_MISMATCH */
 	svc_putnl(resv, 2);	/* Only RPCv2 supported */
@@ -1178,7 +1178,7 @@ err_bad_rpc:
 
 err_bad_auth:
 	dprintk("svc: authentication failed (%d)\n", ntohl(auth_stat));
-	serv->sv_stats->rpcbadauth++;
+	SVC_INC_STAT(serv, rpcbadauth);
 	/* Restore write pointer to location of accept status: */
 	xdr_ressize_check(rqstp, reply_statp);
 	svc_putnl(resv, 1);	/* REJECT */
@@ -1188,7 +1188,7 @@ err_bad_auth:
 
 err_bad_prog:
 	dprintk("svc: unknown program %d\n", prog);
-	serv->sv_stats->rpcbadfmt++;
+	SVC_INC_STAT(serv, rpcbadfmt);
 	svc_putnl(resv, RPC_PROG_UNAVAIL);
 	goto sendit;
 
@@ -1196,7 +1196,7 @@ err_bad_vers:
 	svc_printk(rqstp, "unknown version (%d for prog %d, %s)\n",
 		       vers, prog, progp->pg_name);
 
-	serv->sv_stats->rpcbadfmt++;
+	SVC_INC_STAT(serv, rpcbadfmt);
 	svc_putnl(resv, RPC_PROG_MISMATCH);
 	svc_putnl(resv, progp->pg_lovers);
 	svc_putnl(resv, progp->pg_hivers);
@@ -1205,7 +1205,7 @@ err_bad_vers:
 err_bad_proc:
 	svc_printk(rqstp, "unknown procedure (%d)\n", proc);
 
-	serv->sv_stats->rpcbadfmt++;
+	SVC_INC_STAT(serv, rpcbadfmt);
 	svc_putnl(resv, RPC_PROC_UNAVAIL);
 	goto sendit;
 
@@ -1214,7 +1214,7 @@ err_garbage:
 
 	rpc_stat = rpc_garbage_args;
 err_bad:
-	serv->sv_stats->rpcbadfmt++;
+	SVC_INC_STAT(serv, rpcbadfmt);
 	svc_putnl(resv, ntohl(rpc_stat));
 	goto sendit;
 }
Index: bfields/net/sunrpc/svcsock.c
===================================================================
--- bfields.orig/net/sunrpc/svcsock.c
+++ bfields/net/sunrpc/svcsock.c
@@ -531,8 +531,7 @@ static int svc_udp_recvfrom(struct svc_r
 			DIV_ROUND_UP(rqstp->rq_arg.page_len, PAGE_SIZE);
 	}
 
-	if (serv->sv_stats)
-		serv->sv_stats->netudpcnt++;
+	SVC_INC_STAT(serv, netudpcnt);
 
 	return len;
 }
@@ -770,8 +769,7 @@ static struct svc_xprt *svc_tcp_accept(s
 	}
 	svc_xprt_set_local(&newsvsk->sk_xprt, sin, slen);
 
-	if (serv->sv_stats)
-		serv->sv_stats->nettcpconn++;
+	SVC_INC_STAT(serv, nettcpconn);
 
 	return &newsvsk->sk_xprt;
 
@@ -973,8 +971,7 @@ out:
 
 	svc_xprt_copy_addrs(rqstp, &svsk->sk_xprt);
 	svc_xprt_received(&svsk->sk_xprt);
-	if (serv->sv_stats)
-		serv->sv_stats->nettcpcnt++;
+	SVC_INC_STAT(serv, nettcpcnt);
 
 	return len;
 
Index: bfields/net/sunrpc/svc_xprt.c
===================================================================
--- bfields.orig/net/sunrpc/svc_xprt.c
+++ bfields/net/sunrpc/svc_xprt.c
@@ -765,8 +765,7 @@ int svc_recv(struct svc_rqst *rqstp, lon
 	rqstp->rq_secure = svc_port_is_privileged(svc_addr(rqstp));
 	rqstp->rq_chandle.defer = svc_defer;
 
-	if (serv->sv_stats)
-		serv->sv_stats->netcnt++;
+	SVC_INC_STAT(serv, netcnt);
 	return len;
 }
 EXPORT_SYMBOL_GPL(svc_recv);

--
Greg
