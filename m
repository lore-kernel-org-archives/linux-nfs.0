Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f66.google.com ([209.85.214.66]:33603 "EHLO
        mail-it0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750816AbdCJBh6 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 9 Mar 2017 20:37:58 -0500
Received: by mail-it0-f66.google.com with SMTP id g138so94801itb.0
        for <linux-nfs@vger.kernel.org>; Thu, 09 Mar 2017 17:37:58 -0800 (PST)
Subject: Re: [PATCH] SUNRPC: Make sure authorize svc when meeting SVC_CLOSE
To: "J. Bruce Fields" <bfields@fieldses.org>
References: <090f6673-1bb3-d626-e27e-6be5afcda782@gmail.com>
 <20170118222028.GB4272@fieldses.org>
Cc: linux-nfs@vger.kernel.org, Chuck Lever <chuck.lever@oracle.com>,
        Kinglong Mee <kinglongmee@gmail.com>
From: Kinglong Mee <kinglongmee@gmail.com>
Message-ID: <2a4525db-8ef0-bd33-5119-7d0046345827@gmail.com>
Date: Fri, 10 Mar 2017 09:37:43 +0800
MIME-Version: 1.0
In-Reply-To: <20170118222028.GB4272@fieldses.org>
Content-Type: text/plain; charset=windows-1252
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 1/19/2017 06:20, J. Bruce Fields wrote:
> On Mon, Jan 16, 2017 at 08:23:37AM +0800, Kinglong Mee wrote:
>> Commit 4d712ef1db05 "svcauth_gss: Close connection when
>>  dropping an incoming message" will close connection,
>> but forget authorizing the svc when meeting SVC_CLOSE.
>>
>> That, there will be an module reference to sunrpc,
>> and some memory leak.
>>
>> When mounting an nfs filesystem, the reference leak increase one.
> 
> Thanks, applying for 4.10.
> 
> (I'm not too happy with this function--e.g. it'd be easier to avoid this
> sort of bug if we had a single unavoidable common exit that always
> called svc_authenticate.
> 
> But I'm not sure of the best cleanup on a quick look.  And this is a
> simple bugfix.  Maybe we could add some cleanup on top for 4.11.)

Hi Bruce, 

I don't see this patch in the latest linux kernel (4.11.0-rc1+),
what's your plan about it?

Ps, for the cleanup, I have a draft for it, but it's a good one.

thanks,
Kinglong Mee

-----------------------------------------------------------------------------
diff --git a/net/sunrpc/svc.c b/net/sunrpc/svc.c
index 44e7d49..a390842 100644
--- a/net/sunrpc/svc.c
+++ b/net/sunrpc/svc.c
@@ -1086,6 +1086,30 @@ void svc_printk(struct svc_rqst *rqstp, const char *fmt, ...)
 static __printf(2,3) void svc_printk(struct svc_rqst *rqstp, const char *fmt, ...) {}
 #endif
 
+#define FMT_ERR_ENCODE(rpc_stat) do {					\
+	svc_printk(rqstp, "svc: decode error ##rpc_stat (%s:%d)\n",	\
+			__FILE__, __LINE__);				\
+	serv->sv_stats->rpcbadfmt++;					\
+	svc_putnl(resv, (rpc_stat));					\
+} while (0)
+
+#define VERS_ERR_ENCODE(lovers, hivers) do {				\
+	FMT_ERR_ENCODE(RPC_PROG_MISMATCH);				\
+	svc_putnl(resv, (lovers));					\
+	svc_putnl(resv, (hivers));					\
+} while (0)
+
+#define AUTH_ERR_ENCODE(auth_stat) do {					\
+	svc_printk(rqstp, "svc: authentication error %d (%s:%d)\n",	\
+			ntohl(auth_stat), __FILE__, __LINE__);		\
+	serv->sv_stats->rpcbadauth++;					\
+	/* Restore write pointer to location of accept status: */	\
+	xdr_ressize_check(rqstp, reply_statp);				\
+	svc_putnl(resv, 1);	/* REJECT */				\
+	svc_putnl(resv, 1);	/* AUTH_ERROR */			\
+	svc_putnl(resv, ntohl(auth_stat));	/* status */		\
+} while (0)
+
 /*
  * Common routine for processing the RPC request.
  */
@@ -1099,14 +1123,15 @@ svc_process_common(struct svc_rqst *rqstp, struct kvec *argv, struct kvec *resv)
 	kxdrproc_t		xdr;
 	__be32			*statp;
 	u32			prog, vers, proc;
-	__be32			auth_stat, rpc_stat;
+	__be32			auth_stat;
 	int			auth_res;
 	__be32			*reply_statp;
 
