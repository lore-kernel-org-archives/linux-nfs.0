Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:29130 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752709Ab2F0UFo (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 27 Jun 2012 16:05:44 -0400
From: andros@netapp.com
To: trond.myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org, Andy Adamson <andros@netapp.com>
Subject: [PATCH 1/1] SUNRPC handle EKEYEXPIRED in call_refreshresult
Date: Wed, 27 Jun 2012 16:05:35 -0400
Message-Id: <1340827535-3062-2-git-send-email-andros@netapp.com>
In-Reply-To: <1340827535-3062-1-git-send-email-andros@netapp.com>
References: <1340827535-3062-1-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

When an RPCSEC_GSS context has expired or is non-existent, and the user
(Kerberos) credentials have also expired or are non-existent, the client
retries to refresh the context for ever and the application
hangs. The user is not prompted to refresh/establish their credentials.

Move the -EKEYEXPIRED handling into the RPC layer. Try tk_cred_retry number
of times to refresh the gss_context, and then pass -EPERM to application.

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 fs/nfs/nfs4proc.c |    2 --
 net/sunrpc/clnt.c |    4 ++++
 2 files changed, 4 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 5a7b372..2f291b3 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -342,7 +342,6 @@ static int nfs4_handle_exception(struct nfs_server *server, int errorcode, struc
 			}
 		case -NFS4ERR_GRACE:
 		case -NFS4ERR_DELAY:
-		case -EKEYEXPIRED:
 			ret = nfs4_delay(server->client, &exception->timeout);
 			if (ret != 0)
 				break;
@@ -3939,7 +3938,6 @@ nfs4_async_handle_error(struct rpc_task *task, const struct nfs_server *server,
 		case -NFS4ERR_DELAY:
 			nfs_inc_server_stats(server, NFSIOS_DELAY);
 		case -NFS4ERR_GRACE:
-		case -EKEYEXPIRED:
 			rpc_delay(task, NFS4_POLL_RETRY_MAX);
 			task->tk_status = 0;
 			return -EAGAIN;
diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
index f56f045..a94fc0c 100644
--- a/net/sunrpc/clnt.c
+++ b/net/sunrpc/clnt.c
@@ -1334,8 +1334,12 @@ call_refreshresult(struct rpc_task *task)
 		return;
 	case -ETIMEDOUT:
 		rpc_delay(task, 3*HZ);
+	case -EKEYEXPIRED:
+		status = -EPERM;
+		goto cred_retry;
 	case -EAGAIN:
 		status = -EACCES;
+cred_retry:
 		if (!task->tk_cred_retry)
 			break;
 		task->tk_cred_retry--;
-- 
1.7.7.6

