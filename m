Return-Path: <linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 52DD9C3527E
	for <linux-nfs@archiver.kernel.org>; Mon,  4 Apr 2022 21:18:33 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S240260AbiDDVUN (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 4 Apr 2022 17:20:13 -0400
Received: from lindbergh.monkeyblade.net ([23.128.96.19]:41154 "EHLO
        lindbergh.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1379819AbiDDSLJ (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 4 Apr 2022 14:11:09 -0400
Received: from dfw.source.kernel.org (dfw.source.kernel.org [IPv6:2604:1380:4641:c500::1])
        by lindbergh.monkeyblade.net (Postfix) with ESMTPS id D9D531D0C2
        for <linux-nfs@vger.kernel.org>; Mon,  4 Apr 2022 11:09:12 -0700 (PDT)
Received: from smtp.kernel.org (relay.kernel.org [52.25.139.140])
        (using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
        (No client certificate requested)
        by dfw.source.kernel.org (Postfix) with ESMTPS id 7716160DC4
        for <linux-nfs@vger.kernel.org>; Mon,  4 Apr 2022 18:09:12 +0000 (UTC)
Received: by smtp.kernel.org (Postfix) with ESMTPSA id C353FC2BBE4
        for <linux-nfs@vger.kernel.org>; Mon,  4 Apr 2022 18:09:11 +0000 (UTC)
Subject: [PATCH v1 2/6] SUNRPC: Fix the svc_deferred_event trace class
From:   Chuck Lever <chuck.lever@oracle.com>
To:     linux-nfs@vger.kernel.org
Date:   Mon, 04 Apr 2022 14:09:10 -0400
Message-ID: <164909575064.3716.97945409534409723.stgit@manet.1015granger.net>
In-Reply-To: <164909503892.3716.8666091898179474248.stgit@manet.1015granger.net>
References: <164909503892.3716.8666091898179474248.stgit@manet.1015granger.net>
User-Agent: StGit/1.5
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Fix a NULL deref crash that occurs when an svc_rqst is deferred
while the sunrpc tracing subsystem is enabled.

svc_revisit() sets dr->xprt to NULL, so it can't be relied upon in
the tracepoint to provide the remote's address. Commit ece200ddd54b
("sunrpc: Save remote presentation address in svc_xprt for trace
events") changed these tracepoints to use the transport's pre-
formatted address string in the transport, but clearly that will not
work here. Change the tracepoints back to using the
svc_deferred_req::addr field. User space support for the %pI format
specifier is in the pipeline and should be available soon.

Note that older kernels suffer from this issue, however:
- It won't crash if sunrpc tracing is not enabled
- Deferred requests are quite rare
- __sockaddr() and friends are available only in v5.18 and newer
- This code has churned quite a bit in the past 2-3 years, so each
  stable kernel would likely need its own variant of the fix
- A mechanism to test such fixes is available only later in this
  patch series

Thus I don't currently view this fix as a high priority for stable.
However, if someone is motivated, a specific fix that applies to any
recent stable kernel should not be difficult to construct and test.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 include/trace/events/sunrpc.h |    8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/include/trace/events/sunrpc.h b/include/trace/events/sunrpc.h
index 0f34f13ebd55..de099ca585d7 100644
--- a/include/trace/events/sunrpc.h
+++ b/include/trace/events/sunrpc.h
@@ -2016,18 +2016,18 @@ DECLARE_EVENT_CLASS(svc_deferred_event,
 	TP_STRUCT__entry(
 		__field(const void *, dr)
 		__field(u32, xid)
-		__string(addr, dr->xprt->xpt_remotebuf)
+		__sockaddr(addr, dr->addrlen)
 	),
 
 	TP_fast_assign(
 		__entry->dr = dr;
 		__entry->xid = be32_to_cpu(*(__be32 *)(dr->args +
 						       (dr->xprt_hlen>>2)));
-		__assign_str(addr, dr->xprt->xpt_remotebuf);
+		__assign_sockaddr(addr, &dr->addr, dr->addrlen);
 	),
 
-	TP_printk("addr=%s dr=%p xid=0x%08x", __get_str(addr), __entry->dr,
-		__entry->xid)
+	TP_printk("addr=%pISpc dr=%p xid=0x%08x", __get_sockaddr(addr),
+		__entry->dr, __entry->xid)
 );
 
 #define DEFINE_SVC_DEFERRED_EVENT(name) \