-	rpc_stat = rpc_success;
-
-	if (argv->iov_len < 6*4)
-		goto err_short_len;
+	if (argv->iov_len < 6*4) {
+		svc_printk(rqstp, "short len %zd, dropping request\n",
+				argv->iov_len);
+		goto close;
+	}
 
 	/* Will be turned off only in gss privacy case: */
 	set_bit(RQ_SPLICE_OK, &rqstp->rq_flags);
@@ -1124,8 +1149,14 @@ svc_process_common(struct svc_rqst *rqstp, struct kvec *argv, struct kvec *resv)
 	/* First words of reply: */
 	svc_putnl(resv, 1);		/* REPLY */
 
-	if (vers != 2)		/* RPC version number */
-		goto err_bad_rpc;
+	if (vers != 2) {		/* RPC version number */
+		serv->sv_stats->rpcbadfmt++;
+		svc_putnl(resv, 1);     /* REJECT */
+		svc_putnl(resv, 0);	/* RPC_MISMATCH */
+		svc_putnl(resv, 2);	/* Only RPCv2 supported */
+		svc_putnl(resv, 2);
+		goto sendit;
+	}
 
 	/* Save position in case we later decide to reject: */
 	reply_statp = resv->iov_base + resv->iov_len;
@@ -1155,12 +1186,14 @@ svc_process_common(struct svc_rqst *rqstp, struct kvec *argv, struct kvec *resv)
 	case SVC_OK:
 		break;
 	case SVC_GARBAGE:
-		goto err_garbage;
+		FMT_ERR_ENCODE(RPC_GARBAGE_ARGS);
+		goto sendit;
 	case SVC_SYSERR:
-		rpc_stat = rpc_system_err;
-		goto err_bad;
+		FMT_ERR_ENCODE(RPC_SYSTEM_ERR);
+		goto sendit;
 	case SVC_DENIED:
-		goto err_bad_auth;
+		AUTH_ERR_ENCODE(auth_stat);
+		goto sendit;
 	case SVC_CLOSE:
 		/*
 		 * Makesure authorise svc if progp->pg_authenticate fail,
@@ -1174,12 +1207,19 @@ svc_process_common(struct svc_rqst *rqstp, struct kvec *argv, struct kvec *resv)
 		goto sendit;
 	}
 
-	if (progp == NULL)
-		goto err_bad_prog;
+	if (progp == NULL) {
+		FMT_ERR_ENCODE(RPC_PROG_UNAVAIL);
+		svc_printk(rqstp, "svc: unknown program %d\n", prog);
+		goto sendit;
+	}
 
 	if (vers >= progp->pg_nvers ||
-	  !(versp = progp->pg_vers[vers]))
-		goto err_bad_vers;
+	  !(versp = progp->pg_vers[vers])) {
+		VERS_ERR_ENCODE(progp->pg_lovers, progp->pg_hivers);
+		svc_printk(rqstp, "unknown version (%d for prog %d, %s)\n",
+			       vers, prog, progp->pg_name);
+		goto sendit;
+	}
 
 	/*
 	 * Some protocol versions (namely NFSv4) require some form of
@@ -1193,12 +1233,20 @@ svc_process_common(struct svc_rqst *rqstp, struct kvec *argv, struct kvec *resv)
 	 * fit.
 	 */
 	if (versp->vs_need_cong_ctrl &&
-	    !test_bit(XPT_CONG_CTRL, &rqstp->rq_xprt->xpt_flags))
-		goto err_bad_vers;
+	    !test_bit(XPT_CONG_CTRL, &rqstp->rq_xprt->xpt_flags)) {
+		VERS_ERR_ENCODE(progp->pg_lovers, progp->pg_hivers);
+		svc_printk(rqstp, "congestion control (%d for prog %d, %s)\n",
+			       vers, prog, progp->pg_name);
+		goto sendit;
+	}
 
 	procp = versp->vs_proc + proc;
-	if (proc >= versp->vs_nproc || !procp->pc_func)
-		goto err_bad_proc;
+	if (proc >= versp->vs_nproc || !procp->pc_func) {
+		FMT_ERR_ENCODE(RPC_PROC_UNAVAIL);
+		svc_printk(rqstp, "unknown procedure (%d)\n", proc);
+		goto sendit;
+	}
+
 	rqstp->rq_procinfo = procp;
 
 	/* Syntactic check complete */
