Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qa0-f41.google.com ([209.85.216.41]:35477 "EHLO
	mail-qa0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932977AbaLJTIb (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 10 Dec 2014 14:08:31 -0500
Received: by mail-qa0-f41.google.com with SMTP id f12so2485051qad.0
        for <linux-nfs@vger.kernel.org>; Wed, 10 Dec 2014 11:08:31 -0800 (PST)
From: Jeff Layton <jlayton@primarydata.com>
To: bfields@fieldses.org
Cc: linux-kernel@vger.kernel.org, linux-nfs@vger.kernel.org,
        Tejun Heo <tj@kernel.org>, Al Viro <viro@zeniv.linux.org.uk>,
        NeilBrown <neilb@suse.de>
Subject: [PATCH v2 15/16] sunrpc: print the svc_rqst pointer value in svc_process tracepoint
Date: Wed, 10 Dec 2014 14:07:59 -0500
Message-Id: <1418238480-18857-16-git-send-email-jlayton@primarydata.com>
In-Reply-To: <1418238480-18857-1-git-send-email-jlayton@primarydata.com>
References: <1418238480-18857-1-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Jeff Layton <jlayton@primarydata.com>
---
 include/trace/events/sunrpc.h | 6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff --git a/include/trace/events/sunrpc.h b/include/trace/events/sunrpc.h
index 41e09a1b962d..0d54473d9b37 100644
--- a/include/trace/events/sunrpc.h
+++ b/include/trace/events/sunrpc.h
@@ -454,6 +454,7 @@ DECLARE_EVENT_CLASS(svc_rqst_status,
 	TP_ARGS(rqst, status),
 
 	TP_STRUCT__entry(
+		__field(struct svc_rqst *, rqst)
 		__field(struct sockaddr *, addr)
 		__field(__be32, xid)
 		__field(int, dropme)
@@ -462,14 +463,15 @@ DECLARE_EVENT_CLASS(svc_rqst_status,
 	),
 
 	TP_fast_assign(
+		__entry->rqst = rqst;
 		__entry->addr = (struct sockaddr *)&rqst->rq_addr;
 		__entry->xid = rqst->rq_xid;
 		__entry->status = status;
 		__entry->flags = rqst->rq_flags;
 	),
 
-	TP_printk("addr=%pIScp rq_xid=0x%x status=%d flags=%s",
-		__entry->addr, be32_to_cpu(__entry->xid),
+	TP_printk("rqst=0x%p addr=%pIScp rq_xid=0x%x status=%d flags=%s",
+		__entry->rqst, __entry->addr, be32_to_cpu(__entry->xid),
 		__entry->status, show_rqstp_flags(__entry->flags))
 );
 
-- 
2.1.0

