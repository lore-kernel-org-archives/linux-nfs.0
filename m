Return-Path: <SRS0=ULVj=QS=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D7C49C282CE
	for <linux-nfs@archiver.kernel.org>; Mon, 11 Feb 2019 16:24:57 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 9AFA8218F0
	for <linux-nfs@archiver.kernel.org>; Mon, 11 Feb 2019 16:24:57 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="sXiSrvQJ"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726881AbfBKQY5 (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 11 Feb 2019 11:24:57 -0500
Received: from mail-it1-f194.google.com ([209.85.166.194]:39354 "EHLO
        mail-it1-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1727620AbfBKQY4 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 11 Feb 2019 11:24:56 -0500
Received: by mail-it1-f194.google.com with SMTP id a6so27614265itl.4;
        Mon, 11 Feb 2019 08:24:55 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=sender:subject:from:to:cc:date:message-id:in-reply-to:references
         :user-agent:mime-version:content-transfer-encoding;
        bh=hFisUS2wY4cAxkMK31OrKYlKLz6xp9eW/iYDTJPTW8w=;
        b=sXiSrvQJCeZwXG4NFGWRtKKu7Dn8Np4gzsRxcRKX7UiKAHdqZZXhLgbk9LfjeetZ6f
         6em+AFg41HKyfTaUJHBMlFqzltKjoXnwQfH7dZcPX3dHmNejZgZE5SYbM1mUA13AVpr+
         SN8Z9Jp1yBqTHp0Oe5SXYKJcwtt4XKMlVBhLyux/kzeX/1gm3kK2+lsRoaJ0nTQVjtT5
         RfMQourt/sk3ygxlf+NP7g+ivu/mzkObadSH9Rt0g3iK8MvGd6bFhjN02o/ixJDDwBMu
         b1/8lhYatS8Ovqs633SdPXFGlNsu9x5kcq8/XhORkCFsJJ403E5T4qjm6grq4BimlxF7
         M+nA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:sender:subject:from:to:cc:date:message-id
         :in-reply-to:references:user-agent:mime-version
         :content-transfer-encoding;
        bh=hFisUS2wY4cAxkMK31OrKYlKLz6xp9eW/iYDTJPTW8w=;
        b=KQRN4Lxz6xtknQ0n1WO+FMXZZ7xF1kI4K2RqED+7lwZruYoVjg7kTUaeT41g+lQYPB
         tv9Hqgx2EiEDZXP+Eo+5WIUarBpP/fNyAG248F5pGL7goHSX5wOPa/ItvyYBMops4I/F
         9e8Qr8ZZoVk++2fow9N4Kfs/BokLzfIj/OSl0S18EB00w+yos+dZUJtQdWUKJXjPD2K6
         3Ncx0yTxxOZgUp1bssQoJT8XwTSayrOg38RIUFZNE1OEDju89XFV4PdAOY54stsM4b6t
         NW3KkglBCFv/eebfmXtQrUx90tXlOBC49gwHleWmjq8IHgS5U33nPzXev306NnHH8gIQ
         fB0Q==
X-Gm-Message-State: AHQUAubiYcQAT2o3UhT/dWy7mIhrLu6k7IR5pOL296rCwdLwoQWxVWQC
        5rJBTBhKBirTqnF0cWEJ5G0=
X-Google-Smtp-Source: AHgI3IZuN5QxFj8Y3dpa/dOlRVHFn83txUcWqE17pAg6mtYwKJvhw0z+Kn6OYCTsQr2hCcl4n7n8QQ==
X-Received: by 2002:a02:8a44:: with SMTP id e4mr14696996jal.13.1549902295240;
        Mon, 11 Feb 2019 08:24:55 -0800 (PST)
Received: from gateway.1015granger.net (c-68-61-232-219.hsd1.mi.comcast.net. [68.61.232.219])
        by smtp.gmail.com with ESMTPSA id a21sm4769603iod.63.2019.02.11.08.24.54
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 11 Feb 2019 08:24:54 -0800 (PST)
Received: from manet.1015granger.net (manet.1015granger.net [192.168.1.51])
        by gateway.1015granger.net (8.14.7/8.14.7) with ESMTP id x1BGOriP029994;
        Mon, 11 Feb 2019 16:24:53 GMT
Subject: [PATCH v1 14/23] SUNRPC: Clean up rpc_verify_header()
From:   Chuck Lever <chuck.lever@oracle.com>
To:     anna.schumaker@netapp.com
Cc:     linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date:   Mon, 11 Feb 2019 11:24:53 -0500
Message-ID: <20190211162453.2817.56974.stgit@manet.1015granger.net>
In-Reply-To: <20190211161920.2817.20881.stgit@manet.1015granger.net>
References: <20190211161920.2817.20881.stgit@manet.1015granger.net>
User-Agent: StGit/0.17.1-dirty
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

- Recover some instruction count because I'm about to introduce a
  few xdr_inline_decode call sites
- Replace dprintk() call sites with trace points
- Reduce the hot path so it fits in fewer cachelines

I've also renamed it rpc_decode_header() to match everything else
in the RPC client.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 include/linux/sunrpc/xdr.h    |    7 +
 include/trace/events/sunrpc.h |   52 ++++++++++
 net/sunrpc/clnt.c             |  223 ++++++++++++++++++-----------------------
 3 files changed, 154 insertions(+), 128 deletions(-)

diff --git a/include/linux/sunrpc/xdr.h b/include/linux/sunrpc/xdr.h
index 6df9ac1..c540419 100644
--- a/include/linux/sunrpc/xdr.h
+++ b/include/linux/sunrpc/xdr.h
@@ -92,6 +92,9 @@ struct xdr_buf {
 #define	rpc_auth_gss	cpu_to_be32(RPC_AUTH_GSS)
 
 #define	rpc_call	cpu_to_be32(RPC_CALL)
+#define	rpc_reply	cpu_to_be32(RPC_REPLY)
+
+#define	rpc_msg_accepted	cpu_to_be32(RPC_MSG_ACCEPTED)
 
 #define	rpc_success		cpu_to_be32(RPC_SUCCESS)
 #define	rpc_prog_unavail	cpu_to_be32(RPC_PROG_UNAVAIL)
@@ -101,6 +104,9 @@ struct xdr_buf {
 #define	rpc_system_err		cpu_to_be32(RPC_SYSTEM_ERR)
 #define	rpc_drop_reply		cpu_to_be32(RPC_DROP_REPLY)
 
+#define	rpc_mismatch		cpu_to_be32(RPC_MISMATCH)
+#define	rpc_auth_error		cpu_to_be32(RPC_AUTH_ERROR)
+
 #define	rpc_auth_ok		cpu_to_be32(RPC_AUTH_OK)
 #define	rpc_autherr_badcred	cpu_to_be32(RPC_AUTH_BADCRED)
 #define	rpc_autherr_rejectedcred cpu_to_be32(RPC_AUTH_REJECTEDCRED)
@@ -109,7 +115,6 @@ struct xdr_buf {
 #define	rpc_autherr_tooweak	cpu_to_be32(RPC_AUTH_TOOWEAK)
 #define	rpcsec_gsserr_credproblem	cpu_to_be32(RPCSEC_GSS_CREDPROBLEM)
 #define	rpcsec_gsserr_ctxproblem	cpu_to_be32(RPCSEC_GSS_CTXPROBLEM)
-#define	rpc_autherr_oldseqnum	cpu_to_be32(101)
 
 /*
  * Miscellaneous XDR helper functions
diff --git a/include/trace/events/sunrpc.h b/include/trace/events/sunrpc.h
index 2b3f9d1..0654e9c 100644
--- a/include/trace/events/sunrpc.h
+++ b/include/trace/events/sunrpc.h
@@ -241,6 +241,58 @@
 			TP_ARGS(task))
 
 DEFINE_RPC_FAILURE(callhdr);
+DEFINE_RPC_FAILURE(verifier);
+
+DECLARE_EVENT_CLASS(rpc_reply_event,
+
+	TP_PROTO(
+		const struct rpc_task *task
+	),
+
+	TP_ARGS(task),
+
+	TP_STRUCT__entry(
+		__field(unsigned int, task_id)
+		__field(unsigned int, client_id)
+		__field(u32, xid)
+		__string(progname, task->tk_client->cl_program->name)
+		__field(u32, version)
+		__string(procname, rpc_proc_name(task))
+		__string(servername, task->tk_xprt->servername)
+	),
+
+	TP_fast_assign(
+		__entry->task_id = task->tk_pid;
+		__entry->client_id = task->tk_client->cl_clid;
+		__entry->xid = be32_to_cpu(task->tk_rqstp->rq_xid);
+		__assign_str(progname, task->tk_client->cl_program->name)
+		__entry->version = task->tk_client->cl_vers;
+		__assign_str(procname, rpc_proc_name(task))
+		__assign_str(servername, task->tk_xprt->servername)
+	),
+
+	TP_printk("task:%u@%d server=%s xid=0x%08x %sv%d %s",
+		__entry->task_id, __entry->client_id, __get_str(servername),
+		__entry->xid, __get_str(progname), __entry->version,
+		__get_str(procname))
+)
+
+#define DEFINE_RPC_REPLY_EVENT(name)					\
+	DEFINE_EVENT(rpc_reply_event, rpc__##name,			\
+			TP_PROTO(					\
+				const struct rpc_task *task		\
+			),						\
+			TP_ARGS(task))
+
+DEFINE_RPC_REPLY_EVENT(prog_unavail);
+DEFINE_RPC_REPLY_EVENT(prog_mismatch);
+DEFINE_RPC_REPLY_EVENT(proc_unavail);
+DEFINE_RPC_REPLY_EVENT(garbage_args);
+DEFINE_RPC_REPLY_EVENT(unparsable);
+DEFINE_RPC_REPLY_EVENT(mismatch);
+DEFINE_RPC_REPLY_EVENT(stale_creds);
+DEFINE_RPC_REPLY_EVENT(bad_creds);
+DEFINE_RPC_REPLY_EVENT(auth_tooweak);
 
 TRACE_EVENT(rpc_stats_latency,
 
diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
index d6750b7..e973508 100644
--- a/net/sunrpc/clnt.c
+++ b/net/sunrpc/clnt.c
@@ -79,7 +79,7 @@
 
 static int	rpc_encode_header(struct rpc_task *task,
 				  struct xdr_stream *xdr);
-static __be32	*rpc_verify_header(struct rpc_task *task);
+static __be32	*rpc_decode_header(struct rpc_task *task);
 static int	rpc_ping(struct rpc_clnt *clnt);
 
 static void rpc_register_client(struct rpc_clnt *clnt)
@@ -2292,7 +2292,7 @@ void rpc_force_rebind(struct rpc_clnt *clnt)
 		goto out_retry;
 	}
 
-	p = rpc_verify_header(task);
+	p = rpc_decode_header(task);
 	if (IS_ERR(p)) {
 		if (p == ERR_PTR(-EAGAIN))
 			goto out_retry;
@@ -2308,7 +2308,7 @@ void rpc_force_rebind(struct rpc_clnt *clnt)
 	return;
 out_retry:
 	task->tk_status = 0;
-	/* Note: rpc_verify_header() may have freed the RPC slot */
+	/* Note: rpc_decode_header() may have freed the RPC slot */
 	if (task->tk_rqstp == req) {
 		xdr_free_bvec(&req->rq_rcv_buf);
 		req->rq_reply_bytes_recvd = req->rq_rcv_buf.len = 0;
@@ -2347,164 +2347,133 @@ void rpc_force_rebind(struct rpc_clnt *clnt)
 	return error;
 }
 
-static __be32 *
-rpc_verify_header(struct rpc_task *task)
+static noinline __be32 *
+rpc_decode_header(struct rpc_task *task)
 {
 	struct rpc_clnt *clnt = task->tk_client;
 	struct kvec *iov = &task->tk_rqstp->rq_rcv_buf.head[0];
 	int len = task->tk_rqstp->rq_rcv_buf.len >> 2;
 	__be32	*p = iov->iov_base;
-	u32 n;
 	int error = -EACCES;
 
-	if ((task->tk_rqstp->rq_rcv_buf.len & 3) != 0) {
-		/* RFC-1014 says that the representation of XDR data must be a
-		 * multiple of four bytes
-		 * - if it isn't pointer subtraction in the NFS client may give
-		 *   undefined results
-		 */
-		dprintk("RPC: %5u %s: XDR representation not a multiple of"
-		       " 4 bytes: 0x%x\n", task->tk_pid, __func__,
-		       task->tk_rqstp->rq_rcv_buf.len);
-		error = -EIO;
-		goto out_err;
-	}
+	/* RFC-1014 says that the representation of XDR data must be a
+	 * multiple of four bytes
+	 * - if it isn't pointer subtraction in the NFS client may give
+	 *   undefined results
+	 */
+	if (task->tk_rqstp->rq_rcv_buf.len & 3)
+		goto out_badlen;
 	if ((len -= 3) < 0)
-		goto out_overflow;
+		goto out_unparsable;
 
-	p += 1; /* skip XID */
-	if ((n = ntohl(*p++)) != RPC_REPLY) {
-		dprintk("RPC: %5u %s: not an RPC reply: %x\n",
-			task->tk_pid, __func__, n);
-		error = -EIO;
-		goto out_garbage;
-	}
+	p++;	/* skip XID */
+	if (*p++ != rpc_reply)
+		goto out_unparsable;
+	if (*p++ != rpc_msg_accepted)
+		goto out_msg_denied;
 
-	if ((n = ntohl(*p++)) != RPC_MSG_ACCEPTED) {
-		if (--len < 0)
-			goto out_overflow;
-		switch ((n = ntohl(*p++))) {
-		case RPC_AUTH_ERROR:
-			break;
-		case RPC_MISMATCH:
-			dprintk("RPC: %5u %s: RPC call version mismatch!\n",
-				task->tk_pid, __func__);
-			error = -EPROTONOSUPPORT;
-			goto out_err;
-		default:
-			dprintk("RPC: %5u %s: RPC call rejected, "
-				"unknown error: %x\n",
-				task->tk_pid, __func__, n);
-			error = -EIO;
-			goto out_err;
-		}
-		if (--len < 0)
-			goto out_overflow;
-		switch ((n = ntohl(*p++))) {
-		case RPC_AUTH_REJECTEDCRED:
-		case RPC_AUTH_REJECTEDVERF:
-		case RPCSEC_GSS_CREDPROBLEM:
-		case RPCSEC_GSS_CTXPROBLEM:
-			if (!task->tk_cred_retry)
-				break;
-			task->tk_cred_retry--;
-			dprintk("RPC: %5u %s: retry stale creds\n",
-					task->tk_pid, __func__);
-			rpcauth_invalcred(task);
-			/* Ensure we obtain a new XID! */
-			xprt_release(task);
-			task->tk_action = call_reserve;
-			goto out_retry;
-		case RPC_AUTH_BADCRED:
-		case RPC_AUTH_BADVERF:
-			/* possibly garbled cred/verf? */
-			if (!task->tk_garb_retry)
-				break;
-			task->tk_garb_retry--;
-			dprintk("RPC: %5u %s: retry garbled creds\n",
-					task->tk_pid, __func__);
-			task->tk_action = call_encode;
-			goto out_retry;
-		case RPC_AUTH_TOOWEAK:
-			printk(KERN_NOTICE "RPC: server %s requires stronger "
-			       "authentication.\n",
-			       task->tk_xprt->servername);
-			break;
-		default:
-			dprintk("RPC: %5u %s: unknown auth error: %x\n",
-					task->tk_pid, __func__, n);
-			error = -EIO;
-		}
-		dprintk("RPC: %5u %s: call rejected %d\n",
-				task->tk_pid, __func__, n);
-		goto out_err;
-	}
 	p = rpcauth_checkverf(task, p);
-	if (IS_ERR(p)) {
-		error = PTR_ERR(p);
-		dprintk("RPC: %5u %s: auth check failed with %d\n",
-				task->tk_pid, __func__, error);
-		goto out_garbage;		/* bad verifier, retry */
-	}
+	if (IS_ERR(p))
+		goto out_verifier;
+
 	len = p - (__be32 *)iov->iov_base - 1;
 	if (len < 0)
-		goto out_overflow;
-	switch ((n = ntohl(*p++))) {
-	case RPC_SUCCESS:
+		goto out_unparsable;
+	switch (*p++) {
+	case rpc_success:
 		return p;
-	case RPC_PROG_UNAVAIL:
-		dprintk("RPC: %5u %s: program %u is unsupported "
-				"by server %s\n", task->tk_pid, __func__,
-				(unsigned int)clnt->cl_prog,
-				task->tk_xprt->servername);
+	case rpc_prog_unavail:
+		trace_rpc__prog_unavail(task);
 		error = -EPFNOSUPPORT;
 		goto out_err;
-	case RPC_PROG_MISMATCH:
-		dprintk("RPC: %5u %s: program %u, version %u unsupported "
-				"by server %s\n", task->tk_pid, __func__,
-				(unsigned int)clnt->cl_prog,
-				(unsigned int)clnt->cl_vers,
-				task->tk_xprt->servername);
+	case rpc_prog_mismatch:
+		trace_rpc__prog_mismatch(task);
 		error = -EPROTONOSUPPORT;
 		goto out_err;
-	case RPC_PROC_UNAVAIL:
-		dprintk("RPC: %5u %s: proc %s unsupported by program %u, "
-				"version %u on server %s\n",
-				task->tk_pid, __func__,
-				rpc_proc_name(task),
-				clnt->cl_prog, clnt->cl_vers,
-				task->tk_xprt->servername);
+	case rpc_proc_unavail:
+		trace_rpc__proc_unavail(task);
 		error = -EOPNOTSUPP;
 		goto out_err;
-	case RPC_GARBAGE_ARGS:
-		dprintk("RPC: %5u %s: server saw garbage\n",
-				task->tk_pid, __func__);
-		break;			/* retry */
+	case rpc_garbage_args:
+		trace_rpc__garbage_args(task);
+		break;
 	default:
-		dprintk("RPC: %5u %s: server accept status: %x\n",
-				task->tk_pid, __func__, n);
-		/* Also retry */
+		trace_rpc__unparsable(task);
 	}
 
 out_garbage:
 	clnt->cl_stats->rpcgarbage++;
 	if (task->tk_garb_retry) {
 		task->tk_garb_retry--;
-		dprintk("RPC: %5u %s: retrying\n",
-				task->tk_pid, __func__);
 		task->tk_action = call_encode;
-out_retry:
 		return ERR_PTR(-EAGAIN);
 	}
 out_err:
 	rpc_exit(task, error);
-	dprintk("RPC: %5u %s: call failed with error %d\n", task->tk_pid,
-			__func__, error);
 	return ERR_PTR(error);
-out_overflow:
-	dprintk("RPC: %5u %s: server reply was truncated.\n", task->tk_pid,
-			__func__);
+
+out_badlen:
+	trace_rpc__unparsable(task);
+	error = -EIO;
+	goto out_err;
+
+out_unparsable:
+	trace_rpc__unparsable(task);
+	error = -EIO;
 	goto out_garbage;
+
+out_verifier:
+	trace_rpc_bad_verifier(task);
+	error = PTR_ERR(p);
+	goto out_garbage;
+
+out_msg_denied:
+	switch (*p++) {
+	case rpc_auth_error:
+		break;
+	case rpc_mismatch:
+		trace_rpc__mismatch(task);
+		error = -EPROTONOSUPPORT;
+		goto out_err;
+	default:
+		trace_rpc__unparsable(task);
+		error = -EIO;
+		goto out_err;
+	}
+
+	switch (*p++) {
+	case rpc_autherr_rejectedcred:
+	case rpc_autherr_rejectedverf:
+	case rpcsec_gsserr_credproblem:
+	case rpcsec_gsserr_ctxproblem:
+		if (!task->tk_cred_retry)
+			break;
+		task->tk_cred_retry--;
+		trace_rpc__stale_creds(task);
+		rpcauth_invalcred(task);
+		/* Ensure we obtain a new XID! */
+		xprt_release(task);
+		task->tk_action = call_reserve;
+		return ERR_PTR(-EAGAIN);
+	case rpc_autherr_badcred:
+	case rpc_autherr_badverf:
+		/* possibly garbled cred/verf? */
+		if (!task->tk_garb_retry)
+			break;
+		task->tk_garb_retry--;
+		trace_rpc__bad_creds(task);
+		task->tk_action = call_encode;
+		return ERR_PTR(-EAGAIN);
+	case rpc_autherr_tooweak:
+		trace_rpc__auth_tooweak(task);
+		pr_warn("RPC: server %s requires stronger authentication.\n",
+			task->tk_xprt->servername);
+		break;
+	default:
+		trace_rpc__unparsable(task);
+		error = -EIO;
+	}
+	goto out_err;
 }
 
 static void rpcproc_encode_null(struct rpc_rqst *rqstp, struct xdr_stream *xdr,

