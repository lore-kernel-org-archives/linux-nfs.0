Return-Path: <linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-13.8 required=3.0 tests=BAYES_00,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_CR_TRAILER,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5C4E8C433B4
	for <linux-nfs@archiver.kernel.org>; Fri, 14 May 2021 19:56:41 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by mail.kernel.org (Postfix) with ESMTP id 3EF7C61285
	for <linux-nfs@archiver.kernel.org>; Fri, 14 May 2021 19:56:41 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S233100AbhENT5v (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Fri, 14 May 2021 15:57:51 -0400
Received: from mail.kernel.org ([198.145.29.99]:57416 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S233223AbhENT5u (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 14 May 2021 15:57:50 -0400
Received: by mail.kernel.org (Postfix) with ESMTPSA id 4E97761285;
        Fri, 14 May 2021 19:56:38 +0000 (UTC)
Subject: [PATCH v3 14/24] NFSD: Drop TRACE_DEFINE_ENUM for NFSD4_CB_<state>
 macros
From:   Chuck Lever <chuck.lever@oracle.com>
To:     linux-nfs@vger.kernel.org
Cc:     dwysocha@redhat.com, bfields@fieldses.org
Date:   Fri, 14 May 2021 15:56:37 -0400
Message-ID: <162102219757.10915.284791415112845033.stgit@klimt.1015granger.net>
In-Reply-To: <162102191240.10915.5003178983503027218.stgit@klimt.1015granger.net>
References: <162102191240.10915.5003178983503027218.stgit@klimt.1015granger.net>
User-Agent: StGit/1.1
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

TRACE_DEFINE_ENUM() is necessary for enum {} but not for C macros.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 fs/nfsd/trace.h |    5 -----
 1 file changed, 5 deletions(-)

diff --git a/fs/nfsd/trace.h b/fs/nfsd/trace.h
index 39b7caea4664..1c43e6647d1e 100644
--- a/fs/nfsd/trace.h
+++ b/fs/nfsd/trace.h
@@ -877,11 +877,6 @@ TRACE_EVENT(nfsd_cb_nodelegs,
 	TP_printk("client %08x:%08x", __entry->cl_boot, __entry->cl_id)
 )
 
-TRACE_DEFINE_ENUM(NFSD4_CB_UP);
-TRACE_DEFINE_ENUM(NFSD4_CB_UNKNOWN);
-TRACE_DEFINE_ENUM(NFSD4_CB_DOWN);
-TRACE_DEFINE_ENUM(NFSD4_CB_FAULT);
-
 #define show_cb_state(val)						\
 	__print_symbolic(val,						\
 		{ NFSD4_CB_UP,		"UP" },				\


