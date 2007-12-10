From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 07/27] NFS: Enable NFS client to generate CLIENTID strings
	with IPv6 addresses
Date: Mon, 10 Dec 2007 14:57:09 -0500
Message-ID: <20071210195709.2823.14121.stgit@manray.1015granger.net>
References: <20071210195106.2823.43884.stgit@manray.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: aurelien.charbon-Z51IpKcfGtLk1uMJSBkQmQ@public.gmane.org, linux-nfs@vger.kernel.org
To: trond.myklebust@fys.uio.no
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from flpi102.sbcis.sbc.com ([207.115.20.71]:52400 "EHLO
	flpi102.prodigy.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751613AbXLJUKI (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 10 Dec 2007 15:10:08 -0500
In-Reply-To: <20071210195106.2823.43884.stgit-meopP2rzCrTwdl/1UfZZQIVfYA8g3rJ/@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

We recently added methods to RPC transports that provide string versions of
the remote peer address information.  Convert the NFSv4 SETCLIENTID
procedure to use those methods instead of building the client ID out of
whole cloth.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
Cc: Aurelien Charbon <aurelien.charbon-Z51IpKcfGtLk1uMJSBkQmQ@public.gmane.org>
---

 fs/nfs/nfs4proc.c |   12 ++++++++----
 1 files changed, 8 insertions(+), 4 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index f03d9d5..ec58d1e 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -2912,14 +2912,18 @@ int nfs4_proc_setclientid(struct nfs_client *clp, u32 program, unsigned short po
 
 	for(;;) {
 		setclientid.sc_name_len = scnprintf(setclientid.sc_name,
-				sizeof(setclientid.sc_name), "%s/%u.%u.%u.%u %s %u",
-				clp->cl_ipaddr, NIPQUAD(clp->cl_addr.sin_addr),
+				sizeof(setclientid.sc_name), "%s/%s %s %u",
+				clp->cl_ipaddr,
+				rpc_peeraddr2str(clp->cl_rpcclient,
+							RPC_DISPLAY_ADDR),
 				cred->cr_ops->cr_name,
 				clp->cl_id_uniquifier);
 		setclientid.sc_netid_len = scnprintf(setclientid.sc_netid,
-				sizeof(setclientid.sc_netid), "tcp");
+				sizeof(setclientid.sc_netid),
+				rpc_peeraddr2str(clp->cl_rpcclient,
+							RPC_DISPLAY_NETID));
 		setclientid.sc_uaddr_len = scnprintf(setclientid.sc_uaddr,
-				sizeof(setclientid.sc_uaddr), "%s.%d.%d",
+				sizeof(setclientid.sc_uaddr), "%s.%u.%u",
 				clp->cl_ipaddr, port >> 8, port & 255);
 
 		status = rpc_call_sync(clp->cl_rpcclient, &msg, 0);

