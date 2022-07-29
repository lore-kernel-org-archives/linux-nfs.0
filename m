Return-Path: <linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 913F2C00144
	for <linux-nfs@archiver.kernel.org>; Fri, 29 Jul 2022 16:48:17 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S236366AbiG2QsP (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Fri, 29 Jul 2022 12:48:15 -0400
Received: from lindbergh.monkeyblade.net ([23.128.96.19]:38202 "EHLO
        lindbergh.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S236492AbiG2Qry (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 29 Jul 2022 12:47:54 -0400
Received: from dfw.source.kernel.org (dfw.source.kernel.org [IPv6:2604:1380:4641:c500::1])
        by lindbergh.monkeyblade.net (Postfix) with ESMTPS id 9C08789A7F
        for <linux-nfs@vger.kernel.org>; Fri, 29 Jul 2022 09:47:32 -0700 (PDT)
Received: from smtp.kernel.org (relay.kernel.org [52.25.139.140])
        (using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
        (No client certificate requested)
        by dfw.source.kernel.org (Postfix) with ESMTPS id 7137361E62
        for <linux-nfs@vger.kernel.org>; Fri, 29 Jul 2022 16:47:17 +0000 (UTC)
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 892FDC433C1;
        Fri, 29 Jul 2022 16:47:16 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
        s=k20201202; t=1659113236;
        bh=80p2Zq4IrZ1ZXaM2qm5e/a2ZSJB0WlTqsniphdRRTYc=;
        h=From:To:Cc:Subject:Date:From;
        b=WBHN1vQ1Yf6efltf3bcismc54uWbZLmqToPDr/xiEH1bkALdD3oHxincPAx+qhsz3
         jUrbAXH7iMVqI53qVthdAIXXx0LmO6NoDOXPjjQKhgpi8VYFuykmmMir1CVRKaeyzD
         u+gN8vBtZ027lqNTOCh9m5pQj8see5308RQJzhb5qnAp5pBFZOm7/fCn8RyX1V7VaF
         N4EKbu5/OFj0BP2GyDcN8mBWUQDSpUdfuHhkuYsykIXfaVfNv5WXQAWHDS69k2pI8i
         1ptK+ETDm3GRcUJzGAhmhmpHfm5LHLJhRt7cSIBXugE5/QeMq1Noso8kBkYKnS5Tda
         gWweAsHGEycvQ==
From:   Jeff Layton <jlayton@kernel.org>
To:     chuck.lever@oracle.com
Cc:     linux-nfs@vger.kernel.org
Subject: [PATCH 1/3] nfsd: add new tracepoint in nfsd_open_break_lease
Date:   Fri, 29 Jul 2022 12:47:13 -0400
Message-Id: <20220729164715.75702-1-jlayton@kernel.org>
X-Mailer: git-send-email 2.37.1
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Signed-off-by: Jeff Layton <jlayton@kernel.org>
---
 fs/nfsd/trace.h | 16 ++++++++++++++++
 fs/nfsd/vfs.c   |  2 ++
 2 files changed, 18 insertions(+)

diff --git a/fs/nfsd/trace.h b/fs/nfsd/trace.h
index 96bb6629541e..38fb1ca31010 100644
--- a/fs/nfsd/trace.h
+++ b/fs/nfsd/trace.h
@@ -531,6 +531,22 @@ DEFINE_STATEID_EVENT(open);
 DEFINE_STATEID_EVENT(deleg_read);
 DEFINE_STATEID_EVENT(deleg_recall);
 
+TRACE_EVENT(nfsd_open_break_lease,
+	TP_PROTO(struct inode *inode,
+		 int access),
+	TP_ARGS(inode, access),
+	TP_STRUCT__entry(
+		__field(void *, inode)
+		__field(int, access)
+	),
+	TP_fast_assign(
+		__entry->inode = inode;
+		__entry->access = access;
+	),
+	TP_printk("inode=%p access=%s", __entry->inode,
+		  show_nfsd_may_flags(__entry->access))
+)
+
 DECLARE_EVENT_CLASS(nfsd_stateseqid_class,
 	TP_PROTO(u32 seqid, const stateid_t *stp),
 	TP_ARGS(seqid, stp),
diff --git a/fs/nfsd/vfs.c b/fs/nfsd/vfs.c
index d79db56475d4..0edfe6ff7d22 100644
--- a/fs/nfsd/vfs.c
+++ b/fs/nfsd/vfs.c
@@ -729,6 +729,8 @@ int nfsd_open_break_lease(struct inode *inode, int access)
 {
 	unsigned int mode;
 
+	trace_nfsd_open_break_lease(inode, access);
+
 	if (access & NFSD_MAY_NOT_BREAK_LEASE)
 		return 0;
 	mode = (access & NFSD_MAY_WRITE) ? O_WRONLY : O_RDONLY;
-- 
2.37.1

