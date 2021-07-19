Return-Path: <linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-13.8 required=3.0 tests=BAYES_00,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_CR_TRAILER,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C5843C07E9D
	for <linux-nfs@archiver.kernel.org>; Mon, 19 Jul 2021 15:03:08 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by mail.kernel.org (Postfix) with ESMTP id B252961181
	for <linux-nfs@archiver.kernel.org>; Mon, 19 Jul 2021 15:03:08 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S242897AbhGSOW1 (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 19 Jul 2021 10:22:27 -0400
Received: from mail.kernel.org ([198.145.29.99]:56038 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S242909AbhGSOVS (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 19 Jul 2021 10:21:18 -0400
Received: by mail.kernel.org (Postfix) with ESMTPSA id AAA3B6112D;
        Mon, 19 Jul 2021 15:01:48 +0000 (UTC)
Subject: [PATCH 2/3] NFSD: Use new __string_len C macros for the nfs_dirent
 tracepoint
From:   Chuck Lever <chuck.lever@oracle.com>
To:     linux-kernel@vger.kernel.org, linux-nfs@vger.kernel.org
Cc:     rostedt@goodmis.org
Date:   Mon, 19 Jul 2021 11:01:48 -0400
Message-ID: <162670690799.60572.17887519121075367018.stgit@klimt.1015granger.net>
In-Reply-To: <162670659736.60572.10597769067889138558.stgit@klimt.1015granger.net>
References: <162670659736.60572.10597769067889138558.stgit@klimt.1015granger.net>
User-Agent: StGit/1.1
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Clean up.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 fs/nfsd/trace.h |   12 +++++-------
 1 file changed, 5 insertions(+), 7 deletions(-)

diff --git a/fs/nfsd/trace.h b/fs/nfsd/trace.h
index adaec43548d1..52a43acd546c 100644
--- a/fs/nfsd/trace.h
+++ b/fs/nfsd/trace.h
@@ -400,18 +400,16 @@ TRACE_EVENT(nfsd_dirent,
 	TP_STRUCT__entry(
 		__field(u32, fh_hash)
 		__field(u64, ino)
-		__field(int, len)
-		__dynamic_array(unsigned char, name, namlen)
+		__string_len(name, name, namlen)
 	),
 	TP_fast_assign(
 		__entry->fh_hash = fhp ? knfsd_fh_hash(&fhp->fh_handle) : 0;
 		__entry->ino = ino;
-		__entry->len = namlen;
-		memcpy(__get_str(name), name, namlen);
+		__assign_str_len(name, name, namlen)
 	),
-	TP_printk("fh_hash=0x%08x ino=%llu name=%.*s",
-		__entry->fh_hash, __entry->ino,
-		__entry->len, __get_str(name))
+	TP_printk("fh_hash=0x%08x ino=%llu name=%s",
+		__entry->fh_hash, __entry->ino, __get_str(name)
+	)
 )
 
 #include "state.h"


