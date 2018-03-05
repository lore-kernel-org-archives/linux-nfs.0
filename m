Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from userp2120.oracle.com ([156.151.31.85]:50634 "EHLO
        userp2120.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752063AbeCEVGQ (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 5 Mar 2018 16:06:16 -0500
From: Chuck Lever <chuck.lever@oracle.com>
Content-Type: text/plain;
        charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 11.2 \(3445.5.20\))
Subject: Use of uninitialized value $line in pattern match
Date: Mon, 5 Mar 2018 16:06:08 -0500
References: <20180305210022.18859.37483.stgit@klimt.1015granger.net>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
To: Andy Whitcroft <apw@canonical.com>, Joe Perches <joe@perches.com>
Message-Id: <7BF29D14-256C-4C81-A37C-C816441E57C8@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

I think I'm seeing a parsing error in v4.16-rc4 scripts/checkpatch.pl:

Use of uninitialized value $line in pattern match (m//) at =
scripts/checkpatch.pl line 1300.
Use of uninitialized value $line in pattern match (m//) at =
scripts/checkpatch.pl line 1300.
Use of uninitialized value $line in pattern match (m//) at =
scripts/checkpatch.pl line 1300.
Use of uninitialized value $line in pattern match (m//) at =
scripts/checkpatch.pl line 1300.
Use of uninitialized value $line in pattern match (m//) at =
scripts/checkpatch.pl line 1300.
Use of uninitialized value $line in pattern match (m//) at =
scripts/checkpatch.pl line 1300.
Use of uninitialized value $line in pattern match (m//) at =
scripts/checkpatch.pl line 1300.
Use of uninitialized value $line in pattern match (m//) at =
scripts/checkpatch.pl line 1300.
Use of uninitialized value $line in pattern match (m//) at =
scripts/checkpatch.pl line 1300.
Use of uninitialized value $line in pattern match (m//) at =
scripts/checkpatch.pl line 1300.
Use of uninitialized value $line in pattern match (m//) at =
scripts/checkpatch.pl line 1300.
Use of uninitialized value $line in pattern match (m//) at =
scripts/checkpatch.pl line 1300.
Use of uninitialized value $line in pattern match (m//) at =
scripts/checkpatch.pl line 1300.
Use of uninitialized value $line in pattern match (m//) at =
scripts/checkpatch.pl line 1300.
Use of uninitialized value $line in pattern match (m//) at =
scripts/checkpatch.pl line 1300.
Use of uninitialized value $line in pattern match (m//) at =
scripts/checkpatch.pl line 1300.
Use of uninitialized value $line in pattern match (m//) at =
scripts/checkpatch.pl line 1300.
Use of uninitialized value $line in pattern match (m//) at =
scripts/checkpatch.pl line 1300.
Use of uninitialized value $line in pattern match (m//) at =
scripts/checkpatch.pl line 1300.
Use of uninitialized value $line in pattern match (m//) at =
scripts/checkpatch.pl line 1300.
Use of uninitialized value $line in pattern match (m//) at =
scripts/checkpatch.pl line 1300.
Use of uninitialized value $line in pattern match (m//) at =
scripts/checkpatch.pl line 1300.
Use of uninitialized value $line in pattern match (m//) at =
scripts/checkpatch.pl line 1300.
Use of uninitialized value $line in pattern match (m//) at =
scripts/checkpatch.pl line 1300.
Use of uninitialized value $line in pattern match (m//) at =
scripts/checkpatch.pl line 1300.
Use of uninitialized value $line in pattern match (m//) at =
scripts/checkpatch.pl line 1300.
Use of uninitialized value $line in pattern match (m//) at =
scripts/checkpatch.pl line 1300.
total: 0 errors, 0 warnings, 69 lines checked

patches-nfsd-rdma-for-4.17/nfsd-compound-trace-points has no obvious =
style problems and is ready for submission.



nfsd: Trace NFSv4 COMPOUND execution

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
@@ -1722,12 +1722,10 @@ static void svcxdr_init_encode(struct svc_rqst =
*rqstp,
		goto encode_op;
	}

+	trace_nfsd_compound(rqstp, args->opcnt);
	while (!status && resp->opcnt < args->opcnt) {
		op =3D &args->ops[resp->opcnt++];

-		dprintk("nfsv4 compound op #%d/%d: %d (%s)\n",
-			resp->opcnt, args->opcnt, op->opnum,
-			nfsd4_op_name(op->opnum));
		/*
		 * The XDR decode routines may have pre-set op->status;
		 * for example, if there is a miscellaneous XDR error
@@ -1801,9 +1799,8 @@ static void svcxdr_init_encode(struct svc_rqst =
*rqstp,
			status =3D op->status;
		}

-		dprintk("nfsv4 compound op %p opcnt %d #%d: %d: status =
%d\n",
-			args->ops, args->opcnt, resp->opcnt, op->opnum,
-			be32_to_cpu(status));
+		trace_nfsd_compound_status(args->opcnt, resp->opcnt, =
status,
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
+		__entry->xid =3D be32_to_cpu(rqst->rq_xid);
+		__entry->args_opcnt =3D args_opcnt;
+	),
+	TP_printk("xid=3D0x%08x opcnt=3D%u",
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
+		__entry->args_opcnt =3D args_opcnt;
+		__entry->resp_opcnt =3D resp_opcnt;
+		__entry->status =3D be32_to_cpu(status);
+		__assign_str(name, name);
+	),
+	TP_printk("op=3D%u/%u %s status=3D%d",
+		__entry->resp_opcnt, __entry->args_opcnt,
+		__get_str(name), __entry->status)
+)
+
DECLARE_EVENT_CLASS(nfsd_io_class,
	TP_PROTO(struct svc_rqst *rqstp,
		 struct svc_fh	*fhp,


--
Chuck Lever



