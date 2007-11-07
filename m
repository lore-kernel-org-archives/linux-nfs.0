From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 6/7] SUNRPC: Make call_status()/call_decode()
	call	xprt_force_disconnect()
Date: Tue, 06 Nov 2007 19:40:06 -0500
Message-ID: <20071107004006.13713.47336.stgit@heimdal.trondhjem.org>
References: <20071107003834.13713.73536.stgit@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfsv4@linux-nfs.org, nfs@lists.sourceforge.net
To: Chuck Lever <Chuck.Lever@oracle.com>,
	Tom Talpey <Thomas.Talpey@netapp.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IpYvr-0002RU-6D
	for nfs@lists.sourceforge.net; Tue, 06 Nov 2007 16:38:11 -0800
Received: from c-69-242-210-120.hsd1.mi.comcast.net ([69.242.210.120]
	helo=heimdal.trondhjem.org)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IpYvw-0005F6-QR
	for nfs@lists.sourceforge.net; Tue, 06 Nov 2007 16:38:17 -0800
In-Reply-To: <20071107003834.13713.73536.stgit@heimdal.trondhjem.org>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

From: Trond Myklebust <Trond.Myklebust@netapp.com>

Move the calls to xprt_disconnect() over to xprt_force_disconnect() in
order to enable the transport layer to manage the state of the
XPRT_CONNECTED flag.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---

 net/sunrpc/clnt.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
index 76be83e..046d8f6 100644
--- a/net/sunrpc/clnt.c
+++ b/net/sunrpc/clnt.c
@@ -1137,7 +1137,7 @@ call_status(struct rpc_task *task)
 	case -ETIMEDOUT:
 		task->tk_action = call_timeout;
 		if (task->tk_client->cl_discrtry)
-			xprt_disconnect(task->tk_xprt);
+			xprt_force_disconnect(task->tk_xprt);
 		break;
 	case -ECONNREFUSED:
 	case -ENOTCONN:
@@ -1260,7 +1260,7 @@ out_retry:
 	req->rq_received = req->rq_private_buf.len = 0;
 	task->tk_status = 0;
 	if (task->tk_client->cl_discrtry)
-		xprt_disconnect(task->tk_xprt);
+		xprt_force_disconnect(task->tk_xprt);
 }
 
 /*


-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >> http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
