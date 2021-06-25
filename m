Return-Path: <linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-13.8 required=3.0 tests=BAYES_00,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_CR_TRAILER,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 25523C2B9F4
	for <linux-nfs@archiver.kernel.org>; Fri, 25 Jun 2021 15:12:52 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by mail.kernel.org (Postfix) with ESMTP id 0120061428
	for <linux-nfs@archiver.kernel.org>; Fri, 25 Jun 2021 15:12:51 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S229445AbhFYPPL (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Fri, 25 Jun 2021 11:15:11 -0400
Received: from mail.kernel.org ([198.145.29.99]:50608 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S229764AbhFYPPL (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 25 Jun 2021 11:15:11 -0400
Received: by mail.kernel.org (Postfix) with ESMTPSA id 6D2F461428;
        Fri, 25 Jun 2021 15:12:50 +0000 (UTC)
Subject: [PATCH] NFSD: Prevent a possible oops in the nfs_dirent() tracepoint
From:   Chuck Lever <chuck.lever@oracle.com>
To:     bfields@fieldses.org
Cc:     linux-nfs@vger.kernel.org
Date:   Fri, 25 Jun 2021 11:12:49 -0400
Message-ID: <162463396907.1820.8112792283525036426.stgit@klimt.1015granger.net>
User-Agent: StGit/1.1
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

The double copy of the string is a mistake, plus __assign_str()
uses strlen(), which is wrong to do on a string that isn't
guaranteed to be NUL-terminated.

Fixes: 6019ce0742ca ("NFSD: Add a tracepoint to record directory entry encoding")
Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 fs/nfsd/trace.h |    1 -
 1 file changed, 1 deletion(-)

diff --git a/fs/nfsd/trace.h b/fs/nfsd/trace.h
index 27a93ebd1d80..89dccced526a 100644
--- a/fs/nfsd/trace.h
+++ b/fs/nfsd/trace.h
@@ -408,7 +408,6 @@ TRACE_EVENT(nfsd_dirent,
 		__entry->ino = ino;
 		__entry->len = namlen;
 		memcpy(__get_str(name), name, namlen);
-		__assign_str(name, name);
 	),
 	TP_printk("fh_hash=0x%08x ino=%llu name=%.*s",
 		__entry->fh_hash, __entry->ino,


