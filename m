Return-Path: <linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-13.8 required=3.0 tests=BAYES_00,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_CR_TRAILER,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3BA82C433B4
	for <linux-nfs@archiver.kernel.org>; Fri, 14 May 2021 19:57:44 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by mail.kernel.org (Postfix) with ESMTP id 213A661574
	for <linux-nfs@archiver.kernel.org>; Fri, 14 May 2021 19:57:44 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S233285AbhENT6y (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Fri, 14 May 2021 15:58:54 -0400
Received: from mail.kernel.org ([198.145.29.99]:57698 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S233312AbhENT6w (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 14 May 2021 15:58:52 -0400
Received: by mail.kernel.org (Postfix) with ESMTPSA id B0FE461574;
        Fri, 14 May 2021 19:57:39 +0000 (UTC)
Subject: [PATCH v3 24/24] NFSD: Update nfsd_cb_args tracepoint
From:   Chuck Lever <chuck.lever@oracle.com>
To:     linux-nfs@vger.kernel.org
Cc:     dwysocha@redhat.com, bfields@fieldses.org
Date:   Fri, 14 May 2021 15:57:39 -0400
Message-ID: <162102225898.10915.3599061943005270294.stgit@klimt.1015granger.net>
In-Reply-To: <162102191240.10915.5003178983503027218.stgit@klimt.1015granger.net>
References: <162102191240.10915.5003178983503027218.stgit@klimt.1015granger.net>
User-Agent: StGit/1.1
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Clean-up: Re-order the display of IP address and client ID to be
consistent with other _cb_ tracepoints.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 fs/nfsd/trace.h |    6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/fs/nfsd/trace.h b/fs/nfsd/trace.h
index daadcb54886d..10cc3aaf1089 100644
--- a/fs/nfsd/trace.h
+++ b/fs/nfsd/trace.h
@@ -857,9 +857,9 @@ TRACE_EVENT(nfsd_cb_args,
 		memcpy(__entry->addr, &conn->cb_addr,
 			sizeof(struct sockaddr_in6));
 	),
-	TP_printk("client %08x:%08x callback addr=%pISpc prog=%u ident=%u",
-		__entry->cl_boot, __entry->cl_id,
-		__entry->addr, __entry->prog, __entry->ident)
+	TP_printk("addr=%pISpc client %08x:%08x prog=%u ident=%u",
+		__entry->addr, __entry->cl_boot, __entry->cl_id,
+		__entry->prog, __entry->ident)
 );
 
 TRACE_EVENT(nfsd_cb_nodelegs,


