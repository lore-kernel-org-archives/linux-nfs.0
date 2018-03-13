Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f65.google.com ([209.85.214.65]:38038 "EHLO
        mail-it0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S935016AbeCMPn5 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 13 Mar 2018 11:43:57 -0400
Received: by mail-it0-f65.google.com with SMTP id j7-v6so702671ita.3
        for <linux-nfs@vger.kernel.org>; Tue, 13 Mar 2018 08:43:57 -0700 (PDT)
Subject: [PATCH 03/15] sunrpc: Update show_svc_xprt_flags() to include
 recently added flags
From: Chuck Lever <chuck.lever@oracle.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org
Date: Tue, 13 Mar 2018 11:43:55 -0400
Message-ID: <20180313154355.21531.53207.stgit@klimt.1015granger.net>
In-Reply-To: <20180313154053.21531.86316.stgit@klimt.1015granger.net>
References: <20180313154053.21531.86316.stgit@klimt.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

XPT_KILL_TEMP was added by commit 546125d16142 ("sunrpc: don't call
sleeping functions from the notifier block callbacks"), and
XPT_CONG_CTRL was added by commit 362142b25843 ("sunrpc: flag
transports as having congestion control") .

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 include/trace/events/sunrpc.h |    4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/include/trace/events/sunrpc.h b/include/trace/events/sunrpc.h
index 970c91a..a231444 100644
--- a/include/trace/events/sunrpc.h
+++ b/include/trace/events/sunrpc.h
@@ -591,7 +591,9 @@
 		{ (1UL << XPT_OLD),		"XPT_OLD"},		\
 		{ (1UL << XPT_LISTENER),	"XPT_LISTENER"},	\
 		{ (1UL << XPT_CACHE_AUTH),	"XPT_CACHE_AUTH"},	\
-		{ (1UL << XPT_LOCAL),		"XPT_LOCAL"})
+		{ (1UL << XPT_LOCAL),		"XPT_LOCAL"},		\
+		{ (1UL << XPT_KILL_TEMP),	"XPT_KILL_TEMP"},	\
+		{ (1UL << XPT_CONG_CTRL),	"XPT_CONG_CTRL"})
 
 TRACE_EVENT(svc_xprt_do_enqueue,
 	TP_PROTO(struct svc_xprt *xprt, struct svc_rqst *rqst),

