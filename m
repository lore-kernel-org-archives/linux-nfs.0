Return-Path: <linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 68AB4C54EE9
	for <linux-nfs@archiver.kernel.org>; Thu,  8 Sep 2022 22:13:53 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S229633AbiIHWNw (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Thu, 8 Sep 2022 18:13:52 -0400
Received: from lindbergh.monkeyblade.net ([23.128.96.19]:53476 "EHLO
        lindbergh.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S229832AbiIHWNv (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 8 Sep 2022 18:13:51 -0400
Received: from dfw.source.kernel.org (dfw.source.kernel.org [IPv6:2604:1380:4641:c500::1])
        by lindbergh.monkeyblade.net (Postfix) with ESMTPS id 768DB1098EF
        for <linux-nfs@vger.kernel.org>; Thu,  8 Sep 2022 15:13:50 -0700 (PDT)
Received: from smtp.kernel.org (relay.kernel.org [52.25.139.140])
        (using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
        (No client certificate requested)
        by dfw.source.kernel.org (Postfix) with ESMTPS id 1595961D99
        for <linux-nfs@vger.kernel.org>; Thu,  8 Sep 2022 22:13:50 +0000 (UTC)
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 6D509C433D6
        for <linux-nfs@vger.kernel.org>; Thu,  8 Sep 2022 22:13:49 +0000 (UTC)
Subject: [PATCH v4 2/8] NFSD: Trace NFSv4 COMPOUND tags
From:   Chuck Lever <chuck.lever@oracle.com>
To:     linux-nfs@vger.kernel.org
Date:   Thu, 08 Sep 2022 18:13:48 -0400
Message-ID: <166267522847.1842.6962635386840299926.stgit@manet.1015granger.net>
In-Reply-To: <166267495153.1842.14474564029477470642.stgit@manet.1015granger.net>
References: <166267495153.1842.14474564029477470642.stgit@manet.1015granger.net>
User-Agent: StGit/1.5.dev2+g9ce680a5
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

The Linux NFSv4 client implementation does not use COMPOUND tags,
but the Solaris and MacOS implementations do, and so does pynfs.
Record these eye-catchers in the server's trace buffer to annotate
client requests while troubleshooting.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 fs/nfsd/nfs4proc.c |    2 +-
 fs/nfsd/trace.h    |   21 ++++++++++++++-------
 2 files changed, 15 insertions(+), 8 deletions(-)

diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
index a72ab97f77ef..d43beb732987 100644
--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -2648,7 +2648,7 @@ nfsd4_proc_compound(struct svc_rqst *rqstp)
 
 	rqstp->rq_lease_breaker = (void **)&cstate->clp;
 
-	trace_nfsd_compound(rqstp, args->opcnt);
+	trace_nfsd_compound(rqstp, args->tag, args->taglen, args->opcnt);
 	while (!status && resp->opcnt < args->opcnt) {
 		op = &args->ops[resp->opcnt++];
 
diff --git a/fs/nfsd/trace.h b/fs/nfsd/trace.h
index 1b9f5753f336..0c35a1a844e6 100644
--- a/fs/nfsd/trace.h
+++ b/fs/nfsd/trace.h
@@ -84,19 +84,26 @@ DEFINE_NFSD_XDR_ERR_EVENT(cant_encode);
 		{ NFSD_MAY_64BIT_COOKIE,	"64BIT_COOKIE" })
 
 TRACE_EVENT(nfsd_compound,
-	TP_PROTO(const struct svc_rqst *rqst,
-		 u32 args_opcnt),
-	TP_ARGS(rqst, args_opcnt),
+	TP_PROTO(
+		const struct svc_rqst *rqst,
+		const char *tag,
+		u32 taglen,
+		u32 opcnt
+	),
+	TP_ARGS(rqst, tag, taglen, opcnt),
 	TP_STRUCT__entry(
 		__field(u32, xid)
-		__field(u32, args_opcnt)
+		__field(u32, opcnt)
+		__string_len(tag, tag, taglen)
 	),
 	TP_fast_assign(
 		__entry->xid = be32_to_cpu(rqst->rq_xid);
-		__entry->args_opcnt = args_opcnt;
+		__entry->opcnt = opcnt;
+		__assign_str_len(tag, tag, taglen);
 	),
-	TP_printk("xid=0x%08x opcnt=%u",
-		__entry->xid, __entry->args_opcnt)
+	TP_printk("xid=0x%08x opcnt=%u tag=%s",
+		__entry->xid, __entry->opcnt, __get_str(tag)
+	)
 )
 
 TRACE_EVENT(nfsd_compound_status,