@@ -1225,8 +1273,10 @@ svc_process_common(struct svc_rqst *rqstp, struct kvec *argv, struct kvec *resv)
 	if (!versp->vs_dispatch) {
 		/* Decode arguments */
 		xdr = procp->pc_decode;
-		if (xdr && !xdr(rqstp, argv->iov_base, rqstp->rq_argp))
-			goto err_garbage;
+		if (xdr && !xdr(rqstp, argv->iov_base, rqstp->rq_argp)) {
+			FMT_ERR_ENCODE(RPC_GARBAGE_ARGS);
+			goto sendit;
+		}
 
 		*statp = procp->pc_func(rqstp, rqstp->rq_argp, rqstp->rq_resp);
 
@@ -1240,12 +1290,14 @@ svc_process_common(struct svc_rqst *rqstp, struct kvec *argv, struct kvec *resv)
 		if (*statp == rpc_autherr_badcred) {
 			if (procp->pc_release)
 				procp->pc_release(rqstp, NULL, rqstp->rq_resp);
-			goto err_bad_auth;
+
+			AUTH_ERR_ENCODE(auth_stat);
+			goto sendit;
 		}
 		if (*statp == rpc_success &&
 		    (xdr = procp->pc_encode) &&
 		    !xdr(rqstp, resv->iov_base+resv->iov_len, rqstp->rq_resp)) {
-			dprintk("svc: failed to encode reply\n");
+			svc_printk(rqstp, "svc: failed to encode reply\n");
 			/* serv->sv_stats->rpcsystemerr++; */
 			*statp = rpc_system_err;
 		}
@@ -1269,77 +1321,18 @@ svc_process_common(struct svc_rqst *rqstp, struct kvec *argv, struct kvec *resv)
 
 	if (procp->pc_encode == NULL)
 		goto dropit;
-
- sendit:
-	if (svc_authorise(rqstp))
-		goto close;
-	return 1;		/* Caller can now send it */
-
- dropit:
-	svc_authorise(rqstp);	/* doesn't hurt to call this twice */
-	dprintk("svc: svc_process dropit\n");
-	return 0;
-
- close:
+sendit:
+	if (!svc_authorise(rqstp))
+		return 1;		/* Caller can now send it */
+close:
 	if (test_bit(XPT_TEMP, &rqstp->rq_xprt->xpt_flags))
 		svc_close_xprt(rqstp->rq_xprt);
 	dprintk("svc: svc_process close\n");
 	return 0;
-
-err_short_len:
-	svc_printk(rqstp, "short len %zd, dropping request\n",
-			argv->iov_len);
-	goto close;
-
-err_bad_rpc:
-	serv->sv_stats->rpcbadfmt++;
-	svc_putnl(resv, 1);	/* REJECT */
-	svc_putnl(resv, 0);	/* RPC_MISMATCH */
-	svc_putnl(resv, 2);	/* Only RPCv2 supported */
-	svc_putnl(resv, 2);
-	goto sendit;
-
-err_bad_auth:
-	dprintk("svc: authentication failed (%d)\n", ntohl(auth_stat));
-	serv->sv_stats->rpcbadauth++;
-	/* Restore write pointer to location of accept status: */
-	xdr_ressize_check(rqstp, reply_statp);
-	svc_putnl(resv, 1);	/* REJECT */
-	svc_putnl(resv, 1);	/* AUTH_ERROR */
-	svc_putnl(resv, ntohl(auth_stat));	/* status */
-	goto sendit;
-
-err_bad_prog:
-	dprintk("svc: unknown program %d\n", prog);
-	serv->sv_stats->rpcbadfmt++;
-	svc_putnl(resv, RPC_PROG_UNAVAIL);
-	goto sendit;
-
-err_bad_vers:
-	svc_printk(rqstp, "unknown version (%d for prog %d, %s)\n",
-		       vers, prog, progp->pg_name);
-
-	serv->sv_stats->rpcbadfmt++;
-	svc_putnl(resv, RPC_PROG_MISMATCH);
-	svc_putnl(resv, progp->pg_lovers);
-	svc_putnl(resv, progp->pg_hivers);
-	goto sendit;
-
-err_bad_proc:
-	svc_printk(rqstp, "unknown procedure (%d)\n", proc);
-
-	serv->sv_stats->rpcbadfmt++;
-	svc_putnl(resv, RPC_PROC_UNAVAIL);
-	goto sendit;
-
-err_garbage:
-	svc_printk(rqstp, "failed to decode args\n");
-
-	rpc_stat = rpc_garbage_args;
-err_bad:
-	serv->sv_stats->rpcbadfmt++;
-	svc_putnl(resv, ntohl(rpc_stat));
-	goto sendit;
+dropit:
+	svc_authorise(rqstp);	/* doesn't hurt to call this twice */
+	dprintk("svc: svc_process dropit\n");
+	return 0;
 }
 
 /*
