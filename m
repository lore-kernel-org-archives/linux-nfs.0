Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f68.google.com ([209.85.214.68]:38261 "EHLO
        mail-it0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751241AbeC0OuA (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 27 Mar 2018 10:50:00 -0400
Received: by mail-it0-f68.google.com with SMTP id 19-v6so15621368itw.3
        for <linux-nfs@vger.kernel.org>; Tue, 27 Mar 2018 07:50:00 -0700 (PDT)
Subject: [PATCH v2 03/18] sunrpc: Update show_svc_xprt_flags() to include
 recently added flags
From: Chuck Lever <chuck.lever@oracle.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org
Date: Tue, 27 Mar 2018 10:49:53 -0400
Message-ID: <20180327144953.7710.43197.stgit@oracle-ib-101.nfsv4bat.org>
In-Reply-To: <20180327144420.7710.82288.stgit@oracle-ib-101.nfsv4bat.org>
References: <20180327144420.7710.82288.stgit@oracle-ib-101.nfsv4bat.org>
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

