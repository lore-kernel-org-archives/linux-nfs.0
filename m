Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qg0-f50.google.com ([209.85.192.50]:32947 "EHLO
	mail-qg0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751619AbbJELC5 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 5 Oct 2015 07:02:57 -0400
Received: by qgev79 with SMTP id v79so145481408qge.0
        for <linux-nfs@vger.kernel.org>; Mon, 05 Oct 2015 04:02:56 -0700 (PDT)
From: Jeff Layton <jlayton@poochiereds.net>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        Al Viro <viro@ZenIV.linux.org.uk>
Subject: [PATCH v5 08/20] nfsd: move include of state.h from trace.c to trace.h
Date: Mon,  5 Oct 2015 07:02:30 -0400
Message-Id: <1444042962-6947-9-git-send-email-jeff.layton@primarydata.com>
In-Reply-To: <1444042962-6947-1-git-send-email-jeff.layton@primarydata.com>
References: <1444042962-6947-1-git-send-email-jeff.layton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Any file which includes trace.h will need to include state.h, even if
they aren't using any state tracepoints. Ensure that we include any
headers that might be needed in trace.h instead of relying on the
*.c files to have the right ones.

Signed-off-by: Jeff Layton <jeff.layton@primarydata.com>
Reviewed-by: Christoph Hellwig <hch@lst.de>
---
 fs/nfsd/trace.c | 2 --
 fs/nfsd/trace.h | 2 ++
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/fs/nfsd/trace.c b/fs/nfsd/trace.c
index 82f89070594c..90967466a1e5 100644
--- a/fs/nfsd/trace.c
+++ b/fs/nfsd/trace.c
@@ -1,5 +1,3 @@
 
-#include "state.h"
-
 #define CREATE_TRACE_POINTS
 #include "trace.h"
diff --git a/fs/nfsd/trace.h b/fs/nfsd/trace.h
index c668520c344b..0befe762762b 100644
--- a/fs/nfsd/trace.h
+++ b/fs/nfsd/trace.h
@@ -9,6 +9,8 @@
 
 #include <linux/tracepoint.h>
 
+#include "state.h"
+
 DECLARE_EVENT_CLASS(nfsd_stateid_class,
 	TP_PROTO(stateid_t *stp),
 	TP_ARGS(stp),
-- 
2.4.3

