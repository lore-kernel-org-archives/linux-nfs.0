Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ie0-f181.google.com ([209.85.223.181]:57622 "EHLO
	mail-ie0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756407Ab3LaTkD (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 31 Dec 2013 14:40:03 -0500
Received: by mail-ie0-f181.google.com with SMTP id e14so13503665iej.12
        for <linux-nfs@vger.kernel.org>; Tue, 31 Dec 2013 11:40:02 -0800 (PST)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Cc: Kinglong Mee <kinglongmee@gmail.com>, Chuck Lever <chuck.lever@oracle.com>,
        Bruce Fields <bfields@fieldses.com>,
        Gareth Williams <gareth@garethwilliams.me.uk>
Subject: [PATCH 1/4] SUNRPC: Ensure xprt_connect_status handles all potential connection errors
Date: Tue, 31 Dec 2013 14:39:38 -0500
Message-Id: <1388518781-33571-1-git-send-email-trond.myklebust@primarydata.com>
In-Reply-To: <CAB6yy379-A8fgLpQo+ppx5V93P9pXcabvmBJNTZ5hXxeJMuxBg@mail.gmail.com>
References: <CAB6yy379-A8fgLpQo+ppx5V93P9pXcabvmBJNTZ5hXxeJMuxBg@mail.gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Currently, xprt_connect_status will convert connection error values such
as ECONNREFUSED, ECONNRESET, ... into EIO, which means that they never
get handled.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 net/sunrpc/xprt.c | 5 +++++
 1 file changed, 5 insertions(+)

diff --git a/net/sunrpc/xprt.c b/net/sunrpc/xprt.c
index 04199bc8416f..ddd198e90292 100644
--- a/net/sunrpc/xprt.c
+++ b/net/sunrpc/xprt.c
@@ -749,6 +749,11 @@ static void xprt_connect_status(struct rpc_task *task)
 	}
 
 	switch (task->tk_status) {
+	case -ECONNREFUSED:
+	case -ECONNRESET:
+	case -ECONNABORTED:
+	case -ENETUNREACH:
+	case -EHOSTUNREACH:
 	case -EAGAIN:
 		dprintk("RPC: %5u xprt_connect_status: retrying\n", task->tk_pid);
 		break;
-- 
1.8.4.2

