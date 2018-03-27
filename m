Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f67.google.com ([209.85.214.67]:39832 "EHLO
        mail-it0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752159AbeC0OyA (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 27 Mar 2018 10:54:00 -0400
Received: by mail-it0-f67.google.com with SMTP id e98-v6so15634902itd.4
        for <linux-nfs@vger.kernel.org>; Tue, 27 Mar 2018 07:54:00 -0700 (PDT)
Subject: [PATCH v2 16/18] nfsd: Trace NFSv4 COMPOUND execution
From: Chuck Lever <chuck.lever@oracle.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org
Date: Tue, 27 Mar 2018 10:53:54 -0400
Message-ID: <20180327145354.7710.13621.stgit@oracle-ib-101.nfsv4bat.org>
In-Reply-To: <20180327144420.7710.82288.stgit@oracle-ib-101.nfsv4bat.org>
References: <20180327144420.7710.82288.stgit@oracle-ib-101.nfsv4bat.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This helps record the identity and timing of the ops in each NFSv4
COMPOUND, replacing dprintk calls that did much the same thing.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 fs/nfsd/nfs4proc.c |    9 +++------
 fs/nfsd/trace.h    |   39 +++++++++++++++++++++++++++++++++++++++
 2 files changed, 42 insertions(+), 6 deletions(-)

diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
index 39016b6..0df37e0 100644
--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -1722,12 +1722,10 @@ static void svcxdr_init_encode(struct svc_rqst *rqstp,
 		goto encode_op;
 	}
 
+	trace_nfsd_compound(rqstp, args->opcnt);
 	while (!status && resp->opcnt < args->opcnt) {
 		op = &args->ops[resp->opcnt++];
 
-		dprintk("nfsv4 compound op #%d/%d: %d (%s)\n",
-			resp->opcnt, args->opcnt, op->opnum,
-			nfsd4_op_name(op->opnum));
 		/*
 		 * The XDR decode routines may have pre-set op->status;
 		 * for example, if there is a miscellaneous XDR error
@@ -1801,9 +1799,8 @@ static void svcxdr_init_encode(struct svc_rqst *rqstp,
 			status = op->status;
 		}
 
-		dprintk("nfsv4 compound op %p opcnt %d #%d: %d: status %d\n",
-			args->ops, args->opcnt, resp->opcnt, op->opnum,
-			be32_to_cpu(status));
+		trace_nfsd_compound_status(args->opcnt, resp->opcnt, status,
+					   nfsd4_op_name(op->opnum));
 
 		nfsd4_cstate_clear_replay(cstate);
 		nfsd4_increment_op_stats(op->opnum);
diff --git a/fs/nfsd/trace.h b/fs/nfsd/trace.h
index a8bbd9d..80933e4 100644
--- a/fs/nfsd/trace.h
+++ b/fs/nfsd/trace.h
@@ -11,6 +11,45 @@
 #include <linux/tracepoint.h>
 #include "nfsfh.h"
 
+TRACE_EVENT(nfsd_compound,
+	TP_PROTO(const struct svc_rqst *rqst,
+		 u32 args_opcnt),
+	TP_ARGS(rqst, args_opcnt),
+	TP_STRUCT__entry(
+		__field(u32, xid)
+		__field(u32, args_opcnt)
+	),
+	TP_fast_assign(
+		__entry->xid = be32_to_cpu(rqst->rq_xid);
+		__entry->args_opcnt = args_opcnt;
+	),
+	TP_printk("xid=0x%08x opcnt=%u",
+		__entry->xid, __entry->args_opcnt)
+)
+
+TRACE_EVENT(nfsd_compound_status,
+	TP_PROTO(u32 args_opcnt,
+		 u32 resp_opcnt,
+		 __be32 status,
+		 const char *name),
+	TP_ARGS(args_opcnt, resp_opcnt, status, name),
+	TP_STRUCT__entry(
+		__field(u32, args_opcnt)
+		__field(u32, resp_opcnt)
+		__field(int, status)
+		__string(name, name)
+	),
+	TP_fast_assign(
+		__entry->args_opcnt = args_opcnt;
+		__entry->resp_opcnt = resp_opcnt;
+		__entry->status = be32_to_cpu(status);
+		__assign_str(name, name);
+	),
+	TP_printk("op=%u/%u %s status=%d",
+		__entry->resp_opcnt, __entry->args_opcnt,
+		__get_str(name), __entry->status)
+)
+
 DECLARE_EVENT_CLASS(nfsd_io_class,
 	TP_PROTO(struct svc_rqst *rqstp,
 		 struct svc_fh	*fhp,

