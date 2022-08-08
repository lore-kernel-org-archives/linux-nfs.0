Return-Path: <linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5DCB7C00140
	for <linux-nfs@archiver.kernel.org>; Mon,  8 Aug 2022 13:49:23 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S237349AbiHHNtW (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 8 Aug 2022 09:49:22 -0400
Received: from lindbergh.monkeyblade.net ([23.128.96.19]:54024 "EHLO
        lindbergh.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S235611AbiHHNtV (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 8 Aug 2022 09:49:21 -0400
Received: from ams.source.kernel.org (ams.source.kernel.org [IPv6:2604:1380:4601:e00::1])
        by lindbergh.monkeyblade.net (Postfix) with ESMTPS id 6DD9BB1F8
        for <linux-nfs@vger.kernel.org>; Mon,  8 Aug 2022 06:49:20 -0700 (PDT)
Received: from smtp.kernel.org (relay.kernel.org [52.25.139.140])
        (using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
        (No client certificate requested)
        by ams.source.kernel.org (Postfix) with ESMTPS id 180BCB80EA1
        for <linux-nfs@vger.kernel.org>; Mon,  8 Aug 2022 13:49:19 +0000 (UTC)
Received: by smtp.kernel.org (Postfix) with ESMTPSA id CA381C433C1
        for <linux-nfs@vger.kernel.org>; Mon,  8 Aug 2022 13:49:17 +0000 (UTC)
Subject: [PATCH v3 2/7] NFSD: Replace dprintk() call site in fh_verify()
From:   Chuck Lever <chuck.lever@oracle.com>
To:     linux-nfs@vger.kernel.org
Date:   Mon, 08 Aug 2022 09:49:16 -0400
Message-ID: <165996655686.2613.13952702788417892616.stgit@manet.1015granger.net>
In-Reply-To: <165996655005.2613.3803552076018199850.stgit@manet.1015granger.net>
References: <165996655005.2613.3803552076018199850.stgit@manet.1015granger.net>
User-Agent: StGit/1.5.dev2+g9ce680a5
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Record permission errors in the trace log. Note that the new trace
event is conditional, so it will only record non-zero return values
from nfsd_permission().

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 fs/nfsd/nfsfh.c |    8 +-------
 fs/nfsd/trace.h |   46 ++++++++++++++++++++++++++++++++++++++++++++--
 2 files changed, 45 insertions(+), 9 deletions(-)

diff --git a/fs/nfsd/nfsfh.c b/fs/nfsd/nfsfh.c
index 5e2ed4b2a925..877da093ed2d 100644
--- a/fs/nfsd/nfsfh.c
+++ b/fs/nfsd/nfsfh.c
@@ -392,13 +392,7 @@ fh_verify(struct svc_rqst *rqstp, struct svc_fh *fhp, umode_t type, int access)
 skip_pseudoflavor_check:
 	/* Finally, check access permissions. */
 	error = nfsd_permission(rqstp, exp, dentry, access);
-
-	if (error) {
-		dprintk("fh_verify: %pd2 permission failure, "
-			"acc=%x, error=%d\n",
-			dentry,
-			access, ntohl(error));
-	}
+	trace_nfsd_fh_verify_err(rqstp, fhp, type, access, error);
 out:
 	if (error == nfserr_stale)
 		nfsd_stats_fh_stale_inc(exp);
diff --git a/fs/nfsd/trace.h b/fs/nfsd/trace.h
index 8467fd8f94c2..b6f3c1366a82 100644
--- a/fs/nfsd/trace.h
+++ b/fs/nfsd/trace.h
@@ -211,13 +211,55 @@ TRACE_EVENT(nfsd_fh_verify,
 		__entry->type = type;
 		__entry->access = access;
 	),
-	TP_printk("xid=0x%08x fh_hash=0x%08x inode=%p type=%s access=%s",
-		__entry->xid, __entry->fh_hash, __entry->inode,
+	TP_printk("xid=0x%08x fh_hash=0x%08x type=%s access=%s",
+		__entry->xid, __entry->fh_hash,
 		show_fs_file_type(__entry->type),
 		show_nfsd_may_flags(__entry->access)
 	)
 );
 
+TRACE_EVENT_CONDITION(nfsd_fh_verify_err,
+	TP_PROTO(
+		const struct svc_rqst *rqstp,
+		const struct svc_fh *fhp,
+		umode_t type,
+		int access,
+		__be32 error
+	),
+	TP_ARGS(rqstp, fhp, type, access, error),
+	TP_CONDITION(error),
+	TP_STRUCT__entry(
+		__field(unsigned int, netns_ino)
+		__sockaddr(server, rqstp->rq_xprt->xpt_remotelen)
+		__sockaddr(client, rqstp->rq_xprt->xpt_remotelen)
+		__field(u32, xid)
+		__field(u32, fh_hash)
+		__field(void *, inode)
+		__field(unsigned long, type)
+		__field(unsigned long, access)
+		__field(int, error)
+	),
+	TP_fast_assign(
+		__entry->netns_ino = SVC_NET(rqstp)->ns.inum;
+		__assign_sockaddr(server, &rqstp->rq_xprt->xpt_local,
+		       rqstp->rq_xprt->xpt_locallen);
+		__assign_sockaddr(client, &rqstp->rq_xprt->xpt_remote,
+				  rqstp->rq_xprt->xpt_remotelen);
+		__entry->xid = be32_to_cpu(rqstp->rq_xid);
+		__entry->fh_hash = knfsd_fh_hash(&fhp->fh_handle);
+		__entry->inode = d_inode(fhp->fh_dentry);
+		__entry->type = type;
+		__entry->access = access;
+		__entry->error = be32_to_cpu(error);
+	),
+	TP_printk("xid=0x%08x fh_hash=0x%08x type=%s access=%s error=%d",
+		__entry->xid, __entry->fh_hash,
+		show_fs_file_type(__entry->type),
+		show_nfsd_may_flags(__entry->access),
+		__entry->error
+	)
+);
+
 DECLARE_EVENT_CLASS(nfsd_fh_err_class,
 	TP_PROTO(struct svc_rqst *rqstp,
 		 struct svc_fh	*fhp,


