Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from discipline.rit.edu ([129.21.6.207]:18137 "HELO
	discipline.rit.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1757303AbbLBOUE (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 2 Dec 2015 09:20:04 -0500
From: Andrew Elble <aweits@rit.edu>
To: linux-nfs@vger.kernel.org
Cc: Andrew Elble <aweits@rit.edu>
Subject: [PATCH] nfs: fix missing assignment in nfs4_sequence_done tracepoint
Date: Wed,  2 Dec 2015 09:19:43 -0500
Message-Id: <1449065983-24024-1-git-send-email-aweits@rit.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

status_flags not set

Signed-off-by: Andrew Elble <aweits@rit.edu>
---
 fs/nfs/nfs4trace.h | 1 +
 1 file changed, 1 insertion(+)

diff --git a/fs/nfs/nfs4trace.h b/fs/nfs/nfs4trace.h
index 671cf68fe56b..4c1015462a81 100644
--- a/fs/nfs/nfs4trace.h
+++ b/fs/nfs/nfs4trace.h
@@ -321,6 +321,7 @@ TRACE_EVENT(nfs4_sequence_done,
 			__entry->highest_slotid = res->sr_highest_slotid;
 			__entry->target_highest_slotid =
 					res->sr_target_highest_slotid;
+			__entry->status_flags = res->sr_status_flags;
 			__entry->error = res->sr_status;
 		),
 		TP_printk(
-- 
2.6.3

