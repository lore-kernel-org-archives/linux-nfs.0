Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:63061 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932259Ab1DLRl1 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 12 Apr 2011 13:41:27 -0400
Message-ID: <4DA48EB0.40600@netapp.com>
Date: Tue, 12 Apr 2011 13:41:04 -0400
From: Bryan Schumaker <bjschuma@netapp.com>
To: Jiri Slaby <jslaby@suse.cz>
CC: "Myklebust, Trond" <Trond.Myklebust@netapp.com>,
        linux-kernel@vger.kernel.org, akpm@linux-foundation.org,
        mm-commits@vger.kernel.org, ML netdev <netdev@vger.kernel.org>,
        linux-nfs@vger.kernel.org, Jiri Slaby <jirislaby@gmail.com>
Subject: [PATCH] NFS: Fix infinite loop in gss_create_upcall()
References: <201103312224.p2VMOA5g000983@imap1.linux-foundation.org> <4D96E4C5.2080302@suse.cz> <1302122693.16786.0.camel@lade.trondhjem.org> <4D9D5CC9.2040002@suse.cz> <4DA36722.2020402@suse.cz> <4DA36758.4070203@suse.cz> <4DA36DB6.8060108@suse.cz>
In-Reply-To: <4DA36DB6.8060108@suse.cz>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 04/11/2011 05:08 PM, Jiri Slaby wrote:
> 
> Sorry for an extra message. I've just found out that there appears
> messages in dmesg:
> [   58.656048] RPC: AUTH_GSS upcall timed out.
> [   58.656050] Please check user daemon is running.
> [   88.656065] RPC: AUTH_GSS upcall timed out.
> [   88.656068] Please check user daemon is running.
> [  118.656077] RPC: AUTH_GSS upcall timed out.
> [  118.656080] Please check user daemon is running.
> [  148.656049] RPC: AUTH_GSS upcall timed out.
> [  148.656052] Please check user daemon is running.
> [  178.656046] RPC: AUTH_GSS upcall timed out.
> [  178.656049] Please check user daemon is running.
> 
> 
> I instrumented the code and it's stuck with trying RPC_AUTH_GSS_KRB5.
> 
> I don't use GSS at all.
> 
> regards,

Does this patch help?

- Bryan



There can be an infinite loop if gss_create_upcall() is called without
the userspace program running.  To prevent this, we return -EACCES if
we notice that pipe_version hasn't changed (indicating that the pipe
has not been opened).

Signed-off-by: Bryan Schumaker <bjschuma@netapp.com>
--
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 9bf41ea..8a03ee0 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -2224,8 +2224,9 @@ static int nfs4_proc_get_root(struct nfs_server *server, struct nfs_fh *fhandle,
 
 	for (i = 0; i < len; i++) {
 		status = nfs4_lookup_root_sec(server, fhandle, info, flav_array[i]);
-		if (status != -EPERM)
-			break;
+		if (status == -EPERM || status == -EACCES)
+			continue;
+		break;
 	}
 	if (status == 0)
 		status = nfs4_server_capabilities(server, fhandle);
diff --git a/net/sunrpc/auth_gss/auth_gss.c b/net/sunrpc/auth_gss/auth_gss.c
index f3914d0..339ba64 100644
--- a/net/sunrpc/auth_gss/auth_gss.c
+++ b/net/sunrpc/auth_gss/auth_gss.c
@@ -520,7 +520,7 @@ gss_refresh_upcall(struct rpc_task *task)
 		warn_gssd();
 		task->tk_timeout = 15*HZ;
 		rpc_sleep_on(&pipe_version_rpc_waitqueue, task, NULL);
-		return 0;
+		return -EAGAIN;
 	}
 	if (IS_ERR(gss_msg)) {
 		err = PTR_ERR(gss_msg);
@@ -563,10 +563,12 @@ retry:
 	if (PTR_ERR(gss_msg) == -EAGAIN) {
 		err = wait_event_interruptible_timeout(pipe_version_waitqueue,
 				pipe_version >= 0, 15*HZ);
+		if (pipe_version < 0) {
+			warn_gssd();
+			err = -EACCES;
+		}
 		if (err)
 			goto out;
-		if (pipe_version < 0)
-			warn_gssd();
 		goto retry;
 	}
 	if (IS_ERR(gss_msg)) {


