Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:55376 "EHLO mx1.suse.de"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1750881AbdHRHNl (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 18 Aug 2017 03:13:41 -0400
From: NeilBrown <neilb@suse.com>
To: Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>
Date: Fri, 18 Aug 2017 17:12:51 +1000
Subject: [PATCH 1/8] SUNRPC: ECONNREFUSED should cause a rebind.
Cc: linux-nfs@vger.kernel.org
Message-ID: <150304037184.30218.7244179303036576085.stgit@noble>
In-Reply-To: <150304014011.30218.1636255532744321171.stgit@noble>
References: <150304014011.30218.1636255532744321171.stgit@noble>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

If you
 - mount and NFSv3 filesystem
 - do some file locking which requires the server
   to make a GRANT call back
 - unmount
 - mount again and do the same locking

then the second attempt at locking suffers a 30 second delay.
Unmounting and remounting causes lockd to stop and restart,
which causes it to bind to a new port.
The server still thinks the old port is valid and gets ECONNREFUSED
when trying to contact it.
ECONNREFUSED should be seen as a hard error that is not worth
retrying.  Rebinding is the only reasonable response.

This patch forces a rebind if that makes sense.

Signed-off-by: NeilBrown <neilb@suse.com>
---
 net/sunrpc/clnt.c |    8 ++++++++
 1 file changed, 8 insertions(+)

diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
index 2e49d1f892b7..69a9e5953744 100644
--- a/net/sunrpc/clnt.c
+++ b/net/sunrpc/clnt.c
@@ -1903,6 +1903,14 @@ call_connect_status(struct rpc_task *task)
 	task->tk_status = 0;
 	switch (status) {
 	case -ECONNREFUSED:
+		/* A positive refusal suggests a rebind is needed. */
+		if (RPC_IS_SOFTCONN(task))
+			break;
+		if (clnt->cl_autobind) {
+			rpc_force_rebind(clnt);
+			task->tk_action = call_bind;
+			return;
+		}
 	case -ECONNRESET:
 	case -ECONNABORTED:
 	case -ENETUNREACH:


